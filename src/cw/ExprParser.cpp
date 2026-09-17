/// \file ExprParser.cpp
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "ExprParser.h"

#include <algorithm>
#include <iostream>
#include <type_traits>
#include <unordered_map>
#include <utility>
#include <variant>

#include "ExprGrammar.h"
#include "ExprParseTable.h"
#include "Lexer.h"
#include "Parser.h"
#include "ast.h"

namespace cw {

namespace {

enum HandleSymbolResult {
  kHandleSymbolResultAccept,
  kHandleSymbolResultShift,
  kHandleSymbolResultReduce,
  kHandleSymbolResultError,
};

constexpr expr::ExprGrammarSymbol kExpressionTerminators[] = {
    expr::comma, expr::semi, expr::l_brace, expr::r_brace, expr::r_square,
};

}  // namespace

ExprParser::ExprParser(Parser* parent) : LRStateMachine(ExprGrammar(), ExprParseTable()), parent_(parent) {
  BOOST_ASSERT(parent_);

  SetupRealReduceFunctions();

  // Let Parser-owned delimiters terminate a complete expression.
  for (auto terminator : kExpressionTerminators) {
    BOOST_ASSERT(terminator < parse_table_.num_symbols());
    for (int state = 0; state < parse_table_.num_states(); ++state) {
      auto& action = parse_table_(state, terminator);
      if (action.type == lang::kActionError) {
        action = parse_table_(state, expr::$);
      }
    }
  }
}

ExprParser::~ExprParser() = default;

std::unique_ptr<Expr> ExprParser::operator()() {
  lexer_ = parent_->lexer_;
  diagnostic_engine_ = parent_->diagnostic_engine_;

  BOOST_ASSERT(lexer_);
  BOOST_ASSERT(diagnostic_engine_);

  Reset();
  lexer_->SkipBlankComment();

  for (;;) {
    auto& token = lexer_->Token();

    HandleSymbolResult result = kHandleSymbolResultError;
    if (token.type == tok::eos) {
      result = static_cast<HandleSymbolResult>(LRStateMachine::operator()(expr::$));
    } else if (is_terminal(static_cast<expr::ExprGrammarSymbol>(token.type))) {
      result = static_cast<HandleSymbolResult>(LRStateMachine::operator()(token.type));
    } else {
      const int state = state_stack_.empty() ? 0 : state_stack_.back();
      ReportError(state);
      return nullptr;
    }

    switch (result) {
      case kHandleSymbolResultError:
        return nullptr;
      case kHandleSymbolResultShift:
        // A synthetic type symbol has already consumed its spelling through Parser::Type_.
        if (symbol_stack_.back() != expr::type) {
          AdvanceLexer();
        }
        break;
      case kHandleSymbolResultReduce:
        break;
      case kHandleSymbolResultAccept: {
        BOOST_ASSERT(real_symbol_stack_.size() == 1);
        auto& symbol = real_symbol_stack_.back();
        BOOST_ASSERT(std::holds_alternative<std::unique_ptr<Expr>>(symbol.value));
        return std::move(std::get<std::unique_ptr<Expr>>(symbol.value));
      }
      default:
        throw std::logic_error("Invalid result");
    }
  }
}

void ExprParser::Reset() {
  LRStateMachine::Reset();
  real_symbol_stack_.clear();
  pending_type_.reset();
}

int ExprParser::OnReduced(int production_id, int, int) {
  BOOST_ASSERT(real_reduce_functions_[production_id]);
  return (this->*real_reduce_functions_[production_id])();
}

int ExprParser::OnErrored(int state, int symbol) {
  // At an operand position, delegate an array type (including its length expression) to Parser.
  if (symbol == expr::l_square && parse_table_(state, expr::type).type == lang::kActionShift) {
    auto parsed_type = parent_->Type_();
    pending_type_ = parsed_type.Take();
    if (!pending_type_) {
      return kHandleSymbolResultError;
    }
    return LRStateMachine::operator()(expr::type);
  }

  ReportError(state);
  return kHandleSymbolResultError;
}

int ExprParser::OnShifted(int, int symbol) {
  if (symbol == expr::type) {
    if (!pending_type_) {
      return kHandleSymbolResultError;
    }
    real_symbol_stack_.emplace_back(SymbolValue{std::move(pending_type_)});
  } else {
    real_symbol_stack_.emplace_back(lexer_->Token());
  }
  return kHandleSymbolResultShift;
}

int ExprParser::OnAccepted() { return kHandleSymbolResultAccept; }

void ExprParser::AdvanceLexer() { parent_->AdvanceLexer(); }

void ExprParser::ReportError(int state) { HandleExpect(ExpectedTokens(state)); }

std::vector<tok::TokenType> ExprParser::ExpectedTokens(int state) const {
  BOOST_ASSERT(0 <= state && state < parse_table_.num_states());

  std::vector<tok::TokenType> expected;
  for (int symbol = expr::terminals_start; symbol < expr::terminals_end; ++symbol) {
    if (parse_table_(state, symbol).type == lang::kActionError) {
      continue;
    }

    if (symbol == expr::type) {
      if (std::find(expected.begin(), expected.end(), tok::l_square) == expected.end()) {
        expected.push_back(tok::l_square);
      }
    } else if (symbol == expr::$) {
      expected.push_back(tok::eos);
    } else {
      expected.push_back(static_cast<tok::TokenType>(symbol));
    }
  }
  BOOST_ASSERT(!expected.empty());
  return expected;
}

void ExprParser::HandleExpect(std::vector<tok::TokenType> expected) { parent_->HandleExpect(expected); }

void ExprParser::SetupRealReduceFunctions() {
  using Production = lang::Production<expr::ExprGrammarSymbol>;
  using ReduceFunction = int (ExprParser::*)();

  std::unordered_map<Production, ReduceFunction, boost::hash<Production>> map;

  // clang-format off
  map[Production(expr::Expr, {expr::T16})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::StringLiterals, {expr::string_literal})] = &ExprParser::Reduce_StringLiterals__string_literal;
  map[Production(expr::StringLiterals, {expr::StringLiterals, expr::string_literal})] = &ExprParser::Reduce_StringLiterals__StringLiterals_string_literal;
  map[Production(expr::ID, {expr::identifier})] = &ExprParser::Reduce_ID__identifier;
  map[Production(expr::ArgumentList, {expr::T16})] = &ExprParser::Reduce_ArgumentList__T16;
  map[Production(expr::ArgumentList, {expr::ArgumentList, expr::comma, expr::T16})] = &ExprParser::Reduce_ArgumentList__ArgumentList_comma_T16;
  map[Production(expr::ParenthesizedArgumentList, {expr::l_paren, expr::r_paren})] = &ExprParser::Reduce_ParenthesizedArgumentList__l_paren_r_paren;
  map[Production(expr::ParenthesizedArgumentList, {expr::l_paren, expr::ArgumentList, expr::r_paren})] = &ExprParser::Reduce_ParenthesizedArgumentList__l_paren_ArgumentList_r_paren;
  map[Production(expr::ArrayElement, {expr::T16})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::ArrayElement, {expr::ArrayInitializer})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::ArrayElementList, {expr::ArrayElement})] = &ExprParser::Reduce_ArrayElementList__ArrayElement;
  map[Production(expr::ArrayElementList, {expr::ArrayElementList, expr::comma, expr::ArrayElement})] = &ExprParser::Reduce_ArrayElementList__ArrayElementList_comma_ArrayElement;
  map[Production(expr::ArrayInitializer, {expr::l_brace, expr::r_brace})] = &ExprParser::Reduce_ArrayInitializer__l_brace_r_brace;
  map[Production(expr::ArrayInitializer, {expr::l_brace, expr::ArrayElementList, expr::r_brace})] = &ExprParser::Reduce_ArrayInitializer__l_brace_ArrayElementList_r_brace;
  map[Production(expr::NonVirtualCallName, {expr::nonvirtual_, expr::identifier})] = &ExprParser::Reduce_NonVirtualCallName__nonvirtual_identifier;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::plus})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::minus})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::exclaim})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::star})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::slash})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::percent})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::less})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::lessequal})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::greater})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::greaterequal})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::equalequal})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::exclaimequal})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::equal})] = &ExprParser::Reduce_OperatorFunctionName__operator_operator;
  map[Production(expr::OperatorFunctionName, {expr::operator_, expr::l_paren, expr::r_paren})] = &ExprParser::Reduce_OperatorFunctionName__operator_l_paren_r_paren;
  map[Production(expr::PrimaryExpr, {expr::ID})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::PrimaryExpr, {expr::integer_literal})] = &ExprParser::Reduce_PrimaryExpr__integer_literal;
  map[Production(expr::PrimaryExpr, {expr::character_literal})] = &ExprParser::Reduce_PrimaryExpr__character_literal;
  map[Production(expr::PrimaryExpr, {expr::float_literal})] = &ExprParser::Reduce_PrimaryExpr__float_literal;
  map[Production(expr::PrimaryExpr, {expr::bool_literal})] = &ExprParser::Reduce_PrimaryExpr__bool_literal;
  map[Production(expr::PrimaryExpr, {expr::null_literal})] = &ExprParser::Reduce_PrimaryExpr__null_literal;
  map[Production(expr::PrimaryExpr, {expr::StringLiterals})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::PrimaryExpr, {expr::this_})] = &ExprParser::Reduce_PrimaryExpr__this;
  map[Production(expr::PrimaryExpr, {expr::l_paren, expr::Expr, expr::r_paren})] = &ExprParser::Reduce_PrimaryExpr__l_paren_Expr_r_paren;
  map[Production(expr::PrimaryExpr, {expr::type, expr::ArrayInitializer})] = &ExprParser::Reduce_PrimaryExpr__type_ArrayInitializer;
  map[Production(expr::PostfixExpr, {expr::PrimaryExpr})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::PostfixExpr, {expr::OperatorFunctionName, expr::ParenthesizedArgumentList})] =
      &ExprParser::Reduce_PostfixExpr__PostfixExpr_ParenthesizedArgumentList;
  map[Production(expr::PostfixExpr, {expr::PostfixExpr, expr::ParenthesizedArgumentList})] = &ExprParser::Reduce_PostfixExpr__PostfixExpr_ParenthesizedArgumentList;
  map[Production(expr::PostfixExpr, {expr::PostfixExpr, expr::period, expr::identifier})] = &ExprParser::Reduce_PostfixExpr__PostfixExpr_access_identifier;
  map[Production(expr::PostfixExpr, {expr::PostfixExpr, expr::arrow, expr::identifier})] = &ExprParser::Reduce_PostfixExpr__PostfixExpr_access_identifier;
  map[Production(expr::PostfixExpr, {expr::PostfixExpr, expr::period, expr::NonVirtualCallName, expr::ParenthesizedArgumentList})] = &ExprParser::Reduce_PostfixExpr__PostfixExpr_access_NonVirtualCallName_ParenthesizedArgumentList;
  map[Production(expr::PostfixExpr, {expr::PostfixExpr, expr::arrow, expr::NonVirtualCallName, expr::ParenthesizedArgumentList})] = &ExprParser::Reduce_PostfixExpr__PostfixExpr_access_NonVirtualCallName_ParenthesizedArgumentList;
  map[Production(expr::PostfixExpr, {expr::PostfixExpr, expr::l_square, expr::Expr, expr::r_square})] = &ExprParser::Reduce_PostfixExpr__PostfixExpr_l_square_Expr_r_square;
  map[Production(expr::PostfixExpr, {expr::PostfixExpr, expr::plusplus})] = &ExprParser::Reduce_PostfixExpr__PostfixExpr_postfix_operator;
  map[Production(expr::PostfixExpr, {expr::PostfixExpr, expr::minusminus})] = &ExprParser::Reduce_PostfixExpr__PostfixExpr_postfix_operator;
  map[Production(expr::PostfixExpr, {expr::ctor_, expr::l_paren, expr::Expr, expr::r_paren, expr::identifier, expr::ParenthesizedArgumentList})] = &ExprParser::Reduce_PostfixExpr__ctor_l_paren_Expr_r_paren_identifier_ParenthesizedArgumentList;
  map[Production(expr::PostfixExpr, {expr::dtor_, expr::l_paren, expr::Expr, expr::r_paren, expr::identifier, expr::l_paren, expr::r_paren})] = &ExprParser::Reduce_PostfixExpr__dtor_l_paren_Expr_r_paren_identifier_l_paren_r_paren;
  map[Production(expr::PostfixExpr, {expr::NonVirtualCallName, expr::ParenthesizedArgumentList})] = &ExprParser::Reduce_PostfixExpr__NonVirtualCallName_ParenthesizedArgumentList;
  map[Production(expr::T3, {expr::PostfixExpr})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T3, {expr::plusplus, expr::T3})] = &ExprParser::Reduce_T3__plusplus_T3;
  map[Production(expr::T3, {expr::minusminus, expr::T3})] = &ExprParser::Reduce_T3__minusminus_T3;
  map[Production(expr::T3, {expr::plus, expr::T3})] = &ExprParser::Reduce_T3__plus_T3;
  map[Production(expr::T3, {expr::minus, expr::T3})] = &ExprParser::Reduce_T3__minus_T3;
  map[Production(expr::T3, {expr::exclaim, expr::T3})] = &ExprParser::Reduce_T3__exclaim_T3;
  map[Production(expr::T3, {expr::tilde, expr::T3})] = &ExprParser::Reduce_T3__tilde_T3;
  map[Production(expr::T3, {expr::star, expr::T3})] = &ExprParser::Reduce_T3__star_T3;
  map[Production(expr::T3, {expr::amp, expr::T3})] = &ExprParser::Reduce_T3__amp_T3;
  map[Production(expr::T3, {expr::amp, expr::OperatorFunctionName})] = &ExprParser::Reduce_T3__amp_OperatorFunctionName;
  map[Production(expr::T3, {expr::move_, expr::T3})] = &ExprParser::Reduce_T3__move_T3;
  map[Production(expr::T4, {expr::T3})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T5, {expr::T4})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T5, {expr::T5, expr::star, expr::T4})] = &ExprParser::Reduce_T5__T5_star_T4;
  map[Production(expr::T5, {expr::T5, expr::slash, expr::T4})] = &ExprParser::Reduce_T5__T5_slash_T4;
  map[Production(expr::T5, {expr::T5, expr::percent, expr::T4})] = &ExprParser::Reduce_T5__T5_percent_T4;
  map[Production(expr::T6, {expr::T5})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T6, {expr::T6, expr::plus, expr::T5})] = &ExprParser::Reduce_T6__T6_plus_T5;
  map[Production(expr::T6, {expr::T6, expr::minus, expr::T5})] = &ExprParser::Reduce_T6__T6_minus_T5;
  map[Production(expr::T7, {expr::T6})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T7, {expr::T7, expr::lessless, expr::T6})] = &ExprParser::Reduce_T7__T7_lessless_T6;
  map[Production(expr::T7, {expr::T7, expr::greatergreater, expr::T6})] = &ExprParser::Reduce_T7__T7_greatergreater_T6;
  map[Production(expr::T8, {expr::T7})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T9, {expr::T8})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T9, {expr::T9, expr::less, expr::T8})] = &ExprParser::Reduce_T9__T9_less_T8;
  map[Production(expr::T9, {expr::T9, expr::lessequal, expr::T8})] = &ExprParser::Reduce_T9__T9_lessequal_T8;
  map[Production(expr::T9, {expr::T9, expr::greater, expr::T8})] = &ExprParser::Reduce_T9__T9_greater_T8;
  map[Production(expr::T9, {expr::T9, expr::greaterequal, expr::T8})] = &ExprParser::Reduce_T9__T9_greaterequal_T8;
  map[Production(expr::T10, {expr::T9})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T10, {expr::T10, expr::equalequal, expr::T9})] = &ExprParser::Reduce_T10__T10_equalequal_T9;
  map[Production(expr::T10, {expr::T10, expr::exclaimequal, expr::T9})] = &ExprParser::Reduce_T10__T10_exclaimequal_T9;
  map[Production(expr::T11, {expr::T10})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T11, {expr::T11, expr::amp, expr::T10})] = &ExprParser::Reduce_T11__T11_amp_T10;
  map[Production(expr::T12, {expr::T11})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T12, {expr::T12, expr::caret, expr::T11})] = &ExprParser::Reduce_T12__T12_caret_T11;
  map[Production(expr::T13, {expr::T12})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T13, {expr::T13, expr::pipe, expr::T12})] = &ExprParser::Reduce_T13__T13_pipe_T12;
  map[Production(expr::T14, {expr::T13})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T14, {expr::T14, expr::ampamp, expr::T13})] = &ExprParser::Reduce_T14__T14_ampamp_T13;
  map[Production(expr::T15, {expr::T14})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T15, {expr::T15, expr::pipepipe, expr::T14})] = &ExprParser::Reduce_T15__T15_pipepipe_T14;
  map[Production(expr::T16, {expr::T15})] = &ExprParser::Reduce_PassThrough;
  map[Production(expr::T16, {expr::T15, expr::question, expr::T16, expr::colon, expr::T16})] = &ExprParser::Reduce_T16__T15_question_T16_colon_T16;
  map[Production(expr::T16, {expr::T15, expr::colonequal, expr::T16})] = &ExprParser::Reduce_T16__T15_colonequal_T16;
  map[Production(expr::T16, {expr::T15, expr::equal, expr::T16})] = &ExprParser::Reduce_T16__T15_equal_T16;
  map[Production(expr::T16, {expr::T15, expr::plusequal, expr::T16})] = &ExprParser::Reduce_T16__T15_plusequal_T16;
  map[Production(expr::T16, {expr::T15, expr::minusequal, expr::T16})] = &ExprParser::Reduce_T16__T15_minusequal_T16;
  map[Production(expr::T16, {expr::T15, expr::starequal, expr::T16})] = &ExprParser::Reduce_T16__T15_starequal_T16;
  map[Production(expr::T16, {expr::T15, expr::slashequal, expr::T16})] = &ExprParser::Reduce_T16__T15_slashequal_T16;
  map[Production(expr::T16, {expr::T15, expr::percentequal, expr::T16})] = &ExprParser::Reduce_T16__T15_percentequal_T16;
  map[Production(expr::T16, {expr::T15, expr::lesslessequal, expr::T16})] = &ExprParser::Reduce_T16__T15_lesslessequal_T16;
  map[Production(expr::T16, {expr::T15, expr::greatergreaterequal, expr::T16})] = &ExprParser::Reduce_T16__T15_greatergreaterequal_T16;
  map[Production(expr::T16, {expr::T15, expr::ampequal, expr::T16})] = &ExprParser::Reduce_T16__T15_ampequal_T16;
  map[Production(expr::T16, {expr::T15, expr::caretequal, expr::T16})] = &ExprParser::Reduce_T16__T15_caretequal_T16;
  map[Production(expr::T16, {expr::T15, expr::pipeequal, expr::T16})] = &ExprParser::Reduce_T16__T15_pipeequal_T16;
  // clang-format on

  lang::ProductionTransform<int, expr::ExprGrammarSymbol> transform;
  real_reduce_functions_.resize(grammar_.NumProductions());
  for (int production_id = 0; production_id < grammar_.NumProductions(); ++production_id) {
    real_reduce_functions_[production_id] = map[transform(grammar_.P(production_id))];
    if (real_reduce_functions_[production_id]) {
      continue;
    }

    std::cerr << "Reduce function not found for production ";
    grammar_.DumpProduction(std::cerr, production_id);
    std::cerr << std::endl;
    throw std::logic_error("Reduce function not found for production");
  }
}

