/// \file ExprParser.cpp
/// \author Donghao Chu
/// \date 2025/01/14
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "ExprParser.h"

#include "ExprGrammar.h"
#include "ExprParseTable.h"

namespace cw {

ExprParser::ExprParser() : LRStateMachine(ExprGrammar(), ExprParseTable()) {}

}  // namespace cw
