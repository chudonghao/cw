/// \file Parser.cpp
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "Parser.h"

#include <string_view>
#include <utility>
#include <vector>

#include <fmt/format.h>
#include <fmt/ranges.h>

#include "ASTContext.h"
#include "Diagnostic.h"
#include "Lexer.h"
#include "Token.h"

namespace cw {

namespace {

/// \brief Returns true when \p type starts a keyword-led statement.
bool IsKeywordStmtStart(tok::TokenType type) {
  switch (type) {
    case tok::var:
    case tok::if_:
    case tok::while_:
    case tok::break_:
    case tok::continue_:
    case tok::return_:
      return true;
    default:
      return false;
  }
}

/// \brief Returns true when \p type starts a compound statement (block).
bool IsCompoundStmtStart(tok::TokenType type) { return type == tok::l_brace; }

/// \brief Declaration keywords in diagnostic order; modifiers are parsed separately.
const std::vector<tok::TokenType> kDeclarationKeywords = {tok::namespace_, tok::trivial_, tok::struct_, tok::func,
                                                          tok::ctor,       tok::dtor,     tok::var};

/// \brief Declaration starts and the enclosing namespace boundary used for error recovery.
const std::vector<tok::TokenType> kDeclarationRecoveryTokens = {
    tok::namespace_, tok::export_, tok::import_, tok::trivial_, tok::struct_,
    tok::func,       tok::ctor,    tok::dtor,    tok::var,      tok::r_brace};

/// \brief Returns true when \p type starts source-level type syntax.
bool IsTypeStart(tok::TokenType type) {
  return type == tok::l_square || type == tok::virtual_ || type == tok::const_ || type == tok::amp ||
         type == tok::star || type == tok::func || type == tok::builtin_type || type == tok::identifier ||
         type == tok::coloncolon;
}

/// \brief Returns a user-facing spelling for an expected token kind.
std::string ExpectedTokenSpelling(tok::TokenType type) {
  switch (type) {
    case tok::identifier:
      return "identifier";
    case tok::bool_literal:
      return "boolean literal";
    case tok::integer_literal:
      return "integer literal";
    case tok::character_literal:
      return "character literal";
    case tok::float_literal:
      return "floating literal";
    case tok::string_literal:
      return "string literal";
    case tok::builtin_type:
      return "built-in type";
    case tok::invalid:
      return "invalid token";
    case tok::comment:
      return "comment";
    case tok::blank:
      return "whitespace";
    case tok::eol:
      return "end of line";
    case tok::eof:
      return "end of file";
    case tok::eos:
      return "end of source";
    case tok::undefined:
      return "undefined token";
    default:
      return fmt::format("'{}'", tok::to_string(type));
  }
}

/// \brief Formats one or more expected token kinds as a diagnostic phrase.
std::string FormatExpectedTokens(const std::vector<tok::TokenType>& expected) {
  BOOST_ASSERT(!expected.empty());

  std::vector<std::string> spellings;
  spellings.reserve(expected.size());
  for (const tok::TokenType type : expected) spellings.push_back(ExpectedTokenSpelling(type));

  if (spellings.size() == 1) {
    return fmt::format("expected {}", spellings.front());
  }
  if (spellings.size() == 2) {
    return fmt::format("expected {} or {}", spellings[0], spellings[1]);
  }
  return fmt::format("expected one of {}", fmt::join(spellings, ", "));
}

/// \brief Starts \p node's range at \p token or a zero-width end-of-source anchor.
void BeginRange(Node& node, const Token& token, const SourceLocation& parsed_location) {
  if ((token.type == tok::invalid || token.type == tok::eos) && parsed_location.IsValid()) {
    node.range = {parsed_location, parsed_location};
  } else {
    node.range = token.range;
  }
}

/// \brief Extends \p node's range through \p token.
void ExtendRange(Node& node, const Token& token) { node.range.end = token.range.end; }

/// \brief Extends \p node's range through \p child when present.
void ExtendRange(Node& node, const Node* child) {
  if (child) {
    node.range.end = child->range.end;
  }
}

/// \brief Stores \p child in \p slot, folding its errors and source range into \p parent.
///
/// A child parse that produced no node leaves \p parent unchanged. Whether parsing continues is
/// decided separately by the caller through Parser::Recovering().
template <class T, class U>
void Attach(Node& parent, std::unique_ptr<T>& slot, std::unique_ptr<U> child) {
  if (!child) {
    return;
  }
  parent.contains_errors |= child->contains_errors;
  ExtendRange(parent, child.get());
  slot = std::move(child);
}

/// \brief Appends \p child to \p list, folding its errors and source range into \p parent.
///
/// A child parse that produced no node is not appended. Whether parsing continues is decided
/// separately by the caller through Parser::Recovering().
template <class T, class U>
void Append(Node& parent, std::vector<std::unique_ptr<T>>& list, std::unique_ptr<U> child) {
  if (!child) {
    return;
  }
  parent.contains_errors |= child->contains_errors;
  ExtendRange(parent, child.get());
  list.push_back(std::move(child));
}

}  // namespace

Parser::Parser() = default;

void Parser::SetASTContext(ASTContext* ast_context) { ast_context_ = ast_context; }

void Parser::SetDiagnosticEngine(DiagnosticEngine* diagnostic_engine) { diagnostic_engine_ = diagnostic_engine; }

void Parser::SetLexer(Lexer* lexer) { lexer_ = lexer; }

void Parser::operator()() {
  BOOST_ASSERT(lexer_);
  BOOST_ASSERT(lexer_->Sources());
  BOOST_ASSERT(ast_context_);
  BOOST_ASSERT(diagnostic_engine_);
  BOOST_ASSERT(expr_parser_depth_ == 0);

  InitializeLexer();

  TranslationUnitDecl* translation_unit = ast_context_->GetTranslationUnitDecl();
  BOOST_ASSERT(translation_unit);

  auto& token = lexer_->Token();
  // Each source file contains { Decl }; only this loop advances past its EOF.
  while (token.type != tok::eos) {
    if (token.type == tok::eof) {
      AdvanceLexer();
      continue;
    }

    if (token.type == tok::r_brace) {
      // A stray root closing brace has no enclosing parser to consume it.
      HandleExpect(kDeclarationKeywords);
      AdvanceLexer();
      Unwind();
    } else {
      Append(*translation_unit, translation_unit->Decls, Decl_());
    }
    if (Recovering()) {
      translation_unit->contains_errors = true;
      SkipUntil(kDeclarationRecoveryTokens, SkipUntilFlags::kStopBeforeMatch);
      FinishRecovery();
    }
  }
  // Every recovery point that observed an error has synchronized and finished recovery.
  BOOST_ASSERT(!Recovering());
}

std::unique_ptr<Decl> Parser::Decl_() {
  auto& token = lexer_->Token();
  if (token.type == tok::namespace_) {
    return NamespaceDecl_();
  }

  const SourceLocation begin = token.range.begin;
  DeclModifier modifier = DeclModifier::None;
  bool invalid_modifier = false;
  if (token.type == tok::export_ || token.type == tok::import_) {
    modifier = token.type == tok::export_ ? DeclModifier::Export : DeclModifier::Import;
    AdvanceLexer();
    while (token.type == tok::export_ || token.type == tok::import_) {
      ReportCurrentTokenError("declaration modifiers 'import' and 'export' cannot be repeated or combined");
      invalid_modifier = true;
      AdvanceLexer();
    }
  }

  std::unique_ptr<Decl> declaration;
  switch (token.type) {
    case tok::trivial_:
    case tok::struct_:
      declaration = StructDecl_();
      break;
    case tok::func:
      declaration = FunctionDecl_(modifier);
      break;
    case tok::ctor:
      declaration = ConstructorDecl_(modifier);
      break;
    case tok::dtor:
      declaration = DestructorDecl_(modifier);
      break;
    case tok::var:
      declaration = VarGroupDecl_();
      break;
    default: {
      auto expected = kDeclarationKeywords;
      if (modifier != DeclModifier::None) expected.erase(expected.begin());  // A namespace cannot have a modifier.
      HandleExpect(std::move(expected));
      return Unwind(std::move(declaration));
    }
  }

  if (declaration) {
    declaration->modifier = modifier;
    if (modifier != DeclModifier::None) declaration->range.begin = begin;
    declaration->contains_errors |= invalid_modifier;
  }
  return declaration;
}

std::unique_ptr<NamespaceDecl> Parser::NamespaceDecl_() {
  auto declaration = std::make_unique<NamespaceDecl>();
  auto& token = lexer_->Token();
  BOOST_ASSERT(token.type == tok::namespace_ || token.type == tok::coloncolon);
  BeginRange(*declaration, token, parsed_location_);
  declaration->is_nested = token.type == tok::coloncolon;
  AdvanceLexer();
  if (token.type != tok::identifier) {
    HandleExpect({tok::identifier});
    return Unwind(std::move(declaration));
  }
  declaration->name = token.get<IdentifierProperty>().name;
  declaration->name_range = token.range;
  ExtendRange(*declaration, token);
  AdvanceLexer();

  if (token.type == tok::coloncolon) {
    auto nested = NamespaceDecl_();
    // All layers become usable together once the complete header reaches its actual opening brace.
    declaration->left_brace_range = nested->left_brace_range;
    Append(*declaration, declaration->Decls, std::move(nested));
    if (Recovering()) return Unwind(std::move(declaration));
    return declaration;
  }

  ExtendRange(*declaration, token);
  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return Unwind(std::move(declaration));
  }
  declaration->left_brace_range = token.range;
  AdvanceLexer();

