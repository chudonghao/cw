/// \file CodeGen.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <array>
#include <cstdint>
#include <memory>
#include <optional>
#include <string>
#include <string_view>
#include <unordered_map>
#include <variant>
#include <vector>

#include <llvm/IR/Attributes.h>
#include <llvm/Support/VersionTuple.h>

namespace llvm {
class Constant;
class Function;
class FunctionType;
class GlobalVariable;
class IntegerType;
class LLVMContext;
class Module;
class StructType;
class TargetMachine;
class Type;
}  // namespace llvm

namespace cw {

class ASTContext;
class TargetInfo;
struct TypeLayout;
class DiagnosticEngine;
class FunctionType;
class Type;
struct Decl;
struct FieldDecl;
struct DestructorDecl;
struct FunctionDecl;
struct Node;
struct StringLiteral;
struct StructDecl;
struct TranslationUnitDecl;
struct VarDecl;
struct VirtualFunctionDecl;
struct VTableEntry;
class StructType;

namespace codegen_detail {
class CodeGenFunction;
}

/// \brief Generates one LLVM module from a successful semantic translation unit.
class CodeGen {
  friend class codegen_detail::CodeGenFunction;

  enum class TypeConversionFailure { UnsupportedType, InvalidLayout };
  using TypeConversionResult = std::variant<llvm::Type*, TypeConversionFailure>;

  struct TargetABI {
    enum class Kind { DarwinAArch64, WebAssembly };

    Kind kind;
    bool structors_return_this;
    bool can_call_mismatched_function_type;
    bool use_32_bit_vtable_offset;
  };

  struct ABIArgInfo {
    enum class Kind { Ignore, Direct, Indirect };

    Kind kind{Kind::Ignore};
    llvm::Type* memory_type{};
    llvm::Type* direct_type{};
    llvm::Attribute::AttrKind extension{llvm::Attribute::None};
    bool by_value{};
    std::uint64_t indirect_alignment{};
  };

  struct ParameterInfo {
    ABIArgInfo abi;
    std::optional<unsigned> llvm_index;
  };

  struct FunctionInfo {
    ABIArgInfo result;
    std::vector<ParameterInfo> parameters;
    std::optional<unsigned> result_index;
    std::optional<unsigned> this_index;
    llvm::Type* this_type{};
    bool returns_this{};
    llvm::FunctionType* type{};
    llvm::AttributeList attributes;
  };

  using ABIArgInfoResult = std::variant<ABIArgInfo, TypeConversionFailure>;
  using FunctionInfoResult = std::variant<const FunctionInfo*, TypeConversionFailure>;

  enum class StructorKind { Complete, Base };

  struct FunctionEntry {
    llvm::Function* function{};
    const FunctionInfo* info{};
  };

  struct Thunk {
    llvm::Function* function{};
    llvm::Function* target{};
    std::uint64_t return_adjustment{};
  };

  struct StructRepresentation {
    llvm::StructType* type{};
    llvm::StructType* base_type{};
    std::optional<unsigned> base_index;
    std::unordered_map<const FieldDecl*, unsigned> field_indices;
  };

  const ASTContext* ast_context_{};
  DiagnosticEngine* diagnostic_engine_{};
  llvm::LLVMContext* llvm_context_{};
  const llvm::TargetMachine* target_machine_{};
  std::unique_ptr<llvm::Module> module_;
  std::unordered_map<const FunctionDecl*, std::array<FunctionEntry, 2>> functions_;
  std::unordered_map<llvm::Function*, const FunctionDecl*> function_declarations_;
  std::unordered_map<std::string, Thunk> thunks_;
  std::unordered_map<const VarDecl*, llvm::GlobalVariable*> globals_;
  std::unordered_map<const VarDecl*, llvm::Function*> global_destructors_;
  std::unordered_map<const llvm::Constant*, llvm::GlobalVariable*> string_literals_;
  std::unordered_map<const StructDecl*, StructRepresentation> struct_representations_;
  std::unordered_map<const FunctionType*, FunctionInfo> function_infos_;
  std::unordered_map<const StructType*, std::unordered_map<const FunctionType*, FunctionInfo>> structor_infos_;
  std::unordered_map<const StructDecl*, const DestructorDecl*> destructors_;
  std::unordered_map<const StructDecl*, llvm::GlobalVariable*> vtables_;
  llvm::Function* pure_virtual_{};
  llvm::Function* cxa_atexit_{};
  llvm::GlobalVariable* dso_handle_{};
  bool generated_{};

