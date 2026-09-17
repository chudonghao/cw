/// \file Parser.h
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <memory>
#include <vector>

#include "ExprParser.h"
#include "ParseResult.h"
#include "Token.h"
#include "ast.h"

namespace cw {

class ASTContext;
class Lexer;
class DiagnosticEngine;

class Parser {
  friend class ExprParser;

  /// \brief Flags controlling the behavior of SkipUntil.
  ///
  /// Modeled after Clang's SkipUntilFlags. A strongly typed enum is used to
  /// avoid implicit conversions with tok::TokenType that would cause overload
  /// ambiguity. Values are powers of two and may be combined with operator|.
  enum class SkipUntilFlags {
    kNone = 0,
    /// Stop right before a matched sync token without consuming it, leaving it
    /// for the enclosing layer to handle.
    kStopBeforeMatch = 1 << 0,
    /// Stop when a ';' is reached, treating it as a hard statement/field
    /// boundary (the ';' is not consumed).
    kStopAtSemi = 1 << 1,
  };

  Lexer* lexer_{};
  ASTContext* ast_context_{};
  DiagnosticEngine* diagnostic_engine_{nullptr};

  /// Type_ can re-enter expression parsing; each active depth retains independent LR stacks.
  std::vector<std::unique_ptr<ExprParser>> expr_parsers_;
  std::size_t expr_parser_depth_{};
  SourceLocation parsed_location_{};

 public:
  Parser();

  void SetASTContext(ASTContext* ast_context);

  void SetDiagnosticEngine(DiagnosticEngine* diagnostic_engine);

  void SetLexer(Lexer* lexer);

  void operator()();

 private:
  // Decl parsing
  ParseResult<StructDecl> StructDecl_();
  ParseResult<VirtualDecl> VirtualDecl_();
  ParseResult<FieldDecl> FieldDecl_();
  /// \brief Parses an ordinary function declaration.
  ParseResult<FunctionDecl> FunctionDecl_();
  ParseResult<ConstructorDecl> ConstructorDecl_();
  ParseResult<DestructorDecl> DestructorDecl_();
  ParseResult<VarGroupDecl> VarGroupDecl_();
  ParseResult<ParmVarDecl> ParmVarDecl_();
  ParseResult<ReturnVarDecl> ReturnVarDecl_();

  // Stmt parsing
  ParseResult<Stmt> Stmt_();
  ParseResult<CompoundStmt> CompoundStmt_();
  ParseResult<IfStmt> IfStmt_();
  ParseResult<WhileStmt> WhileStmt_();
  ParseResult<BreakStmt> BreakStmt_();
  ParseResult<ContinueStmt> ContinueStmt_();
  ParseResult<ReturnStmt> ReturnStmt_();
  ParseResult<ExprStmt> ExprStmt_();
  ParseResult<ExprStmt> ExprStmt_(ParseResult<Expr> expr);

  ParseResult<Expr> Expr_();
  std::vector<ParseResult<Expr>> Exprs_(ParseResult<Expr> first);

  ParseResult<TypeSyntax> Type_();
  void Attributes_(AttributeList& attributes);

  // Utilities

  void InitializeLexer();
  void AdvanceLexer();
  void HandleExpect(std::vector<tok::TokenType> expected);
  void ReportCurrentTokenError(std::string message);

  /// \brief Combines two SkipUntilFlags via bitwise or.
  friend constexpr SkipUntilFlags operator|(SkipUntilFlags l, SkipUntilFlags r) {
    return static_cast<SkipUntilFlags>(static_cast<int>(l) | static_cast<int>(r));
  }

  /// \brief Returns true when \p flag is set in \p flags.
  static constexpr bool HasFlag(SkipUntilFlags flags, SkipUntilFlags flag) {
    return (static_cast<int>(flags) & static_cast<int>(flag)) != 0;
  }

  /// \brief Skips tokens until one of \p toks is reached (primary overload).
  ///
  /// Balances (), [] and {} delimiters while skipping so that separators nested
  /// inside them do not trigger a false sync. A current match with
  /// kStopBeforeMatch, a semicolon with kStopAtSemi, or end of sources is
  /// left unconsumed; callers must handle these boundaries before retrying.
  ///
  /// \param toks Sync tokens to stop at (do not include ';'; use kStopAtSemi).
  /// \param flags Behavior flags; see SkipUntilFlags.
  /// \return true if one of \p toks was matched; false if stopped at ';'
  ///         (kStopAtSemi) or end of sources.
  bool SkipUntil(std::vector<tok::TokenType> toks, SkipUntilFlags flags = SkipUntilFlags::kNone);
  bool SkipUntil(tok::TokenType t, SkipUntilFlags flags = SkipUntilFlags::kNone);
  bool SkipUntil(tok::TokenType t1, tok::TokenType t2, SkipUntilFlags flags = SkipUntilFlags::kNone);
  bool SkipUntil(tok::TokenType t1, tok::TokenType t2, tok::TokenType t3, SkipUntilFlags flags = SkipUntilFlags::kNone);
};

}  // namespace cw
