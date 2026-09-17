/// \file Parser.cpp
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "Parser.h"

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

/// \brief Returns true when \p type starts source-level type syntax.
bool IsTypeStart(tok::TokenType type) {
  return type == tok::l_square || type == tok::virtual_ || type == tok::const_ || type == tok::mut ||
         type == tok::copy || type == tok::move_ || type == tok::star || type == tok::func ||
         type == tok::builtin_type || type == tok::identifier;
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
  for (;;) {
    auto& token = lexer_->Token();

    ParseResult<Decl> Decl;

    if (token.type == tok::struct_ || token.type == tok::trivial_) {
      Decl = StructDecl_();
    } else if (token.type == tok::func) {
      Decl = FunctionDecl_();
    } else if (token.type == tok::ctor) {
      Decl = ConstructorDecl_();
    } else if (token.type == tok::dtor) {
      Decl = DestructorDecl_();
    } else if (token.type == tok::var) {
      Decl = VarGroupDecl_();
    } else if (token.type == tok::eos) {
      return;
    } else {
      HandleExpect({tok::trivial_, tok::struct_, tok::func, tok::ctor, tok::dtor, tok::var});
      Decl.Invalidate();
    }

    translation_unit->contains_errors |= Decl.ContainsErrors();
    if (Decl.Get()) {
      translation_unit->Decls.push_back(Decl.Take());
    }
    if (Decl.Incomplete()) {
      // Sync to the start of the next top-level declaration. CW top-level
      // declarations start with a keyword and do not rely on ';'.
      SkipUntil({tok::trivial_, tok::struct_, tok::func, tok::ctor, tok::dtor, tok::var},
                SkipUntilFlags::kStopBeforeMatch);
    }
  }
}

ParseResult<StructDecl> Parser::StructDecl_() {
  auto sd = MakeNode<StructDecl>();
  auto& token = lexer_->Token();
  BeginRange(*sd, token, parsed_location_);

  if (token.type == tok::trivial_) {
    sd->is_declared_trivial = true;
    AdvanceLexer();
  }

  if (token.type != tok::struct_) {
    HandleExpect({tok::struct_});
    return sd.Invalidate();
  }
  AdvanceLexer();

  if (token.type != tok::identifier) {
    HandleExpect({tok::identifier});
    return sd.Invalidate();
  }
  sd->name = token.get<IdentifierProperty>().name;
  sd->name_range = token.range;
  ExtendRange(*sd, token);
  AdvanceLexer();

  // [ ":" Identifier ] - inheritance
  if (token.type == tok::colon) {
    ExtendRange(*sd, token);
    AdvanceLexer();
    if (token.type != tok::identifier) {
      HandleExpect({tok::identifier});
      return sd.Invalidate();
    }
    sd->base = token.get<IdentifierProperty>().name;
    sd->base_range = token.range;
    ExtendRange(*sd, token);
    AdvanceLexer();
  }

  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return sd.Invalidate();
  }
  ExtendRange(*sd, token);
  AdvanceLexer();

  // [ VirtualDecl ] { FieldDecl }
  if (token.type == tok::virtual_) {
    auto r = VirtualDecl_();
    sd->contains_errors |= r.ContainsErrors();
    ExtendRange(*sd, r.Get());
    sd->VirtualDecl = r.Take();
    if (r.Incomplete()) {
      // Required substructure failed: bubble up for the enclosing loop layer.
      return sd.Invalidate();
    }
  }

  while (token.type == tok::identifier) {
    auto field = FieldDecl_();
    sd->contains_errors |= field.ContainsErrors();
    ExtendRange(*sd, field.Get());
    if (field.Get()) {
      sd->Fields.push_back(field.Take());
    }
    if (field.Incomplete()) {
      // Field error: sync within the struct body and keep parsing fields. Stop
      // before ';' (field separator, consumed here) or '}' (left to closing).
      SkipUntil(tok::r_brace, SkipUntilFlags::kStopAtSemi | SkipUntilFlags::kStopBeforeMatch);
      if (token.type == tok::semi) {
        AdvanceLexer();
      } else {
        break;
      }
    }
  }

  if (token.type != tok::r_brace) {
    HandleExpect({tok::r_brace});
    return sd.Invalidate();
  }
  ExtendRange(*sd, token);
  AdvanceLexer();

  return sd;
}

