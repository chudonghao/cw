/// \file ExprParser.cpp
/// \author Donghao Chu
/// \date 2025/01/14
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include "ExprParser.h"

#include "ExprGrammar.h"
#include "ExprParseTable.h"

namespace cw {

ExprParser::ExprParser() : LRStateMachine(ExprGrammar(), ExprParseTable()) {}

}  // namespace cw
