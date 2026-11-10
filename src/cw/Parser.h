/// \file Parser.h
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <memory>
#include <string>
#include <vector>

#include "ExprParser.h"
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
  /// True after a parse error until the nearest enclosing recovery point synchronizes.
  bool recovering_{};

 public:
  Parser();

  void SetASTContext(ASTContext* ast_context);

  void SetDiagnosticEngine(DiagnosticEngine* diagnostic_engine);

  void SetLexer(Lexer* lexer);

  void operator()();

 private:
  // Decl parsing
  /// \brief Parses one declaration at translation-unit or namespace scope, including its modifier.
  std::unique_ptr<Decl> Decl_();
  /// \brief Parses one namespace layer beginning at 'namespace' or a nested '::'.
  /// Qualified namespace headers produce one node per name.
  std::unique_ptr<NamespaceDecl> NamespaceDecl_();
  std::unique_ptr<StructDecl> StructDecl_();
  std::unique_ptr<VirtualDecl> VirtualDecl_();
  std::unique_ptr<FieldDecl> FieldDecl_();
  /// \brief Parses an ordinary function declaration.
  std::unique_ptr<FunctionDecl> FunctionDecl_(DeclModifier modifier);
  std::unique_ptr<ConstructorDecl> ConstructorDecl_(DeclModifier modifier);
  std::unique_ptr<DestructorDecl> DestructorDecl_(DeclModifier modifier);
  std::unique_ptr<VarGroupDecl> VarGroupDecl_();
  std::unique_ptr<ParmVarDecl> ParmVarDecl_();
  std::unique_ptr<ReturnVarDecl> ReturnVarDecl_();

  // Stmt parsing
  std::unique_ptr<Stmt> Stmt_();
  std::unique_ptr<CompoundStmt> CompoundStmt_();
  std::unique_ptr<IfStmt> IfStmt_();
  std::unique_ptr<WhileStmt> WhileStmt_();
  std::unique_ptr<BreakStmt> BreakStmt_();
  std::unique_ptr<ContinueStmt> ContinueStmt_();
  std::unique_ptr<ReturnStmt> ReturnStmt_();
  std::unique_ptr<ExprStmt> ExprStmt_();
  std::unique_ptr<ExprStmt> ExprStmt_(std::unique_ptr<Expr> expr);

  std::unique_ptr<Expr> Expr_();
  std::vector<std::unique_ptr<Expr>> Exprs_(std::unique_ptr<Expr> first);

  // Type and name parsing
  std::unique_ptr<TypeSyntax> Type_();
  /// \brief Parses [ "::" ] Identifier { "::" Identifier } into an empty name.
  /// Returns false after diagnosing an incomplete name, retaining the parsed prefix.
  bool QualifiedName_(NameSyntax& name);

  void Attributes_(AttributeList& attributes);

  // Error recovery
  //
  // A parse error that the current construct cannot handle locally unwinds the parser: each
  // enclosing parse function returns as soon as it observes Recovering(), until the nearest
  // recovery point skips to a synchronization token and calls FinishRecovery().

  /// \brief Enters error recovery without a node, as when no construct could be started.
  void Unwind() { recovering_ = true; }
  /// \brief Marks \p node as containing errors, enters error recovery, and returns \p node.
  template <class T>
  std::unique_ptr<T> Unwind(std::unique_ptr<T> node) {
    if (node) {
      node->contains_errors = true;
    }
    Unwind();
    return node;
  }
  /// \brief Returns true while parsing unwinds to the nearest recovery point.
  bool Recovering() const { return recovering_; }
  /// \brief Leaves error recovery once a recovery point has synchronized.
  void FinishRecovery() { recovering_ = false; }

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
  /// kStopBeforeMatch, a semicolon with kStopAtSemi, or end of file/sources is
  /// left unconsumed; callers must handle these boundaries before retrying.
  ///
  /// \param toks Sync tokens to stop at (do not include ';'; use kStopAtSemi).
  /// \param flags Behavior flags; see SkipUntilFlags.
  /// \return true if one of \p toks was matched; false if stopped at ';'
  ///         (kStopAtSemi) or end of file/sources.
  bool SkipUntil(std::vector<tok::TokenType> toks, SkipUntilFlags flags = SkipUntilFlags::kNone);
  bool SkipUntil(tok::TokenType t, SkipUntilFlags flags = SkipUntilFlags::kNone);
  bool SkipUntil(tok::TokenType t1, tok::TokenType t2, SkipUntilFlags flags = SkipUntilFlags::kNone);
  bool SkipUntil(tok::TokenType t1, tok::TokenType t2, tok::TokenType t3, SkipUntilFlags flags = SkipUntilFlags::kNone);
};

}  // namespace cw
