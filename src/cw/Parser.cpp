/// \file Parser.cpp
/// \author Donghao Chu
/// \date 2025/01/10
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "Parser.h"

#include <memory>

#include <fmt/format.h>

#include "Diagnostic.h"
#include "Lexer.h"
#include "Token.h"

namespace cw {

void Parser::SetDiagnosticEngine(DiagnosticEngine* diagnostic_engine) { diagnostic_engine_ = diagnostic_engine; }

void Parser::Reset(Lexer* lexer) { lexer_ = lexer; }

std::unique_ptr<TranslationUnitDecl> Parser::operator()() noexcept(false) {
  BOOST_ASSERT(lexer_);
  BOOST_ASSERT(lexer_->Sources());
  BOOST_ASSERT(diagnostic_engine_);

  InitializeLexer();

  auto ast = TranslationUnitDecl_();
  return ast;
}

std::unique_ptr<TranslationUnitDecl> Parser::TranslationUnitDecl_() {
  auto tud = std::make_unique<TranslationUnitDecl>();
  for (;;) {
    auto& token = lexer_->Token();

    if (token.type == tok::struct_) {
      tud->Decls.emplace_back(StructDecl_());
    } else if (token.type == tok::func) {
      tud->Decls.emplace_back(FunctionDecl_());
    } else if (token.type == tok::var) {
      tud->Decls.emplace_back(VarDecl_());
    } else if (token.type == tok::eos) {
      return tud;
    } else {
      HandleExpect({tok::struct_, tok::func, tok::var});
    }
  }
}

std::unique_ptr<StructDecl> Parser::StructDecl_() {
  auto sd = std::make_unique<StructDecl>();

  auto& token = lexer_->Token();

  if (token.type != tok::struct_) {
    HandleExpect({tok::struct_});
    return nullptr;
  }

  AdvanceLexer();

  if (token.type != tok::identifier) {
    HandleExpect({tok::identifier});
    return nullptr;
  }
  sd->name = token.get<IdentifierProperty>().name;

  AdvanceLexer();

  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return nullptr;
  }

  AdvanceLexer();

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
      HandleExpect({tok::virtual_, tok::var, tok::r_brace});
      return nullptr;
    }
  }

  if (token.type != tok::r_brace) {
    HandleExpect({tok::r_brace});
    return nullptr;
  }

  return sd;
}

std::unique_ptr<FunctionDecl> Parser::FunctionDecl_() {
  auto fd = std::make_unique<FunctionDecl>();

  auto& token = lexer_->Token();

  if (token.type != tok::func) {
    HandleExpect({tok::func});
    return nullptr;
  }

  AdvanceLexer();

  if (token.type != tok::identifier) {
    HandleExpect({tok::identifier});
    return nullptr;
  }
  fd->name = token.get<IdentifierProperty>().name;

  // TODO: parse function body

  return fd;
}

std::unique_ptr<VarDecl> Parser::VarDecl_() {
  auto vd = std::make_unique<VarDecl>();

  auto& token = lexer_->Token();

  if (token.type != tok::var) {
    HandleExpect({tok::var});
    return nullptr;
  }

  AdvanceLexer();

  if (token.type != tok::identifier) {
    HandleExpect({tok::identifier});
    return nullptr;
  }
  vd->name = token.get<IdentifierProperty>().name;

  AdvanceLexer();

  // TODO

  return vd;
}

std::unique_ptr<VirtualDecl> Parser::VirtualDecl_() {
  auto vd = std::make_unique<VirtualDecl>();

  auto& token = lexer_->Token();

  if (token.type != tok::virtual_) {
    HandleExpect({tok::virtual_});
    return nullptr;
  }

  AdvanceLexer();

  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return nullptr;
  }

  AdvanceLexer();

  for (;;) {
    if (token.type == tok::func) {
      auto fd = FunctionDecl_();
      vd->Funcs.emplace_back(std::move(fd));
    } else if (token.type == tok::r_brace) {
      break;
    } else {
      HandleExpect({tok::func, tok::r_brace});
      return nullptr;
    }
  }

  if (token.type != tok::r_brace) {
    HandleExpect({tok::r_brace});
    return nullptr;
  }

  AdvanceLexer();

  return vd;
}

void Parser::InitializeLexer() {
  parsed_location_ = TokenLocation{};
  // skip blank and comment in the beginning
  lexer_->SkipBlankComment();
}

void Parser::AdvanceLexer() {
  lexer_->Advance(false);
  parsed_location_ = lexer_->Token().location;
  lexer_->SkipBlankComment();
}

void Parser::AdvanceLexerSkipLine() {
  lexer_->SkipLine();
  parsed_location_ = lexer_->Token().location;
  lexer_->SkipBlankComment();
}

void Parser::HandleExpect(std::vector<tok::TokenType> expected) {
  auto sources = lexer_->Sources();
  auto& token = lexer_->Token();

  std::filesystem::path path;
  int line = 0;
  int column = 0;
  std::string info;
  std::string line_source;
  int size = 0;

  if (token.type != tok::invalid && token.type != tok::eos) {
    if (0 <= token.location.file && token.location.file < static_cast<int>(sources->size())) {
      path = (*sources)[token.location.file].path;
      line_source = LineSource((*sources)[token.location.file], token.location.pos);
      line = token.location.line;
      column = token.location.column;
      size = token.source_view.size();
    } else {
      // should not happen
    }
  } else {
    if (0 <= parsed_location_.file && parsed_location_.file < static_cast<int>(sources->size())) {
      path = (*sources)[parsed_location_.file].path;
      line_source = LineSource((*sources)[parsed_location_.file], parsed_location_.pos);
      line = parsed_location_.line;
      column = parsed_location_.column;
      size = 0;
    } else {
      // should not happen
    }
  }

  {
    auto actual = to_string(token.type);
    std::vector<const char*> expected_strs(expected.size());
    std::transform(expected.begin(), expected.end(), expected_strs.begin(), cw::tok::to_string);
    info = fmt::format("Expect {} but got {}", fmt::join(expected_strs, "/"), actual);
  }

  diagnostic_engine_->Add(kErrorDiagnostic, path, line, column, info, line_source, size);

  AdvanceLexerSkipLine();
}

}  // namespace cw