/// \file parser_test.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include <cstddef>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

#include <gtest/gtest.h>

#include "ASTDumpTest.h"
#include "cw/ASTContext.h"
#include "cw/Diagnostic.h"
#include "cw/Lexer.h"
#include "cw/Parser.h"
#include "cw/Source.h"

class ParserTest : public ::testing::Test {
  std::vector<cw::Source> sources_;
  cw::Lexer lexer_;
  cw::ASTContext ast_context_;
  cw::Parser parser_;
  cw::DiagnosticEngine diagnostic_engine_;
  std::size_t next_diagnostic_ = 0;
  bool parsed_ = false;

 protected:
  void Parse(std::string content) { Parse(std::vector<cw::Source>{{"test.cw", std::move(content)}}); }

  void Parse(std::vector<cw::Source> sources) {
    ASSERT_FALSE(parsed_);
    parsed_ = true;

    sources_ = std::move(sources);
    lexer_.Reset(&sources_);
    parser_.SetLexer(&lexer_);
    parser_.SetASTContext(&ast_context_);
    parser_.SetDiagnosticEngine(&diagnostic_engine_);
    parser_();
  }

  void ExpectDiagnostic(cw::DiagnosticSeverity severity, int line, int column, std::string_view message) {
    const auto& diagnostics = diagnostic_engine_.Diagnostics();
    ASSERT_LT(next_diagnostic_, diagnostics.size()) << "missing expected diagnostic";

    const auto& actual = diagnostics[next_diagnostic_++];
    EXPECT_EQ(actual.severity, severity);
    EXPECT_EQ(actual.line, line);
    EXPECT_EQ(actual.column, column);
    EXPECT_EQ(actual.message, std::string(message));
  }

  void ExpectError(int line, int column, std::string_view message) {
    ExpectDiagnostic(cw::kErrorDiagnostic, line, column, message);
  }

  void ExpectAstDump(std::string_view expected_dump) {
    cw::test::ExpectAstDump(*ast_context_.GetTranslationUnitDecl(), sources_, expected_dump);
  }

  void TearDown() override {
    EXPECT_EQ(next_diagnostic_, diagnostic_engine_.Diagnostics().size()) << "unexpected diagnostic";
  }
};

TEST_F(ParserTest, ProducesNoDiagnosticsForEmptyTranslationUnit) { Parse(""); }

