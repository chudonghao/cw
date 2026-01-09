/// \file ExprParser.h
/// \author Donghao Chu
/// \date 2025/01/14
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include "lang/LRStateMachine.h"

namespace cw {

class ExprParser : public lang::LRStateMachine {
 public:
  ExprParser();
};

}  // namespace cw
