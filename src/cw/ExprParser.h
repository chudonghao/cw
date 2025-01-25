/// \file ExprParser.h
/// \author Donghao Chu
/// \date 2025/01/14
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include "lang/LRStateMachine.h"

namespace cw {

class ExprParser : public lang::LRStateMachine {
 public:
  ExprParser();
};

}  // namespace cw