  // { Decl } "}"
  while (token.type != tok::r_brace && token.type != tok::eof && token.type != tok::eos) {
    Append(*declaration, declaration->Decls, Decl_());
    if (Recovering()) {
      declaration->contains_errors = true;
      SkipUntil(kDeclarationRecoveryTokens, SkipUntilFlags::kStopBeforeMatch);
      FinishRecovery();
    }
  }

  if (token.type != tok::r_brace) {
    HandleExpect({tok::r_brace});
    return Unwind(std::move(declaration));
  }
  ExtendRange(*declaration, token);
  AdvanceLexer();
  return declaration;
}

std::unique_ptr<StructDecl> Parser::StructDecl_() {
  auto sd = std::make_unique<StructDecl>();
  auto& token = lexer_->Token();
  BeginRange(*sd, token, parsed_location_);

  if (token.type == tok::trivial_) {
    sd->is_declared_trivial = true;
    AdvanceLexer();
  }

  if (token.type != tok::struct_) {
    HandleExpect({tok::struct_});
    return Unwind(std::move(sd));
  }
  AdvanceLexer();

  if (token.type != tok::identifier) {
    HandleExpect({tok::identifier});
    return Unwind(std::move(sd));
  }
  sd->name = token.get<IdentifierProperty>().name;
  sd->name_range = token.range;
  ExtendRange(*sd, token);
  AdvanceLexer();

  // Optional qualified base type name.
  if (token.type == tok::colon) {
    AdvanceLexer();
    if (!QualifiedName_(sd->base)) return Unwind(std::move(sd));
    sd->range.end = sd->base.Range().end;
  }

  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return Unwind(std::move(sd));
  }
  ExtendRange(*sd, token);
  AdvanceLexer();

  // [ VirtualDecl ] { FieldDecl }
  if (token.type == tok::virtual_) {
    Attach(*sd, sd->VirtualDecl, VirtualDecl_());
    if (Recovering()) {
      // Required substructure failed: unwind to the enclosing recovery point.
      return Unwind(std::move(sd));
    }
  }

  while (token.type == tok::identifier) {
    Append(*sd, sd->Fields, FieldDecl_());
    if (Recovering()) {
      // Field error: sync within the struct body and keep parsing fields. Stop
      // before ';' (field separator, consumed here) or '}' (left to closing).
      sd->contains_errors = true;
      SkipUntil(tok::r_brace, SkipUntilFlags::kStopAtSemi | SkipUntilFlags::kStopBeforeMatch);
      FinishRecovery();
      if (token.type == tok::semi) {
        AdvanceLexer();
      } else {
        break;
      }
    }
  }

  if (token.type != tok::r_brace) {
    HandleExpect({tok::r_brace});
    return Unwind(std::move(sd));
  }
  ExtendRange(*sd, token);
  AdvanceLexer();

  return sd;
}

