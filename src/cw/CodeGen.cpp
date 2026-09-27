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

}  // namespace

std::unique_ptr<llvm::TargetMachine> CodeGen::CreateTarget(const TargetInfo& target_info,
                                                           DiagnosticEngine& diagnostics) {
  const auto& triple = target_info.GetTriple();
  static const bool kNativeTargetInitialized = !llvm::InitializeNativeTarget();
  if (!kNativeTargetInitialized) {
    diagnostics.Add(kErrorDiagnostic, "failed to initialize the native LLVM target");
    return nullptr;
  }
  std::string error;
  const auto* target = llvm::TargetRegistry::lookupTarget(triple, error);
  if (!target) {
    diagnostics.Add(kErrorDiagnostic, "failed to select the native LLVM target: " + error);
    return nullptr;
  }
  std::unique_ptr<llvm::TargetMachine> machine(
      target->createTargetMachine(triple, "generic", "", llvm::TargetOptions(), llvm::Reloc::PIC_));
  if (!machine) {
    diagnostics.Add(kErrorDiagnostic, "failed to create the native LLVM target machine");
  }
  return machine;
}

CodeGen::CodeGen() = default;

CodeGen::~CodeGen() = default;

void CodeGen::SetDiagnosticEngine(DiagnosticEngine* diagnostic_engine) { diagnostic_engine_ = diagnostic_engine; }

void CodeGen::SetASTContext(const ASTContext* ast_context) { ast_context_ = ast_context; }

void CodeGen::SetLLVMContext(llvm::LLVMContext* llvm_context) { llvm_context_ = llvm_context; }

void CodeGen::SetTargetMachine(const llvm::TargetMachine* target_machine) { target_machine_ = target_machine; }

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
    // Use the target's two-word direct ABI value for both SSA and memory.
    return llvm::ArrayType::get(llvm::Type::getInt64Ty(*llvm_context_), 2);
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
      auto* type =
          llvm::StructType::create(*llvm_context_, elements, "struct." + declaration.name + suffix.str(), packed);
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
  if (!type.AsArrayType() && !type.AsStructType()) {
    return ABIArgInfo{ABIArgInfo::Kind::Direct, memory_type, std::get<llvm::Type*>(ConvertType(type))};
  }

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
  if (this_type) {
    // Apple arm64 constructors and non-deleting destructors return the incoming target address.
    return_type = pointer_type;
  }
  info.type = llvm::FunctionType::get(return_type, parameters, false);
  info.attributes = GetFunctionAttributes(type, info);
  return &cache.emplace(&type, std::move(info)).first->second;
}

