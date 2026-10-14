/// \file Backend.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "Backend.h"

#include <memory>
#include <string>
#include <utility>

#include <llvm/ADT/SmallVector.h>
#include <llvm/IR/DiagnosticInfo.h>
#include <llvm/IR/DiagnosticPrinter.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/Target/TargetMachine.h>

#include "Diagnostic.h"

namespace cw {
namespace {

class BackendDiagnosticHandler : public llvm::DiagnosticHandler {
  DiagnosticEngine& diagnostics_;

 public:
  explicit BackendDiagnosticHandler(DiagnosticEngine& diagnostics) : diagnostics_(diagnostics) {}

  bool handleDiagnostics(const llvm::DiagnosticInfo& diagnostic) override {
    DiagnosticSeverity severity = kNoteDiagnostic;
    if (diagnostic.getSeverity() == llvm::DS_Error) {
      severity = kErrorDiagnostic;
      HasErrors = true;
    } else if (diagnostic.getSeverity() == llvm::DS_Warning) {
      severity = kWarningDiagnostic;
    }
    std::string message;
    llvm::raw_string_ostream stream(message);
    llvm::DiagnosticPrinterRawOStream printer(stream);
    diagnostic.print(printer);
    diagnostics_.Add(severity, std::move(message));
    return true;
  }
};

class ScopedBackendDiagnostics {
  llvm::LLVMContext& context_;
  std::unique_ptr<llvm::DiagnosticHandler> previous_;

 public:
  ScopedBackendDiagnostics(llvm::LLVMContext& context, DiagnosticEngine& diagnostics)
      : context_(context), previous_(context.getDiagnosticHandler()) {
    context_.setDiagnosticHandler(std::make_unique<BackendDiagnosticHandler>(diagnostics), true);
  }

  ~ScopedBackendDiagnostics() { context_.setDiagnosticHandler(std::move(previous_)); }
};

}  // namespace

bool EmitBackendOutput(llvm::Module& module, llvm::TargetMachine& target, BackendOutputKind kind,
                       llvm::raw_ostream& output, DiagnosticEngine& diagnostics) {
  if (diagnostics.HasErrors()) {
    return false;
  }
  if (kind == BackendOutputKind::LLVMIR) {
    module.print(output, nullptr);
    return true;
  }

  ScopedBackendDiagnostics diagnostic_scope(module.getContext(), diagnostics);
  // Object writers need random access, including when the destination is a pipe.
  llvm::SmallVector<char, 0> bytes;
  llvm::raw_svector_ostream object_stream(bytes);
  llvm::legacy::PassManager passes;
  if (target.addPassesToEmitFile(passes, object_stream, nullptr, llvm::CodeGenFileType::ObjectFile)) {
    diagnostics.Add(kErrorDiagnostic, "the LLVM target cannot emit object files");
    return false;
  }
  // run() reports whether the module changed, not whether generation succeeded.
  passes.run(module);
  if (diagnostics.HasErrors()) {
    return false;
  }
  output.write(bytes.data(), bytes.size());
  return true;
}

}  // namespace cw
