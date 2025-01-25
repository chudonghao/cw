/// \file ast.h
/// \author Donghao Chu
/// \date 2025/01/15
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include <memory>
#include <string>
#include <vector>

namespace cw {

// Inheritance diagram:
// Decl
// |
// |-TranslationUnitDecl
// |
// `-NamedDecl
//   |
//   |-StructDecl
//   |
//   |-FunctionDecl
//   |
//   `-VarDecl
// Stmt
// |
// |-CompoundStmt
// |
// |-ValueStmt
// | |
// | `-Expr
// |
// |-DeclStmt
// |
// |-ForStmt
// |
// |-BreakStmt
// |
// |-ContinueStmt
// |
// |-IfStmt
// |
// `-ReturnStmt

struct VarDecl;
struct FunctionDecl;
struct CompoundStmt;
struct Expr;

struct Decl {
  virtual ~Decl() = default;
};

struct TranslationUnitDecl : Decl {
  std::vector<std::unique_ptr<Decl>> Decls{};
};

struct NamedDecl : Decl {
  std::string name{};
};

struct VirtualDecl : NamedDecl {
  std::vector<std::unique_ptr<FunctionDecl>> Funcs;
};

struct StructDecl : NamedDecl {
  std::unique_ptr<VirtualDecl> VirtualDecl{};
  std::vector<std::unique_ptr<VarDecl>> Fields{};
};

struct FunctionDecl : NamedDecl {
  std::unique_ptr<CompoundStmt> CompoundStmt{};
};

struct VarDecl : NamedDecl {
  std::unique_ptr<Expr> Init;
};

struct Stmt {
  virtual ~Stmt() = default;
};

struct CompoundStmt : Stmt {
  std::vector<std::unique_ptr<Stmt>> Stmts{};
};

struct ValueStmt : Stmt {};

struct Expr : ValueStmt {};

struct DeclStmt : Stmt {
  std::unique_ptr<Decl> Decl{};
};

}  // namespace cw
