/// \file Sema.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <memory>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "Diagnostic.h"
#include "Source.h"
#include "SymbolTable.h"
#include "ast.h"

namespace cw {

class ASTContext;
struct BinaryOperator;
struct BaseSubobjectExpr;
struct CallExpr;
struct ConditionalOperator;
struct CompoundStmt;
class Type;
struct ConstructorDecl;
struct ConstructionExpr;
struct DeclRefExpr;
struct DestructorDecl;
struct DestructorCallExpr;
struct Expr;
struct FunctionDecl;
struct ImplicitResultInitializationExpr;
struct InitializationExpr;
struct MemberExpr;
struct Node;
struct ParmVarDecl;
struct ReturnStmt;
struct ReceiverCallExpr;
struct Stmt;
struct StructDecl;
struct ThisExpr;
struct TranslationUnitDecl;
struct TypeSyntax;
struct UnaryOperator;
struct VarDecl;
struct VarGroupDecl;

enum class ImplicitConversionRisk;
namespace sema_detail {
struct ConversionSequence;
struct OverloadSetSelectionFailure;
}  // namespace sema_detail

/// \brief Performs semantic analysis after parsing a translation unit.
class Sema {
  enum class ResultBlockKind {
    Function,
    Variable,
  };

  enum class TypeUseKind {
    LocalVariable,
    GlobalVariable,
    Field,
    Parameter,
    Return,
    ArrayElement,
  };

  enum class ExpressionUse {
    General,
    InitializationStatement,
    ConstructorPrologue,
  };

  enum class ComptimeIntMode {
    Materialize,
    Preserve,
  };

  struct ConstructionResultContext {
    QualType target_type;
    ConstructionKind construction_kind{ConstructionKind::CompleteObject};
  };

  enum class DeclRefRole {
    Object,
    Callee,
  };

  class ResultBlockAnalysisContext {
    ResultBlockKind kind_;

   public:
    ResultBlockKind GetKind() const { return kind_; }

   protected:
    explicit ResultBlockAnalysisContext(ResultBlockKind kind) : kind_(kind) {}
  };

  class FunctionResultBlockAnalysisContext final : public ResultBlockAnalysisContext {
    FunctionDecl& declaration_;

   public:
    explicit FunctionResultBlockAnalysisContext(FunctionDecl& declaration)
        : ResultBlockAnalysisContext(ResultBlockKind::Function), declaration_(declaration) {}

    FunctionDecl& GetDeclaration() const { return declaration_; }
  };

  class VariableResultBlockAnalysisContext final : public ResultBlockAnalysisContext {
    VarGroupDecl& declaration_;

   public:
    explicit VariableResultBlockAnalysisContext(VarGroupDecl& declaration)
        : ResultBlockAnalysisContext(ResultBlockKind::Variable), declaration_(declaration) {}

    VarGroupDecl& GetDeclaration() const { return declaration_; }
  };

  /// \brief Temporary inherited-slot view used until final virtual-slot or vtable metadata exposes it directly.
  using InheritedVirtualSlots = std::unordered_map<const StructDecl*, std::vector<VirtualFunctionDecl*>>;

  struct LifecycleDeclarations {
    std::unordered_map<const StructDecl*, std::vector<ConstructorDecl*>> constructors;
    std::unordered_map<const StructDecl*, std::vector<DestructorDecl*>> destructors;
  };

  /// \brief Destination for accumulated semantic diagnostics.
  DiagnosticEngine* diagnostic_engine_{};

  /// \brief Source files referenced by AST locations.
  const std::vector<Source>* sources_{};

  /// \brief Non-owning AST and persistent semantic state owner.
  ASTContext* ast_context_{};

  /// \brief Lexical symbols for the translation unit under analysis.
  SymbolTable symbol_table_;

  /// \brief Top-level variables excluded from function-local initialization operations.
  std::unordered_set<const VarDecl*> global_variables_;

  /// \brief Number of enclosing loops at the current function-body position.
  std::size_t loop_depth_{};

