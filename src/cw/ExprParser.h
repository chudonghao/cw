/// \file ExprParser.h
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <memory>
#include <string>
#include <variant>
#include <vector>

#include "Token.h"
#include "lang/LRStateMachine.h"

namespace cw {

class Lexer;
struct Expr;
class DiagnosticEngine;
class Parser;
struct TypeSyntax;

class ExprParser : public lang::LRStateMachine {
  struct ParsedArgumentList {
    std::vector<std::unique_ptr<Expr>> arguments;
    SourceRange range{};
  };

  struct ParsedNonVirtualCallName {
    std::string name;
    SourceRange name_range{};
    SourceRange keyword_range{};
  };

  struct ParsedArrayElements {
    std::vector<std::unique_ptr<Expr>> elements;
  };

  using SymbolValue = std::variant<std::monostate, Token, std::unique_ptr<Expr>, std::unique_ptr<TypeSyntax>,
                                   ParsedArgumentList, ParsedNonVirtualCallName, ParsedArrayElements>;

  struct StackSymbol {
    SymbolValue value;

    explicit StackSymbol(SymbolValue value = {}) : value(std::move(value)) {}
  };

  /// Reduction handlers indexed by grammar production.
  std::vector<int (ExprParser::*)()> real_reduce_functions_;

  Parser* parent_{};
  Lexer* lexer_{};
  DiagnosticEngine* diagnostic_engine_{};

  /// Semantic values kept in step with the LR symbol stack.
  std::vector<StackSymbol> real_symbol_stack_;
  std::unique_ptr<TypeSyntax> pending_type_;

 public:
  ExprParser(Parser* parent);
  ~ExprParser();

  std::unique_ptr<Expr> operator()();

 protected:
  void Reset() override;

  int OnReduced(int production_id, int state, int symbol) override;

  int OnErrored(int state, int symbol) override;

  int OnShifted(int state, int symbol) override;

  int OnAccepted() override;

 private:
  void AdvanceLexer();

  void ReportError(int state);

  std::vector<tok::TokenType> ExpectedTokens(int state) const;

  void HandleExpect(std::vector<tok::TokenType> expected);

  void SetupRealReduceFunctions();

  // Reduce functions
  int Reduce_PassThrough();
  int Reduce_StringLiterals__string_literal();
  int Reduce_StringLiterals__StringLiterals_string_literal();
  int Reduce_ArgumentList__T16();
  int Reduce_ArgumentList__ArgumentList_comma_T16();
  int Reduce_ParenthesizedArgumentList__l_paren_r_paren();
  int Reduce_ParenthesizedArgumentList__l_paren_ArgumentList_r_paren();
  int Reduce_ArrayElementList__ArrayElement();
  int Reduce_ArrayElementList__ArrayElementList_comma_ArrayElement();
  int Reduce_ArrayInitializer__l_brace_r_brace();
  int Reduce_ArrayInitializer__l_brace_ArrayElementList_r_brace();
  int Reduce_PrimaryExpr__type_ArrayInitializer();
  int Reduce_NonVirtualCallName__nonvirtual_identifier();
  int Reduce_OperatorFunctionName__operator_operator();
  int Reduce_OperatorFunctionName__operator_l_paren_r_paren();
  int Reduce_ID__identifier();
  int Reduce_PrimaryExpr__null_literal();
  int Reduce_PrimaryExpr__integer_literal();
  int Reduce_PrimaryExpr__character_literal();
  int Reduce_PrimaryExpr__float_literal();
  int Reduce_PrimaryExpr__bool_literal();
  int Reduce_PrimaryExpr__this();
  int Reduce_PrimaryExpr__l_paren_Expr_r_paren();
  int Reduce_PostfixExpr__PostfixExpr_ParenthesizedArgumentList();
  int Reduce_PostfixExpr__PostfixExpr_access_identifier();
  int Reduce_PostfixExpr__PostfixExpr_access_NonVirtualCallName_ParenthesizedArgumentList();
  int Reduce_PostfixExpr__PostfixExpr_l_square_Expr_r_square();
  int Reduce_PostfixExpr__PostfixExpr_postfix_operator();
  int Reduce_PostfixExpr__ctor_l_paren_Expr_r_paren_identifier_ParenthesizedArgumentList();
  int Reduce_PostfixExpr__dtor_l_paren_Expr_r_paren_identifier_l_paren_r_paren();
  int Reduce_PostfixExpr__NonVirtualCallName_ParenthesizedArgumentList();
  int Reduce_T3__plusplus_T3();
  int Reduce_T3__minusminus_T3();
  int Reduce_T3__plus_T3();
  int Reduce_T3__minus_T3();
  int Reduce_T3__exclaim_T3();
  int Reduce_T3__tilde_T3();
  int Reduce_T3__star_T3();
  int Reduce_T3__amp_T3();
  int Reduce_T3__amp_OperatorFunctionName();
  int Reduce_T3__move_T3();
  int Reduce_T5__T5_star_T4();
  int Reduce_T5__T5_slash_T4();
  int Reduce_T5__T5_percent_T4();
  int Reduce_T6__T6_plus_T5();
  int Reduce_T6__T6_minus_T5();
  int Reduce_T7__T7_lessless_T6();
  int Reduce_T7__T7_greatergreater_T6();
  int Reduce_T9__T9_less_T8();
  int Reduce_T9__T9_lessequal_T8();
  int Reduce_T9__T9_greater_T8();
  int Reduce_T9__T9_greaterequal_T8();
  int Reduce_T10__T10_equalequal_T9();
  int Reduce_T10__T10_exclaimequal_T9();
  int Reduce_T11__T11_amp_T10();
  int Reduce_T12__T12_caret_T11();
  int Reduce_T13__T13_pipe_T12();
  int Reduce_T14__T14_ampamp_T13();
  int Reduce_T15__T15_pipepipe_T14();
  int Reduce_T16__T15_question_T16_colon_T16();
  int Reduce_T16__T15_colonequal_T16();
  int Reduce_T16__T15_equal_T16();
  int Reduce_T16__T15_plusequal_T16();
  int Reduce_T16__T15_minusequal_T16();
  int Reduce_T16__T15_starequal_T16();
  int Reduce_T16__T15_slashequal_T16();
  int Reduce_T16__T15_percentequal_T16();
  int Reduce_T16__T15_lesslessequal_T16();
  int Reduce_T16__T15_greatergreaterequal_T16();
  int Reduce_T16__T15_ampequal_T16();
  int Reduce_T16__T15_caretequal_T16();
  int Reduce_T16__T15_pipeequal_T16();

  // Reusable reduce functions
  int Reduce_UnaryOperator();
  int Reduce_BinaryOperator();
  int Reduce_InitializationExpr();
};

}  // namespace cw
