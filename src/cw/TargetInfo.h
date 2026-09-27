/// \file TargetInfo.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstdint>
#include <optional>

#include <llvm/TargetParser/Triple.h>

namespace cw {

/// \brief Immutable target facts available before LLVM code generation.
class TargetInfo {
  llvm::Triple triple_;

 public:
  /// \brief Selects the supported native target without creating a target machine.
  static std::optional<TargetInfo> CreateNative();

  const llvm::Triple& GetTriple() const { return triple_; }
  unsigned GetPointerBitWidth() const { return 64; }
  std::uint64_t GetScalarAlignment(unsigned storage_bits) const;
  std::uint64_t GetPointerAlignment() const { return 8; }
  std::uint64_t GetMaxObjectSize() const { return (std::uint64_t{1} << 61) - 1; }

 private:
  explicit TargetInfo(llvm::Triple triple);
};

}  // namespace cw
