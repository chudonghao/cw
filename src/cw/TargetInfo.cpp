/// \file TargetInfo.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "TargetInfo.h"

#include <utility>

#include <boost/assert.hpp>

#include <llvm/TargetParser/Host.h>

namespace cw {

TargetInfo::TargetInfo(llvm::Triple triple) : triple_(std::move(triple)) {}

std::uint64_t TargetInfo::GetScalarAlignment(unsigned storage_bits) const {
  BOOST_ASSERT(storage_bits == 8 || storage_bits == 16 || storage_bits == 32 || storage_bits == 64);
  return storage_bits / 8;
}

std::optional<TargetInfo> TargetInfo::CreateNative() {
  llvm::Triple triple(llvm::sys::getDefaultTargetTriple());
  if (triple.getArch() != llvm::Triple::aarch64 || !triple.isMacOSX()) {
    return std::nullopt;
  }
  return TargetInfo(std::move(triple));
}

}  // namespace cw
