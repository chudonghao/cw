/// \file Parser.h
/// \author Donghao Chu
/// \date 2025/01/07
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <memory>

#include "Token.h"
#include "ast.h"

namespace cw {

class Lexer;
class DiagnosticEngine;

class Parser {
  Lexer* lexer_{};

  TokenLocation parsed_location_{};

  DiagnosticEngine* diagnostic_engine_{nullptr};

 public:
  void SetDiagnosticEngine(DiagnosticEngine* diagnostic_engine);

  void Reset(Lexer* lexer);

  std::unique_ptr<TranslationUnitDecl> operator()() noexcept(false);

 private:
  std::unique_ptr<TranslationUnitDecl> TranslationUnitDecl_();

  std::unique_ptr<StructDecl> StructDecl_();

  std::unique_ptr<FunctionDecl> FunctionDecl_();

  std::unique_ptr<VarDecl> VarDecl_();

  std::unique_ptr<VirtualDecl> VirtualDecl_();

  void InitializeLexer();

  void AdvanceLexer();

  void AdvanceLexerSkipLine();

  void HandleExpect(std::vector<tok::TokenType> expected);
};

}  // namespace cw