  /// \brief Function whose body is currently undergoing semantic analysis.
  FunctionDecl* current_function_{};

 public:
  /// \brief Sets the destination for semantic diagnostics.
  void SetDiagnosticEngine(DiagnosticEngine* diagnostic_engine);

  /// \brief Sets the source files referenced by AST source locations.
  void SetSources(const std::vector<Source>* sources);

  /// \brief Sets the owner of the AST and its persistent semantic state.
  void SetASTContext(ASTContext* ast_context);

  /// \brief Analyzes the translation unit owned by the configured AST context.
  void operator()();

 private:
  // Translation unit stages and their explicit intermediate facts.
  void ResetRunState();
  void ResolveTypeStructures(TranslationUnitDecl& translation_unit);
  InheritedVirtualSlots CompleteTypeSemantics(TranslationUnitDecl& translation_unit);
  void CompleteCallableInterfaces(TranslationUnitDecl& translation_unit, const InheritedVirtualSlots& inherited_slots);
  void AnalyzeDeclarationBodies(TranslationUnitDecl& translation_unit);
  void FinalizeTranslationUnitSemantics(TranslationUnitDecl& translation_unit);

  // Type structure, type syntax, and contextual type-use validation.
  void BindTypeName(StructDecl& declaration);
  void ResolveStructDeclarationTypes(StructDecl& declaration);
  void ValidateStructInheritance(TranslationUnitDecl& translation_unit);
  void ValidateObjectContainment(TranslationUnitDecl& translation_unit);
  bool ResolveTypeUse(TypeSyntax* type_syntax, TypeUseKind use, QualType& resolved_type);
  QualType ResolveType(TypeSyntax& type_syntax);
  bool ValidateTypeUse(Node& owner, QualType type, TypeUseKind use);
  bool ValidateAbstractObjectType(Node& owner, QualType type, TypeUseKind use);
  bool ValidateAbstractTypeUse(TypeSyntax& type_syntax, QualType type, TypeUseKind use);
  bool ValidateAbstractUsesInContainedFunctionTypes(TypeSyntax& type_syntax, QualType type);
  bool ValidateAbstractFunctionTypeUses(FunctionDecl& declaration);

  // Declaration interfaces, binding, virtual hierarchy, and lifecycle facts.
  void ValidateVirtualDeclarationInterfaces(TranslationUnitDecl& translation_unit);
  InheritedVirtualSlots ValidateVirtualHierarchy(TranslationUnitDecl& translation_unit);
  void ValidateTypeDeclarationAbstractUses(TranslationUnitDecl& translation_unit);
  LifecycleDeclarations ResolveLifecycleDeclarationInterfaces(TranslationUnitDecl& translation_unit);
  void BindLifecycleDeclarations(TranslationUnitDecl& translation_unit);
  void ComputeStructTriviality(TranslationUnitDecl& translation_unit,
                               const LifecycleDeclarations& lifecycle_declarations);
  void ValidateLifecycleRequirements(TranslationUnitDecl& translation_unit,
                                     const LifecycleDeclarations& lifecycle_declarations);
  void ResolveCallableInterfaces(TranslationUnitDecl& translation_unit);
  void BindCallableDeclarations(TranslationUnitDecl& translation_unit);
  void BindFunctionDeclaration(FunctionDecl& declaration);
  void AssociateVirtualDefinitions(TranslationUnitDecl& translation_unit);
  void ValidateRequiredOverrideDeclarations(TranslationUnitDecl& translation_unit,
                                            const InheritedVirtualSlots& inherited_slots);
  bool ValidateOperatorFunctionInterface(FunctionDecl& declaration);
  bool RegisterSpecialAssignment(FunctionDecl& declaration);
  bool AddFunctionDeclaration(const std::string& name, FunctionDecl& declaration);
  void ResolveConstructorTarget(ConstructorDecl& declaration);
  void ResolveDestructorTarget(DestructorDecl& declaration);
  void RegisterConstructor(ConstructorDecl& declaration);
  void RegisterDestructor(DestructorDecl& declaration);
  void BindGlobalVariables(VarGroupDecl& declaration);
  void ResolveVariableGroupTypes(VarGroupDecl& declaration, TypeUseKind use);
  void ResolveFunctionDeclarationTypes(FunctionDecl& declaration);
  void CheckFunctionOperatorAndReturnDeclaration(FunctionDecl& declaration);
  void CheckFunctionDeclaration(FunctionDecl& declaration);
  void CheckConstructorDeclaration(ConstructorDecl& declaration);
  void CheckDestructorDeclaration(DestructorDecl& declaration);
  void CheckExplicitThisParameters(FunctionDecl& declaration);
  void CheckVariableGroupDeclaration(VarGroupDecl& declaration, TypeUseKind use);
  void CheckFunctionVariableAttributes(FunctionDecl& declaration);
  void CheckFunctionVariableNames(FunctionDecl& declaration);
  void CheckVariableAttributes(VarDecl& declaration);
  void AddLocalVariable(VarDecl& declaration);

