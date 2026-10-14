/// \file TargetInfo.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "TargetInfo.h"

#include <string>
#include <utility>

#include <boost/assert.hpp>

#include <llvm/TargetParser/Host.h>

namespace cw {

TargetInfo::TargetInfo(llvm::Triple triple) : triple_(std::move(triple)) {}

std::uint64_t TargetInfo::GetScalarAlignment(unsigned storage_bits) const {
  BOOST_ASSERT(storage_bits == 8 || storage_bits == 16 || storage_bits == 32 || storage_bits == 64);
  return storage_bits / 8;
}

std::optional<TargetInfo> TargetInfo::CreateNative() { return Create(llvm::sys::getDefaultTargetTriple()); }

std::optional<TargetInfo> TargetInfo::Create(std::string_view triple_text) {
  if (triple_text.empty()) {
    return std::nullopt;
  }
  llvm::Triple triple(llvm::Triple::normalize(std::string(triple_text)));
  const bool macos_arm64 = triple.getArch() == llvm::Triple::aarch64 && triple.isMacOSX() &&
                           triple.getVendor() == llvm::Triple::Apple && triple.getEnvironmentName().empty();
  const bool wasm32 = triple.str() == "wasm32-unknown-unknown";
  if (!macos_arm64 && !wasm32) {
    return std::nullopt;
  }
  return TargetInfo(std::move(triple));
}

}  // namespace cw
