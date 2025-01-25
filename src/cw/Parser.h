/// \file Parser.h
/// \author Donghao Chu
/// \date 2025/01/07
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include <memory>

#include "ast.h"

namespace cw {

class Lexer;

class Parser {
  Lexer* lexer_;

 public:
  void Reset(Lexer& lexer);

  std::unique_ptr<TranslationUnitDecl> operator()() noexcept(false);

 private:
  std::unique_ptr<TranslationUnitDecl> TranslationUnitDecl_();

  std::unique_ptr<StructDecl> StructDecl_();

  std::unique_ptr<FunctionDecl> FunctionDecl_();

  std::unique_ptr<VarDecl> VarDecl_();

  std::unique_ptr<VirtualDecl> VirtualDecl_();
};

}  // namespace cw