/// \file Interface.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "Interface.h"

#include <algorithm>
#include <cstddef>
#include <memory>
#include <vector>

#include <llvm/Support/ErrorHandling.h>
#include <llvm/Support/raw_ostream.h>

#include "ast.h"

namespace cw {
namespace {

void WriteType(QualType type, llvm::raw_ostream& output) {
  if (type.IsConstQualified()) output << "const ";
  switch (type.GetTypePtr()->GetKind()) {
    case TypeKind::Builtin:
      output << to_string(type.GetTypePtr()->AsBuiltinType()->GetBuiltinTypeKind());
      return;
    case TypeKind::Struct:
      output << "::" << type.GetTypePtr()->AsStructType()->GetDeclaration()->QualifiedName();
      return;
    case TypeKind::Array: {
      const auto& array = *type.GetTypePtr()->AsArrayType();
      output << '[' << array.GetLength() << "] ";
      WriteType(array.GetElementType(), output);
      return;
    }
    case TypeKind::Pointer:
      output << '*';
      WriteType(type.GetTypePtr()->AsPointerType()->GetPointee(), output);
      return;
    case TypeKind::VirtualSlot:
      output << "virtual ";
      WriteType(QualType(type.GetTypePtr()->AsVirtualSlotType()->GetEntryPointerType()), output);
      return;
    case TypeKind::Function: {
      const auto& function = *type.GetTypePtr()->AsFunctionType();
      output << "func(";
      const auto& parameters = function.GetParameterTypes();
      for (std::size_t index = 0; index < parameters.size(); ++index) {
        if (index) output << ", ";
        WriteType(QualType(parameters[index]), output);
      }
      output << ") ";
      WriteType(QualType(function.GetReturnType()), output);
      return;
    }
    case TypeKind::Reference: {
      const auto& reference = *type.GetTypePtr()->AsReferenceType();
      switch (reference.GetMode()) {
        case ReferenceMode::Mut:
          output << "&mut ";
          break;
        case ReferenceMode::Copy:
          output << "&copy ";
          break;
        case ReferenceMode::Move:
          output << "&move ";
          break;
      }
      WriteType(QualType(reference.GetReferentType()), output);
      return;
    }
    case TypeKind::ComptimeInt:
    case TypeKind::Null:
    case TypeKind::FunctionOverloadSet:
    case TypeKind::AddressOfFunctionOverloadSet:
      llvm_unreachable("internal expression types cannot appear in an exported declaration");
  }
  llvm_unreachable("unknown interface type");
}

void WriteFunction(const FunctionDecl& function, llvm::raw_ostream& output) {
  switch (function.GetKind()) {
    case NodeKind::ConstructorDecl:
      output << "ctor ";
      break;
    case NodeKind::DestructorDecl:
      output << "dtor ";
      break;
    default:
      output << "func ";
      if (IsOperatorFunctionName(function.name)) output << "operator ";
      break;
  }
  output << function.name << '(';
  for (std::size_t index = 0; index < function.ParmVars.size(); ++index) {
    if (index) output << ", ";
    const auto& parameter = *function.ParmVars[index];
    output << parameter.name << ' ';
    WriteType(parameter.type, output);
  }
  output << ')';
  if (function.ReturnVar && !function.ReturnVar->type.GetTypePtr()->IsVoid()) {
    output << ' ';
    WriteType(function.ReturnVar->type, output);
  }
  output << ";\n";
}

void WriteStruct(const StructDecl& structure, unsigned indent, llvm::raw_ostream& output) {
  if (structure.is_declared_trivial) output << "trivial ";
  output << "struct " << structure.name;
  if (structure.base_type) {
    output << " : ";
    WriteType(QualType(structure.base_type), output);
  }
  output << " {\n";
  if (structure.VirtualDecl) {
    output.indent(indent + 2) << "virtual {\n";
    for (const auto& function : structure.VirtualDecl->Functions) {
      output.indent(indent + 4);
      if (function->is_override) output << "override ";
      if (function->is_abstract) output << "abstract ";
      WriteFunction(*function, output);
    }
    output.indent(indent + 2) << "}\n";
  }
  for (const auto& field : structure.Fields) {
    output.indent(indent + 2) << field->name << ' ';
    WriteType(field->type, output);
    output << ";\n";
  }
  output.indent(indent) << "}\n";
}

bool HasExports(const Decl& declaration) {
  if (declaration.GetKind() == NodeKind::NamespaceDecl) {
    const auto& members = static_cast<const NamespaceDecl&>(declaration).Decls;
    return std::any_of(members.begin(), members.end(), [](const auto& member) { return HasExports(*member); });
  }
  return declaration.modifier == DeclModifier::Export;
}

void WriteDeclarations(const std::vector<std::unique_ptr<Decl>>& declarations, unsigned indent,
                       llvm::raw_ostream& output) {
  for (const auto& declaration : declarations) {
    if (!HasExports(*declaration)) continue;
    output.indent(indent);
    if (declaration->GetKind() == NodeKind::NamespaceDecl) {
      const auto& space = static_cast<const NamespaceDecl&>(*declaration);
      output << "namespace " << space.name << " {\n";
      WriteDeclarations(space.Decls, indent + 2, output);
      output.indent(indent) << "}\n";
      continue;
    }
    output << "import ";
    switch (declaration->GetKind()) {
      case NodeKind::StructDecl:
        WriteStruct(static_cast<const StructDecl&>(*declaration), indent, output);
        break;
      case NodeKind::FunctionDecl:
      case NodeKind::ConstructorDecl:
      case NodeKind::DestructorDecl:
        WriteFunction(static_cast<const FunctionDecl&>(*declaration), output);
        break;
      default:
        llvm_unreachable("Sema must reject unsupported exported declarations");
    }
  }
}

}  // namespace

void EmitInterface(const TranslationUnitDecl& translation_unit, llvm::raw_ostream& output) {
  WriteDeclarations(translation_unit.Decls, 0, output);
}

}  // namespace cw