std::unique_ptr<VirtualDecl> Parser::VirtualDecl_() {
  auto vd = std::make_unique<VirtualDecl>();
  auto& token = lexer_->Token();
  BeginRange(*vd, token, parsed_location_);

  if (token.type != tok::virtual_) {
    HandleExpect({tok::virtual_});
    return Unwind(std::move(vd));
  }
  AdvanceLexer();

  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return Unwind(std::move(vd));
  }
  ExtendRange(*vd, token);
  AdvanceLexer();

  // { { "override" | "abstract" } "func" Identifier "(" ParamDecls ")" [ ReturnDecl ] ";" }
  while (token.type == tok::func || token.type == tok::override_ || token.type == tok::abstract_) {
    auto fd = std::make_unique<VirtualFunctionDecl>();
    BeginRange(*fd, token, parsed_location_);
    while (token.type == tok::override_ || token.type == tok::abstract_) {
      bool& modifier = token.type == tok::override_ ? fd->is_override : fd->is_abstract;
      if (modifier) {
        ReportCurrentTokenError(fmt::format("duplicate virtual function modifier '{}'", token.source_view));
        fd->contains_errors = true;
      }
      modifier = true;
      ExtendRange(*fd, token);
      AdvanceLexer();
    }

    bool declaration_incomplete = false;
    if (token.type != tok::func) {
      HandleExpect({tok::func});
      declaration_incomplete = true;
    } else {
      ExtendRange(*fd, token);
      AdvanceLexer();
    }

    if (!declaration_incomplete && token.type != tok::identifier) {
      HandleExpect({tok::identifier});
      declaration_incomplete = true;
    } else if (!declaration_incomplete) {
      fd->name = token.get<IdentifierProperty>().name;
      fd->name_range = token.range;
      ExtendRange(*fd, token);
      AdvanceLexer();
    }

    if (!declaration_incomplete && token.type != tok::l_paren) {
      HandleExpect({tok::l_paren});
      declaration_incomplete = true;
    }
    if (!declaration_incomplete) {
      ExtendRange(*fd, token);
      AdvanceLexer();
    }

    // ParamDecls
    if (!declaration_incomplete && token.type != tok::r_paren) {
      for (;;) {
        Append(*fd, fd->ParmVars, ParmVarDecl_());
        if (Recovering()) {
          // Param error: sync to the next param or end of the list.
          fd->contains_errors = true;
          SkipUntil(tok::comma, tok::r_paren, SkipUntilFlags::kStopAtSemi | SkipUntilFlags::kStopBeforeMatch);
          FinishRecovery();
        }
        if (token.type == tok::comma) {
          ExtendRange(*fd, token);
          AdvanceLexer();
          continue;
        }
        break;
      }
    }

    if (!declaration_incomplete && token.type != tok::r_paren) {
      HandleExpect({tok::r_paren});
      declaration_incomplete = true;
    }
    if (!declaration_incomplete) {
      ExtendRange(*fd, token);
      AdvanceLexer();
    }

    // ReturnDecl (optional)
    if (!declaration_incomplete && token.type != tok::semi) {
      Attach(*fd, fd->ReturnVar, ReturnVarDecl_());
      if (Recovering()) {
        declaration_incomplete = true;
      }
    }

    if (!declaration_incomplete && token.type != tok::semi) {
      HandleExpect({tok::semi});
      declaration_incomplete = true;
    }
    if (!declaration_incomplete) {
      ExtendRange(*fd, token);
      AdvanceLexer();
    } else {
      // Each virtual function declaration is a recovery point within the virtual block.
      fd->contains_errors = true;
      SkipUntil(tok::r_brace, SkipUntilFlags::kStopAtSemi | SkipUntilFlags::kStopBeforeMatch);
      FinishRecovery();
      if (token.type == tok::semi) {
        ExtendRange(*fd, token);
        AdvanceLexer();
      }
    }

    Append(*vd, vd->Functions, std::move(fd));
  }

  if (token.type != tok::r_brace) {
    HandleExpect({tok::r_brace});
    return Unwind(std::move(vd));
  }
  ExtendRange(*vd, token);
  AdvanceLexer();

  return vd;
}

std::unique_ptr<FieldDecl> Parser::FieldDecl_() {
  auto fd = std::make_unique<FieldDecl>();
  auto& token = lexer_->Token();
  BeginRange(*fd, token, parsed_location_);

  if (token.type != tok::identifier) {
    HandleExpect({tok::identifier});
    return Unwind(std::move(fd));
  }
  fd->name = token.get<IdentifierProperty>().name;
  fd->name_range = token.range;
  AdvanceLexer();

  // Type
  Attach(*fd, fd->Type, Type_());
  if (Recovering()) {
    return Unwind(std::move(fd));
  }

  if (token.type != tok::semi) {
    HandleExpect({tok::semi});
    return Unwind(std::move(fd));
  }
  ExtendRange(*fd, token);
  AdvanceLexer();

  return fd;
}

