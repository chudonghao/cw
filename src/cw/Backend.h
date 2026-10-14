/// \file Backend.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

namespace llvm {
class Module;
class TargetMachine;
class raw_ostream;
}  // namespace llvm

namespace cw {

class DiagnosticEngine;

enum class BackendOutputKind { LLVMIR, Object };

/// \brief Emits a module using borrowed dependencies; object emission may modify the module.
/// The module must be verified and configured for the supplied target machine.
/// Returns false on generation errors. The caller must finish and check the output stream.
/// Does not open, close, or remove files, or retain any borrowed dependencies.
bool EmitBackendOutput(llvm::Module& module, llvm::TargetMachine& target, BackendOutputKind kind,
                       llvm::raw_ostream& output, DiagnosticEngine& diagnostics);

}  // namespace cw