ParseResult<VirtualDecl> Parser::VirtualDecl_() {
  auto vd = MakeNode<VirtualDecl>();
  auto& token = lexer_->Token();
  BeginRange(*vd, token, parsed_location_);

  if (token.type != tok::virtual_) {
    HandleExpect({tok::virtual_});
    return vd.Invalidate();
  }
  AdvanceLexer();

  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return vd.Invalidate();
  }
  ExtendRange(*vd, token);
  AdvanceLexer();

  // { { "override" | "abstract" } "func" Identifier "(" ParamDecls ")" [ ReturnDecl ] ";" }
  while (token.type == tok::func || token.type == tok::override_ || token.type == tok::abstract_) {
    auto fd = MakeNode<VirtualFunctionDecl>();
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
        auto parm = ParmVarDecl_();
        fd->contains_errors |= parm.ContainsErrors();
        ExtendRange(*fd, parm.Get());
        if (parm.Get()) {
          fd->ParmVars.push_back(parm.Take());
        }
        if (parm.Incomplete()) {
          // Param error: sync to the next param or end of the list.
          SkipUntil(tok::comma, tok::r_paren, SkipUntilFlags::kStopAtSemi | SkipUntilFlags::kStopBeforeMatch);
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
      auto rr = ReturnVarDecl_();
      fd->contains_errors |= rr.ContainsErrors();
      ExtendRange(*fd, rr.Get());
      fd->ReturnVar = rr.Take();
      if (rr.Incomplete()) {
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
      fd->contains_errors = true;
      SkipUntil(tok::r_brace, SkipUntilFlags::kStopAtSemi | SkipUntilFlags::kStopBeforeMatch);
      if (token.type == tok::semi) {
        ExtendRange(*fd, token);
        AdvanceLexer();
      }
    }

    vd->contains_errors |= fd.ContainsErrors();
    ExtendRange(*vd, fd.Get());
    vd->Functions.push_back(fd.Take());
  }

  if (token.type != tok::r_brace) {
    HandleExpect({tok::r_brace});
    return vd.Invalidate();
  }
  ExtendRange(*vd, token);
  AdvanceLexer();

  return vd;
}

ParseResult<FieldDecl> Parser::FieldDecl_() {
  auto fd = MakeNode<FieldDecl>();
  auto& token = lexer_->Token();
  BeginRange(*fd, token, parsed_location_);

  if (token.type != tok::identifier) {
    HandleExpect({tok::identifier});
    return fd.Invalidate();
  }
  fd->name = token.get<IdentifierProperty>().name;
  fd->name_range = token.range;
  AdvanceLexer();

  // Type
  auto type = Type_();
  fd->contains_errors |= type.ContainsErrors();
  ExtendRange(*fd, type.Get());
  fd->Type = type.Take();
  if (type.Incomplete()) {
    return fd.Invalidate();
  }

  if (token.type != tok::semi) {
    HandleExpect({tok::semi});
    return fd.Invalidate();
  }
  ExtendRange(*fd, token);
  AdvanceLexer();

  return fd;
}