int ExprParser::Reduce_PassThrough() { return kHandleSymbolResultReduce; }

int ExprParser::Reduce_StringLiterals__string_literal() {
  auto& symbol = real_symbol_stack_.back();
  auto& token = std::get<Token>(symbol.value);
  if (!std::holds_alternative<StringProperty>(token.property)) {
    return kHandleSymbolResultError;
  }

  auto literal = std::make_unique<StringLiteral>();
  literal->range = token.range;
  literal->value = std::get<StringProperty>(token.property).value;
  symbol.value = std::unique_ptr<Expr>(std::move(literal));
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_StringLiterals__StringLiterals_string_literal() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 2);
  auto& literal = std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 2].value);
  auto& token = std::get<Token>(real_symbol_stack_.back().value);
  if (!std::holds_alternative<StringProperty>(token.property)) {
    return kHandleSymbolResultError;
  }

  auto* string_literal = dynamic_cast<StringLiteral*>(literal.get());
  BOOST_ASSERT(string_literal);
  string_literal->value += std::get<StringProperty>(token.property).value;
  string_literal->range.end = token.range.end;
  real_symbol_stack_.pop_back();
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_ArgumentList__T16() {
  auto& symbol = real_symbol_stack_.back();
  auto expression = std::move(std::get<std::unique_ptr<Expr>>(symbol.value));
  ParsedArgumentList arguments;
  arguments.range = expression->range;
  arguments.arguments.push_back(std::move(expression));
  symbol.value = std::move(arguments);
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_ArgumentList__ArgumentList_comma_T16() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 3);
  auto& arguments = std::get<ParsedArgumentList>(real_symbol_stack_[real_symbol_stack_.size() - 3].value);
  auto expression = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_.back().value));
  arguments.range.end = expression->range.end;
  arguments.arguments.push_back(std::move(expression));
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_ParenthesizedArgumentList__l_paren_r_paren() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 2);
  const auto& left = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 2].value);
  const auto& right = std::get<Token>(real_symbol_stack_.back().value);
  ParsedArgumentList arguments;
  arguments.range = {left.range.begin, right.range.end};
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::move(arguments)});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_ParenthesizedArgumentList__l_paren_ArgumentList_r_paren() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 3);
  const auto& left = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 3].value);
  auto arguments = std::move(std::get<ParsedArgumentList>(real_symbol_stack_[real_symbol_stack_.size() - 2].value));
  const auto& right = std::get<Token>(real_symbol_stack_.back().value);
  arguments.range = {left.range.begin, right.range.end};
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::move(arguments)});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_ArrayElementList__ArrayElement() {
  auto& symbol = real_symbol_stack_.back();
  ParsedArrayElements elements;
  elements.elements.push_back(std::move(std::get<std::unique_ptr<Expr>>(symbol.value)));
  symbol.value = std::move(elements);
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_ArrayElementList__ArrayElementList_comma_ArrayElement() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 3);
  auto& elements = std::get<ParsedArrayElements>(real_symbol_stack_[real_symbol_stack_.size() - 3].value);
  elements.elements.push_back(std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_.back().value)));
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_ArrayInitializer__l_brace_r_brace() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 2);
  const auto& left = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 2].value);
  const auto& right = std::get<Token>(real_symbol_stack_.back().value);

  auto value = std::make_unique<ArrayValueExpr>();
  value->range = {left.range.begin, right.range.end};
  value->left_brace_range = left.range;
  value->right_brace_range = right.range;
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(value))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_ArrayInitializer__l_brace_ArrayElementList_r_brace() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 3);
  const auto& left = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 3].value);
  auto elements = std::move(std::get<ParsedArrayElements>(real_symbol_stack_[real_symbol_stack_.size() - 2].value));
  const auto& right = std::get<Token>(real_symbol_stack_.back().value);

  auto value = std::make_unique<ArrayValueExpr>();
  value->range = {left.range.begin, right.range.end};
  value->left_brace_range = left.range;
  value->right_brace_range = right.range;
  value->Elements = std::move(elements.elements);
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(value))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PrimaryExpr__type_ArrayInitializer() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 2);
  auto type = std::move(std::get<std::unique_ptr<TypeSyntax>>(real_symbol_stack_[real_symbol_stack_.size() - 2].value));
  auto value = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_.back().value));
  if (!type || type->GetKind() != NodeKind::ArrayTypeSyntax) {
    return kHandleSymbolResultError;
  }
  BOOST_ASSERT(value && value->GetKind() == NodeKind::ArrayValueExpr);
  auto& array_value = static_cast<ArrayValueExpr&>(*value);
  array_value.range.begin = type->range.begin;
  array_value.contains_errors |= type->ContainsErrors();
  array_value.Type.reset(static_cast<ArrayTypeSyntax*>(type.release()));
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::move(value)});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_NonVirtualCallName__nonvirtual_identifier() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 2);
  const auto& keyword = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 2].value);
  const auto& identifier = std::get<Token>(real_symbol_stack_.back().value);
  if (!std::holds_alternative<IdentifierProperty>(identifier.property)) {
    return kHandleSymbolResultError;
  }

  ParsedNonVirtualCallName name;
  name.name = std::get<IdentifierProperty>(identifier.property).name;
  name.name_range = identifier.range;
  name.keyword_range = keyword.range;
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::move(name)});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_OperatorFunctionName__operator_operator() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 2);
  const auto& keyword = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 2].value);
  const auto& operation = std::get<Token>(real_symbol_stack_.back().value);

  auto reference = std::make_unique<DeclRefExpr>();
  reference->range = {keyword.range.begin, operation.range.end};
  reference->name = expr::to_string(static_cast<expr::ExprGrammarSymbol>(operation.type));
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(reference))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_OperatorFunctionName__operator_l_paren_r_paren() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 3);
  const auto& keyword = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 3].value);
  const auto& closing_parenthesis = std::get<Token>(real_symbol_stack_.back().value);

  auto reference = std::make_unique<DeclRefExpr>();
  reference->range = {keyword.range.begin, closing_parenthesis.range.end};
  reference->name = "()";
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(reference))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_ID__identifier() {
  auto& symbol = real_symbol_stack_.back();
  auto& token = std::get<Token>(symbol.value);
  if (!std::holds_alternative<IdentifierProperty>(token.property)) {
    return kHandleSymbolResultError;
  }

  auto reference = std::make_unique<DeclRefExpr>();
  reference->range = token.range;
  reference->name = std::get<IdentifierProperty>(token.property).name;
  symbol.value = std::unique_ptr<Expr>(std::move(reference));
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PrimaryExpr__null_literal() {
  auto& symbol = real_symbol_stack_.back();
  const auto& token = std::get<Token>(symbol.value);
  auto literal = std::make_unique<NullLiteral>();
  literal->range = token.range;
  symbol.value = std::unique_ptr<Expr>(std::move(literal));
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PrimaryExpr__integer_literal() {
  auto& symbol = real_symbol_stack_.back();
  auto& token = std::get<Token>(symbol.value);
  if (!std::holds_alternative<IntegerProperty>(token.property)) {
    return kHandleSymbolResultError;
  }

  auto literal = std::make_unique<IntegerLiteral>();
  literal->range = token.range;
  literal->value = std::move(std::get<IntegerProperty>(token.property).value);
  symbol.value = std::unique_ptr<Expr>(std::move(literal));
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PrimaryExpr__character_literal() {
  auto& symbol = real_symbol_stack_.back();
  auto& token = std::get<Token>(symbol.value);
  if (!std::holds_alternative<CharacterProperty>(token.property)) {
    return kHandleSymbolResultError;
  }

  auto literal = std::make_unique<CharacterLiteral>();
  literal->range = token.range;
  literal->value = std::get<CharacterProperty>(token.property).value;
  symbol.value = std::unique_ptr<Expr>(std::move(literal));
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PrimaryExpr__float_literal() {
  auto& symbol = real_symbol_stack_.back();
  auto& token = std::get<Token>(symbol.value);
  if (!std::holds_alternative<FloatProperty>(token.property)) {
    return kHandleSymbolResultError;
  }
  auto& property = std::get<FloatProperty>(token.property);
  if (std::holds_alternative<std::monostate>(property.value)) {
    return kHandleSymbolResultError;
  }

  auto literal = std::make_unique<FloatLiteral>();
  literal->range = token.range;
  std::visit(
      [&](auto value) {
        using Value = decltype(value);
        if constexpr (!std::is_same_v<Value, std::monostate>) {
          literal->value = value;
        }
      },
      property.value);
  symbol.value = std::unique_ptr<Expr>(std::move(literal));
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PrimaryExpr__bool_literal() {
  auto& symbol = real_symbol_stack_.back();
  auto& token = std::get<Token>(symbol.value);
  if (!std::holds_alternative<BoolProperty>(token.property)) {
    return kHandleSymbolResultError;
  }

  auto literal = std::make_unique<BoolLiteral>();
  literal->range = token.range;
  literal->value = std::get<BoolProperty>(token.property).value;
  symbol.value = std::unique_ptr<Expr>(std::move(literal));
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PrimaryExpr__this() {
  auto& symbol = real_symbol_stack_.back();
  const auto& token = std::get<Token>(symbol.value);
  auto reference = std::make_unique<DeclRefExpr>();
  reference->range = token.range;
  reference->name = "this";
  symbol.value = std::unique_ptr<Expr>(std::move(reference));
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PrimaryExpr__l_paren_Expr_r_paren() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 3);
  const auto& left = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 3].value);
  auto subexpression =
      std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 2].value));
  const auto& right = std::get<Token>(real_symbol_stack_.back().value);

  auto parentheses = std::make_unique<ParenExpr>();
  parentheses->range = {left.range.begin, right.range.end};
  parentheses->left_paren_range = left.range;
  parentheses->right_paren_range = right.range;
  parentheses->SubExpr = std::move(subexpression);
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(parentheses))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PostfixExpr__PostfixExpr_ParenthesizedArgumentList() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 2);
  auto callee = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 2].value));
  auto arguments = std::move(std::get<ParsedArgumentList>(real_symbol_stack_.back().value));

  std::unique_ptr<Expr> result;
  if (callee->GetKind() == NodeKind::MemberExpr) {
    std::unique_ptr<MemberExpr> member(static_cast<MemberExpr*>(callee.release()));
    auto named_callee = std::make_unique<DeclRefExpr>();
    named_callee->range = member->member_range;
    named_callee->name = member->member;

    auto call = std::make_unique<ReceiverCallExpr>();
    call->range = {member->range.begin, arguments.range.end};
    call->Receiver = std::move(member->Base);
    call->operator_range = member->operator_range;
    call->op = member->op;
    call->Callee = std::move(named_callee);
    call->Args = std::move(arguments.arguments);
    result = std::move(call);
  } else {
    auto call = std::make_unique<CallExpr>();
    call->range = {callee->range.begin, arguments.range.end};
    call->Callee = std::move(callee);
    call->Args = std::move(arguments.arguments);
    result = std::move(call);
  }

  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::move(result)});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PostfixExpr__PostfixExpr_access_identifier() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 3);
  auto base = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 3].value));
  const auto& access = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 2].value);
  const auto& identifier = std::get<Token>(real_symbol_stack_.back().value);
  if (!std::holds_alternative<IdentifierProperty>(identifier.property)) {
    return kHandleSymbolResultError;
  }

  auto member = std::make_unique<MemberExpr>();
  member->range = {base->range.begin, identifier.range.end};
  member->Base = std::move(base);
  member->member = std::get<IdentifierProperty>(identifier.property).name;
  member->member_range = identifier.range;
  member->operator_range = access.range;
  member->op = static_cast<expr::ExprGrammarSymbol>(access.type);
  BOOST_ASSERT(member->op == expr::period || member->op == expr::arrow);

  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(member))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PostfixExpr__PostfixExpr_access_NonVirtualCallName_ParenthesizedArgumentList() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 4);
  auto receiver = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 4].value));
  const auto& access = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 3].value);
  auto name = std::move(std::get<ParsedNonVirtualCallName>(real_symbol_stack_[real_symbol_stack_.size() - 2].value));
  auto arguments = std::move(std::get<ParsedArgumentList>(real_symbol_stack_.back().value));

  auto callee = std::make_unique<DeclRefExpr>();
  callee->range = name.name_range;
  callee->name = std::move(name.name);
  auto call = std::make_unique<ReceiverCallExpr>();
  call->range = {receiver->range.begin, arguments.range.end};
  call->Receiver = std::move(receiver);
  call->operator_range = access.range;
  call->op = static_cast<expr::ExprGrammarSymbol>(access.type);
  BOOST_ASSERT(call->op == expr::period || call->op == expr::arrow);
  call->Callee = std::move(callee);
  call->Args = std::move(arguments.arguments);
  call->is_nonvirtual = true;
  call->nonvirtual_range = name.keyword_range;

  for (int index = 0; index < 4; ++index) real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(call))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PostfixExpr__PostfixExpr_l_square_Expr_r_square() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 4);
  auto base = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 4].value));
  auto index = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 2].value));
  const auto& right = std::get<Token>(real_symbol_stack_.back().value);

  auto subscript = std::make_unique<SubscriptExpr>();
  subscript->range = {base->range.begin, right.range.end};
  subscript->Base = std::move(base);
  subscript->Index = std::move(index);
  for (int count = 0; count < 4; ++count) real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(subscript))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PostfixExpr__PostfixExpr_postfix_operator() { return Reduce_UnaryOperator(); }