std::unique_ptr<FunctionDecl> Parser::FunctionDecl_(DeclModifier modifier) {
  auto& token = lexer_->Token();
  auto fd = std::make_unique<FunctionDecl>();
  BeginRange(*fd, token, parsed_location_);

  if (token.type != tok::func) {
    HandleExpect({tok::func});
    return Unwind(std::move(fd));
  }
  AdvanceLexer();

  // [ Identifier | "operator" Operator ]
  if (token.type == tok::operator_) {
    fd->name_range = token.range;
    ExtendRange(*fd, token);
    AdvanceLexer();
    if (token.type == tok::invalid || token.type == tok::eos || token.type == tok::eof) {
      HandleExpect({tok::l_paren});
      return Unwind(std::move(fd));
    }

    // [] and () are the only operators whose spelling spans two tokens.
    if (token.type == tok::l_square || token.type == tok::l_paren) {
      const tok::TokenType closing = token.type == tok::l_square ? tok::r_square : tok::r_paren;
      fd->name = token.type == tok::l_square ? "[]" : "()";
      fd->name_range.end = token.range.end;
      ExtendRange(*fd, token);
      AdvanceLexer();
      if (token.type != closing) {
        HandleExpect({closing});
        return Unwind(std::move(fd));
      }
      fd->name_range.end = token.range.end;
      ExtendRange(*fd, token);
      AdvanceLexer();
    } else {
      // Other overloadable operators have a single-token spelling.
      const std::string operator_name(token.source_view);
      if (!IsOperatorFunctionName(operator_name)) {
        HandleExpect({tok::l_paren});
        return Unwind(std::move(fd));
      }
      fd->name = operator_name;
      fd->name_range.end = token.range.end;
      ExtendRange(*fd, token);
      AdvanceLexer();
    }
  } else if (token.type == tok::identifier) {
    fd->name = token.get<IdentifierProperty>().name;
    fd->name_range = token.range;
    ExtendRange(*fd, token);
    AdvanceLexer();
  }

  // "(" ParamDecls ")"
  if (token.type != tok::l_paren) {
    HandleExpect({tok::l_paren});
    return Unwind(std::move(fd));
  }
  ExtendRange(*fd, token);
  AdvanceLexer();

  // ParamDecls
  if (token.type != tok::r_paren) {
    for (;;) {
      Append(*fd, fd->ParmVars, ParmVarDecl_());
      if (Recovering()) {
        // Param error: sync to the next param or end of the list.
        fd->contains_errors = true;
        SkipUntil(tok::comma, tok::r_paren, SkipUntilFlags::kStopAtSemi | SkipUntilFlags::kStopBeforeMatch);
        FinishRecovery();
      }
      if (token.type == tok::comma) {
        ExtendRange(*fd, token);
        AdvanceLexer();
        continue;
      }
      break;
    }
  }

  if (token.type != tok::r_paren) {
    HandleExpect({tok::r_paren});
    return Unwind(std::move(fd));
  }
  ExtendRange(*fd, token);
  AdvanceLexer();

  // ReturnDecl (optional)
  if (token.type != tok::l_brace && !(modifier == DeclModifier::Import && token.type == tok::semi)) {
    Attach(*fd, fd->ReturnVar, ReturnVarDecl_());
    if (Recovering()) {
      if (token.type != tok::l_brace) {
        return Unwind(std::move(fd));
      }
      // The body still starts here, so a return type error needs no further synchronization.
      FinishRecovery();
    }
  }

  if (modifier == DeclModifier::Import) {
    if (token.type != tok::semi) {
      HandleExpect({tok::semi});
      return Unwind(std::move(fd));
    }
    ExtendRange(*fd, token);
    AdvanceLexer();
    return fd;
  }

  // CompoundStmt
  Attach(*fd, fd->Body, CompoundStmt_());
  if (Recovering()) {
    // Required substructure failed: unwind to the enclosing recovery point.
    return Unwind(std::move(fd));
  }

  return fd;
}

std::unique_ptr<ConstructorDecl> Parser::ConstructorDecl_(DeclModifier modifier) {
  auto declaration = std::make_unique<ConstructorDecl>();
  auto& token = lexer_->Token();
  BeginRange(*declaration, token, parsed_location_);

  if (token.type != tok::ctor) {
    HandleExpect({tok::ctor});
    return Unwind(std::move(declaration));
  }
  AdvanceLexer();

  if (token.type != tok::identifier) {
    HandleExpect({tok::identifier});
    return Unwind(std::move(declaration));
  }
  declaration->name = token.get<IdentifierProperty>().name;
  declaration->name_range = token.range;
  ExtendRange(*declaration, token);
  AdvanceLexer();

  // "(" ParamDecls ")"
  if (token.type != tok::l_paren) {
    HandleExpect({tok::l_paren});
    return Unwind(std::move(declaration));
  }
  ExtendRange(*declaration, token);
  AdvanceLexer();

  if (token.type != tok::r_paren) {
    for (;;) {
      Append(*declaration, declaration->ParmVars, ParmVarDecl_());
      if (Recovering()) {
        // Param error: sync to the next param or end of the list.
        declaration->contains_errors = true;
        SkipUntil(tok::comma, tok::r_paren, SkipUntilFlags::kStopAtSemi | SkipUntilFlags::kStopBeforeMatch);
        FinishRecovery();
      }
      if (token.type == tok::comma) {
        ExtendRange(*declaration, token);
        AdvanceLexer();
        continue;
      }
      break;
    }
  }

  if (token.type != tok::r_paren) {
    HandleExpect({tok::r_paren});
    return Unwind(std::move(declaration));
  }
  ExtendRange(*declaration, token);
  AdvanceLexer();

  if (modifier == DeclModifier::Import) {
    if (token.type != tok::semi) {
      HandleExpect({tok::semi});
      return Unwind(std::move(declaration));
    }
    ExtendRange(*declaration, token);
    AdvanceLexer();
    return declaration;
  }

  // CompoundStmt
  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return Unwind(std::move(declaration));
  }

  Attach(*declaration, declaration->Body, CompoundStmt_());
  if (Recovering()) {
    return Unwind(std::move(declaration));
  }

  return declaration;
}

std::unique_ptr<DestructorDecl> Parser::DestructorDecl_(DeclModifier modifier) {
  auto declaration = std::make_unique<DestructorDecl>();
  auto& token = lexer_->Token();
  BeginRange(*declaration, token, parsed_location_);

  if (token.type != tok::dtor) {
    HandleExpect({tok::dtor});
    return Unwind(std::move(declaration));
  }
  AdvanceLexer();

  if (token.type != tok::identifier) {
    HandleExpect({tok::identifier});
    return Unwind(std::move(declaration));
  }
  declaration->name = token.get<IdentifierProperty>().name;
  declaration->name_range = token.range;
  ExtendRange(*declaration, token);
  AdvanceLexer();

  // "(" ")"
  if (token.type != tok::l_paren) {
    HandleExpect({tok::l_paren});
    return Unwind(std::move(declaration));
  }
  ExtendRange(*declaration, token);
  AdvanceLexer();

  if (token.type != tok::r_paren) {
    HandleExpect({tok::r_paren});
    return Unwind(std::move(declaration));
  }
  ExtendRange(*declaration, token);
  AdvanceLexer();

  if (modifier == DeclModifier::Import) {
    if (token.type != tok::semi) {
      HandleExpect({tok::semi});
      return Unwind(std::move(declaration));
    }
    ExtendRange(*declaration, token);
    AdvanceLexer();
    return declaration;
  }

  // CompoundStmt
  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return Unwind(std::move(declaration));
  }

  Attach(*declaration, declaration->Body, CompoundStmt_());
  if (Recovering()) {
    return Unwind(std::move(declaration));
  }

  return declaration;
}

