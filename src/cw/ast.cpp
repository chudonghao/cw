/// \file ast.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "ast.h"

#include <algorithm>

#include <boost/assert.hpp>

#include "ASTVisitor.h"
#include "NamespaceContext.h"

namespace cw {

namespace {

constexpr std::pair<BinaryOperatorKind, BinaryOperatorKind> kCompoundAssignmentOperators[] = {
    {BinaryOperatorKind::AddAssign, BinaryOperatorKind::Add},
    {BinaryOperatorKind::SubtractAssign, BinaryOperatorKind::Subtract},
    {BinaryOperatorKind::MultiplyAssign, BinaryOperatorKind::Multiply},
    {BinaryOperatorKind::DivideAssign, BinaryOperatorKind::Divide},
    {BinaryOperatorKind::RemainderAssign, BinaryOperatorKind::Remainder},
    {BinaryOperatorKind::BitwiseAndAssign, BinaryOperatorKind::BitwiseAnd},
    {BinaryOperatorKind::BitwiseOrAssign, BinaryOperatorKind::BitwiseOr},
    {BinaryOperatorKind::BitwiseXorAssign, BinaryOperatorKind::BitwiseXor},
    {BinaryOperatorKind::ShiftLeftAssign, BinaryOperatorKind::ShiftLeft},
    {BinaryOperatorKind::ShiftRightAssign, BinaryOperatorKind::ShiftRight},
};

template <typename Declaration>
void CollectFlattenedDecls(const std::vector<std::unique_ptr<Decl>>& declarations, std::vector<Declaration*>& result) {
  for (const auto& declaration : declarations) {
    if (!declaration) continue;
    if (declaration->GetKind() == NodeKind::NamespaceDecl) {
      CollectFlattenedDecls(static_cast<const NamespaceDecl&>(*declaration).Decls, result);
    } else {
      result.push_back(declaration.get());
    }
  }
}

const StructType* GetElementStruct(const Type& type) {
  const Type* element = &type;
  while (const auto* array = element->AsArrayType()) {
    element = array->GetElementType().GetTypePtr();
  }
  return element->AsStructType();
}

bool HasDataMembers(const StructDecl& declaration) {
  if (!declaration.Fields.empty()) {
    return true;
  }
  return std::any_of(declaration.base_types.begin(), declaration.base_types.end(),
                     [](const StructType* base) { return base && HasDataMembers(*base->GetDeclaration()); });
}

bool ComputeCXX11StandardLayout(const StructDecl& declaration) {
  if (declaration.IsPolymorphic()) {
    return false;
  }
  // C++11 allows data members in the most derived class or in at most one base, not in both.
  std::size_t bases_with_data = declaration.Fields.empty() ? 0 : 1;
  for (const StructType* base : declaration.base_types) {
    BOOST_ASSERT(base);
    if (!base->GetDeclaration()->IsCXX11StandardLayout()) {
      return false;
    }
    if (HasDataMembers(*base->GetDeclaration())) {
      ++bases_with_data;
    }
  }
  if (bases_with_data > 1) {
    return false;
  }
  for (const auto& field : declaration.Fields) {
    if (const auto* record = GetElementStruct(*field->type.GetTypePtr())) {
      if (!record->GetDeclaration()->IsCXX11StandardLayout()) {
        return false;
      }
      // Use the original C++11 first-member rule, which checks only direct bases, as Clang does.
      if (field == declaration.Fields.front() && std::find(declaration.base_types.begin(), declaration.base_types.end(),
                                                           record) != declaration.base_types.end()) {
        return false;
      }
    }
  }
  return true;
}

}  // namespace

const ComptimeIntType* Type::AsComptimeIntType() const {
  return GetKind() == TypeKind::ComptimeInt ? static_cast<const ComptimeIntType*>(this) : nullptr;
}

const NullType* Type::AsNullType() const {
  return GetKind() == TypeKind::Null ? static_cast<const NullType*>(this) : nullptr;
}

const FunctionOverloadSetType* Type::AsFunctionOverloadSetType() const {
  return GetKind() == TypeKind::FunctionOverloadSet ? static_cast<const FunctionOverloadSetType*>(this) : nullptr;
}

const AddressOfFunctionOverloadSetType* Type::AsAddressOfFunctionOverloadSetType() const {
  return GetKind() == TypeKind::AddressOfFunctionOverloadSet
             ? static_cast<const AddressOfFunctionOverloadSetType*>(this)
             : nullptr;
}

const BuiltinType* Type::AsBuiltinType() const {
  return GetKind() == TypeKind::Builtin ? static_cast<const BuiltinType*>(this) : nullptr;
}

const StructType* Type::AsStructType() const {
  return GetKind() == TypeKind::Struct ? static_cast<const StructType*>(this) : nullptr;
}

const ArrayType* Type::AsArrayType() const {
  return GetKind() == TypeKind::Array ? static_cast<const ArrayType*>(this) : nullptr;
}

const PointerType* Type::AsPointerType() const {
  return GetKind() == TypeKind::Pointer ? static_cast<const PointerType*>(this) : nullptr;
}

const VirtualSlotType* Type::AsVirtualSlotType() const {
  return GetKind() == TypeKind::VirtualSlot ? static_cast<const VirtualSlotType*>(this) : nullptr;
}

const FunctionType* Type::AsFunctionType() const {
  return GetKind() == TypeKind::Function ? static_cast<const FunctionType*>(this) : nullptr;
}

const ReferenceType* Type::AsReferenceType() const {
  return GetKind() == TypeKind::Reference ? static_cast<const ReferenceType*>(this) : nullptr;
}

bool Type::IsVoid() const {
  const auto* builtin = AsBuiltinType();
  return builtin && builtin->GetBuiltinTypeKind() == BuiltinTypeKind::Void;
}

bool Type::IsObject() const { return IsScalar() || AsStructType() || AsArrayType(); }

bool Type::IsScalar() const { return (AsBuiltinType() && !IsVoid()) || AsPointerType() || AsVirtualSlotType(); }

TypeTriviality Type::GetTriviality() const {
  if (const auto* structure = AsStructType()) {
    const auto* declaration = structure->GetDeclaration();
    return declaration ? declaration->triviality : TypeTriviality::Invalid;
  }
  if (const auto* array = AsArrayType()) {
    const auto element = array->GetElementType();
    return element ? element.GetTypePtr()->GetTriviality() : TypeTriviality::Invalid;
  }
  return IsScalar() ? TypeTriviality::Trivial : TypeTriviality::Invalid;
}

bool BuiltinType::IsInteger() const { return IsSignedInteger() || IsUnsignedInteger(); }

bool BuiltinType::IsSignedInteger() const {
  switch (GetBuiltinTypeKind()) {
    case BuiltinTypeKind::I8:
    case BuiltinTypeKind::I16:
    case BuiltinTypeKind::I32:
    case BuiltinTypeKind::I64:
    case BuiltinTypeKind::ISize:
      return true;
    default:
      return false;
  }
}

bool BuiltinType::IsUnsignedInteger() const {
  switch (GetBuiltinTypeKind()) {
    case BuiltinTypeKind::U8:
    case BuiltinTypeKind::U16:
    case BuiltinTypeKind::U32:
    case BuiltinTypeKind::U64:
    case BuiltinTypeKind::USize:
      return true;
    default:
      return false;
  }
}

bool BuiltinType::IsSizeInteger() const {
  return GetBuiltinTypeKind() == BuiltinTypeKind::ISize || GetBuiltinTypeKind() == BuiltinTypeKind::USize;
}

bool BuiltinType::IsFloatingPoint() const {
  return GetBuiltinTypeKind() == BuiltinTypeKind::F32 || GetBuiltinTypeKind() == BuiltinTypeKind::F64;
}

const char* to_string(ImplicitConversionKind kind) {
  switch (kind) {
    case ImplicitConversionKind::Invalid:
      return "Invalid";
    case ImplicitConversionKind::Identity:
      return "Identity";
    case ImplicitConversionKind::NoOp:
      return "NoOp";
    case ImplicitConversionKind::LValueToRValue:
      return "LValueToRValue";
    case ImplicitConversionKind::NullToPointer:
      return "NullToPointer";
    case ImplicitConversionKind::ComptimeIntegerMaterialization:
      return "ComptimeIntegerMaterialization";
    case ImplicitConversionKind::IntegerToInteger:
      return "IntegerToInteger";
    case ImplicitConversionKind::FloatToFloat:
      return "FloatToFloat";
    case ImplicitConversionKind::IntegerToFloat:
      return "IntegerToFloat";
    case ImplicitConversionKind::FloatToInteger:
      return "FloatToInteger";
    case ImplicitConversionKind::Qualification:
      return "Qualification";
    case ImplicitConversionKind::BaseSubobject:
      return "BaseSubobject";
  }
  return "Unknown";
}

const char* to_string(ConstructionKind kind) {
  switch (kind) {
    case ConstructionKind::CompleteObject:
      return "complete-object";
    case ConstructionKind::BaseSubobject:
      return "base-subobject";
    case ConstructionKind::Delegating:
      return "delegating";
  }
  return "unknown";
}

const char* to_string(UnaryOperatorKind kind) {
  switch (kind) {
    case UnaryOperatorKind::PreIncrement:
    case UnaryOperatorKind::PostIncrement:
      return "++";
    case UnaryOperatorKind::PreDecrement:
    case UnaryOperatorKind::PostDecrement:
      return "--";
    case UnaryOperatorKind::Plus:
      return "+";
    case UnaryOperatorKind::Minus:
      return "-";
    case UnaryOperatorKind::LogicalNot:
      return "!";
    case UnaryOperatorKind::BitwiseNot:
      return "~";
    case UnaryOperatorKind::Dereference:
      return "*";
    case UnaryOperatorKind::AddressOf:
      return "&";
    case UnaryOperatorKind::Move:
      return "move";
  }
  return "unknown";
}

const char* to_string(BinaryOperatorKind kind) {
  switch (kind) {
    case BinaryOperatorKind::Multiply:
      return "*";
    case BinaryOperatorKind::Divide:
      return "/";
    case BinaryOperatorKind::Remainder:
      return "%";
    case BinaryOperatorKind::Add:
      return "+";
    case BinaryOperatorKind::Subtract:
      return "-";
    case BinaryOperatorKind::ShiftLeft:
      return "<<";
    case BinaryOperatorKind::ShiftRight:
      return ">>";
    case BinaryOperatorKind::Less:
      return "<";
    case BinaryOperatorKind::LessEqual:
      return "<=";
    case BinaryOperatorKind::Greater:
      return ">";
    case BinaryOperatorKind::GreaterEqual:
      return ">=";
    case BinaryOperatorKind::Equal:
      return "==";
    case BinaryOperatorKind::NotEqual:
      return "!=";
    case BinaryOperatorKind::BitwiseAnd:
      return "&";
    case BinaryOperatorKind::BitwiseXor:
      return "^";
    case BinaryOperatorKind::BitwiseOr:
      return "|";
    case BinaryOperatorKind::LogicalAnd:
      return "&&";
    case BinaryOperatorKind::LogicalOr:
      return "||";
    case BinaryOperatorKind::Assign:
      return "=";
    case BinaryOperatorKind::MultiplyAssign:
      return "*=";
    case BinaryOperatorKind::DivideAssign:
      return "/=";
    case BinaryOperatorKind::RemainderAssign:
      return "%=";
    case BinaryOperatorKind::AddAssign:
      return "+=";
    case BinaryOperatorKind::SubtractAssign:
      return "-=";
    case BinaryOperatorKind::ShiftLeftAssign:
      return "<<=";
    case BinaryOperatorKind::ShiftRightAssign:
      return ">>=";
    case BinaryOperatorKind::BitwiseAndAssign:
      return "&=";
    case BinaryOperatorKind::BitwiseXorAssign:
      return "^=";
    case BinaryOperatorKind::BitwiseOrAssign:
      return "|=";
  }
  return "unknown";
}

const char* to_string(MemberAccessKind kind) {
  switch (kind) {
    case MemberAccessKind::Dot:
      return ".";
    case MemberAccessKind::Arrow:
      return "->";
  }
  return "unknown";
}

const char* to_string(OverloadedOperatorKind kind) {
  switch (kind) {
    case OverloadedOperatorKind::Plus:
      return "+";
    case OverloadedOperatorKind::Minus:
      return "-";
    case OverloadedOperatorKind::PlusPlus:
      return "++";
    case OverloadedOperatorKind::MinusMinus:
      return "--";
    case OverloadedOperatorKind::Exclaim:
      return "!";
    case OverloadedOperatorKind::Tilde:
      return "~";
    case OverloadedOperatorKind::Amp:
      return "&";
    case OverloadedOperatorKind::Pipe:
      return "|";
    case OverloadedOperatorKind::Caret:
      return "^";
    case OverloadedOperatorKind::LessLess:
      return "<<";
    case OverloadedOperatorKind::GreaterGreater:
      return ">>";
    case OverloadedOperatorKind::Star:
      return "*";
    case OverloadedOperatorKind::Slash:
      return "/";
    case OverloadedOperatorKind::Percent:
      return "%";
    case OverloadedOperatorKind::Less:
      return "<";
    case OverloadedOperatorKind::LessEqual:
      return "<=";
    case OverloadedOperatorKind::Greater:
      return ">";
    case OverloadedOperatorKind::GreaterEqual:
      return ">=";
    case OverloadedOperatorKind::EqualEqual:
      return "==";
    case OverloadedOperatorKind::ExclaimEqual:
      return "!=";
    case OverloadedOperatorKind::Equal:
      return "=";
    case OverloadedOperatorKind::PlusEqual:
      return "+=";
    case OverloadedOperatorKind::MinusEqual:
      return "-=";
    case OverloadedOperatorKind::StarEqual:
      return "*=";
    case OverloadedOperatorKind::SlashEqual:
      return "/=";
    case OverloadedOperatorKind::PercentEqual:
      return "%=";
    case OverloadedOperatorKind::AmpEqual:
      return "&=";
    case OverloadedOperatorKind::PipeEqual:
      return "|=";
    case OverloadedOperatorKind::CaretEqual:
      return "^=";
    case OverloadedOperatorKind::LessLessEqual:
      return "<<=";
    case OverloadedOperatorKind::GreaterGreaterEqual:
      return ">>=";
    case OverloadedOperatorKind::Call:
      return "()";
  }
  return "unknown";
}

std::optional<OverloadedOperatorKind> GetOverloadedOperatorKind(std::string_view name) {
  constexpr OverloadedOperatorKind kKinds[] = {
      OverloadedOperatorKind::Plus,
      OverloadedOperatorKind::Minus,
      OverloadedOperatorKind::PlusPlus,
      OverloadedOperatorKind::MinusMinus,
      OverloadedOperatorKind::Exclaim,
      OverloadedOperatorKind::Tilde,
      OverloadedOperatorKind::Amp,
      OverloadedOperatorKind::Pipe,
      OverloadedOperatorKind::Caret,
      OverloadedOperatorKind::LessLess,
      OverloadedOperatorKind::GreaterGreater,
      OverloadedOperatorKind::Star,
      OverloadedOperatorKind::Slash,
      OverloadedOperatorKind::Percent,
      OverloadedOperatorKind::Less,
      OverloadedOperatorKind::LessEqual,
      OverloadedOperatorKind::Greater,
      OverloadedOperatorKind::GreaterEqual,
      OverloadedOperatorKind::EqualEqual,
      OverloadedOperatorKind::ExclaimEqual,
      OverloadedOperatorKind::Equal,
      OverloadedOperatorKind::PlusEqual,
      OverloadedOperatorKind::MinusEqual,
      OverloadedOperatorKind::StarEqual,
      OverloadedOperatorKind::SlashEqual,
      OverloadedOperatorKind::PercentEqual,
      OverloadedOperatorKind::AmpEqual,
      OverloadedOperatorKind::PipeEqual,
      OverloadedOperatorKind::CaretEqual,
      OverloadedOperatorKind::LessLessEqual,
      OverloadedOperatorKind::GreaterGreaterEqual,
      OverloadedOperatorKind::Call,
  };
  for (const auto kind : kKinds) {
    if (name == to_string(kind)) return kind;
  }
  return std::nullopt;
}

std::optional<OverloadedOperatorKind> GetOverloadedOperator(UnaryOperatorKind op) {
  switch (op) {
    case UnaryOperatorKind::PreIncrement:
    case UnaryOperatorKind::PostIncrement:
      return OverloadedOperatorKind::PlusPlus;
    case UnaryOperatorKind::PreDecrement:
    case UnaryOperatorKind::PostDecrement:
      return OverloadedOperatorKind::MinusMinus;
    case UnaryOperatorKind::Plus:
      return OverloadedOperatorKind::Plus;
    case UnaryOperatorKind::Minus:
      return OverloadedOperatorKind::Minus;
    case UnaryOperatorKind::LogicalNot:
      return OverloadedOperatorKind::Exclaim;
    case UnaryOperatorKind::BitwiseNot:
      return OverloadedOperatorKind::Tilde;
    case UnaryOperatorKind::Dereference:
    case UnaryOperatorKind::AddressOf:
    case UnaryOperatorKind::Move:
      return std::nullopt;
  }
  return std::nullopt;
}

std::optional<OverloadedOperatorKind> GetOverloadedOperator(BinaryOperatorKind op) {
  switch (op) {
    case BinaryOperatorKind::Multiply:
      return OverloadedOperatorKind::Star;
    case BinaryOperatorKind::Divide:
      return OverloadedOperatorKind::Slash;
    case BinaryOperatorKind::Remainder:
      return OverloadedOperatorKind::Percent;
    case BinaryOperatorKind::Add:
      return OverloadedOperatorKind::Plus;
    case BinaryOperatorKind::Subtract:
      return OverloadedOperatorKind::Minus;
    case BinaryOperatorKind::ShiftLeft:
      return OverloadedOperatorKind::LessLess;
    case BinaryOperatorKind::ShiftRight:
      return OverloadedOperatorKind::GreaterGreater;
    case BinaryOperatorKind::Less:
      return OverloadedOperatorKind::Less;
    case BinaryOperatorKind::LessEqual:
      return OverloadedOperatorKind::LessEqual;
    case BinaryOperatorKind::Greater:
      return OverloadedOperatorKind::Greater;
    case BinaryOperatorKind::GreaterEqual:
      return OverloadedOperatorKind::GreaterEqual;
    case BinaryOperatorKind::Equal:
      return OverloadedOperatorKind::EqualEqual;
    case BinaryOperatorKind::NotEqual:
      return OverloadedOperatorKind::ExclaimEqual;
    case BinaryOperatorKind::BitwiseAnd:
      return OverloadedOperatorKind::Amp;
    case BinaryOperatorKind::BitwiseXor:
      return OverloadedOperatorKind::Caret;
    case BinaryOperatorKind::BitwiseOr:
      return OverloadedOperatorKind::Pipe;
    case BinaryOperatorKind::LogicalAnd:
    case BinaryOperatorKind::LogicalOr:
      return std::nullopt;
    case BinaryOperatorKind::Assign:
      return OverloadedOperatorKind::Equal;
    case BinaryOperatorKind::MultiplyAssign:
      return OverloadedOperatorKind::StarEqual;
    case BinaryOperatorKind::DivideAssign:
      return OverloadedOperatorKind::SlashEqual;
    case BinaryOperatorKind::RemainderAssign:
      return OverloadedOperatorKind::PercentEqual;
    case BinaryOperatorKind::AddAssign:
      return OverloadedOperatorKind::PlusEqual;
    case BinaryOperatorKind::SubtractAssign:
      return OverloadedOperatorKind::MinusEqual;
    case BinaryOperatorKind::ShiftLeftAssign:
      return OverloadedOperatorKind::LessLessEqual;
    case BinaryOperatorKind::ShiftRightAssign:
      return OverloadedOperatorKind::GreaterGreaterEqual;
    case BinaryOperatorKind::BitwiseAndAssign:
      return OverloadedOperatorKind::AmpEqual;
    case BinaryOperatorKind::BitwiseXorAssign:
      return OverloadedOperatorKind::CaretEqual;
    case BinaryOperatorKind::BitwiseOrAssign:
      return OverloadedOperatorKind::PipeEqual;
  }
  return std::nullopt;
}

bool IsOperatorFunctionName(std::string_view name) {
  return IsAssignmentOperator(name) || name == "." || name == "->" || name == "&" || name == "&&" || name == "*" ||
         name == "+" || name == "++" || name == "-" || name == "--" || name == "~" || name == "!" || name == "!=" ||
         name == "/" || name == "%" || name == "<" || name == "<=" || name == "<<" || name == ">" || name == ">=" ||
         name == ">>" || name == "^" || name == "|" || name == "||" || name == "?" || name == ":" || name == "::" ||
         name == ":=" || name == "==" || name == "," || name == "[]" || name == "()";
}

bool IsIncrementDecrementOperator(UnaryOperatorKind op) {
  return op == UnaryOperatorKind::PreIncrement || op == UnaryOperatorKind::PreDecrement ||
         op == UnaryOperatorKind::PostIncrement || op == UnaryOperatorKind::PostDecrement;
}

bool IsPostfixOperator(UnaryOperatorKind op) {
  return op == UnaryOperatorKind::PostIncrement || op == UnaryOperatorKind::PostDecrement;
}

bool IsLogicalBinaryOperator(BinaryOperatorKind op) {
  return op == BinaryOperatorKind::LogicalAnd || op == BinaryOperatorKind::LogicalOr;
}

bool IsShiftBinaryOperator(BinaryOperatorKind op) {
  return op == BinaryOperatorKind::ShiftLeft || op == BinaryOperatorKind::ShiftRight;
}

bool IsCompoundAssignmentOperator(BinaryOperatorKind op) { return GetComputationOp(op) != op; }

bool IsAssignmentOperator(BinaryOperatorKind op) {
  return op == BinaryOperatorKind::Assign || IsCompoundAssignmentOperator(op);
}

bool IsAssignmentOperator(std::string_view name) {
  if (name == "=") return true;
  for (const auto& assignment : kCompoundAssignmentOperators) {
    if (name == to_string(assignment.first)) return true;
  }
  return false;
}

BinaryOperatorKind GetComputationOp(BinaryOperatorKind op) {
  for (const auto& [assignment, computation] : kCompoundAssignmentOperators) {
    if (op == assignment) return computation;
  }
  return op;
}

bool IsRawObjectPointerType(QualType type) {
  const auto* pointer = type ? type.GetTypePtr()->AsPointerType() : nullptr;
  return pointer && pointer->GetPointee().GetTypePtr()->IsObject();
}

PointerArithmeticKind ClassifyPointerArithmetic(BinaryOperatorKind op, QualType lhs, QualType rhs) {
  const auto is_size_integer = [](QualType type) {
    const auto* builtin = type ? type.GetTypePtr()->AsBuiltinType() : nullptr;
    return builtin && builtin->IsSizeInteger();
  };
  const bool pointer_lhs = IsRawObjectPointerType(lhs);
  const bool pointer_rhs = IsRawObjectPointerType(rhs);
  switch (op) {
    case BinaryOperatorKind::Add:
      return (pointer_lhs && is_size_integer(rhs)) || (is_size_integer(lhs) && pointer_rhs)
                 ? PointerArithmeticKind::Offset
                 : PointerArithmeticKind::None;
    case BinaryOperatorKind::Subtract:
      if (pointer_lhs && is_size_integer(rhs)) return PointerArithmeticKind::Offset;
      return pointer_lhs && pointer_rhs ? PointerArithmeticKind::Difference : PointerArithmeticKind::None;
    case BinaryOperatorKind::AddAssign:
    case BinaryOperatorKind::SubtractAssign:
      // Compound assignment writes back to its target, so only the pointer can be on the left.
      return pointer_lhs && is_size_integer(rhs) ? PointerArithmeticKind::Offset : PointerArithmeticKind::None;
    default:
      return PointerArithmeticKind::None;
  }
}

// Type Accept and Traverse implementations.

void BuiltinTypeSyntax::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void BuiltinTypeSyntax::Traverse(ASTVisitor& visitor) {}

void NamedTypeSyntax::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void NamedTypeSyntax::Traverse(ASTVisitor& visitor) {}

void PointerTypeSyntax::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void PointerTypeSyntax::Traverse(ASTVisitor& visitor) {
  if (Pointee) {
    Pointee->Accept(visitor);
  }
}

void FunctionTypeSyntax::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void FunctionTypeSyntax::Traverse(ASTVisitor& visitor) {
  for (auto& parameter_type : ParameterTypes) {
    if (parameter_type) {
      parameter_type->Accept(visitor);
    }
  }
  if (ReturnType) {
    ReturnType->Accept(visitor);
  }
}

void VirtualSlotTypeSyntax::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void VirtualSlotTypeSyntax::Traverse(ASTVisitor& visitor) {
  if (FunctionPointer) {
    FunctionPointer->Accept(visitor);
  }
}

void ConstTypeSyntax::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ConstTypeSyntax::Traverse(ASTVisitor& visitor) {
  if (QualifiedType) {
    QualifiedType->Accept(visitor);
  }
}

void ReferenceTypeSyntax::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ReferenceTypeSyntax::Traverse(ASTVisitor& visitor) {
  if (ReferentType) {
    ReferentType->Accept(visitor);
  }
}

void ArrayTypeSyntax::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ArrayTypeSyntax::Traverse(ASTVisitor& visitor) {
  if (Length) {
    Length->Accept(visitor);
  }
  if (ElementType) {
    ElementType->Accept(visitor);
  }
}

// Decl Accept and Traverse implementations.

void TranslationUnitDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void TranslationUnitDecl::Traverse(ASTVisitor& visitor) {
  for (auto& Decl : Decls) {
    if (Decl) {
      Decl->Accept(visitor);
    }
  }
}

std::string NamedDecl::QualifiedName() const {
  return !owning_namespace || owning_namespace->IsRoot() ? name : owning_namespace->QualifiedName() + "::" + name;
}

void NamespaceDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void NamespaceDecl::Traverse(ASTVisitor& visitor) {
  for (const auto& declaration : Decls) {
    if (declaration) declaration->Accept(visitor);
  }
}

std::vector<Decl*> TranslationUnitDecl::FlattenedDecls() {
  std::vector<Decl*> result;
  CollectFlattenedDecls(Decls, result);
  return result;
}

std::vector<const Decl*> TranslationUnitDecl::FlattenedDecls() const {
  std::vector<const Decl*> result;
  CollectFlattenedDecls(Decls, result);
  return result;
}

void VirtualDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void VirtualDecl::Traverse(ASTVisitor& visitor) {
  for (auto& Function : Functions) {
    if (Function) {
      Function->Accept(visitor);
    }
  }
}

void VarGroupDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void VarGroupDecl::Traverse(ASTVisitor& visitor) {
  for (auto& Var : Vars) {
    if (Var) {
      Var->Accept(visitor);
    }
  }
  for (auto& InitExpr : InitExprs) {
    if (InitExpr) {
      InitExpr->Accept(visitor);
    }
  }
  if (Body) {
    Body->Accept(visitor);
  }
}

void VarDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void VarDecl::Traverse(ASTVisitor& visitor) {
  if (Type) {
    Type->Accept(visitor);
  }
}

bool StructDecl::IsPolymorphic() const {
  return (VirtualDecl && !VirtualDecl->Functions.empty()) ||
         std::any_of(base_types.begin(), base_types.end(),
                     [](const StructType* base) { return base && base->GetDeclaration()->IsPolymorphic(); });
}

bool StructDecl::IsEmpty() const {
  return Fields.empty() && (!VirtualDecl || VirtualDecl->Functions.empty()) &&
         std::all_of(base_types.begin(), base_types.end(),
                     [](const StructType* base) { return !base || base->GetDeclaration()->IsEmpty(); });
}

bool StructDecl::IsCXX11StandardLayout() const {
  BOOST_ASSERT(!is_invalid);
  BOOST_ASSERT(triviality == TypeTriviality::Trivial || triviality == TypeTriviality::NonTrivial);
  if (!cxx11_standard_layout_.has_value()) {
    cxx11_standard_layout_ = ComputeCXX11StandardLayout(*this);
  }
  return *cxx11_standard_layout_;
}

void StructDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void StructDecl::Traverse(ASTVisitor& visitor) {
  if (VirtualDecl) {
    VirtualDecl->Accept(visitor);
  }
  for (auto& Field : Fields) {
    if (Field) {
      Field->Accept(visitor);
    }
  }
}

void FunctionDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void FunctionDecl::Traverse(ASTVisitor& visitor) {
  for (auto& ParmVar : ParmVars) {
    if (ParmVar) {
      ParmVar->Accept(visitor);
    }
  }
  if (ReturnVar) {
    ReturnVar->Accept(visitor);
  }
  if (Body) {
    Body->Accept(visitor);
  }
}

void ConstructorDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }

void DestructorDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }

void VirtualFunctionDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }

void ParmVarDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ParmVarDecl::Traverse(ASTVisitor& visitor) { VarDecl::Traverse(visitor); }

void ReturnVarDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ReturnVarDecl::Traverse(ASTVisitor& visitor) { VarDecl::Traverse(visitor); }

void FieldDecl::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void FieldDecl::Traverse(ASTVisitor& visitor) {
  if (Type) {
    Type->Accept(visitor);
  }
}

// Stmt Accept and Traverse implementations.

void CompoundStmt::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void CompoundStmt::Traverse(ASTVisitor& visitor) {
  for (auto& Stmt : Stmts) {
    if (Stmt) {
      Stmt->Accept(visitor);
    }
  }
  for (auto& TailExpr : TailExprs) {
    if (TailExpr) {
      TailExpr->Accept(visitor);
    }
  }
}

void ExprStmt::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ExprStmt::Traverse(ASTVisitor& visitor) {
  if (Expr) {
    Expr->Accept(visitor);
  }
}

void ImplicitThisInitializationCompleteStmt::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ImplicitThisInitializationCompleteStmt::Traverse(ASTVisitor&) {}

void DeclStmt::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void DeclStmt::Traverse(ASTVisitor& visitor) {
  if (Decl) {
    Decl->Accept(visitor);
  }
}