TEST_F(ParserTest, ParsesNullAsADedicatedLiteral) {
  Parse("var p *i32 := null;");
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-VarGroupDecl {{address}} <test.cw:1:1, col:20>
  |-VarDecl {{address}} <col:5, col:11> p
  | `-PointerType {{address}} <col:7, col:11>
  |   `-BuiltinType {{address}} <col:8, col:11> 'i32'
  `-NullLiteral {{address}} <col:15, col:19>)");
}

TEST_F(ParserTest, ProducesNoDiagnosticsForDeclarations) {
  Parse(R"(struct Base {}
struct S : Base {
virtual {
func vf(this mut S, value i32) i32;
}
field i32;
next **S;
}
func f(a i32, b *S) i32 {}
func operator+(lhs i32, rhs i32) i32 {}
func operator[](base *S, index i32) i32 {}
func operator()(callable *S) i32 {}
ctor S() {}
dtor S() {}
func vf(owner *S) i32 {}
func receiver(this copy S) {}
func prefixed(var this copy S) {}
func attributed(var(tag) this copy S) {}
func operator-(this copy S) copy S { this }
var x *S;
var y, z := 1, 2;
var block i32 := { 3 }
)");
}

TEST_F(ParserTest, ParsesVirtualInterfaceModifiers) {
  Parse(R"(struct S {
virtual {
func Concrete(this mut S);
abstract func Abstract(this copy S);
override func Override(this mut S);
override abstract func Reabstract(this move S);
abstract override func ReabstractReversed(this move S);
}
})");
}

TEST_F(ParserTest, RecoversDuplicateVirtualModifiersWithoutDiscardingTheBlock) {
  Parse(R"(struct S {
virtual {
abstract abstract func Bad(this mut S);
override override func Bad(this mut S);
abstract func Good(this mut S);
}
field i32;
})");

  ExpectError(2, 9, "duplicate virtual function modifier 'abstract'");
  ExpectError(3, 9, "duplicate virtual function modifier 'override'");
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-StructDecl {{address}} <test.cw:1:1, line:8:2> S contains-errors
  |-VirtualDecl {{address}} <line:2:1, line:6:2> contains-errors
  | |-VirtualFunctionDecl {{address}} <line:3:1, col:40> Bad abstract contains-errors
  | | `-ParmVarDecl {{address}} <col:28, col:38> this
  | |   `-ReferenceType {{address}} <col:33, col:38> 'mut'
  | |     `-NamedType {{address}} <col:37, col:38> 'S'
  | |-VirtualFunctionDecl {{address}} <line:4:1, col:40> Bad override contains-errors
  | | `-ParmVarDecl {{address}} <col:28, col:38> this
  | |   `-ReferenceType {{address}} <col:33, col:38> 'mut'
  | |     `-NamedType {{address}} <col:37, col:38> 'S'
  | `-VirtualFunctionDecl {{address}} <line:5:1, col:32> Good abstract
  |   `-ParmVarDecl {{address}} <col:20, col:30> this
  |     `-ReferenceType {{address}} <col:25, col:30> 'mut'
  |       `-NamedType {{address}} <col:29, col:30> 'S'
  `-FieldDecl {{address}} <line:7:1, col:11> field
    `-BuiltinType {{address}} <col:7, col:10> 'i32')");
}

TEST_F(ParserTest, ParsesMultiTokenOperatorNames) {
  Parse("func operator[](base *S, index i32) i32 {} func operator()(callable *S) i32 {}");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-FunctionDecl {{address}} <test.cw:1:1, col:43> operator[]
| |-ParmVarDecl {{address}} <col:17, col:24> base
| | `-PointerType {{address}} <col:22, col:24>
| |   `-NamedType {{address}} <col:23, col:24> 'S'
| |-ParmVarDecl {{address}} <col:26, col:35> index
| | `-BuiltinType {{address}} <col:32, col:35> 'i32'
| |-ReturnVarDecl {{address}} <col:37, col:40>
| | `-BuiltinType {{address}} <col:37, col:40> 'i32'
| `-CompoundStmt {{address}} <col:41, col:43>
`-FunctionDecl {{address}} <col:44, col:79> operator()
  |-ParmVarDecl {{address}} <col:60, col:71> callable
  | `-PointerType {{address}} <col:69, col:71>
  |   `-NamedType {{address}} <col:70, col:71> 'S'
  |-ReturnVarDecl {{address}} <col:73, col:76>
  | `-BuiltinType {{address}} <col:73, col:76> 'i32'
  `-CompoundStmt {{address}} <col:77, col:79>)");
}

TEST_F(ParserTest, ProducesNoDiagnosticsForBuiltinAndPointerTypes) {
  Parse(R"(struct Types {
void_type void;
bool_type bool;
i8_type i8;
i16_type i16;
i32_type i32;
i64_type i64;
u8_type u8;
u16_type u16;
u32_type u32;
u64_type u64;
f32_type f32;
f64_type f64;
isize_type isize;
usize_type usize;
named_type Name;
pointer_type **Name;
})");
}

TEST_F(ParserTest, DumpsFunctionTypeNodes) {
  Parse(R"(var empty func () void;
var nested func (i32, func (*S) void) func () *S;
var pointer *func (i32) void;
func higher(callback func (i32) void) func () *S {})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-VarGroupDecl {{address}} <test.cw:1:1, col:24>
| `-VarDecl {{address}} <col:5, col:23> empty
|   `-FunctionType {{address}} <col:11, col:23>
|     `-BuiltinType {{address}} <col:19, col:23> 'void'
|-VarGroupDecl {{address}} <line:2:1, col:50>
| `-VarDecl {{address}} <col:5, col:49> nested
|   `-FunctionType {{address}} <col:12, col:49>
|     |-BuiltinType {{address}} <col:18, col:21> 'i32'
|     |-FunctionType {{address}} <col:23, col:37>
|     | |-PointerType {{address}} <col:29, col:31>
|     | | `-NamedType {{address}} <col:30, col:31> 'S'
|     | `-BuiltinType {{address}} <col:33, col:37> 'void'
|     `-FunctionType {{address}} <col:39, col:49>
|       `-PointerType {{address}} <col:47, col:49>
|         `-NamedType {{address}} <col:48, col:49> 'S'
|-VarGroupDecl {{address}} <line:3:1, col:30>
| `-VarDecl {{address}} <col:5, col:29> pointer
|   `-PointerType {{address}} <col:13, col:29>
|     `-FunctionType {{address}} <col:14, col:29>
|       |-BuiltinType {{address}} <col:20, col:23> 'i32'
|       `-BuiltinType {{address}} <col:25, col:29> 'void'
`-FunctionDecl {{address}} <line:4:1, col:52> higher
  |-ParmVarDecl {{address}} <col:13, col:37> callback
  | `-FunctionType {{address}} <col:22, col:37>
  |   |-BuiltinType {{address}} <col:28, col:31> 'i32'
  |   `-BuiltinType {{address}} <col:33, col:37> 'void'
  |-ReturnVarDecl {{address}} <col:39, col:49>
  | `-FunctionType {{address}} <col:39, col:49>
  |   `-PointerType {{address}} <col:47, col:49>
  |     `-NamedType {{address}} <col:48, col:49> 'S'
  `-CompoundStmt {{address}} <col:50, col:52>)");
}

