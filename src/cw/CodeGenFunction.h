/// \file CodeGenFunction.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstdint>
#include <optional>
#include <unordered_map>
#include <variant>
#include <vector>

#include <llvm/ADT/ArrayRef.h>
#include <llvm/ADT/STLFunctionalExtras.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/Support/Alignment.h>

#include "CodeGen.h"
#include "ast.h"

namespace cw::codegen_detail {

enum class Overlap { DoesNotOverlap, MayOverlap };

/// \brief Object storage information retained alongside an opaque LLVM pointer.
struct Address {
  llvm::Value* pointer{};
  llvm::Type* element_type{};
  llvm::Align alignment{};
  const Type* semantic_type{};
  Overlap overlap{Overlap::MayOverlap};

  explicit operator bool() const { return pointer != nullptr; }
};

/// \brief A successful result: no delivered value, a scalar or reference binding, or aggregate storage.
/// Emission failure is represented separately by the caller.
using RValue = std::variant<std::monostate, llvm::Value*, Address>;

struct ReturnValueSlot {
  Address address;
  bool is_unused{};
};

/// \brief Owns transient emission state for one LLVM function, including synthesized helpers.
class CodeGenFunction {
  enum class EvaluationOrder { LeftToRight, RightToLeft };

  struct BreakContinue {
    llvm::BasicBlock* break_block{};
    llvm::BasicBlock* continue_block{};
    std::size_t cleanup_depth{};
  };

  struct Cleanup {
    Address address;
    const Type* type{};
    // Empty for unconditional cleanup; otherwise a dominating SSA condition or flag storage.
    std::variant<std::monostate, llvm::Value*, Address> condition;
  };

  struct LocalCleanup {
    enum class Kind { Destroy, ExitVirtualDispatch };

    Address address;
    const Type* type{};
    const VarDecl* declaration{};
    bool active{};
    Kind kind{Kind::Destroy};
  };

  class ConditionalEvaluation {
    CodeGenFunction& owner_;
    llvm::BasicBlock* previous_entry_;
    llvm::Value* previous_condition_;
    bool previous_inverted_;

   public:
    ConditionalEvaluation(CodeGenFunction& owner, llvm::BasicBlock* entry, llvm::BasicBlock* arm);
    ~ConditionalEvaluation();
  };

  CodeGen& codegen_;
  llvm::Function& function_;
  llvm::IRBuilder<> builder_;
  // Static allocas stay in place throughout function emission.
  llvm::AllocaInst* last_alloca_{};
  std::unordered_map<const VarDecl*, Address> locals_;
  std::vector<BreakContinue> break_continue_stack_;
  std::vector<LocalCleanup> local_cleanups_;
  std::vector<Cleanup> temporary_cleanups_;
  Address this_address_;
  llvm::BasicBlock* conditional_entry_{};
  llvm::Value* conditional_condition_{};
  bool conditional_inverted_{};
  llvm::BasicBlock* return_block_{};

 public:
  CodeGenFunction(CodeGen& codegen, llvm::Function& function);
  bool Generate(const FunctionDecl& declaration, const CodeGen::FunctionInfo& function_info);
  void GenerateThunk(const VTableEntry& entry, const CodeGen::FunctionInfo& info, llvm::Function& implementation);
  bool GenerateGlobalVarInit(const VarGroupDecl& declaration);
  void GenerateGlobalInit(llvm::ArrayRef<llvm::Function*> initializers);
  bool GenerateGlobalDestructor(const VarDecl& declaration);

