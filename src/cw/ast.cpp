/// \file ast.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "ast.h"

#include "ASTVisitor.h"

namespace cw {

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
    case ImplicitConversionKind::DerivedToBase:
      return "DerivedToBase";
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

bool IsOperatorFunctionName(const std::string& name) {
  return name == "." || name == "->" || name == "&" || name == "&&" || name == "*" || name == "+" || name == "++" ||
         name == "-" || name == "--" || name == "~" || name == "!" || name == "!=" || name == "/" || name == "%" ||
         name == "<" || name == "<=" || name == "<<" || name == ">" || name == ">=" || name == ">>" || name == "^" ||
         name == "|" || name == "||" || name == "?" || name == ":" || name == "::" || name == ":=" || name == "=" ||
         name == "+=" || name == "-=" || name == "*=" || name == "/=" || name == "%=" || name == "<<=" ||
         name == ">>=" || name == "&=" || name == "^=" || name == "|=" || name == "==" || name == "," || name == "[]" ||
         name == "()";
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

void ArrayAssignmentExpr::Accept(ASTVisitor& visitor) { visitor.Visit(*this); }
void ArrayAssignmentExpr::Traverse(ASTVisitor& visitor) {
  if (LHS) {
    LHS->Accept(visitor);
  }
  if (RHS) {
    RHS->Accept(visitor);
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
