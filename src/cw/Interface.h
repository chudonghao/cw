/// \file Interface.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

namespace llvm {
class raw_ostream;
}  // namespace llvm

namespace cw {

struct TranslationUnitDecl;

/// Emits the exported declarations of a successfully analyzed translation unit.
/// Borrows the AST and stream; the caller owns output paths and I/O error handling.
void EmitInterface(const TranslationUnitDecl& translation_unit, llvm::raw_ostream& output);

}  // namespace cw