void IfStmt::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void IfStmt::Traverse(ASTVisitor& visitor) {
  if (Cond) {
    Cond->Accept(visitor);
  }
  if (Then) {
    Then->Accept(visitor);
  }
  if (Else) {
    Else->Accept(visitor);
  }
}

void WhileStmt::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void WhileStmt::Traverse(ASTVisitor& visitor) {
  if (Cond) {
    Cond->Accept(visitor);
  }
  if (Body) {
    Body->Accept(visitor);
  }
}

void BreakStmt::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void BreakStmt::Traverse(ASTVisitor& visitor) {}

void ContinueStmt::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ContinueStmt::Traverse(ASTVisitor& visitor) {}

void ReturnStmt::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ReturnStmt::Traverse(ASTVisitor& visitor) {
  if (Expr) {
    Expr->Accept(visitor);
  }
}

// Expr Accept and Traverse implementations.

Expr* Expr::IgnoreParens() {
  Expr* expression = this;
  while (expression->GetKind() == NodeKind::ParenExpr) {
    auto* paren = static_cast<ParenExpr*>(expression);
    if (!paren->SubExpr) {
      break;
    }
    expression = paren->SubExpr.get();
  }
  return expression;
}

const Expr* Expr::IgnoreParens() const {
  const Expr* expression = this;
  while (expression->GetKind() == NodeKind::ParenExpr) {
    const auto* paren = static_cast<const ParenExpr*>(expression);
    if (!paren->SubExpr) {
      break;
    }
    expression = paren->SubExpr.get();
  }
  return expression;
}

