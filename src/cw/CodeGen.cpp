/// \file CodeGen.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "CodeGen.h"

#include <algorithm>
#include <cstdint>
#include <string>
#include <vector>

#include <boost/assert.hpp>

#include <llvm/ADT/APInt.h>
#include <llvm/IR/AttributeMask.h>
#include <llvm/IR/Attributes.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/GlobalVariable.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Verifier.h>
#include <llvm/MC/TargetRegistry.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/Target/TargetMachine.h>
#include <llvm/TargetParser/Triple.h>
#include <llvm/Transforms/Utils/ModuleUtils.h>

#include "ASTContext.h"
#include "CodeGenFunction.h"
#include "Diagnostic.h"

namespace cw {

namespace {

// ABI spelling is derived from canonical semantic types, never their LLVM representation.
void WriteSymbolType(QualType type, llvm::raw_ostream& output);

void WriteSymbolParameters(const FunctionType& type, llvm::raw_ostream& output) {
  output << '(';
  const auto& parameters = type.GetParameterTypes();
  for (std::size_t index = 0; index < parameters.size(); ++index) {
    if (index) output << ',';
    WriteSymbolType(QualType(parameters[index]), output);
  }
  output << ')';
}

void WriteSymbolType(QualType type, llvm::raw_ostream& output) {
  if (type.IsConstQualified()) output << "const ";
  const auto& semantic = *type.GetTypePtr();
  switch (semantic.GetKind()) {
    case TypeKind::Builtin:
      output << to_string(semantic.AsBuiltinType()->GetBuiltinTypeKind());
      return;
    case TypeKind::Struct:
      output << semantic.AsStructType()->GetDeclaration()->QualifiedName();
      return;
    case TypeKind::Array: {
      const auto& array = *semantic.AsArrayType();
      output << '[' << array.GetLength() << ']';
      WriteSymbolType(array.GetElementType(), output);
      return;
    }
    case TypeKind::Pointer:
      output << '*';
      WriteSymbolType(semantic.AsPointerType()->GetPointee(), output);
      return;
    case TypeKind::VirtualSlot:
      output << "virtual ";
      WriteSymbolType(QualType(semantic.AsVirtualSlotType()->GetEntryPointerType()), output);
      return;
    case TypeKind::Function: {
      const auto& function = *semantic.AsFunctionType();
      output << "func";
      WriteSymbolParameters(function, output);
      WriteSymbolType(QualType(function.GetReturnType()), output);
      return;
    }
    case TypeKind::Reference: {
      const auto& reference = *semantic.AsReferenceType();
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
      WriteSymbolType(QualType(reference.GetReferentType()), output);
      return;
    }
    case TypeKind::ComptimeInt:
    case TypeKind::Null:
    case TypeKind::FunctionOverloadSet:
    case TypeKind::AddressOfFunctionOverloadSet:
      llvm_unreachable("internal expression types cannot appear in an ABI name");
  }
  llvm_unreachable("unknown symbol type");
}

const StructType* GetStructorType(const FunctionDecl& declaration) {
  if (declaration.GetKind() == NodeKind::ConstructorDecl)
    return static_cast<const ConstructorDecl&>(declaration).target_type;
  if (declaration.GetKind() == NodeKind::DestructorDecl)
    return static_cast<const DestructorDecl&>(declaration).target_type;
  return nullptr;
}

// Call ABI emptiness also admits zero-length array fields, unlike StructDecl::IsEmpty().
bool IsEmptyRecord(const Type& type) {
  const auto* record = type.AsStructType();
  if (!record) {
    return false;
  }
  const auto& declaration = *record->GetDeclaration();
  if (declaration.base_type && !IsEmptyRecord(*declaration.base_type)) {
    return false;
  }
  return std::all_of(declaration.Fields.begin(), declaration.Fields.end(), [](const auto& field) {
    for (const auto* array = field->type.GetTypePtr()->AsArrayType(); array;
         array = array->GetElementType().GetTypePtr()->AsArrayType()) {
      if (array->GetLength() == 0) {
        return true;
      }
    }
    // Ordinary C++ record members occupy storage, even when their class is empty.
    return false;
  });
}

struct HomogeneousAggregate {
  const BuiltinType* base{};
  std::uint64_t count{};
};

std::optional<HomogeneousAggregate> GetHomogeneousAggregate(const Type& type, const ASTContext& context) {
  if (const auto* builtin = type.AsBuiltinType(); builtin && builtin->IsFloatingPoint()) {
    return HomogeneousAggregate{builtin, 1};
  }
  HomogeneousAggregate result;
  if (const auto* array = type.AsArrayType()) {
    if (array->GetLength() == 0) {
      return std::nullopt;
    }
    const auto element = GetHomogeneousAggregate(*array->GetElementType().GetTypePtr(), context);
    if (!element || array->GetLength() > 4 / element->count) {
      return std::nullopt;
    }
    result = {element->base, element->count * array->GetLength()};
  } else if (const auto* record = type.AsStructType()) {
    const auto& declaration = *record->GetDeclaration();
    const auto append = [&](const Type& element) {
      if (IsEmptyRecord(element)) {
        return true;
      }
      const auto part = GetHomogeneousAggregate(element, context);
      if (!part || result.count + part->count > 4 || (result.base && result.base != part->base)) {
        return false;
      }
      result.base = part->base;
      result.count += part->count;
      return true;
    };
    if (declaration.base_type && !append(*declaration.base_type)) {
      return std::nullopt;
    }
    for (const auto& field : declaration.Fields) {
      const Type* element = field->type.GetTypePtr();
      while (const auto* array = element->AsArrayType()) {
        if (array->GetLength() == 0) {
          return std::nullopt;
        }
        element = array->GetElementType().GetTypePtr();
      }
      if (!IsEmptyRecord(*element) && !append(*field->type.GetTypePtr())) {
        return std::nullopt;
      }
    }
  }
  if (!result.base || std::get<TypeLayout>(context.GetTypeLayout(type)).size !=
                          result.count * std::get<TypeLayout>(context.GetTypeLayout(*result.base)).size) {
    return std::nullopt;
  }
  return result;
}

bool ContainsOnlyPointers(const Type& type) {
  if (const auto* array = type.AsArrayType()) {
    const Type* element = array->GetElementType().GetTypePtr();
    while (const auto* nested = element->AsArrayType()) {
      element = nested->GetElementType().GetTypePtr();
    }
    return element->AsPointerType() || ContainsOnlyPointers(*element);
  }
  const auto* record = type.AsStructType();
  if (!record || IsEmptyRecord(type)) {
    return false;
  }
  const auto& declaration = *record->GetDeclaration();
  if (declaration.base_type && !ContainsOnlyPointers(*declaration.base_type)) {
    return false;
  }
  return std::all_of(declaration.Fields.begin(), declaration.Fields.end(), [](const auto& field) {
    const Type* element = field->type.GetTypePtr();
    while (const auto* array = element->AsArrayType()) {
      element = array->GetElementType().GetTypePtr();
    }
    return element->AsPointerType() || ContainsOnlyPointers(*element);
  });
}

const Type* GetSingleElementStruct(const Type& type, const ASTContext& context) {
  if (type.IsScalar()) {
    // Virtual slots are source-level scalars but ABI-level two-word aggregates.
    return type.AsVirtualSlotType() ? nullptr : &type;
  }
  const auto* record = type.AsStructType();
  if (!record || record->GetDeclaration()->IsPolymorphic()) {
    return nullptr;
  }
  const auto& declaration = *record->GetDeclaration();
  const Type* element = nullptr;
  if (declaration.base_type && !IsEmptyRecord(*declaration.base_type)) {
    element = GetSingleElementStruct(*declaration.base_type, context);
    if (!element) {
      return nullptr;
    }
  }
  for (const auto& field : declaration.Fields) {
    const Type* field_type = field->type.GetTypePtr();
    // Zero-length arrays are empty fields; singleton arrays expose their element.
    for (const auto* array = field_type->AsArrayType(); array;
         array = array->GetElementType().GetTypePtr()->AsArrayType()) {
      if (array->GetLength() == 0) {
        field_type = nullptr;
        break;
      }
    }
    if (!field_type) {
      continue;
    }
    if (element) {
      return nullptr;
    }
    while (const auto* array = field_type->AsArrayType()) {
      if (array->GetLength() != 1) {
        break;
      }
      field_type = array->GetElementType().GetTypePtr();
    }
    element = GetSingleElementStruct(*field_type, context);
    if (!element) {
      return nullptr;
    }
  }
  if (element && std::get<TypeLayout>(context.GetTypeLayout(*element)).size ==
                     std::get<TypeLayout>(context.GetTypeLayout(type)).size) {
    return element;
  }
  return nullptr;
}

}  // namespace

std::unique_ptr<llvm::TargetMachine> CodeGen::CreateTarget(const TargetInfo& target_info, DiagnosticEngine& diagnostics,
                                                           llvm::VersionTuple minimum_os_version) {
  auto triple = target_info.GetTriple();
  if (!minimum_os_version.empty() && triple.isOSDarwin()) {
    triple.setOSName("macosx" + minimum_os_version.getAsString());
  }
  static const bool kAllTargetsInitialized = [] {
    llvm::InitializeAllTargetInfos();
    llvm::InitializeAllTargets();
    llvm::InitializeAllTargetMCs();
    llvm::InitializeAllAsmPrinters();
    llvm::InitializeAllAsmParsers();
    return true;
  }();
  (void)kAllTargetsInitialized;
  std::string error;
  const auto* target = llvm::TargetRegistry::lookupTarget(triple, error);
  if (!target) {
    diagnostics.Add(kErrorDiagnostic, "failed to select LLVM target '" + triple.str() + "': " + error);
    return nullptr;
  }
  // Keep the existing Darwin baseline while allowing LLVM to choose the Wasm ABI defaults.
  const auto cpu = target_info.IsWasm32() ? "" : "generic";
  const std::optional<llvm::Reloc::Model> relocation =
      target_info.IsWasm32() ? std::nullopt : std::optional(llvm::Reloc::PIC_);
  std::unique_ptr<llvm::TargetMachine> machine(target->createTargetMachine(
      triple, cpu, "", llvm::TargetOptions(), relocation, std::nullopt, llvm::CodeGenOptLevel::None));
  if (!machine) {
    diagnostics.Add(kErrorDiagnostic, "failed to create LLVM target machine for '" + triple.str() + "'");
  }
  return machine;
}

CodeGen::CodeGen() = default;

CodeGen::~CodeGen() = default;

void CodeGen::SetDiagnosticEngine(DiagnosticEngine* diagnostic_engine) { diagnostic_engine_ = diagnostic_engine; }

void CodeGen::SetASTContext(const ASTContext* ast_context) { ast_context_ = ast_context; }

void CodeGen::SetLLVMContext(llvm::LLVMContext* llvm_context) { llvm_context_ = llvm_context; }

void CodeGen::SetTargetMachine(const llvm::TargetMachine* target_machine) { target_machine_ = target_machine; }

CodeGen::TargetABI CodeGen::GetTargetABI() const {
  if (ast_context_->GetTargetInfo().IsWasm32()) {
    return {TargetABI::Kind::WebAssembly, true, false, false};
  }
  return {TargetABI::Kind::DarwinAArch64, true, true, true};
}

llvm::IntegerType* CodeGen::GetPointerIndexType() const {
  return module_->getDataLayout().getIndexType(*llvm_context_, 0);
}

bool CodeGen::Unsupported(const Node& node, std::string_view feature) {
  diagnostic_engine_->Add(kErrorDiagnostic, node.range,
                          "code generation for " + std::string(feature) + " is not supported yet");
  return false;
}

bool CodeGen::InternalError(const Node& node, std::string_view message) {
  diagnostic_engine_->Add(kErrorDiagnostic, node.range, "internal code generation error: " + std::string(message));
  return false;
}

bool CodeGen::DiagnoseTypeConversionFailure(const Node& node, TypeConversionFailure failure, std::string_view feature) {
  switch (failure) {
    case TypeConversionFailure::UnsupportedType:
      return Unsupported(node, feature);
    case TypeConversionFailure::InvalidLayout:
      return InternalError(node, "semantic object has no valid target layout");
  }
  BOOST_ASSERT(false && "unknown type conversion failure");
  return false;
}

CodeGen::TypeConversionResult CodeGen::ConvertType(const Type& type) {
  if (const auto* builtin = type.AsBuiltinType()) {
    if (builtin->IsInteger()) {
      return llvm::IntegerType::get(*llvm_context_, ast_context_->GetIntegerBitWidth(*builtin));
    }
    if (builtin->IsFloatingPoint()) {
      return builtin->GetBuiltinTypeKind() == BuiltinTypeKind::F32 ? llvm::Type::getFloatTy(*llvm_context_)
                                                                   : llvm::Type::getDoubleTy(*llvm_context_);
    }
    if (builtin->GetBuiltinTypeKind() == BuiltinTypeKind::Bool) {
      return llvm::Type::getInt1Ty(*llvm_context_);
    }
    if (builtin->IsVoid()) {
      return llvm::Type::getVoidTy(*llvm_context_);
    }
  }
  if (type.AsVirtualSlotType()) {
    auto* word = GetPointerIndexType();
    return llvm::StructType::get(*llvm_context_, {word, word});
  }
  if (type.AsPointerType()) {
    return llvm::PointerType::getUnqual(*llvm_context_);
  }
  if (const auto* reference = type.AsReferenceType()) {
    const auto* referent = reference->GetReferentType();
    auto result = ConvertTypeForMem(*referent);
    if (const auto* failure = std::get_if<TypeConversionFailure>(&result)) {
      return *failure;
    }
    return llvm::PointerType::getUnqual(*llvm_context_);
  }
  return TypeConversionFailure::UnsupportedType;
}

TypeLayout CodeGen::GetTypeLayoutForMem(const Type& type) const {
  if (type.AsReferenceType()) {
    const auto& target = ast_context_->GetTargetInfo();
    return {target.GetPointerBitWidth() / 8, target.GetPointerAlignment()};
  }
  return std::get<TypeLayout>(ast_context_->GetTypeLayout(type));
}

CodeGen::TypeConversionResult CodeGen::ConvertTypeForMem(const Type& type) {
  if (type.IsObject() && std::holds_alternative<LayoutFailure>(ast_context_->GetTypeLayout(type))) {
    return TypeConversionFailure::InvalidLayout;
  }
  if (const auto* builtin = type.AsBuiltinType(); builtin && builtin->GetBuiltinTypeKind() == BuiltinTypeKind::Bool) {
    return llvm::Type::getInt8Ty(*llvm_context_);
  }
  if (const auto* array = type.AsArrayType()) {
    auto result = ConvertTypeForMem(*array->GetElementType().GetTypePtr());
    if (const auto* failure = std::get_if<TypeConversionFailure>(&result)) {
      return *failure;
    }
    return llvm::ArrayType::get(std::get<llvm::Type*>(result), array->GetLength());
  }
  if (const auto* structure = type.AsStructType()) {
    return ConvertStructType(*structure->GetDeclaration());
  }
  return ConvertType(type);
}

CodeGen::TypeConversionResult CodeGen::ConvertStructType(const StructDecl& declaration) {
  if (const auto it = struct_representations_.find(&declaration); it != struct_representations_.end()) {
    return it->second.type;
  }
  const auto shared_result = ast_context_->GetStructLayout(declaration);
  if (std::holds_alternative<LayoutFailure>(shared_result)) {
    return TypeConversionFailure::InvalidLayout;
  }
  const auto& shared = *std::get<const StructLayout*>(shared_result);
  struct Element {
    llvm::Type* type;
    std::uint64_t offset;
    const FieldDecl* field;
    bool is_base{};
  };
  std::vector<Element> members;
  if (declaration.IsPolymorphic() &&
      (!declaration.base_type || !declaration.base_type->GetDeclaration()->IsPolymorphic())) {
    members.push_back({llvm::PointerType::getUnqual(*llvm_context_), 0, nullptr});
  }
  if (declaration.base_type) {
    const auto& base = *declaration.base_type->GetDeclaration();
    const auto conversion = ConvertStructType(base);
    if (const auto* failure = std::get_if<TypeConversionFailure>(&conversion)) {
      return *failure;
    }
    if (!base.IsEmpty()) {
      members.push_back({struct_representations_.at(&base).base_type, *shared.base_offset, nullptr, true});
    }
  }
  for (std::size_t index = 0; index < declaration.Fields.size(); ++index) {
    const auto& field = *declaration.Fields[index];
    const auto conversion = ConvertTypeForMem(*field.type.GetTypePtr());
    if (const auto* failure = std::get_if<TypeConversionFailure>(&conversion)) {
      return *failure;
    }
    members.push_back({std::get<llvm::Type*>(conversion), shared.field_offsets[index], &field});
  }

  StructRepresentation result;
  const auto& data_layout = module_->getDataLayout();
  const auto padding_type = [&](std::uint64_t size) -> llvm::Type* {
    if (size == 1) {
      return llvm::Type::getInt8Ty(*llvm_context_);
    }
    return llvm::ArrayType::get(llvm::Type::getInt8Ty(*llvm_context_), size);
  };
  // Storage types reproduce the shared offsets. LLVM's natural representation is
  // retained when it fits; explicit padding and packing only bridge differences.
  const auto build = [&](std::uint64_t size, llvm::StringRef suffix, bool save_indices) {
    for (bool packed : {false, true}) {
      std::vector<llvm::Type*> elements;
      std::uint64_t cursor = 0;
      std::uint64_t alignment = 1;
      bool fits = true;
      for (const auto& member : members) {
        const auto member_alignment = packed ? 1 : data_layout.getABITypeAlign(member.type).value();
        const auto natural_offset = llvm::alignTo(cursor, member_alignment);
        if (natural_offset > member.offset) {
          fits = false;
          break;
        }
        if (natural_offset < member.offset) {
          elements.push_back(padding_type(member.offset - cursor));
        }
        if (save_indices) {
          if (member.field) {
            result.field_indices[member.field] = static_cast<unsigned>(elements.size());
          } else if (member.is_base) {
            result.base_index = static_cast<unsigned>(elements.size());
          }
        }
        elements.push_back(member.type);
        cursor = member.offset + data_layout.getTypeAllocSize(member.type).getFixedValue();
        alignment = std::max(alignment, member_alignment);
      }
      if (!fits || cursor > size || size % alignment != 0) {
        continue;
      }
      if (llvm::alignTo(cursor, alignment) < size) {
        elements.push_back(padding_type(size - cursor));
      }
      auto* type = llvm::StructType::create(*llvm_context_, elements,
                                            "struct." + declaration.QualifiedName() + suffix.str(), packed);
      BOOST_ASSERT(data_layout.getTypeAllocSize(type).getFixedValue() == size);
      if (save_indices) {
        for (const auto& member : members) {
          const auto index = member.field     ? result.field_indices.at(member.field)
                             : member.is_base ? *result.base_index
                                              : 0;
          BOOST_ASSERT(data_layout.getStructLayout(type)->getElementOffset(index) == member.offset);
        }
      }
      return type;
    }
    BOOST_ASSERT(false && "shared record layout cannot be represented");
    return static_cast<llvm::StructType*>(nullptr);
  };
  result.type = build(shared.complete.size, "", true);
  result.base_type = declaration.IsEmpty() || shared.complete.size == shared.non_virtual_size
                         ? result.type
                         : build(shared.non_virtual_size, ".base", false);
  struct_representations_.emplace(&declaration, std::move(result));
  return struct_representations_.at(&declaration).type;
}

CodeGen::ABIArgInfoResult CodeGen::ClassifyTypeForABI(const Type& type, bool is_return) {
  auto conversion = ConvertTypeForMem(type);
  if (const auto* failure = std::get_if<TypeConversionFailure>(&conversion)) {
    return *failure;
  }
  auto* memory_type = std::get<llvm::Type*>(conversion);
  if (type.IsVoid()) {
    if (!is_return) {
      return TypeConversionFailure::UnsupportedType;
    }
    return ABIArgInfo{ABIArgInfo::Kind::Ignore, memory_type};
  }
  if (!type.AsArrayType() && !type.AsStructType() && !type.AsVirtualSlotType()) {
    ABIArgInfo result{ABIArgInfo::Kind::Direct, memory_type, std::get<llvm::Type*>(ConvertType(type))};
    // Both supported ABIs extend narrow scalar values at the function boundary.
    if (const auto* builtin = type.AsBuiltinType()) {
      if (builtin->GetBuiltinTypeKind() == BuiltinTypeKind::Bool) {
        result.extension = llvm::Attribute::ZExt;
      } else if (builtin->IsInteger() && ast_context_->GetIntegerBitWidth(*builtin) < 32) {
        result.extension = builtin->IsSignedInteger() ? llvm::Attribute::SExt : llvm::Attribute::ZExt;
      }
    }
    return result;
  }

  return GetTargetABI().kind == TargetABI::Kind::WebAssembly ? ClassifyWasmAggregate(type, memory_type, is_return)
                                                             : ClassifyDarwinAggregate(type, memory_type, is_return);
}

CodeGen::ABIArgInfo CodeGen::ClassifyWasmAggregate(const Type& type, llvm::Type* memory_type, bool is_return) {
  const auto layout = GetTypeLayoutForMem(type);
  const bool trivial = type.GetTriviality() == TypeTriviality::Trivial;
  if (trivial) {
    if (layout.size == 0 || IsEmptyRecord(type)) {
      return ABIArgInfo{ABIArgInfo::Kind::Ignore, memory_type};
    }
    if (const auto* element = GetSingleElementStruct(type, *ast_context_)) {
      return ABIArgInfo{ABIArgInfo::Kind::Direct, memory_type, std::get<llvm::Type*>(ConvertType(*element))};
    }
  }
  ABIArgInfo result{ABIArgInfo::Kind::Indirect, memory_type};
  result.by_value = trivial && !is_return;
  result.indirect_alignment = layout.alignment;
  return result;
}

CodeGen::ABIArgInfo CodeGen::ClassifyDarwinAggregate(const Type& type, llvm::Type* memory_type, bool is_return) {
  // Nontrivial objects retain their identity across the call, including zero-sized objects.
  if (type.GetTriviality() == TypeTriviality::NonTrivial) {
    return ABIArgInfo{ABIArgInfo::Kind::Indirect, memory_type};
  }

  const auto object_layout = GetTypeLayoutForMem(type);
  const auto size = object_layout.size;
  if (size == 0 || IsEmptyRecord(type)) {
    return ABIArgInfo{ABIArgInfo::Kind::Ignore, memory_type};
  }
  // Darwin AArch64 gives HFAs their own convention, even when they exceed sixteen bytes.
  if (auto homogeneous = GetHomogeneousAggregate(type, *ast_context_)) {
    auto* direct_type =
        is_return ? memory_type
                  : llvm::ArrayType::get(std::get<llvm::Type*>(ConvertType(*homogeneous->base)), homogeneous->count);
    return ABIArgInfo{ABIArgInfo::Kind::Direct, memory_type, direct_type};
  }
  if (size > 16) {
    return ABIArgInfo{ABIArgInfo::Kind::Indirect, memory_type};
  }
  llvm::Type* direct_type = nullptr;
  if (is_return && size <= 8) {
    direct_type = llvm::IntegerType::get(*llvm_context_, size * 8);
  } else {
    const auto alignment = std::max<std::uint64_t>(8, object_layout.alignment);
    llvm::Type* unit = llvm::IntegerType::get(*llvm_context_, alignment * 8);
    if (!is_return && ContainsOnlyPointers(type)) {
      unit = llvm::PointerType::getUnqual(*llvm_context_);
    }
    const auto count = llvm::divideCeil(size, alignment);
    direct_type = count == 1 ? unit : llvm::ArrayType::get(unit, count);
  }
  return ABIArgInfo{ABIArgInfo::Kind::Direct, memory_type, direct_type};
}

CodeGen::FunctionInfoResult CodeGen::GetFunctionInfo(const FunctionType& type, const StructType* this_type) {
  // A structor's semantic void signature omits its target and the ABI-level this return.
  auto& cache = this_type ? structor_infos_[this_type] : function_infos_;
  if (const auto it = cache.find(&type); it != cache.end()) {
    return &it->second;
  }
  auto result = ClassifyTypeForABI(*type.GetReturnType(), /*is_return=*/true);
  if (const auto* failure = std::get_if<TypeConversionFailure>(&result)) {
    return *failure;
  }
  FunctionInfo info;
  info.result = std::get<ABIArgInfo>(result);
  std::vector<llvm::Type*> parameters;
  auto* pointer_type = llvm::PointerType::getUnqual(*llvm_context_);
  if (this_type) {
    auto conversion = ConvertTypeForMem(*this_type);
    if (const auto* failure = std::get_if<TypeConversionFailure>(&conversion)) {
      return *failure;
    }
    info.this_type = std::get<llvm::Type*>(conversion);
    info.this_index = parameters.size();
    parameters.push_back(pointer_type);
  }
  if (info.result.kind == ABIArgInfo::Kind::Indirect) {
    info.result_index = parameters.size();
    parameters.push_back(pointer_type);
  }
  for (const auto* parameter : type.GetParameterTypes()) {
    auto conversion = ClassifyTypeForABI(*parameter, /*is_return=*/false);
    if (const auto* failure = std::get_if<TypeConversionFailure>(&conversion)) {
      return *failure;
    }
    ParameterInfo parameter_info{std::get<ABIArgInfo>(conversion), std::nullopt};
    if (parameter_info.abi.kind != ABIArgInfo::Kind::Ignore) {
      parameter_info.llvm_index = parameters.size();
      parameters.push_back(parameter_info.abi.kind == ABIArgInfo::Kind::Indirect ? pointer_type
                                                                                 : parameter_info.abi.direct_type);
    }
    info.parameters.push_back(parameter_info);
  }
  auto* return_type =
      info.result.kind == ABIArgInfo::Kind::Direct ? info.result.direct_type : llvm::Type::getVoidTy(*llvm_context_);
  info.returns_this = this_type && GetTargetABI().structors_return_this;
  if (info.returns_this) {
    return_type = pointer_type;
  }
  info.type = llvm::FunctionType::get(return_type, parameters, false);
  info.attributes = GetFunctionAttributes(type, info);
  return &cache.emplace(&type, std::move(info)).first->second;
}

CodeGen::FunctionInfoResult CodeGen::GetFunctionInfo(const FunctionDecl& declaration, StructorKind kind) {
  auto& entry = functions_[&declaration][static_cast<std::size_t>(kind)];
  if (entry.info) return entry.info;
  // Both currently supported targets give complete/base entries the same machine contract.
  // Keep the entry lookup distinct, while sharing the type-level ABI classification.
  auto result = GetFunctionInfo(*declaration.type.GetTypePtr()->AsFunctionType(), GetStructorType(declaration));
  if (const auto* info = std::get_if<const FunctionInfo*>(&result)) entry.info = *info;
  return result;
}

llvm::AttributeList CodeGen::GetFunctionAttributes(const FunctionType& type, const FunctionInfo& info) const {
  const auto get_reference_attributes = [&](const ReferenceType& reference) {
    const auto& referent = *reference.GetReferentType();
    const auto layout = GetTypeLayoutForMem(referent);
    auto size = layout.size;
    // A record reference may designate a base subobject. Arrays retain their complete extent.
    if (const auto* record = referent.AsStructType()) {
      const auto& declaration = *record->GetDeclaration();
      const auto& record_layout = *std::get<const StructLayout*>(ast_context_->GetStructLayout(declaration));
      size = declaration.IsEmpty() ? 1 : record_layout.non_virtual_size;
    }
    llvm::AttrBuilder attributes(*llvm_context_);
    attributes.addAttribute(llvm::Attribute::NonNull);
    attributes.addAlignmentAttr(llvm::Align(layout.alignment));
    // CW admits genuinely zero-sized objects, unlike the ordinary empty-class case above.
    if (size != 0) {
      attributes.addDereferenceableAttr(size);
    }
    return attributes;
  };
  const auto can_add_noundef = [&](const Type& semantic, const ABIArgInfo& abi) {
    if (abi.kind == ABIArgInfo::Kind::Ignore) {
      return false;
    }
    if (abi.kind == ABIArgInfo::Kind::Indirect) {
      return true;  // The argument is the object's address, not its stored representation.
    }
    const Type* element = &semantic;
    llvm::Type* memory_element = abi.memory_type;
    while (const auto* array = element->AsArrayType()) {
      element = array->GetElementType().GetTypePtr();
      memory_element = llvm::cast<llvm::ArrayType>(memory_element)->getElementType();
    }
    // Keep direct records conservative. Arrays require fully defined element storage,
    // and ABI widening must not introduce additional undefined value bits.
    if (!element->IsScalar() && !element->AsReferenceType()) {
      return false;
    }
    const auto& layout = module_->getDataLayout();
    return layout.getTypeSizeInBits(memory_element) == layout.getTypeAllocSizeInBits(memory_element) &&
           layout.getTypeSizeInBits(abi.direct_type) <= layout.getTypeSizeInBits(abi.memory_type);
  };
  llvm::AttributeList attributes;
  if (info.this_index) {
    attributes = attributes.addParamAttribute(*llvm_context_, *info.this_index, llvm::Attribute::NoUndef);
  }
  if (info.returns_this) {
    attributes = attributes.addParamAttribute(*llvm_context_, *info.this_index, llvm::Attribute::Returned);
    attributes = attributes.addRetAttribute(*llvm_context_, llvm::Attribute::NoUndef);
  } else if (info.result.kind == ABIArgInfo::Kind::Direct && can_add_noundef(*type.GetReturnType(), info.result)) {
    attributes = attributes.addRetAttribute(*llvm_context_, llvm::Attribute::NoUndef);
  }
  if (const auto* reference = type.GetReturnType()->AsReferenceType()) {
    attributes = attributes.addRetAttributes(*llvm_context_, get_reference_attributes(*reference));
  }
  if (info.result_index) {
    attributes =
        attributes.addParamAttribute(*llvm_context_, *info.result_index,
                                     llvm::Attribute::getWithStructRetType(*llvm_context_, info.result.memory_type));
    attributes = attributes.addParamAttribute(
        *llvm_context_, *info.result_index,
        llvm::Attribute::getWithAlignment(*llvm_context_,
                                          llvm::Align(GetTypeLayoutForMem(*type.GetReturnType()).alignment)));
  }
  if (info.result.extension != llvm::Attribute::None) {
    attributes = attributes.addRetAttribute(*llvm_context_, info.result.extension);
  }
  const auto& parameters = type.GetParameterTypes();
  for (std::size_t index = 0; index < parameters.size(); ++index) {
    const auto& parameter = info.parameters[index];
    if (!parameter.llvm_index) {
      continue;
    }
    if (can_add_noundef(*parameters[index], parameter.abi)) {
      attributes = attributes.addParamAttribute(*llvm_context_, *parameter.llvm_index, llvm::Attribute::NoUndef);
    }
    if (const auto* reference = parameters[index]->AsReferenceType()) {
      attributes =
          attributes.addParamAttributes(*llvm_context_, *parameter.llvm_index, get_reference_attributes(*reference));
    }
    if (parameter.abi.extension != llvm::Attribute::None) {
      attributes = attributes.addParamAttribute(*llvm_context_, *parameter.llvm_index, parameter.abi.extension);
    }
    if (parameter.abi.by_value) {
      attributes =
          attributes.addParamAttribute(*llvm_context_, *parameter.llvm_index,
                                       llvm::Attribute::getWithByValType(*llvm_context_, parameter.abi.memory_type));
    }
    if (parameter.abi.indirect_alignment) {
      attributes = attributes.addParamAttribute(
          *llvm_context_, *parameter.llvm_index,
          llvm::Attribute::getWithAlignment(*llvm_context_, llvm::Align(parameter.abi.indirect_alignment)));
    }
  }
  return attributes;
}

llvm::GlobalVariable* CodeGen::GetAddrOfStringLiteral(const StringLiteral& literal) {
  // LLVM uniques array constants by type and every content byte, including embedded zeros.
  auto* initializer = llvm::ConstantDataArray::getString(*llvm_context_, literal.value, /*AddNull=*/false);
  const auto it = string_literals_.find(initializer);
  if (it != string_literals_.end()) {
    return it->second;
  }
  auto* global = new llvm::GlobalVariable(*module_, initializer->getType(), true, llvm::GlobalValue::PrivateLinkage,
                                          initializer, "cw:str");
  global->setAlignment(module_->getDataLayout().getABITypeAlign(initializer->getType()));
  string_literals_.emplace(initializer, global);
  return global;
}

llvm::Function* CodeGen::GetVTableEntry(const VTableEntry& entry) {
  if (entry.final_overrider->is_abstract) {
    BOOST_ASSERT(pure_virtual_);
    return pure_virtual_;
  }
  const auto* implementation_declaration = entry.final_overrider->implementation;
  if (!implementation_declaration) implementation_declaration = entry.final_overrider;
  auto* implementation = GetOrCreateFunction(*implementation_declaration);
  if (!implementation) return nullptr;
  auto result = GetFunctionInfo(*entry.interface);
  if (const auto* failure = std::get_if<TypeConversionFailure>(&result)) {
    DiagnoseTypeConversionFailure(*entry.interface, *failure, "this virtual interface signature");
    return nullptr;
  }
  const auto& info = *std::get<const FunctionInfo*>(result);
  auto implementation_result = GetFunctionInfo(*implementation_declaration);
  if (const auto* failure = std::get_if<TypeConversionFailure>(&implementation_result)) {
    DiagnoseTypeConversionFailure(*implementation_declaration, *failure, "this virtual implementation signature");
    return nullptr;
  }
  const auto& implementation_info = *std::get<const FunctionInfo*>(implementation_result);
  // Reference guarantees may differ between an interface and its override without changing the ABI.
  // Strip them only at reference positions; alignment on indirect ABI parameters must still match.
  llvm::AttributeMask reference_attributes;
  reference_attributes.addAttribute(llvm::Attribute::NonNull);
  reference_attributes.addAttribute(llvm::Attribute::Alignment);
  reference_attributes.addAttribute(llvm::Attribute::Dereferenceable);
  const auto without_reference_attributes = [&](const FunctionType& signature, const FunctionInfo& function_info) {
    auto attributes = function_info.attributes;
    if (signature.GetReturnType()->AsReferenceType()) {
      attributes = attributes.removeRetAttributes(*llvm_context_, reference_attributes);
    }
    const auto& parameters = signature.GetParameterTypes();
    for (std::size_t index = 0; index < parameters.size(); ++index) {
      const auto& parameter = function_info.parameters[index];
      if (parameters[index]->AsReferenceType() && parameter.llvm_index) {
        attributes = attributes.removeParamAttributes(*llvm_context_, *parameter.llvm_index, reference_attributes);
      }
    }
    return attributes;
  };
  if (entry.return_adjustment == 0 && implementation->getFunctionType() == info.type &&
      implementation->getCallingConv() == llvm::CallingConv::C &&
      without_reference_attributes(*implementation_declaration->type.GetTypePtr()->AsFunctionType(),
                                   implementation_info) ==
          without_reference_attributes(*entry.interface->type.GetTypePtr()->AsFunctionType(), info)) {
    return implementation;
  }
  const auto name = implementation->getName().str() + ":thunk(0," + std::to_string(entry.return_adjustment) + ")";
  // A shared entry must not inherit stronger reference guarantees from its first interface.
  const auto attributes = without_reference_attributes(*entry.interface->type.GetTypePtr()->AsFunctionType(), info);
  if (auto* existing = module_->getNamedValue(name)) {
    const auto it = thunks_.find(name);
    auto* function = llvm::dyn_cast<llvm::Function>(existing);
    if (it == thunks_.end() || it->second.function != function || it->second.target != implementation ||
        it->second.return_adjustment != entry.return_adjustment || !function ||
        function->getFunctionType() != info.type || function->getCallingConv() != llvm::CallingConv::C ||
        function->getAttributes() != attributes) {
      InternalError(*entry.interface, "incompatible stable symbol '" + name + "'");
      return nullptr;
    }
    if (function->empty())
      codegen_detail::CodeGenFunction(*this, *function).GenerateThunk(entry, info, *implementation);
    return function;
  }
  auto* thunk = llvm::Function::Create(info.type, llvm::GlobalValue::InternalLinkage, name, *module_);
  thunk->setAttributes(attributes);
  thunks_.emplace(name, Thunk{thunk, implementation, entry.return_adjustment});
  codegen_detail::CodeGenFunction(*this, *thunk).GenerateThunk(entry, info, *implementation);
  return thunk;
}

llvm::GlobalVariable* CodeGen::GetOrCreateVTable(const StructDecl& declaration) {
  auto it = vtables_.find(&declaration);
  if (it == vtables_.end()) {
    const auto name = "cw:" + declaration.QualifiedName() + ":vtable";
    if (module_->getNamedValue(name)) {
      InternalError(declaration, "conflicting stable symbol '" + name + "'");
      return nullptr;
    }
    auto* pointer_type = llvm::PointerType::getUnqual(*llvm_context_);
    auto* type = llvm::ArrayType::get(pointer_type, ast_context_->GetVTableLayout(declaration).entries.size() + 2);
    auto* table = new llvm::GlobalVariable(*module_, type, true, llvm::GlobalValue::ExternalLinkage, nullptr, name);
    table->setAlignment(llvm::Align(ast_context_->GetTargetInfo().GetPointerAlignment()));
    it = vtables_.emplace(&declaration, table).first;
  }
  return it->second;
}

bool CodeGen::EmitVTableDefinition(const StructDecl& declaration) {
  BOOST_ASSERT(declaration.modifier != DeclModifier::Import);
  auto* table = GetOrCreateVTable(declaration);
  if (!table) return false;
  if (table->hasInitializer()) return true;
  auto* pointer_type = llvm::PointerType::getUnqual(*llvm_context_);
  // The primary vtable has offset-to-top zero and a null RTTI descriptor.
  std::vector<llvm::Constant*> entries(2, llvm::ConstantPointerNull::get(pointer_type));
  for (const auto& entry : ast_context_->GetVTableLayout(declaration).entries) {
    auto* function = GetVTableEntry(entry);
    if (!function) return false;
    entries.push_back(function);
  }
  table->setInitializer(llvm::ConstantArray::get(llvm::cast<llvm::ArrayType>(table->getValueType()), entries));
  return true;
}

llvm::Constant* CodeGen::GetVTableAddressPoint(const StructDecl& declaration) {
  auto* table = GetOrCreateVTable(declaration);
  if (!table) return nullptr;
  auto* index_type = GetPointerIndexType();
  llvm::Constant* indices[] = {llvm::ConstantInt::get(index_type, 0), llvm::ConstantInt::get(index_type, 2)};
  return llvm::ConstantExpr::getGetElementPtr(table->getValueType(), table, indices);
}

llvm::Constant* CodeGen::GetVirtualFunctionPointer(const VirtualFunctionDecl& declaration) {
  const auto* receiver = declaration.ParmVars.front()->type.GetTypePtr()->AsReferenceType();
  const auto& structure = *receiver->GetReferentType()->AsStructType()->GetDeclaration();
  const auto index = ast_context_->GetVTableLayout(structure).function_indices.at(&declaration);
  auto* word = GetPointerIndexType();
  llvm::Constant* values[] = {
      llvm::ConstantInt::get(word, index * ast_context_->GetTargetInfo().GetPointerBitWidth() / 8),
      llvm::ConstantInt::get(word, 1)};
  return llvm::ConstantStruct::get(llvm::StructType::get(*llvm_context_, {word, word}), values);
}

std::string CodeGen::GetFunctionName(const FunctionDecl& declaration, StructorKind kind) const {
  const auto* type = declaration.type.GetTypePtr()->AsFunctionType();
  std::string name;
  llvm::raw_string_ostream output(name);
  if (const auto* target = GetStructorType(declaration)) {
    output << "cw:" << target->GetDeclaration()->QualifiedName()
           << (declaration.GetKind() == NodeKind::ConstructorDecl ? ":ctor" : ":dtor");
    WriteSymbolParameters(*type, output);
    output << (kind == StructorKind::Complete ? ":complete" : ":base");
  } else {
    auto qualified = declaration.QualifiedName();
    if (qualified == "main") return "main";
    if (IsOperatorFunctionName(declaration.name))
      qualified.insert(qualified.size() - declaration.name.size(), "operator");
    output << "cw:" << qualified << ':';
    WriteSymbolType(QualType(type), output);
  }
  return name;
}

llvm::Function* CodeGen::GetOrCreateFunction(const FunctionDecl& declaration, StructorKind kind) {
  if (declaration.GetKind() == NodeKind::VirtualFunctionDecl) {
    const auto& slot = static_cast<const VirtualFunctionDecl&>(declaration);
    if (slot.implementation) return GetOrCreateFunction(*slot.implementation, kind);
    const auto* receiver = slot.ParmVars.front()->type.GetTypePtr()->AsReferenceType();
    const auto& owner = *receiver->GetReferentType()->AsStructType()->GetDeclaration();
    BOOST_ASSERT(owner.modifier == DeclModifier::Import && !slot.is_abstract);
  }
  auto& entry = functions_[&declaration][static_cast<std::size_t>(kind)];
  if (entry.function) return entry.function;
  const auto* semantic_type = declaration.type.GetTypePtr()->AsFunctionType();
  if (!semantic_type) {
    InternalError(declaration, "function has no semantic signature");
    return nullptr;
  }
  auto result = GetFunctionInfo(declaration, kind);
  if (const auto* failure = std::get_if<TypeConversionFailure>(&result)) {
    DiagnoseTypeConversionFailure(declaration, *failure, "this function signature");
    return nullptr;
  }
  const auto& info = *std::get<const FunctionInfo*>(result);
  const auto name = GetFunctionName(declaration, kind);
  if (auto* existing = module_->getNamedValue(name)) {
    auto* function = llvm::dyn_cast<llvm::Function>(existing);
    const auto previous = function_declarations_.find(function);
    if (!function || previous == function_declarations_.end() || previous->second->type != declaration.type ||
        GetStructorType(*previous->second) != GetStructorType(declaration) ||
        function->getFunctionType() != info.type || function->getCallingConv() != llvm::CallingConv::C ||
        function->getAttributes() != info.attributes || (previous->second->Body && declaration.Body)) {
      InternalError(declaration, "incompatible stable symbol '" + name + "'");
      return nullptr;
    }
    if (declaration.Body) previous->second = &declaration;
    entry.function = function;
    return function;
  }
  auto* function = llvm::Function::Create(info.type, llvm::GlobalValue::ExternalLinkage, name, *module_);
  function->setAttributes(info.attributes);
  entry.function = function;
  function_declarations_.emplace(function, &declaration);
  if (declaration.GetKind() == NodeKind::DestructorDecl) {
    const auto& destructor = static_cast<const DestructorDecl&>(declaration);
    destructors_.emplace(destructor.target_type->GetDeclaration(), &destructor);
  }
  return function;
}

bool CodeGen::DeclareGlobalVariable(const VarDecl& declaration) {
  auto result = ConvertTypeForMem(*declaration.type.GetTypePtr());
  if (const auto* failure = std::get_if<TypeConversionFailure>(&result)) {
    return DiagnoseTypeConversionFailure(declaration, *failure, "this global variable type");
  }
  auto* type = std::get<llvm::Type*>(result);
  if (type->isVoidTy()) {
    return Unsupported(declaration, "this global variable type");
  }
  // Zero-filled backing storage does not form the CW object. Its initializer still executes in order.
  const auto name = "cw:" + declaration.QualifiedName() + ":var";
  if (module_->getNamedValue(name)) return InternalError(declaration, "conflicting stable symbol '" + name + "'");
  auto* global = new llvm::GlobalVariable(*module_, type, false, llvm::GlobalValue::ExternalLinkage,
                                          llvm::Constant::getNullValue(type), name);
  global->setAlignment(llvm::Align(GetTypeLayoutForMem(*declaration.type.GetTypePtr()).alignment));
  globals_.emplace(&declaration, global);
  return true;
}

bool CodeGen::NeedsGlobalDestruction(const Type& type) {
  if (type.GetTriviality() != TypeTriviality::NonTrivial) {
    return false;
  }
  for (const auto* array = type.AsArrayType(); array; array = array->GetElementType().GetTypePtr()->AsArrayType()) {
    if (array->GetLength() == 0) {
      return false;
    }
  }
  return true;
}

void CodeGen::DeclareGlobalDestructionRuntime() {
  auto* pointer_type = llvm::PointerType::getUnqual(*llvm_context_);
  auto* signature = llvm::FunctionType::get(llvm::Type::getInt32Ty(*llvm_context_),
                                            {pointer_type, pointer_type, pointer_type}, false);
  cxa_atexit_ = llvm::Function::Create(signature, llvm::GlobalValue::ExternalLinkage, "__cxa_atexit", *module_);
  cxa_atexit_->setDoesNotThrow();
  dso_handle_ = new llvm::GlobalVariable(*module_, llvm::Type::getInt8Ty(*llvm_context_), false,
                                         llvm::GlobalValue::ExternalLinkage, nullptr, "__dso_handle");
  dso_handle_->setVisibility(llvm::GlobalValue::HiddenVisibility);
}

llvm::Function* CodeGen::GetGlobalDestructor(const VarDecl& declaration) {
  const auto* type = declaration.type.GetTypePtr();
  if (const auto* structure = type->AsStructType()) {
    auto* destructor = GetOrCreateFunction(*destructors_.at(structure->GetDeclaration()), StructorKind::Complete);
    if (!destructor) return nullptr;
    if (destructor->getReturnType()->isVoidTy() || GetTargetABI().can_call_mismatched_function_type) {
      return destructor;
    }
    // WebAssembly requires the atexit callback to have the exact void(pointer) type;
    // adapt the target ABI's this-returning destructor below.
  }
  if (const auto it = global_destructors_.find(&declaration); it != global_destructors_.end()) {
    return it->second;
  }
  auto* signature = llvm::FunctionType::get(llvm::Type::getVoidTy(*llvm_context_),
                                            {llvm::PointerType::getUnqual(*llvm_context_)}, false);
  auto* function = llvm::Function::Create(signature, llvm::GlobalValue::InternalLinkage,
                                          type->AsArrayType() ? "cw:global_array_dtor" : "cw:global_dtor", *module_);
  function->addParamAttr(0, llvm::Attribute::NoUndef);
  if (!codegen_detail::CodeGenFunction(*this, *function).GenerateGlobalDestructor(declaration)) {
    return nullptr;
  }
  global_destructors_.emplace(&declaration, function);
  return function;
}

bool CodeGen::EmitGlobalInitializers(const TranslationUnitDecl& declaration) {
  auto* signature = llvm::FunctionType::get(llvm::Type::getVoidTy(*llvm_context_), false);
  std::vector<llvm::Function*> initializers;
  for (const auto* child : declaration.FlattenedDecls()) {
    if (child->GetKind() != NodeKind::VarGroupDecl) {
      continue;
    }
    auto* function =
        llvm::Function::Create(signature, llvm::GlobalValue::InternalLinkage, "cw:global_var_init", *module_);
    if (!codegen_detail::CodeGenFunction(*this, *function)
             .GenerateGlobalVarInit(static_cast<const VarGroupDecl&>(*child))) {
      return false;
    }
    initializers.push_back(function);
  }
  if (!initializers.empty()) {
    auto* function = llvm::Function::Create(signature, llvm::GlobalValue::InternalLinkage, "cw:global_init", *module_);
    codegen_detail::CodeGenFunction(*this, *function).GenerateGlobalInit(initializers);
    llvm::appendToGlobalCtors(*module_, function, 65535);
  }
  return true;
}

std::unique_ptr<llvm::Module> CodeGen::operator()(std::string_view module_name) {
  BOOST_ASSERT(diagnostic_engine_);
  BOOST_ASSERT(ast_context_);
  BOOST_ASSERT(llvm_context_);
  BOOST_ASSERT(target_machine_);

  if (generated_) {
    diagnostic_engine_->Add(kErrorDiagnostic,
                            "internal code generation error: a CodeGen instance may generate only once");
    return nullptr;
  }
  generated_ = true;
  if (diagnostic_engine_->HasErrors()) {
    return nullptr;
  }
  const auto* translation_unit = ast_context_->GetTranslationUnitDecl();
  if (!translation_unit || translation_unit->ContainsErrors()) {
    diagnostic_engine_->Add(kErrorDiagnostic, "code generation requires a successfully analyzed translation unit");
    return nullptr;
  }
  const auto& triple = target_machine_->getTargetTriple();
  const auto& target_info = ast_context_->GetTargetInfo();
  const auto data_layout = target_machine_->createDataLayout();
  auto semantic_triple = target_info.GetTriple();
  // Darwin and macOS triples describe the same semantic target; deployment versions belong to code emission.
  if (triple.isMacOSX() && semantic_triple.isMacOSX()) {
    semantic_triple.setOS(triple.getOS());
  }
  if (triple != semantic_triple || !data_layout.isLittleEndian() ||
      data_layout.getPointerSizeInBits() != target_info.GetPointerBitWidth() ||
      data_layout.getPointerABIAlignment(0).value() != target_info.GetPointerAlignment() ||
      data_layout.getIndexSizeInBits(0) != target_info.GetPointerBitWidth()) {
    diagnostic_engine_->Add(kErrorDiagnostic, "code generation target does not match the semantic target");
    return nullptr;
  }
  for (unsigned bits : {8, 16, 32, 64}) {
    if (data_layout.getABITypeAlign(llvm::IntegerType::get(*llvm_context_, bits)).value() !=
        target_info.GetScalarAlignment(bits)) {
      diagnostic_engine_->Add(kErrorDiagnostic, "code generation data layout does not match the semantic target");
      return nullptr;
    }
  }
  if (data_layout.getABITypeAlign(llvm::Type::getFloatTy(*llvm_context_)).value() !=
          target_info.GetScalarAlignment(32) ||
      data_layout.getABITypeAlign(llvm::Type::getDoubleTy(*llvm_context_)).value() !=
          target_info.GetScalarAlignment(64)) {
    diagnostic_engine_->Add(kErrorDiagnostic, "code generation data layout does not match the semantic target");
    return nullptr;
  }
  module_ = std::make_unique<llvm::Module>(llvm::StringRef(module_name), *llvm_context_);
  module_->setTargetTriple(triple);
  module_->setDataLayout(target_machine_->createDataLayout());

  // Runtime entries keep their ABI names; named source entities use the CW namespace.
  const auto declarations = translation_unit->FlattenedDecls();
  const bool needs_global_destruction =
      std::any_of(declarations.begin(), declarations.end(), [](const auto& declaration) {
        if (declaration->GetKind() != NodeKind::VarGroupDecl) {
          return false;
        }
        const auto& group = static_cast<const VarGroupDecl&>(*declaration);
        return std::any_of(group.Vars.begin(), group.Vars.end(),
                           [](const auto& variable) { return NeedsGlobalDestruction(*variable->type.GetTypePtr()); });
      });
  if (needs_global_destruction) {
    DeclareGlobalDestructionRuntime();
  }

  const bool needs_pure_virtual = std::any_of(declarations.begin(), declarations.end(), [](const auto& declaration) {
    return declaration->GetKind() == NodeKind::StructDecl && static_cast<const StructDecl&>(*declaration).is_abstract;
  });
  if (needs_pure_virtual) {
    pure_virtual_ = llvm::Function::Create(llvm::FunctionType::get(llvm::Type::getVoidTy(*llvm_context_), false),
                                           llvm::GlobalValue::ExternalLinkage, "__cxa_pure_virtual", *module_);
    pure_virtual_->addFnAttr(llvm::Attribute::NoReturn);
  }

  // Prepare every global address and callable before emitting bodies, including forward references from functions.
  for (const auto& declaration : declarations) {
    if (declaration->GetKind() == NodeKind::StructDecl) {
      continue;  // A type declaration alone has no runtime representation.
    }
    if (declaration->GetKind() == NodeKind::VarGroupDecl) {
      for (const auto& variable : static_cast<const VarGroupDecl&>(*declaration).Vars) {
        if (!DeclareGlobalVariable(*variable)) {
          break;
        }
      }
      if (diagnostic_engine_->HasErrors()) {
        break;
      }
      continue;
    }
    if (declaration->GetKind() != NodeKind::FunctionDecl && declaration->GetKind() != NodeKind::ConstructorDecl &&
        declaration->GetKind() != NodeKind::DestructorDecl) {
      Unsupported(*declaration, "this top-level declaration");
      break;
    }
    if (!GetOrCreateFunction(static_cast<const FunctionDecl&>(*declaration))) {
      break;
    }
    if (GetStructorType(static_cast<const FunctionDecl&>(*declaration)) &&
        !GetOrCreateFunction(static_cast<const FunctionDecl&>(*declaration), StructorKind::Base)) {
      break;
    }
  }
  if (!diagnostic_engine_->HasErrors()) {
    for (const auto& declaration : declarations) {
      if (declaration->GetKind() != NodeKind::FunctionDecl && declaration->GetKind() != NodeKind::ConstructorDecl &&
          declaration->GetKind() != NodeKind::DestructorDecl) {
        continue;
      }
      const auto& function = static_cast<const FunctionDecl&>(*declaration);
      if (!function.Body) continue;
      for (const auto kind : {StructorKind::Complete, StructorKind::Base}) {
        if (kind == StructorKind::Base && !GetStructorType(function)) continue;
        auto* entry = GetOrCreateFunction(function, kind);
        if (!entry ||
            (entry->empty() &&
             !codegen_detail::CodeGenFunction(*this, *entry)
                  .Generate(function, *std::get<const FunctionInfo*>(GetFunctionInfo(function, kind)), kind))) {
          break;
        }
      }
      if (diagnostic_engine_->HasErrors()) break;
    }
  }
  if (!diagnostic_engine_->HasErrors()) {
    EmitGlobalInitializers(*translation_unit);
  }
  if (!diagnostic_engine_->HasErrors()) {
    for (const auto* declaration : declarations) {
      if (declaration->GetKind() != NodeKind::StructDecl) continue;
      const auto& structure = static_cast<const StructDecl&>(*declaration);
      if (structure.modifier == DeclModifier::Import || !structure.IsPolymorphic()) continue;
      if ((structure.modifier == DeclModifier::Export || vtables_.find(&structure) != vtables_.end()) &&
          !EmitVTableDefinition(structure))
        break;
    }
  }
  if (!diagnostic_engine_->HasErrors()) {
    std::string error;
    llvm::raw_string_ostream stream(error);
    if (llvm::verifyModule(*module_, &stream)) {
      diagnostic_engine_->Add(kErrorDiagnostic, "internal code generation error: LLVM verification failed: " + error);
    }
  }
  if (diagnostic_engine_->HasErrors()) {
    module_.reset();
    functions_.clear();
    function_declarations_.clear();
    thunks_.clear();
    globals_.clear();
    global_destructors_.clear();
    string_literals_.clear();
    struct_representations_.clear();
    function_infos_.clear();
    structor_infos_.clear();
    destructors_.clear();
    vtables_.clear();
    pure_virtual_ = nullptr;
    cxa_atexit_ = nullptr;
    dso_handle_ = nullptr;
    return nullptr;
  }
  return std::move(module_);
}

}  // namespace cw