  // Bodies, control flow, and outer result-object initialization.
  void AnalyzeFunction(FunctionDecl& declaration);
  void AnalyzeCompoundStmt(CompoundStmt& statement, bool creates_scope,
                           const ResultBlockAnalysisContext& result_block_context, bool is_result_block = false);
  void AnalyzeStmt(Stmt& statement, const ResultBlockAnalysisContext& result_block_context,
                   bool forwards_result_position = false, bool is_constructor_prologue = false);
  void AnalyzeReturnStmt(ReturnStmt& statement, const ResultBlockAnalysisContext& result_block_context);
  void AnalyzeResultBlockTailExpressions(CompoundStmt& statement,
                                         const ResultBlockAnalysisContext& result_block_context);
  void AnalyzeFunctionTailExpressions(CompoundStmt& statement, FunctionDecl& function);
  void AnalyzeVariableTailExpressions(CompoundStmt& statement, VarGroupDecl& declaration);
  void FormImplicitResultInitialization(std::unique_ptr<Expr>& expression, VarDecl& target,
                                        FunctionDecl* function = nullptr);
  bool AdaptReturnExpression(std::unique_ptr<Expr>& expression, QualType target_type, Node& diagnostic_owner);
  void AnalyzeVariableGroup(VarGroupDecl& declaration, TypeUseKind use = TypeUseKind::LocalVariable);

  // Expression preparation and operator-specific semantics.
  [[nodiscard]] std::unique_ptr<Expr> AnalyzeExpr(std::unique_ptr<Expr> expression,
                                                  ComptimeIntMode mode = ComptimeIntMode::Materialize,
                                                  ExpressionUse use = ExpressionUse::General,
                                                  const ConstructionResultContext* construction_context = nullptr);
  [[nodiscard]] std::unique_ptr<Expr> AnalyzeCalleeExpr(std::unique_ptr<Expr> expression);
  [[nodiscard]] std::unique_ptr<Expr> AnalyzeUnaryOperator(std::unique_ptr<Expr> expression);
  [[nodiscard]] std::unique_ptr<Expr> AnalyzeBinaryOperator(std::unique_ptr<Expr> expression);
  [[nodiscard]] std::unique_ptr<Expr> AnalyzeOverloadableOperator(std::unique_ptr<Expr> expression,
                                                                  expr::ExprGrammarSymbol op,
                                                                  SourceRange operator_range,
                                                                  const std::vector<std::unique_ptr<Expr>*>& operands);
  void AnalyzeBuiltinUnaryOperator(UnaryOperator& expression);
  void AnalyzeBuiltinBinaryOperator(BinaryOperator& expression);
  void AnalyzeSubscriptExpr(SubscriptExpr& expression);
  void AnalyzeArrayValueExpr(ArrayValueExpr& expression, QualType contextual_type = {});
  void AnalyzeArrayValueElementsForRecovery(ArrayValueExpr& expression);
  [[nodiscard]] std::unique_ptr<Expr> AnalyzeSimpleAssignment(std::unique_ptr<Expr> expression);
  void AnalyzeInitializationExpr(InitializationExpr& expression, ExpressionUse use);
  void AnalyzeConditionalOperator(ConditionalOperator& expression,
                                  const ConstructionResultContext* construction_context);
  void AnalyzeThisExpr(ThisExpr& expression);
  [[nodiscard]] std::unique_ptr<Expr> AnalyzeDeclRefExpr(std::unique_ptr<Expr> expression, DeclRefRole role);
  [[nodiscard]] std::unique_ptr<Expr> AnalyzeMemberExpr(std::unique_ptr<Expr> expression);
  bool MaterializeComptimeInteger(std::unique_ptr<Expr>& expression);

