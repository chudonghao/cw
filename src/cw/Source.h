/// \file Source.h
/// \author Donghao Chu
/// \date 2025/01/07
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <filesystem>
#include <string>
#include <string_view>

namespace cw {

struct Source {
  std::filesystem::path path;
  std::string content;
};

std::string_view LineSource(const Source &source, int pos);

}  // namespace cw