CodeGen::FunctionInfoResult CodeGen::GetFunctionInfo(const FunctionDecl& declaration) {
  const StructType* this_type = nullptr;
  if (declaration.GetKind() == NodeKind::ConstructorDecl) {
    this_type = static_cast<const ConstructorDecl&>(declaration).target_type;
  } else if (declaration.GetKind() == NodeKind::DestructorDecl) {
    this_type = static_cast<const DestructorDecl&>(declaration).target_type;
  }
  return GetFunctionInfo(*declaration.type.GetTypePtr()->AsFunctionType(), this_type);
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
  // Native macOS arm64 extends narrow scalar arguments and results at the ABI boundary.
  // LLVM integer types do not retain signedness, so derive the attribute from the semantic type.
  const auto get_extension = [&](const Type& semantic) {
    const auto* builtin = semantic.AsBuiltinType();
    if (builtin && builtin->GetBuiltinTypeKind() == BuiltinTypeKind::Bool) {
      return llvm::Attribute::ZExt;
    }
    if (builtin && builtin->IsInteger() && ast_context_->GetIntegerBitWidth(*builtin) < 32) {
      return builtin->IsSignedInteger() ? llvm::Attribute::SExt : llvm::Attribute::ZExt;
    }
    return llvm::Attribute::None;
  };
  llvm::AttributeList attributes;
  if (info.this_index) {
    attributes = attributes.addParamAttribute(*llvm_context_, *info.this_index, llvm::Attribute::NoUndef);
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
  if (const auto extension = get_extension(*type.GetReturnType()); extension != llvm::Attribute::None) {
    attributes = attributes.addRetAttribute(*llvm_context_, extension);
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
    if (const auto extension = get_extension(*parameters[index]); extension != llvm::Attribute::None) {
      attributes = attributes.addParamAttribute(*llvm_context_, *parameter.llvm_index, extension);
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
                                          initializer, ".str");
  global->setAlignment(module_->getDataLayout().getABITypeAlign(initializer->getType()));
  string_literals_.emplace(initializer, global);
  return global;
}

llvm::Function* CodeGen::GetVTableEntry(const VTableEntry& entry) {
  if (entry.final_overrider->is_abstract) {
    BOOST_ASSERT(pure_virtual_);
    return pure_virtual_;
  }
  const auto* definition = entry.final_overrider->definition;
  BOOST_ASSERT(definition);
  auto* implementation = functions_.at(definition);
  const auto& info = *std::get<const FunctionInfo*>(GetFunctionInfo(*entry.interface));
  const auto& implementation_info = *std::get<const FunctionInfo*>(GetFunctionInfo(*definition));
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
      without_reference_attributes(*definition->type.GetTypePtr()->AsFunctionType(), implementation_info) ==
          without_reference_attributes(*entry.interface->type.GetTypePtr()->AsFunctionType(), info)) {
    return implementation;
  }
  auto* thunk =
      llvm::Function::Create(info.type, llvm::GlobalValue::InternalLinkage, ".cw.thunk." + definition->name, *module_);
  thunk->setAttributes(info.attributes);
  codegen_detail::CodeGenFunction(*this, *thunk).GenerateThunk(entry, info, *implementation);
  return thunk;
}

llvm::Constant* CodeGen::GetVTableAddressPoint(const StructDecl& declaration) {
  auto it = vtables_.find(&declaration);
  if (it == vtables_.end()) {
    auto* pointer_type = llvm::PointerType::getUnqual(*llvm_context_);
    // The primary vtable has offset-to-top zero and a null RTTI descriptor.
    std::vector<llvm::Constant*> entries(2, llvm::ConstantPointerNull::get(pointer_type));
    for (const auto& entry : ast_context_->GetVTableLayout(declaration).entries) {
      entries.push_back(GetVTableEntry(entry));
    }
    auto* initializer = llvm::ConstantArray::get(llvm::ArrayType::get(pointer_type, entries.size()), entries);
    auto* table = new llvm::GlobalVariable(*module_, initializer->getType(), true, llvm::GlobalValue::InternalLinkage,
                                           initializer, ".cw.vtable." + declaration.name);
    table->setAlignment(llvm::Align(ast_context_->GetTargetInfo().GetPointerAlignment()));
    it = vtables_.emplace(&declaration, table).first;
  }
  llvm::Constant* indices[] = {llvm::ConstantInt::get(llvm::Type::getInt32Ty(*llvm_context_), 0),
                               llvm::ConstantInt::get(llvm::Type::getInt32Ty(*llvm_context_), 2)};
  return llvm::ConstantExpr::getGetElementPtr(it->second->getValueType(), it->second, indices);
}

llvm::Constant* CodeGen::GetVirtualFunctionPointer(const VirtualFunctionDecl& declaration) {
  const auto* receiver = declaration.ParmVars.front()->type.GetTypePtr()->AsReferenceType();
  const auto& structure = *receiver->GetReferentType()->AsStructType()->GetDeclaration();
  const auto index = ast_context_->GetVTableLayout(structure).function_indices.at(&declaration);
  auto* word = llvm::Type::getInt64Ty(*llvm_context_);
  llvm::Constant* values[] = {
      llvm::ConstantInt::get(word, index * ast_context_->GetTargetInfo().GetPointerBitWidth() / 8),
      llvm::ConstantInt::get(word, 1)};
  return llvm::ConstantArray::get(llvm::ArrayType::get(word, 2), values);
}

bool CodeGen::DeclareFunction(const FunctionDecl& declaration) {
  const auto* semantic_type = declaration.type.GetTypePtr()->AsFunctionType();
  if (!semantic_type) {
    return InternalError(declaration, "function has no semantic signature");
  }
  auto result = GetFunctionInfo(declaration);
  if (const auto* failure = std::get_if<TypeConversionFailure>(&result)) {
    return DiagnoseTypeConversionFailure(declaration, *failure, "this function signature");
  }
  const auto& info = *std::get<const FunctionInfo*>(result);
  // Source names remain readable. LLVM disambiguates overloaded names within this module;
  // calls use declaration identity, never the spelling or the lowered parameter types.
  std::string name = declaration.name;
  if (declaration.GetKind() == NodeKind::ConstructorDecl) {
    name += ".ctor";
  } else if (declaration.GetKind() == NodeKind::DestructorDecl) {
    name += ".dtor";
  }
  auto* function = llvm::Function::Create(info.type, llvm::GlobalValue::ExternalLinkage, name, *module_);
  function->setAttributes(info.attributes);
  functions_.emplace(&declaration, function);
  if (declaration.GetKind() == NodeKind::DestructorDecl) {
    const auto& destructor = static_cast<const DestructorDecl&>(declaration);
    destructors_.emplace(destructor.target_type->GetDeclaration(), &destructor);
  }
  return true;
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
  auto* global = new llvm::GlobalVariable(*module_, type, false, llvm::GlobalValue::ExternalLinkage,
                                          llvm::Constant::getNullValue(type), declaration.name);
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
    // Like Clang, Apple arm64 can register a this-returning destructor; the exit runtime ignores its return.
    return functions_.at(destructors_.at(structure->GetDeclaration()));
  }
  BOOST_ASSERT(type->AsArrayType());
  if (const auto it = global_destructors_.find(&declaration); it != global_destructors_.end()) {
    return it->second;
  }
  auto* signature = llvm::FunctionType::get(llvm::Type::getVoidTy(*llvm_context_),
                                            {llvm::PointerType::getUnqual(*llvm_context_)}, false);
  auto* function =
      llvm::Function::Create(signature, llvm::GlobalValue::InternalLinkage, ".cw.global_array_dtor", *module_);
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
  for (const auto& child : declaration.Decls) {
    if (child->GetKind() != NodeKind::VarGroupDecl) {
      continue;
    }
    auto* function =
        llvm::Function::Create(signature, llvm::GlobalValue::InternalLinkage, ".cw.global_var_init", *module_);
    if (!codegen_detail::CodeGenFunction(*this, *function)
             .GenerateGlobalVarInit(static_cast<const VarGroupDecl&>(*child))) {
      return false;
    }
    initializers.push_back(function);
  }
  if (!initializers.empty()) {
    auto* function = llvm::Function::Create(signature, llvm::GlobalValue::InternalLinkage, ".cw.global_init", *module_);
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
  if (triple != target_info.GetTriple() || !data_layout.isLittleEndian() ||
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

  // Reserve runtime symbols before source symbols, which LLVM can then disambiguate without changing bindings.
  const bool needs_global_destruction =
      std::any_of(translation_unit->Decls.begin(), translation_unit->Decls.end(), [](const auto& declaration) {
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

  const bool needs_pure_virtual =
      std::any_of(translation_unit->Decls.begin(), translation_unit->Decls.end(), [](const auto& declaration) {
        return declaration->GetKind() == NodeKind::StructDecl &&
               static_cast<const StructDecl&>(*declaration).is_abstract;
      });
  if (needs_pure_virtual) {
    pure_virtual_ = llvm::Function::Create(llvm::FunctionType::get(llvm::Type::getVoidTy(*llvm_context_), false),
                                           llvm::GlobalValue::ExternalLinkage, "__cxa_pure_virtual", *module_);
    pure_virtual_->addFnAttr(llvm::Attribute::NoReturn);
  }

  // Prepare every global address and callable before emitting bodies, including forward references from functions.
  for (const auto& declaration : translation_unit->Decls) {
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
    if (!DeclareFunction(static_cast<const FunctionDecl&>(*declaration))) {
      break;
    }
  }
  if (!diagnostic_engine_->HasErrors()) {
    for (const auto& declaration : translation_unit->Decls) {
      if (declaration->GetKind() != NodeKind::FunctionDecl && declaration->GetKind() != NodeKind::ConstructorDecl &&
          declaration->GetKind() != NodeKind::DestructorDecl) {
        continue;
      }
      const auto& function = static_cast<const FunctionDecl&>(*declaration);
      if (function.Body && !codegen_detail::CodeGenFunction(*this, *functions_.at(&function))
                                .Generate(function, *std::get<const FunctionInfo*>(GetFunctionInfo(function)))) {
        break;
      }
    }
  }
  if (!diagnostic_engine_->HasErrors()) {
    EmitGlobalInitializers(*translation_unit);
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
    globals_.clear();
    global_destructors_.clear();
    string_literals_.clear();
    struct_representations_.clear();
    function_infos_.clear();
    structor_infos_.clear();
    destructors_.clear();
    cxa_atexit_ = nullptr;
    dso_handle_ = nullptr;
    return nullptr;
  }
  return std::move(module_);
}

}  // namespace cw
