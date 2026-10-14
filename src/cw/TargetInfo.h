/// \file TargetInfo.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstdint>
#include <optional>
#include <string_view>

#include <llvm/TargetParser/Triple.h>

namespace cw {

/// \brief Immutable target facts available before LLVM code generation.
class TargetInfo {
  llvm::Triple triple_;

 public:
  /// \brief Selects the supported native target without creating a target machine.
  static std::optional<TargetInfo> CreateNative();
  /// \brief Selects a supported target from its normalized LLVM triple.
  static std::optional<TargetInfo> Create(std::string_view triple);

  const llvm::Triple& GetTriple() const { return triple_; }
  bool IsWasm32() const { return triple_.getArch() == llvm::Triple::wasm32; }
  unsigned GetPointerBitWidth() const { return IsWasm32() ? 32 : 64; }
  std::uint64_t GetScalarAlignment(unsigned storage_bits) const;
  std::uint64_t GetPointerAlignment() const { return IsWasm32() ? 4 : 8; }
  std::uint64_t GetMaxObjectSize() const {
    return IsWasm32() ? (std::uint64_t{1} << 32) - 1 : (std::uint64_t{1} << 61) - 1;
  }

 private:
  explicit TargetInfo(llvm::Triple triple);
};

}  // namespace cw