TEST_F(ParserTest, DumpsQualifiedAndReferenceTypeNodes) {
  Parse(R"(var pointer const *const i32;
var signature *func (copy i32, *const i32) move i32;
func refs(value mut *const i32, read copy i32, sink move i32) move i32 {}
var duplicate const const i32;)");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-VarGroupDecl {{address}} <test.cw:1:1, col:30>
| `-VarDecl {{address}} <col:5, col:29> pointer
|   `-ConstType {{address}} <col:13, col:29>
|     `-PointerType {{address}} <col:19, col:29>
|       `-ConstType {{address}} <col:20, col:29>
|         `-BuiltinType {{address}} <col:26, col:29> 'i32'
|-VarGroupDecl {{address}} <line:2:1, col:53>
| `-VarDecl {{address}} <col:5, col:52> signature
|   `-PointerType {{address}} <col:15, col:52>
|     `-FunctionType {{address}} <col:16, col:52>
|       |-ReferenceType {{address}} <col:22, col:30> 'copy'
|       | `-BuiltinType {{address}} <col:27, col:30> 'i32'
|       |-PointerType {{address}} <col:32, col:42>
|       | `-ConstType {{address}} <col:33, col:42>
|       |   `-BuiltinType {{address}} <col:39, col:42> 'i32'
|       `-ReferenceType {{address}} <col:44, col:52> 'move'
|         `-BuiltinType {{address}} <col:49, col:52> 'i32'
|-FunctionDecl {{address}} <line:3:1, col:74> refs
| |-ParmVarDecl {{address}} <col:11, col:31> value
| | `-ReferenceType {{address}} <col:17, col:31> 'mut'
| |   `-PointerType {{address}} <col:21, col:31>
| |     `-ConstType {{address}} <col:22, col:31>
| |       `-BuiltinType {{address}} <col:28, col:31> 'i32'
| |-ParmVarDecl {{address}} <col:33, col:46> read
| | `-ReferenceType {{address}} <col:38, col:46> 'copy'
| |   `-BuiltinType {{address}} <col:43, col:46> 'i32'
| |-ParmVarDecl {{address}} <col:48, col:61> sink
| | `-ReferenceType {{address}} <col:53, col:61> 'move'
| |   `-BuiltinType {{address}} <col:58, col:61> 'i32'
| |-ReturnVarDecl {{address}} <col:63, col:71>
| | `-ReferenceType {{address}} <col:63, col:71> 'move'
| |   `-BuiltinType {{address}} <col:68, col:71> 'i32'
| `-CompoundStmt {{address}} <col:72, col:74>
`-VarGroupDecl {{address}} <line:4:1, col:31>
  `-VarDecl {{address}} <col:5, col:30> duplicate
    `-ConstType {{address}} <col:15, col:30>
      `-ConstType {{address}} <col:21, col:30>
        `-BuiltinType {{address}} <col:27, col:30> 'i32')");
}

TEST_F(ParserTest, PreservesIncompleteQualifiedTypePrefixes) {
  Parse("var broken const mut; var next i32;");

  ExpectError(0, 20,
              "expected one of '[', 'virtual', 'const', 'mut', 'copy', 'move', '*', 'func', built-in type, identifier");
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-VarGroupDecl {{address}} <test.cw:1:1, col:21> contains-errors
| `-VarDecl {{address}} <col:5, col:21> broken contains-errors
|   `-ConstType {{address}} <col:12, col:21> contains-errors
|     `-ReferenceType {{address}} <col:18, col:21> 'mut' contains-errors
`-VarGroupDecl {{address}} <col:23, col:36>
  `-VarDecl {{address}} <col:27, col:35> next
    `-BuiltinType {{address}} <col:32, col:35> 'i32')");
}

TEST_F(ParserTest, ProducesNoDiagnosticsForStatementsAndExpressions) {
  Parse(R"(func f() {
var x := 1;
if true { x += 1; } else { x -= 1; }
while x < 10 { x++; continue; }
{ break; }
return x;
}
func tail() { 1, 2 }
)");
}

TEST_F(ParserTest, ParsesDeclarationInitializationForms) {
  Parse(R"(var inferred := 1;
var explicit i32 := 2;
var first i32, second i32 := { first := 3; second := 4; }
)");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-VarGroupDecl {{address}} <test.cw:1:1, col:19>
| |-VarDecl {{address}} <col:5, col:13> inferred
| `-IntegerLiteral {{address}} <col:17, col:18> 1
|-VarGroupDecl {{address}} <line:2:1, col:23>
| |-VarDecl {{address}} <col:5, col:17> explicit
| | `-BuiltinType {{address}} <col:14, col:17> 'i32'
| `-IntegerLiteral {{address}} <col:21, col:22> 2
`-VarGroupDecl {{address}} <line:3:1, col:58>
  |-VarDecl {{address}} <col:5, col:14> first
  | `-BuiltinType {{address}} <col:11, col:14> 'i32'
  |-VarDecl {{address}} <col:16, col:26> second
  | `-BuiltinType {{address}} <col:23, col:26> 'i32'
  `-CompoundStmt {{address}} <col:30, col:58>
    |-ExprStmt {{address}} <col:32, col:43>
    | `-InitializationExpr {{address}} <col:32, col:42>
    |   |-DeclRefExpr {{address}} <col:32, col:37> 'first'
    |   `-IntegerLiteral {{address}} <col:41, col:42> 3
    `-ExprStmt {{address}} <col:44, col:56>
      `-InitializationExpr {{address}} <col:44, col:55>
        |-DeclRefExpr {{address}} <col:44, col:50> 'second'
        `-IntegerLiteral {{address}} <col:54, col:55> 4)");
}

TEST_F(ParserTest, DistinguishesInitializationAndAssignmentExpressions) {
  Parse("func f() { target := source := value; first = second = value; }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:64> f
  `-CompoundStmt {{address}} <col:10, col:64>
    |-ExprStmt {{address}} <col:12, col:38>
    | `-InitializationExpr {{address}} <col:12, col:37>
    |   |-DeclRefExpr {{address}} <col:12, col:18> 'target'
    |   `-InitializationExpr {{address}} <col:22, col:37>
    |     |-DeclRefExpr {{address}} <col:22, col:28> 'source'
    |     `-DeclRefExpr {{address}} <col:32, col:37> 'value'
    `-ExprStmt {{address}} <col:39, col:62>
      `-BinaryOperator {{address}} <col:39, col:61> '='
        |-DeclRefExpr {{address}} <col:39, col:44> 'first'
        `-BinaryOperator {{address}} <col:47, col:61> '='
          |-DeclRefExpr {{address}} <col:47, col:53> 'second'
          `-DeclRefExpr {{address}} <col:56, col:61> 'value')");
}

TEST_F(ParserTest, RejectsLegacyVariableInitializationSyntax) {
  Parse("var old = 1;\nvar block i32 { 2 }\n");

  ExpectError(0, 8, "expected ':=' or ';'");
  ExpectError(1, 14, "expected ':=' or ';'");
}

TEST_F(ParserTest, ReportsMissingVariableInitializer) {
  Parse("var x := ;");
  ExpectError(
      0, 9,
      "expected one of identifier, 'null', boolean literal, integer literal, character literal, floating literal, "
      "string literal, 'move', 'operator', 'this', 'ctor', 'dtor', 'nonvirtual', '&', '*', '+', '++', "
      "'-', '--', '~', '!', '(', '['");
}

TEST_F(ParserTest, ReportsNonExpressionTokenInExpression) {
  Parse(R"(func f() {
var x := return;
})");
  ExpectError(
      1, 9,
      "expected one of identifier, 'null', boolean literal, integer literal, character literal, floating literal, "
      "string literal, 'move', 'operator', 'this', 'ctor', 'dtor', 'nonvirtual', '&', '*', '+', '++', "
      "'-', '--', '~', '!', '(', '['");
}

TEST_F(ParserTest, ReportsMissingCondition) {
  Parse("func f() { if {} }");
  ExpectError(
      0, 14,
      "expected one of identifier, 'null', boolean literal, integer literal, character literal, floating literal, "
      "string literal, 'move', 'operator', 'this', 'ctor', 'dtor', 'nonvirtual', '&', '*', '+', '++', "
      "'-', '--', '~', '!', '(', '['");
}

TEST_F(ParserTest, ReportsMissingRightOperand) {
  Parse("func f() { return 1 + ; }");
  ExpectError(
      0, 22,
      "expected one of identifier, 'null', boolean literal, integer literal, character literal, floating literal, "
      "string literal, 'move', 'operator', 'this', 'ctor', 'dtor', 'nonvirtual', '&', '*', '+', '++', "
      "'-', '--', '~', '!', '(', '['");
}

TEST_F(ParserTest, ReportsMissingMemberName) {
  Parse("func f() { value.; }");
  ExpectError(0, 17, "expected identifier or 'nonvirtual'");
}

TEST_F(ParserTest, ReportsMissingTailExpression) {
  Parse("func f() { 1, }");
  ExpectError(
      0, 14,
      "expected one of identifier, 'null', boolean literal, integer literal, character literal, floating literal, "
      "string literal, 'move', 'operator', 'this', 'ctor', 'dtor', 'nonvirtual', '&', '*', '+', '++', "
      "'-', '--', '~', '!', '(', '['");
}

TEST_F(ParserTest, ReportsMultipleExpressionErrorsAndContinuesParsing) {
  Parse(R"(func f() {
var x := ;
return 1 + ;
;
}
var ;)");
  ExpectError(
      1, 9,
      "expected one of identifier, 'null', boolean literal, integer literal, character literal, floating literal, "
      "string literal, 'move', 'operator', 'this', 'ctor', 'dtor', 'nonvirtual', '&', '*', '+', '++', "
      "'-', '--', '~', '!', '(', '['");
  ExpectError(
      2, 11,
      "expected one of identifier, 'null', boolean literal, integer literal, character literal, floating literal, "
      "string literal, 'move', 'operator', 'this', 'ctor', 'dtor', 'nonvirtual', '&', '*', '+', '++', "
      "'-', '--', '~', '!', '(', '['");
  ExpectError(
      3, 0,
      "expected one of identifier, 'null', boolean literal, integer literal, character literal, floating literal, "
      "string literal, 'move', 'operator', 'this', 'ctor', 'dtor', 'nonvirtual', '&', '*', '+', '++', "
      "'-', '--', '~', '!', '(', '['");
  ExpectError(5, 4, "expected identifier");
}

TEST_F(ParserTest, ReportsUnexpectedTopLevelToken) {
  Parse("123");
  ExpectError(0, 0, "expected one of 'trivial', 'struct', 'func', 'ctor', 'dtor', 'var'");
}

TEST_F(ParserTest, ReportsFunctionTypeSyntaxErrorsAndContinuesParsing) {
  Parse(R"(var missing_left func i32;
var trailing func (i32,) void;
var missing_right func (i32 void;
var missing_return func ();
var valid func () void;)");

  ExpectError(0, 22, "expected '('");
  ExpectError(1, 23,
              "expected one of '[', 'virtual', 'const', 'mut', 'copy', 'move', '*', 'func', built-in type, identifier");
  ExpectError(2, 28, "expected ',' or ')'");
  ExpectError(3, 26,
              "expected one of '[', 'virtual', 'const', 'mut', 'copy', 'move', '*', 'func', built-in type, identifier");

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-VarGroupDecl {{address}} <test.cw:1:1, col:22> contains-errors
| `-VarDecl {{address}} <col:5, col:22> missing_left contains-errors
|   `-FunctionType {{address}} <col:18, col:22> contains-errors
|-VarGroupDecl {{address}} <line:2:1, col:24> contains-errors
| `-VarDecl {{address}} <col:5, col:24> trailing contains-errors
|   `-FunctionType {{address}} <col:14, col:24> contains-errors
|     `-BuiltinType {{address}} <col:20, col:23> 'i32'
|-VarGroupDecl {{address}} <line:3:1, col:28> contains-errors
| `-VarDecl {{address}} <col:5, col:28> missing_right contains-errors
|   `-FunctionType {{address}} <col:19, col:28> contains-errors
|     `-BuiltinType {{address}} <col:25, col:28> 'i32'
|-VarGroupDecl {{address}} <line:4:1, col:27> contains-errors
| `-VarDecl {{address}} <col:5, col:27> missing_return contains-errors
|   `-FunctionType {{address}} <col:20, col:27> contains-errors
`-VarGroupDecl {{address}} <line:5:1, col:24>
  `-VarDecl {{address}} <col:5, col:23> valid
    `-FunctionType {{address}} <col:11, col:23>
      `-BuiltinType {{address}} <col:19, col:23> 'void')");
}

TEST_F(ParserTest, ReportsUnexpectedTopLevelVirtual) {
  Parse("virtual f() {}");
  ExpectError(0, 0, "expected one of 'trivial', 'struct', 'func', 'ctor', 'dtor', 'var'");
}

TEST_F(ParserTest, ReportsMissingStructName) {
  Parse("struct 123");
  ExpectError(0, 7, "expected identifier");
}

TEST_F(ParserTest, ReportsMultipleTopLevelErrorsInOrder) {
  Parse("123\nstruct\nvar ;");
  ExpectError(0, 0, "expected one of 'trivial', 'struct', 'func', 'ctor', 'dtor', 'var'");
  ExpectError(2, 0, "expected identifier");
  ExpectError(2, 4, "expected identifier");
}

TEST_F(ParserTest, ReportsMissingStructClosingBraceAtEndOfSource) {
  Parse("struct A {");
  ExpectError(0, 10, "expected '}'");
}

TEST_F(ParserTest, ReportsFieldTypeErrorsInOrder) {
  Parse(R"(struct A {
bad ;
good i32;
worse **;
})");
  ExpectError(1, 4,
              "expected one of '[', 'virtual', 'const', 'mut', 'copy', 'move', '*', 'func', built-in type, identifier");
  ExpectError(3, 8,
              "expected one of '[', 'virtual', 'const', 'mut', 'copy', 'move', '*', 'func', built-in type, identifier");
}

TEST_F(ParserTest, ReportsMissingFieldSemicolon) {
  Parse("struct A { field i32 }");
  ExpectError(0, 21, "expected ';'");
}

TEST_F(ParserTest, ReportsMissingFunctionLeftParenthesis) {
  Parse("func f i32");
  ExpectError(0, 7, "expected '('");
}

TEST_F(ParserTest, RecoversAtParameterSeparator) {
  Parse("func f(i32, x i32) {}");
  ExpectError(0, 7, "expected one of 'var', identifier, 'this'");
}

TEST_F(ParserTest, ReportsMissingParameterType) {
  Parse("func f(x, y i32) {}");
  ExpectError(0, 8,
              "expected one of '[', 'virtual', 'const', 'mut', 'copy', 'move', '*', 'func', built-in type, identifier");
}

TEST_F(ParserTest, ReportsMissingReturnPointee) {
  Parse("func f() * {}");
  ExpectError(0, 11,
              "expected one of '[', 'virtual', 'const', 'mut', 'copy', 'move', '*', 'func', built-in type, identifier");
}

TEST_F(ParserTest, RequiresNamesForVarReturnDeclarationsAndRecoversAtDeclarationBoundaries) {
  Parse(R"(func Bad() var i32 {}
func Recovered() {}
struct S {
virtual {
abstract func Bad(this mut S) var i32;
func Recovered(this mut S);
}
field i32;
})");

  ExpectError(0, 15, "expected identifier");
  ExpectError(4, 34, "expected identifier");
}

TEST_F(ParserTest, ReportsMissingVariableSemicolon) {
  Parse("var x i32");
  ExpectError(0, 9, "expected ':=' or ';'");
}

TEST_F(ParserTest, ReportsMissingBreakSemicolon) {
  Parse("func f() { break }");
  ExpectError(0, 17, "expected ';'");
}

TEST_F(ParserTest, ReportsMissingContinueSemicolon) {
  Parse("func f() { continue }");
  ExpectError(0, 20, "expected ';'");
}

TEST_F(ParserTest, ReportsMissingReturnSemicolon) {
  Parse("func f() { return 1 }");
  ExpectError(0, 20, "expected ';'");
}

TEST_F(ParserTest, ReportsMissingIfBody) {
  Parse("func f() { if true }");
  ExpectError(0, 19, "expected '{'");
}

TEST_F(ParserTest, ReportsStatementAndTopLevelErrorsInOrder) {
  Parse(R"(func f() {
var ;
break
}
var ;)");
  ExpectError(1, 4, "expected identifier");
  ExpectError(3, 0, "expected ';'");
  ExpectError(4, 4, "expected identifier");
}

TEST_F(ParserTest, DumpsDeclarationAndTypeNodes) {
  Parse(
      "struct S : B { virtual { func vf(this mut S, p i32) i32; } field **Name; } "
      "func f(x i32) i32 {} ctor S() {} dtor S() {} func v() {} var a, b := 1, 2;");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address}} <test.cw:1:1, col:75> S : 'B'
| |-VirtualDecl {{address}} <col:16, col:59>
| | `-VirtualFunctionDecl {{address}} <col:26, col:57> vf
| |   |-ParmVarDecl {{address}} <col:34, col:44> this
| |   | `-ReferenceType {{address}} <col:39, col:44> 'mut'
| |   |   `-NamedType {{address}} <col:43, col:44> 'S'
| |   |-ParmVarDecl {{address}} <col:46, col:51> p
| |   | `-BuiltinType {{address}} <col:48, col:51> 'i32'
| |   `-ReturnVarDecl {{address}} <col:53, col:56>
| |     `-BuiltinType {{address}} <col:53, col:56> 'i32'
| `-FieldDecl {{address}} <col:60, col:73> field
|   `-PointerType {{address}} <col:66, col:72>
|     `-PointerType {{address}} <col:67, col:72>
|       `-NamedType {{address}} <col:68, col:72> 'Name'
|-FunctionDecl {{address}} <col:76, col:96> f
| |-ParmVarDecl {{address}} <col:83, col:88> x
| | `-BuiltinType {{address}} <col:85, col:88> 'i32'
| |-ReturnVarDecl {{address}} <col:90, col:93>
| | `-BuiltinType {{address}} <col:90, col:93> 'i32'
| `-CompoundStmt {{address}} <col:94, col:96>
|-ConstructorDecl {{address}} <col:97, col:108> S
| `-CompoundStmt {{address}} <col:106, col:108>
|-DestructorDecl {{address}} <col:109, col:120> S
| `-CompoundStmt {{address}} <col:118, col:120>
|-FunctionDecl {{address}} <col:121, col:132> v
| `-CompoundStmt {{address}} <col:130, col:132>
`-VarGroupDecl {{address}} <col:133, col:150>
  |-VarDecl {{address}} <col:137, col:138> a
  |-VarDecl {{address}} <col:140, col:141> b
  |-IntegerLiteral {{address}} <col:145, col:146> 1
  `-IntegerLiteral {{address}} <col:148, col:149> 2)");
}

TEST_F(ParserTest, PreservesVariableAttributesAndPerVariableOptionalType) {
  Parse("var(foo, bar) a, b *Foo := x, y;");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-VarGroupDecl {{address}} <test.cw:1:1, col:33>
  |-VarDecl {{address}} <col:15, col:16> a attr='foo' attr='bar'
  |-VarDecl {{address}} <col:18, col:24> b attr='foo' attr='bar'
  | `-PointerType {{address}} <col:20, col:24>
  |   `-NamedType {{address}} <col:21, col:24> 'Foo'
  |-DeclRefExpr {{address}} <col:28, col:29> 'x'
  `-DeclRefExpr {{address}} <col:31, col:32> 'y')");
}