std::unique_ptr<VarGroupDecl> Parser::VarGroupDecl_() {
  auto group = std::make_unique<VarGroupDecl>();
  auto& token = lexer_->Token();
  BeginRange(*group, token, parsed_location_);

  if (token.type != tok::var) {
    HandleExpect({tok::var});
    return Unwind(std::move(group));
  }
  AdvanceLexer();

  // [ "(" Attrs ")" ]
  AttributeList attributes;
  if (token.type == tok::l_paren) {
    Attributes_(attributes);
  }

  // Identifier [ Type ] { "," Identifier [ Type ] }
  for (;;) {
    if (token.type != tok::identifier) {
      HandleExpect({tok::identifier});
      return Unwind(std::move(group));
    }

    auto variable = std::make_unique<VarDecl>();
    variable->name = token.get<IdentifierProperty>().name;
    variable->range = token.range;
    variable->name_range = token.range;
    variable->attributes = attributes;
    VarDecl* variable_decl = variable.get();
    group->Vars.push_back(std::move(variable));
    ExtendRange(*group, token);
    AdvanceLexer();

    if (IsTypeStart(token.type)) {
      // The type belongs to the variable, while the group also covers its errors and range.
      auto type = Type_();
      const bool type_contains_errors = Recovering() || (type && type->contains_errors);
      variable_decl->contains_errors |= type_contains_errors;
      group->contains_errors |= type_contains_errors;
      ExtendRange(*variable_decl, type.get());
      ExtendRange(*group, type.get());
      variable_decl->Type = std::move(type);
      if (Recovering()) {
        return Unwind(std::move(group));
      }
    }

    if (token.type != tok::comma) {
      break;
    }
    ExtendRange(*group, token);
    AdvanceLexer();
  }

  // [ ":=" (Exprs ";" | CompoundStmt) ] | ";"
  if (token.type == tok::colonequal) {
    ExtendRange(*group, token);
    AdvanceLexer();

    if (token.type == tok::l_brace) {
      Attach(*group, group->Body, CompoundStmt_());
      if (Recovering()) {
        return Unwind(std::move(group));
      }
      return group;
    }

    {
      // Required init expression: Expr_() always yields a node (RecoveryExpr on failure).
      Append(*group, group->InitExprs, Expr_());
      if (Recovering()) {
        return Unwind(std::move(group));
      }
    }
    while (token.type == tok::comma) {
      ExtendRange(*group, token);
      AdvanceLexer();
      Append(*group, group->InitExprs, Expr_());
      if (Recovering()) {
        return Unwind(std::move(group));
      }
    }

    if (token.type != tok::semi) {
      HandleExpect({tok::semi});
      return Unwind(std::move(group));
    }
    ExtendRange(*group, token);
    AdvanceLexer();
  } else if (token.type == tok::semi) {
    ExtendRange(*group, token);
    AdvanceLexer();
  } else {
    HandleExpect({tok::colonequal, tok::semi});
    return Unwind(std::move(group));
  }

  return group;
}

std::unique_ptr<ParmVarDecl> Parser::ParmVarDecl_() {
  auto pd = std::make_unique<ParmVarDecl>();
  auto& token = lexer_->Token();
  BeginRange(*pd, token, parsed_location_);

  // [ "var" [ "(" Attrs ")" ] ] (Identifier | "this") Type
  const bool has_var_prefix = token.type == tok::var;
  if (has_var_prefix) {
    AdvanceLexer();
    if (token.type == tok::l_paren) {
      Attributes_(pd->attributes);
    }
  }

  if (token.type == tok::identifier || token.type == tok::this_) {
    if (token.type == tok::identifier) {
      pd->name = token.get<IdentifierProperty>().name;
    } else {
      pd->name = "this";
    }
    pd->name_range = token.range;
    ExtendRange(*pd, token);
    AdvanceLexer();
  } else {
    if (has_var_prefix) {
      HandleExpect({tok::identifier, tok::this_});
    } else {
      HandleExpect({tok::var, tok::identifier, tok::this_});
    }
    return Unwind(std::move(pd));
  }

  Attach(*pd, pd->Type, Type_());
  if (Recovering()) {
    return Unwind(std::move(pd));
  }

  return pd;
}

std::unique_ptr<ReturnVarDecl> Parser::ReturnVarDecl_() {
  auto rd = std::make_unique<ReturnVarDecl>();
  auto& token = lexer_->Token();
  BeginRange(*rd, token, parsed_location_);

  // "var" [ "(" Attrs ")" ] Identifier Type
  if (token.type == tok::var) {
    AdvanceLexer();
    if (token.type == tok::l_paren) {
      Attributes_(rd->attributes);
    }
    if (token.type != tok::identifier) {
      HandleExpect({tok::identifier});
      return Unwind(std::move(rd));
    }
    rd->name = token.get<IdentifierProperty>().name;
    rd->name_range = token.range;
    ExtendRange(*rd, token);
    AdvanceLexer();
  }

  Attach(*rd, rd->Type, Type_());
  if (Recovering()) {
    return Unwind(std::move(rd));
  }

  return rd;
}

// Stmt parsing

