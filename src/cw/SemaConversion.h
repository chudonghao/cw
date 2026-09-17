/// \file SemaConversion.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <memory>
#include <optional>
#include <string>
#include <variant>
#include <vector>

#include "ast.h"

namespace cw {
class ASTContext;
class SymbolTable;

/// \brief A warning condition for a conversion that will actually be adopted.
enum class ImplicitConversionRisk {
  None,
  IntegerTruncation,
  IntegerToFloatPrecisionLoss,
  FloatNarrowing,
  FloatToIntegerValueLoss,
};

namespace sema_detail {

/// \brief Reference-transparent type and category of one semantic value.
struct ValueState {
  QualType type{};                              ///< Actual type, including object-level const.
  ValueCategory category{ValueCategory::None};  ///< Category of this value.
};

/// \brief A borrowed, prepared expression and its matching value state.
struct ConversionSource {
  const Expr* expression{};  ///< Expression owned by the surrounding semantic operation.
  ValueState state{};        ///< State of the same prepared expression.
};

/// \brief Reads a referable object to produce a pure value.
struct ValueRead {};
/// \brief Adds const access to the same object, preserving its value category.
struct ReadOnlyProjection {};
/// \brief Makes a pure result object referable as a temporary.
struct TemporaryMaterialization {};
/// \brief Safely adds qualifiers within a pointer value type.
struct PointerQualification {};
/// \brief Forms a pointer null value of the type held in the result state.
struct NullPointerConversion {};

/// \brief Classification over all language values of the source numeric type.
enum class NumericPreservation { ValuePreserving, PotentiallyLossy };

/// \brief A numeric operation and its established value-domain relationship.
struct NumericConversion {
  ImplicitConversionKind kind{};       ///< Numeric conversion to commit.
  NumericPreservation preservation{};  ///< Established once during conversion building.
};

/// \brief Selects an existing base subobject, preserving its permissions and category.
struct BaseObjectProjection {
  std::vector<const StructDecl*> path;  ///< Valid direct-base path in source-to-target order.
};

/// \brief Adjusts a pointer value to address a base subobject.
struct BasePointerConversion {
  std::vector<const StructDecl*> path;  ///< Valid direct-base path in source-to-target order.
};

/// \brief The declaration chosen by exact function address selection.
struct FunctionAddressSelection {
  const FunctionDecl* declaration{};  ///< Unique selected declaration; its type is in the result state.
};

/// \brief A same-type formation whose constructor availability is checked separately from matching.
struct PendingObjectFormation {};

/// \brief A fully selected ordinary or array object construction.
struct CompletedObjectFormation {
  const ConstructorDecl* constructor{};         ///< Constructor, or leaf constructor for an array.
  bool is_array{};                              ///< Commit an array operation rather than an ordinary construction.
  std::optional<ValueState> readonly_argument;  ///< Required ordinary constructor argument projection, if any.
};

/// \brief The semantic action of a conversion step, with only action-specific data.
using TransitionSemantics =
    std::variant<ValueRead, ReadOnlyProjection, TemporaryMaterialization, PointerQualification, NullPointerConversion,
                 NumericConversion, BaseObjectProjection, BasePointerConversion, FunctionAddressSelection,
                 PendingObjectFormation, CompletedObjectFormation>;

/// \brief A semantic step and the state that it produces.
struct ConversionTransition {
  TransitionSemantics semantics;  ///< Action selected by analysis.
  ValueState result;              ///< Fully determined output type and category.
};

/// \brief Ordered changes from an independently owned source to an independently supplied target.
struct ConversionSequence {
  std::vector<ConversionTransition> transitions;  ///< Empty when the source already satisfies the target.
};

/// \brief Relative quality of two viable conversions of the same source.
enum class ConversionComparison { Better, Worse, Indistinguishable };

/// \brief A failed built-in value conversion.
enum class ImplicitConversionFailureKind { NoConversion, DiscardsConst };
/// \brief A failed built-in value conversion with diagnostic type facts.
struct ImplicitConversionFailure {
  ImplicitConversionFailureKind kind{};  ///< Reason the built-in conversion is unavailable.
  QualType source_type{};                ///< Source type at the failure.
  QualType target_type{};                ///< Required target type.
};

/// \brief A failed direct reference match.
enum class ReferenceBindingFailureKind { ReferentTypeMismatch, ModeMismatch, NotBindableValue };
/// \brief A failed reference target requirement.
struct ReferenceBindingFailure {
  ReferenceBindingFailureKind kind{};  ///< Failed reference requirement.
  QualType source_type{};              ///< Actual source type at the match.
  ValueCategory source_category{};     ///< Actual source category at the match.
  const ReferenceType* target_type{};  ///< Reference whose requirement failed.
};

/// \brief A failed implementation of an already matched object formation.
enum class ObjectFormationFailureKind { CopyUnavailable, MoveAndCopyUnavailable };
/// \brief An unavailable same-type object formation.
struct ObjectFormationFailure {
  ObjectFormationFailureKind kind{};  ///< Formation failure reason.
  QualType source_type{};             ///< Source of the formation step, possibly after a base projection.
  QualType target_type{};             ///< Result object type.
  ValueCategory source_category{};    ///< Category used to select copy or move.
};

/// \brief Failure of target-driven exact function address selection.
enum class OverloadSetSelectionFailureKind { MissingTarget, InvalidTarget, NoMatch, Ambiguous };
/// \brief One addressable declaration and its concrete address type.
struct AddressCandidate {
  const FunctionDecl* declaration{};  ///< Available declaration.
  QualType result_type{};             ///< Type of its address.
};
/// \brief Exact selection failure and available address candidates.
struct OverloadSetSelectionFailure {
  OverloadSetSelectionFailureKind kind{OverloadSetSelectionFailureKind::MissingTarget};  ///< Selection outcome.
  std::string name;                          ///< Source-level addressed name.
  QualType target_type{};                    ///< Exact required address type.
  std::vector<AddressCandidate> candidates;  ///< Facts needed for candidate notes.
};

/// \brief A build-time failure without formatted diagnostic text.
using ConversionFailure = std::variant<ImplicitConversionFailure, ReferenceBindingFailure, OverloadSetSelectionFailure>;
using ValueConversionResult = std::variant<ConversionSequence, ImplicitConversionFailure>;
using BuildConversionResult = std::variant<ConversionSequence, ConversionFailure>;
using FunctionAddressSelectionResult = std::variant<FunctionAddressSelection, OverloadSetSelectionFailure>;

/// \brief Identifies the failed formation without changing the selected conversion.
struct ConversionCompletionFailure {
  std::size_t transition_index{};    ///< Formation step that could not be completed.
  ObjectFormationFailure failure{};  ///< Underlying same-type formation failure.
};
using ConversionCompletionResult = std::optional<ConversionCompletionFailure>;

/// \brief Independent warning facts for an adopted numeric conversion.
struct ConversionRiskFact {
  QualType source_type{};         ///< Input type of the numeric step.
  QualType target_type{};         ///< Output type of the numeric step.
  ImplicitConversionKind kind{};  ///< Numeric operation.
  ImplicitConversionRisk risk{};  ///< Warning condition, never used for candidate ordering.
};
using ConversionRiskFacts = std::vector<ConversionRiskFact>;

/// \brief Selects the language's common numeric type, or null for incompatible families.
const BuiltinType* CommonNumericType(ASTContext& ast_context, QualType left, QualType right);
/// \brief Selects a common concrete raw pointer type, or null when none is available.
const PointerType* CommonPointerType(ASTContext& ast_context, QualType left, QualType right);

/// \brief Borrows a fully prepared expression without changing it.
ConversionSource MakeConversionSource(const Expr& expression);
/// \brief Returns a unique nonempty static base path, or no path.
std::optional<std::vector<const StructDecl*>> FindDerivedToBasePath(const Type* source, const Type* target);
/// \brief Returns whether a concrete target can select a function address.
bool IsFunctionAddressTarget(QualType type);
/// \brief Selects exactly one address of the specified concrete type without modifying the source.
FunctionAddressSelectionResult SelectFunctionAddress(const ConversionSource& source, QualType target,
                                                     ASTContext& ast_context, const SymbolTable& symbol_table);
/// \brief Builds a viable conversion without modifying AST or issuing diagnostics.
BuildConversionResult BuildConversion(const ConversionSource& source, QualType target, ASTContext& ast_context,
                                      const SymbolTable& symbol_table);
/// \brief Builds the built-in value changes from a prepared state, without entity initialization.
ValueConversionResult BuildValueConversion(ValueState source, QualType target, ASTContext& ast_context);
/// \brief Compares two successfully built conversions of the same source state.
ConversionComparison CompareConversion(const ValueState& source, QualType left_target, const ConversionSequence& left,
                                       QualType right_target, const ConversionSequence& right);
/// \brief Completes deferred formation in place without changing the matched result states.
ConversionCompletionResult CompleteConversion(const ConversionSource& source, QualType target,
                                              ConversionSequence& sequence, const SymbolTable& symbol_table);
/// \brief Reads warning facts only after every required conversion has completed.
ConversionRiskFacts CollectConversionRisks(const ConversionSource& source, QualType target,
                                           const ConversionSequence& sequence, const ASTContext& ast_context);
/// \brief Mechanically commits a completed conversion, transferring expression ownership.
std::unique_ptr<Expr> CommitConversion(std::unique_ptr<Expr> expression, QualType target,
                                       const ConversionSequence& sequence, ConstructionKind result_kind);

}  // namespace sema_detail
}  // namespace cw