TEST_F(ParserTest, DumpsStatementNodes) {
  Parse(
      "func f() { var x := 1; x++; if true { break; } else { continue; } "
      "while x < 2 { return x; } return; }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:102> f
  `-CompoundStmt {{address}} <col:10, col:102>
    |-DeclStmt {{address}} <col:12, col:23>
    | `-VarGroupDecl {{address}} <col:12, col:23>
    |   |-VarDecl {{address}} <col:16, col:17> x
    |   `-IntegerLiteral {{address}} <col:21, col:22> 1
    |-ExprStmt {{address}} <col:24, col:28>
    | `-UnaryOperator {{address}} <col:24, col:27> '++' postfix
    |   `-DeclRefExpr {{address}} <col:24, col:25> 'x'
    |-IfStmt {{address}} <col:29, col:66>
    | |-BoolLiteral {{address}} <col:32, col:36> true
    | |-CompoundStmt {{address}} <col:37, col:47>
    | | `-BreakStmt {{address}} <col:39, col:45>
    | `-CompoundStmt {{address}} <col:53, col:66>
    |   `-ContinueStmt {{address}} <col:55, col:64>
    |-WhileStmt {{address}} <col:67, col:92>
    | |-BinaryOperator {{address}} <col:73, col:78> '<'
    | | |-DeclRefExpr {{address}} <col:73, col:74> 'x'
    | | `-IntegerLiteral {{address}} <col:77, col:78> 2
    | `-CompoundStmt {{address}} <col:79, col:92>
    |   `-ReturnStmt {{address}} <col:81, col:90>
    |     `-DeclRefExpr {{address}} <col:88, col:89> 'x'
    `-ReturnStmt {{address}} <col:93, col:100>)");
}

TEST_F(ParserTest, DumpsExpressionNodes) {
  Parse(R"(func f() { 1.5; "a""b"; a ? b : c; obj.m; ptr->m; arr[i]; fn(1, x); -x; (1); })");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:79> f
  `-CompoundStmt {{address}} <col:10, col:79>
    |-ExprStmt {{address}} <col:12, col:16>
    | `-FloatLiteral {{address}} <col:12, col:15> 1.5
    |-ExprStmt {{address}} <col:17, col:24>
    | `-StringLiteral {{address}} <col:17, col:23> "ab"
    |-ExprStmt {{address}} <col:25, col:35>
    | `-ConditionalOperator {{address}} <col:25, col:34>
    |   |-DeclRefExpr {{address}} <col:25, col:26> 'a'
    |   |-DeclRefExpr {{address}} <col:29, col:30> 'b'
    |   `-DeclRefExpr {{address}} <col:33, col:34> 'c'
    |-ExprStmt {{address}} <col:36, col:42>
    | `-MemberExpr {{address}} <col:36, col:41> .m
    |   `-DeclRefExpr {{address}} <col:36, col:39> 'obj'
    |-ExprStmt {{address}} <col:43, col:50>
    | `-MemberExpr {{address}} <col:43, col:49> ->m
    |   `-DeclRefExpr {{address}} <col:43, col:46> 'ptr'
    |-ExprStmt {{address}} <col:51, col:58>
    | `-SubscriptExpr {{address}} <col:51, col:57>
    |   |-DeclRefExpr {{address}} <col:51, col:54> 'arr'
    |   `-DeclRefExpr {{address}} <col:55, col:56> 'i'
    |-ExprStmt {{address}} <col:59, col:68>
    | `-CallExpr {{address}} <col:59, col:67>
    |   |-DeclRefExpr {{address}} <col:59, col:61> 'fn'
    |   |-IntegerLiteral {{address}} <col:62, col:63> 1
    |   `-DeclRefExpr {{address}} <col:65, col:66> 'x'
    |-ExprStmt {{address}} <col:69, col:72>
    | `-UnaryOperator {{address}} <col:69, col:71> '-'
    |   `-DeclRefExpr {{address}} <col:70, col:71> 'x'
    `-ExprStmt {{address}} <col:73, col:77>
      `-ParenExpr {{address}} <col:73, col:76>
        `-IntegerLiteral {{address}} <col:74, col:75> 1)");
}

TEST_F(ParserTest, DistinguishesReceiverCallsFromParenthesizedFieldCalls) {
  Parse("func f() { obj.run(1); ptr->run(); (obj.field)(2); (ptr->field)(); }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:69> f
  `-CompoundStmt {{address}} <col:10, col:69>
    |-ExprStmt {{address}} <col:12, col:23>
    | `-ReceiverCallExpr {{address}} <col:12, col:22> .
    |   |-DeclRefExpr {{address}} <col:12, col:15> 'obj'
    |   |-DeclRefExpr {{address}} <col:16, col:19> 'run'
    |   `-IntegerLiteral {{address}} <col:20, col:21> 1
    |-ExprStmt {{address}} <col:24, col:35>
    | `-ReceiverCallExpr {{address}} <col:24, col:34> ->
    |   |-DeclRefExpr {{address}} <col:24, col:27> 'ptr'
    |   `-DeclRefExpr {{address}} <col:29, col:32> 'run'
    |-ExprStmt {{address}} <col:36, col:51>
    | `-CallExpr {{address}} <col:36, col:50>
    |   |-ParenExpr {{address}} <col:36, col:47>
    |   | `-MemberExpr {{address}} <col:37, col:46> .field
    |   |   `-DeclRefExpr {{address}} <col:37, col:40> 'obj'
    |   `-IntegerLiteral {{address}} <col:48, col:49> 2
    `-ExprStmt {{address}} <col:52, col:67>
      `-CallExpr {{address}} <col:52, col:66>
        `-ParenExpr {{address}} <col:52, col:64>
          `-MemberExpr {{address}} <col:53, col:63> ->field
            `-DeclRefExpr {{address}} <col:53, col:56> 'ptr')");
}

TEST_F(ParserTest, FormsCallsFromGeneralPostfixExpressionsAndPreservesNestedParentheses) {
  Parse("func f() { fn()(); array[index](); ((value)); }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:48> f
  `-CompoundStmt {{address}} <col:10, col:48>
    |-ExprStmt {{address}} <col:12, col:19>
    | `-CallExpr {{address}} <col:12, col:18>
    |   `-CallExpr {{address}} <col:12, col:16>
    |     `-DeclRefExpr {{address}} <col:12, col:14> 'fn'
    |-ExprStmt {{address}} <col:20, col:35>
    | `-CallExpr {{address}} <col:20, col:34>
    |   `-SubscriptExpr {{address}} <col:20, col:32>
    |     |-DeclRefExpr {{address}} <col:20, col:25> 'array'
    |     `-DeclRefExpr {{address}} <col:26, col:31> 'index'
    `-ExprStmt {{address}} <col:36, col:46>
      `-ParenExpr {{address}} <col:36, col:45>
        `-ParenExpr {{address}} <col:37, col:44>
          `-DeclRefExpr {{address}} <col:38, col:43> 'value')");
}