int ExprParser::Reduce_PostfixExpr__ctor_l_paren_Expr_r_paren_identifier_ParenthesizedArgumentList() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 6);
  const auto& keyword = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 6].value);
  auto target = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 4].value));
  const auto& identifier = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 2].value);
  auto arguments = std::move(std::get<ParsedArgumentList>(real_symbol_stack_.back().value));
  if (!std::holds_alternative<IdentifierProperty>(identifier.property)) {
    return kHandleSymbolResultError;
  }

  auto construction = std::make_unique<ConstructionExpr>();
  construction->range = {keyword.range.begin, arguments.range.end};
  construction->target_name = std::get<IdentifierProperty>(identifier.property).name;
  construction->target_name_range = identifier.range;
  construction->TargetAddress = std::move(target);
  construction->Args = std::move(arguments.arguments);
  for (int count = 0; count < 6; ++count) real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(construction))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PostfixExpr__dtor_l_paren_Expr_r_paren_identifier_l_paren_r_paren() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 7);
  const auto& keyword = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 7].value);
  auto target = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 5].value));
  const auto& identifier = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 3].value);
  const auto& right = std::get<Token>(real_symbol_stack_.back().value);
  if (!std::holds_alternative<IdentifierProperty>(identifier.property)) {
    return kHandleSymbolResultError;
  }

  auto callee = std::make_unique<DeclRefExpr>();
  callee->range = identifier.range;
  callee->name = std::get<IdentifierProperty>(identifier.property).name;
  auto call = std::make_unique<DestructorCallExpr>();
  call->range = {keyword.range.begin, right.range.end};
  call->TargetAddress = std::move(target);
  call->Callee = std::move(callee);
  for (int count = 0; count < 7; ++count) real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(call))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_PostfixExpr__NonVirtualCallName_ParenthesizedArgumentList() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 2);
  auto name = std::move(std::get<ParsedNonVirtualCallName>(real_symbol_stack_[real_symbol_stack_.size() - 2].value));
  auto arguments = std::move(std::get<ParsedArgumentList>(real_symbol_stack_.back().value));

  auto callee = std::make_unique<DeclRefExpr>();
  callee->range = name.name_range;
  callee->name = std::move(name.name);
  auto call = std::make_unique<CallExpr>();
  call->range = {name.keyword_range.begin, arguments.range.end};
  call->Callee = std::move(callee);
  call->Args = std::move(arguments.arguments);
  call->is_nonvirtual = true;
  call->nonvirtual_range = name.keyword_range;
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(call))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_T3__plusplus_T3() { return Reduce_UnaryOperator(); }
int ExprParser::Reduce_T3__minusminus_T3() { return Reduce_UnaryOperator(); }
int ExprParser::Reduce_T3__plus_T3() { return Reduce_UnaryOperator(); }
int ExprParser::Reduce_T3__minus_T3() { return Reduce_UnaryOperator(); }
int ExprParser::Reduce_T3__exclaim_T3() { return Reduce_UnaryOperator(); }
int ExprParser::Reduce_T3__tilde_T3() { return Reduce_UnaryOperator(); }
int ExprParser::Reduce_T3__star_T3() { return Reduce_UnaryOperator(); }
int ExprParser::Reduce_T3__amp_T3() { return Reduce_UnaryOperator(); }
int ExprParser::Reduce_T3__amp_OperatorFunctionName() { return Reduce_UnaryOperator(); }
int ExprParser::Reduce_T3__move_T3() { return Reduce_UnaryOperator(); }
int ExprParser::Reduce_T5__T5_star_T4() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T5__T5_slash_T4() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T5__T5_percent_T4() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T6__T6_plus_T5() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T6__T6_minus_T5() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T7__T7_lessless_T6() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T7__T7_greatergreater_T6() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T9__T9_less_T8() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T9__T9_lessequal_T8() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T9__T9_greater_T8() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T9__T9_greaterequal_T8() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T10__T10_equalequal_T9() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T10__T10_exclaimequal_T9() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T11__T11_amp_T10() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T12__T12_caret_T11() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T13__T13_pipe_T12() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T14__T14_ampamp_T13() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T15__T15_pipepipe_T14() { return Reduce_BinaryOperator(); }