std::unique_ptr<Stmt> Parser::Stmt_() {
  auto& token = lexer_->Token();

  if (token.type == tok::l_brace) {
    return CompoundStmt_();
  } else if (token.type == tok::var) {
    auto ds = std::make_unique<DeclStmt>();
    ds->Decl = VarGroupDecl_();
    if (ds->Decl) {
      // The statement spans exactly its declaration rather than extending from a token.
      ds->contains_errors |= ds->Decl->contains_errors;
      ds->range = ds->Decl->range;
    }
    if (Recovering()) {
      return Unwind(std::move(ds));
    }
    return ds;
  } else if (token.type == tok::if_) {
    return IfStmt_();
  } else if (token.type == tok::while_) {
    return WhileStmt_();
  } else if (token.type == tok::break_) {
    return BreakStmt_();
  } else if (token.type == tok::continue_) {
    return ContinueStmt_();
  } else if (token.type == tok::return_) {
    return ReturnStmt_();
  } else {
    return ExprStmt_();
  }
}

std::unique_ptr<CompoundStmt> Parser::CompoundStmt_() {
  auto cs = std::make_unique<CompoundStmt>();
  auto& token = lexer_->Token();
  BeginRange(*cs, token, parsed_location_);

  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return Unwind(std::move(cs));
  }
  AdvanceLexer();

  // { Stmt } [ Exprs ] "}"
  while (token.type != tok::r_brace && token.type != tok::eos && token.type != tok::eof) {
    if (IsKeywordStmtStart(token.type) || IsCompoundStmtStart(token.type)) {
      // Statement dispatched by its leading token.
      Append(*cs, cs->Stmts, Stmt_());
      if (!Recovering()) {
        continue;
      }
      // Statement error falls through to the recovery point below.
    } else {
      // Expression-led item: ExprStmt (ends with ';') or tail Exprs (',' / '}').
      auto expr = Expr_();  // always yields a node (RecoveryExpr on failure)
      if (!Recovering()) {
        if (token.type == tok::semi) {
          Append(*cs, cs->Stmts, ExprStmt_(std::move(expr)));
          continue;
        }
        // Tail expressions are the last items in the block.
        for (auto& tail : Exprs_(std::move(expr))) {
          Append(*cs, cs->TailExprs, std::move(tail));
        }
        if (!Recovering()) {
          break;
        }
        // Tail error falls through to the recovery point below.
      } else {
        // Expr_ failed: retain the RecoveryExpr as a tail expr, then recover.
        Append(*cs, cs->TailExprs, std::move(expr));
      }
    }

    // Single recovery point: reached only on a parse error this iteration.
    cs->contains_errors = true;
    SkipUntil(tok::r_brace, SkipUntilFlags::kStopAtSemi | SkipUntilFlags::kStopBeforeMatch);
    FinishRecovery();
    if (token.type != tok::semi) {
      break;
    }
    AdvanceLexer();
  }

  if (token.type != tok::r_brace) {
    HandleExpect({tok::r_brace});
    return Unwind(std::move(cs));
  }
  ExtendRange(*cs, token);
  AdvanceLexer();

  return cs;
}

std::unique_ptr<IfStmt> Parser::IfStmt_() {
  auto is = std::make_unique<IfStmt>();
  auto& token = lexer_->Token();
  BeginRange(*is, token, parsed_location_);

  if (token.type != tok::if_) {
    HandleExpect({tok::if_});
    return Unwind(std::move(is));
  }
  AdvanceLexer();

  // Expr (required condition slot: Expr_() always yields a node)
  Attach(*is, is->Cond, Expr_());
  if (Recovering()) {
    return Unwind(std::move(is));
  }

  // CompoundStmt
  Attach(*is, is->Then, CompoundStmt_());
  if (Recovering()) {
    return Unwind(std::move(is));
  }

  // [ "else" CompoundStmt ]
  if (token.type == tok::else_) {
    ExtendRange(*is, token);
    AdvanceLexer();
    Attach(*is, is->Else, CompoundStmt_());
    if (Recovering()) {
      return Unwind(std::move(is));
    }
  }

  return is;
}

std::unique_ptr<WhileStmt> Parser::WhileStmt_() {
  auto ws = std::make_unique<WhileStmt>();
  auto& token = lexer_->Token();
  BeginRange(*ws, token, parsed_location_);

  if (token.type != tok::while_) {
    HandleExpect({tok::while_});
    return Unwind(std::move(ws));
  }
  AdvanceLexer();

  // Expr (required condition slot: Expr_() always yields a node)
  Attach(*ws, ws->Cond, Expr_());
  if (Recovering()) {
    return Unwind(std::move(ws));
  }

  // CompoundStmt
  Attach(*ws, ws->Body, CompoundStmt_());
  if (Recovering()) {
    return Unwind(std::move(ws));
  }

  return ws;
}

std::unique_ptr<BreakStmt> Parser::BreakStmt_() {
  auto bs = std::make_unique<BreakStmt>();
  auto& token = lexer_->Token();
  BeginRange(*bs, token, parsed_location_);

  if (token.type != tok::break_) {
    HandleExpect({tok::break_});
    return Unwind(std::move(bs));
  }
  AdvanceLexer();

  if (token.type != tok::semi) {
    HandleExpect({tok::semi});
    return Unwind(std::move(bs));
  }
  ExtendRange(*bs, token);
  AdvanceLexer();

  return bs;
}

std::unique_ptr<ContinueStmt> Parser::ContinueStmt_() {
  auto cs = std::make_unique<ContinueStmt>();
  auto& token = lexer_->Token();
  BeginRange(*cs, token, parsed_location_);

  if (token.type != tok::continue_) {
    HandleExpect({tok::continue_});
    return Unwind(std::move(cs));
  }
  AdvanceLexer();

  if (token.type != tok::semi) {
    HandleExpect({tok::semi});
    return Unwind(std::move(cs));
  }
  ExtendRange(*cs, token);
  AdvanceLexer();

  return cs;
}

std::unique_ptr<ReturnStmt> Parser::ReturnStmt_() {
  auto rs = std::make_unique<ReturnStmt>();
  auto& token = lexer_->Token();
  BeginRange(*rs, token, parsed_location_);

  if (token.type != tok::return_) {
    HandleExpect({tok::return_});
    return Unwind(std::move(rs));
  }
  AdvanceLexer();

  // [ Expr ] (when present, Expr_() always yields a node)
  if (token.type != tok::semi) {
    Attach(*rs, rs->Expr, Expr_());
    if (Recovering()) {
      return Unwind(std::move(rs));
    }
  }

  if (token.type != tok::semi) {
    HandleExpect({tok::semi});
    return Unwind(std::move(rs));
  }
  ExtendRange(*rs, token);
  AdvanceLexer();

  return rs;
}