TEST_F(ParserTest, DumpsExistingFunctionAndReferenceProperties) {
  Parse("func operator+(lhs i32, rhs i32) i32 { value; }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:48> operator+
  |-ParmVarDecl {{address}} <col:16, col:23> lhs
  | `-BuiltinType {{address}} <col:20, col:23> 'i32'
  |-ParmVarDecl {{address}} <col:25, col:32> rhs
  | `-BuiltinType {{address}} <col:29, col:32> 'i32'
  |-ReturnVarDecl {{address}} <col:34, col:37>
  | `-BuiltinType {{address}} <col:34, col:37> 'i32'
  `-CompoundStmt {{address}} <col:38, col:48>
    `-ExprStmt {{address}} <col:40, col:46>
      `-DeclRefExpr {{address}} <col:40, col:45> 'value')");
}

TEST_F(ParserTest, DumpsSpecialFunctionDeclarations) {
  Parse("ctor C(value i32) {} dtor C() {}");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-ConstructorDecl {{address}} <test.cw:1:1, col:21> C
| |-ParmVarDecl {{address}} <col:8, col:17> value
| | `-BuiltinType {{address}} <col:14, col:17> 'i32'
| `-CompoundStmt {{address}} <col:19, col:21>
`-DestructorDecl {{address}} <col:22, col:33> C
  `-CompoundStmt {{address}} <col:31, col:33>)");
}

