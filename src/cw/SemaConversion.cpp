/// \file SemaConversion.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "SemaConversion.h"

#include <algorithm>
#include <iterator>
#include <unordered_set>
#include <utility>

#include <boost/assert.hpp>

#include "ASTContext.h"
#include "Symbol.h"
#include "SymbolTable.h"

namespace cw::sema_detail {
namespace {

/// \brief Tests containment of the entire source numeric value domain.
bool NumericRangeContains(const ASTContext& ast_context, const BuiltinType& target, const BuiltinType& source) {
  BOOST_ASSERT(target.IsInteger() || target.IsFloatingPoint());
  BOOST_ASSERT(source.IsInteger() || source.IsFloatingPoint());
  if (target.IsInteger()) {
    if (!source.IsInteger()) {
      return false;
    }
    const unsigned target_width = ast_context.GetIntegerBitWidth(target);
    const unsigned source_width = ast_context.GetIntegerBitWidth(source);
    if (target.IsSignedInteger() == source.IsSignedInteger()) {
      return target_width >= source_width;
    }
    return target.IsSignedInteger() && target_width > source_width;
  }
  const auto target_properties = ast_context.GetFloatingPointProperties(target);
  if (source.IsInteger()) {
    const unsigned precision = ast_context.GetIntegerBitWidth(source) - (source.IsSignedInteger() ? 1 : 0);
    return target_properties.significand_bits >= precision &&
           target_properties.maximum_exponent >= static_cast<int>(precision);
  }
  const auto source_properties = ast_context.GetFloatingPointProperties(source);
  return target_properties.significand_bits >= source_properties.significand_bits &&
         target_properties.maximum_exponent >= source_properties.maximum_exponent &&
         target_properties.minimum_subnormal_exponent <= source_properties.minimum_subnormal_exponent;
}

const TypeSymbol* AsTypeSymbol(const Symbol* symbol) {
  return symbol && symbol->GetKind() == SymbolKind::Type ? static_cast<const TypeSymbol*>(symbol) : nullptr;
}

const FunctionSymbol* AsFunctionSymbol(const Symbol* symbol) {
  return symbol && symbol->GetKind() == SymbolKind::Function ? static_cast<const FunctionSymbol*>(symbol) : nullptr;
}

const DeclRefExpr* AddressedFunctionName(const Expr& expression) {
  const Expr* unwrapped = expression.IgnoreParens();
  if (!unwrapped || unwrapped->GetKind() != NodeKind::UnaryOperator || !unwrapped->type ||
      !unwrapped->type.GetTypePtr()->AsAddressOfFunctionOverloadSetType()) {
    return nullptr;
  }

  const auto& address = static_cast<const UnaryOperator&>(*unwrapped);
  if (address.op != expr::amp || !address.Operand) {
    return nullptr;
  }
  const Expr* operand = address.Operand->IgnoreParens();
  if (!operand || operand->GetKind() != NodeKind::DeclRefExpr || !operand->type ||
      !operand->type.GetTypePtr()->AsFunctionOverloadSetType()) {
    return nullptr;
  }
  return static_cast<const DeclRefExpr*>(operand);
}

bool IsQualificationConversion(QualType source, QualType target, bool& discards_const) {
  discards_const = false;
  source = source.WithoutConst();
  target = target.WithoutConst();
  if (!source || !target || !source.GetTypePtr()->AsPointerType() || !target.GetTypePtr()->AsPointerType()) {
    return false;
  }
  if (source == target) {
    return true;
  }

  // Compare matching pointer shapes before checking qualifiers at each pointee depth.
  std::vector<bool> source_const;
  std::vector<bool> target_const;
  while (source.GetTypePtr()->AsPointerType() && target.GetTypePtr()->AsPointerType()) {
    const QualType source_pointee = source.GetTypePtr()->AsPointerType()->GetPointee();
    const QualType target_pointee = target.GetTypePtr()->AsPointerType()->GetPointee();
    source_const.push_back(source_pointee.IsConstQualified());
    target_const.push_back(target_pointee.IsConstQualified());
    source = source_pointee.WithoutConst();
    target = target_pointee.WithoutConst();
  }
  if (source.GetTypePtr()->AsPointerType() || target.GetTypePtr()->AsPointerType() || source != target) {
    return false;
  }

  // Adding deep const requires const at every intervening pointer level to prevent writes through aliases.
  for (std::size_t depth = 1; depth < source_const.size(); ++depth) {
    if (source_const[depth] || !target_const[depth]) {
      continue;
    }
    for (std::size_t barrier = 0; barrier < depth; ++barrier) {
      if (!target_const[barrier]) {
        return false;
      }
    }
  }
  for (std::size_t depth = 0; depth < source_const.size(); ++depth) {
    if (source_const[depth] && !target_const[depth]) {
      discards_const = true;
      return false;
    }
  }
  return true;
}

const TypeSymbol* TypeSymbolForObjectType(QualType type, const SymbolTable& symbol_table) {
  if (!type || !type.GetTypePtr()->AsStructType()) {
    return nullptr;
  }
  const StructDecl* declaration = type.GetTypePtr()->AsStructType()->GetDeclaration();
  if (!declaration) {
    return nullptr;
  }
  const TypeSymbol* symbol = AsTypeSymbol(symbol_table.LookupRoot(declaration->name));
  return symbol && symbol->GetDeclaration() == declaration ? symbol : nullptr;
}

/// \brief Ordinary or array leaf types for fixed copy/move constructor selection.
struct ObjectFormationTypes {
  QualType source_leaf_type{};  ///< Source leaf including inherited array const.
  QualType target_leaf_type{};  ///< Object type whose constructor slot is required.
  bool is_array{};              ///< Formation recursively applies to array elements.
};

std::optional<ObjectFormationTypes> DecomposeObjectFormationTypes(QualType source_type, QualType target_type) {
  ObjectFormationTypes result{source_type, target_type};
  while (result.target_leaf_type && result.target_leaf_type.GetTypePtr()->AsArrayType()) {
    result.is_array = true;
    if (!result.source_leaf_type || !result.source_leaf_type.GetTypePtr()->AsArrayType()) {
      return std::nullopt;
    }

    const auto* source_array = result.source_leaf_type.GetTypePtr()->AsArrayType();
    const auto* target_array = result.target_leaf_type.GetTypePtr()->AsArrayType();
    QualType source_element_type = source_array->GetElementType();
    if (result.source_leaf_type.IsConstQualified()) {
      source_element_type = source_element_type.WithConst();
    }
    result.source_leaf_type = source_element_type;
    result.target_leaf_type = target_array->GetElementType();
  }
  if (result.source_leaf_type && result.source_leaf_type.GetTypePtr()->AsArrayType()) {
    return std::nullopt;
  }
  return result;
}

QualType ObjectTarget(QualType target) {
  if (target) {
    if (const auto* reference = target.GetTypePtr()->AsReferenceType()) {
      return QualType(reference->GetReferentType());
    }
  }
  return target.WithoutConst();
}

bool SatisfiesTarget(ValueState state, QualType target) {
  BOOST_ASSERT(target);
  if (const auto* reference = target.GetTypePtr()->AsReferenceType()) {
    const QualType object(reference->GetReferentType());
    switch (reference->GetMode()) {
      case ReferenceMode::Mut:
        return state.type == object && state.category == ValueCategory::LValue;
      case ReferenceMode::Copy:
        return state.type == object.WithConst() &&
               (state.category == ValueCategory::LValue || state.category == ValueCategory::MoveLValue);
      case ReferenceMode::Move:
        return state.type == object && state.category == ValueCategory::MoveLValue;
    }
  }
  return target.GetTypePtr()->IsObject() && state.type == target.WithoutConst() &&
         state.category == ValueCategory::PureRValue;
}

bool CanBindMode(ValueState source, ReferenceMode mode) {
  if (source.category == ValueCategory::None) {
    return false;
  }
  if (source.type.IsConstQualified()) {
    return mode == ReferenceMode::Copy;
  }
  if (mode == ReferenceMode::Copy) {
    return true;
  }
  if (source.category == ValueCategory::LValue) {
    return mode == ReferenceMode::Mut;
  }
  return mode == ReferenceMode::Move;
}

std::variant<CompletedObjectFormation, ObjectFormationFailure> CompleteObjectFormation(
    ValueState source, QualType target, const SymbolTable& symbol_table) {
  const auto failure = [&](ObjectFormationFailureKind kind) {
    return ObjectFormationFailure{kind, source.type, target, source.category};
  };
  BOOST_ASSERT(source.type.WithoutConst() == target.WithoutConst());
  BOOST_ASSERT(source.category == ValueCategory::LValue || source.category == ValueCategory::MoveLValue);
  const auto types = DecomposeObjectFormationTypes(source.type, target);
  BOOST_ASSERT(types);
  const TypeSymbol* symbol = TypeSymbolForObjectType(types->target_leaf_type, symbol_table);
  const bool prefers_move = !types->source_leaf_type.IsConstQualified() && source.category == ValueCategory::MoveLValue;
  const auto unavailable =
      prefers_move ? ObjectFormationFailureKind::MoveAndCopyUnavailable : ObjectFormationFailureKind::CopyUnavailable;
  if (!symbol) {
    return failure(unavailable);
  }
  const auto usable = [&](const ConstructorDecl* constructor) {
    if (!constructor || !constructor->type) {
      return false;
    }
    const auto* function = constructor->type.GetTypePtr()->AsFunctionType();
    if (!function || function->GetParameterTypes().size() != 1) {
      return false;
    }
    const auto* reference = function->GetParameterTypes()[0]->AsReferenceType();
    return reference && reference->GetReferentType() == types->source_leaf_type.GetTypePtr() &&
           CanBindMode({types->source_leaf_type, source.category}, reference->GetMode());
  };
  // A mutable move-lvalue prefers the move slot, with copy as the permitted fallback.
  const ConstructorDecl* constructor = symbol->GetCopyConstructor();
  if (prefers_move) {
    constructor = symbol->GetMoveConstructor();
    if (!usable(constructor)) {
      constructor = symbol->GetCopyConstructor();
    }
  }
  if (!usable(constructor)) {
    return failure(unavailable);
  }
  CompletedObjectFormation result{constructor, types->is_array, std::nullopt};
  const auto* reference = constructor->type.GetTypePtr()->AsFunctionType()->GetParameterTypes()[0]->AsReferenceType();
  if (!types->is_array && reference->GetMode() == ReferenceMode::Copy && !source.type.IsConstQualified()) {
    result.readonly_argument = ValueState{source.type.WithConst(), source.category};
  }
  return result;
}

std::unique_ptr<Expr> Cast(std::unique_ptr<Expr> expression, ValueState result, ImplicitConversionKind kind,
                           std::vector<const StructDecl*> path = {}) {
  auto cast = std::make_unique<ImplicitCastExpr>();
  cast->range = expression->range;
  cast->type = result.type;
  cast->value_category = result.category;
  cast->conversion_kind = kind;
  cast->base_path = std::move(path);
  cast->SubExpr = std::move(expression);
  return cast;
}

const std::vector<const StructDecl*>& BasePath(const ConversionSequence& sequence) {
  for (const auto& step : sequence.transitions) {
    if (const auto* base = std::get_if<BaseObjectProjection>(&step.semantics)) {
      return base->path;
    }
    if (const auto* base = std::get_if<BasePointerConversion>(&step.semantics)) {
      return base->path;
    }
  }
  static const std::vector<const StructDecl*> empty;
  return empty;
}

int NumericGrade(const ConversionSequence& sequence) {
  for (const auto& step : sequence.transitions) {
    if (const auto* numeric = std::get_if<NumericConversion>(&step.semantics)) {
      return numeric->preservation == NumericPreservation::ValuePreserving ? 1 : 2;
    }
  }
  return 0;
}

ValueState EffectiveSource(ValueState source, const ConversionSequence& sequence) {
  if (!sequence.transitions.empty() &&
      (std::holds_alternative<FunctionAddressSelection>(sequence.transitions.front().semantics) ||
       std::holds_alternative<NullPointerConversion>(sequence.transitions.front().semantics))) {
    return sequence.transitions.front().result;
  }
  return source;
}

}  // namespace

const BuiltinType* CommonNumericType(ASTContext& ast_context, QualType left, QualType right) {
  const auto* lhs = left ? left.GetTypePtr()->AsBuiltinType() : nullptr;
  const auto* rhs = right ? right.GetTypePtr()->AsBuiltinType() : nullptr;
  if (!lhs || !rhs) {
    return nullptr;
  }
  if (lhs->IsInteger() && rhs->IsInteger()) {
    if (lhs->IsSizeInteger() || rhs->IsSizeInteger()) {
      if (!lhs->IsSizeInteger() || !rhs->IsSizeInteger()) {
        return nullptr;
      }
      return lhs == rhs ? lhs : ast_context.GetBuiltinType(BuiltinTypeKind::USize);
    }
    const unsigned lhs_width = ast_context.GetIntegerBitWidth(*lhs);
    const unsigned rhs_width = ast_context.GetIntegerBitWidth(*rhs);
    if (lhs->IsSignedInteger() == rhs->IsSignedInteger()) {
      return lhs_width >= rhs_width ? lhs : rhs;
    }
    const auto* signed_type = lhs->IsSignedInteger() ? lhs : rhs;
    const auto* unsigned_type = lhs->IsSignedInteger() ? rhs : lhs;
    return ast_context.GetIntegerBitWidth(*unsigned_type) >= ast_context.GetIntegerBitWidth(*signed_type)
               ? unsigned_type
               : signed_type;
  }
  if (lhs->IsFloatingPoint() && rhs->IsFloatingPoint()) {
    return ast_context.GetFloatingPointProperties(*lhs).storage_bits >=
                   ast_context.GetFloatingPointProperties(*rhs).storage_bits
               ? lhs
               : rhs;
  }
  if (lhs->IsFloatingPoint() && rhs->IsInteger() && !rhs->IsSizeInteger()) {
    return lhs;
  }
  if (rhs->IsFloatingPoint() && lhs->IsInteger() && !lhs->IsSizeInteger()) {
    return rhs;
  }
  return nullptr;
}

const PointerType* CommonPointerType(ASTContext& ast_context, QualType left, QualType right) {
  const auto* lhs = left ? left.GetTypePtr()->AsPointerType() : nullptr;
  const auto* rhs = right ? right.GetTypePtr()->AsPointerType() : nullptr;
  if (!lhs || !rhs || lhs->GetPointee().GetTypePtr()->AsFunctionType() ||
      rhs->GetPointee().GetTypePtr()->AsFunctionType()) {
    return nullptr;
  }
  if (lhs == rhs) {
    return lhs;
  }

  const QualType left_pointee = lhs->GetPointee();
  const QualType right_pointee = rhs->GetPointee();
  const bool pointee_const = left_pointee.IsConstQualified() || right_pointee.IsConstQualified();
  if (FindDerivedToBasePath(left_pointee.GetTypePtr(), right_pointee.GetTypePtr())) {
    return ast_context.GetPointerType(QualType(right_pointee.GetTypePtr(), pointee_const));
  }
  if (FindDerivedToBasePath(right_pointee.GetTypePtr(), left_pointee.GetTypePtr())) {
    return ast_context.GetPointerType(QualType(left_pointee.GetTypePtr(), pointee_const));
  }

  // Merge each pointee level, adding the const barriers needed by either
  // source when a deeper level gains a qualifier.
  std::vector<bool> qualifiers;
  std::size_t required_const_barriers = 0;
  left = left.WithoutConst();
  right = right.WithoutConst();
  while (left.GetTypePtr()->AsPointerType() && right.GetTypePtr()->AsPointerType()) {
    left = left.GetTypePtr()->AsPointerType()->GetPointee();
    right = right.GetTypePtr()->AsPointerType()->GetPointee();
    if (left.IsConstQualified() != right.IsConstQualified()) {
      required_const_barriers = qualifiers.size();
    }
    qualifiers.push_back(left.IsConstQualified() || right.IsConstQualified());
    left = left.WithoutConst();
    right = right.WithoutConst();
  }
  if (left != right) {
    return nullptr;
  }
  std::fill_n(qualifiers.begin(), required_const_barriers, true);
  QualType result = left;
  for (std::size_t depth = qualifiers.size(); depth > 0; --depth) {
    result = QualType(ast_context.GetPointerType(QualType(result.GetTypePtr(), qualifiers[depth - 1])));
  }
  return result.GetTypePtr()->AsPointerType();
}

ConversionSource MakeConversionSource(const Expr& expression) {
  BOOST_ASSERT(!expression.type || !expression.type.GetTypePtr()->AsReferenceType());
  return {&expression, {expression.type, expression.value_category}};
}

std::optional<std::vector<const StructDecl*>> FindDerivedToBasePath(const Type* source_type, const Type* target_type) {
  if (!source_type || !target_type || !source_type->AsStructType() || !target_type->AsStructType()) {
    return std::nullopt;
  }
  const StructDecl* current = source_type->AsStructType()->GetDeclaration();
  const StructDecl* target = target_type->AsStructType()->GetDeclaration();
  if (!current || !target) {
    return std::nullopt;
  }
  std::vector<const StructDecl*> path;
  std::unordered_set<const StructDecl*> visited;
  while (current) {
    if (!visited.insert(current).second) {
      return std::nullopt;
    }
    const StructType* base_type = current->base_type;
    const StructDecl* base = base_type ? base_type->GetDeclaration() : nullptr;
    if (!base) {
      return std::nullopt;
    }
    path.push_back(base);
    if (base == target) {
      return path;
    }
    current = base;
  }
  return std::nullopt;
}

bool IsFunctionAddressTarget(QualType type) {
  if (!type) {
    return false;
  }
  if (type.GetTypePtr()->AsVirtualSlotType()) {
    return true;
  }
  if (!type.GetTypePtr()->AsPointerType()) {
    return false;
  }
  const QualType pointee = type.GetTypePtr()->AsPointerType()->GetPointee();
  return pointee && pointee.GetTypePtr()->AsFunctionType();
}

FunctionAddressSelectionResult SelectFunctionAddress(const ConversionSource& source, QualType target_type,
                                                     ASTContext& ast_context, const SymbolTable& symbol_table) {
  const DeclRefExpr* name = AddressedFunctionName(*source.expression);
  BOOST_ASSERT(name);

  OverloadSetSelectionFailure failure;
  failure.name = name->name;
  if (!target_type) {
    return failure;
  }
  target_type = target_type.WithoutConst();
  failure.target_type = target_type.WithoutConst();
  if (!IsFunctionAddressTarget(failure.target_type)) {
    failure.kind = OverloadSetSelectionFailureKind::InvalidTarget;
    return failure;
  }

  if (const FunctionSymbol* symbol = AsFunctionSymbol(symbol_table.Lookup(name->name))) {
    const auto add_candidate = [&](const FunctionDecl* declaration) {
      if (!declaration || declaration->is_invalid || !declaration->type ||
          !declaration->type.GetTypePtr()->AsFunctionType() || declaration->name != name->name) {
        return;
      }
      const auto* function_type = declaration->type.GetTypePtr()->AsFunctionType();
      const PointerType* pointer_type = ast_context.GetPointerType(QualType(function_type));
      QualType result_type;
      if (declaration->GetKind() == NodeKind::VirtualFunctionDecl) {
        result_type = QualType(ast_context.GetVirtualSlotType(pointer_type));
      } else if (declaration->GetKind() == NodeKind::FunctionDecl) {
        result_type = QualType(pointer_type);
      } else {
        return;
      }
      if (std::any_of(failure.candidates.begin(), failure.candidates.end(),
                      [&](const AddressCandidate& candidate) { return candidate.declaration == declaration; })) {
        return;
      }
      failure.candidates.push_back(AddressCandidate{declaration, result_type});
    };
    for (const FunctionDecl* declaration : symbol->Declarations()) {
      add_candidate(declaration);
      if (declaration && declaration->GetKind() == NodeKind::FunctionDecl) {
        add_candidate(declaration->virtual_declaration);
      }
    }
  }

  // Address selection requires an exact pointer or virtual-slot type, without call-style conversions.
  std::vector<const AddressCandidate*> matches;
  for (const AddressCandidate& candidate : failure.candidates) {
    if (candidate.result_type == failure.target_type) {
      matches.push_back(&candidate);
    }
  }
  if (matches.empty()) {
    failure.kind = OverloadSetSelectionFailureKind::NoMatch;
    return failure;
  }
  if (matches.size() != 1) {
    failure.kind = OverloadSetSelectionFailureKind::Ambiguous;
    return failure;
  }
  return FunctionAddressSelection{matches.front()->declaration};
}

BuildConversionResult BuildConversion(const ConversionSource& source, QualType target, ASTContext& ast_context,
                                      const SymbolTable& symbol_table) {
  BOOST_ASSERT(source.expression);
  BOOST_ASSERT(source.expression->type == source.state.type);
  BOOST_ASSERT(source.expression->value_category == source.state.category);
  ConversionSequence sequence;
  ValueState current = source.state;
  const auto unavailable = [&](ImplicitConversionFailureKind kind =
                                   ImplicitConversionFailureKind::NoConversion) -> BuildConversionResult {
    return ConversionFailure{ImplicitConversionFailure{kind, current.type, target}};
  };
  if (!current.type || source.expression->ContainsErrors()) {
    return unavailable();
  }
  const auto append = [&](TransitionSemantics semantics, ValueState result) {
    sequence.transitions.push_back({std::move(semantics), result});
    current = result;
  };
  const auto materialize = [&] {
    if (current.category == ValueCategory::PureRValue) {
      append(TemporaryMaterialization{}, {current.type, ValueCategory::MoveLValue});
    }
  };
  // Resolve an overloaded address using the target before ordinary binding or value conversion.
  if (current.type.GetTypePtr()->AsAddressOfFunctionOverloadSetType()) {
    const QualType address_target = ObjectTarget(target);
    auto selection = SelectFunctionAddress(source, address_target, ast_context, symbol_table);
    if (const auto* failure = std::get_if<OverloadSetSelectionFailure>(&selection)) {
      return ConversionFailure{*failure};
    }
    append(std::get<FunctionAddressSelection>(selection), {address_target, ValueCategory::PureRValue});
  }
  if (!target) {
    return unavailable();
  }

  // Reference binding may project a base or materialize a temporary, but does not copy the object.
  if (const auto* reference = target.GetTypePtr()->AsReferenceType()) {
    if (current.type.GetTypePtr()->AsNullType()) {
      auto formation = BuildValueConversion(current, ObjectTarget(target), ast_context);
      if (const auto* failure = std::get_if<ImplicitConversionFailure>(&formation)) {
        return ConversionFailure{*failure};
      }
      for (auto& step : std::get<ConversionSequence>(formation).transitions) {
        append(std::move(step.semantics), step.result);
      }
    }
    const auto failure = [&](ReferenceBindingFailureKind kind) -> BuildConversionResult {
      return ConversionFailure{ReferenceBindingFailure{kind, current.type, current.category, reference}};
    };
    if (!current.type.GetTypePtr()->IsObject() || current.category == ValueCategory::None) {
      return failure(ReferenceBindingFailureKind::NotBindableValue);
    }
    const QualType object_type(reference->GetReferentType());
    std::vector<const StructDecl*> path;
    if (current.type.WithoutConst() != object_type) {
      auto base = FindDerivedToBasePath(current.type.GetTypePtr(), object_type.GetTypePtr());
      if (!base) {
        return failure(ReferenceBindingFailureKind::ReferentTypeMismatch);
      }
      path = std::move(*base);
    }
    if (!CanBindMode(current, reference->GetMode())) {
      return failure(ReferenceBindingFailureKind::ModeMismatch);
    }
    materialize();
    if (!path.empty()) {
      append(BaseObjectProjection{std::move(path)},
             {QualType(object_type.GetTypePtr(), current.type.IsConstQualified()), current.category});
    }
    if (reference->GetMode() == ReferenceMode::Copy && !current.type.IsConstQualified()) {
      append(ReadOnlyProjection{}, {current.type.WithConst(), current.category});
    }
    return sequence;
  }
  auto value = BuildValueConversion(current, target, ast_context);
  if (const auto* failure = std::get_if<ImplicitConversionFailure>(&value)) {
    return ConversionFailure{*failure};
  }
  auto& tail = std::get<ConversionSequence>(value).transitions;
  sequence.transitions.insert(sequence.transitions.end(), std::make_move_iterator(tail.begin()),
                              std::make_move_iterator(tail.end()));
  return sequence;
}

ValueConversionResult BuildValueConversion(ValueState source, QualType target, ASTContext& ast_context) {
  ConversionSequence sequence;
  ValueState current = source;
  const auto unavailable = [&](ImplicitConversionFailureKind kind =
                                   ImplicitConversionFailureKind::NoConversion) -> ValueConversionResult {
    return ImplicitConversionFailure{kind, current.type.WithoutConst(), target.WithoutConst()};
  };
  if (!current.type || !target) {
    return unavailable();
  }
  const auto append = [&](TransitionSemantics semantics, ValueState result) {
    sequence.transitions.push_back({std::move(semantics), result});
    current = result;
  };
  const auto materialize = [&] {
    if (current.category == ValueCategory::PureRValue) {
      append(TemporaryMaterialization{}, {current.type, ValueCategory::MoveLValue});
    }
  };
  target = target.WithoutConst();
  if (current.type.GetTypePtr()->AsNullType()) {
    if (!target.GetTypePtr()->AsPointerType() && !target.GetTypePtr()->AsVirtualSlotType()) {
      return unavailable();
    }
    append(NullPointerConversion{}, {target, ValueCategory::PureRValue});
    return sequence;
  }
  if (!current.type.GetTypePtr()->IsObject() || !target.GetTypePtr()->IsObject() ||
      current.category == ValueCategory::None) {
    return unavailable();
  }
  if (current.type.WithoutConst() != target) {
    if (auto path = FindDerivedToBasePath(current.type.GetTypePtr(), target.GetTypePtr())) {
      materialize();
      append(BaseObjectProjection{std::move(*path)},
             {QualType(target.GetTypePtr(), current.type.IsConstQualified()), current.category});
    }
  }
  if (current.type.WithoutConst() == target) {
    if (current.category != ValueCategory::PureRValue) {
      if (target.GetTypePtr()->GetTriviality() == TypeTriviality::NonTrivial) {
        // Keep constructor availability out of conversion ranking; complete object formation separately.
        append(PendingObjectFormation{}, {target, ValueCategory::PureRValue});
      } else {
        append(ValueRead{}, {target, ValueCategory::PureRValue});
      }
    }
    return sequence;
  }
  // Classify numeric conversions by their full value domains, independently of diagnostics.
  const auto* source_builtin = current.type.GetTypePtr()->AsBuiltinType();
  const auto* target_builtin = target.GetTypePtr()->AsBuiltinType();
  ImplicitConversionKind numeric_kind = ImplicitConversionKind::Invalid;
  if (source_builtin && target_builtin) {
    if (source_builtin->IsInteger() && target_builtin->IsInteger() &&
        source_builtin->IsSizeInteger() == target_builtin->IsSizeInteger()) {
      numeric_kind = ImplicitConversionKind::IntegerToInteger;
    } else if (source_builtin->IsFloatingPoint() && target_builtin->IsFloatingPoint()) {
      numeric_kind = ImplicitConversionKind::FloatToFloat;
    } else if (source_builtin->IsInteger() && !source_builtin->IsSizeInteger() && target_builtin->IsFloatingPoint()) {
      numeric_kind = ImplicitConversionKind::IntegerToFloat;
    } else if (source_builtin->IsFloatingPoint() && target_builtin->IsInteger() && !target_builtin->IsSizeInteger()) {
      numeric_kind = ImplicitConversionKind::FloatToInteger;
    }
  }
  if (numeric_kind != ImplicitConversionKind::Invalid) {
    const auto preservation = NumericRangeContains(ast_context, *target_builtin, *source_builtin)
                                  ? NumericPreservation::ValuePreserving
                                  : NumericPreservation::PotentiallyLossy;
    if (current.category != ValueCategory::PureRValue) {
      append(ValueRead{}, {current.type.WithoutConst(), ValueCategory::PureRValue});
    }
    append(NumericConversion{numeric_kind, preservation}, {target, ValueCategory::PureRValue});
    return sequence;
  }
  // Pointer conversions preserve pointee const and may adjust along one derived-to-base path.
  const auto* source_pointer = current.type.GetTypePtr()->AsPointerType();
  const auto* target_pointer = target.GetTypePtr()->AsPointerType();
  if (source_pointer && target_pointer) {
    bool discards_const = false;
    if (IsQualificationConversion(current.type, target, discards_const)) {
      if (current.category != ValueCategory::PureRValue) {
        append(ValueRead{}, {current.type.WithoutConst(), ValueCategory::PureRValue});
      }
      append(PointerQualification{}, {target, ValueCategory::PureRValue});
      return sequence;
    }
    if (discards_const) {
      return unavailable(ImplicitConversionFailureKind::DiscardsConst);
    }
    const auto source_pointee = source_pointer->GetPointee();
    const auto target_pointee = target_pointer->GetPointee();
    if (auto path = FindDerivedToBasePath(source_pointee.GetTypePtr(), target_pointee.GetTypePtr())) {
      if (source_pointee.IsConstQualified() && !target_pointee.IsConstQualified()) {
        return unavailable(ImplicitConversionFailureKind::DiscardsConst);
      }
      if (current.category != ValueCategory::PureRValue) {
        append(ValueRead{}, {current.type.WithoutConst(), ValueCategory::PureRValue});
      }
      const QualType adjusted(
          ast_context.GetPointerType(QualType(target_pointee.GetTypePtr(), source_pointee.IsConstQualified())));
      append(BasePointerConversion{std::move(*path)}, {adjusted, ValueCategory::PureRValue});
      if (adjusted != target) {
        append(PointerQualification{}, {target, ValueCategory::PureRValue});
      }
      return sequence;
    }
  }
  return unavailable();
}

ConversionComparison CompareConversion(const ValueState& source, QualType left_target, const ConversionSequence& left,
                                       QualType right_target, const ConversionSequence& right) {
  const ValueState left_source = EffectiveSource(source, left);
  const ValueState right_source = EffectiveSource(source, right);
  // Independently formed pointer types do not establish a preference between
  // their targets. Ordinary ranking starts after the same source has formed.
  if (left_source.type.WithoutConst() != right_source.type.WithoutConst()) {
    return ConversionComparison::Indistinguishable;
  }
  const auto* numeric = source.type ? source.type.GetTypePtr()->AsBuiltinType() : nullptr;
  if (numeric && (numeric->IsInteger() || numeric->IsFloatingPoint())) {
    const int lhs = NumericGrade(left), rhs = NumericGrade(right);
    if (lhs != rhs) {
      return lhs < rhs ? ConversionComparison::Better : ConversionComparison::Worse;
    }
  }
  const auto& left_path = BasePath(left);
  const auto& right_path = BasePath(right);
  if (left_path.size() < right_path.size() && std::equal(left_path.begin(), left_path.end(), right_path.begin())) {
    return ConversionComparison::Better;
  }
  if (right_path.size() < left_path.size() && std::equal(right_path.begin(), right_path.end(), left_path.begin())) {
    return ConversionComparison::Worse;
  }
  const auto* left_reference = left_target.GetTypePtr()->AsReferenceType();
  const auto* right_reference = right_target.GetTypePtr()->AsReferenceType();
  const QualType left_object = ObjectTarget(left_target), right_object = ObjectTarget(right_target);
  if (left_reference && right_reference && left_object == right_object && left_path == right_path) {
    const auto preferred = left_source.category == ValueCategory::LValue ? ReferenceMode::Mut : ReferenceMode::Move;
    if (left_reference->GetMode() == preferred && right_reference->GetMode() == ReferenceMode::Copy) {
      return ConversionComparison::Better;
    }
    if (right_reference->GetMode() == preferred && left_reference->GetMode() == ReferenceMode::Copy) {
      return ConversionComparison::Worse;
    }
  }
  if (left_path == right_path) {
    bool ignored = false;
    const bool left_to_right = IsQualificationConversion(left_object, right_object, ignored);
    const bool right_to_left = IsQualificationConversion(right_object, left_object, ignored);
    if (left_to_right && !right_to_left) {
      return ConversionComparison::Better;
    }
    if (right_to_left && !left_to_right) {
      return ConversionComparison::Worse;
    }
  }
  return ConversionComparison::Indistinguishable;
}

ConversionCompletionResult CompleteConversion(const ConversionSource& source, QualType target,
                                              ConversionSequence& sequence, const SymbolTable& symbol_table) {
  BOOST_ASSERT(target);
  ValueState current = source.state;
  for (std::size_t index = 0; index < sequence.transitions.size(); ++index) {
    auto& step = sequence.transitions[index];
    if (std::holds_alternative<PendingObjectFormation>(step.semantics)) {
      auto result = CompleteObjectFormation(current, step.result.type, symbol_table);
      if (const auto* failure = std::get_if<ObjectFormationFailure>(&result)) {
        return ConversionCompletionFailure{index, *failure};
      }
      step.semantics = std::get<CompletedObjectFormation>(std::move(result));
    }
    current = step.result;
  }
  BOOST_ASSERT(SatisfiesTarget(current, target));
  return std::nullopt;
}

ConversionRiskFacts CollectConversionRisks(const ConversionSource& source, QualType target,
                                           const ConversionSequence& sequence, const ASTContext& ast_context) {
  BOOST_ASSERT(target);
  ConversionRiskFacts facts;
  ValueState current = source.state;
  for (const auto& step : sequence.transitions) {
    BOOST_ASSERT(!std::holds_alternative<PendingObjectFormation>(step.semantics));
    if (const auto* numeric = std::get_if<NumericConversion>(&step.semantics)) {
      const auto& input = *current.type.GetTypePtr()->AsBuiltinType();
      const auto& output = *step.result.type.GetTypePtr()->AsBuiltinType();
      auto risk = ImplicitConversionRisk::None;
      switch (numeric->kind) {
        case ImplicitConversionKind::IntegerToInteger:
          if (ast_context.GetIntegerBitWidth(output) < ast_context.GetIntegerBitWidth(input)) {
            risk = ImplicitConversionRisk::IntegerTruncation;
          }
          break;
        case ImplicitConversionKind::IntegerToFloat:
          if (ast_context.GetIntegerBitWidth(input) - (input.IsSignedInteger() ? 1 : 0) >
              ast_context.GetFloatingPointProperties(output).significand_bits) {
            risk = ImplicitConversionRisk::IntegerToFloatPrecisionLoss;
          }
          break;
        case ImplicitConversionKind::FloatToFloat:
          if (ast_context.GetFloatingPointProperties(output).storage_bits <
              ast_context.GetFloatingPointProperties(input).storage_bits) {
            risk = ImplicitConversionRisk::FloatNarrowing;
          }
          break;
        case ImplicitConversionKind::FloatToInteger:
          risk = ImplicitConversionRisk::FloatToIntegerValueLoss;
          break;
        default:
          BOOST_ASSERT(false && "not a numeric conversion");
      }
      if (risk != ImplicitConversionRisk::None) {
        facts.push_back({current.type, step.result.type, numeric->kind, risk});
      }
    }
    current = step.result;
  }
  return facts;
}

std::unique_ptr<Expr> CommitConversion(std::unique_ptr<Expr> expression, QualType target,
                                       const ConversionSequence& sequence, ConstructionKind result_kind) {
  BOOST_ASSERT(expression && target);
  for (std::size_t index = 0; index < sequence.transitions.size(); ++index) {
    const auto& step = sequence.transitions[index];
    if (std::holds_alternative<ValueRead>(step.semantics)) {
      expression = Cast(std::move(expression), step.result, ImplicitConversionKind::LValueToRValue);
    } else if (std::holds_alternative<ReadOnlyProjection>(step.semantics)) {
      expression = Cast(std::move(expression), step.result, ImplicitConversionKind::NoOp);
    } else if (std::holds_alternative<PointerQualification>(step.semantics)) {
      expression = Cast(std::move(expression), step.result, ImplicitConversionKind::Qualification);
    } else if (std::holds_alternative<NullPointerConversion>(step.semantics)) {
      expression = Cast(std::move(expression), step.result, ImplicitConversionKind::NullToPointer);
    } else if (const auto* numeric = std::get_if<NumericConversion>(&step.semantics)) {
      expression = Cast(std::move(expression), step.result, numeric->kind);
    } else if (const auto* base = std::get_if<BaseObjectProjection>(&step.semantics)) {
      expression = Cast(std::move(expression), step.result, ImplicitConversionKind::DerivedToBase, base->path);
    } else if (const auto* base = std::get_if<BasePointerConversion>(&step.semantics)) {
      expression = Cast(std::move(expression), step.result, ImplicitConversionKind::DerivedToBase, base->path);
    } else if (std::holds_alternative<TemporaryMaterialization>(step.semantics)) {
      auto temporary = std::make_unique<MaterializeTemporaryExpr>();
      temporary->range = expression->range;
      temporary->type = step.result.type;
      temporary->value_category = step.result.category;
      temporary->SubExpr = std::move(expression);
      expression = std::move(temporary);
    } else if (const auto* selection = std::get_if<FunctionAddressSelection>(&step.semantics)) {
      auto address = std::make_unique<ImplicitOverloadSetSelectionExpr>();
      address->range = expression->range;
      address->type = step.result.type;
      address->value_category = step.result.category;
      address->selected_declaration = selection->declaration;
      address->SubExpr = std::move(expression);
      expression = std::move(address);
    } else if (const auto* formation = std::get_if<CompletedObjectFormation>(&step.semantics)) {
      if (formation->is_array) {
        auto construction = std::make_unique<ArrayConstructionExpr>();
        construction->range = expression->range;
        construction->type = step.result.type;
        construction->value_category = step.result.category;
        construction->element_constructor = formation->constructor;
        construction->Source = std::move(expression);
        expression = std::move(construction);
      } else {
        if (formation->readonly_argument) {
          expression = Cast(std::move(expression), *formation->readonly_argument, ImplicitConversionKind::NoOp);
        }
        auto construction = std::make_unique<ConstructionExpr>();
        construction->range = expression->range;
        construction->type = step.result.type;
        construction->value_category = step.result.category;
        construction->constructor = formation->constructor;
        construction->construction_kind =
            index + 1 == sequence.transitions.size() ? result_kind : ConstructionKind::CompleteObject;
        construction->Args.push_back(std::move(expression));
        expression = std::move(construction);
      }
    } else {
      BOOST_ASSERT(false && "cannot commit an incomplete conversion");
    }
    BOOST_ASSERT(expression->type == step.result.type && expression->value_category == step.result.category);
  }
  BOOST_ASSERT(SatisfiesTarget({expression->type, expression->value_category}, target));
  return expression;
}

}  // namespace cw::sema_detail