  // Call discovery, receiver eligibility, argument conversion, and result formation.
  [[nodiscard]] std::unique_ptr<Expr> AnalyzeCallableObjectCall(std::unique_ptr<Expr> expression);
  void AnalyzeCallExpr(CallExpr& expression, const ConstructionResultContext* construction_context);
  void AnalyzeIndirectCallExpr(CallExpr& expression, const FunctionType& function_type);
  void AnalyzeReceiverCallExpr(ReceiverCallExpr& expression);
  void AnalyzeConstructionExpr(ConstructionExpr& expression);
  void AnalyzeDestructorCallExpr(DestructorCallExpr& expression);
  void FormCallResult(CallExpr& expression, const FunctionType& function_type);
  void FormDirectCallResult(CallExpr& expression, DeclRefExpr& callee, const FunctionDecl& declaration);
  void FormConstructionResult(ConstructionExpr& expression, const ConstructorDecl& declaration, bool returns_pointer);
  void FormDestructorCallResult(DestructorCallExpr& expression, DeclRefExpr& callee, const DestructorDecl& declaration);

  // Conversion orchestration; matching and completion live in SemaConversion.
  /// \brief Runs one noncompeting initialization after source analysis.
  bool ConvertExpression(std::unique_ptr<Expr>& expression, QualType target, Node& owner,
                         const std::string& failure_prefix,
                         ConstructionKind result_kind = ConstructionKind::CompleteObject);
  /// \brief Applies only the exact function-address exception for assignment.
  bool SelectAssignmentFunctionAddress(std::unique_ptr<Expr>& expression, QualType target, Node& owner);
  void DiagnoseFunctionAddressFailure(Node& owner, const SourceRange& range,
                                      const sema_detail::OverloadSetSelectionFailure& failure);
  void DiagnoseConversionRisks(Node& owner, const Expr& source, QualType target,
                               const sema_detail::ConversionSequence& conversion);
  /// \brief Diagnoses all completed argument conversions before committing any argument.
  void CommitArgumentConversions(const std::vector<std::unique_ptr<Expr>*>& arguments,
                                 const std::vector<const Type*>& targets,
                                 const std::vector<sema_detail::ConversionSequence>& conversions);
  void DiagnoseImplicitConversionRisk(Node& owner, const SourceRange& range, QualType source, QualType target,
                                      ImplicitConversionKind kind, ImplicitConversionRisk risk);
  void FinalizeVariableInitializer(VarDecl& declaration, std::unique_ptr<Expr>& initializer, TypeUseKind use);

  // Derived analyses and diagnostic presentation.
  void AnalyzeDefiniteInitialization(TranslationUnitDecl& translation_unit);
  void ValidateDelegatingConstructorCycles(TranslationUnitDecl& translation_unit);
  void Diagnose(Node& owner, DiagnosticSeverity severity, const SourceRange& range, std::string message);
  void EmitDiagnostic(DiagnosticSeverity severity, const SourceRange& range, std::string message);
  void DiagnoseConflict(Node& current_owner, const SourceRange& current_range, const std::string& message,
                        const SourceRange& conflicting_range, const char* note_message);
};

}  // namespace cw