TEST_F(ParserTest, DistinguishesConstructionAndDestructionCallNodes) {
  Parse("func f() { T(1); this; ctor (p) T(2, x); dtor (p) T(); }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:57> f
  `-CompoundStmt {{address}} <col:10, col:57>
    |-ExprStmt {{address}} <col:12, col:17>
    | `-CallExpr {{address}} <col:12, col:16>
    |   |-DeclRefExpr {{address}} <col:12, col:13> 'T'
    |   `-IntegerLiteral {{address}} <col:14, col:15> 1
    |-ExprStmt {{address}} <col:18, col:23>
    | `-DeclRefExpr {{address}} <col:18, col:22> 'this'
    |-ExprStmt {{address}} <col:24, col:41>
    | `-ConstructionExpr {{address}} <col:24, col:40> complete-object target <col:33, col:34> 'T'
    |   |-DeclRefExpr {{address}} <col:30, col:31> 'p'
    |   |-IntegerLiteral {{address}} <col:35, col:36> 2
    |   `-DeclRefExpr {{address}} <col:38, col:39> 'x'
    `-ExprStmt {{address}} <col:42, col:55>
      `-DestructorCallExpr {{address}} <col:42, col:54>
        |-DeclRefExpr {{address}} <col:48, col:49> 'p'
        `-DeclRefExpr {{address}} <col:51, col:52> 'T')");
}

TEST_F(ParserTest, ReservesThisFromDeclarationNames) {
  Parse("func f() { var this i32; }");

  ExpectError(0, 15, "expected identifier");
}

TEST_F(ParserTest, RejectsAnonymousFirstParameters) {
  Parse("func f(mut S) {}");

  ExpectError(0, 7, "expected one of 'var', identifier, 'this'");
}

TEST_F(ParserTest, RejectsRemovedAndInvalidSpecialFunctionDeclarationShapes) {
  Parse(R"(ctor(owner *C) {}
func recovered1() {}
dtor(owner *C) {}
func recovered2() {}
ctor operator+(value i32) {}
dtor operator()() {}
ctor C() i32 {}
dtor C(value i32) {}
dtor C() i32 {})");

  ExpectError(0, 4, "expected identifier");
  ExpectError(2, 4, "expected identifier");
  ExpectError(4, 5, "expected identifier");
  ExpectError(5, 5, "expected identifier");
  ExpectError(6, 9, "expected '{'");
  ExpectError(7, 7, "expected ')'");
  ExpectError(8, 9, "expected '{'");
}

TEST_F(ParserTest, PreservesTopLevelDeclarationsAfterMissingSpecialFunctionBodies) {
  Parse(R"(ctor C()
func RecoveredFunction() {}
dtor C()
var RecoveredVariable i32;)");

  ExpectError(1, 0, "expected '{'");
  ExpectError(3, 0, "expected '{'");
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-ConstructorDecl {{address}} <test.cw:1:1, col:9> C contains-errors
|-FunctionDecl {{address}} <line:2:1, col:28> RecoveredFunction
| `-CompoundStmt {{address}} <col:26, col:28>
|-DestructorDecl {{address}} <line:3:1, col:9> C contains-errors
`-VarGroupDecl {{address}} <line:4:1, col:27>
  `-VarDecl {{address}} <col:5, col:26> RecoveredVariable
    `-BuiltinType {{address}} <col:23, col:26> 'i32')");
}

TEST_F(ParserTest, EscapesStringLiteralProperties) {
  Parse(R"(func f() { "\n"; })");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:19> f
  `-CompoundStmt {{address}} <col:10, col:19>
    `-ExprStmt {{address}} <col:12, col:17>
      `-StringLiteral {{address}} <col:12, col:16> "\n")");
}

