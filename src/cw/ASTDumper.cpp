/// \file ASTDumper.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "ASTDumper.h"

#include <cstdint>
#include <iomanip>

namespace cw {

ASTDumper::ASTDumper(std::ostream& os, const std::vector<Source>& sources) : os_(os), sources_(sources) {}

void ASTDumper::Dump(Node& node) {
  indent_stack_.clear();
  previous_location_ = {};
  node.Accept(*this);
}

void ASTDumper::PrintIndent() {
  for (size_t i = 0; i < indent_stack_.size(); ++i) {
    if (i == indent_stack_.size() - 1) {
      os_ << (indent_stack_[i] ? "`-" : "|-");
    } else {
      os_ << (indent_stack_[i] ? "  " : "| ");
    }
  }
}

void ASTDumper::PushIndent(bool is_last) { indent_stack_.push_back(is_last); }

void ASTDumper::PopIndent() { indent_stack_.pop_back(); }

void ASTDumper::PrintAddress(const void* address) {
  const auto flags = os_.flags();
  os_ << "0x" << std::hex << std::nouppercase << std::noshowbase << std::noshowpos
      << reinterpret_cast<std::uintptr_t>(address);
  os_.flags(flags);
}

void ASTDumper::PrintNodeIdentity(const char* name, const Node& n) {
  PrintIndent();
  os_ << name << " ";
  PrintAddress(&n);
}

void ASTDumper::PrintNode(const char* name, const Node& n) {
  PrintNodeIdentity(name, n);
  os_ << " ";
  PrintSourceRange(n.range);
}

void ASTDumper::PrintSourceRange(const SourceRange& range) {
  if (!range.IsValid() || !IsPrintable(range.begin) || !IsPrintable(range.end)) {
    os_ << "<invalid sloc>";
    return;
  }

  os_ << "<";
  PrintSourceLocation(range.begin);
  os_ << ", ";
  PrintSourceLocation(range.end);
  os_ << ">";
}

void ASTDumper::PrintSourceLocation(const SourceLocation& location) {
  // Abbreviations refer to the last printed endpoint, even across node boundaries.
  if (!previous_location_.IsValid() || previous_location_.file != location.file) {
    os_ << sources_[location.file].path.string() << ":" << location.line + 1 << ":" << location.column + 1;
  } else if (previous_location_.line != location.line) {
    os_ << "line:" << location.line + 1 << ":" << location.column + 1;
  } else {
    os_ << "col:" << location.column + 1;
  }
  previous_location_ = location;
}

void ASTDumper::PrintEscapedString(std::string_view value) {
  constexpr char kHexDigits[] = "0123456789abcdef";

  for (unsigned char c : value) {
    switch (c) {
      case '\a':
        os_ << "\\a";
        break;
      case '\b':
        os_ << "\\b";
        break;
      case '\f':
        os_ << "\\f";
        break;
      case '\n':
        os_ << "\\n";
        break;
      case '\r':
        os_ << "\\r";
        break;
      case '\t':
        os_ << "\\t";
        break;
      case '\v':
        os_ << "\\v";
        break;
      case '\0':
        os_ << "\\0";
        break;
      case '\\':
        os_ << "\\\\";
        break;
      case '"':
        os_ << "\\\"";
        break;
      default:
        if (c < 0x20 || c == 0x7f) {
          os_ << "\\x" << kHexDigits[c >> 4] << kHexDigits[c & 0xf];
        } else {
          os_ << c;
        }
        break;
    }
  }
}

void ASTDumper::PrintTypeName(QualType type) {
  if (!type) {
    return;
  }
  if (type.IsConstQualified()) {
    os_ << "const ";
  }
  PrintUnqualifiedTypeName(*type.GetTypePtr());
}

void ASTDumper::PrintUnqualifiedTypeName(const Type& type) {
  switch (type.GetKind()) {
    case TypeKind::ComptimeInt:
      os_ << "comptime_int";
      break;
    case TypeKind::Null:
      os_ << "<null>";
      break;
    case TypeKind::FunctionOverloadSet:
      os_ << "<function-overload-set>";
      break;
    case TypeKind::AddressOfFunctionOverloadSet:
      os_ << "<address-of-function-overload-set>";
      break;
    case TypeKind::Builtin:
      os_ << to_string(static_cast<const BuiltinType&>(type).GetBuiltinTypeKind());
      break;
    case TypeKind::Struct:
      os_ << static_cast<const StructType&>(type).GetDeclaration()->name;
      break;
    case TypeKind::Array: {
      const auto& array_type = static_cast<const ArrayType&>(type);
      os_ << "[" << array_type.GetLength() << "] ";
      PrintTypeName(array_type.GetElementType());
      break;
    }
    case TypeKind::Pointer:
      os_ << "*";
      PrintTypeName(static_cast<const PointerType&>(type).GetPointee());
      break;
    case TypeKind::VirtualSlot:
      os_ << "virtual ";
      PrintUnqualifiedTypeName(*static_cast<const VirtualSlotType&>(type).GetEntryPointerType());
      break;
    case TypeKind::Function: {
      const auto& function_type = static_cast<const FunctionType&>(type);
      os_ << "func (";
      const auto& parameter_types = function_type.GetParameterTypes();
      for (std::size_t i = 0; i < parameter_types.size(); ++i) {
        if (i != 0) {
          os_ << ", ";
        }
        PrintTypeName(QualType(parameter_types[i]));
      }
      os_ << ") ";
      PrintTypeName(QualType(function_type.GetReturnType()));
      break;
    }
    case TypeKind::Reference: {
      const auto& reference_type = static_cast<const ReferenceType&>(type);
      switch (reference_type.GetMode()) {
        case ReferenceMode::Mut:
          os_ << "mut ";
          break;
        case ReferenceMode::Copy:
          os_ << "copy ";
          break;
        case ReferenceMode::Move:
          os_ << "move ";
          break;
      }
      PrintTypeName(QualType(reference_type.GetReferentType()));
      break;
    }
  }
}

void ASTDumper::PrintType(QualType type) {
  if (!type) {
    return;
  }
  os_ << " '";
  PrintTypeName(type);
  os_ << "'";
}

void ASTDumper::PrintExprType(const Expr& expression) {
  PrintType(expression.type);
  switch (expression.value_category) {
    case ValueCategory::None:
      break;
    case ValueCategory::LValue:
      os_ << " lvalue";
      break;
    case ValueCategory::MoveLValue:
      os_ << " move-lvalue";
      break;
    case ValueCategory::PureRValue:
      os_ << " pure-rvalue";
      break;
  }
}

void ASTDumper::PrintDeclReference(const ValueDecl& declaration) {
  const char* kind = "Value";
  switch (declaration.GetKind()) {
    case NodeKind::VarDecl:
      kind = "Var";
      break;
    case NodeKind::ParmVarDecl:
      kind = "ParmVar";
      break;
    case NodeKind::ReturnVarDecl:
      kind = "ReturnVar";
      break;
    case NodeKind::FieldDecl:
      kind = "Field";
      break;
    case NodeKind::FunctionDecl:
      kind = "Function";
      break;
    case NodeKind::ConstructorDecl:
      kind = "Constructor";
      break;
    case NodeKind::DestructorDecl:
      kind = "Destructor";
      break;
    case NodeKind::VirtualFunctionDecl:
      kind = "VirtualFunction";
      break;
    default:
      break;
  }

  os_ << " " << kind << " ";
  PrintAddress(&declaration);
  if (!declaration.name.empty()) {
    if ((declaration.GetKind() == NodeKind::FunctionDecl || declaration.GetKind() == NodeKind::VirtualFunctionDecl) &&
        IsOperatorFunctionName(declaration.name)) {
      os_ << " 'operator" << declaration.name << "'";
    } else {
      os_ << " '" << declaration.name << "'";
    }
  }
  PrintType(declaration.type);
}

void ASTDumper::PrintStructReference(const StructDecl& declaration) {
  os_ << " Struct ";
  PrintAddress(&declaration);
  if (!declaration.name.empty()) {
    os_ << " '" << declaration.name << "'";
  }
}

void ASTDumper::PrintSpecialFunctionTarget(const StructType* target_type) {
  if (!target_type) {
    return;
  }
  os_ << " target Struct ";
  PrintAddress(target_type->GetDeclaration());
  PrintType(QualType(target_type));
}

void ASTDumper::PrintBaseType(const StructType& type, bool is_last) {
  PushIndent(is_last);
  PrintIndent();
  os_ << "BaseType";
  PrintType(QualType{&type});

  const StructDecl* declaration = type.GetDeclaration();
  os_ << " Struct ";
  PrintAddress(declaration);
  if (declaration && !declaration->name.empty()) {
    os_ << " '" << declaration->name << "'";
  }
  os_ << "\n";
  PopIndent();
}

bool ASTDumper::IsPrintable(const SourceLocation& location) const {
  return location.IsValid() && location.file < static_cast<int>(sources_.size());
}

void ASTDumper::PrintErrorMark(const Node& n) {
  if (n.contains_errors) {
    os_ << " contains-errors";
  }
}

void ASTDumper::VisitChild(Node* child, bool is_last) {
  if (child) {
    PushIndent(is_last);
    child->Accept(*this);
    PopIndent();
  }
}

// =============================================================================
// Type Visit implementations
// =============================================================================

void ASTDumper::Visit(BuiltinTypeSyntax& n) {
  PrintNode("BuiltinType", n);
  os_ << " '" << to_string(n.kind) << "'";
  PrintErrorMark(n);
  os_ << "\n";
}

void ASTDumper::Visit(NamedTypeSyntax& n) {
  PrintNode("NamedType", n);
  os_ << " '" << n.name << "'";
  PrintErrorMark(n);
  os_ << "\n";
}

void ASTDumper::Visit(PointerTypeSyntax& n) {
  PrintNode("PointerType", n);
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Pointee.get(), true);
}