 private:
  void StartFunction();
  void FinishFunction();
  Address MakeAddress(llvm::Value* pointer, llvm::Type* element_type, const Type* semantic_type = nullptr,
                      Overlap overlap = Overlap::MayOverlap) const;
  Address CreateStorage(llvm::Type* type, llvm::StringRef name, const Type* semantic_type = nullptr);
  Address DeclareVariable(const VarDecl& declaration, llvm::StringRef name = {});
  Address GetStorage(const VarDecl& declaration);
  Address EmitArrayElement(Address array, llvm::Value* index, bool in_bounds = false);
  Address EmitStructElement(Address object, unsigned index, llvm::StringRef name);
  Address EmitBase(Address object, const StructDecl& declaration);
  Address EmitField(Address object, const StructDecl& declaration, const FieldDecl& field);
  std::uint64_t GetOperationSize(Address address) const;
  void EmitAggregateCopy(Address destination, Address source);
  llvm::Value* EmitCoercedLoad(Address source, llvm::Type* type);
  void EmitCoercedStore(llvm::Value* value, Address destination);
  llvm::Value* EmitLoadOfScalar(Address address, const Type& type);
  void EmitStoreOfScalar(llvm::Value* value, Address address, const Type& type);
  llvm::BasicBlock* CreateBasicBlock(llvm::StringRef name);
  bool HaveInsertPoint() const;
  void EmitBranch(llvm::BasicBlock* target);
  void EmitBlock(llvm::BasicBlock* block, bool is_finished = false);
  bool EmitBranchOnBoolExpr(const Expr& expression, llvm::BasicBlock* true_block, llvm::BasicBlock* false_block);
  bool EmitCondition(const Expr& expression, llvm::BasicBlock* true_block, llvm::BasicBlock* false_block);
  bool EmitFullExpr(const Expr& expression);
  void AddTemporaryCleanup(Address address, const Type& type);
  bool EmitTemporaryCleanups(std::size_t depth);
  bool EmitLocalCleanups(std::size_t depth);
  bool EmitCleanup(const Cleanup& cleanup);
  bool EmitDestroy(Address address, const Type& type);
  void EmitVTablePointer(Address object, const StructDecl& stage);
  llvm::Value* EmitVirtualCallee(const VirtualFunctionDecl& declaration, llvm::Value* receiver);
  llvm::Value* EmitVirtualCallee(llvm::Value* pointer, llvm::Value*& receiver);
  llvm::Value* EmitVirtualPointerIsNotNull(llvm::Value* pointer);
  void EnterDestructorCleanups(const DestructorDecl& declaration);
  bool RegisterGlobalDestructor(const VarDecl& declaration);
  bool EmitArrayLoop(std::uint64_t count, bool reverse, llvm::StringRef name,
                     llvm::function_ref<bool(llvm::Value*)> emit_element);
  bool EmitCompound(const CompoundStmt& statement);
  bool EmitStmt(const Stmt& statement);
  bool EmitIfStmt(const IfStmt& statement);
  bool EmitWhileStmt(const WhileStmt& statement);
  bool EmitVarGroup(const VarGroupDecl& declaration);
  bool EmitInitialization(const VarDecl& target, const Expr& source);
  bool EmitInitialization(Address target, const Type& type, const Expr& source);
  void EmitReturnBlock();
  bool EmitFunctionReturn(const FunctionDecl& declaration, const CodeGen::FunctionInfo& function_info);
  bool EmitIgnoredExpr(const Expr& expression);
  bool EmitIgnoredConditionalExpr(const ConditionalOperator& expression);
  Address EmitLValue(const Expr& expression);
  Address EmitBaseSubobject(const Expr& source, const std::vector<const StructDecl*>& path, bool through_pointer);
  Address EmitMemberExpr(const MemberExpr& expression);
  Address EmitConditionalLValue(const ConditionalOperator& expression);
  bool EmitAggExpr(const Expr& expression, Address destination);
  bool EmitConstruction(const ConstructionExpr& expression, Address destination);
  bool EmitArrayConstruction(Address destination, Address source, const ArrayType& type,
                             const ConstructorDecl& constructor);
  bool EmitArrayAssignment(Address destination, Address source, const ArrayType& type, const FunctionDecl& assignment);
  bool EmitStructorCall(const FunctionDecl& declaration, Address target, llvm::ArrayRef<const Expr*> sources);
  bool EmitCallArguments(const FunctionType& signature, const CodeGen::FunctionInfo& info,
                         llvm::ArrayRef<const Expr*> sources, EvaluationOrder order,
                         std::vector<llvm::Value*>& arguments);
  llvm::Value* EmitScalarExpr(const Expr& expression);
  llvm::Value* EmitIntegerDivRem(llvm::Value* lhs, llvm::Value* rhs, bool is_division, bool is_signed);
  llvm::Value* EmitLogicalExpr(const BinaryOperator& expression);
  llvm::Value* EmitConditionalExpr(const ConditionalOperator& expression);
  std::optional<RValue> EmitCall(const CallExpr& expression, ReturnValueSlot slot = {});
  RValue EmitCall(const FunctionType& signature, const CodeGen::FunctionInfo& info, llvm::Value* target,
                  std::vector<llvm::Value*>& arguments, ReturnValueSlot slot);
};

}  // namespace cw::codegen_detail