std::unique_ptr<ExprStmt> Parser::ExprStmt_() { return ExprStmt_(Expr_()); }

std::unique_ptr<ExprStmt> Parser::ExprStmt_(std::unique_ptr<Expr> expr) {
  // Precondition: expr is non-null (callers pass Expr_() results, which always yield a node).
  auto es = std::make_unique<ExprStmt>();
  es->Expr = std::move(expr);
  if (es->Expr) {
    // The statement begins at its expression rather than at a token of its own.
    es->contains_errors |= es->Expr->contains_errors;
    es->range = es->Expr->range;
  }
  if (Recovering()) {
    return Unwind(std::move(es));
  }

  auto& token = lexer_->Token();
  if (token.type != tok::semi) {
    HandleExpect({tok::semi});
    return Unwind(std::move(es));
  }
  ExtendRange(*es, token);
  AdvanceLexer();

  return es;
}

std::unique_ptr<Expr> Parser::Expr_() {
  const auto& token = lexer_->Token();
  const SourceLocation expression_begin = token.type == tok::eos ? parsed_location_ : token.range.begin;

  // Array type lengths can re-enter expression parsing; each active depth needs its own LR stacks.
  const std::size_t parser_index = expr_parser_depth_++;
  if (parser_index == expr_parsers_.size()) {
    expr_parsers_.push_back(std::make_unique<ExprParser>(this));
  }
  ExprParser* expr_parser = expr_parsers_[parser_index].get();
  auto e = (*expr_parser)();
  --expr_parser_depth_;
  if (e) {
    return e;
  }

  auto recovery = std::make_unique<RecoveryExpr>();
  recovery->range = {expression_begin, expression_begin};
  return Unwind(std::move(recovery));
}

std::vector<std::unique_ptr<Expr>> Parser::Exprs_(std::unique_ptr<Expr> first) {
  std::vector<std::unique_ptr<Expr>> exprs;
  exprs.push_back(std::move(first));

  auto& token = lexer_->Token();
  while (token.type == tok::comma) {
    AdvanceLexer();
    exprs.push_back(Expr_());
    if (Recovering()) {
      break;
    }
  }

  return exprs;
}

std::unique_ptr<TypeSyntax> Parser::Type_() {
  auto& token = lexer_->Token();

  if (token.type == tok::l_square) {
    auto array_type = std::make_unique<ArrayTypeSyntax>();
    array_type->range = token.range;
    array_type->left_bracket_range = token.range;
    AdvanceLexer();

    Attach(*array_type, array_type->Length, Expr_());
    if (Recovering()) {
      return Unwind(std::move(array_type));
    }

    if (token.type != tok::r_square) {
      HandleExpect({tok::r_square});
      return Unwind(std::move(array_type));
    }
    array_type->right_bracket_range = token.range;
    ExtendRange(*array_type, token);
    AdvanceLexer();

    Attach(*array_type, array_type->ElementType, Type_());
    if (Recovering()) {
      return Unwind(std::move(array_type));
    }
    return array_type;
  }

  if (token.type == tok::virtual_) {
    auto virtual_slot_type = std::make_unique<VirtualSlotTypeSyntax>();
    virtual_slot_type->range = token.range;
    virtual_slot_type->virtual_range = token.range;
    AdvanceLexer();

    if (token.type != tok::star) {
      HandleExpect({tok::star});
      return Unwind(std::move(virtual_slot_type));
    }

    auto function_pointer = std::make_unique<PointerTypeSyntax>();
    function_pointer->range = token.range;
    AdvanceLexer();
    if (token.type != tok::func) {
      HandleExpect({tok::func});
      virtual_slot_type->FunctionPointer = std::move(function_pointer);
      return Unwind(std::move(virtual_slot_type));
    }

    Attach(*function_pointer, function_pointer->Pointee, Type_());
    Attach(*virtual_slot_type, virtual_slot_type->FunctionPointer, std::move(function_pointer));
    if (Recovering()) {
      return Unwind(std::move(virtual_slot_type));
    }
    return virtual_slot_type;
  }

  if (token.type == tok::const_) {
    auto const_type = std::make_unique<ConstTypeSyntax>();
    const_type->range = token.range;
    AdvanceLexer();

    Attach(*const_type, const_type->QualifiedType, Type_());
    if (Recovering()) {
      return Unwind(std::move(const_type));
    }
    return const_type;
  }

  if (token.type == tok::amp) {
    const SourceLocation begin = token.range.begin;
    AdvanceLexer();

    ReferenceMode mode;
    switch (token.type) {
      case tok::mut:
        mode = ReferenceMode::Mut;
        break;
      case tok::copy:
        mode = ReferenceMode::Copy;
        break;
      case tok::move_:
        mode = ReferenceMode::Move;
        break;
      default: {
        HandleExpect({tok::mut, tok::copy, tok::move_});
        Unwind();
        return nullptr;
      }
    }

    auto reference_type = std::make_unique<ReferenceTypeSyntax>();
    reference_type->range = {begin, token.range.end};
    reference_type->mode = mode;
    AdvanceLexer();

    Attach(*reference_type, reference_type->ReferentType, Type_());
    if (Recovering()) {
      return Unwind(std::move(reference_type));
    }
    return reference_type;
  }

  if (token.type == tok::star) {
    auto pointer_type = std::make_unique<PointerTypeSyntax>();
    pointer_type->range = token.range;
    AdvanceLexer();

    Attach(*pointer_type, pointer_type->Pointee, Type_());
    if (Recovering()) {
      return Unwind(std::move(pointer_type));
    }
    return pointer_type;
  }

  if (token.type == tok::func) {
    auto function_type = std::make_unique<FunctionTypeSyntax>();
    function_type->range = token.range;
    AdvanceLexer();

    if (token.type != tok::l_paren) {
      HandleExpect({tok::l_paren});
      return Unwind(std::move(function_type));
    }
    ExtendRange(*function_type, token);
    AdvanceLexer();

    if (token.type != tok::r_paren) {
      for (;;) {
        Append(*function_type, function_type->ParameterTypes, Type_());
        if (Recovering()) {
          return Unwind(std::move(function_type));
        }

        if (token.type == tok::comma) {
          ExtendRange(*function_type, token);
          AdvanceLexer();
          continue;
        }
        if (token.type != tok::r_paren) {
          HandleExpect({tok::comma, tok::r_paren});
          return Unwind(std::move(function_type));
        }
        break;
      }
    }

    if (token.type != tok::r_paren) {
      HandleExpect({tok::r_paren});
      return Unwind(std::move(function_type));
    }
    ExtendRange(*function_type, token);
    AdvanceLexer();

    Attach(*function_type, function_type->ReturnType, Type_());
    if (Recovering()) {
      return Unwind(std::move(function_type));
    }

    return function_type;
  }

  if (token.type == tok::builtin_type) {
    auto builtin_type = std::make_unique<BuiltinTypeSyntax>();
    builtin_type->range = token.range;
    builtin_type->kind = token.get<BuiltinTypeProperty>().kind;
    AdvanceLexer();
    return builtin_type;
  }

  if (token.type == tok::identifier || token.type == tok::coloncolon) {
    auto named_type = std::make_unique<NamedTypeSyntax>();
    const bool complete = QualifiedName_(named_type->name);
    named_type->range = named_type->name.Range();
    if (!complete) return Unwind(std::move(named_type));
    return named_type;
  }

  HandleExpect({tok::l_square, tok::virtual_, tok::const_, tok::amp, tok::star, tok::func, tok::builtin_type,
                tok::identifier, tok::coloncolon});
  Unwind();
  return nullptr;
}