ParseResult<FunctionDecl> Parser::FunctionDecl_() {
  auto& token = lexer_->Token();
  auto fd = MakeNode<FunctionDecl>();
  BeginRange(*fd, token, parsed_location_);

  if (token.type != tok::func) {
    HandleExpect({tok::func});
    return fd.Invalidate();
  }
  AdvanceLexer();

  // [ Identifier | "operator" Operator ]
  if (token.type == tok::operator_) {
    fd->name_range = token.range;
    ExtendRange(*fd, token);
    AdvanceLexer();
    if (token.type == tok::invalid || token.type == tok::eos) {
      HandleExpect({tok::l_paren});
      return fd.Invalidate();
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
        return fd.Invalidate();
      }
      fd->name_range.end = token.range.end;
      ExtendRange(*fd, token);
      AdvanceLexer();
    } else {
      // Other overloadable operators have a single-token spelling.
      const std::string operator_name(token.source_view);
      if (!IsOperatorFunctionName(operator_name)) {
        HandleExpect({tok::l_paren});
        return fd.Invalidate();
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
    return fd.Invalidate();
  }
  ExtendRange(*fd, token);
  AdvanceLexer();

  // ParamDecls
  if (token.type != tok::r_paren) {
    for (;;) {
      auto parm = ParmVarDecl_();
      fd->contains_errors |= parm.ContainsErrors();
      ExtendRange(*fd, parm.Get());
      if (parm.Get()) {
        fd->ParmVars.push_back(parm.Take());
      }
      if (parm.Incomplete()) {
        // Param error: sync to the next param or end of the list.
        SkipUntil(tok::comma, tok::r_paren, SkipUntilFlags::kStopAtSemi | SkipUntilFlags::kStopBeforeMatch);
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
    return fd.Invalidate();
  }
  ExtendRange(*fd, token);
  AdvanceLexer();

  // ReturnDecl (optional)
  if (token.type != tok::l_brace) {
    auto rr = ReturnVarDecl_();
    fd->contains_errors |= rr.ContainsErrors();
    ExtendRange(*fd, rr.Get());
    fd->ReturnVar = rr.Take();
    if (rr.Incomplete() && token.type != tok::l_brace) {
      return fd.Invalidate();
    }
  }

  // CompoundStmt
  {
    auto r = CompoundStmt_();
    fd->contains_errors |= r.ContainsErrors();
    ExtendRange(*fd, r.Get());
    fd->Body = r.Take();
    if (r.Incomplete()) {
      // Required substructure failed: bubble up for the enclosing loop layer.
      return fd.Invalidate();
    }
  }

  return fd;
}

ParseResult<ConstructorDecl> Parser::ConstructorDecl_() {
  auto declaration = MakeNode<ConstructorDecl>();
  auto& token = lexer_->Token();
  BeginRange(*declaration, token, parsed_location_);

  if (token.type != tok::ctor) {
    HandleExpect({tok::ctor});
    return declaration.Invalidate();
  }
  AdvanceLexer();

  if (token.type != tok::identifier) {
    HandleExpect({tok::identifier});
    return declaration.Invalidate();
  }
  declaration->name = token.get<IdentifierProperty>().name;
  declaration->name_range = token.range;
  ExtendRange(*declaration, token);
  AdvanceLexer();

  // "(" ParamDecls ")"
  if (token.type != tok::l_paren) {
    HandleExpect({tok::l_paren});
    return declaration.Invalidate();
  }
  ExtendRange(*declaration, token);
  AdvanceLexer();

  if (token.type != tok::r_paren) {
    for (;;) {
      auto parm = ParmVarDecl_();
      declaration->contains_errors |= parm.ContainsErrors();
      ExtendRange(*declaration, parm.Get());
      if (parm.Get()) {
        declaration->ParmVars.push_back(parm.Take());
      }
      if (parm.Incomplete()) {
        // Param error: sync to the next param or end of the list.
        SkipUntil(tok::comma, tok::r_paren, SkipUntilFlags::kStopAtSemi | SkipUntilFlags::kStopBeforeMatch);
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
    return declaration.Invalidate();
  }
  ExtendRange(*declaration, token);
  AdvanceLexer();

  // CompoundStmt
  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return declaration.Invalidate();
  }

  {
    auto r = CompoundStmt_();
    declaration->contains_errors |= r.ContainsErrors();
    ExtendRange(*declaration, r.Get());
    declaration->Body = r.Take();
    if (r.Incomplete()) {
      return declaration.Invalidate();
    }
  }

  return declaration;
}

ParseResult<DestructorDecl> Parser::DestructorDecl_() {
  auto declaration = MakeNode<DestructorDecl>();
  auto& token = lexer_->Token();
  BeginRange(*declaration, token, parsed_location_);

  if (token.type != tok::dtor) {
    HandleExpect({tok::dtor});
    return declaration.Invalidate();
  }
  AdvanceLexer();

  if (token.type != tok::identifier) {
    HandleExpect({tok::identifier});
    return declaration.Invalidate();
  }
  declaration->name = token.get<IdentifierProperty>().name;
  declaration->name_range = token.range;
  ExtendRange(*declaration, token);
  AdvanceLexer();

  // "(" ")"
  if (token.type != tok::l_paren) {
    HandleExpect({tok::l_paren});
    return declaration.Invalidate();
  }
  ExtendRange(*declaration, token);
  AdvanceLexer();

  if (token.type != tok::r_paren) {
    HandleExpect({tok::r_paren});
    return declaration.Invalidate();
  }
  ExtendRange(*declaration, token);
  AdvanceLexer();

  // CompoundStmt
  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return declaration.Invalidate();
  }

  {
    auto r = CompoundStmt_();
    declaration->contains_errors |= r.ContainsErrors();
    ExtendRange(*declaration, r.Get());
    declaration->Body = r.Take();
    if (r.Incomplete()) {
      return declaration.Invalidate();
    }
  }

  return declaration;
}

ParseResult<VarGroupDecl> Parser::VarGroupDecl_() {
  auto group = MakeNode<VarGroupDecl>();
  auto& token = lexer_->Token();
  BeginRange(*group, token, parsed_location_);

  if (token.type != tok::var) {
    HandleExpect({tok::var});
    return group.Invalidate();
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
      return group.Invalidate();
    }

    auto variable = MakeNode<VarDecl>();
    variable->name = token.get<IdentifierProperty>().name;
    variable->range = token.range;
    variable->name_range = token.range;
    variable->attributes = attributes;
    VarDecl* variable_decl = variable.Get();
    group->Vars.push_back(variable.Take());
    ExtendRange(*group, token);
    AdvanceLexer();

    if (IsTypeStart(token.type)) {
      auto type = Type_();
      variable_decl->contains_errors |= type.ContainsErrors();
      group->contains_errors |= type.ContainsErrors();
      ExtendRange(*variable_decl, type.Get());
      ExtendRange(*group, type.Get());
      variable_decl->Type = type.Take();
      if (type.Incomplete()) {
        return group.Invalidate();
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
      auto r = CompoundStmt_();
      group->contains_errors |= r.ContainsErrors();
      ExtendRange(*group, r.Get());
      group->Body = r.Take();
      if (r.Incomplete()) {
        return group.Invalidate();
      }
      return group;
    }

    {
      // Required init expression: Expr_() always yields a node (RecoveryExpr on failure).
      auto r = Expr_();
      group->contains_errors |= r.ContainsErrors();
      ExtendRange(*group, r.Get());
      group->InitExprs.push_back(r.Take());
      if (r.Incomplete()) {
        return group.Invalidate();
      }
    }
    while (token.type == tok::comma) {
      ExtendRange(*group, token);
      AdvanceLexer();
      auto r = Expr_();
      group->contains_errors |= r.ContainsErrors();
      ExtendRange(*group, r.Get());
      group->InitExprs.push_back(r.Take());
      if (r.Incomplete()) {
        return group.Invalidate();
      }
    }

    if (token.type != tok::semi) {
      HandleExpect({tok::semi});
      return group.Invalidate();
    }
    ExtendRange(*group, token);
    AdvanceLexer();
  } else if (token.type == tok::semi) {
    ExtendRange(*group, token);
    AdvanceLexer();
  } else {
    HandleExpect({tok::colonequal, tok::semi});
    return group.Invalidate();
  }

  return group;
}

ParseResult<ParmVarDecl> Parser::ParmVarDecl_() {
  auto pd = MakeNode<ParmVarDecl>();
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
    return pd.Invalidate();
  }

  auto type = Type_();
  pd->contains_errors |= type.ContainsErrors();
  ExtendRange(*pd, type.Get());
  pd->Type = type.Take();
  if (type.Incomplete()) {
    return pd.Invalidate();
  }

  return pd;
}

ParseResult<ReturnVarDecl> Parser::ReturnVarDecl_() {
  auto rd = MakeNode<ReturnVarDecl>();
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
      return rd.Invalidate();
    }
    rd->name = token.get<IdentifierProperty>().name;
    rd->name_range = token.range;
    ExtendRange(*rd, token);
    AdvanceLexer();
  }

  auto type = Type_();
  rd->contains_errors |= type.ContainsErrors();
  ExtendRange(*rd, type.Get());
  rd->Type = type.Take();
  if (type.Incomplete()) {
    return rd.Invalidate();
  }

  return rd;
}