TEST_F(ParserTest, BuildsIndependentCharacterAndExactIntegerLiterals) {
  Parse("func f() { 'a'; 18446744073709551616; }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:40> f
  `-CompoundStmt {{address}} <col:10, col:40>
    |-ExprStmt {{address}} <col:12, col:16>
    | `-CharacterLiteral {{address}} <col:12, col:15> 97
    `-ExprStmt {{address}} <col:17, col:38>
      `-IntegerLiteral {{address}} <col:17, col:37> 18446744073709551616)");
}

TEST_F(ParserTest, KeepsPartialFunctionRangeValidAtEndOfSource) {
  Parse("func operator");
  ExpectError(0, 13, "expected '('");

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, col:14> contains-errors)");
}

TEST_F(ParserTest, DumpsRecoveryAnchorAtExpressionStart) {
  Parse("var x := 1 + ;");
  ExpectError(
      0, 13,
      "expected one of identifier, 'null', boolean literal, integer literal, character literal, floating literal, "
      "string literal, 'move', 'operator', 'this', 'ctor', 'dtor', 'nonvirtual', '&', '*', '+', '++', "
      "'-', '--', '~', '!', '(', '['");

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-VarGroupDecl {{address}} <test.cw:1:1, col:10> contains-errors
  |-VarDecl {{address}} <col:5, col:6> x
  `-RecoveryExpr {{address}} <col:10, col:10> contains-errors)");
}

TEST_F(ParserTest, DumpsZeroWidthRecoveryRangeBeforeDelimiter) {
  Parse("var x := ;");
  ExpectError(
      0, 9,
      "expected one of identifier, 'null', boolean literal, integer literal, character literal, floating literal, "
      "string literal, 'move', 'operator', 'this', 'ctor', 'dtor', 'nonvirtual', '&', '*', '+', '++', "
      "'-', '--', '~', '!', '(', '['");

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-VarGroupDecl {{address}} <test.cw:1:1, col:10> contains-errors
  |-VarDecl {{address}} <col:5, col:6> x
  `-RecoveryExpr {{address}} <col:10, col:10> contains-errors)");
}