void ASTDumper::Visit(FunctionTypeSyntax& n) {
  PrintNode("FunctionType", n);
  PrintErrorMark(n);
  os_ << "\n";

  const std::size_t total_children = n.ParameterTypes.size() + (n.ReturnType ? 1 : 0);
  std::size_t child_index = 0;
  for (const auto& parameter_type : n.ParameterTypes) {
    VisitChild(parameter_type.get(), ++child_index == total_children);
  }
  if (n.ReturnType) {
    VisitChild(n.ReturnType.get(), ++child_index == total_children);
  }
}

void ASTDumper::Visit(VirtualSlotTypeSyntax& n) {
  PrintNode("VirtualSlotType", n);
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.FunctionPointer.get(), true);
}

void ASTDumper::Visit(ConstTypeSyntax& n) {
  PrintNode("ConstType", n);
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.QualifiedType.get(), true);
}

void ASTDumper::Visit(ReferenceTypeSyntax& n) {
  PrintNode("ReferenceType", n);
  switch (n.mode) {
    case ReferenceMode::Mut:
      os_ << " 'mut'";
      break;
    case ReferenceMode::Copy:
      os_ << " 'copy'";
      break;
    case ReferenceMode::Move:
      os_ << " 'move'";
      break;
  }
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.ReferentType.get(), true);
}

