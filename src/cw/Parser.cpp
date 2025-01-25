/// \file Parser.cpp
/// \author Donghao Chu
/// \date 2025/01/10
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include "Parser.h"

#include <boost/leaf/exception.hpp>
#include <memory>

#include <boost/leaf.hpp>

#include "Exception.h"
#include "Lexer.h"
#include "Token.h"

#define THROW(info) BOOST_LEAF_THROW_EXCEPTION(ParseException(info))

namespace cw {

void Parser::Reset(Lexer& lexer) { lexer_ = &lexer; }

std::unique_ptr<TranslationUnitDecl> Parser::operator()() noexcept(false) {
  if (!lexer_) {
    BOOST_LEAF_THROW_EXCEPTION(ParseException("Lexer is not initialized"));
  }
  auto ast = TranslationUnitDecl_();
  return ast;
}

std::unique_ptr<TranslationUnitDecl> Parser::TranslationUnitDecl_() {
  auto tud = std::make_unique<TranslationUnitDecl>();
  for (;;) {
    auto& token = lexer_->Token();
    if (token.type == tok::struct_) {
      tud->Decls.emplace_back(StructDecl_());
    }
    if (token.type == tok::func) {
      tud->Decls.emplace_back(FunctionDecl_());
    } else if (token.type == tok::var) {
      tud->Decls.emplace_back(VarDecl_());
    } else if (token.type == tok::eos) {
      return tud;
    } else {
      THROW("Expect struct/func/var");
    }
  }
}

std::unique_ptr<StructDecl> Parser::StructDecl_() {
  auto sd = std::make_unique<StructDecl>();

  auto& token = lexer_->Token();
  if (token.type != tok::struct_) {
    THROW("Expect struct");
  }

  lexer_->Advance();

  if (token.type != tok::identifier) {
    THROW("Expect identifier");
  }
  sd->name = token.get<IdentifierProperty>().name;

  lexer_->Advance();

  if (token.type == tok::semi) {
    lexer_->Advance();
    return sd;
  }

  if (token.type != tok::l_brace) {
    THROW("Expect '{'");
  }
  lexer_->Advance();

  for (;;) {
    if (token.type == tok::var) {
      auto vd = VarDecl_();
      sd->Fields.emplace_back(std::move(vd));
    } else if (token.type == tok::virtual_) {
      auto vd = VirtualDecl_();
      sd->VirtualDecl = std::move(vd);
    } else if (token.type == tok::r_brace) {
      break;
    } else {
      THROW("Expect virtual/var/'}'");
    }
  }

  if (token.type != tok::r_brace) {
    THROW("Expect '}'");
  }

  return sd;
}

std::unique_ptr<FunctionDecl> Parser::FunctionDecl_() {
  auto fd = std::make_unique<FunctionDecl>();

  auto& token = lexer_->Token();
  if (token.type != tok::func) {
    THROW("Expect func");
  }
  lexer_->Advance();

  if (token.type != tok::identifier) {
    THROW("Expect identifier");
  }
  fd->name = token.get<IdentifierProperty>().name;

  // TODO: parse function body

  return fd;
}

std::unique_ptr<VarDecl> Parser::VarDecl_() {
  auto vd = std::make_unique<VarDecl>();

  auto& token = lexer_->Token();
  if (token.type != tok::var) {
    THROW("Expect var");
  }
  lexer_->Advance();

  if (token.type != tok::identifier) {
    THROW("Expect identifier");
  }
  vd->name = token.get<IdentifierProperty>().name;
  lexer_->Advance();

  if (token.type != tok::colon) {
    THROW("Expect ':'");
  }
  lexer_->Advance();

  // TODO: parse type

  if (token.type == tok::semi) {
    lexer_->Advance();
    return vd;
  }

  return vd;
}

std::unique_ptr<VirtualDecl> Parser::VirtualDecl_() {
  auto vd = std::make_unique<VirtualDecl>();

  auto& token = lexer_->Token();
  if (token.type != tok::virtual_) {
    THROW("Expect virtual");
  }
  lexer_->Advance();

  if (token.type != tok::l_brace) {
    THROW("Expect '{'");
  }
  lexer_->Advance();

  for (;;) {
    if (token.type == tok::func) {
      auto fd = FunctionDecl_();
      vd->Funcs.emplace_back(std::move(fd));
    } else if (token.type == tok::r_brace) {
      break;
    } else {
      THROW("Expect func/'}'");
    }
  }

  if (token.type != tok::r_brace) {
    THROW("Expect '}'");
  }
  lexer_->Advance();

  return vd;
}

}  // namespace cw