bool Parser::QualifiedName_(NameSyntax& name) {
  BOOST_ASSERT(name.empty() && !name.absolute);
  if (lexer_->Token().type == tok::coloncolon) {
    name.absolute = true;
    name.global_range = lexer_->Token().range;
    AdvanceLexer();
  }
  for (;;) {
    const auto& token = lexer_->Token();
    if (token.type != tok::identifier) {
      HandleExpect({tok::identifier});
      return false;
    }
    name.segments.push_back({token.get<IdentifierProperty>().name, token.range});
    AdvanceLexer();
    if (token.type != tok::coloncolon) return true;
    AdvanceLexer();
  }
}

void Parser::Attributes_(AttributeList& attributes) {
  auto& token = lexer_->Token();
  BOOST_ASSERT(token.type == tok::l_paren);
  AdvanceLexer();

  // Preserve the parser's existing tolerant behavior for malformed attribute
  // lists while retaining every source-level attribute name that can be
  // identified. Sema decides whether names, duplicates, and placement are
  // valid.
  while (token.type != tok::r_paren && token.type != tok::eos && token.type != tok::eof) {
    if (token.type == tok::identifier) {
      attributes.push_back({token.get<IdentifierProperty>().name, token.range});
    }
    AdvanceLexer();
  }

  if (token.type == tok::r_paren) {
    AdvanceLexer();
  }
}

void Parser::InitializeLexer() { parsed_location_ = SourceLocation{}; }

void Parser::AdvanceLexer() {
  parsed_location_ = lexer_->Token().range.end;
  lexer_->Advance();
}

void Parser::HandleExpect(std::vector<tok::TokenType> expected) {
  ReportCurrentTokenError(FormatExpectedTokens(expected));
}

void Parser::ReportCurrentTokenError(std::string message) {
  auto& token = lexer_->Token();
  if (token.type != tok::invalid && token.type != tok::eos && token.type != tok::eof) {
    diagnostic_engine_->Add(kErrorDiagnostic, token.range.begin, std::move(message), token.source_view.size());
  } else {
    diagnostic_engine_->Add(kErrorDiagnostic, parsed_location_, std::move(message));
  }
}

bool Parser::SkipUntil(tok::TokenType t, SkipUntilFlags flags) {
  return SkipUntil(std::vector<tok::TokenType>{t}, flags);
}

bool Parser::SkipUntil(tok::TokenType t1, tok::TokenType t2, SkipUntilFlags flags) {
  return SkipUntil(std::vector<tok::TokenType>{t1, t2}, flags);
}

bool Parser::SkipUntil(tok::TokenType t1, tok::TokenType t2, tok::TokenType t3, SkipUntilFlags flags) {
  return SkipUntil(std::vector<tok::TokenType>{t1, t2, t3}, flags);
}

bool Parser::SkipUntil(std::vector<tok::TokenType> toks, SkipUntilFlags flags) {
  for (;;) {
    auto& token = lexer_->Token();

    // Matched one of the sync tokens. Any closing delimiter a caller cares
    // about (e.g. r_brace / r_paren) is passed in toks and handled here, so it
    // can be left in place via kStopBeforeMatch for the enclosing layer.
    for (auto t : toks) {
      if (token.type == t) {
        if (!HasFlag(flags, SkipUntilFlags::kStopBeforeMatch)) {
          AdvanceLexer();
        }
        return true;
      }
    }

    switch (token.type) {
      case tok::eof:
      case tok::eos:
        return false;

      case tok::semi:
        if (HasFlag(flags, SkipUntilFlags::kStopAtSemi)) {
          return false;
        }
        AdvanceLexer();
        break;

      // Recursively skip properly-nested delimiters so that separators nested
      // inside them do not trigger a false sync.
      case tok::l_paren:
        AdvanceLexer();
        SkipUntil(tok::r_paren);
        break;
      case tok::l_square:
        AdvanceLexer();
        SkipUntil(tok::r_square);
        break;
      case tok::l_brace:
        AdvanceLexer();
        SkipUntil(tok::r_brace);
        break;

      default:
        // Includes stray closing delimiters that are not in toks: consume them
        // to guarantee forward progress (the delimiters a caller wants left in
        // place are always present in toks and handled by the match above).
        AdvanceLexer();
        break;
    }
  }
}

}  // namespace cw