 public:
  /// \brief Creates the LLVM target selected for semantic analysis; reports failure through diagnostics.
  static std::unique_ptr<llvm::TargetMachine> CreateTarget(const TargetInfo& target, DiagnosticEngine& diagnostics,
                                                           llvm::VersionTuple minimum_os_version = {});

  CodeGen();
  ~CodeGen();

  CodeGen(const CodeGen&) = delete;
  CodeGen& operator=(const CodeGen&) = delete;

  /// \brief Sets the destination for generation diagnostics.
  void SetDiagnosticEngine(DiagnosticEngine* diagnostic_engine);

  /// \brief Sets the completed semantic AST to consume without modifying it.
  void SetASTContext(const ASTContext* ast_context);

  /// \brief Sets the externally owned LLVM context for the generated module.
  void SetLLVMContext(llvm::LLVMContext* llvm_context);

  /// \brief Sets the target used for platform validation and data layout.
  void SetTargetMachine(const llvm::TargetMachine* target_machine);

  /// \brief Transfers the verified module, or returns null after a diagnostic. May be called once.
  /// All dependencies must be configured before generation.
  /// The supplied LLVMContext must outlive the returned module; the other inputs need only outlive generation.
  std::unique_ptr<llvm::Module> operator()(std::string_view module_name = "cw");

 private:
  TargetABI GetTargetABI() const;
  llvm::IntegerType* GetPointerIndexType() const;
  TypeLayout GetTypeLayoutForMem(const Type& type) const;
  TypeConversionResult ConvertType(const Type& type);
  TypeConversionResult ConvertTypeForMem(const Type& type);
  TypeConversionResult ConvertStructType(const StructDecl& declaration);
  ABIArgInfoResult ClassifyTypeForABI(const Type& type, bool is_return);
  ABIArgInfo ClassifyDarwinAggregate(const Type& type, llvm::Type* memory_type, bool is_return);
  ABIArgInfo ClassifyWasmAggregate(const Type& type, llvm::Type* memory_type, bool is_return);
  FunctionInfoResult GetFunctionInfo(const FunctionType& type, const StructType* this_type = nullptr);
  FunctionInfoResult GetFunctionInfo(const FunctionDecl& declaration, StructorKind kind = StructorKind::Complete);
  llvm::AttributeList GetFunctionAttributes(const FunctionType& type, const FunctionInfo& info) const;
  llvm::GlobalVariable* GetAddrOfStringLiteral(const StringLiteral& literal);
  llvm::GlobalVariable* GetOrCreateVTable(const StructDecl& declaration);
  bool EmitVTableDefinition(const StructDecl& declaration);
  llvm::Constant* GetVTableAddressPoint(const StructDecl& declaration);
  llvm::Constant* GetVirtualFunctionPointer(const VirtualFunctionDecl& declaration);
  llvm::Function* GetVTableEntry(const VTableEntry& entry);
  std::string GetFunctionName(const FunctionDecl& declaration, StructorKind kind) const;
  llvm::Function* GetOrCreateFunction(const FunctionDecl& declaration, StructorKind kind = StructorKind::Complete);
  bool DeclareGlobalVariable(const VarDecl& declaration);
  static bool NeedsGlobalDestruction(const Type& type);
  void DeclareGlobalDestructionRuntime();
  llvm::Function* GetGlobalDestructor(const VarDecl& declaration);
  bool EmitGlobalInitializers(const TranslationUnitDecl& declaration);
  bool DiagnoseTypeConversionFailure(const Node& node, TypeConversionFailure failure, std::string_view feature);
  bool Unsupported(const Node& node, std::string_view feature);
  bool InternalError(const Node& node, std::string_view message);
};

}  // namespace cw