void ASTDumper::Visit(ArrayTypeSyntax& n) {
  PrintNode("ArrayType", n);
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Length.get(), false);
  VisitChild(n.ElementType.get(), true);
}

// =============================================================================
// Decl Visit implementations
// =============================================================================

void ASTDumper::Visit(TranslationUnitDecl& n) {
  PrintNodeIdentity("TranslationUnitDecl", n);
  PrintErrorMark(n);
  os_ << "\n";
  for (size_t i = 0; i < n.Decls.size(); ++i) {
    VisitChild(n.Decls[i].get(), i == n.Decls.size() - 1);
  }
}

void ASTDumper::Visit(VirtualDecl& n) {
  PrintNode("VirtualDecl", n);
  PrintErrorMark(n);
  os_ << "\n";
  for (size_t i = 0; i < n.Functions.size(); ++i) {
    VisitChild(n.Functions[i].get(), i == n.Functions.size() - 1);
  }
}

void ASTDumper::Visit(VarGroupDecl& n) {
  PrintNode("VarGroupDecl", n);
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = n.Vars.size() + n.InitExprs.size() + (n.Body ? 1 : 0);
  size_t child_idx = 0;
  for (const auto& var : n.Vars) {
    VisitChild(var.get(), ++child_idx == total_children);
  }
  for (const auto& init_expr : n.InitExprs) {
    VisitChild(init_expr.get(), ++child_idx == total_children);
  }
  if (n.Body) {
    VisitChild(n.Body.get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(VarDecl& n) {
  PrintNode("VarDecl", n);
  if (!n.name.empty()) {
    os_ << " " << n.name;
  }
  PrintType(n.type);
  for (const auto& attribute : n.attributes) {
    os_ << " attr='" << attribute.name << "'";
  }
  PrintErrorMark(n);
  os_ << "\n";
  if (n.Type) {
    VisitChild(n.Type.get(), true);
  }
}

void ASTDumper::Visit(StructDecl& n) {
  PrintNode("StructDecl", n);
  if (!n.name.empty()) {
    os_ << " " << n.name;
  }
  if (n.is_declared_trivial) {
    os_ << " trivial";
  }
  if (n.is_abstract) {
    os_ << " abstract";
  }
  if (!n.base.empty()) {
    os_ << " : '" << n.base << "'";
  }
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = (n.base_type ? 1 : 0) + (n.VirtualDecl ? 1 : 0) + n.Fields.size();
  size_t child_idx = 0;
  if (n.base_type) {
    PrintBaseType(*n.base_type, ++child_idx == total_children);
  }
  if (n.VirtualDecl) {
    VisitChild(n.VirtualDecl.get(), ++child_idx == total_children);
  }
  for (size_t i = 0; i < n.Fields.size(); ++i) {
    VisitChild(n.Fields[i].get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(FunctionDecl& n) {
  PrintNode("FunctionDecl", n);
  if (!n.name.empty()) {
    os_ << (IsOperatorFunctionName(n.name) ? " operator" : " ") << n.name;
  }
  PrintType(n.type);
  if (n.virtual_declaration) {
    os_ << " virtual-declaration";
    PrintDeclReference(*n.virtual_declaration);
  }
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = n.ParmVars.size() + (n.ReturnVar ? 1 : 0) + (n.Body ? 1 : 0);
  size_t child_idx = 0;
  for (size_t i = 0; i < n.ParmVars.size(); ++i) {
    VisitChild(n.ParmVars[i].get(), ++child_idx == total_children);
  }
  if (n.ReturnVar) {
    VisitChild(n.ReturnVar.get(), ++child_idx == total_children);
  }
  if (n.Body) {
    VisitChild(n.Body.get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(ConstructorDecl& n) {
  PrintNode("ConstructorDecl", n);
  if (!n.name.empty()) {
    os_ << " " << n.name;
  }
  PrintSpecialFunctionTarget(n.target_type);
  PrintType(n.type);
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = n.ParmVars.size() + (n.ReturnVar ? 1 : 0) + (n.Body ? 1 : 0);
  size_t child_idx = 0;
  for (size_t i = 0; i < n.ParmVars.size(); ++i) {
    VisitChild(n.ParmVars[i].get(), ++child_idx == total_children);
  }
  if (n.ReturnVar) {
    VisitChild(n.ReturnVar.get(), ++child_idx == total_children);
  }
  if (n.Body) {
    VisitChild(n.Body.get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(DestructorDecl& n) {
  PrintNode("DestructorDecl", n);
  if (!n.name.empty()) {
    os_ << " " << n.name;
  }
  PrintSpecialFunctionTarget(n.target_type);
  PrintType(n.type);
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = n.ParmVars.size() + (n.ReturnVar ? 1 : 0) + (n.Body ? 1 : 0);
  size_t child_idx = 0;
  for (size_t i = 0; i < n.ParmVars.size(); ++i) {
    VisitChild(n.ParmVars[i].get(), ++child_idx == total_children);
  }
  if (n.ReturnVar) {
    VisitChild(n.ReturnVar.get(), ++child_idx == total_children);
  }
  if (n.Body) {
    VisitChild(n.Body.get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(VirtualFunctionDecl& n) {
  PrintNode("VirtualFunctionDecl", n);
  if (!n.name.empty()) {
    os_ << " " << n.name;
  }
  PrintType(n.type);
  if (n.is_override) {
    os_ << " override";
  }
  if (n.is_abstract) {
    os_ << " abstract";
  }
  if (n.overridden_virtual_function) {
    os_ << " overrides";
    PrintDeclReference(*n.overridden_virtual_function);
  }
  if (n.definition) {
    os_ << " definition";
    PrintDeclReference(*n.definition);
  }
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = n.ParmVars.size() + (n.ReturnVar ? 1 : 0);
  size_t child_idx = 0;
  for (const auto& parm_var : n.ParmVars) {
    VisitChild(parm_var.get(), ++child_idx == total_children);
  }
  if (n.ReturnVar) {
    VisitChild(n.ReturnVar.get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(ParmVarDecl& n) {
  PrintNode("ParmVarDecl", n);
  if (!n.name.empty()) {
    os_ << " " << n.name;
  }
  PrintType(n.type);
  for (const auto& attribute : n.attributes) {
    os_ << " attr='" << attribute.name << "'";
  }
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Type.get(), true);
}

void ASTDumper::Visit(ReturnVarDecl& n) {
  PrintNode("ReturnVarDecl", n);
  if (!n.name.empty()) {
    os_ << " " << n.name;
  }
  PrintType(n.type);
  for (const auto& attribute : n.attributes) {
    os_ << " attr='" << attribute.name << "'";
  }
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Type.get(), true);
}

void ASTDumper::Visit(FieldDecl& n) {
  PrintNode("FieldDecl", n);
  if (!n.name.empty()) {
    os_ << " " << n.name;
  }
  PrintType(n.type);
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Type.get(), true);
}

// =============================================================================
// Stmt Visit implementations
// =============================================================================

void ASTDumper::Visit(CompoundStmt& n) {
  PrintNode("CompoundStmt", n);
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = n.Stmts.size() + n.TailExprs.size();
  size_t child_idx = 0;
  for (size_t i = 0; i < n.Stmts.size(); ++i) {
    VisitChild(n.Stmts[i].get(), ++child_idx == total_children);
  }
  for (size_t i = 0; i < n.TailExprs.size(); ++i) {
    VisitChild(n.TailExprs[i].get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(ExprStmt& n) {
  PrintNode("ExprStmt", n);
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Expr.get(), true);
}

void ASTDumper::Visit(DeclStmt& n) {
  PrintNode("DeclStmt", n);
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Decl.get(), true);
}

void ASTDumper::Visit(IfStmt& n) {
  PrintNode("IfStmt", n);
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = (n.Cond ? 1 : 0) + (n.Then ? 1 : 0) + (n.Else ? 1 : 0);
  size_t child_idx = 0;
  if (n.Cond) {
    VisitChild(n.Cond.get(), ++child_idx == total_children);
  }
  if (n.Then) {
    VisitChild(n.Then.get(), ++child_idx == total_children);
  }
  if (n.Else) {
    VisitChild(n.Else.get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(WhileStmt& n) {
  PrintNode("WhileStmt", n);
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = (n.Cond ? 1 : 0) + (n.Body ? 1 : 0);
  size_t child_idx = 0;
  if (n.Cond) {
    VisitChild(n.Cond.get(), ++child_idx == total_children);
  }
  if (n.Body) {
    VisitChild(n.Body.get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(BreakStmt& n) {
  PrintNode("BreakStmt", n);
  PrintErrorMark(n);
  os_ << "\n";
}

void ASTDumper::Visit(ContinueStmt& n) {
  PrintNode("ContinueStmt", n);
  PrintErrorMark(n);
  os_ << "\n";
}

void ASTDumper::Visit(ReturnStmt& n) {
  PrintNode("ReturnStmt", n);
  PrintErrorMark(n);
  os_ << "\n";
  if (n.Expr) {
    VisitChild(n.Expr.get(), true);
  }
}

// =============================================================================
// Expr Visit implementations
// =============================================================================

void ASTDumper::Visit(IntegerLiteral& n) {
  PrintNode("IntegerLiteral", n);
  PrintExprType(n);
  os_ << " " << n.value;
  PrintErrorMark(n);
  os_ << "\n";
}

void ASTDumper::Visit(CharacterLiteral& n) {
  PrintNode("CharacterLiteral", n);
  PrintExprType(n);
  os_ << " " << static_cast<uint64_t>(n.value);
  PrintErrorMark(n);
  os_ << "\n";
}

void ASTDumper::Visit(FloatLiteral& n) {
  PrintNode("FloatLiteral", n);
  PrintExprType(n);
  os_ << " ";
  std::visit([this](auto&& v) { os_ << v; }, n.value);
  PrintErrorMark(n);
  os_ << "\n";
}

void ASTDumper::Visit(NullLiteral& n) {
  PrintNode("NullLiteral", n);
  PrintExprType(n);
  PrintErrorMark(n);
  os_ << "\n";
}

void ASTDumper::Visit(BoolLiteral& n) {
  PrintNode("BoolLiteral", n);
  PrintExprType(n);
  os_ << " " << (n.value ? "true" : "false");
  PrintErrorMark(n);
  os_ << "\n";
}

void ASTDumper::Visit(StringLiteral& n) {
  PrintNode("StringLiteral", n);
  PrintExprType(n);
  os_ << " \"";
  PrintEscapedString(n.value);
  os_ << "\"";
  PrintErrorMark(n);
  os_ << "\n";
}

void ASTDumper::Visit(DeclRefExpr& n) {
  PrintNode("DeclRefExpr", n);
  PrintExprType(n);
  if (n.declaration) {
    PrintDeclReference(*n.declaration);
  } else {
    os_ << " '";
    if (IsOperatorFunctionName(n.name)) {
      os_ << "operator " << n.name;
    } else {
      os_ << n.name;
    }
    os_ << "'";
  }
  PrintErrorMark(n);
  os_ << "\n";
}

void ASTDumper::Visit(ThisExpr& n) {
  PrintNode("ThisExpr", n);
  PrintExprType(n);
  os_ << " this";
  PrintErrorMark(n);
  os_ << "\n";
}

void ASTDumper::Visit(ParenExpr& n) {
  PrintNode("ParenExpr", n);
  PrintExprType(n);
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.SubExpr.get(), true);
}

void ASTDumper::Visit(UnaryOperator& n) {
  PrintNode("UnaryOperator", n);
  PrintExprType(n);
  os_ << " '" << expr::to_string(n.op) << "'";
  if (n.is_postfix) {
    os_ << " postfix";
  }
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Operand.get(), true);
}

void ASTDumper::Visit(BinaryOperator& n) {
  PrintNode("BinaryOperator", n);
  PrintExprType(n);
  os_ << " '" << expr::to_string(n.op) << "'";
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.LHS.get(), false);
  VisitChild(n.RHS.get(), true);
}

void ASTDumper::Visit(InitializationExpr& n) {
  PrintNode("InitializationExpr", n);
  PrintExprType(n);
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Target.get(), false);
  VisitChild(n.Source.get(), true);
}

void ASTDumper::Visit(ImplicitResultInitializationExpr& n) {
  PrintNode("ImplicitResultInitializationExpr", n);
  PrintExprType(n);
  if (n.Target) {
    PrintDeclReference(*n.Target);
  }
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Source.get(), true);
}

void ASTDumper::Visit(ConditionalOperator& n) {
  PrintNode("ConditionalOperator", n);
  PrintExprType(n);
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Cond.get(), false);
  VisitChild(n.Then.get(), false);
  VisitChild(n.Else.get(), true);
}

void ASTDumper::Visit(MemberExpr& n) {
  PrintNode("MemberExpr", n);
  PrintExprType(n);
  os_ << " " << expr::to_string(n.op) << n.member;
  if (n.declaration) {
    PrintDeclReference(*n.declaration);
  }
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Base.get(), true);
}

void ASTDumper::Visit(BaseSubobjectExpr& n) {
  PrintNode("BaseSubobjectExpr", n);
  PrintExprType(n);
  os_ << " " << expr::to_string(n.op);
  if (const StructDecl* declaration = n.GetDeclaration()) {
    os_ << declaration->name;
    if (n.base_path.size() == 1) {
      PrintStructReference(*declaration);
    } else {
      os_ << " path";
      for (const StructDecl* path_declaration : n.base_path) {
        if (path_declaration) {
          PrintStructReference(*path_declaration);
        }
      }
    }
  }
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Base.get(), true);
}

void ASTDumper::Visit(SubscriptExpr& n) {
  PrintNode("SubscriptExpr", n);
  PrintExprType(n);
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Base.get(), false);
  VisitChild(n.Index.get(), true);
}

void ASTDumper::Visit(ArrayValueExpr& n) {
  PrintNode("ArrayValueExpr", n);
  PrintExprType(n);
  PrintErrorMark(n);
  os_ << "\n";

  const std::size_t total_children = (n.Type ? 1 : 0) + n.Elements.size();
  std::size_t child_index = 0;
  if (n.Type) {
    VisitChild(n.Type.get(), ++child_index == total_children);
  }
  for (const auto& element : n.Elements) {
    VisitChild(element.get(), ++child_index == total_children);
  }
}

void ASTDumper::Visit(CallExpr& n) {
  PrintNode("CallExpr", n);
  PrintExprType(n);
  if (n.is_nonvirtual) {
    os_ << " nonvirtual";
  }
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = (n.Callee ? 1 : 0) + n.Args.size();
  size_t child_idx = 0;
  if (n.Callee) {
    VisitChild(n.Callee.get(), ++child_idx == total_children);
  }
  for (size_t i = 0; i < n.Args.size(); ++i) {
    VisitChild(n.Args[i].get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(OperatorCallExpr& n) {
  PrintNode("OperatorCallExpr", n);
  PrintExprType(n);
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = (n.Callee ? 1 : 0) + n.Args.size();
  size_t child_idx = 0;
  if (n.Callee) {
    VisitChild(n.Callee.get(), ++child_idx == total_children);
  }
  for (const auto& argument : n.Args) {
    VisitChild(argument.get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(ConstructionExpr& n) {
  PrintNode("ConstructionExpr", n);
  PrintExprType(n);
  os_ << " " << to_string(n.construction_kind);
  if (!n.target_name.empty()) {
    os_ << " target ";
    PrintSourceRange(n.target_name_range);
    os_ << " '" << n.target_name << "'";
  }
  if (n.constructor) {
    PrintDeclReference(*n.constructor);
  }
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = (n.TargetAddress ? 1 : 0) + n.Args.size();
  size_t child_idx = 0;
  if (n.TargetAddress) {
    VisitChild(n.TargetAddress.get(), ++child_idx == total_children);
  }
  for (const auto& argument : n.Args) {
    VisitChild(argument.get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(ArrayConstructionExpr& n) {
  PrintNode("ArrayConstructionExpr", n);
  PrintExprType(n);
  if (n.element_constructor) {
    PrintDeclReference(*n.element_constructor);
  }
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.Source.get(), true);
}

void ASTDumper::Visit(ArrayAssignmentExpr& n) {
  PrintNode("ArrayAssignmentExpr", n);
  PrintExprType(n);
  if (n.element_assignment) {
    PrintDeclReference(*n.element_assignment);
  }
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.LHS.get(), false);
  VisitChild(n.RHS.get(), true);
}

void ASTDumper::Visit(DestructorCallExpr& n) {
  PrintNode("DestructorCallExpr", n);
  PrintExprType(n);
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = (n.TargetAddress ? 1 : 0) + (n.Callee ? 1 : 0) + n.Args.size();
  size_t child_idx = 0;
  if (n.TargetAddress) {
    VisitChild(n.TargetAddress.get(), ++child_idx == total_children);
  }
  if (n.Callee) {
    VisitChild(n.Callee.get(), ++child_idx == total_children);
  }
  for (const auto& argument : n.Args) {
    VisitChild(argument.get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(ReceiverCallExpr& n) {
  PrintNode("ReceiverCallExpr", n);
  PrintExprType(n);
  os_ << " " << expr::to_string(n.op);
  if (n.is_nonvirtual) {
    os_ << " nonvirtual";
  }
  PrintErrorMark(n);
  os_ << "\n";

  size_t total_children = (n.Receiver ? 1 : 0) + (n.Callee ? 1 : 0) + n.Args.size();
  size_t child_idx = 0;
  if (n.Receiver) {
    VisitChild(n.Receiver.get(), ++child_idx == total_children);
  }
  if (n.Callee) {
    VisitChild(n.Callee.get(), ++child_idx == total_children);
  }
  for (const auto& argument : n.Args) {
    VisitChild(argument.get(), ++child_idx == total_children);
  }
}

void ASTDumper::Visit(ImplicitOverloadSetSelectionExpr& n) {
  PrintNode("ImplicitOverloadSetSelectionExpr", n);
  PrintExprType(n);
  if (n.selected_declaration) {
    PrintDeclReference(*n.selected_declaration);
  }
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.SubExpr.get(), true);
}

void ASTDumper::Visit(ImplicitCastExpr& n) {
  PrintNode("ImplicitCastExpr", n);
  PrintExprType(n);
  os_ << " <" << to_string(n.conversion_kind) << ">";
  if (n.conversion_kind == ImplicitConversionKind::DerivedToBase) {
    os_ << " path";
    for (const StructDecl* declaration : n.base_path) {
      if (declaration) {
        PrintStructReference(*declaration);
      }
    }
  }
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.SubExpr.get(), true);
}

void ASTDumper::Visit(MaterializeTemporaryExpr& n) {
  PrintNode("MaterializeTemporaryExpr", n);
  PrintExprType(n);
  PrintErrorMark(n);
  os_ << "\n";
  VisitChild(n.SubExpr.get(), true);
}

void ASTDumper::Visit(RecoveryExpr& n) {
  PrintNode("RecoveryExpr", n);
  PrintExprType(n);
  PrintErrorMark(n);
  os_ << "\n";
}

}  // namespace cw