TEST_F(ParserTest, DumpsZeroWidthRecoveryRangeAtEndOfSource) {
  Parse("var x :=");
  ExpectError(
      0, 8,
      "expected one of identifier, 'null', boolean literal, integer literal, character literal, floating literal, "
      "string literal, 'move', 'operator', 'this', 'ctor', 'dtor', 'nonvirtual', '&', '*', '+', '++', "
      "'-', '--', '~', '!', '(', '['");

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-VarGroupDecl {{address}} <test.cw:1:1, col:9> contains-errors
  |-VarDecl {{address}} <col:5, col:6> x
  `-RecoveryExpr {{address}} <col:9, col:9> contains-errors)");
}

TEST_F(ParserTest, AbbreviatesLocationsAcrossLines) {
  Parse("var x :=\n  1;");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-VarGroupDecl {{address}} <test.cw:1:1, line:2:5>
  |-VarDecl {{address}} <line:1:5, col:6> x
  `-IntegerLiteral {{address}} <line:2:3, col:4> 1)");
}

TEST_F(ParserTest, PrintsPathAgainWhenSourceFileChanges) {
  Parse(std::vector<cw::Source>{{"first.cw", "var a;"}, {"second.cw", "var b;"}});

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-VarGroupDecl {{address}} <first.cw:1:1, col:7>
| `-VarDecl {{address}} <col:5, col:6> a
`-VarGroupDecl {{address}} <second.cw:1:1, col:7>
  `-VarDecl {{address}} <col:5, col:6> b)");
}

TEST_F(ParserTest, PreservesExplicitTrivialModifierAndLeavesDefaultCallForSema) {
  Parse(R"(trivial struct Empty {}
func Use() { Empty(); })");
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address}} <test.cw:1:1, col:24> Empty trivial
`-FunctionDecl {{address}} <line:2:1, col:24> Use
  `-CompoundStmt {{address}} <col:12, col:24>
    `-ExprStmt {{address}} <col:14, col:22>
      `-CallExpr {{address}} <col:14, col:21>
        `-DeclRefExpr {{address}} <col:14, col:19> 'Empty')");
}

TEST_F(ParserTest, RejectsSuffixVirtualModifiersAsOrdinarySyntaxErrors) {
  Parse(R"(struct Object {
virtual {
func Old(this mut Object) void override;
abstract func Good(this copy Object) void;
}
})");
  ExpectError(2, 31, "expected ';'");
}

TEST_F(ParserTest, RestrictsTrivialModifierToStructDeclarations) {
  Parse("trivial func Use() {}");
  ExpectError(0, 8, "expected 'struct'");
}

TEST_F(ParserTest, ReservesTrivialFromDeclarationNames) {
  Parse("var trivial i32;");
  ExpectError(0, 4, "expected identifier");
  ExpectError(0, 12, "expected 'struct'");
}