// Stmt parsing

ParseResult<Stmt> Parser::Stmt_() {
  auto& token = lexer_->Token();

  if (token.type == tok::l_brace) {
    return CompoundStmt_();
  } else if (token.type == tok::var) {
    auto ds = MakeNode<DeclStmt>();
    auto r = VarGroupDecl_();
    ds->contains_errors |= r.ContainsErrors();
    ds->Decl = r.Take();
    if (ds->Decl) {
      ds->range = ds->Decl->range;
    }
    if (r.Incomplete()) {
      return ds.Invalidate();
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

ParseResult<CompoundStmt> Parser::CompoundStmt_() {
  auto cs = MakeNode<CompoundStmt>();
  auto& token = lexer_->Token();
  BeginRange(*cs, token, parsed_location_);

  if (token.type != tok::l_brace) {
    HandleExpect({tok::l_brace});
    return cs.Invalidate();
  }
  AdvanceLexer();

  // { Stmt } [ Exprs ] "}"
  while (token.type != tok::r_brace && token.type != tok::eos) {
    if (IsKeywordStmtStart(token.type) || IsCompoundStmtStart(token.type)) {
      // Statement dispatched by its leading token.
      auto stmt = Stmt_();
      cs->contains_errors |= stmt.ContainsErrors();
      ExtendRange(*cs, stmt.Get());
      if (stmt.Get()) {
        cs->Stmts.push_back(stmt.Take());
      }
      if (stmt.Complete()) {
        continue;
      }
      // Statement error falls through to the recovery point below.
    } else {
      // Expression-led item: ExprStmt (ends with ';') or tail Exprs (',' / '}').
      auto expr = Expr_();  // always yields a node (RecoveryExpr on failure)
      if (expr.Complete()) {
        if (token.type == tok::semi) {
          auto es = ExprStmt_(std::move(expr));
          cs->contains_errors |= es.ContainsErrors();
          ExtendRange(*cs, es.Get());
          cs->Stmts.push_back(es.Take());
          continue;
        }
        // Tail expressions are the last items in the block.
        auto exprs = Exprs_(std::move(expr));
        const bool tail_complete = exprs.back().Complete();
        for (auto& e : exprs) {
          cs->contains_errors |= e.ContainsErrors();
          ExtendRange(*cs, e.Get());
          cs->TailExprs.push_back(e.Take());
        }
        if (tail_complete) {
          break;
        }
        // Tail error falls through to the recovery point below.
      } else {
        // Expr_ failed: retain the RecoveryExpr as a tail expr, then recover.
        cs->contains_errors |= expr.ContainsErrors();
        ExtendRange(*cs, expr.Get());
        cs->TailExprs.push_back(expr.Take());
      }
    }

    // Single recovery point: reached only on a parse error this iteration.
    SkipUntil(tok::r_brace, SkipUntilFlags::kStopAtSemi | SkipUntilFlags::kStopBeforeMatch);
    if (token.type != tok::semi) {
      break;
    }
    AdvanceLexer();
  }

  if (token.type != tok::r_brace) {
    HandleExpect({tok::r_brace});
    return cs.Invalidate();
  }
  ExtendRange(*cs, token);
  AdvanceLexer();

  return cs;
}

ParseResult<IfStmt> Parser::IfStmt_() {
  auto is = MakeNode<IfStmt>();
  auto& token = lexer_->Token();
  BeginRange(*is, token, parsed_location_);

  if (token.type != tok::if_) {
    HandleExpect({tok::if_});
    return is.Invalidate();
  }
  AdvanceLexer();

  // Expr (required condition slot: Expr_() always yields a node)
  {
    auto r = Expr_();
    is->contains_errors |= r.ContainsErrors();
    ExtendRange(*is, r.Get());
    is->Cond = r.Take();
    if (r.Incomplete()) {
      return is.Invalidate();
    }
  }

  // CompoundStmt
  {
    auto r = CompoundStmt_();
    is->contains_errors |= r.ContainsErrors();
    ExtendRange(*is, r.Get());
    is->Then = r.Take();
    if (r.Incomplete()) {
      return is.Invalidate();
    }
  }

  // [ "else" CompoundStmt ]
  if (token.type == tok::else_) {
    ExtendRange(*is, token);
    AdvanceLexer();
    auto r = CompoundStmt_();
    is->contains_errors |= r.ContainsErrors();
    ExtendRange(*is, r.Get());
    is->Else = r.Take();
    if (r.Incomplete()) {
      return is.Invalidate();
    }
  }

  return is;
}

ParseResult<WhileStmt> Parser::WhileStmt_() {
  auto ws = MakeNode<WhileStmt>();
  auto& token = lexer_->Token();
  BeginRange(*ws, token, parsed_location_);

  if (token.type != tok::while_) {
    HandleExpect({tok::while_});
    return ws.Invalidate();
  }
  AdvanceLexer();

  // Expr (required condition slot: Expr_() always yields a node)
  {
    auto r = Expr_();
    ws->contains_errors |= r.ContainsErrors();
    ExtendRange(*ws, r.Get());
    ws->Cond = r.Take();
    if (r.Incomplete()) {
      return ws.Invalidate();
    }
  }

  // CompoundStmt
  {
    auto r = CompoundStmt_();
    ws->contains_errors |= r.ContainsErrors();
    ExtendRange(*ws, r.Get());
    ws->Body = r.Take();
    if (r.Incomplete()) {
      return ws.Invalidate();
    }
  }

  return ws;
}

ParseResult<BreakStmt> Parser::BreakStmt_() {
  auto bs = MakeNode<BreakStmt>();
  auto& token = lexer_->Token();
  BeginRange(*bs, token, parsed_location_);

  if (token.type != tok::break_) {
    HandleExpect({tok::break_});
    return bs.Invalidate();
  }
  AdvanceLexer();

  if (token.type != tok::semi) {
    HandleExpect({tok::semi});
    return bs.Invalidate();
  }
  ExtendRange(*bs, token);
  AdvanceLexer();

  return bs;
}

ParseResult<ContinueStmt> Parser::ContinueStmt_() {
  auto cs = MakeNode<ContinueStmt>();
  auto& token = lexer_->Token();
  BeginRange(*cs, token, parsed_location_);

  if (token.type != tok::continue_) {
    HandleExpect({tok::continue_});
    return cs.Invalidate();
  }
  AdvanceLexer();

  if (token.type != tok::semi) {
    HandleExpect({tok::semi});
    return cs.Invalidate();
  }
  ExtendRange(*cs, token);
  AdvanceLexer();

  return cs;
}

ParseResult<ReturnStmt> Parser::ReturnStmt_() {
  auto rs = MakeNode<ReturnStmt>();
  auto& token = lexer_->Token();
  BeginRange(*rs, token, parsed_location_);

  if (token.type != tok::return_) {
    HandleExpect({tok::return_});
    return rs.Invalidate();
  }
  AdvanceLexer();

  // [ Expr ] (when present, Expr_() always yields a node)
  if (token.type != tok::semi) {
    auto r = Expr_();
    rs->contains_errors |= r.ContainsErrors();
    ExtendRange(*rs, r.Get());
    rs->Expr = r.Take();
    if (r.Incomplete()) {
      return rs.Invalidate();
    }
  }

  if (token.type != tok::semi) {
    HandleExpect({tok::semi});
    return rs.Invalidate();
  }
  ExtendRange(*rs, token);
  AdvanceLexer();

  return rs;
}

ParseResult<ExprStmt> Parser::ExprStmt_() { return ExprStmt_(Expr_()); }

ParseResult<ExprStmt> Parser::ExprStmt_(ParseResult<Expr> expr) {
  // Precondition: expr is non-null (callers pass Expr_() results, which always yield a node).
  auto es = MakeNode<ExprStmt>();
  es->contains_errors |= expr.ContainsErrors();
  es->Expr = expr.Take();
  if (es->Expr) {
    es->range = es->Expr->range;
  }
  if (expr.Incomplete()) {
    return es.Invalidate();
  }

  auto& token = lexer_->Token();
  if (token.type != tok::semi) {
    HandleExpect({tok::semi});
    return es.Invalidate();
  }
  ExtendRange(*es, token);
  AdvanceLexer();

  return es;
}

ParseResult<Expr> Parser::Expr_() {
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
    return ParseResult<Expr>(std::move(e));
  }

  auto recovery = MakeNode<RecoveryExpr>();
  recovery->range = {expression_begin, expression_begin};
  return recovery.Invalidate();
}

std::vector<ParseResult<Expr>> Parser::Exprs_(ParseResult<Expr> first) {
  std::vector<ParseResult<Expr>> exprs;
  exprs.push_back(std::move(first));

  auto& token = lexer_->Token();
  while (token.type == tok::comma) {
    AdvanceLexer();
    auto expr = Expr_();
    exprs.push_back(std::move(expr));
    if (exprs.back().Incomplete()) {
      break;
    }
  }

  return exprs;
}

ParseResult<TypeSyntax> Parser::Type_() {
  auto& token = lexer_->Token();

  if (token.type == tok::l_square) {
    auto array_type = MakeNode<ArrayTypeSyntax>();
    array_type->range = token.range;
    array_type->left_bracket_range = token.range;
    AdvanceLexer();

    auto length = Expr_();
    array_type->contains_errors |= length.ContainsErrors();
    ExtendRange(*array_type, length.Get());
    array_type->Length = length.Take();
    if (length.Incomplete()) {
      return array_type.Invalidate();
    }

    if (token.type != tok::r_square) {
      HandleExpect({tok::r_square});
      return array_type.Invalidate();
    }
    array_type->right_bracket_range = token.range;
    ExtendRange(*array_type, token);
    AdvanceLexer();

    auto element_type = Type_();
    array_type->contains_errors |= element_type.ContainsErrors();
    ExtendRange(*array_type, element_type.Get());
    array_type->ElementType = element_type.Take();
    if (element_type.Incomplete()) {
      return array_type.Invalidate();
    }
    return array_type;
  }

  if (token.type == tok::virtual_) {
    auto virtual_slot_type = MakeNode<VirtualSlotTypeSyntax>();
    virtual_slot_type->range = token.range;
    virtual_slot_type->virtual_range = token.range;
    AdvanceLexer();

    if (token.type != tok::star) {
      HandleExpect({tok::star});
      return virtual_slot_type.Invalidate();
    }

    auto function_pointer = MakeNode<PointerTypeSyntax>();
    function_pointer->range = token.range;
    AdvanceLexer();
    if (token.type != tok::func) {
      HandleExpect({tok::func});
      virtual_slot_type->FunctionPointer = function_pointer.Take();
      return virtual_slot_type.Invalidate();
    }

    auto function_type = Type_();
    function_pointer->contains_errors |= function_type.ContainsErrors();
    if (function_type.Get()) {
      function_pointer->range.end = function_type->range.end;
      function_pointer->Pointee = function_type.Take();
    }
    virtual_slot_type->contains_errors |= function_pointer.ContainsErrors();
    virtual_slot_type->range.end = function_pointer->range.end;
    virtual_slot_type->FunctionPointer = function_pointer.Take();
    if (function_type.Incomplete()) {
      return virtual_slot_type.Invalidate();
    }
    return virtual_slot_type;
  }

  if (token.type == tok::const_) {
    auto const_type = MakeNode<ConstTypeSyntax>();
    const_type->range = token.range;
    AdvanceLexer();

    auto qualified_type = Type_();
    const_type->contains_errors |= qualified_type.ContainsErrors();
    if (qualified_type.Get()) {
      const_type->range.end = qualified_type->range.end;
      const_type->QualifiedType = qualified_type.Take();
    }
    if (qualified_type.Incomplete()) {
      return const_type.Invalidate();
    }
    return const_type;
  }

  if (token.type == tok::mut || token.type == tok::copy || token.type == tok::move_) {
    auto reference_type = MakeNode<ReferenceTypeSyntax>();
    reference_type->range = token.range;
    switch (token.type) {
      case tok::mut:
        reference_type->mode = ReferenceMode::Mut;
        break;
      case tok::copy:
        reference_type->mode = ReferenceMode::Copy;
        break;
      case tok::move_:
        reference_type->mode = ReferenceMode::Move;
        break;
      default:
        BOOST_ASSERT(false && "unsupported reference prefix");
    }
    AdvanceLexer();

    auto referent_type = Type_();
    reference_type->contains_errors |= referent_type.ContainsErrors();
    if (referent_type.Get()) {
      reference_type->range.end = referent_type->range.end;
      reference_type->ReferentType = referent_type.Take();
    }
    if (referent_type.Incomplete()) {
      return reference_type.Invalidate();
    }
    return reference_type;
  }

  if (token.type == tok::star) {
    auto pointer_type = MakeNode<PointerTypeSyntax>();
    pointer_type->range = token.range;
    AdvanceLexer();

    auto pointee = Type_();
    pointer_type->contains_errors |= pointee.ContainsErrors();
    if (pointee.Get()) {
      pointer_type->range.end = pointee->range.end;
      pointer_type->Pointee = pointee.Take();
    }
    if (pointee.Incomplete()) {
      return pointer_type.Invalidate();
    }
    return pointer_type;
  }

  if (token.type == tok::func) {
    auto function_type = MakeNode<FunctionTypeSyntax>();
    function_type->range = token.range;
    AdvanceLexer();

    if (token.type != tok::l_paren) {
      HandleExpect({tok::l_paren});
      return function_type.Invalidate();
    }
    ExtendRange(*function_type, token);
    AdvanceLexer();

    if (token.type != tok::r_paren) {
      for (;;) {
        auto parameter_type = Type_();
        function_type->contains_errors |= parameter_type.ContainsErrors();
        ExtendRange(*function_type, parameter_type.Get());
        if (parameter_type.Get()) {
          function_type->ParameterTypes.push_back(parameter_type.Take());
        }
        if (parameter_type.Incomplete()) {
          return function_type.Invalidate();
        }

        if (token.type == tok::comma) {
          ExtendRange(*function_type, token);
          AdvanceLexer();
          continue;
        }
        if (token.type != tok::r_paren) {
          HandleExpect({tok::comma, tok::r_paren});
          return function_type.Invalidate();
        }
        break;
      }
    }

    if (token.type != tok::r_paren) {
      HandleExpect({tok::r_paren});
      return function_type.Invalidate();
    }
    ExtendRange(*function_type, token);
    AdvanceLexer();

    auto return_type = Type_();
    function_type->contains_errors |= return_type.ContainsErrors();
    ExtendRange(*function_type, return_type.Get());
    function_type->ReturnType = return_type.Take();
    if (return_type.Incomplete()) {
      return function_type.Invalidate();
    }

    return function_type;
  }

  if (token.type == tok::builtin_type) {
    auto builtin_type = MakeNode<BuiltinTypeSyntax>();
    builtin_type->range = token.range;
    builtin_type->kind = token.get<BuiltinTypeProperty>().kind;
    AdvanceLexer();
    return builtin_type;
  }

  if (token.type == tok::identifier) {
    auto named_type = MakeNode<NamedTypeSyntax>();
    named_type->range = token.range;
    named_type->name = token.get<IdentifierProperty>().name;
    AdvanceLexer();
    return named_type;
  }

  HandleExpect({tok::l_square, tok::virtual_, tok::const_, tok::mut, tok::copy, tok::move_, tok::star, tok::func,
                tok::builtin_type, tok::identifier});
  ParseResult<TypeSyntax> type;
  return type.Invalidate();
}

void Parser::Attributes_(AttributeList& attributes) {
  auto& token = lexer_->Token();
  BOOST_ASSERT(token.type == tok::l_paren);
  AdvanceLexer();

  // Preserve the parser's existing tolerant behavior for malformed attribute
  // lists while retaining every source-level attribute name that can be
  // identified. Sema decides whether names, duplicates, and placement are
  // valid.
  while (token.type != tok::r_paren && token.type != tok::eos) {
    if (token.type == tok::identifier) {
      attributes.push_back({token.get<IdentifierProperty>().name, token.range});
    }
    AdvanceLexer();
  }

  if (token.type == tok::r_paren) {
    AdvanceLexer();
  }
}

void Parser::InitializeLexer() {
  parsed_location_ = SourceLocation{};
  // skip blank and comment in the beginning
  lexer_->SkipBlankComment();
}

void Parser::AdvanceLexer() {
  parsed_location_ = lexer_->Token().range.end;
  lexer_->Advance();
}

void Parser::HandleExpect(std::vector<tok::TokenType> expected) {
  ReportCurrentTokenError(FormatExpectedTokens(expected));
}

void Parser::ReportCurrentTokenError(std::string message) {
  auto sources = lexer_->Sources();
  auto& token = lexer_->Token();

  std::filesystem::path path;
  int line = 0;
  int column = 0;
  std::string line_source;
  int size = 0;

  if (token.type != tok::invalid && token.type != tok::eos) {
    auto& loc = token.range.begin;
    if (0 <= loc.file && loc.file < static_cast<int>(sources->size())) {
      path = (*sources)[loc.file].path;
      line_source = LineSource((*sources)[loc.file], loc.pos);
      line = loc.line;
      column = loc.column;
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

  diagnostic_engine_->Add(kErrorDiagnostic, path, line, column, std::move(message), line_source, size);
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