void IntegerLiteral::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void IntegerLiteral::Traverse(ASTVisitor& visitor) {}

void CharacterLiteral::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void CharacterLiteral::Traverse(ASTVisitor& visitor) {}

void FloatLiteral::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void FloatLiteral::Traverse(ASTVisitor& visitor) {}

void BoolLiteral::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void BoolLiteral::Traverse(ASTVisitor& visitor) {}

void NullLiteral::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void NullLiteral::Traverse(ASTVisitor& visitor) {}

void StringLiteral::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void StringLiteral::Traverse(ASTVisitor& visitor) {}

void DeclRefExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void DeclRefExpr::Traverse(ASTVisitor& visitor) {}

void ThisExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ThisExpr::Traverse(ASTVisitor& visitor) {}

void ParenExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ParenExpr::Traverse(ASTVisitor& visitor) {
  if (SubExpr) {
    SubExpr->Accept(visitor);
  }
}

void UnaryOperator::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void UnaryOperator::Traverse(ASTVisitor& visitor) {
  if (Operand) {
    Operand->Accept(visitor);
  }
}

void BinaryOperator::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void BinaryOperator::Traverse(ASTVisitor& visitor) {
  if (LHS) {
    LHS->Accept(visitor);
  }
  if (RHS) {
    RHS->Accept(visitor);
  }
}

void InitializationExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void InitializationExpr::Traverse(ASTVisitor& visitor) {
  if (Target) {
    Target->Accept(visitor);
  }
  if (Source) {
    Source->Accept(visitor);
  }
}

void ImplicitResultInitializationExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ImplicitResultInitializationExpr::Traverse(ASTVisitor& visitor) {
  if (Source) {
    Source->Accept(visitor);
  }
}

void ConditionalOperator::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ConditionalOperator::Traverse(ASTVisitor& visitor) {
  if (Cond) {
    Cond->Accept(visitor);
  }
  if (Then) {
    Then->Accept(visitor);
  }
  if (Else) {
    Else->Accept(visitor);
  }
}

void MemberExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void MemberExpr::Traverse(ASTVisitor& visitor) {
  if (Base) {
    Base->Accept(visitor);
  }
}

void BaseSubobjectExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void BaseSubobjectExpr::Traverse(ASTVisitor& visitor) {
  if (Base) {
    Base->Accept(visitor);
  }
}

void SubscriptExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void SubscriptExpr::Traverse(ASTVisitor& visitor) {
  if (Base) {
    Base->Accept(visitor);
  }
  if (Index) {
    Index->Accept(visitor);
  }
}

void ArrayValueExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ArrayValueExpr::Traverse(ASTVisitor& visitor) {
  if (Type) {
    Type->Accept(visitor);
  }
  for (auto& element : Elements) {
    if (element) {
      element->Accept(visitor);
    }
  }
}

void BuiltinTypeExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void BuiltinTypeExpr::Traverse(ASTVisitor& visitor) {}

void ScalarValueInitExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ScalarValueInitExpr::Traverse(ASTVisitor& visitor) {}

void FunctionalCastExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void FunctionalCastExpr::Traverse(ASTVisitor& visitor) {
  if (SubExpr) {
    SubExpr->Accept(visitor);
  }
}

void CallExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void CallExpr::Traverse(ASTVisitor& visitor) {
  if (Callee) {
    Callee->Accept(visitor);
  }
  for (auto& Arg : Args) {
    if (Arg) {
      Arg->Accept(visitor);
    }
  }
}

void OperatorCallExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }

bool OperatorCallExpr::IsAssignment() const {
  if (Args.size() != 2 || !Args[0] || !Args[1] || !Callee || Callee->GetKind() != NodeKind::DeclRefExpr) {
    return false;
  }
  const ValueDecl* declaration = static_cast<const DeclRefExpr&>(*Callee).declaration;
  if (!declaration) {
    return false;
  }
  switch (declaration->GetKind()) {
    case NodeKind::FunctionDecl:
    case NodeKind::VirtualFunctionDecl:
      return IsAssignmentOperator(static_cast<const FunctionDecl*>(declaration)->name);
    default:
      return false;
  }
}

void ConstructionExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ConstructionExpr::Traverse(ASTVisitor& visitor) {
  if (TargetAddress) {
    TargetAddress->Accept(visitor);
  }
  for (auto& Arg : Args) {
    if (Arg) {
      Arg->Accept(visitor);
    }
  }
}

void ArrayConstructionExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ArrayConstructionExpr::Traverse(ASTVisitor& visitor) {
  if (Source) {
    Source->Accept(visitor);
  }
}

void OpaqueValueExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void OpaqueValueExpr::Traverse(ASTVisitor& visitor) {}

void ArrayAssignmentExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ArrayAssignmentExpr::Traverse(ASTVisitor& visitor) {
  if (LHS) {
    LHS->Accept(visitor);
  }
  if (RHS) {
    RHS->Accept(visitor);
  }
  if (ElementAssignment) {
    ElementAssignment->Accept(visitor);
  }
}

void DestructorCallExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void DestructorCallExpr::Traverse(ASTVisitor& visitor) {
  if (TargetAddress) {
    TargetAddress->Accept(visitor);
  }
  if (Callee) {
    Callee->Accept(visitor);
  }
  for (auto& Arg : Args) {
    if (Arg) {
      Arg->Accept(visitor);
    }
  }
}

void ReceiverCallExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ReceiverCallExpr::Traverse(ASTVisitor& visitor) {
  if (Receiver) {
    Receiver->Accept(visitor);
  }
  if (Callee) {
    Callee->Accept(visitor);
  }
  for (auto& Arg : Args) {
    if (Arg) {
      Arg->Accept(visitor);
    }
  }
}

void ImplicitOverloadSetSelectionExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ImplicitOverloadSetSelectionExpr::Traverse(ASTVisitor& visitor) {
  if (SubExpr) {
    SubExpr->Accept(visitor);
  }
}

void ImplicitCastExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ImplicitCastExpr::Traverse(ASTVisitor& visitor) {
  if (SubExpr) {
    SubExpr->Accept(visitor);
  }
}

void MaterializeTemporaryExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void MaterializeTemporaryExpr::Traverse(ASTVisitor& visitor) {
  if (SubExpr) {
    SubExpr->Accept(visitor);
  }
}

void RecoveryExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void RecoveryExpr::Traverse(ASTVisitor& visitor) {}

}  // namespace cw