int ExprParser::Reduce_T16__T15_question_T16_colon_T16() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 5);
  auto condition = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 5].value));
  auto then_expression =
      std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 3].value));
  auto else_expression = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_.back().value));

  auto conditional = std::make_unique<ConditionalOperator>();
  conditional->range = {condition->range.begin, else_expression->range.end};
  conditional->Cond = std::move(condition);
  conditional->Then = std::move(then_expression);
  conditional->Else = std::move(else_expression);
  for (int count = 0; count < 5; ++count) real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(conditional))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_T16__T15_colonequal_T16() { return Reduce_InitializationExpr(); }
int ExprParser::Reduce_T16__T15_equal_T16() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T16__T15_plusequal_T16() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T16__T15_minusequal_T16() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T16__T15_starequal_T16() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T16__T15_slashequal_T16() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T16__T15_percentequal_T16() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T16__T15_lesslessequal_T16() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T16__T15_greatergreaterequal_T16() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T16__T15_ampequal_T16() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T16__T15_caretequal_T16() { return Reduce_BinaryOperator(); }
int ExprParser::Reduce_T16__T15_pipeequal_T16() { return Reduce_BinaryOperator(); }

int ExprParser::Reduce_UnaryOperator() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 2);
  auto& first = real_symbol_stack_[real_symbol_stack_.size() - 2];
  auto& second = real_symbol_stack_.back();
  const bool is_postfix = std::holds_alternative<Token>(second.value);

  auto unary = std::make_unique<UnaryOperator>();
  unary->is_postfix = is_postfix;
  if (is_postfix) {
    auto operand = std::move(std::get<std::unique_ptr<Expr>>(first.value));
    const auto& operation = std::get<Token>(second.value);
    unary->range = {operand->range.begin, operation.range.end};
    unary->op = static_cast<expr::ExprGrammarSymbol>(operation.type);
    unary->operator_range = operation.range;
    unary->Operand = std::move(operand);
  } else {
    const auto& operation = std::get<Token>(first.value);
    auto operand = std::move(std::get<std::unique_ptr<Expr>>(second.value));
    unary->range = {operation.range.begin, operand->range.end};
    unary->op = static_cast<expr::ExprGrammarSymbol>(operation.type);
    unary->operator_range = operation.range;
    unary->Operand = std::move(operand);
  }

  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(unary))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_BinaryOperator() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 3);
  auto left = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 3].value));
  const auto& operation = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 2].value);
  auto right = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_.back().value));

  auto binary = std::make_unique<BinaryOperator>();
  binary->range = {left->range.begin, right->range.end};
  binary->LHS = std::move(left);
  binary->op = static_cast<expr::ExprGrammarSymbol>(operation.type);
  binary->operator_range = operation.range;
  binary->RHS = std::move(right);
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(binary))});
  return kHandleSymbolResultReduce;
}

int ExprParser::Reduce_InitializationExpr() {
  BOOST_ASSERT(real_symbol_stack_.size() >= 3);
  auto target = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_[real_symbol_stack_.size() - 3].value));
  const auto& operation = std::get<Token>(real_symbol_stack_[real_symbol_stack_.size() - 2].value);
  auto source = std::move(std::get<std::unique_ptr<Expr>>(real_symbol_stack_.back().value));
  BOOST_ASSERT(operation.type == tok::colonequal);

  auto initialization = std::make_unique<InitializationExpr>();
  initialization->range = {target->range.begin, source->range.end};
  initialization->Target = std::move(target);
  initialization->Source = std::move(source);
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.pop_back();
  real_symbol_stack_.emplace_back(SymbolValue{std::unique_ptr<Expr>(std::move(initialization))});
  return kHandleSymbolResultReduce;
}

}  // namespace cw
