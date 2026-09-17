/// \file sema_test.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include <cstddef>
#include <filesystem>
#include <fstream>
#include <iterator>
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
#include "cw/Sema.h"
#include "cw/Source.h"
#include "cw/ast.h"

class SemaTest : public ::testing::Test {
  std::vector<cw::Source> sources_;
  cw::Lexer lexer_;
  cw::ASTContext ast_context_;
  cw::Parser parser_;
  cw::Sema sema_;
  cw::DiagnosticEngine diagnostic_engine_;
  std::size_t next_diagnostic_ = 0;
  bool analyzed_ = false;

 protected:
  explicit SemaTest(cw::ABIKind abi = cw::ABIKind::Itanium) : ast_context_(abi) {}

  void Analyze(std::string content, std::string path = "test.cw") {
    ASSERT_FALSE(analyzed_);
    analyzed_ = true;

    sources_ = {{std::move(path), std::move(content)}};
    lexer_.Reset(&sources_);
    parser_.SetLexer(&lexer_);
    parser_.SetASTContext(&ast_context_);
    parser_.SetDiagnosticEngine(&diagnostic_engine_);
    parser_();

    sema_.SetDiagnosticEngine(&diagnostic_engine_);
    sema_.SetSources(&sources_);
    sema_.SetASTContext(&ast_context_);
    sema_();
  }

  void ExpectDiagnostic(cw::DiagnosticSeverity severity, int line, int column, std::string_view message,
                        int highlight_size) {
    const auto& diagnostics = diagnostic_engine_.Diagnostics();
    ASSERT_LT(next_diagnostic_, diagnostics.size()) << "missing expected diagnostic";

    const auto& actual = diagnostics[next_diagnostic_++];
    EXPECT_EQ(actual.severity, severity);
    EXPECT_EQ(actual.line, line);
    EXPECT_EQ(actual.column, column);
    EXPECT_EQ(actual.message, std::string(message));
    ASSERT_EQ(actual.highlights.size(), 1);
    EXPECT_EQ(actual.highlights.front().column, column);
    EXPECT_EQ(actual.highlights.front().size, highlight_size);
  }

  void ExpectError(int line, int column, std::string_view message, int highlight_size) {
    ExpectDiagnostic(cw::kErrorDiagnostic, line, column, message, highlight_size);
  }

  void ExpectWarning(int line, int column, std::string_view message, int highlight_size) {
    ExpectDiagnostic(cw::kWarningDiagnostic, line, column, message, highlight_size);
  }

  void ExpectNote(int line, int column, std::string_view message, int highlight_size) {
    ExpectDiagnostic(cw::kNoteDiagnostic, line, column, message, highlight_size);
  }

  void ExpectAstDump(std::string_view expected_dump) {
    cw::test::ExpectAstDump(*ast_context_.GetTranslationUnitDecl(), sources_, expected_dump);
  }

  void AnalyzeLanguageFeature(std::string_view name) {
    const std::filesystem::path case_directory{CW_SEMA_CASE_DIR};
    const std::filesystem::path source_path = case_directory / (std::string(name) + ".cw");
    const std::filesystem::path expected_path = case_directory / (std::string(name) + ".cw.ast.txt");

    std::ifstream source_stream(source_path, std::ios::binary);
    ASSERT_TRUE(source_stream.is_open()) << "failed to open " << source_path;
    std::ifstream expected_stream(expected_path, std::ios::binary);
    ASSERT_TRUE(expected_stream.is_open()) << "failed to open " << expected_path;

    std::string source((std::istreambuf_iterator<char>(source_stream)), std::istreambuf_iterator<char>());
    std::string expected((std::istreambuf_iterator<char>(expected_stream)), std::istreambuf_iterator<char>());
    Analyze(std::move(source), source_path.filename().string());
    ExpectAstDump(expected);
  }

  void TearDown() override {
    const auto& diagnostics = diagnostic_engine_.Diagnostics();
    std::string unexpected;
    for (std::size_t index = next_diagnostic_; index < diagnostics.size(); ++index) {
      const auto& diagnostic = diagnostics[index];
      unexpected +=
          "\n" + std::to_string(diagnostic.line) + ":" + std::to_string(diagnostic.column) + " " + diagnostic.message;
    }
    EXPECT_EQ(next_diagnostic_, diagnostics.size()) << "unexpected diagnostic" << unexpected;
  }
};

class ConfiguredSemaTest : public SemaTest, public ::testing::WithParamInterface<cw::ABIKind> {
 protected:
  ConfiguredSemaTest() : SemaTest(GetParam()) {}
};

INSTANTIATE_TEST_SUITE_P(ABIs, ConfiguredSemaTest, ::testing::Values(cw::ABIKind::Itanium, cw::ABIKind::Microsoft),
                         [](const auto& info) { return info.param == cw::ABIKind::Itanium ? "Itanium" : "Microsoft"; });

/// \brief Metadata for one external language feature case.
struct LanguageFeatureCase {
  const char* file_stem;  ///< Shared snake_case file stem.
  const char* test_name;  ///< PascalCase GTest parameter name.
};

/// \brief Runs source-driven language feature cases through Parser and Sema.
class LanguageFeatureTest : public SemaTest, public ::testing::WithParamInterface<LanguageFeatureCase> {};

TEST_P(LanguageFeatureTest, MatchesExpectedAst) { AnalyzeLanguageFeature(GetParam().file_stem); }

std::string LanguageFeatureCaseName(const ::testing::TestParamInfo<LanguageFeatureCase>& information) {
  return information.param.test_name;
}

INSTANTIATE_TEST_SUITE_P(
    LanguageFeatures, LanguageFeatureTest,
    ::testing::Values(
        LanguageFeatureCase{"variable_declaration", "VariableDeclaration"},
        LanguageFeatureCase{"local_integer_initialization", "LocalIntegerInitialization"},
        LanguageFeatureCase{"numeric_arithmetic", "NumericArithmetic"},
        LanguageFeatureCase{"builtin_comparison", "BuiltinComparison"},
        LanguageFeatureCase{"boolean_logic", "BooleanLogic"},
        LanguageFeatureCase{"boolean_control_flow", "BooleanControlFlow"},
        LanguageFeatureCase{"conditional_expression", "ConditionalExpression"},
        LanguageFeatureCase{"reference_binding", "ReferenceBinding"},
        LanguageFeatureCase{"struct_fields", "StructFields"}, LanguageFeatureCase{"member_access", "MemberAccess"},
        LanguageFeatureCase{"receiver_call", "ReceiverCall"},
        LanguageFeatureCase{"function_definition", "FunctionDefinition"},
        LanguageFeatureCase{"function_type", "FunctionType"},
        LanguageFeatureCase{"function_pointer_call", "FunctionPointerCall"},
        LanguageFeatureCase{"function_address", "FunctionAddress"},
        LanguageFeatureCase{"object_address", "ObjectAddress"}, LanguageFeatureCase{"lexical_scope", "LexicalScope"},
        LanguageFeatureCase{"single_inheritance", "SingleInheritance"},
        LanguageFeatureCase{"derived_to_base_reference_binding", "DerivedToBaseReferenceBinding"},
        LanguageFeatureCase{"object_pointer_conversion", "ObjectPointerConversion"},
        LanguageFeatureCase{"function_overloading", "FunctionOverloading"},
        LanguageFeatureCase{"named_type_parameter", "NamedTypeParameter"},
        LanguageFeatureCase{"construction", "Construction"},
        LanguageFeatureCase{"copy_move_construction", "CopyMoveConstruction"},
        LanguageFeatureCase{"explicit_destruction", "ExplicitDestruction"},
        LanguageFeatureCase{"constructor_this", "ConstructorThis"},
        LanguageFeatureCase{"operator_expression", "OperatorExpression"},
        LanguageFeatureCase{"operator_function_address", "OperatorFunctionAddress"},
        LanguageFeatureCase{"operator_function_call", "OperatorFunctionCall"},
        LanguageFeatureCase{"virtual_functions", "VirtualFunctions"},
        LanguageFeatureCase{"covariant_return", "CovariantReturn"},
        LanguageFeatureCase{"virtual_interface_pointer", "VirtualInterfacePointer"},
        LanguageFeatureCase{"nonvirtual_call", "NonVirtualCall"},
        LanguageFeatureCase{"callable_object", "CallableObject"}, LanguageFeatureCase{"fixed_array", "FixedArray"}),
    LanguageFeatureCaseName);

// Declarations, name conflicts, and type formation.

TEST_F(SemaTest, ReportsDuplicateTypesWithPreviousDeclarationNote) {
  Analyze(R"(trivial struct S {}
trivial struct S {})");

  ExpectError(1, 15, "redefinition of type 'S'", 0);
  ExpectNote(0, 15, "previous declaration is here", 0);
}

TEST_F(SemaTest, DumpsForwardReferencedBaseAndFieldTypes) {
  Analyze("trivial struct D : B { field *B; } trivial struct B {}");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address}} <test.cw:1:1, col:35> D trivial : 'B'
| |-BaseType 'B' Struct {{address:base}} 'B'
| `-FieldDecl {{address}} <col:24, col:33> field '*B'
|   `-PointerType {{address}} <col:30, col:32>
|     `-NamedType {{address}} <col:31, col:32> 'B'
`-StructDecl {{address:base}} <col:36, col:55> B trivial)");
}

TEST_F(SemaTest, ReportsFunctionConflictingWithEarlierType) {
  Analyze(R"(trivial struct S {}
func S() {})");

  ExpectError(1, 5, "declaration of function 'S' conflicts with type declaration", 0);
  ExpectNote(0, 15, "conflicting declaration is here", 0);
}

TEST_F(SemaTest, ReportsFunctionConflictingWithLaterType) {
  Analyze(R"(func S() {}
trivial struct S {})");

  ExpectError(0, 5, "declaration of function 'S' conflicts with type declaration", 0);
  ExpectNote(1, 15, "conflicting declaration is here", 0);
}

TEST_F(SemaTest, AcceptsSameNameOrdinaryFunctions) {
  Analyze(R"(func f() {}
func f(value i32) {})");
}

TEST_F(SemaTest, RejectsDuplicateOrdinaryFunctionSignatures) {
  Analyze(R"(func f(first i32) i32 {}
func f(second i32) u32 {}
func f(third i32) void {}
func f(value u32) void {})");

  ExpectError(1, 5, "redefinition of function 'f'", 0);
  ExpectNote(0, 5, "previous declaration is here", 0);
  ExpectError(2, 5, "redefinition of function 'f'", 0);
  ExpectNote(0, 5, "previous declaration is here", 0);
  ExpectError(0, 22, "function return object is not initialized on this path", 2);
  ExpectError(1, 23, "function return object is not initialized on this path", 2);
}

TEST_F(SemaTest, IgnoresIncompleteParameterSignaturesWhenCheckingDuplicates) {
  Analyze(R"(func f(value Missing) {}
func f(value i32) {}
func f(other i32) {})");

  ExpectError(0, 13, "unknown type 'Missing'", 7);
  ExpectError(2, 5, "redefinition of function 'f'", 0);
  ExpectNote(1, 5, "previous declaration is here", 0);
}

TEST_F(SemaTest, KeepsCompleteParameterSignatureWhenReturnTypeIsUnknown) {
  Analyze(R"(func f(value i32) Missing {}
func f(other i32) void {})");

  ExpectError(0, 18, "unknown type 'Missing'", 7);
  ExpectError(1, 5, "redefinition of function 'f'", 0);
  ExpectNote(0, 5, "previous declaration is here", 0);
}

TEST_F(SemaTest, PreservesInvalidNamedParameterSignaturesWithoutMakingThemCandidates) {
  Analyze(R"(func Before() bool { F(1, 2) }
func F(value i32, value i32) i32 { value }
func F(first i32, second i32) i32 { first }
func F(first i64, second i64) bool { true }
func After() bool { F(1, 2) })");

  ExpectError(1, 18, "redefinition of variable 'value'", 5);
  ExpectNote(1, 7, "previous declaration is here", 5);
  ExpectError(2, 5, "redefinition of function 'F'", 0);
  ExpectNote(1, 5, "previous declaration is here", 0);
}

TEST_F(SemaTest, DoesNotSupplementConflictsForUnregisteredFunctions) {
  Analyze(R"(var f i32 := 1;
func f(value Missing) {})");

  ExpectError(1, 13, "unknown type 'Missing'", 7);
}

TEST_F(SemaTest, ReportsDuplicateGlobalVariablesPerName) {
  Analyze(R"(var first i32, second i32 := 1, 2;
var second i32 := 3;
var first i32 := 4;)");

  ExpectError(1, 4, "redefinition of variable 'second'", 0);
  ExpectNote(0, 15, "previous declaration is here", 0);
  ExpectError(2, 4, "redefinition of variable 'first'", 0);
  ExpectNote(0, 4, "previous declaration is here", 0);
}

TEST_F(SemaTest, GivesTypesPriorityOverGlobalVariables) {
  Analyze(R"(var Earlier i32 := 0;
trivial struct Earlier {}
trivial struct Later {}
var Later i32 := 0;)");

  ExpectError(0, 4, "declaration of variable 'Earlier' conflicts with type declaration", 0);
  ExpectNote(1, 15, "conflicting declaration is here", 0);
  ExpectError(3, 4, "declaration of variable 'Later' conflicts with type declaration", 0);
  ExpectNote(2, 15, "conflicting declaration is here", 0);
}

TEST_F(SemaTest, KeepsFunctionSymbolsWhenGlobalVariablesConflict) {
  Analyze(R"(func function_first() {}
var function_first i32 := 0;
var variable_first i32 := 0;
func variable_first() {})");

  ExpectError(1, 4, "declaration of variable 'function_first' conflicts with function declaration", 0);
  ExpectNote(0, 5, "conflicting declaration is here", 0);
  ExpectError(2, 4, "declaration of variable 'variable_first' conflicts with function declaration", 0);
  ExpectNote(3, 5, "conflicting declaration is here", 0);
}

TEST_F(SemaTest, ContinuesAfterOneNameInGlobalDeclarationConflicts) {
  Analyze(R"(trivial struct Type {}
var first i32, Type i32, second i32 := 1, 2, 3;
var first i32 := 4;
var second i32 := 5;)");

  ExpectError(1, 15, "declaration of variable 'Type' conflicts with type declaration", 0);
  ExpectNote(0, 15, "conflicting declaration is here", 0);
  ExpectError(2, 4, "redefinition of variable 'first'", 0);
  ExpectNote(1, 4, "previous declaration is here", 0);
  ExpectError(3, 4, "redefinition of variable 'second'", 0);
  ExpectNote(1, 25, "previous declaration is here", 0);
}

TEST_F(SemaTest, ResolvesIndependentExplicitVariableTypes) {
  Analyze(R"(trivial struct S {}
func f() { var first *S, second i32; })");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address}} <test.cw:1:1, col:20> S trivial
`-FunctionDecl {{address}} <line:2:1, col:39> f 'func () void'
  `-CompoundStmt {{address}} <col:10, col:39>
    `-DeclStmt {{address}} <col:12, col:37>
      `-VarGroupDecl {{address}} <col:12, col:37>
        |-VarDecl {{address}} <col:16, col:24> first '*S'
        | `-PointerType {{address}} <col:22, col:24>
        |   `-NamedType {{address}} <col:23, col:24> 'S'
        `-VarDecl {{address}} <col:26, col:36> second 'i32'
          `-BuiltinType {{address}} <col:33, col:36> 'i32')");
}

TEST_F(SemaTest, ResolvesNestedFunctionTypeSyntax) {
  Analyze(R"(trivial struct S {}
var empty *func () void := null;
var nested *func (i32, *func (*S) void) *func () *S := null;
var pointer *func (i32) void := null;
func higher(callback *func (i32) void) *func () *S { null })");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address}} <test.cw:1:1, col:20> S trivial
|-VarGroupDecl {{address}} <line:2:1, col:33>
| |-VarDecl {{address}} <col:5, col:24> empty '*func () void'
| | `-PointerType {{address}} <col:11, col:24>
| |   `-FunctionType {{address}} <col:12, col:24>
| |     `-BuiltinType {{address}} <col:20, col:24> 'void'
| `-ImplicitCastExpr {{address}} <col:28, col:32> '*func () void' pure-rvalue <NullToPointer>
|   `-NullLiteral {{address}} <col:28, col:32> '<null>'
|-VarGroupDecl {{address}} <line:3:1, col:61>
| |-VarDecl {{address}} <col:5, col:52> nested '*func (i32, *func (*S) void) *func () *S'
| | `-PointerType {{address}} <col:12, col:52>
| |   `-FunctionType {{address}} <col:13, col:52>
| |     |-BuiltinType {{address}} <col:19, col:22> 'i32'
| |     |-PointerType {{address}} <col:24, col:39>
| |     | `-FunctionType {{address}} <col:25, col:39>
| |     |   |-PointerType {{address}} <col:31, col:33>
| |     |   | `-NamedType {{address}} <col:32, col:33> 'S'
| |     |   `-BuiltinType {{address}} <col:35, col:39> 'void'
| |     `-PointerType {{address}} <col:41, col:52>
| |       `-FunctionType {{address}} <col:42, col:52>
| |         `-PointerType {{address}} <col:50, col:52>
| |           `-NamedType {{address}} <col:51, col:52> 'S'
| `-ImplicitCastExpr {{address}} <col:56, col:60> '*func (i32, *func (*S) void) *func () *S' pure-rvalue <NullToPointer>
|   `-NullLiteral {{address}} <col:56, col:60> '<null>'
|-VarGroupDecl {{address}} <line:4:1, col:38>
| |-VarDecl {{address}} <col:5, col:29> pointer '*func (i32) void'
| | `-PointerType {{address}} <col:13, col:29>
| |   `-FunctionType {{address}} <col:14, col:29>
| |     |-BuiltinType {{address}} <col:20, col:23> 'i32'
| |     `-BuiltinType {{address}} <col:25, col:29> 'void'
| `-ImplicitCastExpr {{address}} <col:33, col:37> '*func (i32) void' pure-rvalue <NullToPointer>
|   `-NullLiteral {{address}} <col:33, col:37> '<null>'
`-FunctionDecl {{address}} <line:5:1, col:60> higher 'func (*func (i32) void) *func () *S'
  |-ParmVarDecl {{address}} <col:13, col:38> callback '*func (i32) void'
  | `-PointerType {{address}} <col:22, col:38>
  |   `-FunctionType {{address}} <col:23, col:38>
  |     |-BuiltinType {{address}} <col:29, col:32> 'i32'
  |     `-BuiltinType {{address}} <col:34, col:38> 'void'
  |-ReturnVarDecl {{address:result}} <col:40, col:51> '*func () *S'
  | `-PointerType {{address}} <col:40, col:51>
  |   `-FunctionType {{address}} <col:41, col:51>
  |     `-PointerType {{address}} <col:49, col:51>
  |       `-NamedType {{address}} <col:50, col:51> 'S'
  `-CompoundStmt {{address}} <col:52, col:60>
    `-ImplicitResultInitializationExpr {{address}} <col:54, col:58> 'void' ReturnVar {{address:result}} '*func () *S'
      `-ImplicitCastExpr {{address}} <col:54, col:58> '*func () *S' pure-rvalue <NullToPointer>
        `-NullLiteral {{address}} <col:54, col:58> '<null>')");
}

TEST_F(SemaTest, PreservesNestedConstAndReferenceFunctionTypes) {
  Analyze(R"(trivial struct S {}
func qualified(value *const S, callback *func (copy S, *const S) move S) *const S {})");

  ExpectError(1, 82, "function return object is not initialized on this path", 2);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-StructDecl {{address}} <test.cw:1:1, col:20> S trivial
`-FunctionDecl {{address}} <line:2:1, col:85> qualified 'func (*const S, *func (copy S, *const S) move S) *const S' contains-errors
  |-ParmVarDecl {{address}} <col:16, col:30> value '*const S'
  | `-PointerType {{address}} <col:22, col:30>
  |   `-ConstType {{address}} <col:23, col:30>
  |     `-NamedType {{address}} <col:29, col:30> 'S'
  |-ParmVarDecl {{address}} <col:32, col:72> callback '*func (copy S, *const S) move S'
  | `-PointerType {{address}} <col:41, col:72>
  |   `-FunctionType {{address}} <col:42, col:72>
  |     |-ReferenceType {{address}} <col:48, col:54> 'copy'
  |     | `-NamedType {{address}} <col:53, col:54> 'S'
  |     |-PointerType {{address}} <col:56, col:64>
  |     | `-ConstType {{address}} <col:57, col:64>
  |     |   `-NamedType {{address}} <col:63, col:64> 'S'
  |     `-ReferenceType {{address}} <col:66, col:72> 'move'
  |       `-NamedType {{address}} <col:71, col:72> 'S'
  |-ReturnVarDecl {{address}} <col:74, col:82> '*const S'
  | `-PointerType {{address}} <col:74, col:82>
  |   `-ConstType {{address}} <col:75, col:82>
  |     `-NamedType {{address}} <col:81, col:82> 'S'
  `-CompoundStmt {{address}} <col:83, col:85> contains-errors)");
}

TEST_F(SemaTest, ReportsAllUnknownTypesInsideFunctionTypes) {
  Analyze(R"(var callback func (MissingParam, MissingSecond) MissingReturn;
var pointer *func (MissingPointee) void;)");

  ExpectError(0, 4, "global variable declaration requires an initializer", 0);
  ExpectError(0, 19, "unknown type 'MissingParam'", 12);
  ExpectError(0, 33, "unknown type 'MissingSecond'", 13);
  ExpectError(0, 48, "unknown type 'MissingReturn'", 13);
  ExpectError(1, 4, "global variable declaration requires an initializer", 0);
  ExpectError(1, 19, "unknown type 'MissingPointee'", 14);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-VarGroupDecl {{address}} <test.cw:1:1, col:63> contains-errors
| `-VarDecl {{address}} <col:5, col:62> callback contains-errors
|   `-FunctionType {{address}} <col:14, col:62> contains-errors
|     |-NamedType {{address}} <col:20, col:32> 'MissingParam' contains-errors
|     |-NamedType {{address}} <col:34, col:47> 'MissingSecond' contains-errors
|     `-NamedType {{address}} <col:49, col:62> 'MissingReturn' contains-errors
`-VarGroupDecl {{address}} <line:2:1, col:41> contains-errors
  `-VarDecl {{address}} <col:5, col:40> pointer contains-errors
    `-PointerType {{address}} <col:13, col:40> contains-errors
      `-FunctionType {{address}} <col:14, col:40> contains-errors
        |-NamedType {{address}} <col:20, col:34> 'MissingPointee' contains-errors
        `-BuiltinType {{address}} <col:36, col:40> 'void')");
}

TEST_F(SemaTest, RejectsInvalidReferenceStructuresAndUses) {
  Analyze(R"(trivial struct S { field mut i32; }
var global mut i32;
func invalid(a const const i32, b mut const i32, c const mut i32, d mut copy i32, e *mut i32, f copy void, g move func () void) {}
func interfaces(a const i32) const i32 {})");

  ExpectError(0, 25, "field type 'mut i32' is not an object type", 7);
  ExpectError(2, 15, "duplicate 'const' qualifier on the same object layer", 15);
  ExpectError(2, 34, "reference referent must not be const-qualified", 13);
  ExpectError(2, 51, "a reference type cannot be const-qualified", 13);
  ExpectError(2, 68, "a reference cannot refer to another reference type", 12);
  ExpectError(2, 84, "pointer type cannot have a reference pointee", 8);
  ExpectError(2, 96, "reference referent 'void' is not an object type", 9);
  ExpectError(2, 109, "reference referent 'func () void' is not an object type", 17);
  ExpectError(3, 18, "by-value parameter type cannot be top-level const-qualified", 9);
  ExpectError(3, 29, "by-value return type cannot be top-level const-qualified", 9);
  ExpectError(1, 4, "global variable declaration requires an initializer", 0);
  ExpectError(1, 11, "global reference variables are not currently supported", 7);
}

TEST_F(SemaTest, RejectsBareVoidObjectDeclarations) {
  Analyze(R"(func sink() {}
var global void;
func bad_parameter(value void) {}
func bad_return() var result void { result := sink(); }
func bad_local() { var value void := { sink() } }
struct S { virtual { func bad_virtual() var result void; } })");

  ExpectError(5, 40, "void function cannot declare a named return object", 15);
  ExpectError(2, 25, "parameter type 'void' is not an object type", 4);
  ExpectError(3, 18, "void function cannot declare a named return object", 15);
  ExpectError(1, 4, "global variable declaration requires an initializer", 0);
  ExpectError(1, 11, "variable type 'void' is not an object type", 4);
  ExpectError(4, 29, "variable type 'void' is not an object type", 4);
}

TEST_F(SemaTest, AcceptsWellFormedFunctionLikeDeclarations) {
  Analyze(R"(struct S {}
struct T {}
func f() {}
func operator+(value copy S) {}
func operator[](base *S, index i32) i32 { 0 }
func operator()(callable copy S) i32 { 0 }
ctor S(value i32) {}
ctor S() {}
dtor S() {}
dtor T() {}
ctor T() {})");
}

TEST_F(SemaTest, ReportsMissingFunctionNameOrOperator) {
  Analyze("func() {}");

  ExpectError(0, 0, "function declaration requires a name or operator", 0);
}

TEST_F(SemaTest, ReportsVariableWithoutTypeOrInitializer) {
  Analyze("var value;");

  ExpectError(0, 4, "global variable declaration requires an initializer", 0);
}

TEST_F(SemaTest, ReportsUnknownAndDuplicateVariableAttributes) {
  Analyze(R"(var(tag, mystery, tag) value i32, other i32 := 1, 2;
func f(var(other) value i32) var(tag, tag) result i32 {}
struct S { virtual { func vf(var(bad) value i32); } })");

  ExpectError(2, 33, "unknown attribute 'bad'", 3);
  ExpectError(1, 11, "unknown attribute 'other'", 5);
  ExpectError(1, 33, "unknown attribute 'tag'", 3);
  ExpectError(1, 38, "unknown attribute 'tag'", 3);
  ExpectError(1, 38, "duplicate attribute 'tag'", 3);
  ExpectError(0, 4, "unknown attribute 'tag'", 3);
  ExpectError(0, 9, "unknown attribute 'mystery'", 7);
  ExpectError(0, 18, "unknown attribute 'tag'", 3);
  ExpectError(0, 18, "duplicate attribute 'tag'", 3);
  ExpectError(1, 54, "return object 'result' is not initialized on this path", 2);
}

// Struct fields, inheritance, and member lookup.

TEST_F(SemaTest, DiagnosesDirectBaseAndFieldNameConflicts) {
  Analyze(R"(trivial struct Base {}
trivial struct Derived : Base {
  Base i32;
})");

  ExpectError(2, 2, "field 'Base' conflicts with direct base 'Base'", 0);
  ExpectNote(1, 25, "direct base is specified here", 0);
}

TEST_F(SemaTest, AllowsDirectFieldsToHideIndirectBaseProjections) {
  Analyze(R"(trivial struct Root { value i32; }
trivial struct Middle : Root {}
trivial struct Derived : Middle { Root i32; }
func Check(value copy Derived) { value.Root; value.Middle.Root.value; })");
}

TEST_F(SemaTest, TracksInitializationThroughAnIndirectBaseProjection) {
  Analyze(R"(trivial struct Root { value i32; }
trivial struct Middle : Root {}
trivial struct Derived : Middle {}
func Initialize(source copy Root) {
  var value Derived;
  value.Root := source;
  value;
})");
}

TEST_F(SemaTest, RejectsDuplicateAndNonObjectFieldsAndInheritanceCycles) {
  Analyze(R"(trivial struct Duplicate { x i32; x u32; }
trivial struct Self : Self {}
trivial struct A : B {}
trivial struct B : A {}
trivial struct BadFields { nothing void; callable func () void; link mut i32; callback *func () void; })");

  ExpectError(0, 34, "duplicate field 'x' in struct 'Duplicate'", 0);
  ExpectNote(0, 27, "previous field declaration is here", 0);
  ExpectError(4, 35, "field type 'void' is not an object type", 4);
  ExpectError(4, 50, "field type 'func () void' is not an object type", 12);
  ExpectError(4, 69, "field type 'mut i32' is not an object type", 7);
  ExpectError(1, 22, "inheritance cycle involving struct 'Self'", 4);
  ExpectError(3, 19, "inheritance cycle involving struct 'A'", 1);
}

TEST_F(SemaTest, DiagnosesInvalidAndUnknownFieldAccessesAndRecovers) {
  Analyze(R"(trivial struct S { value i32; }
func use(value S, number i32, pointer *i32) {
value.missing;
number.value;
pointer->value;
value.value;
}
func later(value i32) { value; })");

  ExpectError(2, 0, "no field or base named 'missing' in struct 'S'", 13);
  ExpectError(3, 0, "member access with '.' requires a struct object, not 'i32'", 12);
  ExpectError(4, 0, "member access with '->' requires a pointer to a struct, not '*i32'", 14);
}

TEST_F(SemaTest, SuppressesFieldDiagnosticsForAnInvalidStruct) {
  Analyze(R"(trivial struct Broken { bad void; good i32; }
func use(value Broken) { value.good; }
func later(value i32) { value; })");

  ExpectError(0, 28, "field type 'void' is not an object type", 4);
}

// Virtual interfaces, overrides, and abstract types.

TEST_F(SemaTest, AssociatesVirtualDefinitionsAndSelectsVirtualInterfacesForCalls) {
  Analyze(R"(func Draw(object copy Base) {}
func Measure(receiver copy Base) {}
struct Base {
  virtual {
    func Draw(this copy Base);
    abstract func Measure(receiver copy Base);
  }
}
ctor Base() {}
dtor Base() {}
func Use(value copy Base) {
  Draw(value);
  value.Measure();
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-FunctionDecl {{address:draw_definition}} <test.cw:1:1, col:31> Draw 'func (copy Base) void' virtual-declaration VirtualFunction {{address:draw_interface}} 'Draw' 'func (copy Base) void'
| |-ParmVarDecl {{address}} <col:11, col:27> object 'copy Base'
| | `-ReferenceType {{address}} <col:18, col:27> 'copy'
| |   `-NamedType {{address}} <col:23, col:27> 'Base'
| `-CompoundStmt {{address}} <col:29, col:31>
|-FunctionDecl {{address:measure_definition}} <line:2:1, col:36> Measure 'func (copy Base) void' virtual-declaration VirtualFunction {{address:measure_interface}} 'Measure' 'func (copy Base) void'
| |-ParmVarDecl {{address}} <col:14, col:32> receiver 'copy Base'
| | `-ReferenceType {{address}} <col:23, col:32> 'copy'
| |   `-NamedType {{address}} <col:28, col:32> 'Base'
| `-CompoundStmt {{address}} <col:34, col:36>
|-StructDecl {{address:base}} <line:3:1, line:8:2> Base abstract
| `-VirtualDecl {{address}} <line:4:3, line:7:4>
|   |-VirtualFunctionDecl {{address:draw_interface}} <line:5:5, col:31> Draw 'func (copy Base) void' definition Function {{address:draw_definition}} 'Draw' 'func (copy Base) void'
|   | `-ParmVarDecl {{address}} <col:15, col:29> this 'copy Base'
|   |   `-ReferenceType {{address}} <col:20, col:29> 'copy'
|   |     `-NamedType {{address}} <col:25, col:29> 'Base'
|   `-VirtualFunctionDecl {{address:measure_interface}} <line:6:5, col:47> Measure 'func (copy Base) void' abstract definition Function {{address:measure_definition}} 'Measure' 'func (copy Base) void'
|     `-ParmVarDecl {{address}} <col:27, col:45> receiver 'copy Base'
|       `-ReferenceType {{address}} <col:36, col:45> 'copy'
|         `-NamedType {{address}} <col:41, col:45> 'Base'
|-ConstructorDecl {{address}} <line:9:1, col:15> Base target Struct {{address:base}} 'Base' 'func () void'
| `-CompoundStmt {{address}} <col:13, col:15>
|-DestructorDecl {{address}} <line:10:1, col:15> Base target Struct {{address:base}} 'Base' 'func () void'
| `-CompoundStmt {{address}} <col:13, col:15>
`-FunctionDecl {{address}} <line:11:1, line:14:2> Use 'func (copy Base) void'
  |-ParmVarDecl {{address:value}} <line:11:10, col:25> value 'copy Base'
  | `-ReferenceType {{address}} <col:16, col:25> 'copy'
  |   `-NamedType {{address}} <col:21, col:25> 'Base'
  `-CompoundStmt {{address}} <col:27, line:14:2>
    |-ExprStmt {{address}} <line:12:3, col:15>
    | `-CallExpr {{address}} <col:3, col:14> 'void'
    |   |-DeclRefExpr {{address}} <col:3, col:7> 'func (copy Base) void' VirtualFunction {{address:draw_interface}} 'Draw' 'func (copy Base) void'
    |   `-DeclRefExpr {{address}} <col:8, col:13> 'const Base' lvalue ParmVar {{address:value}} 'value' 'copy Base'
    `-ExprStmt {{address}} <line:13:3, col:19>
      `-ReceiverCallExpr {{address}} <col:3, col:18> 'void' .
        |-DeclRefExpr {{address}} <col:3, col:8> 'const Base' lvalue ParmVar {{address:value}} 'value' 'copy Base'
        `-DeclRefExpr {{address}} <col:9, col:16> 'func (copy Base) void' VirtualFunction {{address:measure_interface}} 'Measure' 'func (copy Base) void')");
}

TEST_F(SemaTest, RejectsVirtualDeclarationParameterAndReturnNameConflicts) {
  Analyze(R"(struct S {
  virtual {
    abstract func F(s copy S, x i32, x bool);
    func G(s copy S, x i32) var x i32;
  }
}
ctor S() {}
dtor S() {}
func G(receiver copy S, value i32) i32 { value })");

  ExpectError(2, 37, "redefinition of variable 'x'", 1);
  ExpectNote(2, 30, "previous declaration is here", 1);
  ExpectError(3, 32, "redefinition of variable 'x'", 1);
  ExpectNote(3, 21, "previous declaration is here", 1);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-StructDecl {{address:s}} <test.cw:1:1, line:6:2> S contains-errors
| `-VirtualDecl {{address}} <line:2:3, line:5:4> contains-errors
|   |-VirtualFunctionDecl {{address}} <line:3:5, col:46> F 'func (copy S, i32, bool) void' abstract contains-errors
|   | |-ParmVarDecl {{address}} <col:21, col:29> s 'copy S'
|   | | `-ReferenceType {{address}} <col:23, col:29> 'copy'
|   | |   `-NamedType {{address}} <col:28, col:29> 'S'
|   | |-ParmVarDecl {{address}} <col:31, col:36> x 'i32'
|   | | `-BuiltinType {{address}} <col:33, col:36> 'i32'
|   | `-ParmVarDecl {{address}} <col:38, col:44> x 'bool' contains-errors
|   |   `-BuiltinType {{address}} <col:40, col:44> 'bool'
|   `-VirtualFunctionDecl {{address}} <line:4:5, col:39> G 'func (copy S, i32) i32' contains-errors
|     |-ParmVarDecl {{address}} <col:12, col:20> s 'copy S'
|     | `-ReferenceType {{address}} <col:14, col:20> 'copy'
|     |   `-NamedType {{address}} <col:19, col:20> 'S'
|     |-ParmVarDecl {{address}} <col:22, col:27> x 'i32'
|     | `-BuiltinType {{address}} <col:24, col:27> 'i32'
|     `-ReturnVarDecl {{address}} <col:29, col:38> x 'i32' contains-errors
|       `-BuiltinType {{address}} <col:35, col:38> 'i32'
|-ConstructorDecl {{address}} <line:7:1, col:12> S target Struct {{address:s}} 'S' 'func () void'
| `-CompoundStmt {{address}} <col:10, col:12>
|-DestructorDecl {{address}} <line:8:1, col:12> S target Struct {{address:s}} 'S' 'func () void'
| `-CompoundStmt {{address}} <col:10, col:12>
`-FunctionDecl {{address}} <line:9:1, col:49> G 'func (copy S, i32) i32'
  |-ParmVarDecl {{address}} <col:8, col:23> receiver 'copy S'
  | `-ReferenceType {{address}} <col:17, col:23> 'copy'
  |   `-NamedType {{address}} <col:22, col:23> 'S'
  |-ParmVarDecl {{address:value}} <col:25, col:34> value 'i32'
  | `-BuiltinType {{address}} <col:31, col:34> 'i32'
  |-ReturnVarDecl {{address:result}} <col:36, col:39> 'i32'
  | `-BuiltinType {{address}} <col:36, col:39> 'i32'
  `-CompoundStmt {{address}} <col:40, col:49>
    `-ImplicitResultInitializationExpr {{address}} <col:42, col:47> 'void' ReturnVar {{address:result}} 'i32'
      `-ImplicitCastExpr {{address}} <col:42, col:47> 'i32' pure-rvalue <LValueToRValue>
        `-DeclRefExpr {{address}} <col:42, col:47> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32')");
}

TEST_F(SemaTest, ExcludesVirtualInterfacesWithNameConflictsFromOverloads) {
  Analyze(R"(func Use(s copy S) bool { F(s, 1, 2) }
struct S {
  virtual { abstract func F(s copy S, x i32, x i32) i32; }
}
ctor S() {}
dtor S() {}
func F(s copy S, first i64, second i64) bool { true })");

  ExpectError(2, 45, "redefinition of variable 'x'", 1);
  ExpectNote(2, 38, "previous declaration is here", 1);
}

TEST_F(SemaTest, KeepsVirtualRecoveryForDefinitionsWithParameterNameConflicts) {
  Analyze(R"(struct S {
  virtual { func F(s copy S, x i32) i32; }
}
func F(value copy S, value i32) i32 { 1 }
ctor S() {}
dtor S() {}
func Use(s copy S) i32 { F(s, 1) })");

  ExpectError(3, 21, "redefinition of variable 'value'", 5);
  ExpectNote(3, 7, "previous declaration is here", 5);
}

TEST_F(SemaTest, KeepsParameterAndReturnNamesLocalToEachVirtualDeclaration) {
  Analyze(R"(struct S {
  virtual {
    func F(receiver copy S, value i32) var result i32;
    abstract func G(receiver copy S, value i32) var result i32;
  }
}
func F(object copy S, input i32) var output i32 { input }
ctor S() {}
dtor S() {}
func Use(receiver copy S) i32 { F(receiver, 1) + G(receiver, 2) })");
}

TEST_F(SemaTest, DiagnosesNonVirtualCallsWithUnsupportedCallees) {
  Analyze(R"(struct S {}
ctor S() {}
dtor S() {}
func Use(callback *func () void) {
nonvirtual callback();
nonvirtual S();
})");

  ExpectError(4, 0, "'nonvirtual' cannot be used with an indirect function call", 10);
  ExpectError(5, 0, "'nonvirtual' cannot be used with a constructor call", 10);
}

TEST_F(SemaTest, DiagnosesNonVirtualCallsWithoutViableOrdinaryCandidates) {
  Analyze(R"(struct Abstract {
virtual {
abstract func Missing(this copy Abstract);
abstract func Present(this copy Abstract);
}
}
func Present(value i32) {}
ctor Abstract() {}
dtor Abstract() {}
func Use(value copy Abstract) {
value.nonvirtual Missing();
nonvirtual Missing(value);
nonvirtual Present();
})");

  ExpectError(10, 0, "no matching receiver function for nonvirtual call to 'Missing'", 26);
  ExpectError(11, 0, "no matching function for nonvirtual call to 'Missing'", 25);
  ExpectError(12, 0, "no matching function for nonvirtual call to 'Present'", 20);
  ExpectNote(6, 0, "candidate function requires 1 argument, but 0 were provided", 0);
}

TEST_F(SemaTest, DiagnosesOrdinaryFunctionRedefinitionBeforeVirtualDefinitionAssociation) {
  Analyze(R"(struct S {
  virtual { func Draw(self copy S); }
}
func Draw(self copy S) {}
func Draw(object copy S) {}
ctor S() {}
dtor S() {})");

  ExpectError(4, 5, "redefinition of function 'Draw'", 0);
  ExpectNote(3, 5, "previous declaration is here", 0);
}

TEST_F(SemaTest, AssociatesOnlyTheExactOrdinaryOverloadWithAVirtualFunction) {
  Analyze(R"(func Draw(self copy S, value i32) {}
struct S {
  virtual { func Draw(self copy S); }
}
func Draw(self copy S) {}
ctor S() {}
dtor S() {}
func Use(self copy S) {
  Draw(self);
  Draw(self, 1);
})");
}

TEST_F(SemaTest, RejectsIncompatibleVirtualDefinitionReturnWithoutOrdinaryFallback) {
  Analyze(R"(struct S {
  virtual { func Value(self copy S) i32; }
}
func Value(self copy S) u32 { 0 }
ctor S() {}
dtor S() {})");

  ExpectError(3, 24,
              "return type 'u32' of matching function definition does not match return type 'i32' of virtual function "
              "'Value'",
              3);
  ExpectNote(1, 17, "virtual function is declared here", 5);
}

TEST_F(SemaTest, AvoidsMissingDefinitionCascadeAfterAnInvalidMatchingDeclaration) {
  Analyze(R"(struct S {
  virtual { func Value(this copy S) i32; }
}
func Value(this copy S) Missing {}
ctor S() {}
dtor S() {}
func Use(value copy S) {
  value.Value();
  nonvirtual Value(value);
  value.nonvirtual Value();
})");

  ExpectError(3, 24, "unknown type 'Missing'", 7);
}

TEST_F(SemaTest, ReportsSharedNameConflictsWithoutDependentVirtualDiagnostics) {
  Analyze(R"(trivial struct Clash {}
struct S { virtual { func Clash(this copy S); } }
func Clash(this copy S) {}
ctor S() {}
dtor S() {})");

  ExpectError(2, 5, "declaration of function 'Clash' conflicts with type declaration", 0);
  ExpectNote(0, 15, "conflicting declaration is here", 0);
  ExpectError(1, 26, "declaration of function 'Clash' conflicts with type declaration", 0);
  ExpectNote(0, 15, "conflicting declaration is here", 0);
}

TEST_F(SemaTest, EstablishesExplicitOverridesAndAllowsReabstraction) {
  Analyze(R"(struct Base {
  virtual { abstract func Draw(self copy Base); }
}
struct Middle : Base {
  virtual { override func Draw(self copy Middle); }
}
struct Leaf : Middle {
  virtual { abstract override func Draw(self copy Leaf); }
}
func Draw(self copy Middle) {}
ctor Base() {}
dtor Base() {}
ctor Middle() { this.Base := Base(); }
dtor Middle() {}
ctor Leaf() { this.Middle := Middle(); }
dtor Leaf() {}
func Use(middle copy Middle, leaf copy Leaf) {
  middle.Draw();
  leaf.Draw();
})");
}

TEST_F(SemaTest, AcceptsCovariantVirtualReturnTypes) {
  Analyze(R"(trivial struct Product {}
trivial struct SpecialProduct : Product {}
struct Factory {
  virtual {
    abstract func Pointer(this copy Factory) *const Product;
    abstract func Mutable(this copy Factory) mut Product;
    abstract func Copyable(this copy Factory) copy Product;
    abstract func Movable(this copy Factory) move Product;
  }
}
struct SpecialFactory : Factory {
  virtual {
    override abstract func Pointer(this copy SpecialFactory) *SpecialProduct;
    override abstract func Mutable(this copy SpecialFactory) mut SpecialProduct;
    override abstract func Copyable(this copy SpecialFactory) mut SpecialProduct;
    override abstract func Movable(this copy SpecialFactory) move SpecialProduct;
  }
}
ctor Factory() {}
dtor Factory() {}
ctor SpecialFactory() { this.Factory := Factory(); }
dtor SpecialFactory() {})");
}

TEST_F(SemaTest, PreservesStaticCovariantResultsAcrossVirtualCallForms) {
  Analyze(R"(trivial struct Product {}
trivial struct SpecialProduct : Product {}
struct Factory {
  virtual { func Create(this copy Factory, value *SpecialProduct) *Product; }
}
func Create(this copy Factory, value *SpecialProduct) *Product { value }
struct SpecialFactory : Factory {
  virtual { override func Create(this copy SpecialFactory, value *SpecialProduct) *SpecialProduct; }
}
func Create(this copy SpecialFactory, value *SpecialProduct) *SpecialProduct { value }
ctor Factory() {}
dtor Factory() {}
ctor SpecialFactory() { this.Factory := Factory(); }
dtor SpecialFactory() {}
func Use(factory copy Factory, special copy SpecialFactory, value *SpecialProduct) {
  var direct_base *Product := Create(factory, value);
  var direct_special *SpecialProduct := Create(special, value);
  var receiver_base *Product := factory.Create(value);
  var receiver_special *SpecialProduct := special.Create(value);
  var base_slot virtual *func (copy Factory, *SpecialProduct) *Product := &Create;
  var special_slot virtual *func (copy SpecialFactory, *SpecialProduct) *SpecialProduct := &Create;
  var indirect_base *Product := base_slot(factory, value);
  var indirect_special *SpecialProduct := special_slot(special, value);
  var nonvirtual_base *Product := nonvirtual Create(factory, value);
  var nonvirtual_special *SpecialProduct := special.nonvirtual Create(value);
})");
}

TEST_F(SemaTest, RejectsInvalidCovariantPointerReturns) {
  Analyze(R"(trivial struct Root {}
trivial struct Leaf : Root {}
trivial struct Other {}
struct Base {
  virtual {
    abstract func Unrelated(this copy Base) *Root;
    abstract func Reverse(this copy Base) *Leaf;
    abstract func ConstLoss(this copy Base) *Root;
    abstract func Deep(this copy Base) **Root;
    abstract func Mixed(this copy Base) *Root;
  }
}
struct Derived : Base {
  virtual {
    override abstract func Unrelated(this copy Derived) *Other;
    override abstract func Reverse(this copy Derived) *Root;
    override abstract func ConstLoss(this copy Derived) *const Leaf;
    override abstract func Deep(this copy Derived) **Leaf;
    override abstract func Mixed(this copy Derived) copy Leaf;
  }
}
ctor Base() {}
dtor Base() {}
ctor Derived() { this.Base := Base(); }
dtor Derived() {})");

  ExpectError(14, 56,
              "return type '*Other' of virtual function 'Unrelated' is not covariant with overridden return type "
              "'*Root' because 'Other' is not derived from 'Root'",
              6);
  ExpectNote(5, 44, "overridden virtual function is declared here", 5);
  ExpectError(15, 54,
              "return type '*Root' of virtual function 'Reverse' is not covariant with overridden return type "
              "'*Leaf' because 'Root' is not derived from 'Leaf'",
              5);
  ExpectNote(6, 42, "overridden virtual function is declared here", 5);
  ExpectError(16, 56,
              "return type '*const Leaf' of virtual function 'ConstLoss' is not covariant with overridden return "
              "type '*Root' because it would remove pointee 'const'",
              11);
  ExpectNote(7, 44, "overridden virtual function is declared here", 5);
  ExpectError(17, 51,
              "return type '**Leaf' of virtual function 'Deep' is not covariant with overridden return type "
              "'**Root'; only direct object pointer and reference return types may be covariant",
              6);
  ExpectNote(8, 39, "overridden virtual function is declared here", 6);
  ExpectError(18, 52,
              "return type 'copy Leaf' of virtual function 'Mixed' is not covariant with overridden return type "
              "'*Root' because one return type is a pointer and the other is a reference",
              9);
  ExpectNote(9, 40, "overridden virtual function is declared here", 5);
}

TEST_F(SemaTest, RejectsInvalidCovariantReferenceReturns) {
  Analyze(R"(trivial struct Root {}
trivial struct Leaf : Root {}
struct Base {
  virtual {
    abstract func Mutable(this copy Base) mut Root;
    abstract func Copyable(this copy Base) copy Root;
    abstract func Movable(this copy Base) move Root;
  }
}
struct Derived : Base {
  virtual {
    override abstract func Mutable(this copy Derived) copy Leaf;
    override abstract func Copyable(this copy Derived) move Leaf;
    override abstract func Movable(this copy Derived) copy Leaf;
  }
}
ctor Base() {}
dtor Base() {}
ctor Derived() { this.Base := Base(); }
dtor Derived() {})");

  ExpectError(11, 54,
              "return type 'copy Leaf' of virtual function 'Mutable' is not covariant with overridden return type "
              "'mut Root' because a 'copy' return cannot satisfy the overridden 'mut' return",
              9);
  ExpectNote(4, 42, "overridden virtual function is declared here", 8);
  ExpectError(12, 55,
              "return type 'move Leaf' of virtual function 'Copyable' is not covariant with overridden return type "
              "'copy Root' because their reference categories differ",
              9);
  ExpectNote(5, 43, "overridden virtual function is declared here", 9);
  ExpectError(13, 54,
              "return type 'copy Leaf' of virtual function 'Movable' is not covariant with overridden return type "
              "'move Root' because their reference categories differ",
              9);
  ExpectNote(6, 42, "overridden virtual function is declared here", 9);
}

TEST_F(SemaTest, KeepsAnInheritedAbstractSlotAfterInvalidCovariantOverride) {
  Analyze(R"(trivial struct Root {}
trivial struct Other {}
struct Base {
  virtual { abstract func Make(this copy Base) *Root; }
}
struct Broken : Base {
  virtual { override func Make(this copy Broken) *Other; }
}
ctor Base() {}
dtor Base() {}
ctor Broken() { this.Base := Base(); }
dtor Broken() {}
func Use(value Broken) {})");

  ExpectError(6, 49,
              "return type '*Other' of virtual function 'Make' is not covariant with overridden return type '*Root' "
              "because 'Other' is not derived from 'Root'",
              6);
  ExpectNote(3, 47, "overridden virtual function is declared here", 5);
  ExpectError(12, 15, "by-value parameter type 'Broken' is abstract", 6);
}

TEST_F(SemaTest, KeepsAbstractnessAfterVirtualInterfaceTypeUseError) {
  Analyze(R"(struct A {
  virtual { abstract func F(this copy A, value A); }
}
ctor A() {}
dtor A() {}
func Take(value A) {})");

  ExpectError(1, 47, "by-value parameter type 'A' is abstract", 1);
  ExpectError(5, 16, "by-value parameter type 'A' is abstract", 1);
}

TEST_F(SemaTest, ValidatesAbstractUsesInsideContainedFunctionTypes) {
  Analyze(R"(struct Abstract {
  virtual { abstract func Observe(self copy Abstract); }
}
ctor Abstract() {}
dtor Abstract() {}
trivial struct Holder {
  callback *func (Abstract, *Abstract, copy Abstract) Abstract;
  pointer *Abstract;
}
func Use(callback *func (Abstract, *Abstract, copy Abstract) Abstract) {})");

  ExpectError(6, 18, "by-value parameter type 'Abstract' is abstract", 8);
  ExpectError(6, 54, "by-value return type 'Abstract' is abstract", 8);
  ExpectError(9, 25, "by-value parameter type 'Abstract' is abstract", 8);
  ExpectError(9, 61, "by-value return type 'Abstract' is abstract", 8);
}

TEST_F(SemaTest, RequiresALocalOverrideForACovariantTypeOutsideFunction) {
  Analyze(R"(trivial struct Product {}
trivial struct SpecialProduct : Product {}
struct Factory {
  virtual { abstract func Create(this copy Factory, value *SpecialProduct) *Product; }
}
struct SpecialFactory : Factory {}
func Create(this copy SpecialFactory, value *SpecialProduct) *SpecialProduct { value }
ctor Factory() {}
dtor Factory() {}
ctor SpecialFactory() { this.Factory := Factory(); }
dtor SpecialFactory() {})");

  ExpectError(5, 7, "type 'SpecialFactory' is missing an explicit override declaration for virtual function 'Create'",
              14);
  ExpectNote(6, 5, "function with a matching signature is defined here", 6);
  ExpectNote(3, 26, "inherited virtual function is declared here", 6);
}

TEST_F(SemaTest, RequiresAnExactDefinitionReturnForACovariantInterface) {
  Analyze(R"(trivial struct Product {}
trivial struct SpecialProduct : Product {}
struct Factory {
  virtual { abstract func Create(this copy Factory, value *Product) *Product; }
}
struct SpecialFactory : Factory {
  virtual { override func Create(this copy SpecialFactory, value *Product) *SpecialProduct; }
}
func Create(this copy SpecialFactory, value *Product) *Product { value }
ctor Factory() {}
dtor Factory() {}
ctor SpecialFactory() { this.Factory := Factory(); }
dtor SpecialFactory() {})");

  ExpectError(8, 54,
              "return type '*Product' of matching function definition does not match return type "
              "'*SpecialProduct' of virtual function 'Create'",
              8);
  ExpectNote(6, 26, "virtual function is declared here", 6);
}

TEST_F(SemaTest, RequiresVirtualDefinitionsAndExplicitOverrides) {
  Analyze(R"(struct Base {
  virtual {
    func Missing(self copy Base);
    abstract func Draw(self copy Base);
  }
}
struct Derived : Base {
  virtual {
    abstract func Draw(self copy Derived);
    override func New(self copy Derived);
  }
}
ctor Base() {}
dtor Base() {}
ctor Derived() { this.Base := Base(); }
dtor Derived() {})");

  ExpectError(8, 18, "virtual function 'Draw' overrides an inherited virtual function but is not marked 'override'", 4);
  ExpectNote(3, 18, "inherited virtual function is declared here", 4);
  ExpectError(9, 18, "virtual function 'New' marked 'override' does not override an inherited virtual function", 3);
  ExpectError(2, 9, "virtual function 'Missing' requires a definition", 7);
}

TEST_F(SemaTest, KeepsMatchingTopLevelFunctionOrdinaryWhenLocalOverrideIsMissing) {
  Analyze(R"(struct Base {
  virtual { abstract func Draw(self copy Base); }
}
struct Derived : Base {}
func Draw(self copy Derived) { Missing; }
ctor Base() {}
dtor Base() {}
ctor Derived() { this.Base := Base(); }
dtor Derived() {}
func Use(value copy Derived) { value.Draw(); })");

  ExpectError(3, 7, "type 'Derived' is missing an explicit override declaration for virtual function 'Draw'", 7);
  ExpectNote(4, 5, "function with a matching signature is defined here", 4);
  ExpectNote(1, 26, "inherited virtual function is declared here", 4);
  ExpectError(4, 31, "use of undeclared identifier 'Missing'", 7);
}

TEST_F(SemaTest, RejectsCompleteObjectsOfAbstractTypeButAllowsReferencesAndPointers) {
  Analyze(R"(struct Abstract {
  virtual { abstract func Observe(self copy Abstract); }
}
ctor Abstract() {}
dtor Abstract() {}
struct Holder { value Abstract; }
var global Abstract;
func Take(value Abstract) {}
func Make() Abstract {}
func Use(value copy Abstract, pointer *Abstract) {
  value.Observe();
  Abstract();
  var local Abstract;
})");

  ExpectError(5, 22, "field type 'Abstract' is abstract", 8);
  ExpectError(7, 16, "by-value parameter type 'Abstract' is abstract", 8);
  ExpectError(8, 12, "by-value return type 'Abstract' is abstract", 8);
  ExpectError(6, 4, "global variable declaration requires an initializer", 0);
  ExpectError(6, 11, "variable type 'Abstract' is abstract", 8);
  ExpectError(11, 2, "cannot construct an object of abstract type 'Abstract'", 8);
  ExpectError(12, 12, "variable type 'Abstract' is abstract", 8);
}

TEST_F(SemaTest, AllowsConstructionOfAnAbstractDirectBaseSubobject) {
  Analyze(R"(struct Abstract {
  virtual { abstract func Observe(self copy Abstract); }
}
ctor Abstract() {}
dtor Abstract() {}
struct Concrete : Abstract {
  virtual { override func Observe(self copy Concrete); }
}
func Observe(self copy Concrete) {}
ctor Concrete() { this.Abstract := Abstract(); }
dtor Concrete() {})");
}

// Construction, destruction, and explicit trivial types.

TEST_F(SemaTest, RejectsDuplicateConstructorAndDestructorSignatures) {
  Analyze(R"(struct S {}
struct T {}
ctor S(value i32) {}
ctor S(other i32) {}
ctor T() {}
dtor S() {}
dtor S() {}
dtor T() {})");

  ExpectError(3, 5, "redefinition of constructor", 0);
  ExpectNote(2, 5, "previous declaration is here", 0);
  ExpectError(6, 5, "redefinition of destructor", 0);
  ExpectNote(5, 5, "previous declaration is here", 0);
  ExpectError(0, 0, "non-trivial struct 'S' requires exactly one destructor", 11);
}

TEST_F(SemaTest, RejectsConstructorNameConflictsBeforeRegisteringCandidates) {
  Analyze(R"(struct S {}
ctor S(value i32, value i32) {}
dtor S() {}
func Use() { var value S := S(1, 2); })");

  ExpectError(1, 18, "redefinition of variable 'value'", 5);
  ExpectNote(1, 7, "previous declaration is here", 5);
  ExpectError(3, 28, "no constructor declared for type 'S'", 7);
}

TEST_F(SemaTest, ExcludesInvalidConstructorInterfaceFromCallableSlot) {
  Analyze(R"(struct S {}
ctor S(var(bad) value i32) {}
dtor S() {}
func use() { S(1); })");

  ExpectError(1, 11, "unknown attribute 'bad'", 3);
  ExpectError(3, 13, "no constructor declared for type 'S'", 4);
}

TEST_F(SemaTest, ComputesNonTrivialityBeforeCheckingSpecialFunctionCompleteness) {
  Analyze(R"(trivial struct Base {}
struct Derived : Base {}
ctor Derived() {}
dtor Derived() {}
struct Child {}
ctor Child() {}
dtor Child() {}
struct Container { field Child; }
struct InvalidCtor {}
ctor InvalidCtor(value Missing) {})");

  ExpectError(9, 23, "unknown type 'Missing'", 7);
  ExpectError(1, 17, "non-trivial struct 'Derived' cannot inherit trivial struct 'Base'", 4);
  ExpectError(7, 0, "non-trivial struct 'Container' requires a constructor", 33);
  ExpectError(7, 0, "non-trivial struct 'Container' requires exactly one destructor", 33);
  ExpectError(8, 0, "non-trivial struct 'InvalidCtor' requires exactly one destructor", 21);
  ExpectError(2, 15, "object 'this' is not fully initialized on this path", 2);
}

TEST_F(SemaTest, SpecialFunctionCompletenessErrorsDoNotBlockMemberBinding) {
  Analyze(R"(struct S { value i32; }
ctor S() { this.value := 1; })");

  ExpectError(0, 0, "non-trivial struct 'S' requires exactly one destructor", 23);
}

TEST_F(SemaTest, DumpsConstructorAndDestructorTypes) {
  Analyze(R"(struct S {}
ctor S(value i32) {}
dtor S() {})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address:structure}} <test.cw:1:1, col:12> S
|-ConstructorDecl {{address}} <line:2:1, col:21> S target Struct {{address:structure}} 'S' 'func (i32) void'
| |-ParmVarDecl {{address}} <col:8, col:17> value 'i32'
| | `-BuiltinType {{address}} <col:14, col:17> 'i32'
| `-CompoundStmt {{address}} <col:19, col:21>
`-DestructorDecl {{address}} <line:3:1, col:12> S target Struct {{address:structure}} 'S' 'func () void'
  `-CompoundStmt {{address}} <col:10, col:12>)");
}

TEST_F(SemaTest, ReportsUnknownAndNonTypeSpecialFunctionTargets) {
  Analyze(R"(trivial struct S {}
var Value i32 := 0;
func Function() {}
ctor Missing() {}
ctor Value() {}
dtor Missing() {}
dtor Function() {})");

  ExpectError(3, 5, "unknown constructor target type 'Missing'", 7);
  ExpectError(4, 5, "unknown constructor target type 'Value'", 5);
  ExpectError(5, 5, "unknown destructor target type 'Missing'", 7);
  ExpectError(6, 5, "unknown destructor target type 'Function'", 8);
}

TEST_F(SemaTest, FormsOrdinaryPlacementConstructionAndExplicitDestruction) {
  Analyze(R"(struct S {}
ctor S(value i64) {}
dtor S() {}
func use(pointer *S, constant *const S, value i32) {
  S(value);
  ctor (pointer) S(value);
  dtor (pointer) S();
  dtor (constant) S();
})");
}

TEST_F(SemaTest, DiagnosesInvalidConstructionAndDestructionAddresses) {
  Analyze(R"(struct S {}
trivial struct T {}
ctor S() {}
dtor S() {}
func use(mutable *S, fixed *const S, other *T, number i32) {
  ctor (fixed) S();
  ctor (other) S();
  ctor (number) S();
  dtor (other) S();
  dtor (number) S();
})");

  ExpectError(5, 8, "constructor target address must have type '*S', not '*const S'", 5);
  ExpectError(6, 8, "constructor target address must have type '*S', not '*T'", 5);
  ExpectError(7, 8, "constructor target address must have type '*S', not 'i32'", 6);
  ExpectError(8, 8, "destructor target address must have type '*S' or '*const S', not '*T'", 5);
  ExpectError(9, 8, "destructor target address must have type '*S' or '*const S', not 'i32'", 6);
}

TEST_F(SemaTest, DiagnosesUnknownExplicitDestructorTarget) {
  Analyze("func use(pointer *i32) { dtor (pointer) Missing(); }");

  ExpectError(0, 40, "unknown destructor target type 'Missing'", 7);
}

TEST_F(SemaTest, DiagnosesMissingNoMatchAndAmbiguousConstructors) {
  Analyze(R"(trivial struct Missing {}
struct Choice {}
ctor Choice(value i16) {}
ctor Choice(value u16) {} dtor Choice() {}
func use(pointer *Missing, value i32) {
  Missing(1);
  dtor (pointer) Missing();
  Choice(true);
  Choice(value);
})");

  ExpectError(5, 2, "no constructor declared for type 'Missing'", 10);
  ExpectError(6, 2, "no destructor declared for type 'Missing'", 24);
  ExpectError(7, 2, "no matching constructor for type 'Choice'", 12);
  ExpectNote(2, 0, "candidate constructor is not viable: no implicit conversion from 'bool' to 'i16' for argument 1",
             0);
  ExpectNote(3, 0, "candidate constructor is not viable: no implicit conversion from 'bool' to 'u16' for argument 1",
             0);
  ExpectError(8, 2, "construction of 'Choice' is ambiguous", 13);
  ExpectNote(2, 0, "candidate constructor", 0);
  ExpectNote(3, 0, "candidate constructor", 0);
}

TEST_F(SemaTest, AppliesNonTrivialDirectTransferToConstructorArguments) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func Make() Value { return Value(); }
struct Box {}
ctor Box(value Value) {}
dtor Box() {}
func Check(existing mut Value) {
  Box(Make());
  Box(existing);
  Box(move existing);
})");

  ExpectError(9, 6, "cannot initialize parameter 1 of constructor 'Box': no copy constructor is available for 'Value'",
              8);
  ExpectError(10, 6,
              "cannot initialize parameter 1 of constructor 'Box': no move or copy constructor is available for "
              "'Value'",
              13);
}

TEST_F(SemaTest, RestrictsThisAndDelegationToTheirSemanticContexts) {
  Analyze(R"(struct S {}
ctor S(value i32) {}
ctor S() { 0; this := S(1); }
ctor S(value bool) { this := value; }
dtor S() { this := S(1); this; }
func outside() { this; })");

  ExpectError(2, 14, "constructor delegation must be the first complete statement in the constructor body", 4);
  ExpectError(3, 29, "constructor delegation must directly construct the current type 'S'", 5);
  ExpectError(4, 11, "only a constructor can initialize the current object", 4);
  ExpectError(5, 17, "use of undeclared identifier 'this'", 4);
}

TEST_F(SemaTest, DiagnosesIndirectDelegatingConstructorCycles) {
  Analyze(R"(struct S {}
ctor S(value i32) { this := S(); }
ctor S() { this := S(0); }
dtor S() {})");

  ExpectError(2, 19, "delegating constructor cycle for type 'S'", 4);
  ExpectNote(1, 28, "constructor 'S' delegates here", 3);
  ExpectNote(2, 19, "constructor 'S' delegates here", 4);
}

TEST_F(SemaTest, DiagnosesIndirectDelegatingConstructorCyclesThroughParentheses) {
  Analyze(R"(struct S {}
ctor S(value i32) { this := (S()); }
ctor S() { this := ((S(0))); }
dtor S() {})");

  ExpectError(2, 21, "delegating constructor cycle for type 'S'", 4);
  ExpectNote(1, 29, "constructor 'S' delegates here", 3);
  ExpectNote(2, 21, "constructor 'S' delegates here", 4);
}

TEST_F(SemaTest, TreatsGroupedBaseInitializationAsOneInvalidPrologueAttempt) {
  Analyze(R"(struct Base {}
ctor Base() {}
dtor Base() {}
struct Derived : Base {}
ctor Derived() { (this.Base := Base()); }
dtor Derived() {})");

  ExpectError(4, 18, "initialization expression must be used directly as an expression statement", 19);
}

TEST_F(SemaTest, TransfersNonTrivialPureRValuesAndRejectsGlvalues) {
  Analyze(R"(struct Inner {}
ctor Inner() {}
dtor Inner() {}
struct Outer { field Inner; }
ctor Outer(source copy Inner) {
  this.field := source;
}
dtor Outer() {}
func local(source copy Inner) {
  var value Inner;
  value := source;
}
func bad_declarations(source copy Inner) {
  var explicit Inner := source;
  var inferred := source;
}
func make() Inner { return Inner(); }
func bad_return(source copy Inner) Inner { return source; }
func good_function_result() { var value Inner := make(); }
ctor Outer() { this.field := make(); }
func good_results(condition bool) Inner {
  var explicit Inner := make();
  var inferred := make();
  var block Inner := { make() }
  return condition ? make() : Inner();
})");

  ExpectError(5, 16, "cannot initialize field 'field': no copy constructor is available for 'Inner'", 6);
  ExpectError(10, 11, "cannot initialize variable 'value': no copy constructor is available for 'Inner'", 6);
  ExpectError(13, 24, "cannot initialize variable 'explicit': no copy constructor is available for 'Inner'", 6);
  ExpectError(14, 18, "cannot infer and initialize variable: no copy constructor is available for 'Inner'", 6);
  ExpectError(17, 50, "cannot initialize return object: no copy constructor is available for 'Inner'", 6);
}

TEST_F(SemaTest, RejectsSeparateInitializationOfANonTrivialObjectsSubobject) {
  Analyze(R"(struct Inner {}
ctor Inner() {}
dtor Inner() {}
struct Outer { inner Inner; }
ctor Outer() { this.inner := Inner(); }
dtor Outer() {}
func Reject() {
  var outer Outer;
  outer.inner := Inner();
})");

  ExpectError(8, 2, "cannot initialize a subobject of type 'Outer' separately", 5);
}

TEST_F(SemaTest, RejectsDirectInitializationOfInheritedFieldsInDerivedConstructor) {
  Analyze(R"(struct Base { inherited i32; }
ctor Base(value i32) { this.inherited := value; }
dtor Base() {}
struct Derived : Base { own i32; }
ctor Derived() {
  this.Base := Base(0);
  this.inherited := 1;
  this.own := 2;
}
dtor Derived() {})");

  ExpectError(6, 2,
              "constructor for 'Derived' cannot initialize inherited field 'inherited' directly; initialize direct "
              "base 'Base' instead",
              14);
}

TEST_F(SemaTest, RequiresDerivedConstructorsToInitializeTheDirectBaseProjection) {
  Analyze(R"(struct Root {}
ctor Root() {}
dtor Root() {}
struct Middle : Root {}
ctor Middle() { this.Root := Root(); }
dtor Middle() {}
struct Derived : Middle {}
ctor Derived() { this.Root := Root(); }
dtor Derived() {})");

  ExpectError(7, 17, "constructor for 'Derived' must initialize direct base 'Middle', not indirect base 'Root'", 9);
}

TEST_F(SemaTest, RequiresDelegationOrDirectBaseConstructionAtDerivedConstructorEntry) {
  Analyze(R"(struct Base { value i32; }
ctor Base() { this.value := 1; }
dtor Base() {}
struct Derived : Base { own i32; }
ctor Derived() { this.own := 2; }
dtor Derived() {})");

  ExpectError(4, 5, "constructor for 'Derived' must begin by delegating or by initializing direct base 'Base'", 7);
}

TEST_F(SemaTest, DiagnosesInvalidDirectBaseInitializationAtTheAttempt) {
  Analyze(R"(struct Base { member i32; }
ctor Base(value i32) { this.member := value; }
dtor Base() {}
struct Late : Base {}
ctor Late() { 0; this.Base := Base(0); }
dtor Late() {}
struct Partial : Base {}
ctor Partial(value i32) { this.Base.member := value; }
dtor Partial() {}
struct Copy : Base {}
ctor Copy(source copy Base) { this.Base := source; }
dtor Copy() {})");

  ExpectError(4, 17, "direct base 'Base' must be initialized by the first complete statement of constructor 'Late'", 9);
  ExpectError(7, 26, "constructor for 'Partial' must initialize direct base 'Base' as a whole", 16);
  ExpectError(10, 43, "cannot initialize base subobject 'Base': no copy constructor is available for 'Base'", 6);
}

TEST_F(SemaTest, RecoversSpecialCallsAcrossIncompleteDeclarationsBodiesAndArguments) {
  Analyze(R"(struct S {}
struct T {}
ctor S(value Missing) {}
ctor S(value i32) { missing_constructor_body; }
dtor S() { missing_destructor_body; }
ctor T(value Missing) {}
dtor T(value i32) {}
func use(pointer *S, other *T, value i32) {
  S(value);
  ctor (pointer) S(missing_argument);
  T(value);
  dtor (other) T();
})");

  ExpectError(6, 7, "expected ')'", 5);
  ExpectError(2, 13, "unknown type 'Missing'", 7);
  ExpectError(5, 13, "unknown type 'Missing'", 7);
  ExpectError(3, 20, "use of undeclared identifier 'missing_constructor_body'", 24);
  ExpectError(4, 11, "use of undeclared identifier 'missing_destructor_body'", 23);
  ExpectError(9, 19, "use of undeclared identifier 'missing_argument'", 16);
  ExpectError(10, 2, "no constructor declared for type 'T'", 8);
  ExpectError(11, 2, "no destructor declared for type 'T'", 16);
}

TEST_F(SemaTest, KeepsConstructorWithErroneousBodyInOverloadSet) {
  Analyze(R"(struct S {}
ctor S(value i32) { missing_constructor_body; }
ctor S(value bool) {}
func use(value i32) { S(value); }
dtor S() {})");

  ExpectError(1, 20, "use of undeclared identifier 'missing_constructor_body'", 24);
}

TEST_F(SemaTest, KeepsDestructorWithErroneousBodyInUniqueSlot) {
  Analyze(R"(struct S {}
dtor S() { missing_destructor_body; }
dtor S() {}
ctor S() {})");

  ExpectError(2, 5, "redefinition of destructor", 0);
  ExpectNote(1, 5, "previous declaration is here", 0);
  ExpectError(0, 0, "non-trivial struct 'S' requires exactly one destructor", 11);
  ExpectError(1, 11, "use of undeclared identifier 'missing_destructor_body'", 23);
}

TEST_F(SemaTest, DoesNotBypassInnerSymbolForSpecialCalls) {
  Analyze(R"(struct S {}
ctor S() {} dtor S() {}
func use(pointer *S) {
  var S i32 := 1;
  S();
  ctor (pointer) S();
})");

  ExpectError(4, 2, "expression of type 'i32' is not callable", 3);
  ExpectError(5, 17, "'S' does not name a struct type", 1);
}

TEST_F(SemaTest, KeepsFormedPlacementConstructionAfterLateUninitializedAddressFinding) {
  Analyze(R"(struct S {}
ctor S() {} dtor S() {}
func use() {
  var pointer *S;
  ctor (pointer) S();
})");

  ExpectError(4, 8, "use of uninitialized variable 'pointer'", 7);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-StructDecl {{address:structure}} <test.cw:1:1, col:12> S
|-ConstructorDecl {{address:constructor}} <line:2:1, col:12> S target Struct {{address:structure}} 'S' 'func () void'
| `-CompoundStmt {{address}} <col:10, col:12>
|-DestructorDecl {{address}} <col:13, col:24> S target Struct {{address:structure}} 'S' 'func () void'
| `-CompoundStmt {{address}} <col:22, col:24>
`-FunctionDecl {{address}} <line:3:1, line:6:2> use 'func () void' contains-errors
  `-CompoundStmt {{address}} <line:3:12, line:6:2> contains-errors
    |-DeclStmt {{address}} <line:4:3, col:18>
    | `-VarGroupDecl {{address}} <col:3, col:18>
    |   `-VarDecl {{address:pointer}} <col:7, col:17> pointer '*S'
    |     `-PointerType {{address}} <col:15, col:17>
    |       `-NamedType {{address}} <col:16, col:17> 'S'
    `-ExprStmt {{address}} <line:5:3, col:22> contains-errors
      `-ConstructionExpr {{address}} <col:3, col:21> '*S' pure-rvalue complete-object target <col:18, col:19> 'S' Constructor {{address:constructor}} 'S' 'func () void' contains-errors
        `-ImplicitCastExpr {{address}} <col:9, col:16> '*S' pure-rvalue <LValueToRValue> contains-errors
          `-DeclRefExpr {{address}} <col:9, col:16> '*S' lvalue Var {{address:pointer}} 'pointer' '*S' contains-errors)");
}

TEST_F(SemaTest, KeepsPlacementConstructionUnboundWhenAnArgumentIsErroneous) {
  Analyze(R"(struct S {}
ctor S(value i32) {} dtor S() {}
func use(pointer *S) {
  ctor (pointer) S(missing);
})");

  ExpectError(3, 19, "use of undeclared identifier 'missing'", 7);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-StructDecl {{address:structure}} <test.cw:1:1, col:12> S
|-ConstructorDecl {{address:constructor}} <line:2:1, col:21> S target Struct {{address:structure}} 'S' 'func (i32) void'
| |-ParmVarDecl {{address}} <col:8, col:17> value 'i32'
| | `-BuiltinType {{address}} <col:14, col:17> 'i32'
| `-CompoundStmt {{address}} <col:19, col:21>
|-DestructorDecl {{address}} <col:22, col:33> S target Struct {{address:structure}} 'S' 'func () void'
| `-CompoundStmt {{address}} <col:31, col:33>
`-FunctionDecl {{address}} <line:3:1, line:5:2> use 'func (*S) void' contains-errors
  |-ParmVarDecl {{address:pointer}} <line:3:10, col:20> pointer '*S'
  | `-PointerType {{address}} <col:18, col:20>
  |   `-NamedType {{address}} <col:19, col:20> 'S'
  `-CompoundStmt {{address}} <col:22, line:5:2> contains-errors
    `-ExprStmt {{address}} <line:4:3, col:29> contains-errors
      `-ConstructionExpr {{address}} <col:3, col:28> complete-object target <col:18, col:19> 'S' contains-errors
        |-DeclRefExpr {{address}} <col:9, col:16> '*S' lvalue ParmVar {{address:pointer}} 'pointer' '*S'
        `-DeclRefExpr {{address}} <col:20, col:27> 'missing' contains-errors)");
}

TEST_F(SemaTest, RejectsValueReturnsFromConstructorsAndDestructors) {
  Analyze(R"(struct S {}
ctor S() { return 1; }
dtor S() { return 1; })");

  ExpectError(1, 11, "constructor cannot return a value", 0);
  ExpectError(2, 11, "destructor cannot return a value", 0);
}

TEST_P(ConfiguredSemaTest, PreservesTrivialDefaultFormationAndFinalDestination) {
  Analyze(R"(trivial struct Empty {}
func Make() Empty { Empty() })");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address}} <test.cw:1:1, col:24> Empty trivial
`-FunctionDecl {{address}} <line:2:1, col:30> Make 'func () Empty'
  |-ReturnVarDecl {{address:result}} <col:13, col:18> 'Empty'
  | `-NamedType {{address}} <col:13, col:18> 'Empty'
  `-CompoundStmt {{address}} <col:19, col:30>
    `-ImplicitResultInitializationExpr {{address}} <col:21, col:28> 'void' ReturnVar {{address:result}} 'Empty'
      `-ConstructionExpr {{address}} <col:21, col:28> 'Empty' pure-rvalue complete-object target <col:21, col:26> 'Empty')");
}

TEST_F(SemaTest, DefaultsAllTrivialComponentsWithoutSyntheticConstructors) {
  Analyze(R"(trivial struct Empty {}
trivial struct Base { integer i64; }
trivial struct Value : Base {
  empty Empty;
  array [3] Empty;
  zero [0] Empty;
  boolean bool;
  floating f64;
  pointer *Value;
  function *func() void;
  slot virtual *func(mut Value) void;
}
func Use() Value {
  var value Value := Value();
  var delayed Empty;
  delayed := Empty();
  var nested [2] Value := [2] Value { Value(), Value() };
  value
})");
}

TEST_F(SemaTest, RequiresLifecycleDeclarationsForUnmarkedEmptyStruct) {
  Analyze("struct Empty {}");
  ExpectError(0, 0, "non-trivial struct 'Empty' requires a constructor", 15);
  ExpectError(0, 0, "non-trivial struct 'Empty' requires exactly one destructor", 15);
}

TEST_F(SemaTest, RejectsLifecycleDeclarationsOnExplicitTrivialStruct) {
  Analyze(R"(trivial struct Value {}
ctor Value() {}
dtor Value() {})");
  ExpectError(0, 0, "trivial struct 'Value' cannot declare constructors, destructors or virtual slots", 23);
}

TEST_F(SemaTest, RejectsNonTrivialComponentsEvenInZeroLengthArrays) {
  Analyze(R"(struct Object {}
ctor Object() {}
dtor Object() {}
trivial struct Field { object Object; }
trivial struct Derived : Object {}
trivial struct Array { objects [0] Object; })");
  ExpectError(3, 0, "trivial struct 'Field' requires trivial base and field types", 39);
  ExpectError(4, 0, "trivial struct 'Derived' requires trivial base and field types", 34);
  ExpectError(5, 0, "trivial struct 'Array' requires trivial base and field types", 44);
}

TEST_F(SemaTest, PreservesMissingConstructorBindingAsAnError) {
  Analyze(R"(trivial struct Empty {}
func Use() { Empty(1); })");
  ExpectError(1, 13, "no constructor declared for type 'Empty'", 8);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-StructDecl {{address}} <test.cw:1:1, col:24> Empty trivial
`-FunctionDecl {{address}} <line:2:1, col:25> Use 'func () void' contains-errors
  `-CompoundStmt {{address}} <col:12, col:25> contains-errors
    `-ExprStmt {{address}} <col:14, col:23> contains-errors
      `-CallExpr {{address}} <col:14, col:22> contains-errors
        |-DeclRefExpr {{address}} <col:14, col:19> 'Empty' contains-errors
        `-ImplicitCastExpr {{address}} <col:20, col:21> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
          `-IntegerLiteral {{address}} <col:20, col:21> 'comptime_int' 1)");
}

TEST_F(SemaTest, RejectsVirtualSlotsOnExplicitTrivialStruct) {
  Analyze(R"(trivial struct Value {
  virtual { abstract func Read(this copy Value) i32; }
})");
  ExpectError(0, 0, "trivial struct 'Value' cannot declare constructors, destructors or virtual slots", 0);
}

// Function calls, receivers, and callable objects.

TEST_F(SemaTest, ResolvesForwardAndRecursiveZeroArgumentCalls) {
  Analyze(R"(func caller() i32 { return target(); }
func target() i32 { return target(); })");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-FunctionDecl {{address}} <test.cw:1:1, col:39> caller 'func () i32'
| |-ReturnVarDecl {{address:caller_return}} <col:15, col:18> 'i32'
| | `-BuiltinType {{address}} <col:15, col:18> 'i32'
| `-CompoundStmt {{address}} <col:19, col:39>
|   `-ReturnStmt {{address}} <col:21, col:37>
|     `-ImplicitResultInitializationExpr {{address}} <col:28, col:36> 'void' ReturnVar {{address:caller_return}} 'i32'
|       `-CallExpr {{address}} <col:28, col:36> 'i32' pure-rvalue
|         `-DeclRefExpr {{address}} <col:28, col:34> 'func () i32' Function {{address:target}} 'target' 'func () i32'
`-FunctionDecl {{address:target}} <line:2:1, col:39> target 'func () i32'
  |-ReturnVarDecl {{address:target_return}} <col:15, col:18> 'i32'
  | `-BuiltinType {{address}} <col:15, col:18> 'i32'
  `-CompoundStmt {{address}} <col:19, col:39>
    `-ReturnStmt {{address}} <col:21, col:37>
      `-ImplicitResultInitializationExpr {{address}} <col:28, col:36> 'void' ReturnVar {{address:target_return}} 'i32'
        `-CallExpr {{address}} <col:28, col:36> 'i32' pure-rvalue
          `-DeclRefExpr {{address}} <col:28, col:34> 'func () i32' Function {{address:target}} 'target' 'func () i32')");
}

TEST_F(SemaTest, AcceptsFieldAccessAndReceiverFormCalls) {
  Analyze(R"(trivial struct S { value i32; read i32; }
func read(receiver copy S) i32 { 0 }
func mutate(receiver mut S) i32 { 0 }
func take(receiver move S) i32 { 0 }
func read_pointer(receiver copy *S) i32 { 0 }
func read_number(receiver copy i32) i32 { 0 }
func make() S { S() }
func caller(value S, pointer *S, const_pointer *const S, number_pointer *i32) {
value.value;
value.read;
pointer->value;
value.read();
value.mutate();
(move value).take();
make().take();
pointer.read_pointer();
pointer->mutate();
pointer->read();
const_pointer->read();
number_pointer->read_number();
})");
}

TEST_F(SemaTest, AcceptsExplicitThisParametersWithoutChangingReceiverEligibility) {
  Analyze(R"(trivial struct S {}
func Read(this copy S) { this; }
func Write(this mut S, source copy S) { this = source; }
func Consume(this move S) { move this; }
func Named(receiver copy S) { receiver; }
func Pointer(this copy *S) { this; }
struct V { virtual { abstract func Observe(this copy V); } }
ctor V() {}
dtor V() {}
func Calls(value S, pointer *S) {
  Read(value);
  value.Read();
  Write(value, value);
  value.Write(value);
  Consume(move value);
  (move value).Consume();
  value.Named();
  pointer.Pointer();
})");
}

TEST_F(SemaTest, DiagnosesInvalidExplicitThisParametersAndDoesNotCreateAnAlias) {
  Analyze(R"(struct S {}
func Later(value i32, this mut S) { this; }
func ByValue(this S) {}
func Pointer(this *S) {}
ctor S(this mut S) { this; }
dtor S() {}
func Named(receiver mut S) { this; })");

  ExpectError(4, 7, "constructor cannot declare an explicit 'this' parameter", 4);
  ExpectError(1, 22, "'this' parameter must be the first parameter", 4);
  ExpectError(2, 13, "'this' parameter must have type 'mut T', 'copy T', or 'move T'", 4);
  ExpectError(3, 13, "'this' parameter must have type 'mut T', 'copy T', or 'move T'", 4);
  ExpectError(6, 29, "use of undeclared identifier 'this'", 4);
}

TEST_F(SemaTest, TreatsExplicitThisAndOrdinaryParameterNamesAsTheSameSignature) {
  Analyze(R"(trivial struct S {}
func Same(this mut S) {}
func Same(object mut S) {})");

  ExpectError(2, 5, "redefinition of function 'Same'", 0);
  ExpectNote(1, 5, "previous declaration is here", 0);
}

TEST_F(SemaTest, ExplainsReceiverCandidateFailuresAndCrossArgumentAmbiguity) {
  Analyze(R"(func read(receiver copy i32) {}
func zero() {}
func by_value(receiver i32) {}
func wrong(receiver copy i64) {}
func only_move(receiver move i32) {}
func typed(receiver copy i32, value i32) {}
func cross(receiver mut i32, value i64) {}
func cross(receiver copy i32, value i32) {}
func recover(number i32, pointer *void) {
pointer->read();
number.zero();
number.by_value();
number.wrong();
number.only_move();
number.typed();
number.typed(true);
number.cross(number);
number;
})");

  ExpectError(9, 7, "receiver call with '->' requires a pointer to an object, not '*void'", 2);
  ExpectError(10, 0, "no matching receiver function for call to 'zero'", 13);
  ExpectNote(1, 0, "candidate function is not viable: no receiver parameter is declared", 0);
  ExpectError(12, 0, "no matching receiver function for call to 'wrong'", 14);
  ExpectNote(3, 0,
             "candidate function is not viable: reference type 'copy i64' cannot bind to a value of type 'i32' for "
             "receiver",
             0);
  ExpectError(13, 0, "no matching receiver function for call to 'only_move'", 18);
  ExpectNote(4, 0,
             "candidate function is not viable: reference type 'move i32' cannot bind to lvalue of type 'i32' for "
             "receiver",
             0);
  ExpectError(14, 0, "no matching receiver function for call to 'typed'", 14);
  ExpectNote(5, 0, "candidate function requires 1 explicit argument, but 0 were provided", 0);
  ExpectError(15, 0, "no matching receiver function for call to 'typed'", 18);
  ExpectNote(5, 0, "candidate function is not viable: no implicit conversion from 'bool' to 'i32' for argument 1", 0);
  ExpectError(16, 0, "call to 'cross' is ambiguous", 20);
  ExpectNote(6, 0, "candidate function", 0);
  ExpectNote(7, 0, "candidate function", 0);
}

TEST_F(SemaTest, ReportsReceiverCandidateFailuresInDependencyOrder) {
  Analyze(R"(func Invalid(receiver i32) {}
func Use(value i32) { value.Invalid(1); })");

  ExpectError(1, 22, "no matching receiver function for call to 'Invalid'", 16);
  ExpectNote(0, 0, "candidate function requires 0 explicit arguments, but 1 was provided", 0);
}

TEST_F(SemaTest, CallsFunctionPointersAndRejectsNonCallableObjects) {
  Analyze(R"(trivial struct Holder { callback *func () void; value i32; }
func inspect(holder Holder, fnptr *func () void) {
(holder.callback)();
(holder.value)();
holder.callback();
fnptr();
})");

  ExpectError(3, 0, "expression of type 'i32' is not callable", 16);
  ExpectError(4, 7, "use of undeclared identifier 'callback'", 8);
}

TEST_F(SemaTest, FormsValueReceiversLikeOrdinaryArguments) {
  Analyze(R"(func Take(value i32) {}
func Use(value i32, pointer *i32) {
  value.Take();
  pointer->Take();
  Take(value);
  Take(*pointer);
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-FunctionDecl {{address:take}} <test.cw:1:1, col:24> Take 'func (i32) void'
| |-ParmVarDecl {{address}} <col:11, col:20> value 'i32'
| | `-BuiltinType {{address}} <col:17, col:20> 'i32'
| `-CompoundStmt {{address}} <col:22, col:24>
`-FunctionDecl {{address}} <line:2:1, line:7:2> Use 'func (i32, *i32) void'
  |-ParmVarDecl {{address:value}} <line:2:10, col:19> value 'i32'
  | `-BuiltinType {{address}} <col:16, col:19> 'i32'
  |-ParmVarDecl {{address:pointer}} <col:21, col:33> pointer '*i32'
  | `-PointerType {{address}} <col:29, col:33>
  |   `-BuiltinType {{address}} <col:30, col:33> 'i32'
  `-CompoundStmt {{address}} <col:35, line:7:2>
    |-ExprStmt {{address}} <line:3:3, col:16>
    | `-ReceiverCallExpr {{address}} <col:3, col:15> 'void' .
    |   |-ImplicitCastExpr {{address}} <col:3, col:8> 'i32' pure-rvalue <LValueToRValue>
    |   | `-DeclRefExpr {{address}} <col:3, col:8> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
    |   `-DeclRefExpr {{address}} <col:9, col:13> 'func (i32) void' Function {{address:take}} 'Take' 'func (i32) void'
    |-ExprStmt {{address}} <line:4:3, col:19>
    | `-ReceiverCallExpr {{address}} <col:3, col:18> 'void' ->
    |   |-ImplicitCastExpr {{address}} <col:3, col:10> 'i32' pure-rvalue <LValueToRValue>
    |   | `-UnaryOperator {{address}} <col:3, col:10> 'i32' lvalue '*'
    |   |   `-ImplicitCastExpr {{address}} <col:3, col:10> '*i32' pure-rvalue <LValueToRValue>
    |   |     `-DeclRefExpr {{address}} <col:3, col:10> '*i32' lvalue ParmVar {{address:pointer}} 'pointer' '*i32'
    |   `-DeclRefExpr {{address}} <col:12, col:16> 'func (i32) void' Function {{address:take}} 'Take' 'func (i32) void'
    |-ExprStmt {{address}} <line:5:3, col:15>
    | `-CallExpr {{address}} <col:3, col:14> 'void'
    |   |-DeclRefExpr {{address}} <col:3, col:7> 'func (i32) void' Function {{address:take}} 'Take' 'func (i32) void'
    |   `-ImplicitCastExpr {{address}} <col:8, col:13> 'i32' pure-rvalue <LValueToRValue>
    |     `-DeclRefExpr {{address}} <col:8, col:13> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
    `-ExprStmt {{address}} <line:6:3, col:18>
      `-CallExpr {{address}} <col:3, col:17> 'void'
        |-DeclRefExpr {{address}} <col:3, col:7> 'func (i32) void' Function {{address:take}} 'Take' 'func (i32) void'
        `-ImplicitCastExpr {{address}} <col:8, col:16> 'i32' pure-rvalue <LValueToRValue>
          `-UnaryOperator {{address}} <col:8, col:16> 'i32' lvalue '*'
            `-ImplicitCastExpr {{address}} <col:9, col:16> '*i32' pure-rvalue <LValueToRValue>
              `-DeclRefExpr {{address}} <col:9, col:16> '*i32' lvalue ParmVar {{address:pointer}} 'pointer' '*i32')");
}

TEST_F(SemaTest, CopiesMovesAndSlicesValueReceivers) {
  Analyze(R"(struct Base {}
ctor Base() {}
ctor Base(source copy Base) {}
dtor Base() {}
struct Derived : Base {}
ctor Derived() { this.Base := Base(); }
dtor Derived() {}
struct Movable {}
ctor Movable() {}
ctor Movable(source move Movable) {}
dtor Movable() {}
func Take(value Base) {}
func Consume(value Movable) {}
func Pointer(value *Derived) {}
func Use(base mut Base, fixed copy Base, derived mut Derived, pointer *Derived, movable mut Movable) {
  base.Take();
  fixed.Take();
  (move base).Take();
  Base().Take();
  derived.Take();
  pointer->Take();
  pointer.Pointer();
  (move movable).Consume();
  Movable().Consume();
  Take(derived);
  Take(*pointer);
})");
}

TEST_F(SemaTest, KeepsReceiverAndOrdinaryCallAmbiguityEquivalent) {
  Analyze(R"(func Pick(value i32) {}
func Pick(value mut i32) {}
func Use(value i32) {
  value.Pick();
  Pick(value);
})");

  ExpectError(3, 2, "call to 'Pick' is ambiguous", 12);
  ExpectNote(0, 0, "candidate function", 0);
  ExpectNote(1, 0, "candidate function", 0);
  ExpectError(4, 2, "call to 'Pick' is ambiguous", 11);
  ExpectNote(0, 0, "candidate function", 0);
  ExpectNote(1, 0, "candidate function", 0);
}

TEST_F(SemaTest, PreservesArrowSourceWhenReceiverFormationFails) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func Take(receiver Value, number u8) {}
func Use(pointer *Value, number i32) {
  pointer->Take(number);
})");

  ExpectError(5, 2, "cannot initialize receiver of function 'Take': no copy constructor is available for 'Value'", 7);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-StructDecl {{address:value}} <test.cw:1:1, col:16> Value
|-ConstructorDecl {{address}} <line:2:1, col:16> Value target Struct {{address:value}} 'Value' 'func () void'
| `-CompoundStmt {{address}} <col:14, col:16>
|-DestructorDecl {{address}} <line:3:1, col:16> Value target Struct {{address:value}} 'Value' 'func () void'
| `-CompoundStmt {{address}} <col:14, col:16>
|-FunctionDecl {{address:take}} <line:4:1, col:40> Take 'func (Value, u8) void'
| |-ParmVarDecl {{address}} <col:11, col:25> receiver 'Value'
| | `-NamedType {{address}} <col:20, col:25> 'Value'
| |-ParmVarDecl {{address}} <col:27, col:36> number 'u8'
| | `-BuiltinType {{address}} <col:34, col:36> 'u8'
| `-CompoundStmt {{address}} <col:38, col:40>
`-FunctionDecl {{address}} <line:5:1, line:7:2> Use 'func (*Value, i32) void' contains-errors
  |-ParmVarDecl {{address:pointer}} <line:5:10, col:24> pointer '*Value'
  | `-PointerType {{address}} <col:18, col:24>
  |   `-NamedType {{address}} <col:19, col:24> 'Value'
  |-ParmVarDecl {{address:number}} <col:26, col:36> number 'i32'
  | `-BuiltinType {{address}} <col:33, col:36> 'i32'
  `-CompoundStmt {{address}} <col:38, line:7:2> contains-errors
    `-ExprStmt {{address}} <line:6:3, col:25> contains-errors
      `-ReceiverCallExpr {{address}} <col:3, col:24> -> contains-errors
        |-UnaryOperator {{address}} <col:3, col:10> 'Value' lvalue '*'
        | `-ImplicitCastExpr {{address}} <col:3, col:10> '*Value' pure-rvalue <LValueToRValue>
        |   `-DeclRefExpr {{address}} <col:3, col:10> '*Value' lvalue ParmVar {{address:pointer}} 'pointer' '*Value'
        |-DeclRefExpr {{address}} <col:12, col:16> 'func (Value, u8) void' Function {{address:take}} 'Take' 'func (Value, u8) void'
        `-DeclRefExpr {{address}} <col:17, col:23> 'i32' lvalue ParmVar {{address:number}} 'number' 'i32')");
}

TEST_F(SemaTest, DoesNotFallBackAfterSelectedReceiverOrParameterFormationFails) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func Take(receiver Value, rank i32) {}
func Take(receiver copy Value, rank i64) {}
func Use(value mut Value, rank i32) {
  value.Take(rank);
  Take(value, rank);
})");

  ExpectError(6, 2, "cannot initialize receiver of function 'Take': no copy constructor is available for 'Value'", 5);
  ExpectError(7, 7, "cannot initialize parameter 1 of function 'Take': no copy constructor is available for 'Value'",
              5);
}

TEST_F(SemaTest, ReportsValueReceiverConversionRisksInArgumentOrder) {
  Analyze(R"(func Take(receiver u8, number u8) {}
func Use(value i32, number i16) {
  value.Take(number);
})");

  ExpectWarning(2, 2, "implicit integer conversion from 'i32' to 'u8' may truncate value", 5);
  ExpectWarning(2, 13, "implicit integer conversion from 'i16' to 'u8' may truncate value", 6);
}

TEST_F(SemaTest, RejectsStructObjectWithoutCallOperator) {
  Analyze(R"(trivial struct S {}
func Use(object mut S) {
  object();
})");

  ExpectError(2, 2, "expression of type 'S' is not callable", 8);
}

TEST_F(SemaTest, ReportsCallOperatorArityWithoutCountingReceiver) {
  Analyze(R"(trivial struct S {}
func operator()(object mut S, value i32) {}
func Use(object mut S) {
  object();
})");

  ExpectError(3, 2, "no matching function for call to object of type 'S'", 8);
  ExpectNote(1, 0, "candidate function requires 1 explicit argument, but 0 were provided", 0);
}

TEST_F(SemaTest, ReportsAmbiguousCallableObjectOverloads) {
  Analyze(R"(trivial struct S {}
func operator()(object mut S, value i64) {}
func operator()(object copy S, value i32) {}
func Use(object mut S, value i32) {
  object(value);
})");

  ExpectError(4, 2, "call to object of type 'S' is ambiguous", 13);
  ExpectNote(1, 0, "candidate function", 0);
  ExpectNote(2, 0, "candidate function", 0);
}

TEST_F(SemaTest, RequiresExplicitDereferenceForCallableObjectPointers) {
  Analyze(R"(trivial struct S {}
func operator()(object mut S) {}
func Use(pointer *S) {
  pointer();
})");

  ExpectError(3, 2, "expression of type '*S' is not callable", 9);
}

TEST_F(SemaTest, DiagnosesUninitializedCallableObjectCallee) {
  Analyze(R"(trivial struct S { value i32; }
func operator()(object mut S) {}
func Use() {
  var object S;
  object();
})");

  ExpectError(4, 2, "use of uninitialized variable 'object'", 6);
}

TEST_F(SemaTest, DiagnosesExplicitParameterFormationFailureInReceiverCall) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func Consume(receiver copy i32, object Value) {}
func Use(receiver i32, object mut Value) { receiver.Consume(object); })");

  ExpectError(4, 60,
              "cannot initialize parameter 1 of receiver function 'Consume': no copy constructor is available for "
              "'Value'",
              6);
}

TEST_F(SemaTest, KeepsArrowReceiverPreparedWhenWinnerFormationFails) {
  const std::string source = R"(trivial struct Base {}
trivial struct Derived : Base {}
struct Value {}
ctor Value() {}
dtor Value() {}
func Consume(receiver copy Base, number u8, object Value) {}
func Use(pointer *Derived, number i32, object mut Value) { pointer->Consume(number, object); })";
  Analyze(source);
  const auto call_line = source.substr(source.rfind('\n') + 1);
  ExpectError(
      6, static_cast<int>(call_line.find("object);")),
      "cannot initialize parameter 2 of receiver function 'Consume': no copy constructor is available for 'Value'", 6);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-StructDecl {{address:base}} <test.cw:1:1, col:23> Base trivial
|-StructDecl {{address:derived}} <line:2:1, col:33> Derived trivial : 'Base'
| `-BaseType 'Base' Struct {{address:base}} 'Base'
|-StructDecl {{address:value}} <line:3:1, col:16> Value
|-ConstructorDecl {{address:value_constructor}} <line:4:1, col:16> Value target Struct {{address:value}} 'Value' 'func () void'
| `-CompoundStmt {{address}} <col:14, col:16>
|-DestructorDecl {{address:value_destructor}} <line:5:1, col:16> Value target Struct {{address:value}} 'Value' 'func () void'
| `-CompoundStmt {{address}} <col:14, col:16>
|-FunctionDecl {{address:consume}} <line:6:1, col:61> Consume 'func (copy Base, u8, Value) void'
| |-ParmVarDecl {{address:consume_receiver}} <col:14, col:32> receiver 'copy Base'
| | `-ReferenceType {{address}} <col:23, col:32> 'copy'
| |   `-NamedType {{address}} <col:28, col:32> 'Base'
| |-ParmVarDecl {{address:consume_number}} <col:34, col:43> number 'u8'
| | `-BuiltinType {{address}} <col:41, col:43> 'u8'
| |-ParmVarDecl {{address:consume_object}} <col:45, col:57> object 'Value'
| | `-NamedType {{address}} <col:52, col:57> 'Value'
| `-CompoundStmt {{address}} <col:59, col:61>
`-FunctionDecl {{address:use}} <line:7:1, col:95> Use 'func (*Derived, i32, mut Value) void' contains-errors
  |-ParmVarDecl {{address:use_pointer}} <col:10, col:26> pointer '*Derived'
  | `-PointerType {{address}} <col:18, col:26>
  |   `-NamedType {{address}} <col:19, col:26> 'Derived'
  |-ParmVarDecl {{address:use_number}} <col:28, col:38> number 'i32'
  | `-BuiltinType {{address}} <col:35, col:38> 'i32'
  |-ParmVarDecl {{address:use_object}} <col:40, col:56> object 'mut Value'
  | `-ReferenceType {{address}} <col:47, col:56> 'mut'
  |   `-NamedType {{address}} <col:51, col:56> 'Value'
  `-CompoundStmt {{address}} <col:58, col:95> contains-errors
    `-ExprStmt {{address}} <col:60, col:93> contains-errors
      `-ReceiverCallExpr {{address}} <col:60, col:92> -> contains-errors
        |-UnaryOperator {{address}} <col:60, col:67> 'Derived' lvalue '*'
        | `-ImplicitCastExpr {{address}} <col:60, col:67> '*Derived' pure-rvalue <LValueToRValue>
        |   `-DeclRefExpr {{address}} <col:60, col:67> '*Derived' lvalue ParmVar {{address:use_pointer}} 'pointer' '*Derived'
        |-DeclRefExpr {{address}} <col:69, col:76> 'func (copy Base, u8, Value) void' Function {{address:consume}} 'Consume' 'func (copy Base, u8, Value) void'
        |-DeclRefExpr {{address}} <col:77, col:83> 'i32' lvalue ParmVar {{address:use_number}} 'number' 'i32'
        `-DeclRefExpr {{address}} <col:85, col:91> 'Value' lvalue ParmVar {{address:use_object}} 'object' 'mut Value')");
}

TEST_F(SemaTest, ChecksArrowPointerOnceThroughReadonlyBaseProjection) {
  Analyze(R"(trivial struct Base {}
trivial struct Derived : Base {}
func Take(receiver copy Base) {}
func Use() {
  var pointer *Derived;
  pointer->Take();
})");
  ExpectError(5, 2, "use of uninitialized variable 'pointer'", 7);
}

// Function names, function pointers, and indirect calls.

TEST_F(SemaTest, RejectsParenthesizedDirectFunctionAndTypeNames) {
  Analyze(R"(trivial struct Value {}
func Make() {}
func Use() {
  (Make)();
  (Value)();
})");

  ExpectError(3, 3, "function 'Make' cannot be used as an object expression", 4);
  ExpectError(4, 3, "type 'Value' cannot be used as an object expression", 5);
}

TEST_F(SemaTest, RejectsUnconsumedFunctionOverloadSetsInExpressionStatements) {
  Analyze(R"(func Single() {}
func Over(x i32) {}
func Over(x bool) {}
func Use() {
  Single;
  Over;
  (Single);
  ((Over));
})");

  ExpectError(4, 2, "function 'Single' cannot be used as an object expression", 6);
  ExpectError(5, 2, "function 'Over' cannot be used as an object expression", 4);
  ExpectError(6, 3, "function 'Single' cannot be used as an object expression", 6);
  ExpectError(7, 4, "function 'Over' cannot be used as an object expression", 4);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-FunctionDecl {{address}} <test.cw:1:1, col:17> Single 'func () void'
| `-CompoundStmt {{address}} <col:15, col:17>
|-FunctionDecl {{address}} <line:2:1, col:20> Over 'func (i32) void'
| |-ParmVarDecl {{address}} <col:11, col:16> x 'i32'
| | `-BuiltinType {{address}} <col:13, col:16> 'i32'
| `-CompoundStmt {{address}} <col:18, col:20>
|-FunctionDecl {{address}} <line:3:1, col:21> Over 'func (bool) void'
| |-ParmVarDecl {{address}} <col:11, col:17> x 'bool'
| | `-BuiltinType {{address}} <col:13, col:17> 'bool'
| `-CompoundStmt {{address}} <col:19, col:21>
`-FunctionDecl {{address}} <line:4:1, line:9:2> Use 'func () void' contains-errors
  `-CompoundStmt {{address}} <line:4:12, line:9:2> contains-errors
    |-ExprStmt {{address}} <line:5:3, col:10> contains-errors
    | `-DeclRefExpr {{address}} <col:3, col:9> '<function-overload-set>' 'Single' contains-errors
    |-ExprStmt {{address}} <line:6:3, col:8> contains-errors
    | `-DeclRefExpr {{address}} <col:3, col:7> '<function-overload-set>' 'Over' contains-errors
    |-ExprStmt {{address}} <line:7:3, col:12> contains-errors
    | `-ParenExpr {{address}} <col:3, col:11> '<function-overload-set>' contains-errors
    |   `-DeclRefExpr {{address}} <col:4, col:10> '<function-overload-set>' 'Single'
    `-ExprStmt {{address}} <line:8:3, col:12> contains-errors
      `-ParenExpr {{address}} <col:3, col:11> '<function-overload-set>' contains-errors
        `-ParenExpr {{address}} <col:4, col:10> '<function-overload-set>'
          `-DeclRefExpr {{address}} <col:5, col:9> '<function-overload-set>' 'Over')");
}

TEST_F(SemaTest, RecoversUnconsumedFunctionNamesUsingOnlyDependentErrors) {
  Analyze(R"(func Broken(x i32) Missing {}
func Body() { missing_body; }
func Mixed(x Missing) {}
func Mixed(x i32) {}
func Use() {
  Broken;
  (Broken);
  unknown;
  Body;
  Mixed;
  (Body)();
})");

  ExpectError(0, 19, "unknown type 'Missing'", 7);
  ExpectError(2, 13, "unknown type 'Missing'", 7);
  ExpectError(1, 14, "use of undeclared identifier 'missing_body'", 12);
  ExpectError(7, 2, "use of undeclared identifier 'unknown'", 7);
  ExpectError(8, 2, "function 'Body' cannot be used as an object expression", 4);
  ExpectError(9, 2, "function 'Mixed' cannot be used as an object expression", 5);
  ExpectError(10, 3, "function 'Body' cannot be used as an object expression", 4);
}

TEST_F(SemaTest, AcceptsConsumedFunctionNamesAndIndependentPointerOrShadowingValues) {
  Analyze(R"(func G(x i32) {}
func G(x bool) {}
func Take(p *func (i32) void) {}
func Use() {
  G(1);
  var p *func (i32) void := &G;
  p;
  (p);
  (p)(1);
  p = &G;
  Take(&G);
  var G i32 := 1;
  G;
  (G);
})");
}

TEST_F(SemaTest, KeepsMissingTargetDiagnosticForUnconsumedFunctionAddresses) {
  Analyze(R"(func G() {}
func Use() {
  &G;
  (&G);
})");

  ExpectError(2, 2, "address of function 'G' requires a target function pointer type", 2);
  ExpectError(3, 2, "address of function 'G' requires a target function pointer type", 4);
}

TEST_F(SemaTest, FormsIndirectCallReferenceBindingsAndResults) {
  Analyze(R"(func indirect_mut(callback *func () mut i32) mut i32 { callback() }
func indirect_copy(callback *func () copy i32) copy i32 { callback() }
func indirect_move(callback *func () move i32) move i32 { callback() }
func indirect_value(callback *func () i32) i32 { callback() }
func indirect_function(callback *func () *func () void) { callback(); }
func indirect_void(callback *func (mut i32, copy i32, move i32) void,
                   first i32, second i32) {
callback(first, second, move second);
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-FunctionDecl {{address}} <test.cw:1:1, col:68> indirect_mut 'func (*func () mut i32) mut i32'
| |-ParmVarDecl {{address:mut_callback}} <col:19, col:44> callback '*func () mut i32'
| | `-PointerType {{address}} <col:28, col:44>
| |   `-FunctionType {{address}} <col:29, col:44>
| |     `-ReferenceType {{address}} <col:37, col:44> 'mut'
| |       `-BuiltinType {{address}} <col:41, col:44> 'i32'
| |-ReturnVarDecl {{address:mut_return}} <col:46, col:53> 'mut i32'
| | `-ReferenceType {{address}} <col:46, col:53> 'mut'
| |   `-BuiltinType {{address}} <col:50, col:53> 'i32'
| `-CompoundStmt {{address}} <col:54, col:68>
|   `-ImplicitResultInitializationExpr {{address}} <col:56, col:66> 'void' ReturnVar {{address:mut_return}} 'mut i32'
|     `-CallExpr {{address}} <col:56, col:66> 'i32' lvalue
|       `-ImplicitCastExpr {{address}} <col:56, col:64> '*func () mut i32' pure-rvalue <LValueToRValue>
|         `-DeclRefExpr {{address}} <col:56, col:64> '*func () mut i32' lvalue ParmVar {{address:mut_callback}} 'callback' '*func () mut i32'
|-FunctionDecl {{address}} <line:2:1, col:71> indirect_copy 'func (*func () copy i32) copy i32'
| |-ParmVarDecl {{address:copy_callback}} <col:20, col:46> callback '*func () copy i32'
| | `-PointerType {{address}} <col:29, col:46>
| |   `-FunctionType {{address}} <col:30, col:46>
| |     `-ReferenceType {{address}} <col:38, col:46> 'copy'
| |       `-BuiltinType {{address}} <col:43, col:46> 'i32'
| |-ReturnVarDecl {{address:copy_return}} <col:48, col:56> 'copy i32'
| | `-ReferenceType {{address}} <col:48, col:56> 'copy'
| |   `-BuiltinType {{address}} <col:53, col:56> 'i32'
| `-CompoundStmt {{address}} <col:57, col:71>
|   `-ImplicitResultInitializationExpr {{address}} <col:59, col:69> 'void' ReturnVar {{address:copy_return}} 'copy i32'
|     `-CallExpr {{address}} <col:59, col:69> 'const i32' lvalue
|       `-ImplicitCastExpr {{address}} <col:59, col:67> '*func () copy i32' pure-rvalue <LValueToRValue>
|         `-DeclRefExpr {{address}} <col:59, col:67> '*func () copy i32' lvalue ParmVar {{address:copy_callback}} 'callback' '*func () copy i32'
|-FunctionDecl {{address}} <line:3:1, col:71> indirect_move 'func (*func () move i32) move i32'
| |-ParmVarDecl {{address:move_callback}} <col:20, col:46> callback '*func () move i32'
| | `-PointerType {{address}} <col:29, col:46>
| |   `-FunctionType {{address}} <col:30, col:46>
| |     `-ReferenceType {{address}} <col:38, col:46> 'move'
| |       `-BuiltinType {{address}} <col:43, col:46> 'i32'
| |-ReturnVarDecl {{address:move_return}} <col:48, col:56> 'move i32'
| | `-ReferenceType {{address}} <col:48, col:56> 'move'
| |   `-BuiltinType {{address}} <col:53, col:56> 'i32'
| `-CompoundStmt {{address}} <col:57, col:71>
|   `-ImplicitResultInitializationExpr {{address}} <col:59, col:69> 'void' ReturnVar {{address:move_return}} 'move i32'
|     `-CallExpr {{address}} <col:59, col:69> 'i32' move-lvalue
|       `-ImplicitCastExpr {{address}} <col:59, col:67> '*func () move i32' pure-rvalue <LValueToRValue>
|         `-DeclRefExpr {{address}} <col:59, col:67> '*func () move i32' lvalue ParmVar {{address:move_callback}} 'callback' '*func () move i32'
|-FunctionDecl {{address}} <line:4:1, col:62> indirect_value 'func (*func () i32) i32'
| |-ParmVarDecl {{address:value_callback}} <col:21, col:42> callback '*func () i32'
| | `-PointerType {{address}} <col:30, col:42>
| |   `-FunctionType {{address}} <col:31, col:42>
| |     `-BuiltinType {{address}} <col:39, col:42> 'i32'
| |-ReturnVarDecl {{address:value_return}} <col:44, col:47> 'i32'
| | `-BuiltinType {{address}} <col:44, col:47> 'i32'
| `-CompoundStmt {{address}} <col:48, col:62>
|   `-ImplicitResultInitializationExpr {{address}} <col:50, col:60> 'void' ReturnVar {{address:value_return}} 'i32'
|     `-CallExpr {{address}} <col:50, col:60> 'i32' pure-rvalue
|       `-ImplicitCastExpr {{address}} <col:50, col:58> '*func () i32' pure-rvalue <LValueToRValue>
|         `-DeclRefExpr {{address}} <col:50, col:58> '*func () i32' lvalue ParmVar {{address:value_callback}} 'callback' '*func () i32'
|-FunctionDecl {{address}} <line:5:1, col:72> indirect_function 'func (*func () *func () void) void'
| |-ParmVarDecl {{address:function_callback}} <col:24, col:55> callback '*func () *func () void'
| | `-PointerType {{address}} <col:33, col:55>
| |   `-FunctionType {{address}} <col:34, col:55>
| |     `-PointerType {{address}} <col:42, col:55>
| |       `-FunctionType {{address}} <col:43, col:55>
| |         `-BuiltinType {{address}} <col:51, col:55> 'void'
| `-CompoundStmt {{address}} <col:57, col:72>
|   `-ExprStmt {{address}} <col:59, col:70>
|     `-CallExpr {{address}} <col:59, col:69> '*func () void' pure-rvalue
|       `-ImplicitCastExpr {{address}} <col:59, col:67> '*func () *func () void' pure-rvalue <LValueToRValue>
|         `-DeclRefExpr {{address}} <col:59, col:67> '*func () *func () void' lvalue ParmVar {{address:function_callback}} 'callback' '*func () *func () void'
`-FunctionDecl {{address}} <line:6:1, line:9:2> indirect_void 'func (*func (mut i32, copy i32, move i32) void, i32, i32) void'
  |-ParmVarDecl {{address:void_callback}} <line:6:20, col:69> callback '*func (mut i32, copy i32, move i32) void'
  | `-PointerType {{address}} <col:29, col:69>
  |   `-FunctionType {{address}} <col:30, col:69>
  |     |-ReferenceType {{address}} <col:36, col:43> 'mut'
  |     | `-BuiltinType {{address}} <col:40, col:43> 'i32'
  |     |-ReferenceType {{address}} <col:45, col:53> 'copy'
  |     | `-BuiltinType {{address}} <col:50, col:53> 'i32'
  |     |-ReferenceType {{address}} <col:55, col:63> 'move'
  |     | `-BuiltinType {{address}} <col:60, col:63> 'i32'
  |     `-BuiltinType {{address}} <col:65, col:69> 'void'
  |-ParmVarDecl {{address:first}} <line:7:20, col:29> first 'i32'
  | `-BuiltinType {{address}} <col:26, col:29> 'i32'
  |-ParmVarDecl {{address:second}} <col:31, col:41> second 'i32'
  | `-BuiltinType {{address}} <col:38, col:41> 'i32'
  `-CompoundStmt {{address}} <col:43, line:9:2>
    `-ExprStmt {{address}} <line:8:1, col:38>
      `-CallExpr {{address}} <col:1, col:37> 'void'
        |-ImplicitCastExpr {{address}} <col:1, col:9> '*func (mut i32, copy i32, move i32) void' pure-rvalue <LValueToRValue>
        | `-DeclRefExpr {{address}} <col:1, col:9> '*func (mut i32, copy i32, move i32) void' lvalue ParmVar {{address:void_callback}} 'callback' '*func (mut i32, copy i32, move i32) void'
        |-DeclRefExpr {{address}} <col:10, col:15> 'i32' lvalue ParmVar {{address:first}} 'first' 'i32'
        |-ImplicitCastExpr {{address}} <col:17, col:23> 'const i32' lvalue <NoOp>
        | `-DeclRefExpr {{address}} <col:17, col:23> 'i32' lvalue ParmVar {{address:second}} 'second' 'i32'
        `-UnaryOperator {{address}} <col:25, col:36> 'i32' move-lvalue 'move'
          `-DeclRefExpr {{address}} <col:30, col:36> 'i32' lvalue ParmVar {{address:second}} 'second' 'i32')");
}

TEST_F(SemaTest, DiagnosesIndirectCallSignatureErrorsWithoutCandidateNotes) {
  Analyze(R"(func inspect(callback *func (i32, mut i32) void, readonly copy i32) {
callback();
callback(true, readonly);
})");

  ExpectError(1, 0, "indirect function call requires 2 arguments, but 0 were provided", 10);
  ExpectError(
      2, 9, "cannot initialize parameter 1 of indirect function call: no implicit conversion from 'bool' to 'i32'", 4);
}

TEST_F(SemaTest, PreservesFailedIndirectCallChildrenWithoutPartialConversions) {
  Analyze(R"(func inspect(callback *func (i16, i32) void, small i8) {
callback(small, true);
})");

  ExpectError(
      1, 16, "cannot initialize parameter 2 of indirect function call: no implicit conversion from 'bool' to 'i32'", 4);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, line:3:2> inspect 'func (*func (i16, i32) void, i8) void' contains-errors
  |-ParmVarDecl {{address:callback}} <line:1:14, col:44> callback '*func (i16, i32) void'
  | `-PointerType {{address}} <col:23, col:44>
  |   `-FunctionType {{address}} <col:24, col:44>
  |     |-BuiltinType {{address}} <col:30, col:33> 'i16'
  |     |-BuiltinType {{address}} <col:35, col:38> 'i32'
  |     `-BuiltinType {{address}} <col:40, col:44> 'void'
  |-ParmVarDecl {{address:small}} <col:46, col:54> small 'i8'
  | `-BuiltinType {{address}} <col:52, col:54> 'i8'
  `-CompoundStmt {{address}} <col:56, line:3:2> contains-errors
    `-ExprStmt {{address}} <line:2:1, col:23> contains-errors
      `-CallExpr {{address}} <col:1, col:22> contains-errors
        |-DeclRefExpr {{address}} <col:1, col:9> '*func (i16, i32) void' lvalue ParmVar {{address:callback}} 'callback' '*func (i16, i32) void'
        |-DeclRefExpr {{address}} <col:10, col:15> 'i8' lvalue ParmVar {{address:small}} 'small' 'i8'
        `-BoolLiteral {{address}} <col:17, col:21> 'bool' pure-rvalue true contains-errors)");
}

TEST_F(SemaTest, DiagnosesUninitializedFunctionPointerCalleeAfterCallFormation) {
  Analyze(R"(func inspect() {
var callback *func () void;
callback();
})");

  ExpectError(2, 0, "use of uninitialized variable 'callback'", 8);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, line:4:2> inspect 'func () void' contains-errors
  `-CompoundStmt {{address}} <line:1:16, line:4:2> contains-errors
    |-DeclStmt {{address}} <line:2:1, col:28>
    | `-VarGroupDecl {{address}} <col:1, col:28>
    |   `-VarDecl {{address:callback}} <col:5, col:27> callback '*func () void'
    |     `-PointerType {{address}} <col:14, col:27>
    |       `-FunctionType {{address}} <col:15, col:27>
    |         `-BuiltinType {{address}} <col:23, col:27> 'void'
    `-ExprStmt {{address}} <line:3:1, col:12> contains-errors
      `-CallExpr {{address}} <col:1, col:11> 'void' contains-errors
        `-ImplicitCastExpr {{address}} <col:1, col:9> '*func () void' pure-rvalue <LValueToRValue> contains-errors
          `-DeclRefExpr {{address}} <col:1, col:9> '*func () void' lvalue Var {{address:callback}} 'callback' '*func () void' contains-errors)");
}

TEST_F(SemaTest, ReportsIndirectCallConversionRisks) {
  Analyze(R"(func inspect(callback *func (i8) void, value i32) {
callback(value);
})");

  ExpectWarning(1, 9, "implicit integer conversion from 'i32' to 'i8' may truncate value", 5);
}

TEST_F(SemaTest, DescribesFunctionNamesAndAddressesInDiagnostics) {
  Analyze(R"(func F() {}
func Take(value copy i32) {}
func Use() {
  if F {}
  !(&F);
  var inferred := F;
  var number i32 := F;
  Take(F);
})");

  ExpectError(3, 5, "condition expression must have type 'bool', not a function name", 1);
  ExpectError(4, 2, "unary operator '!' cannot be applied to a function address without a target type", 5);
  ExpectError(5, 18, "cannot infer an object type from a function name", 1);
  ExpectError(6, 20, "cannot initialize variable 'number': no implicit conversion from a function name to 'i32'", 1);
  ExpectError(7, 2, "no matching function for call to 'Take'", 7);
  ExpectNote(1, 0,
             "candidate function is not viable: a function name does not produce a value that can bind to "
             "reference type 'copy i32' for argument 1",
             0);
}

TEST_F(SemaTest, RejectsBareFunctionValueTransfers) {
  Analyze(R"(func Carry(value func () void) func () void { value }
func Store(value func () void) {
  var other func () void := value;
  other;
  missing;
})");

  ExpectError(0, 17, "parameter type 'func () void' is not an object type", 12);
  ExpectError(0, 31, "return type 'func () void' is not an object type", 12);
  ExpectError(1, 17, "parameter type 'func () void' is not an object type", 12);
  ExpectError(2, 12, "variable type 'func () void' is not an object type", 12);
  ExpectError(4, 2, "use of undeclared identifier 'missing'", 7);
}

TEST_F(SemaTest, PreservesBareFunctionTypeUseErrorsInAst) {
  Analyze(R"(func F() {
var callback func () void;
callback;
})");

  ExpectError(1, 13, "variable type 'func () void' is not an object type", 12);
  ExpectError(2, 0, "use of uninitialized variable 'callback'", 8);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, line:4:2> F 'func () void' contains-errors
  `-CompoundStmt {{address}} <line:1:10, line:4:2> contains-errors
    |-DeclStmt {{address}} <line:2:1, col:27> contains-errors
    | `-VarGroupDecl {{address}} <col:1, col:27> contains-errors
    |   `-VarDecl {{address:callback}} <col:5, col:26> callback 'func () void' contains-errors
    |     `-FunctionType {{address}} <col:14, col:26> contains-errors
    |       `-BuiltinType {{address}} <col:22, col:26> 'void'
    `-ExprStmt {{address}} <line:3:1, col:10> contains-errors
      `-DeclRefExpr {{address}} <col:1, col:9> Var {{address:callback}} 'callback' 'func () void' contains-errors)");
}

TEST_F(SemaTest, RejectsBareFunctionVariablesBeforeConvertingTheirInitializers) {
  Analyze(R"(var global func () void := null;
func Use() {
global;
var local func () void := null;
local;
})");

  ExpectError(0, 11, "variable type 'func () void' is not an object type", 12);
  ExpectError(3, 10, "variable type 'func () void' is not an object type", 12);
}

TEST_F(SemaTest, DiagnosesIndependentBareFunctionUsesInsideNestedSignatures) {
  Analyze(R"(func F(callback *func (func () void, func (i32) void) func () void) { callback(); }
func G(callback *func (*func (func () void) void, i32) void) { callback(); })");

  ExpectError(0, 23, "parameter type 'func () void' is not an object type", 12);
  ExpectError(0, 37, "parameter type 'func (i32) void' is not an object type", 15);
  ExpectError(0, 54, "return type 'func () void' is not an object type", 12);
  ExpectError(1, 30, "parameter type 'func () void' is not an object type", 12);
}

TEST_F(SemaTest, RetainsAddressedSourceWhenSelectedFunctionPointerCannotBindToMut) {
  Analyze(R"(func F() {}
func Use() { var callback mut *func () void := &F; })");
  ExpectError(
      1, 47,
      "cannot initialize variable 'callback': reference type 'mut *func () void' cannot bind to pure rvalue of type '*func () void'",
      2);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-FunctionDecl {{address:f}} <test.cw:1:1, col:12> F 'func () void'
| `-CompoundStmt {{address}} <col:10, col:12>
`-FunctionDecl {{address:use}} <line:2:1, col:53> Use 'func () void' contains-errors
  `-CompoundStmt {{address}} <col:12, col:53> contains-errors
    `-DeclStmt {{address}} <col:14, col:51> contains-errors
      `-VarGroupDecl {{address}} <col:14, col:51> contains-errors
        |-VarDecl {{address}} <col:18, col:44> callback 'mut *func () void'
        | `-ReferenceType {{address}} <col:27, col:44> 'mut'
        |   `-PointerType {{address}} <col:31, col:44>
        |     `-FunctionType {{address}} <col:32, col:44>
        |       `-BuiltinType {{address}} <col:40, col:44> 'void'
        `-UnaryOperator {{address}} <col:48, col:50> '<address-of-function-overload-set>' '&' contains-errors
          `-DeclRefExpr {{address}} <col:49, col:50> '<function-overload-set>' 'F')");
}

TEST_F(SemaTest, FormsFunctionAddressReferenceEndpoints) {
  Analyze(R"(func F() {}
func TakeMove(value move *func () void) {}
func TakeCopy(value copy *func () void) {}
func Use() {
  TakeMove(&F);
  TakeCopy(&F);
})");
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-FunctionDecl {{address:f}} <test.cw:1:1, col:12> F 'func () void'
| `-CompoundStmt {{address}} <col:10, col:12>
|-FunctionDecl {{address:take_move}} <line:2:1, col:43> TakeMove 'func (move *func () void) void'
| |-ParmVarDecl {{address:take_move_value}} <col:15, col:39> value 'move *func () void'
| | `-ReferenceType {{address}} <col:21, col:39> 'move'
| |   `-PointerType {{address}} <col:26, col:39>
| |     `-FunctionType {{address}} <col:27, col:39>
| |       `-BuiltinType {{address}} <col:35, col:39> 'void'
| `-CompoundStmt {{address}} <col:41, col:43>
|-FunctionDecl {{address:take_copy}} <line:3:1, col:43> TakeCopy 'func (copy *func () void) void'
| |-ParmVarDecl {{address:take_copy_value}} <col:15, col:39> value 'copy *func () void'
| | `-ReferenceType {{address}} <col:21, col:39> 'copy'
| |   `-PointerType {{address}} <col:26, col:39>
| |     `-FunctionType {{address}} <col:27, col:39>
| |       `-BuiltinType {{address}} <col:35, col:39> 'void'
| `-CompoundStmt {{address}} <col:41, col:43>
`-FunctionDecl {{address:use}} <line:4:1, line:7:2> Use 'func () void'
  `-CompoundStmt {{address}} <line:4:12, line:7:2>
    |-ExprStmt {{address}} <line:5:3, col:16>
    | `-CallExpr {{address}} <col:3, col:15> 'void'
    |   |-DeclRefExpr {{address}} <col:3, col:11> 'func (move *func () void) void' Function {{address:take_move}} 'TakeMove' 'func (move *func () void) void'
    |   `-MaterializeTemporaryExpr {{address}} <col:12, col:14> '*func () void' move-lvalue
    |     `-ImplicitOverloadSetSelectionExpr {{address}} <col:12, col:14> '*func () void' pure-rvalue Function {{address:f}} 'F' 'func () void'
    |       `-UnaryOperator {{address}} <col:12, col:14> '<address-of-function-overload-set>' '&'
    |         `-DeclRefExpr {{address}} <col:13, col:14> '<function-overload-set>' 'F'
    `-ExprStmt {{address}} <line:6:3, col:16>
      `-CallExpr {{address}} <col:3, col:15> 'void'
        |-DeclRefExpr {{address}} <col:3, col:11> 'func (copy *func () void) void' Function {{address:take_copy}} 'TakeCopy' 'func (copy *func () void) void'
        `-ImplicitCastExpr {{address}} <col:12, col:14> 'const *func () void' move-lvalue <NoOp>
          `-MaterializeTemporaryExpr {{address}} <col:12, col:14> '*func () void' move-lvalue
            `-ImplicitOverloadSetSelectionExpr {{address}} <col:12, col:14> '*func () void' pure-rvalue Function {{address:f}} 'F' 'func () void'
              `-UnaryOperator {{address}} <col:12, col:14> '<address-of-function-overload-set>' '&'
                `-DeclRefExpr {{address}} <col:13, col:14> '<function-overload-set>' 'F')");
}

// Overload selection and candidate diagnostics.

TEST_F(SemaTest, TreatsSameTypeValueAndReferenceSequencesAsIndistinguishable) {
  Analyze(R"(struct Value { number i32; }
ctor Value(number i32) { this.number := number; }
ctor Value(other copy Value) { this.number := other.number; }
dtor Value() {}
func Select(value Value) {}
func Select(value copy Value) {}
func Choose(value Value, rank i16) {}
func Choose(value copy Value, rank i32) {}
func Rank(source mut Value, rank i16) {
  Select(source);
  Choose(source, rank);
})");

  ExpectError(9, 2, "call to 'Select' is ambiguous", 14);
  ExpectNote(4, 0, "candidate function", 0);
  ExpectNote(5, 0, "candidate function", 0);
}

TEST_F(SemaTest, DoesNotUseObjectFormationAvailabilityToBreakValueReferenceAmbiguity) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func Select(value Value) {}
func Select(value copy Value) {}
func Use(value mut Value) { Select(value); })");

  ExpectError(5, 28, "call to 'Select' is ambiguous", 13);
  ExpectNote(3, 0, "candidate function", 0);
  ExpectNote(4, 0, "candidate function", 0);
}

TEST_F(SemaTest, RanksValuePreservationWithoutUsingWarningRiskOrSourceOrder) {
  Analyze(R"(func range(value u16) u16 { value }
func range(value i16) i16 { value }
func width(value f32) f32 { value }
func width(value i64) i64 { value }
func caller(small i8, regular i32) { range(small); width(regular); })");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-FunctionDecl {{address}} <test.cw:1:1, col:36> range 'func (u16) u16'
| |-ParmVarDecl {{address:unsigned_range_value}} <col:12, col:21> value 'u16'
| | `-BuiltinType {{address}} <col:18, col:21> 'u16'
| |-ReturnVarDecl {{address:unsigned_range_result}} <col:23, col:26> 'u16'
| | `-BuiltinType {{address}} <col:23, col:26> 'u16'
| `-CompoundStmt {{address}} <col:27, col:36>
|   `-ImplicitResultInitializationExpr {{address}} <col:29, col:34> 'void' ReturnVar {{address:unsigned_range_result}} 'u16'
|     `-ImplicitCastExpr {{address}} <col:29, col:34> 'u16' pure-rvalue <LValueToRValue>
|       `-DeclRefExpr {{address}} <col:29, col:34> 'u16' lvalue ParmVar {{address:unsigned_range_value}} 'value' 'u16'
|-FunctionDecl {{address:signed_range}} <line:2:1, col:36> range 'func (i16) i16'
| |-ParmVarDecl {{address:signed_range_value}} <col:12, col:21> value 'i16'
| | `-BuiltinType {{address}} <col:18, col:21> 'i16'
| |-ReturnVarDecl {{address:signed_range_result}} <col:23, col:26> 'i16'
| | `-BuiltinType {{address}} <col:23, col:26> 'i16'
| `-CompoundStmt {{address}} <col:27, col:36>
|   `-ImplicitResultInitializationExpr {{address}} <col:29, col:34> 'void' ReturnVar {{address:signed_range_result}} 'i16'
|     `-ImplicitCastExpr {{address}} <col:29, col:34> 'i16' pure-rvalue <LValueToRValue>
|       `-DeclRefExpr {{address}} <col:29, col:34> 'i16' lvalue ParmVar {{address:signed_range_value}} 'value' 'i16'
|-FunctionDecl {{address}} <line:3:1, col:36> width 'func (f32) f32'
| |-ParmVarDecl {{address:floating_width_value}} <col:12, col:21> value 'f32'
| | `-BuiltinType {{address}} <col:18, col:21> 'f32'
| |-ReturnVarDecl {{address:floating_width_result}} <col:23, col:26> 'f32'
| | `-BuiltinType {{address}} <col:23, col:26> 'f32'
| `-CompoundStmt {{address}} <col:27, col:36>
|   `-ImplicitResultInitializationExpr {{address}} <col:29, col:34> 'void' ReturnVar {{address:floating_width_result}} 'f32'
|     `-ImplicitCastExpr {{address}} <col:29, col:34> 'f32' pure-rvalue <LValueToRValue>
|       `-DeclRefExpr {{address}} <col:29, col:34> 'f32' lvalue ParmVar {{address:floating_width_value}} 'value' 'f32'
|-FunctionDecl {{address:integer_width}} <line:4:1, col:36> width 'func (i64) i64'
| |-ParmVarDecl {{address:integer_width_value}} <col:12, col:21> value 'i64'
| | `-BuiltinType {{address}} <col:18, col:21> 'i64'
| |-ReturnVarDecl {{address:integer_width_result}} <col:23, col:26> 'i64'
| | `-BuiltinType {{address}} <col:23, col:26> 'i64'
| `-CompoundStmt {{address}} <col:27, col:36>
|   `-ImplicitResultInitializationExpr {{address}} <col:29, col:34> 'void' ReturnVar {{address:integer_width_result}} 'i64'
|     `-ImplicitCastExpr {{address}} <col:29, col:34> 'i64' pure-rvalue <LValueToRValue>
|       `-DeclRefExpr {{address}} <col:29, col:34> 'i64' lvalue ParmVar {{address:integer_width_value}} 'value' 'i64'
`-FunctionDecl {{address}} <line:5:1, col:69> caller 'func (i8, i32) void'
  |-ParmVarDecl {{address:small}} <col:13, col:21> small 'i8'
  | `-BuiltinType {{address}} <col:19, col:21> 'i8'
  |-ParmVarDecl {{address:regular}} <col:23, col:34> regular 'i32'
  | `-BuiltinType {{address}} <col:31, col:34> 'i32'
  `-CompoundStmt {{address}} <col:36, col:69>
    |-ExprStmt {{address}} <col:38, col:51>
    | `-CallExpr {{address}} <col:38, col:50> 'i16' pure-rvalue
    |   |-DeclRefExpr {{address}} <col:38, col:43> 'func (i16) i16' Function {{address:signed_range}} 'range' 'func (i16) i16'
    |   `-ImplicitCastExpr {{address}} <col:44, col:49> 'i16' pure-rvalue <IntegerToInteger>
    |     `-ImplicitCastExpr {{address}} <col:44, col:49> 'i8' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:44, col:49> 'i8' lvalue ParmVar {{address:small}} 'small' 'i8'
    `-ExprStmt {{address}} <col:52, col:67>
      `-CallExpr {{address}} <col:52, col:66> 'i64' pure-rvalue
        |-DeclRefExpr {{address}} <col:52, col:57> 'func (i64) i64' Function {{address:integer_width}} 'width' 'func (i64) i64'
        `-ImplicitCastExpr {{address}} <col:58, col:65> 'i64' pure-rvalue <IntegerToInteger>
          `-ImplicitCastExpr {{address}} <col:58, col:65> 'i32' pure-rvalue <LValueToRValue>
            `-DeclRefExpr {{address}} <col:58, col:65> 'i32' lvalue ParmVar {{address:regular}} 'regular' 'i32')");
}

TEST_F(SemaTest, UsesFixedLiteralTypeForOverloadResolution) {
  Analyze(R"(func select(value i32) i32 { value }
func select(value i64) i64 { value }
func caller() { select(1); })");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-FunctionDecl {{address:selected}} <test.cw:1:1, col:37> select 'func (i32) i32'
| |-ParmVarDecl {{address:selected_value}} <col:13, col:22> value 'i32'
| | `-BuiltinType {{address}} <col:19, col:22> 'i32'
| |-ReturnVarDecl {{address:selected_result}} <col:24, col:27> 'i32'
| | `-BuiltinType {{address}} <col:24, col:27> 'i32'
| `-CompoundStmt {{address}} <col:28, col:37>
|   `-ImplicitResultInitializationExpr {{address}} <col:30, col:35> 'void' ReturnVar {{address:selected_result}} 'i32'
|     `-ImplicitCastExpr {{address}} <col:30, col:35> 'i32' pure-rvalue <LValueToRValue>
|       `-DeclRefExpr {{address}} <col:30, col:35> 'i32' lvalue ParmVar {{address:selected_value}} 'value' 'i32'
|-FunctionDecl {{address}} <line:2:1, col:37> select 'func (i64) i64'
| |-ParmVarDecl {{address:wide_value}} <col:13, col:22> value 'i64'
| | `-BuiltinType {{address}} <col:19, col:22> 'i64'
| |-ReturnVarDecl {{address:wide_result}} <col:24, col:27> 'i64'
| | `-BuiltinType {{address}} <col:24, col:27> 'i64'
| `-CompoundStmt {{address}} <col:28, col:37>
|   `-ImplicitResultInitializationExpr {{address}} <col:30, col:35> 'void' ReturnVar {{address:wide_result}} 'i64'
|     `-ImplicitCastExpr {{address}} <col:30, col:35> 'i64' pure-rvalue <LValueToRValue>
|       `-DeclRefExpr {{address}} <col:30, col:35> 'i64' lvalue ParmVar {{address:wide_value}} 'value' 'i64'
`-FunctionDecl {{address}} <line:3:1, col:29> caller 'func () void'
  `-CompoundStmt {{address}} <col:15, col:29>
    `-ExprStmt {{address}} <col:17, col:27>
      `-CallExpr {{address}} <col:17, col:26> 'i32' pure-rvalue
        |-DeclRefExpr {{address}} <col:17, col:23> 'func (i32) i32' Function {{address:selected}} 'select' 'func (i32) i32'
        `-ImplicitCastExpr {{address}} <col:24, col:25> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
          `-IntegerLiteral {{address}} <col:24, col:25> 'comptime_int' 1)");
}

TEST_F(SemaTest, ReportsCrossParameterAmbiguityWithoutUsingResultContext) {
  Analyze(R"(func choose(a i32, b i64) i64 { b }
func choose(a i64, b i32) i32 { b }
func choose(a i64, b i64) i64 { b }
func caller(a i32, b i32) { var result i32 := choose(a, b); })");

  ExpectError(3, 46, "call to 'choose' is ambiguous", 12);
  ExpectNote(0, 0, "candidate function", 0);
  ExpectNote(1, 0, "candidate function", 0);
  ExpectNote(2, 0, "candidate function", 0);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-FunctionDecl {{address}} <test.cw:1:1, col:36> choose 'func (i32, i64) i64'
| |-ParmVarDecl {{address}} <col:13, col:18> a 'i32'
| | `-BuiltinType {{address}} <col:15, col:18> 'i32'
| |-ParmVarDecl {{address:first_b}} <col:20, col:25> b 'i64'
| | `-BuiltinType {{address}} <col:22, col:25> 'i64'
| |-ReturnVarDecl {{address:first_result}} <col:27, col:30> 'i64'
| | `-BuiltinType {{address}} <col:27, col:30> 'i64'
| `-CompoundStmt {{address}} <col:31, col:36>
|   `-ImplicitResultInitializationExpr {{address}} <col:33, col:34> 'void' ReturnVar {{address:first_result}} 'i64'
|     `-ImplicitCastExpr {{address}} <col:33, col:34> 'i64' pure-rvalue <LValueToRValue>
|       `-DeclRefExpr {{address}} <col:33, col:34> 'i64' lvalue ParmVar {{address:first_b}} 'b' 'i64'
|-FunctionDecl {{address}} <line:2:1, col:36> choose 'func (i64, i32) i32'
| |-ParmVarDecl {{address}} <col:13, col:18> a 'i64'
| | `-BuiltinType {{address}} <col:15, col:18> 'i64'
| |-ParmVarDecl {{address:second_b}} <col:20, col:25> b 'i32'
| | `-BuiltinType {{address}} <col:22, col:25> 'i32'
| |-ReturnVarDecl {{address:second_result}} <col:27, col:30> 'i32'
| | `-BuiltinType {{address}} <col:27, col:30> 'i32'
| `-CompoundStmt {{address}} <col:31, col:36>
|   `-ImplicitResultInitializationExpr {{address}} <col:33, col:34> 'void' ReturnVar {{address:second_result}} 'i32'
|     `-ImplicitCastExpr {{address}} <col:33, col:34> 'i32' pure-rvalue <LValueToRValue>
|       `-DeclRefExpr {{address}} <col:33, col:34> 'i32' lvalue ParmVar {{address:second_b}} 'b' 'i32'
|-FunctionDecl {{address}} <line:3:1, col:36> choose 'func (i64, i64) i64'
| |-ParmVarDecl {{address}} <col:13, col:18> a 'i64'
| | `-BuiltinType {{address}} <col:15, col:18> 'i64'
| |-ParmVarDecl {{address:third_b}} <col:20, col:25> b 'i64'
| | `-BuiltinType {{address}} <col:22, col:25> 'i64'
| |-ReturnVarDecl {{address:third_result}} <col:27, col:30> 'i64'
| | `-BuiltinType {{address}} <col:27, col:30> 'i64'
| `-CompoundStmt {{address}} <col:31, col:36>
|   `-ImplicitResultInitializationExpr {{address}} <col:33, col:34> 'void' ReturnVar {{address:third_result}} 'i64'
|     `-ImplicitCastExpr {{address}} <col:33, col:34> 'i64' pure-rvalue <LValueToRValue>
|       `-DeclRefExpr {{address}} <col:33, col:34> 'i64' lvalue ParmVar {{address:third_b}} 'b' 'i64'
`-FunctionDecl {{address}} <line:4:1, col:62> caller 'func (i32, i32) void' contains-errors
  |-ParmVarDecl {{address:a}} <col:13, col:18> a 'i32'
  | `-BuiltinType {{address}} <col:15, col:18> 'i32'
  |-ParmVarDecl {{address:b}} <col:20, col:25> b 'i32'
  | `-BuiltinType {{address}} <col:22, col:25> 'i32'
  `-CompoundStmt {{address}} <col:27, col:62> contains-errors
    `-DeclStmt {{address}} <col:29, col:60> contains-errors
      `-VarGroupDecl {{address}} <col:29, col:60> contains-errors
        |-VarDecl {{address}} <col:33, col:43> result 'i32'
        | `-BuiltinType {{address}} <col:40, col:43> 'i32'
        `-CallExpr {{address}} <col:47, col:59> contains-errors
          |-DeclRefExpr {{address}} <col:47, col:53> '<function-overload-set>' 'choose' contains-errors
          |-DeclRefExpr {{address}} <col:54, col:55> 'i32' lvalue ParmVar {{address:a}} 'a' 'i32'
          `-DeclRefExpr {{address}} <col:57, col:58> 'i32' lvalue ParmVar {{address:b}} 'b' 'i32')");
}

TEST_F(SemaTest, ReportsAmbiguityForEqualValuePreservingRanks) {
  Analyze(R"(func same(value i32) {}
func same(value i64) {}
func caller(value i16) { same(value); })");

  ExpectError(2, 25, "call to 'same' is ambiguous", 11);
  ExpectNote(0, 0, "candidate function", 0);
  ExpectNote(1, 0, "candidate function", 0);
}

TEST_F(SemaTest, ReportsAllViableCandidatesForNonTransitiveComparisons) {
  Analyze(R"(func Pick(a mut i32, b i32) {}
func Pick(a copy i32, b mut i32) {}
func Pick(a i32, b copy i32) {}
func Reverse(a i32, b copy i32) {}
func Reverse(a copy i32, b mut i32) {}
func Reverse(a mut i32, b i32) {}
func Use(a i32, b i32) {
  Pick(a, b);
  Reverse(a, b);
})");

  ExpectError(7, 2, "call to 'Pick' is ambiguous", 10);
  ExpectNote(0, 0, "candidate function", 0);
  ExpectNote(1, 0, "candidate function", 0);
  ExpectNote(2, 0, "candidate function", 0);
  ExpectError(8, 2, "call to 'Reverse' is ambiguous", 13);
  ExpectNote(3, 0, "candidate function", 0);
  ExpectNote(4, 0, "candidate function", 0);
  ExpectNote(5, 0, "candidate function", 0);
}

TEST_F(SemaTest, ReportsAllViableCandidatesForCyclicComparisons) {
  Analyze(R"(func Pick(a mut i32, b copy i32, c i32) {}
func Pick(a copy i32, b i32, c mut i32) {}
func Pick(a i32, b mut i32, c copy i32) {}
func Use(value i32) {
  Pick(value, value, value);
})");

  ExpectError(4, 2, "call to 'Pick' is ambiguous", 25);
  ExpectNote(0, 0, "candidate function", 0);
  ExpectNote(1, 0, "candidate function", 0);
  ExpectNote(2, 0, "candidate function", 0);
}

TEST_F(SemaTest, SelectsFunctionsIndependentlyOfCandidateOrderAndArityFailures) {
  Analyze(R"(func First(value i32) i32 { value }
func First(value i64) bool { true }
func Last(value i64) bool { true }
func Last(value i32) i32 { value }
func Empty(value i32) {}
func Empty() {}
func Use(value i32) {
  var first i32 := First(value);
  var last i32 := Last(value);
  Empty();
})");
}

TEST_F(SemaTest, ExplainsArityAndConversionFailures) {
  Analyze(R"(func arity(value i32) {}
func typed(value i32) {}
func caller() { arity(); typed(true); })");

  ExpectError(2, 16, "no matching function for call to 'arity'", 7);
  ExpectNote(0, 0, "candidate function requires 1 argument, but 0 were provided", 0);
  ExpectError(2, 25, "no matching function for call to 'typed'", 11);
  ExpectNote(1, 0, "candidate function is not viable: no implicit conversion from 'bool' to 'i32' for argument 1", 0);
}

TEST_F(SemaTest, AppliesSelectedCallWarningsInArgumentOrder) {
  Analyze(R"(func narrow(first u8, second u8) {}
func caller(first i32, second i16) { narrow(first, second); })");

  ExpectWarning(1, 44, "implicit integer conversion from 'i32' to 'u8' may truncate value", 5);
  ExpectWarning(1, 51, "implicit integer conversion from 'i16' to 'u8' may truncate value", 6);
}

TEST_F(SemaTest, KeepsExactValueAndReferenceConversionsIndistinguishableAndExplainsBindingFailures) {
  Analyze(R"(func choice(value i32) {}
func choice(value mut i32) {}
func only_mut(value mut i32) {}
func only_move(value move i32) {}
func converted(value copy u8) {}
func caller(value i32) {
  choice(value);
  only_mut(move value);
  only_move(value);
  converted(value);
})");

  ExpectError(6, 2, "call to 'choice' is ambiguous", 13);
  ExpectNote(0, 0, "candidate function", 0);
  ExpectNote(1, 0, "candidate function", 0);
  ExpectError(7, 2, "no matching function for call to 'only_mut'", 20);
  ExpectNote(2, 0,
             "candidate function is not viable: reference type 'mut i32' cannot bind to move lvalue of type 'i32' "
             "for argument 1",
             0);
  ExpectError(8, 2, "no matching function for call to 'only_move'", 16);
  ExpectNote(3, 0,
             "candidate function is not viable: reference type 'move i32' cannot bind to lvalue of type 'i32' for "
             "argument 1",
             0);
  ExpectError(9, 2, "no matching function for call to 'converted'", 16);
  ExpectNote(4, 0,
             "candidate function is not viable: reference type 'copy u8' cannot bind to a value of type 'i32' for "
             "argument 1",
             0);
}

TEST_F(SemaTest, ReportsCrossArgumentAmbiguityForDerivedToBaseReferenceBindings) {
  Analyze(R"(trivial struct Root {}
trivial struct Middle : Root {}
trivial struct Derived : Middle {}
func Choose(left copy Middle, right copy Root) {}
func Choose(left copy Root, right copy Middle) {}
func Check(left mut Derived, right mut Derived) {
  Choose(left, right);
})");

  ExpectError(6, 2, "call to 'Choose' is ambiguous", 19);
  ExpectNote(3, 0, "candidate function", 0);
  ExpectNote(4, 0, "candidate function", 0);
}

TEST_F(SemaTest, RecoversCallsAcrossIncompleteCandidatesBodiesAndArguments) {
  Analyze(R"(func broken(value i32) Missing {}
func usable(value i32) { missing_body; }
func caller(value i32) {
broken(value);
usable(value);
target(missing_arg);
target(value);
}
func target(value i32) {})");

  ExpectError(0, 23, "unknown type 'Missing'", 7);
  ExpectError(1, 25, "use of undeclared identifier 'missing_body'", 12);
  ExpectError(5, 7, "use of undeclared identifier 'missing_arg'", 11);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-FunctionDecl {{address}} <test.cw:1:1, col:34> broken contains-errors
| |-ParmVarDecl {{address}} <col:13, col:22> value 'i32'
| | `-BuiltinType {{address}} <col:19, col:22> 'i32'
| |-ReturnVarDecl {{address}} <col:24, col:31> contains-errors
| | `-NamedType {{address}} <col:24, col:31> 'Missing' contains-errors
| `-CompoundStmt {{address}} <col:32, col:34>
|-FunctionDecl {{address:usable}} <line:2:1, col:41> usable 'func (i32) void' contains-errors
| |-ParmVarDecl {{address}} <col:13, col:22> value 'i32'
| | `-BuiltinType {{address}} <col:19, col:22> 'i32'
| `-CompoundStmt {{address}} <col:24, col:41> contains-errors
|   `-ExprStmt {{address}} <col:26, col:39> contains-errors
|     `-DeclRefExpr {{address}} <col:26, col:38> 'missing_body' contains-errors
|-FunctionDecl {{address}} <line:3:1, line:8:2> caller 'func (i32) void' contains-errors
| |-ParmVarDecl {{address:value}} <line:3:13, col:22> value 'i32'
| | `-BuiltinType {{address}} <col:19, col:22> 'i32'
| `-CompoundStmt {{address}} <col:24, line:8:2> contains-errors
|   |-ExprStmt {{address}} <line:4:1, col:15> contains-errors
|   | `-CallExpr {{address}} <col:1, col:14> contains-errors
|   |   |-DeclRefExpr {{address}} <col:1, col:7> '<function-overload-set>' 'broken' contains-errors
|   |   `-DeclRefExpr {{address}} <col:8, col:13> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
|   |-ExprStmt {{address}} <line:5:1, col:15>
|   | `-CallExpr {{address}} <col:1, col:14> 'void'
|   |   |-DeclRefExpr {{address}} <col:1, col:7> 'func (i32) void' Function {{address:usable}} 'usable' 'func (i32) void'
|   |   `-ImplicitCastExpr {{address}} <col:8, col:13> 'i32' pure-rvalue <LValueToRValue>
|   |     `-DeclRefExpr {{address}} <col:8, col:13> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
|   |-ExprStmt {{address}} <line:6:1, col:21> contains-errors
|   | `-CallExpr {{address}} <col:1, col:20> contains-errors
|   |   |-DeclRefExpr {{address}} <col:1, col:7> '<function-overload-set>' 'target'
|   |   `-DeclRefExpr {{address}} <col:8, col:19> 'missing_arg' contains-errors
|   `-ExprStmt {{address}} <line:7:1, col:15>
|     `-CallExpr {{address}} <col:1, col:14> 'void'
|       |-DeclRefExpr {{address}} <col:1, col:7> 'func (i32) void' Function {{address:target}} 'target' 'func (i32) void'
|       `-ImplicitCastExpr {{address}} <col:8, col:13> 'i32' pure-rvalue <LValueToRValue>
|         `-DeclRefExpr {{address}} <col:8, col:13> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
`-FunctionDecl {{address:target}} <line:9:1, col:26> target 'func (i32) void'
  |-ParmVarDecl {{address}} <col:13, col:22> value 'i32'
  | `-BuiltinType {{address}} <col:19, col:22> 'i32'
  `-CompoundStmt {{address}} <col:24, col:26>)");
}

TEST_F(SemaTest, PrefersExactReferencesOverNumericAndPointerQualificationConversions) {
  Analyze(R"(func Number(value copy i32) i32 { 1 }
func Number(value i64) bool { true }
func Pointer(value copy *i32) i32 { 1 }
func Pointer(value *const i32) bool { true }
func Use(number i32, pointer *i32) i32 {
  var first i32 := Number(number);
  var second i32 := Pointer(pointer);
  first + second
})");
}

TEST_F(SemaTest, LetsOtherArgumentsDecideBetweenDifferentSelectedFunctionAddressTypes) {
  Analyze(R"(func F(value i32) {}
func F(value bool) {}
func ValueChoice(fn *func (i32) void, rank i64) bool { true }
func ValueChoice(fn *func (bool) void, rank i32) i32 { 1 }
func ReferenceChoice(fn move *func (i32) void, rank i64) bool { true }
func ReferenceChoice(fn copy *func (bool) void, rank i32) i32 { 1 }
func Use(rank i32) i32 {
  var first i32 := ValueChoice(&F, rank);
  var second i32 := ReferenceChoice(&F, rank);
  first + second
})");
}

/// \brief Exercises the nontransitive indistinguishability relation in every declaration order.
class ConversionOrderTest : public SemaTest, public ::testing::WithParamInterface<std::string> {};

TEST_P(ConversionOrderTest, KeepsValueMutCopyAmbiguityIndependentOfDeclarationOrder) {
  const std::string declarations[] = {"func Select(value i32) {}\n", "func Select(value mut i32) {}\n",
                                      "func Select(value copy i32) {}\n"};
  std::string source;
  for (char index : GetParam()) source += declarations[index - '0'];
  source += "func Use(value i32) { Select(value); }";
  Analyze(source);
  ExpectError(3, 22, "call to 'Select' is ambiguous", 13);
  ExpectNote(0, 0, "candidate function", 0);
  ExpectNote(1, 0, "candidate function", 0);
  ExpectNote(2, 0, "candidate function", 0);
}

INSTANTIATE_TEST_SUITE_P(DeclarationOrders, ConversionOrderTest,
                         ::testing::Values("012", "021", "102", "120", "201", "210"));

TEST_F(SemaTest, PrefersNearerValueAndReferenceBaseTargetsBeforeBindingModes) {
  Analyze(R"(trivial struct Base {}
trivial struct Middle : Base {}
trivial struct Derived : Middle {}
func First(value Base) bool { true }
func First(value copy Middle) i32 { 1 }
func Second(value Middle) i32 { 1 }
func Second(value mut Base) bool { true }
func Exact(value Derived) i32 { 1 }
func Exact(value copy Base) bool { true }
func Use(source mut Derived) i32 {
  var first i32 := First(source);
  var second i32 := Second(source);
  var exact i32 := Exact(source);
  first + second + exact
})");
}

// Value formation, reference binding, and base projections.

TEST_F(SemaTest, PassesNonTrivialPureRValuesDirectlyToValueParameters) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func Make() Value { return Value(); }
func Take(value Value) {}
func Use(condition bool) {
  Take(Value());
  Take(condition ? Value() : Make());
})");
}

TEST_F(SemaTest, FormsNonTrivialValuesWithCopyAndMoveConstructors) {
  Analyze(R"(struct Value { number i32; }
ctor Value(number i32) { this.number := number; }
ctor Value(other copy Value) { this.number := other.number; }
ctor Value(other move Value) { this.number := other.number; }
dtor Value() {}
func Make() Value { Value(1) }
func Take(value Value) {}
func Use(left mut Value, right copy Value, condition bool) Value {
  var copied Value := left;
  var inferred := left;
  var readonly_copy Value := right;
  var moved Value := move left;
  var explicit_copy Value := Value(left);
  var direct Value := Make();
  Take(right);
  Take(move left);
  return condition ? right : move moved;
}
struct CopyOnly { number i32; }
ctor CopyOnly(number i32) { this.number := number; }
ctor CopyOnly(other copy CopyOnly) { this.number := other.number; }
dtor CopyOnly() {}
func CopyFallback(source mut CopyOnly) {
  var result CopyOnly := move source;
})");
}

TEST_F(SemaTest, FormsCopyConstructionAcrossConstructorIndirectAndOperatorCalls) {
  Analyze(R"(struct Value { number i32; }
ctor Value(number i32) { this.number := number; }
ctor Value(other copy Value) { this.number := other.number; }
ctor Value(other Value, tag bool) { this.number := other.number; }
dtor Value() {}
func operator+(left Value, right copy Value) {}
func Use(source mut Value, callback *func (Value) void) {
  Value(source, true);
  callback(source);
  source + source;
})");
}

TEST_F(SemaTest, DiagnosesMissingCopyAndMoveConstruction) {
  Analyze(R"(struct Missing { number i32; }
ctor Missing(number i32) { this.number := number; }
dtor Missing() {}
func Reject(source mut Missing) {
  var copied Missing := source;
  var moved Missing := move source;
})");

  ExpectError(4, 24, "cannot initialize variable 'copied': no copy constructor is available for 'Missing'", 6);
  ExpectError(5, 23, "cannot initialize variable 'moved': no move or copy constructor is available for 'Missing'", 11);
}

TEST_F(SemaTest, PreservesSelectedCallAndArgumentsWhenParameterFormationFails) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func Consume(number u8, object Value) {}
func Use(number i32, object mut Value) { Consume(number, object); })");

  ExpectError(4, 57,
              "cannot initialize parameter 2 of function 'Consume': no copy constructor is available for 'Value'", 6);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-StructDecl {{address:structure}} <test.cw:1:1, col:16> Value
|-ConstructorDecl {{address:constructor}} <line:2:1, col:16> Value target Struct {{address:structure}} 'Value' 'func () void'
| `-CompoundStmt {{address}} <col:14, col:16>
|-DestructorDecl {{address}} <line:3:1, col:16> Value target Struct {{address:structure}} 'Value' 'func () void'
| `-CompoundStmt {{address}} <col:14, col:16>
|-FunctionDecl {{address:consume}} <line:4:1, col:41> Consume 'func (u8, Value) void'
| |-ParmVarDecl {{address}} <col:14, col:23> number 'u8'
| | `-BuiltinType {{address}} <col:21, col:23> 'u8'
| |-ParmVarDecl {{address}} <col:25, col:37> object 'Value'
| | `-NamedType {{address}} <col:32, col:37> 'Value'
| `-CompoundStmt {{address}} <col:39, col:41>
`-FunctionDecl {{address}} <line:5:1, col:68> Use 'func (i32, mut Value) void' contains-errors
  |-ParmVarDecl {{address:number}} <col:10, col:20> number 'i32'
  | `-BuiltinType {{address}} <col:17, col:20> 'i32'
  |-ParmVarDecl {{address:object}} <col:22, col:38> object 'mut Value'
  | `-ReferenceType {{address}} <col:29, col:38> 'mut'
  |   `-NamedType {{address}} <col:33, col:38> 'Value'
  `-CompoundStmt {{address}} <col:40, col:68> contains-errors
    `-ExprStmt {{address}} <col:42, col:66> contains-errors
      `-CallExpr {{address}} <col:42, col:65> contains-errors
        |-DeclRefExpr {{address}} <col:42, col:49> 'func (u8, Value) void' Function {{address:consume}} 'Consume' 'func (u8, Value) void'
        |-DeclRefExpr {{address}} <col:50, col:56> 'i32' lvalue ParmVar {{address:number}} 'number' 'i32'
        `-DeclRefExpr {{address}} <col:58, col:64> 'Value' lvalue ParmVar {{address:object}} 'object' 'mut Value')");
}

TEST_F(SemaTest, KeepsDirectlyPassedNonTrivialPureRValueUnwrappedInSemanticAst) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func Make() Value { return Value(); }
func Take(value Value) {}
func Use() { Take(Make()); })");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address:structure}} <test.cw:1:1, col:16> Value
|-ConstructorDecl {{address:constructor}} <line:2:1, col:16> Value target Struct {{address:structure}} 'Value' 'func () void'
| `-CompoundStmt {{address}} <col:14, col:16>
|-DestructorDecl {{address}} <line:3:1, col:16> Value target Struct {{address:structure}} 'Value' 'func () void'
| `-CompoundStmt {{address}} <col:14, col:16>
|-FunctionDecl {{address:make}} <line:4:1, col:38> Make 'func () Value'
| |-ReturnVarDecl {{address:make_result}} <col:13, col:18> 'Value'
| | `-NamedType {{address}} <col:13, col:18> 'Value'
| `-CompoundStmt {{address}} <col:19, col:38>
|   `-ReturnStmt {{address}} <col:21, col:36>
|     `-ImplicitResultInitializationExpr {{address}} <col:28, col:35> 'void' ReturnVar {{address:make_result}} 'Value'
|       `-ConstructionExpr {{address}} <col:28, col:35> 'Value' pure-rvalue complete-object target <col:28, col:33> 'Value' Constructor {{address:constructor}} 'Value' 'func () void'
|-FunctionDecl {{address:take}} <line:5:1, col:26> Take 'func (Value) void'
| |-ParmVarDecl {{address}} <col:11, col:22> value 'Value'
| | `-NamedType {{address}} <col:17, col:22> 'Value'
| `-CompoundStmt {{address}} <col:24, col:26>
`-FunctionDecl {{address}} <line:6:1, col:29> Use 'func () void'
  `-CompoundStmt {{address}} <col:12, col:29>
    `-ExprStmt {{address}} <col:14, col:27>
      `-CallExpr {{address}} <col:14, col:26> 'void'
        |-DeclRefExpr {{address}} <col:14, col:18> 'func (Value) void' Function {{address:take}} 'Take' 'func (Value) void'
        `-CallExpr {{address}} <col:19, col:25> 'Value' pure-rvalue
          `-DeclRefExpr {{address}} <col:19, col:23> 'func () Value' Function {{address:make}} 'Make' 'func () Value')");
}

TEST_F(SemaTest, RejectsNonTrivialGlvaluesAndMixedConditionalValuesForValueParameters) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func Take(value Value) {}
func Reject(condition bool, existing mut Value, other mut Value) {
  Take(existing);
  Take(move existing);
  Take(condition ? existing : Value());
  Take(condition ? move existing : Value());
  Take(condition ? existing : move other);
})");

  ExpectError(5, 7, "cannot initialize parameter 1 of function 'Take': no copy constructor is available for 'Value'",
              8);
  ExpectError(6, 7,
              "cannot initialize parameter 1 of function 'Take': no move or copy constructor is available for 'Value'",
              13);
  ExpectError(7, 19, "cannot form conditional result from then branch: no copy constructor is available for 'Value'",
              8);
  ExpectError(8, 19,
              "cannot form conditional result from then branch: no move or copy constructor is available for 'Value'",
              13);
  ExpectError(9, 19, "cannot form conditional result from then branch: no copy constructor is available for 'Value'",
              8);
}

TEST_F(SemaTest, AppliesNonTrivialDirectTransferToIndirectCallArguments) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func Make() Value { return Value(); }
func Check(callback *func (Value) void, existing mut Value) {
  callback(Make());
  callback(existing);
  callback(move existing);
})");

  ExpectError(6, 11,
              "cannot initialize parameter 1 of indirect function call: no copy constructor is available for 'Value'",
              8);
  ExpectError(7, 11,
              "cannot initialize parameter 1 of indirect function call: no move or copy constructor is available for "
              "'Value'",
              13);
}

TEST_F(SemaTest, ExplainsDerivedToBaseReferenceBindingFailures) {
  Analyze(R"(trivial struct Base {}
trivial struct Derived : Base {}
trivial struct Other {}
func NeedBase(value mut Base) {}
func MoveBase(value move Base) {}
func Check(other mut Other, fixed copy Derived, value mut Derived) {
  NeedBase(other);
  NeedBase(fixed);
  MoveBase(value);
})");

  ExpectError(6, 2, "no matching function for call to 'NeedBase'", 15);
  ExpectNote(3, 0,
             "candidate function is not viable: reference type 'mut Base' cannot bind to a value of type 'Other' "
             "for argument 1",
             0);
  ExpectError(7, 2, "no matching function for call to 'NeedBase'", 15);
  ExpectNote(3, 0,
             "candidate function is not viable: binding a reference of type 'mut Base' to a value of type 'const "
             "Derived' would discard const for argument 1",
             0);
  ExpectError(8, 2, "no matching function for call to 'MoveBase'", 15);
  ExpectNote(4, 0,
             "candidate function is not viable: reference type 'move Base' cannot bind to lvalue of type 'Derived' "
             "for argument 1",
             0);
}

TEST_F(SemaTest, AcceptsDelayedDerivedToBaseReferenceBinding) {
  Analyze(R"(trivial struct Base {}
trivial struct Derived : Base {}
func Check(source mut Derived) {
  var link mut Base;
  link := source;
  link;
})");
}

TEST_F(SemaTest, FormsBaseValuesFromProjectedObjectsAndMaterializedDerivedResults) {
  Analyze(R"(struct Base { number i32; }
ctor Base(number i32) { this.number := number; }
ctor Base(source copy Base) { this.number := source.number; }
ctor Base(source move Base) { this.number := source.number; }
dtor Base() {}
struct Derived : Base {}
ctor Derived() { this.Base := Base(1); }
dtor Derived() {}
func Use(source mut Derived, callback *func (Base) Base) Base {
  var copied Base := source;
  var moved Base := move source;
  var temporary Base := Derived();
  callback(source);
  Derived()
})");
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address:base}} <test.cw:1:1, col:28> Base
| `-FieldDecl {{address:base_number}} <col:15, col:26> number 'i32'
|   `-BuiltinType {{address}} <col:22, col:25> 'i32'
|-ConstructorDecl {{address:base_value_constructor}} <line:2:1, col:49> Base target Struct {{address:base}} 'Base' 'func (i32) void'
| |-ParmVarDecl {{address:base_value_constructor_number}} <col:11, col:21> number 'i32'
| | `-BuiltinType {{address}} <col:18, col:21> 'i32'
| `-CompoundStmt {{address}} <col:23, col:49>
|   `-ExprStmt {{address}} <col:25, col:47>
|     `-InitializationExpr {{address}} <col:25, col:46> 'void'
|       |-MemberExpr {{address}} <col:25, col:36> 'i32' lvalue .number Field {{address:base_number}} 'number' 'i32'
|       | `-ThisExpr {{address}} <col:25, col:29> 'Base' lvalue this
|       `-ImplicitCastExpr {{address}} <col:40, col:46> 'i32' pure-rvalue <LValueToRValue>
|         `-DeclRefExpr {{address}} <col:40, col:46> 'i32' lvalue ParmVar {{address:base_value_constructor_number}} 'number' 'i32'
|-ConstructorDecl {{address:base_copy_constructor}} <line:3:1, col:62> Base target Struct {{address:base}} 'Base' 'func (copy Base) void'
| |-ParmVarDecl {{address:base_copy_constructor_source}} <col:11, col:27> source 'copy Base'
| | `-ReferenceType {{address}} <col:18, col:27> 'copy'
| |   `-NamedType {{address}} <col:23, col:27> 'Base'
| `-CompoundStmt {{address}} <col:29, col:62>
|   `-ExprStmt {{address}} <col:31, col:60>
|     `-InitializationExpr {{address}} <col:31, col:59> 'void'
|       |-MemberExpr {{address}} <col:31, col:42> 'i32' lvalue .number Field {{address:base_number}} 'number' 'i32'
|       | `-ThisExpr {{address}} <col:31, col:35> 'Base' lvalue this
|       `-ImplicitCastExpr {{address}} <col:46, col:59> 'i32' pure-rvalue <LValueToRValue>
|         `-MemberExpr {{address}} <col:46, col:59> 'const i32' lvalue .number Field {{address:base_number}} 'number' 'i32'
|           `-DeclRefExpr {{address}} <col:46, col:52> 'const Base' lvalue ParmVar {{address:base_copy_constructor_source}} 'source' 'copy Base'
|-ConstructorDecl {{address:base_move_constructor}} <line:4:1, col:62> Base target Struct {{address:base}} 'Base' 'func (move Base) void'
| |-ParmVarDecl {{address:base_move_constructor_source}} <col:11, col:27> source 'move Base'
| | `-ReferenceType {{address}} <col:18, col:27> 'move'
| |   `-NamedType {{address}} <col:23, col:27> 'Base'
| `-CompoundStmt {{address}} <col:29, col:62>
|   `-ExprStmt {{address}} <col:31, col:60>
|     `-InitializationExpr {{address}} <col:31, col:59> 'void'
|       |-MemberExpr {{address}} <col:31, col:42> 'i32' lvalue .number Field {{address:base_number}} 'number' 'i32'
|       | `-ThisExpr {{address}} <col:31, col:35> 'Base' lvalue this
|       `-ImplicitCastExpr {{address}} <col:46, col:59> 'i32' pure-rvalue <LValueToRValue>
|         `-MemberExpr {{address}} <col:46, col:59> 'i32' lvalue .number Field {{address:base_number}} 'number' 'i32'
|           `-DeclRefExpr {{address}} <col:46, col:52> 'Base' lvalue ParmVar {{address:base_move_constructor_source}} 'source' 'move Base'
|-DestructorDecl {{address:base_destructor}} <line:5:1, col:15> Base target Struct {{address:base}} 'Base' 'func () void'
| `-CompoundStmt {{address}} <col:13, col:15>
|-StructDecl {{address:derived}} <line:6:1, col:25> Derived : 'Base'
| `-BaseType 'Base' Struct {{address:base}} 'Base'
|-ConstructorDecl {{address:derived_constructor}} <line:7:1, col:41> Derived target Struct {{address:derived}} 'Derived' 'func () void'
| `-CompoundStmt {{address}} <col:16, col:41>
|   `-ExprStmt {{address}} <col:18, col:39>
|     `-InitializationExpr {{address}} <col:18, col:38> 'void'
|       |-BaseSubobjectExpr {{address}} <col:18, col:27> 'Base' lvalue .Base Struct {{address:base}} 'Base'
|       | `-ThisExpr {{address}} <col:18, col:22> 'Derived' lvalue this
|       `-ConstructionExpr {{address}} <col:31, col:38> 'Base' pure-rvalue base-subobject target <col:31, col:35> 'Base' Constructor {{address:base_value_constructor}} 'Base' 'func (i32) void'
|         `-ImplicitCastExpr {{address}} <col:36, col:37> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
|           `-IntegerLiteral {{address}} <col:36, col:37> 'comptime_int' 1
|-DestructorDecl {{address:derived_destructor}} <line:8:1, col:18> Derived target Struct {{address:derived}} 'Derived' 'func () void'
| `-CompoundStmt {{address}} <col:16, col:18>
`-FunctionDecl {{address:use}} <line:9:1, line:15:2> Use 'func (mut Derived, *func (Base) Base) Base'
  |-ParmVarDecl {{address:use_source}} <line:9:10, col:28> source 'mut Derived'
  | `-ReferenceType {{address}} <col:17, col:28> 'mut'
  |   `-NamedType {{address}} <col:21, col:28> 'Derived'
  |-ParmVarDecl {{address:use_callback}} <col:30, col:56> callback '*func (Base) Base'
  | `-PointerType {{address}} <col:39, col:56>
  |   `-FunctionType {{address}} <col:40, col:56>
  |     |-NamedType {{address}} <col:46, col:50> 'Base'
  |     `-NamedType {{address}} <col:52, col:56> 'Base'
  |-ReturnVarDecl {{address:use_result}} <col:58, col:62> 'Base'
  | `-NamedType {{address}} <col:58, col:62> 'Base'
  `-CompoundStmt {{address}} <col:63, line:15:2>
    |-DeclStmt {{address}} <line:10:3, col:29>
    | `-VarGroupDecl {{address}} <col:3, col:29>
    |   |-VarDecl {{address}} <col:7, col:18> copied 'Base'
    |   | `-NamedType {{address}} <col:14, col:18> 'Base'
    |   `-ConstructionExpr {{address}} <col:22, col:28> 'Base' pure-rvalue complete-object Constructor {{address:base_copy_constructor}} 'Base' 'func (copy Base) void'
    |     `-ImplicitCastExpr {{address}} <col:22, col:28> 'const Base' lvalue <NoOp>
    |       `-ImplicitCastExpr {{address}} <col:22, col:28> 'Base' lvalue <DerivedToBase> path Struct {{address:base}} 'Base'
    |         `-DeclRefExpr {{address}} <col:22, col:28> 'Derived' lvalue ParmVar {{address:use_source}} 'source' 'mut Derived'
    |-DeclStmt {{address}} <line:11:3, col:33>
    | `-VarGroupDecl {{address}} <col:3, col:33>
    |   |-VarDecl {{address}} <col:7, col:17> moved 'Base'
    |   | `-NamedType {{address}} <col:13, col:17> 'Base'
    |   `-ConstructionExpr {{address}} <col:21, col:32> 'Base' pure-rvalue complete-object Constructor {{address:base_move_constructor}} 'Base' 'func (move Base) void'
    |     `-ImplicitCastExpr {{address}} <col:21, col:32> 'Base' move-lvalue <DerivedToBase> path Struct {{address:base}} 'Base'
    |       `-UnaryOperator {{address}} <col:21, col:32> 'Derived' move-lvalue 'move'
    |         `-DeclRefExpr {{address}} <col:26, col:32> 'Derived' lvalue ParmVar {{address:use_source}} 'source' 'mut Derived'
    |-DeclStmt {{address}} <line:12:3, col:35>
    | `-VarGroupDecl {{address}} <col:3, col:35>
    |   |-VarDecl {{address}} <col:7, col:21> temporary 'Base'
    |   | `-NamedType {{address}} <col:17, col:21> 'Base'
    |   `-ConstructionExpr {{address}} <col:25, col:34> 'Base' pure-rvalue complete-object Constructor {{address:base_move_constructor}} 'Base' 'func (move Base) void'
    |     `-ImplicitCastExpr {{address}} <col:25, col:34> 'Base' move-lvalue <DerivedToBase> path Struct {{address:base}} 'Base'
    |       `-MaterializeTemporaryExpr {{address}} <col:25, col:34> 'Derived' move-lvalue
    |         `-ConstructionExpr {{address}} <col:25, col:34> 'Derived' pure-rvalue complete-object target <col:25, col:32> 'Derived' Constructor {{address:derived_constructor}} 'Derived' 'func () void'
    |-ExprStmt {{address}} <line:13:3, col:20>
    | `-CallExpr {{address}} <col:3, col:19> 'Base' pure-rvalue
    |   |-ImplicitCastExpr {{address}} <col:3, col:11> '*func (Base) Base' pure-rvalue <LValueToRValue>
    |   | `-DeclRefExpr {{address}} <col:3, col:11> '*func (Base) Base' lvalue ParmVar {{address:use_callback}} 'callback' '*func (Base) Base'
    |   `-ConstructionExpr {{address}} <col:12, col:18> 'Base' pure-rvalue complete-object Constructor {{address:base_copy_constructor}} 'Base' 'func (copy Base) void'
    |     `-ImplicitCastExpr {{address}} <col:12, col:18> 'const Base' lvalue <NoOp>
    |       `-ImplicitCastExpr {{address}} <col:12, col:18> 'Base' lvalue <DerivedToBase> path Struct {{address:base}} 'Base'
    |         `-DeclRefExpr {{address}} <col:12, col:18> 'Derived' lvalue ParmVar {{address:use_source}} 'source' 'mut Derived'
    `-ImplicitResultInitializationExpr {{address}} <line:14:3, col:12> 'void' ReturnVar {{address:use_result}} 'Base'
      `-ConstructionExpr {{address}} <col:3, col:12> 'Base' pure-rvalue complete-object Constructor {{address:base_move_constructor}} 'Base' 'func (move Base) void'
        `-ImplicitCastExpr {{address}} <col:3, col:12> 'Base' move-lvalue <DerivedToBase> path Struct {{address:base}} 'Base'
          `-MaterializeTemporaryExpr {{address}} <col:3, col:12> 'Derived' move-lvalue
            `-ConstructionExpr {{address}} <col:3, col:12> 'Derived' pure-rvalue complete-object target <col:3, col:10> 'Derived' Constructor {{address:derived_constructor}} 'Derived' 'func () void')");
}

TEST_F(SemaTest, FormsTrivialBaseValuesFromEverySourceCategory) {
  Analyze(R"(trivial struct Base { number i32; }
trivial struct Derived : Base {}
func Make(source copy Derived) Derived { source }
func Use(source mut Derived, readonly copy Derived) {
  var copied Base := source;
  var fixed Base := readonly;
  var moved Base := move source;
  var temporary Base := Make(source);
})");
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address:base}} <test.cw:1:1, col:36> Base trivial
| `-FieldDecl {{address:base_number}} <col:23, col:34> number 'i32'
|   `-BuiltinType {{address}} <col:30, col:33> 'i32'
|-StructDecl {{address:derived}} <line:2:1, col:33> Derived trivial : 'Base'
| `-BaseType 'Base' Struct {{address:base}} 'Base'
|-FunctionDecl {{address:make}} <line:3:1, col:50> Make 'func (copy Derived) Derived'
| |-ParmVarDecl {{address:make_source}} <col:11, col:30> source 'copy Derived'
| | `-ReferenceType {{address}} <col:18, col:30> 'copy'
| |   `-NamedType {{address}} <col:23, col:30> 'Derived'
| |-ReturnVarDecl {{address:make_result}} <col:32, col:39> 'Derived'
| | `-NamedType {{address}} <col:32, col:39> 'Derived'
| `-CompoundStmt {{address}} <col:40, col:50>
|   `-ImplicitResultInitializationExpr {{address}} <col:42, col:48> 'void' ReturnVar {{address:make_result}} 'Derived'
|     `-ImplicitCastExpr {{address}} <col:42, col:48> 'Derived' pure-rvalue <LValueToRValue>
|       `-DeclRefExpr {{address}} <col:42, col:48> 'const Derived' lvalue ParmVar {{address:make_source}} 'source' 'copy Derived'
`-FunctionDecl {{address:use}} <line:4:1, line:9:2> Use 'func (mut Derived, copy Derived) void'
  |-ParmVarDecl {{address:use_source}} <line:4:10, col:28> source 'mut Derived'
  | `-ReferenceType {{address}} <col:17, col:28> 'mut'
  |   `-NamedType {{address}} <col:21, col:28> 'Derived'
  |-ParmVarDecl {{address:use_readonly}} <col:30, col:51> readonly 'copy Derived'
  | `-ReferenceType {{address}} <col:39, col:51> 'copy'
  |   `-NamedType {{address}} <col:44, col:51> 'Derived'
  `-CompoundStmt {{address}} <col:53, line:9:2>
    |-DeclStmt {{address}} <line:5:3, col:29>
    | `-VarGroupDecl {{address}} <col:3, col:29>
    |   |-VarDecl {{address}} <col:7, col:18> copied 'Base'
    |   | `-NamedType {{address}} <col:14, col:18> 'Base'
    |   `-ImplicitCastExpr {{address}} <col:22, col:28> 'Base' pure-rvalue <LValueToRValue>
    |     `-ImplicitCastExpr {{address}} <col:22, col:28> 'Base' lvalue <DerivedToBase> path Struct {{address:base}} 'Base'
    |       `-DeclRefExpr {{address}} <col:22, col:28> 'Derived' lvalue ParmVar {{address:use_source}} 'source' 'mut Derived'
    |-DeclStmt {{address}} <line:6:3, col:30>
    | `-VarGroupDecl {{address}} <col:3, col:30>
    |   |-VarDecl {{address}} <col:7, col:17> fixed 'Base'
    |   | `-NamedType {{address}} <col:13, col:17> 'Base'
    |   `-ImplicitCastExpr {{address}} <col:21, col:29> 'Base' pure-rvalue <LValueToRValue>
    |     `-ImplicitCastExpr {{address}} <col:21, col:29> 'const Base' lvalue <DerivedToBase> path Struct {{address:base}} 'Base'
    |       `-DeclRefExpr {{address}} <col:21, col:29> 'const Derived' lvalue ParmVar {{address:use_readonly}} 'readonly' 'copy Derived'
    |-DeclStmt {{address}} <line:7:3, col:33>
    | `-VarGroupDecl {{address}} <col:3, col:33>
    |   |-VarDecl {{address}} <col:7, col:17> moved 'Base'
    |   | `-NamedType {{address}} <col:13, col:17> 'Base'
    |   `-ImplicitCastExpr {{address}} <col:21, col:32> 'Base' pure-rvalue <LValueToRValue>
    |     `-ImplicitCastExpr {{address}} <col:21, col:32> 'Base' move-lvalue <DerivedToBase> path Struct {{address:base}} 'Base'
    |       `-UnaryOperator {{address}} <col:21, col:32> 'Derived' move-lvalue 'move'
    |         `-DeclRefExpr {{address}} <col:26, col:32> 'Derived' lvalue ParmVar {{address:use_source}} 'source' 'mut Derived'
    `-DeclStmt {{address}} <line:8:3, col:38>
      `-VarGroupDecl {{address}} <col:3, col:38>
        |-VarDecl {{address}} <col:7, col:21> temporary 'Base'
        | `-NamedType {{address}} <col:17, col:21> 'Base'
        `-ImplicitCastExpr {{address}} <col:25, col:37> 'Base' pure-rvalue <LValueToRValue>
          `-ImplicitCastExpr {{address}} <col:25, col:37> 'Base' move-lvalue <DerivedToBase> path Struct {{address:base}} 'Base'
            `-MaterializeTemporaryExpr {{address}} <col:25, col:37> 'Derived' move-lvalue
              `-CallExpr {{address}} <col:25, col:37> 'Derived' pure-rvalue
                |-DeclRefExpr {{address}} <col:25, col:29> 'func (copy Derived) Derived' Function {{address:make}} 'Make' 'func (copy Derived) Derived'
                `-ImplicitCastExpr {{address}} <col:30, col:36> 'const Derived' lvalue <NoOp>
                  `-DeclRefExpr {{address}} <col:30, col:36> 'Derived' lvalue ParmVar {{address:use_source}} 'source' 'mut Derived')");
}

TEST_F(SemaTest, PreservesAllArgumentsWhenSelectedBaseValueFormationFails) {
  const std::string source = R"(struct Base {}
ctor Base() {}
dtor Base() {}
struct Derived : Base {}
ctor Derived() { this.Base := Base(); }
dtor Derived() {}
func F() {}
func Select(fn *func () void, number u8, object Base, rank i32) {}
func Select(fn *func () void, number u8, object copy Base, rank i64) {}
func Use(source mut Derived, number i32) { Select(&F, number, source, number); })";
  Analyze(source);
  const auto call_line = source.substr(source.rfind('\n') + 1);
  ExpectError(9, static_cast<int>(call_line.find("source, number")),
              "cannot initialize parameter 3 of function 'Select': no copy constructor is available for 'Base'", 6);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-StructDecl {{address:base}} <test.cw:1:1, col:15> Base
|-ConstructorDecl {{address:base_constructor}} <line:2:1, col:15> Base target Struct {{address:base}} 'Base' 'func () void'
| `-CompoundStmt {{address}} <col:13, col:15>
|-DestructorDecl {{address:base_destructor}} <line:3:1, col:15> Base target Struct {{address:base}} 'Base' 'func () void'
| `-CompoundStmt {{address}} <col:13, col:15>
|-StructDecl {{address:derived}} <line:4:1, col:25> Derived : 'Base'
| `-BaseType 'Base' Struct {{address:base}} 'Base'
|-ConstructorDecl {{address:derived_constructor}} <line:5:1, col:40> Derived target Struct {{address:derived}} 'Derived' 'func () void'
| `-CompoundStmt {{address}} <col:16, col:40>
|   `-ExprStmt {{address}} <col:18, col:38>
|     `-InitializationExpr {{address}} <col:18, col:37> 'void'
|       |-BaseSubobjectExpr {{address}} <col:18, col:27> 'Base' lvalue .Base Struct {{address:base}} 'Base'
|       | `-ThisExpr {{address}} <col:18, col:22> 'Derived' lvalue this
|       `-ConstructionExpr {{address}} <col:31, col:37> 'Base' pure-rvalue base-subobject target <col:31, col:35> 'Base' Constructor {{address:base_constructor}} 'Base' 'func () void'
|-DestructorDecl {{address:derived_destructor}} <line:6:1, col:18> Derived target Struct {{address:derived}} 'Derived' 'func () void'
| `-CompoundStmt {{address}} <col:16, col:18>
|-FunctionDecl {{address:f}} <line:7:1, col:12> F 'func () void'
| `-CompoundStmt {{address}} <col:10, col:12>
|-FunctionDecl {{address:selected}} <line:8:1, col:67> Select 'func (*func () void, u8, Base, i32) void'
| |-ParmVarDecl {{address:selected_fn}} <col:13, col:29> fn '*func () void'
| | `-PointerType {{address}} <col:16, col:29>
| |   `-FunctionType {{address}} <col:17, col:29>
| |     `-BuiltinType {{address}} <col:25, col:29> 'void'
| |-ParmVarDecl {{address:selected_number}} <col:31, col:40> number 'u8'
| | `-BuiltinType {{address}} <col:38, col:40> 'u8'
| |-ParmVarDecl {{address:selected_object}} <col:42, col:53> object 'Base'
| | `-NamedType {{address}} <col:49, col:53> 'Base'
| |-ParmVarDecl {{address:selected_rank}} <col:55, col:63> rank 'i32'
| | `-BuiltinType {{address}} <col:60, col:63> 'i32'
| `-CompoundStmt {{address}} <col:65, col:67>
|-FunctionDecl {{address:other_candidate}} <line:9:1, col:72> Select 'func (*func () void, u8, copy Base, i64) void'
| |-ParmVarDecl {{address:other_candidate_fn}} <col:13, col:29> fn '*func () void'
| | `-PointerType {{address}} <col:16, col:29>
| |   `-FunctionType {{address}} <col:17, col:29>
| |     `-BuiltinType {{address}} <col:25, col:29> 'void'
| |-ParmVarDecl {{address:other_candidate_number}} <col:31, col:40> number 'u8'
| | `-BuiltinType {{address}} <col:38, col:40> 'u8'
| |-ParmVarDecl {{address:other_candidate_object}} <col:42, col:58> object 'copy Base'
| | `-ReferenceType {{address}} <col:49, col:58> 'copy'
| |   `-NamedType {{address}} <col:54, col:58> 'Base'
| |-ParmVarDecl {{address:other_candidate_rank}} <col:60, col:68> rank 'i64'
| | `-BuiltinType {{address}} <col:65, col:68> 'i64'
| `-CompoundStmt {{address}} <col:70, col:72>
`-FunctionDecl {{address:use}} <line:10:1, col:81> Use 'func (mut Derived, i32) void' contains-errors
  |-ParmVarDecl {{address:use_source}} <col:10, col:28> source 'mut Derived'
  | `-ReferenceType {{address}} <col:17, col:28> 'mut'
  |   `-NamedType {{address}} <col:21, col:28> 'Derived'
  |-ParmVarDecl {{address:use_number}} <col:30, col:40> number 'i32'
  | `-BuiltinType {{address}} <col:37, col:40> 'i32'
  `-CompoundStmt {{address}} <col:42, col:81> contains-errors
    `-ExprStmt {{address}} <col:44, col:79> contains-errors
      `-CallExpr {{address}} <col:44, col:78> contains-errors
        |-DeclRefExpr {{address}} <col:44, col:50> 'func (*func () void, u8, Base, i32) void' Function {{address:selected}} 'Select' 'func (*func () void, u8, Base, i32) void'
        |-UnaryOperator {{address}} <col:51, col:53> '<address-of-function-overload-set>' '&'
        | `-DeclRefExpr {{address}} <col:52, col:53> '<function-overload-set>' 'F'
        |-DeclRefExpr {{address}} <col:55, col:61> 'i32' lvalue ParmVar {{address:use_number}} 'number' 'i32'
        |-DeclRefExpr {{address}} <col:63, col:69> 'Derived' lvalue ParmVar {{address:use_source}} 'source' 'mut Derived'
        `-DeclRefExpr {{address}} <col:71, col:77> 'i32' lvalue ParmVar {{address:use_number}} 'number' 'i32')");
}

TEST_F(SemaTest, PreservesBaseSubobjectConstructionKindAfterSlicing) {
  Analyze(R"(struct Base {}
ctor Base() {}
ctor Base(source copy Base) {}
dtor Base() {}
struct Derived : Base {}
ctor Derived() { this.Base := Base(); }
dtor Derived() {}
struct Holder : Base {}
dtor Holder() {}
ctor Holder(source copy Derived) { this.Base := source; })");
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address:base}} <test.cw:1:1, col:15> Base
|-ConstructorDecl {{address:base_constructor}} <line:2:1, col:15> Base target Struct {{address:base}} 'Base' 'func () void'
| `-CompoundStmt {{address}} <col:13, col:15>
|-ConstructorDecl {{address:base_copy_constructor}} <line:3:1, col:31> Base target Struct {{address:base}} 'Base' 'func (copy Base) void'
| |-ParmVarDecl {{address:base_copy_constructor_source}} <col:11, col:27> source 'copy Base'
| | `-ReferenceType {{address}} <col:18, col:27> 'copy'
| |   `-NamedType {{address}} <col:23, col:27> 'Base'
| `-CompoundStmt {{address}} <col:29, col:31>
|-DestructorDecl {{address:base_destructor}} <line:4:1, col:15> Base target Struct {{address:base}} 'Base' 'func () void'
| `-CompoundStmt {{address}} <col:13, col:15>
|-StructDecl {{address:derived}} <line:5:1, col:25> Derived : 'Base'
| `-BaseType 'Base' Struct {{address:base}} 'Base'
|-ConstructorDecl {{address:derived_constructor}} <line:6:1, col:40> Derived target Struct {{address:derived}} 'Derived' 'func () void'
| `-CompoundStmt {{address}} <col:16, col:40>
|   `-ExprStmt {{address}} <col:18, col:38>
|     `-InitializationExpr {{address}} <col:18, col:37> 'void'
|       |-BaseSubobjectExpr {{address}} <col:18, col:27> 'Base' lvalue .Base Struct {{address:base}} 'Base'
|       | `-ThisExpr {{address}} <col:18, col:22> 'Derived' lvalue this
|       `-ConstructionExpr {{address}} <col:31, col:37> 'Base' pure-rvalue base-subobject target <col:31, col:35> 'Base' Constructor {{address:base_constructor}} 'Base' 'func () void'
|-DestructorDecl {{address:derived_destructor}} <line:7:1, col:18> Derived target Struct {{address:derived}} 'Derived' 'func () void'
| `-CompoundStmt {{address}} <col:16, col:18>
|-StructDecl {{address:holder}} <line:8:1, col:24> Holder : 'Base'
| `-BaseType 'Base' Struct {{address:base}} 'Base'
|-DestructorDecl {{address:holder_destructor}} <line:9:1, col:17> Holder target Struct {{address:holder}} 'Holder' 'func () void'
| `-CompoundStmt {{address}} <col:15, col:17>
`-ConstructorDecl {{address:holder_constructor}} <line:10:1, col:58> Holder target Struct {{address:holder}} 'Holder' 'func (copy Derived) void'
  |-ParmVarDecl {{address:holder_constructor_source}} <col:13, col:32> source 'copy Derived'
  | `-ReferenceType {{address}} <col:20, col:32> 'copy'
  |   `-NamedType {{address}} <col:25, col:32> 'Derived'
  `-CompoundStmt {{address}} <col:34, col:58>
    `-ExprStmt {{address}} <col:36, col:56>
      `-InitializationExpr {{address}} <col:36, col:55> 'void'
        |-BaseSubobjectExpr {{address}} <col:36, col:45> 'Base' lvalue .Base Struct {{address:base}} 'Base'
        | `-ThisExpr {{address}} <col:36, col:40> 'Holder' lvalue this
        `-ConstructionExpr {{address}} <col:49, col:55> 'Base' pure-rvalue base-subobject Constructor {{address:base_copy_constructor}} 'Base' 'func (copy Base) void'
          `-ImplicitCastExpr {{address}} <col:49, col:55> 'const Base' lvalue <DerivedToBase> path Struct {{address:base}} 'Base'
            `-DeclRefExpr {{address}} <col:49, col:55> 'const Derived' lvalue ParmVar {{address:holder_constructor_source}} 'source' 'copy Derived')");
}

// User operators and special assignment.

TEST_F(SemaTest, RejectsDuplicateOperatorSignatures) {
  Analyze(R"(trivial struct S {}
func operator+(left mut S, right copy S) {}
func operator+(lhs mut S, rhs copy S) {}
func operator+(left copy S, right copy S) {})");

  ExpectError(2, 5, "redefinition of operator '+'", 0);
  ExpectNote(1, 5, "previous declaration is here", 0);
}

TEST_F(SemaTest, SelectsCopyMoveAndMoveFallbackAssignmentBySameTypeIdentity) {
  Analyze(R"(struct Both {}
func operator=(dst mut Both, src copy Both) i32 { return 1; }
func operator=(dst mut Both, src move Both) bool { return true; }
ctor Both() {}
dtor Both() {}
func copy_both(dst mut Both, src copy Both) i32 { return dst = src; }
func move_both(dst mut Both, src move Both) bool { return dst = move src; }
struct CopyOnly {}
func operator=(dst mut CopyOnly, src copy CopyOnly) i32 { return 3; }
ctor CopyOnly() {}
dtor CopyOnly() {}
func move_fallback(dst mut CopyOnly, src move CopyOnly) i32 { return dst = move src; })");
}

TEST_F(SemaTest, RejectsForbiddenAndDuplicateSpecialAssignmentIdentities) {
  Analyze(R"(struct S {}
func operator=(dst mut S, src mut S) {}
func operator=(dst mut S, src copy S) {}
func operator=(other mut S, value copy S) {}
func operator=(dst mut S, src move S) {}
func operator=(other mut S, value move S) {}
ctor S() {}
dtor S() {})");

  ExpectError(1, 5, "same-type assignment cannot use a 'mut' source parameter", 9);
  ExpectError(3, 5, "redefinition of copy assignment", 0);
  ExpectNote(2, 5, "previous declaration is here", 0);
  ExpectError(5, 5, "redefinition of move assignment", 0);
  ExpectNote(4, 5, "previous declaration is here", 0);
}

TEST_F(SemaTest, RejectsSpecialAssignmentDeclarationsForTrivialTypes) {
  Analyze(R"(trivial struct S {}
func operator=(dst mut S, src copy S) {}
func operator=(dst mut S, src move S) {})");

  ExpectError(1, 5, "copy assignment cannot be declared for trivial type 'S'", 9);
  ExpectError(2, 5, "move assignment cannot be declared for trivial type 'S'", 9);
}

TEST_F(SemaTest, ExcludesInvalidCopyAssignmentInterfaceFromCallableSlot) {
  Analyze(R"(struct S {}
func operator=(dst mut S, src copy S) var result void {}
ctor S() {}
dtor S() {}
func use(dst mut S, src copy S) {
  dst = src;
})");

  ExpectError(1, 38, "void function cannot declare a named return object", 15);
  ExpectError(5, 2, "no copy assignment declared for type 'S'", 9);
}

TEST_F(SemaTest, KeepsSpecialAssignmentWithErroneousBodyInCallableSlot) {
  Analyze(R"(struct S {}
func operator=(dst mut S, src copy S) { missing_body; }
ctor S() {}
dtor S() {}
func use(dst mut S, src copy S) { dst = src; })");

  ExpectError(1, 40, "use of undeclared identifier 'missing_body'", 12);
}

TEST_F(SemaTest, FormsMoveAssignmentCallFromPureRValueAtomically) {
  Analyze(R"(struct S {}
func operator=(dst mut S, src move S) {}
ctor S() {}
dtor S() {}
func Make() S { return S(); }
func Assign(dst mut S) { dst = Make(); })");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address:structure}} <test.cw:1:1, col:12> S
|-FunctionDecl {{address:move_assignment}} <line:2:1, col:41> operator= 'func (mut S, move S) void'
| |-ParmVarDecl {{address:destination}} <col:16, col:25> dst 'mut S'
| | `-ReferenceType {{address}} <col:20, col:25> 'mut'
| |   `-NamedType {{address}} <col:24, col:25> 'S'
| |-ParmVarDecl {{address:source}} <col:27, col:37> src 'move S'
| | `-ReferenceType {{address}} <col:31, col:37> 'move'
| |   `-NamedType {{address}} <col:36, col:37> 'S'
| `-CompoundStmt {{address}} <col:39, col:41>
|-ConstructorDecl {{address:constructor}} <line:3:1, col:12> S target Struct {{address:structure}} 'S' 'func () void'
| `-CompoundStmt {{address}} <col:10, col:12>
|-DestructorDecl {{address}} <line:4:1, col:12> S target Struct {{address:structure}} 'S' 'func () void'
| `-CompoundStmt {{address}} <col:10, col:12>
|-FunctionDecl {{address:make}} <line:5:1, col:30> Make 'func () S'
| |-ReturnVarDecl {{address:make_result}} <col:13, col:14> 'S'
| | `-NamedType {{address}} <col:13, col:14> 'S'
| `-CompoundStmt {{address}} <col:15, col:30>
|   `-ReturnStmt {{address}} <col:17, col:28>
|     `-ImplicitResultInitializationExpr {{address}} <col:24, col:27> 'void' ReturnVar {{address:make_result}} 'S'
|       `-ConstructionExpr {{address}} <col:24, col:27> 'S' pure-rvalue complete-object target <col:24, col:25> 'S' Constructor {{address:constructor}} 'S' 'func () void'
`-FunctionDecl {{address}} <line:6:1, col:41> Assign 'func (mut S) void'
  |-ParmVarDecl {{address:assign_destination}} <col:13, col:22> dst 'mut S'
  | `-ReferenceType {{address}} <col:17, col:22> 'mut'
  |   `-NamedType {{address}} <col:21, col:22> 'S'
  `-CompoundStmt {{address}} <col:24, col:41>
    `-ExprStmt {{address}} <col:26, col:39>
      `-OperatorCallExpr {{address}} <col:26, col:38> 'void'
        |-DeclRefExpr {{address}} <col:30, col:31> 'func (mut S, move S) void' Function {{address:move_assignment}} 'operator=' 'func (mut S, move S) void'
        |-DeclRefExpr {{address}} <col:26, col:29> 'S' lvalue ParmVar {{address:assign_destination}} 'dst' 'mut S'
        `-MaterializeTemporaryExpr {{address}} <col:32, col:38> 'S' move-lvalue
          `-CallExpr {{address}} <col:32, col:38> 'S' pure-rvalue
            `-DeclRefExpr {{address}} <col:32, col:36> 'func () S' Function {{address:make}} 'Make' 'func () S')");
}

TEST_F(SemaTest, RejectsInvalidSupportedOperatorInterfacesBeforeLookup) {
  Analyze(R"(trivial struct S {}
func operator+() {}
func operator!(left S, right S) {}
func operator*(left i32, right i32) {}
func operator/(left *S, right *S) {})");

  ExpectError(1, 5, "operator '+' requires one or two parameters", 9);
  ExpectError(2, 5, "operator '!' requires exactly one parameter", 9);
  ExpectError(3, 5, "operator '*' requires a struct or reference-to-struct parameter", 9);
  ExpectError(4, 5, "operator '/' requires a struct or reference-to-struct parameter", 9);
}

TEST_F(SemaTest, RejectsInvalidCallOperatorReceiversWithoutCascadingAtUseSites) {
  Analyze(R"(trivial struct S {}
func operator()() {}
func operator()(object S) {}
func operator()(object *S) {}
func operator()(object mut i32) {}
func Use(object mut S) { object(); })");

  ExpectError(1, 5, "operator '()' requires a receiver parameter", 10);
  ExpectError(2, 5, "first parameter of operator '()' must be a reference to a struct, not 'S'", 10);
  ExpectError(3, 5, "first parameter of operator '()' must be a reference to a struct, not '*S'", 10);
  ExpectError(4, 5, "first parameter of operator '()' must be a reference to a struct, not 'mut i32'", 10);
}

TEST_F(SemaTest, RejectsInitializationOperatorOverload) {
  Analyze("func operator:=() {}");

  ExpectError(0, 5, "operator ':=' cannot be overloaded", 10);
}

TEST_F(SemaTest, ChecksNonOverloadableOperatorAfterSignatureError) {
  Analyze("func operator:=(value Missing) {}");

  ExpectError(0, 22, "unknown type 'Missing'", 7);
  ExpectError(0, 5, "operator ':=' cannot be overloaded", 10);
}

TEST_F(SemaTest, ReportsUnavailableOperatorsWithoutFunctionCandidates) {
  Analyze(R"(trivial struct S {}
func Use(value S) {
  +value;
  value + value;
})");

  ExpectError(2, 2, "unary operator '+' cannot be applied to type 'S'", 6);
  ExpectError(3, 2, "binary operator '+' cannot be applied to types 'S' and 'S'", 13);
}

TEST_F(SemaTest, AppliesNonTrivialDirectTransferToOperatorArguments) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func Make() Value { return Value(); }
func operator!(value Value) bool { return true; }
func Check(existing mut Value) {
  !Make();
  !existing;
  !(move existing);
})");

  ExpectError(7, 3, "cannot initialize parameter 1 of operator '!': no copy constructor is available for 'Value'", 8);
  ExpectError(
      8, 3, "cannot initialize parameter 1 of operator '!': no move or copy constructor is available for 'Value'", 15);
}

TEST_F(SemaTest, RetainsSelectedOperatorCallWhenParameterFormationFails) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func operator!(value Value) bool { true }
func Check(existing mut Value) { !existing; })");

  ExpectError(4, 34, "cannot initialize parameter 1 of operator '!': no copy constructor is available for 'Value'", 8);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-StructDecl {{address:structure}} <test.cw:1:1, col:16> Value
|-ConstructorDecl {{address:constructor}} <line:2:1, col:16> Value target Struct {{address:structure}} 'Value' 'func () void'
| `-CompoundStmt {{address}} <col:14, col:16>
|-DestructorDecl {{address}} <line:3:1, col:16> Value target Struct {{address:structure}} 'Value' 'func () void'
| `-CompoundStmt {{address}} <col:14, col:16>
|-FunctionDecl {{address:operator}} <line:4:1, col:42> operator! 'func (Value) bool'
| |-ParmVarDecl {{address}} <col:16, col:27> value 'Value'
| | `-NamedType {{address}} <col:22, col:27> 'Value'
| |-ReturnVarDecl {{address:result}} <col:29, col:33> 'bool'
| | `-BuiltinType {{address}} <col:29, col:33> 'bool'
| `-CompoundStmt {{address}} <col:34, col:42>
|   `-ImplicitResultInitializationExpr {{address}} <col:36, col:40> 'void' ReturnVar {{address:result}} 'bool'
|     `-BoolLiteral {{address}} <col:36, col:40> 'bool' pure-rvalue true
`-FunctionDecl {{address}} <line:5:1, col:46> Check 'func (mut Value) void' contains-errors
  |-ParmVarDecl {{address:existing}} <col:12, col:30> existing 'mut Value'
  | `-ReferenceType {{address}} <col:21, col:30> 'mut'
  |   `-NamedType {{address}} <col:25, col:30> 'Value'
  `-CompoundStmt {{address}} <col:32, col:46> contains-errors
    `-ExprStmt {{address}} <col:34, col:44> contains-errors
      `-OperatorCallExpr {{address}} <col:34, col:43> contains-errors
        |-DeclRefExpr {{address}} <col:34, col:35> 'func (Value) bool' Function {{address:operator}} 'operator!' 'func (Value) bool'
        `-DeclRefExpr {{address}} <col:35, col:43> 'Value' lvalue ParmVar {{address:existing}} 'existing' 'mut Value')");
}

TEST_F(SemaTest, ReportsNoMatchingUserOperatorWithCandidateNotes) {
  Analyze(R"(trivial struct S {}
func operator+(left mut S, right copy S) {}
func Use(left copy S, right S) { left + right; })");

  ExpectError(2, 33, "no matching overloaded operator '+'", 12);
  ExpectNote(1, 0,
             "candidate function is not viable: binding a reference of type 'mut S' to a value of type 'const S' "
             "would discard const for operand 1",
             0);
}

TEST_F(SemaTest, ReportsAllViableUserOperatorCandidatesForAmbiguity) {
  Analyze(R"(trivial struct S {}
func operator+(left mut S, right copy S) {}
func operator+(left copy S, right mut S) {}
func operator+(left copy S, right copy S) {}
func Use(left S, right S) { left + right; })");

  ExpectError(4, 28, "use of overloaded operator '+' is ambiguous", 12);
  ExpectNote(1, 0, "candidate function", 0);
  ExpectNote(2, 0, "candidate function", 0);
  ExpectNote(3, 0, "candidate function", 0);
}

TEST_F(SemaTest, DiagnosesExplicitOperatorFunctionCallFailures) {
  Analyze(R"(trivial struct S {}
func operator!(value copy S) {}
func operator+(left mut S, right copy S) {}
func operator+(left copy S, right mut S) {}
func Diagnose(left S, right S) {
  operator %(1, 2);
  operator !(left, right);
  operator +(left, right);
})");

  ExpectError(5, 2, "use of undeclared operator '%'", 10);
  ExpectError(6, 2, "no matching function for call to operator '!'", 23);
  ExpectNote(1, 0, "candidate function requires 1 argument, but 2 were provided", 0);
  ExpectError(7, 2, "call to operator '+' is ambiguous", 23);
  ExpectNote(2, 0, "candidate function", 0);
  ExpectNote(3, 0, "candidate function", 0);
}

TEST_F(SemaTest, SuppressesDependentExplicitOperatorCallDiagnosticsForInvalidDeclarations) {
  Analyze(R"(trivial struct S {}
func operator+() {}
func Use() { operator +(); })");

  ExpectError(1, 5, "operator '+' requires one or two parameters", 9);
}

TEST_F(SemaTest, TreatsExplicitAssignmentOperatorCallAsAnOrdinaryCall) {
  Analyze(R"(struct S {}
ctor S() {}
dtor S() {}
func operator=(dst mut S, src copy S) {}
func Use(src copy S) {
  var dst S;
  operator =(dst, src);
})");

  ExpectError(6, 13, "use of uninitialized variable 'dst'", 3);
}

TEST_F(SemaTest, ExcludesIncompleteOperatorDeclarationWithoutCandidateRecovery) {
  Analyze(R"(trivial struct S {}
func operator+(left S, right Missing) {}
func Use(left S, right S) { left + right; })");

  ExpectError(1, 29, "unknown type 'Missing'", 7);
  ExpectError(2, 28, "binary operator '+' cannot be applied to types 'S' and 'S'", 12);
}

TEST_F(SemaTest, DoesNotUseStructOperatorForPointerOperands) {
  Analyze(R"(trivial struct S {}
func operator+(left copy S, right copy S) {}
func Use(left *S, right *S) { left + right; })");

  ExpectError(2, 30, "binary operator '+' cannot be applied to types '*S' and '*S'", 12);
}

TEST_F(SemaTest, ReportsSelectedOperatorArgumentConversionRisk) {
  Analyze(R"(trivial struct S {}
func operator+(left copy S, right i8) {}
func Use(left copy S, right i16) { left + right; })");

  ExpectWarning(2, 42, "implicit integer conversion from 'i16' to 'i8' may truncate value", 5);
}

TEST_F(SemaTest, KeepsCompleteOperatorInterfaceAfterFunctionBodyError) {
  Analyze(R"(trivial struct S {}
func operator+(left copy S, right copy S) { var bad i32; bad; }
func Use(left copy S, right copy S) { left + right; })");

  ExpectError(1, 57, "use of uninitialized variable 'bad'", 3);
}

TEST_F(SemaTest, DiagnosesUninitializedOperandAfterOperatorCallFormation) {
  Analyze(R"(trivial struct S { value i32; }
func operator+(left copy S, right copy S) {}
func Use(right copy S) {
  var left S;
  left + right;
})");

  ExpectError(4, 2, "use of uninitialized variable 'left'", 4);
}

TEST_F(SemaTest, KeepsOrdinaryAssignmentOutsideBaseValueSlicing) {
  Analyze(R"(trivial struct Base {}
trivial struct Derived : Base {}
func Use(base mut Base, derived mut Derived) {
  base = derived;
})");
  ExpectError(3, 9, "cannot assign to target: no implicit conversion from 'Derived' to 'Base'", 7);
}

// Return conversions and result boundaries.

TEST_F(SemaTest, AppliesReferenceBindingRulesToTailReturns) {
  Analyze(R"(func bad_move(value i32) move i32 { value }
func bad_mut() mut i32 { 1 }
func bad_copy(value i32) copy u8 { value })");

  ExpectError(0, 36, "cannot initialize return object: reference type 'move i32' cannot bind to lvalue of type 'i32'",
              5);
  ExpectError(1, 25,
              "cannot initialize return object: reference type 'mut i32' cannot bind to pure rvalue of type 'i32'", 1);
  ExpectError(2, 35, "cannot initialize return object: reference type 'copy u8' cannot bind to a value of type 'i32'",
              5);
}

TEST_F(SemaTest, AppliesReferenceBindingRulesToReturnStatements) {
  Analyze(R"(func return_mut(value i32) mut i32 { return value; }
func return_copy() copy i32 { return 1; }
func return_move(value i32) move i32 { return move value; })");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-FunctionDecl {{address}} <test.cw:1:1, col:53> return_mut 'func (i32) mut i32'
| |-ParmVarDecl {{address:return_mut_parameter}} <col:17, col:26> value 'i32'
| | `-BuiltinType {{address}} <col:23, col:26> 'i32'
| |-ReturnVarDecl {{address:return_mut_result}} <col:28, col:35> 'mut i32'
| | `-ReferenceType {{address}} <col:28, col:35> 'mut'
| |   `-BuiltinType {{address}} <col:32, col:35> 'i32'
| `-CompoundStmt {{address}} <col:36, col:53>
|   `-ReturnStmt {{address}} <col:38, col:51>
|     `-ImplicitResultInitializationExpr {{address}} <col:45, col:50> 'void' ReturnVar {{address:return_mut_result}} 'mut i32'
|       `-DeclRefExpr {{address}} <col:45, col:50> 'i32' lvalue ParmVar {{address:return_mut_parameter}} 'value' 'i32'
|-FunctionDecl {{address}} <line:2:1, col:42> return_copy 'func () copy i32'
| |-ReturnVarDecl {{address:return_copy_result}} <col:20, col:28> 'copy i32'
| | `-ReferenceType {{address}} <col:20, col:28> 'copy'
| |   `-BuiltinType {{address}} <col:25, col:28> 'i32'
| `-CompoundStmt {{address}} <col:29, col:42>
|   `-ReturnStmt {{address}} <col:31, col:40>
|     `-ImplicitResultInitializationExpr {{address}} <col:38, col:39> 'void' ReturnVar {{address:return_copy_result}} 'copy i32'
|       `-ImplicitCastExpr {{address}} <col:38, col:39> 'const i32' move-lvalue <NoOp>
|         `-MaterializeTemporaryExpr {{address}} <col:38, col:39> 'i32' move-lvalue
|           `-ImplicitCastExpr {{address}} <col:38, col:39> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
|             `-IntegerLiteral {{address}} <col:38, col:39> 'comptime_int' 1
`-FunctionDecl {{address}} <line:3:1, col:60> return_move 'func (i32) move i32'
  |-ParmVarDecl {{address:return_move_parameter}} <col:18, col:27> value 'i32'
  | `-BuiltinType {{address}} <col:24, col:27> 'i32'
  |-ReturnVarDecl {{address:return_move_result}} <col:29, col:37> 'move i32'
  | `-ReferenceType {{address}} <col:29, col:37> 'move'
  |   `-BuiltinType {{address}} <col:34, col:37> 'i32'
  `-CompoundStmt {{address}} <col:38, col:60>
    `-ReturnStmt {{address}} <col:40, col:58>
      `-ImplicitResultInitializationExpr {{address}} <col:47, col:57> 'void' ReturnVar {{address:return_move_result}} 'move i32'
        `-UnaryOperator {{address}} <col:47, col:57> 'i32' move-lvalue 'move'
          `-DeclRefExpr {{address}} <col:52, col:57> 'i32' lvalue ParmVar {{address:return_move_parameter}} 'value' 'i32')");
}

TEST_F(SemaTest, AdaptsReturnExpressionsToCanonicalTypes) {
  Analyze("func f(value i16) i32 { return value; }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:40> f 'func (i16) i32'
  |-ParmVarDecl {{address:parameter}} <col:8, col:17> value 'i16'
  | `-BuiltinType {{address}} <col:14, col:17> 'i16'
  |-ReturnVarDecl {{address:return_object}} <col:19, col:22> 'i32'
  | `-BuiltinType {{address}} <col:19, col:22> 'i32'
  `-CompoundStmt {{address}} <col:23, col:40>
    `-ReturnStmt {{address}} <col:25, col:38>
      `-ImplicitResultInitializationExpr {{address}} <col:32, col:37> 'void' ReturnVar {{address:return_object}} 'i32'
        `-ImplicitCastExpr {{address}} <col:32, col:37> 'i32' pure-rvalue <IntegerToInteger>
          `-ImplicitCastExpr {{address}} <col:32, col:37> 'i16' pure-rvalue <LValueToRValue>
            `-DeclRefExpr {{address}} <col:32, col:37> 'i16' lvalue ParmVar {{address:parameter}} 'value' 'i16')");
}

TEST_F(SemaTest, MaterializesReturnIntegerBeforeTargetConversion) {
  Analyze("func f() i64 { return 1; }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:27> f 'func () i64'
  |-ReturnVarDecl {{address:return_object}} <col:10, col:13> 'i64'
  | `-BuiltinType {{address}} <col:10, col:13> 'i64'
  `-CompoundStmt {{address}} <col:14, col:27>
    `-ReturnStmt {{address}} <col:16, col:25>
      `-ImplicitResultInitializationExpr {{address}} <col:23, col:24> 'void' ReturnVar {{address:return_object}} 'i64'
        `-ImplicitCastExpr {{address}} <col:23, col:24> 'i64' pure-rvalue <IntegerToInteger>
          `-ImplicitCastExpr {{address}} <col:23, col:24> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
            `-IntegerLiteral {{address}} <col:23, col:24> 'comptime_int' 1)");
}

TEST_F(SemaTest, KeepsCurrentEmptyReturnBehavior) {
  Analyze(R"(struct S {}
func f() i32 { return; }
ctor S() { return; }
dtor S() { return; })");

  ExpectError(1, 15, "function return object is not initialized on this path", 7);
}

TEST_F(SemaTest, ReportsReturnConversionWarnings) {
  Analyze(R"(func integer(value i64) i8 { return value; }
func intfloat(value i64) f32 { return value; }
func floatnarrow(value f64) f32 { return value; }
func floatint(value f32) i32 { return value; })");

  ExpectWarning(0, 36, "implicit integer conversion from 'i64' to 'i8' may truncate value", 5);
  ExpectWarning(1, 38, "implicit conversion from 'i64' to 'f32' may lose integer precision", 5);
  ExpectWarning(2, 41, "implicit floating-point conversion from 'f64' to 'f32' may lose precision or range", 5);
  ExpectWarning(3, 38, "implicit conversion from 'f32' to 'i32' may lose fractional value or exceed integer range", 5);
}

TEST_F(SemaTest, RejectsIncompatibleReturnsWithoutPoisoningExpressions) {
  Analyze("func f() i32 { return true; return 1; }");

  ExpectError(0, 22, "cannot initialize return object: no implicit conversion from 'bool' to 'i32'", 4);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, col:40> f 'func () i32' contains-errors
  |-ReturnVarDecl {{address:return_object}} <col:10, col:13> 'i32'
  | `-BuiltinType {{address}} <col:10, col:13> 'i32'
  `-CompoundStmt {{address}} <col:14, col:40> contains-errors
    |-ReturnStmt {{address}} <col:16, col:28> contains-errors
    | `-ImplicitResultInitializationExpr {{address}} <col:23, col:27> 'void' ReturnVar {{address:return_object}} 'i32' contains-errors
    |   `-BoolLiteral {{address}} <col:23, col:27> 'bool' pure-rvalue true
    `-ReturnStmt {{address}} <col:29, col:38>
      `-ImplicitResultInitializationExpr {{address}} <col:36, col:37> 'void' ReturnVar {{address:return_object}} 'i32'
        `-ImplicitCastExpr {{address}} <col:36, col:37> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
          `-IntegerLiteral {{address}} <col:36, col:37> 'comptime_int' 1)");
}

TEST_F(SemaTest, ReportsStructuralReturnErrorsAfterAnalyzingExpressions) {
  Analyze(R"(func valid() { return; }
func value() { return 1; }
func failed() { return missing; })");

  ExpectError(1, 15, "void function cannot return a value", 0);
  ExpectError(2, 23, "use of undeclared identifier 'missing'", 7);
  ExpectError(2, 16, "void function cannot return a value", 0);
}

TEST_F(SemaTest, KeepsVoidReturnExpressionUnpoisoned) {
  Analyze("func f() { return 1; }");

  ExpectError(0, 11, "void function cannot return a value", 0);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, col:23> f 'func () void' contains-errors
  `-CompoundStmt {{address}} <col:10, col:23> contains-errors
    `-ReturnStmt {{address}} <col:12, col:21> contains-errors
      `-ImplicitCastExpr {{address}} <col:19, col:20> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
        `-IntegerLiteral {{address}} <col:19, col:20> 'comptime_int' 1)");
}

TEST_F(SemaTest, SuppressesReturnTypeDiagnosticsAfterExpressionFailure) {
  Analyze("func f() i32 { return missing; return 1; }");

  ExpectError(0, 22, "use of undeclared identifier 'missing'", 7);
}

TEST_F(SemaTest, EnforcesVariableInitializerReturnBoundary) {
  Analyze(R"(func f() i32 {
  {
    return 1;
  }
  while false {
    return 1;
  }
  var value i32 := {
    if true {
      return missing;
    }
    return 1.0;
    0
  }
  return 2;
})");

  ExpectError(9, 13, "use of undeclared identifier 'missing'", 7);
  ExpectError(9, 6, "return is not allowed in a variable initializer block", 0);
  ExpectError(11, 4, "return is not allowed in a variable initializer block", 0);
}

TEST_F(SemaTest, KeepsVariableBlockReturnExpressionUnpoisoned) {
  Analyze("func f() { var value i32 := { return true; 0 } }");

  ExpectError(0, 30, "return is not allowed in a variable initializer block", 0);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, col:49> f 'func () void' contains-errors
  `-CompoundStmt {{address}} <col:10, col:49> contains-errors
    `-DeclStmt {{address}} <col:12, col:47> contains-errors
      `-VarGroupDecl {{address}} <col:12, col:47> contains-errors
        |-VarDecl {{address:value}} <col:16, col:25> value 'i32'
        | `-BuiltinType {{address}} <col:22, col:25> 'i32'
        `-CompoundStmt {{address}} <col:29, col:47> contains-errors
          |-ReturnStmt {{address}} <col:31, col:43> contains-errors
          | `-BoolLiteral {{address}} <col:38, col:42> 'bool' pure-rvalue true
          `-ImplicitResultInitializationExpr {{address}} <col:44, col:45> 'void' Var {{address:value}} 'value' 'i32'
            `-ImplicitCastExpr {{address}} <col:44, col:45> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
              `-IntegerLiteral {{address}} <col:44, col:45> 'comptime_int' 0)");
}

// Local declarations, lexical scope, and initializers.

TEST_F(SemaTest, EnforcesSupportedLocalReferenceKindsBindingAndMoveOperands) {
  Analyze(R"(func local(value i32) {
  var fixed const i32 := value;
  var read copy i32 := value;
  var transfer move i32 := move value;
  var missing mut i32;
  var block mut i32 := { value }
  var wrong mut i32 := fixed;
  move fixed;
  move 1;
})");

  ExpectError(2, 11, "local 'copy i32' reference variables are not currently supported", 8);
  ExpectError(3, 15, "local 'move i32' reference variables are not currently supported", 8);
  ExpectError(6, 23,
              "cannot initialize variable 'wrong': binding a reference of type 'mut i32' to a value of type 'const "
              "i32' would discard const",
              5);
  ExpectError(8, 2, "'move' requires an lvalue of object type, not 'i32'", 6);
}

TEST_F(SemaTest, BindsForwardGlobalAfterLocalDeclarationPoint) {
  Analyze(R"(func f() { g; var x i32 := x; x; } var g i32 := 0;)");

  ExpectError(0, 27, "use of undeclared identifier 'x'", 1);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-FunctionDecl {{address}} <test.cw:1:1, col:35> f 'func () void' contains-errors
| `-CompoundStmt {{address}} <col:10, col:35> contains-errors
|   |-ExprStmt {{address}} <col:12, col:14>
|   | `-DeclRefExpr {{address}} <col:12, col:13> 'i32' lvalue Var {{address:global}} 'g' 'i32'
|   |-DeclStmt {{address}} <col:15, col:30> contains-errors
|   | `-VarGroupDecl {{address}} <col:15, col:30> contains-errors
|   |   |-VarDecl {{address:local}} <col:19, col:24> x 'i32'
|   |   | `-BuiltinType {{address}} <col:21, col:24> 'i32'
|   |   `-DeclRefExpr {{address}} <col:28, col:29> 'x' contains-errors
|   `-ExprStmt {{address}} <col:31, col:33>
|     `-DeclRefExpr {{address}} <col:31, col:32> 'i32' lvalue Var {{address:local}} 'x' 'i32'
`-VarGroupDecl {{address}} <col:36, col:51>
  |-VarDecl {{address:global}} <col:40, col:45> g 'i32'
  | `-BuiltinType {{address}} <col:42, col:45> 'i32'
  `-ImplicitCastExpr {{address}} <col:49, col:50> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    `-IntegerLiteral {{address}} <col:49, col:50> 'comptime_int' 0)");
}

TEST_F(SemaTest, IntroducesVariableGroupNamesAfterAllInitializers) {
  Analyze(R"(func f() { var a i32, b i32 := b, a; a; b; })");

  ExpectError(0, 31, "use of undeclared identifier 'b'", 1);
  ExpectError(0, 34, "use of undeclared identifier 'a'", 1);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, col:45> f 'func () void' contains-errors
  `-CompoundStmt {{address}} <col:10, col:45> contains-errors
    |-DeclStmt {{address}} <col:12, col:37> contains-errors
    | `-VarGroupDecl {{address}} <col:12, col:37> contains-errors
    |   |-VarDecl {{address:a}} <col:16, col:21> a 'i32'
    |   | `-BuiltinType {{address}} <col:18, col:21> 'i32'
    |   |-VarDecl {{address:b}} <col:23, col:28> b 'i32'
    |   | `-BuiltinType {{address}} <col:25, col:28> 'i32'
    |   |-DeclRefExpr {{address}} <col:32, col:33> 'b' contains-errors
    |   `-DeclRefExpr {{address}} <col:35, col:36> 'a' contains-errors
    |-ExprStmt {{address}} <col:38, col:40>
    | `-DeclRefExpr {{address}} <col:38, col:39> 'i32' lvalue Var {{address:a}} 'a' 'i32'
    `-ExprStmt {{address}} <col:41, col:43>
      `-DeclRefExpr {{address}} <col:41, col:42> 'i32' lvalue Var {{address:b}} 'b' 'i32')");
}

TEST_F(SemaTest, KeepsFirstVariableAfterFunctionScopeRedefinition) {
  Analyze("func f(x i32) { var x i32; x; }");

  ExpectError(0, 20, "redefinition of variable 'x'", 1);
  ExpectNote(0, 7, "previous declaration is here", 1);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, col:32> f 'func (i32) void' contains-errors
  |-ParmVarDecl {{address:parameter}} <col:8, col:13> x 'i32'
  | `-BuiltinType {{address}} <col:10, col:13> 'i32'
  `-CompoundStmt {{address}} <col:15, col:32> contains-errors
    |-DeclStmt {{address}} <col:17, col:27> contains-errors
    | `-VarGroupDecl {{address}} <col:17, col:27> contains-errors
    |   `-VarDecl {{address:duplicate}} <col:21, col:26> x 'i32' contains-errors
    |     `-BuiltinType {{address}} <col:23, col:26> 'i32'
    `-ExprStmt {{address}} <col:28, col:30>
      `-DeclRefExpr {{address}} <col:28, col:29> 'i32' lvalue ParmVar {{address:parameter}} 'x' 'i32')");
}

TEST_F(SemaTest, KeepsFirstParameterAcrossParameterAndReturnRedefinitions) {
  Analyze("func f(x i32, x i32) var x i32 { x; }");

  ExpectError(0, 14, "redefinition of variable 'x'", 1);
  ExpectNote(0, 7, "previous declaration is here", 1);
  ExpectError(0, 25, "redefinition of variable 'x'", 1);
  ExpectNote(0, 7, "previous declaration is here", 1);
  ExpectError(0, 31, "return object 'x' is not initialized on this path", 6);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, col:38> f 'func (i32, i32) i32' contains-errors
  |-ParmVarDecl {{address:first}} <col:8, col:13> x 'i32'
  | `-BuiltinType {{address}} <col:10, col:13> 'i32'
  |-ParmVarDecl {{address}} <col:15, col:20> x 'i32' contains-errors
  | `-BuiltinType {{address}} <col:17, col:20> 'i32'
  |-ReturnVarDecl {{address}} <col:22, col:31> x 'i32' contains-errors
  | `-BuiltinType {{address}} <col:28, col:31> 'i32'
  `-CompoundStmt {{address}} <col:32, col:38> contains-errors
    `-ExprStmt {{address}} <col:34, col:36>
      `-DeclRefExpr {{address}} <col:34, col:35> 'i32' lvalue ParmVar {{address:first}} 'x' 'i32')");
}

TEST_F(SemaTest, BindsNamedReturnVariableThroughoutExpressionTrees) {
  Analyze("func f(a i32) var r i32 { -a; a + r; true ? r : a; a; a[r]; f(a); return r; }");

  ExpectError(0, 54, "subscripted expression must have array type, not 'i32'", 1);
  ExpectError(0, 34, "use of uninitialized variable 'r'", 1);
  ExpectError(0, 44, "use of uninitialized variable 'r'", 1);
  ExpectError(0, 56, "use of uninitialized variable 'r'", 1);
  ExpectError(0, 73, "use of uninitialized variable 'r'", 1);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address:function}} <test.cw:1:1, col:78> f 'func (i32) i32' contains-errors
  |-ParmVarDecl {{address:parameter}} <col:8, col:13> a 'i32'
  | `-BuiltinType {{address}} <col:10, col:13> 'i32'
  |-ReturnVarDecl {{address:return}} <col:15, col:24> r 'i32'
  | `-BuiltinType {{address}} <col:21, col:24> 'i32'
  `-CompoundStmt {{address}} <col:25, col:78> contains-errors
    |-ExprStmt {{address}} <col:27, col:30>
    | `-UnaryOperator {{address}} <col:27, col:29> 'i32' pure-rvalue '-'
    |   `-ImplicitCastExpr {{address}} <col:28, col:29> 'i32' pure-rvalue <LValueToRValue>
    |     `-DeclRefExpr {{address}} <col:28, col:29> 'i32' lvalue ParmVar {{address:parameter}} 'a' 'i32'
    |-ExprStmt {{address}} <col:31, col:37> contains-errors
    | `-BinaryOperator {{address}} <col:31, col:36> 'i32' pure-rvalue '+' contains-errors
    |   |-ImplicitCastExpr {{address}} <col:31, col:32> 'i32' pure-rvalue <LValueToRValue>
    |   | `-DeclRefExpr {{address}} <col:31, col:32> 'i32' lvalue ParmVar {{address:parameter}} 'a' 'i32'
    |   `-ImplicitCastExpr {{address}} <col:35, col:36> 'i32' pure-rvalue <LValueToRValue> contains-errors
    |     `-DeclRefExpr {{address}} <col:35, col:36> 'i32' lvalue ReturnVar {{address:return}} 'r' 'i32' contains-errors
    |-ExprStmt {{address}} <col:38, col:51> contains-errors
    | `-ConditionalOperator {{address}} <col:38, col:50> 'i32' lvalue contains-errors
    |   |-BoolLiteral {{address}} <col:38, col:42> 'bool' pure-rvalue true
    |   |-DeclRefExpr {{address}} <col:45, col:46> 'i32' lvalue ReturnVar {{address:return}} 'r' 'i32' contains-errors
    |   `-DeclRefExpr {{address}} <col:49, col:50> 'i32' lvalue ParmVar {{address:parameter}} 'a' 'i32'
    |-ExprStmt {{address}} <col:52, col:54>
    | `-DeclRefExpr {{address}} <col:52, col:53> 'i32' lvalue ParmVar {{address:parameter}} 'a' 'i32'
    |-ExprStmt {{address}} <col:55, col:60> contains-errors
    | `-SubscriptExpr {{address}} <col:55, col:59> contains-errors
    |   |-DeclRefExpr {{address}} <col:55, col:56> 'i32' lvalue ParmVar {{address:parameter}} 'a' 'i32'
    |   `-DeclRefExpr {{address}} <col:57, col:58> 'i32' lvalue ReturnVar {{address:return}} 'r' 'i32' contains-errors
    |-ExprStmt {{address}} <col:61, col:66>
    | `-CallExpr {{address}} <col:61, col:65> 'i32' pure-rvalue
    |   |-DeclRefExpr {{address}} <col:61, col:62> 'func (i32) i32' Function {{address:function}} 'f' 'func (i32) i32'
    |   `-ImplicitCastExpr {{address}} <col:63, col:64> 'i32' pure-rvalue <LValueToRValue>
    |     `-DeclRefExpr {{address}} <col:63, col:64> 'i32' lvalue ParmVar {{address:parameter}} 'a' 'i32'
    `-ReturnStmt {{address}} <col:67, col:76> contains-errors
      `-ImplicitResultInitializationExpr {{address}} <col:74, col:75> 'void' ReturnVar {{address:return}} 'r' 'i32' contains-errors
        `-ImplicitCastExpr {{address}} <col:74, col:75> 'i32' pure-rvalue <LValueToRValue> contains-errors
          `-DeclRefExpr {{address}} <col:74, col:75> 'i32' lvalue ReturnVar {{address:return}} 'r' 'i32' contains-errors)");
}

TEST_F(SemaTest, PreservesNameLookupErrorsAndFunctionShadowing) {
  Analyze(R"(func target() {}
func caller(target i32) { target(); missing(missing_arg); })");

  ExpectError(1, 26, "expression of type 'i32' is not callable", 8);
  ExpectError(1, 36, "use of undeclared identifier 'missing'", 7);
  ExpectError(1, 44, "use of undeclared identifier 'missing_arg'", 11);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-FunctionDecl {{address}} <test.cw:1:1, col:17> target 'func () void'
| `-CompoundStmt {{address}} <col:15, col:17>
`-FunctionDecl {{address}} <line:2:1, col:60> caller 'func (i32) void' contains-errors
  |-ParmVarDecl {{address:parameter}} <col:13, col:23> target 'i32'
  | `-BuiltinType {{address}} <col:20, col:23> 'i32'
  `-CompoundStmt {{address}} <col:25, col:60> contains-errors
    |-ExprStmt {{address}} <col:27, col:36> contains-errors
    | `-CallExpr {{address}} <col:27, col:35> contains-errors
    |   `-DeclRefExpr {{address}} <col:27, col:33> 'i32' lvalue ParmVar {{address:parameter}} 'target' 'i32'
    `-ExprStmt {{address}} <col:37, col:58> contains-errors
      `-CallExpr {{address}} <col:37, col:57> contains-errors
        |-DeclRefExpr {{address}} <col:37, col:44> 'missing' contains-errors
        `-DeclRefExpr {{address}} <col:45, col:56> 'missing_arg' contains-errors)");
}

TEST_F(SemaTest, ManagesIfAndWhileBlockScopes) {
  Analyze("func f(x bool) { if x { var y i32; y; } while x { x; } y; }");

  ExpectError(0, 55, "use of undeclared identifier 'y'", 1);
  ExpectError(0, 35, "use of uninitialized variable 'y'", 1);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, col:60> f 'func (bool) void' contains-errors
  |-ParmVarDecl {{address:parameter}} <col:8, col:14> x 'bool'
  | `-BuiltinType {{address}} <col:10, col:14> 'bool'
  `-CompoundStmt {{address}} <col:16, col:60> contains-errors
    |-IfStmt {{address}} <col:18, col:40> contains-errors
    | |-ImplicitCastExpr {{address}} <col:21, col:22> 'bool' pure-rvalue <LValueToRValue>
    | | `-DeclRefExpr {{address}} <col:21, col:22> 'bool' lvalue ParmVar {{address:parameter}} 'x' 'bool'
    | `-CompoundStmt {{address}} <col:23, col:40> contains-errors
    |   |-DeclStmt {{address}} <col:25, col:35>
    |   | `-VarGroupDecl {{address}} <col:25, col:35>
    |   |   `-VarDecl {{address:local}} <col:29, col:34> y 'i32'
    |   |     `-BuiltinType {{address}} <col:31, col:34> 'i32'
    |   `-ExprStmt {{address}} <col:36, col:38> contains-errors
    |     `-DeclRefExpr {{address}} <col:36, col:37> 'i32' lvalue Var {{address:local}} 'y' 'i32' contains-errors
    |-WhileStmt {{address}} <col:41, col:55>
    | |-ImplicitCastExpr {{address}} <col:47, col:48> 'bool' pure-rvalue <LValueToRValue>
    | | `-DeclRefExpr {{address}} <col:47, col:48> 'bool' lvalue ParmVar {{address:parameter}} 'x' 'bool'
    | `-CompoundStmt {{address}} <col:49, col:55>
    |   `-ExprStmt {{address}} <col:51, col:53>
    |     `-DeclRefExpr {{address}} <col:51, col:52> 'bool' lvalue ParmVar {{address:parameter}} 'x' 'bool'
    `-ExprStmt {{address}} <col:56, col:58> contains-errors
      `-DeclRefExpr {{address}} <col:56, col:57> 'y' contains-errors)");
}

TEST_F(SemaTest, DiagnosesTypeNamesOutsideCalleePositions) {
  Analyze(R"(struct S {}
ctor S(value i32) {} dtor S() {}
func use(pointer *S) {
  S;
  S(S);
  ctor (S) S(1);
  ctor (pointer) S(S);
})");

  ExpectError(3, 2, "type 'S' cannot be used as an object expression", 1);
  ExpectError(4, 4, "type 'S' cannot be used as an object expression", 1);
  ExpectError(5, 8, "type 'S' cannot be used as an object expression", 1);
  ExpectError(6, 19, "type 'S' cannot be used as an object expression", 1);
}

TEST_F(SemaTest, AllowsVariablesToShadowTypesAndFunctions) {
  Analyze("trivial struct S {} func target() {} func f() { var S i32; S; { var target i32; target; } target(); }");

  ExpectError(0, 59, "use of uninitialized variable 'S'", 1);
  ExpectError(0, 80, "use of uninitialized variable 'target'", 6);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-StructDecl {{address}} <test.cw:1:1, col:20> S trivial
|-FunctionDecl {{address:target}} <col:21, col:37> target 'func () void'
| `-CompoundStmt {{address}} <col:35, col:37>
`-FunctionDecl {{address}} <col:38, col:102> f 'func () void' contains-errors
  `-CompoundStmt {{address}} <col:47, col:102> contains-errors
    |-DeclStmt {{address}} <col:49, col:59>
    | `-VarGroupDecl {{address}} <col:49, col:59>
    |   `-VarDecl {{address:type_shadow}} <col:53, col:58> S 'i32'
    |     `-BuiltinType {{address}} <col:55, col:58> 'i32'
    |-ExprStmt {{address}} <col:60, col:62> contains-errors
    | `-DeclRefExpr {{address}} <col:60, col:61> 'i32' lvalue Var {{address:type_shadow}} 'S' 'i32' contains-errors
    |-CompoundStmt {{address}} <col:63, col:90> contains-errors
    | |-DeclStmt {{address}} <col:65, col:80>
    | | `-VarGroupDecl {{address}} <col:65, col:80>
    | |   `-VarDecl {{address:function_shadow}} <col:69, col:79> target 'i32'
    | |     `-BuiltinType {{address}} <col:76, col:79> 'i32'
    | `-ExprStmt {{address}} <col:81, col:88> contains-errors
    |   `-DeclRefExpr {{address}} <col:81, col:87> 'i32' lvalue Var {{address:function_shadow}} 'target' 'i32' contains-errors
    `-ExprStmt {{address}} <col:91, col:100>
      `-CallExpr {{address}} <col:91, col:99> 'void'
        `-DeclRefExpr {{address}} <col:91, col:97> 'func () void' Function {{address:target}} 'target' 'func () void')");
}

TEST_F(SemaTest, InfersLocalTypeWhileLeavingFailedExplicitTypeEmpty) {
  Analyze("func f() { var inferred := 1; inferred; var failed Missing; failed; }");

  ExpectError(0, 51, "unknown type 'Missing'", 7);
  ExpectError(0, 60, "use of uninitialized variable 'failed'", 6);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, col:70> f 'func () void' contains-errors
  `-CompoundStmt {{address}} <col:10, col:70> contains-errors
    |-DeclStmt {{address}} <col:12, col:30>
    | `-VarGroupDecl {{address}} <col:12, col:30>
    |   |-VarDecl {{address:inferred}} <col:16, col:24> inferred 'i32'
    |   `-ImplicitCastExpr {{address}} <col:28, col:29> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    |     `-IntegerLiteral {{address}} <col:28, col:29> 'comptime_int' 1
    |-ExprStmt {{address}} <col:31, col:40>
    | `-DeclRefExpr {{address}} <col:31, col:39> 'i32' lvalue Var {{address:inferred}} 'inferred' 'i32'
    |-DeclStmt {{address}} <col:41, col:60> contains-errors
    | `-VarGroupDecl {{address}} <col:41, col:60> contains-errors
    |   `-VarDecl {{address:failed}} <col:45, col:59> failed contains-errors
    |     `-NamedType {{address}} <col:52, col:59> 'Missing' contains-errors
    `-ExprStmt {{address}} <col:61, col:68> contains-errors
      `-DeclRefExpr {{address}} <col:61, col:67> Var {{address:failed}} 'failed' contains-errors)");
}

TEST_F(SemaTest, InfersEachVariableInAGroupFromItsCorrespondingInitializer) {
  Analyze("func f() { var small, large := 1, 2147483648; }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:48> f 'func () void'
  `-CompoundStmt {{address}} <col:10, col:48>
    `-DeclStmt {{address}} <col:12, col:46>
      `-VarGroupDecl {{address}} <col:12, col:46>
        |-VarDecl {{address}} <col:16, col:21> small 'i32'
        |-VarDecl {{address}} <col:23, col:28> large 'i64'
        |-ImplicitCastExpr {{address}} <col:32, col:33> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
        | `-IntegerLiteral {{address}} <col:32, col:33> 'comptime_int' 1
        `-ImplicitCastExpr {{address}} <col:35, col:45> 'i64' pure-rvalue <ComptimeIntegerMaterialization>
          `-IntegerLiteral {{address}} <col:35, col:45> 'comptime_int' 2147483648)");
}

TEST_F(SemaTest, AppliesValueReadsToNonNumericInitializers) {
  Analyze(R"(trivial struct S {}
func f(value S, pointer *S, callback *func () void) {
var value_copy S := value;
var pointer_copy *S := pointer;
var callback_copy *func () void := callback;
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address}} <test.cw:1:1, col:20> S trivial
`-FunctionDecl {{address}} <line:2:1, line:6:2> f 'func (S, *S, *func () void) void'
  |-ParmVarDecl {{address:value}} <line:2:8, col:15> value 'S'
  | `-NamedType {{address}} <col:14, col:15> 'S'
  |-ParmVarDecl {{address:pointer}} <col:17, col:27> pointer '*S'
  | `-PointerType {{address}} <col:25, col:27>
  |   `-NamedType {{address}} <col:26, col:27> 'S'
  |-ParmVarDecl {{address:callback}} <col:29, col:51> callback '*func () void'
  | `-PointerType {{address}} <col:38, col:51>
  |   `-FunctionType {{address}} <col:39, col:51>
  |     `-BuiltinType {{address}} <col:47, col:51> 'void'
  `-CompoundStmt {{address}} <col:53, line:6:2>
    |-DeclStmt {{address}} <line:3:1, col:27>
    | `-VarGroupDecl {{address}} <col:1, col:27>
    |   |-VarDecl {{address}} <col:5, col:17> value_copy 'S'
    |   | `-NamedType {{address}} <col:16, col:17> 'S'
    |   `-ImplicitCastExpr {{address}} <col:21, col:26> 'S' pure-rvalue <LValueToRValue>
    |     `-DeclRefExpr {{address}} <col:21, col:26> 'S' lvalue ParmVar {{address:value}} 'value' 'S'
    |-DeclStmt {{address}} <line:4:1, col:32>
    | `-VarGroupDecl {{address}} <col:1, col:32>
    |   |-VarDecl {{address}} <col:5, col:20> pointer_copy '*S'
    |   | `-PointerType {{address}} <col:18, col:20>
    |   |   `-NamedType {{address}} <col:19, col:20> 'S'
    |   `-ImplicitCastExpr {{address}} <col:24, col:31> '*S' pure-rvalue <LValueToRValue>
    |     `-DeclRefExpr {{address}} <col:24, col:31> '*S' lvalue ParmVar {{address:pointer}} 'pointer' '*S'
    `-DeclStmt {{address}} <line:5:1, col:45>
      `-VarGroupDecl {{address}} <col:1, col:45>
        |-VarDecl {{address}} <col:5, col:32> callback_copy '*func () void'
        | `-PointerType {{address}} <col:19, col:32>
        |   `-FunctionType {{address}} <col:20, col:32>
        |     `-BuiltinType {{address}} <col:28, col:32> 'void'
        `-ImplicitCastExpr {{address}} <col:36, col:44> '*func () void' pure-rvalue <LValueToRValue>
          `-DeclRefExpr {{address}} <col:36, col:44> '*func () void' lvalue ParmVar {{address:callback}} 'callback' '*func () void')");
}

TEST_F(SemaTest, RejectsIncompatibleExplicitInitializerTypes) {
  Analyze(R"(trivial struct A {}
trivial struct B {}
func f(integer i32, size usize, single f32, pointer *B, value B, callback *func (u32) void) {
var boolean bool := integer;
var number i32 := true;
var fixed i32 := size;
var sized usize := integer;
var floating f32 := size;
var size_from_float usize := single;
var pointer_copy *A := pointer;
var value_copy A := value;
var callback_copy *func (i32) void := callback;
})");

  ExpectError(3, 20, "cannot initialize variable 'boolean': no implicit conversion from 'i32' to 'bool'", 7);
  ExpectError(4, 18, "cannot initialize variable 'number': no implicit conversion from 'bool' to 'i32'", 4);
  ExpectError(5, 17, "cannot initialize variable 'fixed': no implicit conversion from 'usize' to 'i32'", 4);
  ExpectError(6, 19, "cannot initialize variable 'sized': no implicit conversion from 'i32' to 'usize'", 7);
  ExpectError(7, 20, "cannot initialize variable 'floating': no implicit conversion from 'usize' to 'f32'", 4);
  ExpectError(8, 29, "cannot initialize variable 'size_from_float': no implicit conversion from 'f32' to 'usize'", 6);
  ExpectError(9, 23, "cannot initialize variable 'pointer_copy': no implicit conversion from '*B' to '*A'", 7);
  ExpectError(10, 20, "cannot initialize variable 'value_copy': no implicit conversion from 'B' to 'A'", 5);
  ExpectError(11, 38,
              "cannot initialize variable 'callback_copy': no implicit conversion from '*func (u32) void' to '*func "
              "(i32) void'",
              8);
}

TEST_F(SemaTest, RecoversInitializerGroupsInDiagnosticSourceOrder) {
  Analyze(R"(func f() {
var bad bool, unresolved bool, good bool := 1, missing, true;
bad;
unresolved;
good;
})");

  ExpectError(1, 44, "cannot initialize variable 'bad': no implicit conversion from 'i32' to 'bool'", 1);
  ExpectError(1, 47, "use of undeclared identifier 'missing'", 7);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, line:6:2> f 'func () void' contains-errors
  `-CompoundStmt {{address}} <line:1:10, line:6:2> contains-errors
    |-DeclStmt {{address}} <line:2:1, col:62> contains-errors
    | `-VarGroupDecl {{address}} <col:1, col:62> contains-errors
    |   |-VarDecl {{address:bad}} <col:5, col:13> bad 'bool'
    |   | `-BuiltinType {{address}} <col:9, col:13> 'bool'
    |   |-VarDecl {{address:unresolved}} <col:15, col:30> unresolved 'bool'
    |   | `-BuiltinType {{address}} <col:26, col:30> 'bool'
    |   |-VarDecl {{address:good}} <col:32, col:41> good 'bool'
    |   | `-BuiltinType {{address}} <col:37, col:41> 'bool'
    |   |-ImplicitCastExpr {{address}} <col:45, col:46> 'i32' pure-rvalue <ComptimeIntegerMaterialization> contains-errors
    |   | `-IntegerLiteral {{address}} <col:45, col:46> 'comptime_int' 1
    |   |-DeclRefExpr {{address}} <col:48, col:55> 'missing' contains-errors
    |   `-BoolLiteral {{address}} <col:57, col:61> 'bool' pure-rvalue true
    |-ExprStmt {{address}} <line:3:1, col:5>
    | `-DeclRefExpr {{address}} <col:1, col:4> 'bool' lvalue Var {{address:bad}} 'bad' 'bool'
    |-ExprStmt {{address}} <line:4:1, col:12>
    | `-DeclRefExpr {{address}} <col:1, col:11> 'bool' lvalue Var {{address:unresolved}} 'unresolved' 'bool'
    `-ExprStmt {{address}} <line:5:1, col:6>
      `-DeclRefExpr {{address}} <col:1, col:5> 'bool' lvalue Var {{address:good}} 'good' 'bool')");
}

TEST_F(SemaTest, RecoversPairedPrefixAfterInitializerCountMismatch) {
  Analyze(R"(func f() {
var a, b i32 := 1;
var c := 1, 2;
})");

  ExpectError(1, 7, "variable count does not match initializer count", 1);
  ExpectError(2, 12, "variable count does not match initializer count", 1);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, line:4:2> f 'func () void' contains-errors
  `-CompoundStmt {{address}} <line:1:10, line:4:2> contains-errors
    |-DeclStmt {{address}} <line:2:1, col:19> contains-errors
    | `-VarGroupDecl {{address}} <col:1, col:19> contains-errors
    |   |-VarDecl {{address}} <col:5, col:6> a 'i32'
    |   |-VarDecl {{address}} <col:8, col:13> b 'i32'
    |   | `-BuiltinType {{address}} <col:10, col:13> 'i32'
    |   `-ImplicitCastExpr {{address}} <col:17, col:18> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    |     `-IntegerLiteral {{address}} <col:17, col:18> 'comptime_int' 1
    `-DeclStmt {{address}} <line:3:1, col:15> contains-errors
      `-VarGroupDecl {{address}} <col:1, col:15> contains-errors
        |-VarDecl {{address}} <col:5, col:6> c 'i32'
        |-ImplicitCastExpr {{address}} <col:10, col:11> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
        | `-IntegerLiteral {{address}} <col:10, col:11> 'comptime_int' 1
        `-ImplicitCastExpr {{address}} <col:13, col:14> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
          `-IntegerLiteral {{address}} <col:13, col:14> 'comptime_int' 2)");
}

TEST_F(SemaTest, ContinuesBindingAfterLocalDeclarationShapeError) {
  Analyze("func f() { var x; x; }");

  ExpectError(0, 15, "variable declaration requires a type or initializer", 0);
  ExpectError(0, 18, "use of uninitialized variable 'x'", 1);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, col:23> f 'func () void' contains-errors
  `-CompoundStmt {{address}} <col:10, col:23> contains-errors
    |-DeclStmt {{address}} <col:12, col:18> contains-errors
    | `-VarGroupDecl {{address}} <col:12, col:18> contains-errors
    |   `-VarDecl {{address:local}} <col:16, col:17> x contains-errors
    `-ExprStmt {{address}} <col:19, col:21> contains-errors
      `-DeclRefExpr {{address}} <col:19, col:20> Var {{address:local}} 'x' contains-errors)");
}

TEST_F(SemaTest, KeepsLocalExplicitAndInferredTypesIndependent) {
  Analyze("func Use() { var a, b i64 := 1, 2; }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:37> Use 'func () void'
  `-CompoundStmt {{address}} <col:12, col:37>
    `-DeclStmt {{address}} <col:14, col:35>
      `-VarGroupDecl {{address}} <col:14, col:35>
        |-VarDecl {{address}} <col:18, col:19> a 'i32'
        |-VarDecl {{address}} <col:21, col:26> b 'i64'
        | `-BuiltinType {{address}} <col:23, col:26> 'i64'
        |-ImplicitCastExpr {{address}} <col:30, col:31> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
        | `-IntegerLiteral {{address}} <col:30, col:31> 'comptime_int' 1
        `-ImplicitCastExpr {{address}} <col:33, col:34> 'i64' pure-rvalue <IntegerToInteger>
          `-ImplicitCastExpr {{address}} <col:33, col:34> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
            `-IntegerLiteral {{address}} <col:33, col:34> 'comptime_int' 2)");
}

// Numeric conversions, arithmetic, and boolean expressions.

TEST_F(SemaTest, MaterializesExactIntegersUsingDefaultTypeBoundaries) {
  Analyze(R"(func f() {
var a := 2147483647;
var b := 2147483648;
var c := -9223372036854775808;
var d := 9223372036854775808;
var e := 18446744073709551615;
a; b; c; d; e;
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:8:2> f 'func () void'
  `-CompoundStmt {{address}} <line:1:10, line:8:2>
    |-DeclStmt {{address}} <line:2:1, col:21>
    | `-VarGroupDecl {{address}} <col:1, col:21>
    |   |-VarDecl {{address:a}} <col:5, col:6> a 'i32'
    |   `-ImplicitCastExpr {{address}} <col:10, col:20> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    |     `-IntegerLiteral {{address}} <col:10, col:20> 'comptime_int' 2147483647
    |-DeclStmt {{address}} <line:3:1, col:21>
    | `-VarGroupDecl {{address}} <col:1, col:21>
    |   |-VarDecl {{address:b}} <col:5, col:6> b 'i64'
    |   `-ImplicitCastExpr {{address}} <col:10, col:20> 'i64' pure-rvalue <ComptimeIntegerMaterialization>
    |     `-IntegerLiteral {{address}} <col:10, col:20> 'comptime_int' 2147483648
    |-DeclStmt {{address}} <line:4:1, col:31>
    | `-VarGroupDecl {{address}} <col:1, col:31>
    |   |-VarDecl {{address:c}} <col:5, col:6> c 'i64'
    |   `-ImplicitCastExpr {{address}} <col:10, col:30> 'i64' pure-rvalue <ComptimeIntegerMaterialization>
    |     `-UnaryOperator {{address}} <col:10, col:30> 'comptime_int' '-'
    |       `-IntegerLiteral {{address}} <col:11, col:30> 'comptime_int' 9223372036854775808
    |-DeclStmt {{address}} <line:5:1, col:30>
    | `-VarGroupDecl {{address}} <col:1, col:30>
    |   |-VarDecl {{address:d}} <col:5, col:6> d 'u64'
    |   `-ImplicitCastExpr {{address}} <col:10, col:29> 'u64' pure-rvalue <ComptimeIntegerMaterialization>
    |     `-IntegerLiteral {{address}} <col:10, col:29> 'comptime_int' 9223372036854775808
    |-DeclStmt {{address}} <line:6:1, col:31>
    | `-VarGroupDecl {{address}} <col:1, col:31>
    |   |-VarDecl {{address:e}} <col:5, col:6> e 'u64'
    |   `-ImplicitCastExpr {{address}} <col:10, col:30> 'u64' pure-rvalue <ComptimeIntegerMaterialization>
    |     `-IntegerLiteral {{address}} <col:10, col:30> 'comptime_int' 18446744073709551615
    |-ExprStmt {{address}} <line:7:1, col:3>
    | `-DeclRefExpr {{address}} <col:1, col:2> 'i32' lvalue Var {{address:a}} 'a' 'i32'
    |-ExprStmt {{address}} <col:4, col:6>
    | `-DeclRefExpr {{address}} <col:4, col:5> 'i64' lvalue Var {{address:b}} 'b' 'i64'
    |-ExprStmt {{address}} <col:7, col:9>
    | `-DeclRefExpr {{address}} <col:7, col:8> 'i64' lvalue Var {{address:c}} 'c' 'i64'
    |-ExprStmt {{address}} <col:10, col:12>
    | `-DeclRefExpr {{address}} <col:10, col:11> 'u64' lvalue Var {{address:d}} 'd' 'u64'
    `-ExprStmt {{address}} <col:13, col:15>
      `-DeclRefExpr {{address}} <col:13, col:14> 'u64' lvalue Var {{address:e}} 'e' 'u64')");
}

TEST_F(SemaTest, MaterializesComptimeUnaryPlusWithoutLosingItsExactType) {
  Analyze("func f() { var value := +1; }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:30> f 'func () void'
  `-CompoundStmt {{address}} <col:10, col:30>
    `-DeclStmt {{address}} <col:12, col:28>
      `-VarGroupDecl {{address}} <col:12, col:28>
        |-VarDecl {{address}} <col:16, col:21> value 'i32'
        `-ImplicitCastExpr {{address}} <col:25, col:27> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
          `-UnaryOperator {{address}} <col:25, col:27> 'comptime_int' '+'
            `-IntegerLiteral {{address}} <col:26, col:27> 'comptime_int' 1)");
}

TEST_F(SemaTest, RejectsExactIntegersOutsideAllDefaultTypes) {
  Analyze(R"(func f() {
var inferred := 18446744073709551616;
var explicit u8 := 18446744073709551616;
})");

  ExpectError(1, 16, "integer constant cannot be represented by any default integer type", 20);
  ExpectError(2, 19, "integer constant cannot be represented by any default integer type", 20);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, line:4:2> f 'func () void' contains-errors
  `-CompoundStmt {{address}} <line:1:10, line:4:2> contains-errors
    |-DeclStmt {{address}} <line:2:1, col:38> contains-errors
    | `-VarGroupDecl {{address}} <col:1, col:38> contains-errors
    |   |-VarDecl {{address}} <col:5, col:13> inferred
    |   `-IntegerLiteral {{address}} <col:17, col:37> 'comptime_int' 18446744073709551616 contains-errors
    `-DeclStmt {{address}} <line:3:1, col:41> contains-errors
      `-VarGroupDecl {{address}} <col:1, col:41> contains-errors
        |-VarDecl {{address}} <col:5, col:16> explicit 'u8'
        | `-BuiltinType {{address}} <col:14, col:16> 'u8'
        `-IntegerLiteral {{address}} <col:20, col:40> 'comptime_int' 18446744073709551616 contains-errors)");
}

TEST_F(SemaTest, WarnsForNarrowingEvenWhenTheExactConstantValueFits) {
  Analyze("func f() { var a u8 := 1; var b u8 := 257; }");

  ExpectWarning(0, 23, "implicit integer conversion from 'i32' to 'u8' may truncate value", 1);
  ExpectWarning(0, 38, "implicit integer conversion from 'i32' to 'u8' may truncate value", 3);
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:45> f 'func () void'
  `-CompoundStmt {{address}} <col:10, col:45>
    |-DeclStmt {{address}} <col:12, col:26>
    | `-VarGroupDecl {{address}} <col:12, col:26>
    |   |-VarDecl {{address}} <col:16, col:20> a 'u8'
    |   | `-BuiltinType {{address}} <col:18, col:20> 'u8'
    |   `-ImplicitCastExpr {{address}} <col:24, col:25> 'u8' pure-rvalue <IntegerToInteger>
    |     `-ImplicitCastExpr {{address}} <col:24, col:25> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    |       `-IntegerLiteral {{address}} <col:24, col:25> 'comptime_int' 1
    `-DeclStmt {{address}} <col:27, col:43>
      `-VarGroupDecl {{address}} <col:27, col:43>
        |-VarDecl {{address}} <col:31, col:35> b 'u8'
        | `-BuiltinType {{address}} <col:33, col:35> 'u8'
        `-ImplicitCastExpr {{address}} <col:39, col:42> 'u8' pure-rvalue <IntegerToInteger>
          `-ImplicitCastExpr {{address}} <col:39, col:42> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
            `-IntegerLiteral {{address}} <col:39, col:42> 'comptime_int' 257)");
}

TEST_F(SemaTest, InsertsRuntimeIntegerConversionsAndWarnsOnlyWhenNarrowing) {
  Analyze(R"(func f(source i32) {
var small u8 := 257;
var narrow u8 := source;
var hold := source;
var wide i64 := source;
var sign u32 := source;
})");

  ExpectWarning(1, 16, "implicit integer conversion from 'i32' to 'u8' may truncate value", 3);
  ExpectWarning(2, 17, "implicit integer conversion from 'i32' to 'u8' may truncate value", 6);
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:7:2> f 'func (i32) void'
  |-ParmVarDecl {{address:source}} <line:1:8, col:18> source 'i32'
  | `-BuiltinType {{address}} <col:15, col:18> 'i32'
  `-CompoundStmt {{address}} <col:20, line:7:2>
    |-DeclStmt {{address}} <line:2:1, col:21>
    | `-VarGroupDecl {{address}} <col:1, col:21>
    |   |-VarDecl {{address}} <col:5, col:13> small 'u8'
    |   | `-BuiltinType {{address}} <col:11, col:13> 'u8'
    |   `-ImplicitCastExpr {{address}} <col:17, col:20> 'u8' pure-rvalue <IntegerToInteger>
    |     `-ImplicitCastExpr {{address}} <col:17, col:20> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    |       `-IntegerLiteral {{address}} <col:17, col:20> 'comptime_int' 257
    |-DeclStmt {{address}} <line:3:1, col:25>
    | `-VarGroupDecl {{address}} <col:1, col:25>
    |   |-VarDecl {{address}} <col:5, col:14> narrow 'u8'
    |   | `-BuiltinType {{address}} <col:12, col:14> 'u8'
    |   `-ImplicitCastExpr {{address}} <col:18, col:24> 'u8' pure-rvalue <IntegerToInteger>
    |     `-ImplicitCastExpr {{address}} <col:18, col:24> 'i32' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:18, col:24> 'i32' lvalue ParmVar {{address:source}} 'source' 'i32'
    |-DeclStmt {{address}} <line:4:1, col:20>
    | `-VarGroupDecl {{address}} <col:1, col:20>
    |   |-VarDecl {{address:copy}} <col:5, col:9> hold 'i32'
    |   `-ImplicitCastExpr {{address}} <col:13, col:19> 'i32' pure-rvalue <LValueToRValue>
    |     `-DeclRefExpr {{address}} <col:13, col:19> 'i32' lvalue ParmVar {{address:source}} 'source' 'i32'
    |-DeclStmt {{address}} <line:5:1, col:24>
    | `-VarGroupDecl {{address}} <col:1, col:24>
    |   |-VarDecl {{address}} <col:5, col:13> wide 'i64'
    |   | `-BuiltinType {{address}} <col:10, col:13> 'i64'
    |   `-ImplicitCastExpr {{address}} <col:17, col:23> 'i64' pure-rvalue <IntegerToInteger>
    |     `-ImplicitCastExpr {{address}} <col:17, col:23> 'i32' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:17, col:23> 'i32' lvalue ParmVar {{address:source}} 'source' 'i32'
    `-DeclStmt {{address}} <line:6:1, col:24>
      `-VarGroupDecl {{address}} <col:1, col:24>
        |-VarDecl {{address}} <col:5, col:13> sign 'u32'
        | `-BuiltinType {{address}} <col:10, col:13> 'u32'
        `-ImplicitCastExpr {{address}} <col:17, col:23> 'u32' pure-rvalue <IntegerToInteger>
          `-ImplicitCastExpr {{address}} <col:17, col:23> 'i32' pure-rvalue <LValueToRValue>
            `-DeclRefExpr {{address}} <col:17, col:23> 'i32' lvalue ParmVar {{address:source}} 'source' 'i32')");
}

TEST_F(SemaTest, ConvertsSizeIntegerInitializersWithinTheirFamily) {
  Analyze(R"(func f(signed_value isize, unsigned_value usize) {
var to_unsigned usize := signed_value;
var to_signed isize := unsigned_value;
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:4:2> f 'func (isize, usize) void'
  |-ParmVarDecl {{address:signed_value}} <line:1:8, col:26> signed_value 'isize'
  | `-BuiltinType {{address}} <col:21, col:26> 'isize'
  |-ParmVarDecl {{address:unsigned_value}} <col:28, col:48> unsigned_value 'usize'
  | `-BuiltinType {{address}} <col:43, col:48> 'usize'
  `-CompoundStmt {{address}} <col:50, line:4:2>
    |-DeclStmt {{address}} <line:2:1, col:39>
    | `-VarGroupDecl {{address}} <col:1, col:39>
    |   |-VarDecl {{address}} <col:5, col:22> to_unsigned 'usize'
    |   | `-BuiltinType {{address}} <col:17, col:22> 'usize'
    |   `-ImplicitCastExpr {{address}} <col:26, col:38> 'usize' pure-rvalue <IntegerToInteger>
    |     `-ImplicitCastExpr {{address}} <col:26, col:38> 'isize' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:26, col:38> 'isize' lvalue ParmVar {{address:signed_value}} 'signed_value' 'isize'
    `-DeclStmt {{address}} <line:3:1, col:39>
      `-VarGroupDecl {{address}} <col:1, col:39>
        |-VarDecl {{address}} <col:5, col:20> to_signed 'isize'
        | `-BuiltinType {{address}} <col:15, col:20> 'isize'
        `-ImplicitCastExpr {{address}} <col:24, col:38> 'isize' pure-rvalue <IntegerToInteger>
          `-ImplicitCastExpr {{address}} <col:24, col:38> 'usize' pure-rvalue <LValueToRValue>
            `-DeclRefExpr {{address}} <col:24, col:38> 'usize' lvalue ParmVar {{address:unsigned_value}} 'unsigned_value' 'usize')");
}

TEST_F(SemaTest, WarnsAtExplicitNumericInitializerPrecisionBoundaries) {
  Analyze(R"(func f(small i16, medium i32, large i64, single f32, wide f64) {
var safe_single f32 := small;
var lossy_single f32 := medium;
var safe_double f64 := medium;
var lossy_double f64 := large;
var narrow_float f32 := wide;
var float_to_int i32 := single;
var narrow_int i8 := medium;
var literal_single f32 := 1;
var literal_double f64 := 1;
})");

  ExpectWarning(2, 24, "implicit conversion from 'i32' to 'f32' may lose integer precision", 6);
  ExpectWarning(4, 24, "implicit conversion from 'i64' to 'f64' may lose integer precision", 5);
  ExpectWarning(5, 24, "implicit floating-point conversion from 'f64' to 'f32' may lose precision or range", 4);
  ExpectWarning(6, 24, "implicit conversion from 'f32' to 'i32' may lose fractional value or exceed integer range", 6);
  ExpectWarning(7, 21, "implicit integer conversion from 'i32' to 'i8' may truncate value", 6);
  ExpectWarning(8, 26, "implicit conversion from 'i32' to 'f32' may lose integer precision", 1);

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:11:2> f 'func (i16, i32, i64, f32, f64) void'
  |-ParmVarDecl {{address:small}} <line:1:8, col:17> small 'i16'
  | `-BuiltinType {{address}} <col:14, col:17> 'i16'
  |-ParmVarDecl {{address:medium}} <col:19, col:29> medium 'i32'
  | `-BuiltinType {{address}} <col:26, col:29> 'i32'
  |-ParmVarDecl {{address:large}} <col:31, col:40> large 'i64'
  | `-BuiltinType {{address}} <col:37, col:40> 'i64'
  |-ParmVarDecl {{address:single}} <col:42, col:52> single 'f32'
  | `-BuiltinType {{address}} <col:49, col:52> 'f32'
  |-ParmVarDecl {{address:wide}} <col:54, col:62> wide 'f64'
  | `-BuiltinType {{address}} <col:59, col:62> 'f64'
  `-CompoundStmt {{address}} <col:64, line:11:2>
    |-DeclStmt {{address}} <line:2:1, col:30>
    | `-VarGroupDecl {{address}} <col:1, col:30>
    |   |-VarDecl {{address}} <col:5, col:20> safe_single 'f32'
    |   | `-BuiltinType {{address}} <col:17, col:20> 'f32'
    |   `-ImplicitCastExpr {{address}} <col:24, col:29> 'f32' pure-rvalue <IntegerToFloat>
    |     `-ImplicitCastExpr {{address}} <col:24, col:29> 'i16' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:24, col:29> 'i16' lvalue ParmVar {{address:small}} 'small' 'i16'
    |-DeclStmt {{address}} <line:3:1, col:32>
    | `-VarGroupDecl {{address}} <col:1, col:32>
    |   |-VarDecl {{address}} <col:5, col:21> lossy_single 'f32'
    |   | `-BuiltinType {{address}} <col:18, col:21> 'f32'
    |   `-ImplicitCastExpr {{address}} <col:25, col:31> 'f32' pure-rvalue <IntegerToFloat>
    |     `-ImplicitCastExpr {{address}} <col:25, col:31> 'i32' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:25, col:31> 'i32' lvalue ParmVar {{address:medium}} 'medium' 'i32'
    |-DeclStmt {{address}} <line:4:1, col:31>
    | `-VarGroupDecl {{address}} <col:1, col:31>
    |   |-VarDecl {{address}} <col:5, col:20> safe_double 'f64'
    |   | `-BuiltinType {{address}} <col:17, col:20> 'f64'
    |   `-ImplicitCastExpr {{address}} <col:24, col:30> 'f64' pure-rvalue <IntegerToFloat>
    |     `-ImplicitCastExpr {{address}} <col:24, col:30> 'i32' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:24, col:30> 'i32' lvalue ParmVar {{address:medium}} 'medium' 'i32'
    |-DeclStmt {{address}} <line:5:1, col:31>
    | `-VarGroupDecl {{address}} <col:1, col:31>
    |   |-VarDecl {{address}} <col:5, col:21> lossy_double 'f64'
    |   | `-BuiltinType {{address}} <col:18, col:21> 'f64'
    |   `-ImplicitCastExpr {{address}} <col:25, col:30> 'f64' pure-rvalue <IntegerToFloat>
    |     `-ImplicitCastExpr {{address}} <col:25, col:30> 'i64' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:25, col:30> 'i64' lvalue ParmVar {{address:large}} 'large' 'i64'
    |-DeclStmt {{address}} <line:6:1, col:30>
    | `-VarGroupDecl {{address}} <col:1, col:30>
    |   |-VarDecl {{address}} <col:5, col:21> narrow_float 'f32'
    |   | `-BuiltinType {{address}} <col:18, col:21> 'f32'
    |   `-ImplicitCastExpr {{address}} <col:25, col:29> 'f32' pure-rvalue <FloatToFloat>
    |     `-ImplicitCastExpr {{address}} <col:25, col:29> 'f64' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:25, col:29> 'f64' lvalue ParmVar {{address:wide}} 'wide' 'f64'
    |-DeclStmt {{address}} <line:7:1, col:32>
    | `-VarGroupDecl {{address}} <col:1, col:32>
    |   |-VarDecl {{address}} <col:5, col:21> float_to_int 'i32'
    |   | `-BuiltinType {{address}} <col:18, col:21> 'i32'
    |   `-ImplicitCastExpr {{address}} <col:25, col:31> 'i32' pure-rvalue <FloatToInteger>
    |     `-ImplicitCastExpr {{address}} <col:25, col:31> 'f32' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:25, col:31> 'f32' lvalue ParmVar {{address:single}} 'single' 'f32'
    |-DeclStmt {{address}} <line:8:1, col:29>
    | `-VarGroupDecl {{address}} <col:1, col:29>
    |   |-VarDecl {{address}} <col:5, col:18> narrow_int 'i8'
    |   | `-BuiltinType {{address}} <col:16, col:18> 'i8'
    |   `-ImplicitCastExpr {{address}} <col:22, col:28> 'i8' pure-rvalue <IntegerToInteger>
    |     `-ImplicitCastExpr {{address}} <col:22, col:28> 'i32' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:22, col:28> 'i32' lvalue ParmVar {{address:medium}} 'medium' 'i32'
    |-DeclStmt {{address}} <line:9:1, col:29>
    | `-VarGroupDecl {{address}} <col:1, col:29>
    |   |-VarDecl {{address}} <col:5, col:23> literal_single 'f32'
    |   | `-BuiltinType {{address}} <col:20, col:23> 'f32'
    |   `-ImplicitCastExpr {{address}} <col:27, col:28> 'f32' pure-rvalue <IntegerToFloat>
    |     `-ImplicitCastExpr {{address}} <col:27, col:28> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    |       `-IntegerLiteral {{address}} <col:27, col:28> 'comptime_int' 1
    `-DeclStmt {{address}} <line:10:1, col:29>
      `-VarGroupDecl {{address}} <col:1, col:29>
        |-VarDecl {{address}} <col:5, col:23> literal_double 'f64'
        | `-BuiltinType {{address}} <col:20, col:23> 'f64'
        `-ImplicitCastExpr {{address}} <col:27, col:28> 'f64' pure-rvalue <IntegerToFloat>
          `-ImplicitCastExpr {{address}} <col:27, col:28> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
            `-IntegerLiteral {{address}} <col:27, col:28> 'comptime_int' 1)");
}

TEST_F(SemaTest, PreservesRuntimeUnaryTypesAndRejectsUnsignedNegation) {
  Analyze(R"(func f() {
var ch := 'a';
var plus := +ch;
var bad := -ch;
-'b';
})");

  ExpectError(3, 11, "unary '-' cannot be applied to unsigned integer type 'u8'", 3);
  ExpectError(4, 0, "unary '-' cannot be applied to unsigned integer type 'u8'", 4);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, line:6:2> f 'func () void' contains-errors
  `-CompoundStmt {{address}} <line:1:10, line:6:2> contains-errors
    |-DeclStmt {{address}} <line:2:1, col:15>
    | `-VarGroupDecl {{address}} <col:1, col:15>
    |   |-VarDecl {{address:ch}} <col:5, col:7> ch 'u8'
    |   `-CharacterLiteral {{address}} <col:11, col:14> 'u8' pure-rvalue 97
    |-DeclStmt {{address}} <line:3:1, col:17>
    | `-VarGroupDecl {{address}} <col:1, col:17>
    |   |-VarDecl {{address}} <col:5, col:9> plus 'u8'
    |   `-UnaryOperator {{address}} <col:13, col:16> 'u8' pure-rvalue '+'
    |     `-ImplicitCastExpr {{address}} <col:14, col:16> 'u8' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:14, col:16> 'u8' lvalue Var {{address:ch}} 'ch' 'u8'
    |-DeclStmt {{address}} <line:4:1, col:16> contains-errors
    | `-VarGroupDecl {{address}} <col:1, col:16> contains-errors
    |   |-VarDecl {{address}} <col:5, col:8> bad
    |   `-UnaryOperator {{address}} <col:12, col:15> '-' contains-errors
    |     `-DeclRefExpr {{address}} <col:13, col:15> 'u8' lvalue Var {{address:ch}} 'ch' 'u8'
    `-ExprStmt {{address}} <line:5:1, col:6> contains-errors
      `-UnaryOperator {{address}} <col:1, col:5> '-' contains-errors
        `-CharacterLiteral {{address}} <col:2, col:5> 'u8' pure-rvalue 98)");
}

TEST_F(SemaTest, TypesFloatingBooleanAndMixedLiteralArithmetic) {
  Analyze(R"(func f() {
var positive := +1.0f;
var negative := -2.0;
var flag := true;
var mixed := 1 + 2.0;
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:6:2> f 'func () void'
  `-CompoundStmt {{address}} <line:1:10, line:6:2>
    |-DeclStmt {{address}} <line:2:1, col:23>
    | `-VarGroupDecl {{address}} <col:1, col:23>
    |   |-VarDecl {{address}} <col:5, col:13> positive 'f32'
    |   `-UnaryOperator {{address}} <col:17, col:22> 'f32' pure-rvalue '+'
    |     `-FloatLiteral {{address}} <col:18, col:22> 'f32' pure-rvalue 1
    |-DeclStmt {{address}} <line:3:1, col:22>
    | `-VarGroupDecl {{address}} <col:1, col:22>
    |   |-VarDecl {{address}} <col:5, col:13> negative 'f64'
    |   `-UnaryOperator {{address}} <col:17, col:21> 'f64' pure-rvalue '-'
    |     `-FloatLiteral {{address}} <col:18, col:21> 'f64' pure-rvalue 2
    |-DeclStmt {{address}} <line:4:1, col:18>
    | `-VarGroupDecl {{address}} <col:1, col:18>
    |   |-VarDecl {{address}} <col:5, col:9> flag 'bool'
    |   `-BoolLiteral {{address}} <col:13, col:17> 'bool' pure-rvalue true
    `-DeclStmt {{address}} <line:5:1, col:22>
      `-VarGroupDecl {{address}} <col:1, col:22>
        |-VarDecl {{address}} <col:5, col:10> mixed 'f64'
        `-BinaryOperator {{address}} <col:14, col:21> 'f64' pure-rvalue '+'
          |-ImplicitCastExpr {{address}} <col:14, col:15> 'f64' pure-rvalue <IntegerToFloat>
          | `-ImplicitCastExpr {{address}} <col:14, col:15> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
          |   `-IntegerLiteral {{address}} <col:14, col:15> 'comptime_int' 1
          `-FloatLiteral {{address}} <col:18, col:21> 'f64' pure-rvalue 2)");
}

TEST_F(SemaTest, AppliesFixedWidthIntegerCommonTypesWithoutPromotions) {
  Analyze(R"(func f(signed32 i32, unsigned32 u32, signed64 i64, unsigned64 u64) {
var signed_widening := signed32 + signed64;
var covered := unsigned32 + signed64;
var same_rank := signed32 + unsigned32;
var wider_unsigned := signed32 + unsigned64;
var same_rank64 := signed64 + unsigned64;
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:7:2> f 'func (i32, u32, i64, u64) void'
  |-ParmVarDecl {{address:signed32}} <line:1:8, col:20> signed32 'i32'
  | `-BuiltinType {{address}} <col:17, col:20> 'i32'
  |-ParmVarDecl {{address:unsigned32}} <col:22, col:36> unsigned32 'u32'
  | `-BuiltinType {{address}} <col:33, col:36> 'u32'
  |-ParmVarDecl {{address:signed64}} <col:38, col:50> signed64 'i64'
  | `-BuiltinType {{address}} <col:47, col:50> 'i64'
  |-ParmVarDecl {{address:unsigned64}} <col:52, col:66> unsigned64 'u64'
  | `-BuiltinType {{address}} <col:63, col:66> 'u64'
  `-CompoundStmt {{address}} <col:68, line:7:2>
    |-DeclStmt {{address}} <line:2:1, col:44>
    | `-VarGroupDecl {{address}} <col:1, col:44>
    |   |-VarDecl {{address}} <col:5, col:20> signed_widening 'i64'
    |   `-BinaryOperator {{address}} <col:24, col:43> 'i64' pure-rvalue '+'
    |     |-ImplicitCastExpr {{address}} <col:24, col:32> 'i64' pure-rvalue <IntegerToInteger>
    |     | `-ImplicitCastExpr {{address}} <col:24, col:32> 'i32' pure-rvalue <LValueToRValue>
    |     |   `-DeclRefExpr {{address}} <col:24, col:32> 'i32' lvalue ParmVar {{address:signed32}} 'signed32' 'i32'
    |     `-ImplicitCastExpr {{address}} <col:35, col:43> 'i64' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:35, col:43> 'i64' lvalue ParmVar {{address:signed64}} 'signed64' 'i64'
    |-DeclStmt {{address}} <line:3:1, col:38>
    | `-VarGroupDecl {{address}} <col:1, col:38>
    |   |-VarDecl {{address}} <col:5, col:12> covered 'i64'
    |   `-BinaryOperator {{address}} <col:16, col:37> 'i64' pure-rvalue '+'
    |     |-ImplicitCastExpr {{address}} <col:16, col:26> 'i64' pure-rvalue <IntegerToInteger>
    |     | `-ImplicitCastExpr {{address}} <col:16, col:26> 'u32' pure-rvalue <LValueToRValue>
    |     |   `-DeclRefExpr {{address}} <col:16, col:26> 'u32' lvalue ParmVar {{address:unsigned32}} 'unsigned32' 'u32'
    |     `-ImplicitCastExpr {{address}} <col:29, col:37> 'i64' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:29, col:37> 'i64' lvalue ParmVar {{address:signed64}} 'signed64' 'i64'
    |-DeclStmt {{address}} <line:4:1, col:40>
    | `-VarGroupDecl {{address}} <col:1, col:40>
    |   |-VarDecl {{address}} <col:5, col:14> same_rank 'u32'
    |   `-BinaryOperator {{address}} <col:18, col:39> 'u32' pure-rvalue '+'
    |     |-ImplicitCastExpr {{address}} <col:18, col:26> 'u32' pure-rvalue <IntegerToInteger>
    |     | `-ImplicitCastExpr {{address}} <col:18, col:26> 'i32' pure-rvalue <LValueToRValue>
    |     |   `-DeclRefExpr {{address}} <col:18, col:26> 'i32' lvalue ParmVar {{address:signed32}} 'signed32' 'i32'
    |     `-ImplicitCastExpr {{address}} <col:29, col:39> 'u32' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:29, col:39> 'u32' lvalue ParmVar {{address:unsigned32}} 'unsigned32' 'u32'
    |-DeclStmt {{address}} <line:5:1, col:45>
    | `-VarGroupDecl {{address}} <col:1, col:45>
    |   |-VarDecl {{address}} <col:5, col:19> wider_unsigned 'u64'
    |   `-BinaryOperator {{address}} <col:23, col:44> 'u64' pure-rvalue '+'
    |     |-ImplicitCastExpr {{address}} <col:23, col:31> 'u64' pure-rvalue <IntegerToInteger>
    |     | `-ImplicitCastExpr {{address}} <col:23, col:31> 'i32' pure-rvalue <LValueToRValue>
    |     |   `-DeclRefExpr {{address}} <col:23, col:31> 'i32' lvalue ParmVar {{address:signed32}} 'signed32' 'i32'
    |     `-ImplicitCastExpr {{address}} <col:34, col:44> 'u64' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:34, col:44> 'u64' lvalue ParmVar {{address:unsigned64}} 'unsigned64' 'u64'
    `-DeclStmt {{address}} <line:6:1, col:42>
      `-VarGroupDecl {{address}} <col:1, col:42>
        |-VarDecl {{address}} <col:5, col:16> same_rank64 'u64'
        `-BinaryOperator {{address}} <col:20, col:41> 'u64' pure-rvalue '+'
          |-ImplicitCastExpr {{address}} <col:20, col:28> 'u64' pure-rvalue <IntegerToInteger>
          | `-ImplicitCastExpr {{address}} <col:20, col:28> 'i64' pure-rvalue <LValueToRValue>
          |   `-DeclRefExpr {{address}} <col:20, col:28> 'i64' lvalue ParmVar {{address:signed64}} 'signed64' 'i64'
          `-ImplicitCastExpr {{address}} <col:31, col:41> 'u64' pure-rvalue <LValueToRValue>
            `-DeclRefExpr {{address}} <col:31, col:41> 'u64' lvalue ParmVar {{address:unsigned64}} 'unsigned64' 'u64')");
}

TEST_F(SemaTest, MaterializesStandaloneExactIntegerExpressions) {
  Analyze(R"(func f() i32 {
1;
+1;
-1;
1
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:6:2> f 'func () i32'
  |-ReturnVarDecl {{address:return_object}} <line:1:10, col:13> 'i32'
  | `-BuiltinType {{address}} <col:10, col:13> 'i32'
  `-CompoundStmt {{address}} <col:14, line:6:2>
    |-ExprStmt {{address}} <line:2:1, col:3>
    | `-ImplicitCastExpr {{address}} <col:1, col:2> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    |   `-IntegerLiteral {{address}} <col:1, col:2> 'comptime_int' 1
    |-ExprStmt {{address}} <line:3:1, col:4>
    | `-ImplicitCastExpr {{address}} <col:1, col:3> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    |   `-UnaryOperator {{address}} <col:1, col:3> 'comptime_int' '+'
    |     `-IntegerLiteral {{address}} <col:2, col:3> 'comptime_int' 1
    |-ExprStmt {{address}} <line:4:1, col:4>
    | `-ImplicitCastExpr {{address}} <col:1, col:3> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    |   `-UnaryOperator {{address}} <col:1, col:3> 'comptime_int' '-'
    |     `-IntegerLiteral {{address}} <col:2, col:3> 'comptime_int' 1
    `-ImplicitResultInitializationExpr {{address}} <line:5:1, col:2> 'void' ReturnVar {{address:return_object}} 'i32'
      `-ImplicitCastExpr {{address}} <col:1, col:2> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
        `-IntegerLiteral {{address}} <col:1, col:2> 'comptime_int' 1)");
}

TEST_F(SemaTest, MaterializesIntegerBeforeStrictBooleanCheck) {
  Analyze("func f() { if -1 {} }");

  ExpectError(0, 14, "condition expression must have type 'bool', not 'i32'", 2);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, col:22> f 'func () void' contains-errors
  `-CompoundStmt {{address}} <col:10, col:22> contains-errors
    `-IfStmt {{address}} <col:12, col:20> contains-errors
      |-ImplicitCastExpr {{address}} <col:15, col:17> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
      | `-UnaryOperator {{address}} <col:15, col:17> 'comptime_int' '-'
      |   `-IntegerLiteral {{address}} <col:16, col:17> 'comptime_int' 1
      `-CompoundStmt {{address}} <col:18, col:20>)");
}

TEST_F(SemaTest, ReportsInvalidComparisonAndBooleanOperands) {
  Analyze(R"(func f(size usize, fixed i32) {
true < false;
size == fixed;
!1;
1 && true;
if fixed {}
while -1 {}
})");

  ExpectError(1, 0, "binary operator '<' cannot be applied to types 'bool' and 'bool'", 12);
  ExpectError(2, 0, "binary operator '==' cannot be applied to types 'usize' and 'i32'", 13);
  ExpectError(3, 0, "unary operator '!' cannot be applied to type 'i32'", 2);
  ExpectError(4, 0, "binary operator '&&' cannot be applied to types 'i32' and 'bool'", 9);
  ExpectError(5, 3, "condition expression must have type 'bool', not 'i32'", 5);
  ExpectError(6, 6, "condition expression must have type 'bool', not 'i32'", 2);
}

TEST_F(SemaTest, SuppressesComparisonDiagnosticsAfterOperandFailure) {
  Analyze(R"(func f() {
missing < 1;
1 < 18446744073709551616;
})");

  ExpectError(1, 0, "use of undeclared identifier 'missing'", 7);
  ExpectError(2, 4, "integer constant cannot be represented by any default integer type", 20);
}

TEST_F(SemaTest, ReportsUnsupportedArithmeticOperandTypes) {
  Analyze(R"(func f(size usize, integer i64, single f32) {
size + integer;
size + 1;
size + single;
single % single;
true * integer;
})");

  ExpectError(1, 0, "binary operator '+' cannot be applied to types 'usize' and 'i64'", 14);
  ExpectError(2, 0, "binary operator '+' cannot be applied to types 'usize' and 'i32'", 8);
  ExpectError(3, 0, "binary operator '+' cannot be applied to types 'usize' and 'f32'", 13);
  ExpectError(4, 0, "binary operator '%' cannot be applied to types 'f32' and 'f32'", 15);
  ExpectError(5, 0, "binary operator '*' cannot be applied to types 'bool' and 'i64'", 14);
}

TEST_F(SemaTest, SuppressesBinaryDiagnosticAfterComptimeMaterializationFailure) {
  Analyze(R"(func f() {
var value := 1 + 18446744073709551616;
})");

  ExpectError(1, 17, "integer constant cannot be represented by any default integer type", 20);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, line:3:2> f 'func () void' contains-errors
  `-CompoundStmt {{address}} <line:1:10, line:3:2> contains-errors
    `-DeclStmt {{address}} <line:2:1, col:39> contains-errors
      `-VarGroupDecl {{address}} <col:1, col:39> contains-errors
        |-VarDecl {{address}} <col:5, col:10> value
        `-BinaryOperator {{address}} <col:14, col:38> '+' contains-errors
          |-ImplicitCastExpr {{address}} <col:14, col:15> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
          | `-IntegerLiteral {{address}} <col:14, col:15> 'comptime_int' 1
          `-IntegerLiteral {{address}} <col:18, col:38> 'comptime_int' 18446744073709551616 contains-errors)");
}

// Conditional expression types and value categories.

TEST_F(SemaTest, TypesConditionalExpressionsBeforeOuterConversions) {
  Analyze(R"(func consume(value f32) {}
func adapt(condition bool, large i64, single f32) f64 {
var fixed := condition ? 1 : large;
var local f64 := condition ? large : single;
var reverse := condition ? single : large;
consume(condition ? large : single);
return condition ? large : single;
})");

  ExpectWarning(3, 29, "implicit conversion from 'i64' to 'f32' may lose integer precision", 5);
  ExpectWarning(4, 36, "implicit conversion from 'i64' to 'f32' may lose integer precision", 5);
  ExpectWarning(5, 20, "implicit conversion from 'i64' to 'f32' may lose integer precision", 5);
  ExpectWarning(6, 19, "implicit conversion from 'i64' to 'f32' may lose integer precision", 5);

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-FunctionDecl {{address:consume}} <test.cw:1:1, col:27> consume 'func (f32) void'
| |-ParmVarDecl {{address}} <col:14, col:23> value 'f32'
| | `-BuiltinType {{address}} <col:20, col:23> 'f32'
| `-CompoundStmt {{address}} <col:25, col:27>
`-FunctionDecl {{address}} <line:2:1, line:8:2> adapt 'func (bool, i64, f32) f64'
  |-ParmVarDecl {{address:condition}} <line:2:12, col:26> condition 'bool'
  | `-BuiltinType {{address}} <col:22, col:26> 'bool'
  |-ParmVarDecl {{address:large}} <col:28, col:37> large 'i64'
  | `-BuiltinType {{address}} <col:34, col:37> 'i64'
  |-ParmVarDecl {{address:single}} <col:39, col:49> single 'f32'
  | `-BuiltinType {{address}} <col:46, col:49> 'f32'
  |-ReturnVarDecl {{address:return_object}} <col:51, col:54> 'f64'
  | `-BuiltinType {{address}} <col:51, col:54> 'f64'
  `-CompoundStmt {{address}} <col:55, line:8:2>
    |-DeclStmt {{address}} <line:3:1, col:36>
    | `-VarGroupDecl {{address}} <col:1, col:36>
    |   |-VarDecl {{address}} <col:5, col:10> fixed 'i64'
    |   `-ConditionalOperator {{address}} <col:14, col:35> 'i64' pure-rvalue
    |     |-ImplicitCastExpr {{address}} <col:14, col:23> 'bool' pure-rvalue <LValueToRValue>
    |     | `-DeclRefExpr {{address}} <col:14, col:23> 'bool' lvalue ParmVar {{address:condition}} 'condition' 'bool'
    |     |-ImplicitCastExpr {{address}} <col:26, col:27> 'i64' pure-rvalue <IntegerToInteger>
    |     | `-ImplicitCastExpr {{address}} <col:26, col:27> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    |     |   `-IntegerLiteral {{address}} <col:26, col:27> 'comptime_int' 1
    |     `-ImplicitCastExpr {{address}} <col:30, col:35> 'i64' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:30, col:35> 'i64' lvalue ParmVar {{address:large}} 'large' 'i64'
    |-DeclStmt {{address}} <line:4:1, col:45>
    | `-VarGroupDecl {{address}} <col:1, col:45>
    |   |-VarDecl {{address}} <col:5, col:14> local 'f64'
    |   | `-BuiltinType {{address}} <col:11, col:14> 'f64'
    |   `-ImplicitCastExpr {{address}} <col:18, col:44> 'f64' pure-rvalue <FloatToFloat>
    |     `-ConditionalOperator {{address}} <col:18, col:44> 'f32' pure-rvalue
    |       |-ImplicitCastExpr {{address}} <col:18, col:27> 'bool' pure-rvalue <LValueToRValue>
    |       | `-DeclRefExpr {{address}} <col:18, col:27> 'bool' lvalue ParmVar {{address:condition}} 'condition' 'bool'
    |       |-ImplicitCastExpr {{address}} <col:30, col:35> 'f32' pure-rvalue <IntegerToFloat>
    |       | `-ImplicitCastExpr {{address}} <col:30, col:35> 'i64' pure-rvalue <LValueToRValue>
    |       |   `-DeclRefExpr {{address}} <col:30, col:35> 'i64' lvalue ParmVar {{address:large}} 'large' 'i64'
    |       `-ImplicitCastExpr {{address}} <col:38, col:44> 'f32' pure-rvalue <LValueToRValue>
    |         `-DeclRefExpr {{address}} <col:38, col:44> 'f32' lvalue ParmVar {{address:single}} 'single' 'f32'
    |-DeclStmt {{address}} <line:5:1, col:43>
    | `-VarGroupDecl {{address}} <col:1, col:43>
    |   |-VarDecl {{address}} <col:5, col:12> reverse 'f32'
    |   `-ConditionalOperator {{address}} <col:16, col:42> 'f32' pure-rvalue
    |     |-ImplicitCastExpr {{address}} <col:16, col:25> 'bool' pure-rvalue <LValueToRValue>
    |     | `-DeclRefExpr {{address}} <col:16, col:25> 'bool' lvalue ParmVar {{address:condition}} 'condition' 'bool'
    |     |-ImplicitCastExpr {{address}} <col:28, col:34> 'f32' pure-rvalue <LValueToRValue>
    |     | `-DeclRefExpr {{address}} <col:28, col:34> 'f32' lvalue ParmVar {{address:single}} 'single' 'f32'
    |     `-ImplicitCastExpr {{address}} <col:37, col:42> 'f32' pure-rvalue <IntegerToFloat>
    |       `-ImplicitCastExpr {{address}} <col:37, col:42> 'i64' pure-rvalue <LValueToRValue>
    |         `-DeclRefExpr {{address}} <col:37, col:42> 'i64' lvalue ParmVar {{address:large}} 'large' 'i64'
    |-ExprStmt {{address}} <line:6:1, col:37>
    | `-CallExpr {{address}} <col:1, col:36> 'void'
    |   |-DeclRefExpr {{address}} <col:1, col:8> 'func (f32) void' Function {{address:consume}} 'consume' 'func (f32) void'
    |   `-ConditionalOperator {{address}} <col:9, col:35> 'f32' pure-rvalue
    |     |-ImplicitCastExpr {{address}} <col:9, col:18> 'bool' pure-rvalue <LValueToRValue>
    |     | `-DeclRefExpr {{address}} <col:9, col:18> 'bool' lvalue ParmVar {{address:condition}} 'condition' 'bool'
    |     |-ImplicitCastExpr {{address}} <col:21, col:26> 'f32' pure-rvalue <IntegerToFloat>
    |     | `-ImplicitCastExpr {{address}} <col:21, col:26> 'i64' pure-rvalue <LValueToRValue>
    |     |   `-DeclRefExpr {{address}} <col:21, col:26> 'i64' lvalue ParmVar {{address:large}} 'large' 'i64'
    |     `-ImplicitCastExpr {{address}} <col:29, col:35> 'f32' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:29, col:35> 'f32' lvalue ParmVar {{address:single}} 'single' 'f32'
    `-ReturnStmt {{address}} <line:7:1, col:35>
      `-ImplicitResultInitializationExpr {{address}} <col:8, col:34> 'void' ReturnVar {{address:return_object}} 'f64'
        `-ImplicitCastExpr {{address}} <col:8, col:34> 'f64' pure-rvalue <FloatToFloat>
          `-ConditionalOperator {{address}} <col:8, col:34> 'f32' pure-rvalue
            |-ImplicitCastExpr {{address}} <col:8, col:17> 'bool' pure-rvalue <LValueToRValue>
            | `-DeclRefExpr {{address}} <col:8, col:17> 'bool' lvalue ParmVar {{address:condition}} 'condition' 'bool'
            |-ImplicitCastExpr {{address}} <col:20, col:25> 'f32' pure-rvalue <IntegerToFloat>
            | `-ImplicitCastExpr {{address}} <col:20, col:25> 'i64' pure-rvalue <LValueToRValue>
            |   `-DeclRefExpr {{address}} <col:20, col:25> 'i64' lvalue ParmVar {{address:large}} 'large' 'i64'
            `-ImplicitCastExpr {{address}} <col:28, col:34> 'f32' pure-rvalue <LValueToRValue>
              `-DeclRefExpr {{address}} <col:28, col:34> 'f32' lvalue ParmVar {{address:single}} 'single' 'f32')");
}

TEST_F(SemaTest, PreservesConditionalObjectValueCategories) {
  Analyze(R"(func categories(flag bool, left i32, right i32) {
  var fixed const i32 := left;
  var link mut i32 := flag ? left : right;
  var owned := flag ? left : fixed;
  var moved := flag ? move left : move right;
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:6:2> categories 'func (bool, i32, i32) void'
  |-ParmVarDecl {{address:flag}} <line:1:17, col:26> flag 'bool'
  | `-BuiltinType {{address}} <col:22, col:26> 'bool'
  |-ParmVarDecl {{address:left}} <col:28, col:36> left 'i32'
  | `-BuiltinType {{address}} <col:33, col:36> 'i32'
  |-ParmVarDecl {{address:right}} <col:38, col:47> right 'i32'
  | `-BuiltinType {{address}} <col:44, col:47> 'i32'
  `-CompoundStmt {{address}} <col:49, line:6:2>
    |-DeclStmt {{address}} <line:2:3, col:31>
    | `-VarGroupDecl {{address}} <col:3, col:31>
    |   |-VarDecl {{address:fixed}} <col:7, col:22> fixed 'const i32'
    |   | `-ConstType {{address}} <col:13, col:22>
    |   |   `-BuiltinType {{address}} <col:19, col:22> 'i32'
    |   `-ImplicitCastExpr {{address}} <col:26, col:30> 'i32' pure-rvalue <LValueToRValue>
    |     `-DeclRefExpr {{address}} <col:26, col:30> 'i32' lvalue ParmVar {{address:left}} 'left' 'i32'
    |-DeclStmt {{address}} <line:3:3, col:43>
    | `-VarGroupDecl {{address}} <col:3, col:43>
    |   |-VarDecl {{address}} <col:7, col:19> link 'mut i32'
    |   | `-ReferenceType {{address}} <col:12, col:19> 'mut'
    |   |   `-BuiltinType {{address}} <col:16, col:19> 'i32'
    |   `-ConditionalOperator {{address}} <col:23, col:42> 'i32' lvalue
    |     |-ImplicitCastExpr {{address}} <col:23, col:27> 'bool' pure-rvalue <LValueToRValue>
    |     | `-DeclRefExpr {{address}} <col:23, col:27> 'bool' lvalue ParmVar {{address:flag}} 'flag' 'bool'
    |     |-DeclRefExpr {{address}} <col:30, col:34> 'i32' lvalue ParmVar {{address:left}} 'left' 'i32'
    |     `-DeclRefExpr {{address}} <col:37, col:42> 'i32' lvalue ParmVar {{address:right}} 'right' 'i32'
    |-DeclStmt {{address}} <line:4:3, col:36>
    | `-VarGroupDecl {{address}} <col:3, col:36>
    |   |-VarDecl {{address}} <col:7, col:12> owned 'i32'
    |   `-ImplicitCastExpr {{address}} <col:16, col:35> 'i32' pure-rvalue <LValueToRValue>
    |     `-ConditionalOperator {{address}} <col:16, col:35> 'const i32' lvalue
    |       |-ImplicitCastExpr {{address}} <col:16, col:20> 'bool' pure-rvalue <LValueToRValue>
    |       | `-DeclRefExpr {{address}} <col:16, col:20> 'bool' lvalue ParmVar {{address:flag}} 'flag' 'bool'
    |       |-DeclRefExpr {{address}} <col:23, col:27> 'i32' lvalue ParmVar {{address:left}} 'left' 'i32'
    |       `-DeclRefExpr {{address}} <col:30, col:35> 'const i32' lvalue Var {{address:fixed}} 'fixed' 'const i32'
    `-DeclStmt {{address}} <line:5:3, col:46>
      `-VarGroupDecl {{address}} <col:3, col:46>
        |-VarDecl {{address}} <col:7, col:12> moved 'i32'
        `-ImplicitCastExpr {{address}} <col:16, col:45> 'i32' pure-rvalue <LValueToRValue>
          `-ConditionalOperator {{address}} <col:16, col:45> 'i32' move-lvalue
            |-ImplicitCastExpr {{address}} <col:16, col:20> 'bool' pure-rvalue <LValueToRValue>
            | `-DeclRefExpr {{address}} <col:16, col:20> 'bool' lvalue ParmVar {{address:flag}} 'flag' 'bool'
            |-UnaryOperator {{address}} <col:23, col:32> 'i32' move-lvalue 'move'
            | `-DeclRefExpr {{address}} <col:28, col:32> 'i32' lvalue ParmVar {{address:left}} 'left' 'i32'
            `-UnaryOperator {{address}} <col:35, col:45> 'i32' move-lvalue 'move'
              `-DeclRefExpr {{address}} <col:40, col:45> 'i32' lvalue ParmVar {{address:right}} 'right' 'i32')");
}

TEST_F(SemaTest, RejectsNonObjectConditionalValueResults) {
  Analyze(R"(func left() {}
func right() {}
func choose(flag bool) {
  flag ? left : right;
})");

  ExpectError(3, 9, "a function name cannot be used as a conditional value result", 12);
}

TEST_F(SemaTest, ReportsIndependentConditionalExpressionErrors) {
  Analyze(R"(func diagnose(condition i32, flag bool, value i32, size usize) {
condition ? value : 1.0f;
condition ? flag : value;
flag ? flag : value;
flag ? size : value;
})");

  ExpectError(1, 0, "condition expression must have type 'bool', not 'i32'", 9);
  ExpectError(2, 0, "condition expression must have type 'bool', not 'i32'", 9);
  ExpectError(2, 12, "conditional expression has no common result type for 'bool' and 'i32'", 12);
  ExpectError(3, 7, "conditional expression has no common result type for 'bool' and 'i32'", 12);
  ExpectError(4, 7, "conditional expression has no common result type for 'usize' and 'i32'", 12);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, line:6:2> diagnose 'func (i32, bool, i32, usize) void' contains-errors
  |-ParmVarDecl {{address:condition}} <line:1:15, col:28> condition 'i32'
  | `-BuiltinType {{address}} <col:25, col:28> 'i32'
  |-ParmVarDecl {{address:flag}} <col:30, col:39> flag 'bool'
  | `-BuiltinType {{address}} <col:35, col:39> 'bool'
  |-ParmVarDecl {{address:value}} <col:41, col:50> value 'i32'
  | `-BuiltinType {{address}} <col:47, col:50> 'i32'
  |-ParmVarDecl {{address:size}} <col:52, col:62> size 'usize'
  | `-BuiltinType {{address}} <col:57, col:62> 'usize'
  `-CompoundStmt {{address}} <col:64, line:6:2> contains-errors
    |-ExprStmt {{address}} <line:2:1, col:26> contains-errors
    | `-ConditionalOperator {{address}} <col:1, col:25> contains-errors
    |   |-DeclRefExpr {{address}} <col:1, col:10> 'i32' lvalue ParmVar {{address:condition}} 'condition' 'i32'
    |   |-DeclRefExpr {{address}} <col:13, col:18> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
    |   `-FloatLiteral {{address}} <col:21, col:25> 'f32' pure-rvalue 1
    |-ExprStmt {{address}} <line:3:1, col:26> contains-errors
    | `-ConditionalOperator {{address}} <col:1, col:25> contains-errors
    |   |-DeclRefExpr {{address}} <col:1, col:10> 'i32' lvalue ParmVar {{address:condition}} 'condition' 'i32'
    |   |-DeclRefExpr {{address}} <col:13, col:17> 'bool' lvalue ParmVar {{address:flag}} 'flag' 'bool'
    |   `-DeclRefExpr {{address}} <col:20, col:25> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
    |-ExprStmt {{address}} <line:4:1, col:21> contains-errors
    | `-ConditionalOperator {{address}} <col:1, col:20> contains-errors
    |   |-ImplicitCastExpr {{address}} <col:1, col:5> 'bool' pure-rvalue <LValueToRValue>
    |   | `-DeclRefExpr {{address}} <col:1, col:5> 'bool' lvalue ParmVar {{address:flag}} 'flag' 'bool'
    |   |-DeclRefExpr {{address}} <col:8, col:12> 'bool' lvalue ParmVar {{address:flag}} 'flag' 'bool'
    |   `-DeclRefExpr {{address}} <col:15, col:20> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
    `-ExprStmt {{address}} <line:5:1, col:21> contains-errors
      `-ConditionalOperator {{address}} <col:1, col:20> contains-errors
        |-ImplicitCastExpr {{address}} <col:1, col:5> 'bool' pure-rvalue <LValueToRValue>
        | `-DeclRefExpr {{address}} <col:1, col:5> 'bool' lvalue ParmVar {{address:flag}} 'flag' 'bool'
        |-DeclRefExpr {{address}} <col:8, col:12> 'usize' lvalue ParmVar {{address:size}} 'size' 'usize'
        `-DeclRefExpr {{address}} <col:15, col:20> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32')");
}

TEST_F(SemaTest, SuppressesDependentConditionalDiagnosticsAfterChildErrors) {
  Analyze(R"(func recover(flag bool, value i32) {
missing_condition ? value : value;
flag ? missing_then : value;
flag ? value : missing_else;
flag ? value : value;
})");

  ExpectError(1, 0, "use of undeclared identifier 'missing_condition'", 17);
  ExpectError(2, 7, "use of undeclared identifier 'missing_then'", 12);
  ExpectError(3, 15, "use of undeclared identifier 'missing_else'", 12);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, line:6:2> recover 'func (bool, i32) void' contains-errors
  |-ParmVarDecl {{address:flag}} <line:1:14, col:23> flag 'bool'
  | `-BuiltinType {{address}} <col:19, col:23> 'bool'
  |-ParmVarDecl {{address:value}} <col:25, col:34> value 'i32'
  | `-BuiltinType {{address}} <col:31, col:34> 'i32'
  `-CompoundStmt {{address}} <col:36, line:6:2> contains-errors
    |-ExprStmt {{address}} <line:2:1, col:35> contains-errors
    | `-ConditionalOperator {{address}} <col:1, col:34> contains-errors
    |   |-DeclRefExpr {{address}} <col:1, col:18> 'missing_condition' contains-errors
    |   |-DeclRefExpr {{address}} <col:21, col:26> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
    |   `-DeclRefExpr {{address}} <col:29, col:34> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
    |-ExprStmt {{address}} <line:3:1, col:29> contains-errors
    | `-ConditionalOperator {{address}} <col:1, col:28> contains-errors
    |   |-ImplicitCastExpr {{address}} <col:1, col:5> 'bool' pure-rvalue <LValueToRValue>
    |   | `-DeclRefExpr {{address}} <col:1, col:5> 'bool' lvalue ParmVar {{address:flag}} 'flag' 'bool'
    |   |-DeclRefExpr {{address}} <col:8, col:20> 'missing_then' contains-errors
    |   `-DeclRefExpr {{address}} <col:23, col:28> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
    |-ExprStmt {{address}} <line:4:1, col:29> contains-errors
    | `-ConditionalOperator {{address}} <col:1, col:28> contains-errors
    |   |-ImplicitCastExpr {{address}} <col:1, col:5> 'bool' pure-rvalue <LValueToRValue>
    |   | `-DeclRefExpr {{address}} <col:1, col:5> 'bool' lvalue ParmVar {{address:flag}} 'flag' 'bool'
    |   |-DeclRefExpr {{address}} <col:8, col:13> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
    |   `-DeclRefExpr {{address}} <col:16, col:28> 'missing_else' contains-errors
    `-ExprStmt {{address}} <line:5:1, col:22>
      `-ConditionalOperator {{address}} <col:1, col:21> 'i32' lvalue
        |-ImplicitCastExpr {{address}} <col:1, col:5> 'bool' pure-rvalue <LValueToRValue>
        | `-DeclRefExpr {{address}} <col:1, col:5> 'bool' lvalue ParmVar {{address:flag}} 'flag' 'bool'
        |-DeclRefExpr {{address}} <col:8, col:13> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
        `-DeclRefExpr {{address}} <col:16, col:21> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32')");
}

// Object pointers, addresses, and dereference.

TEST_F(SemaTest, AcceptsObjectPointerConversionsAcrossValueContexts) {
  Analyze(R"(trivial struct Base {}
trivial struct Derived : Base {}
struct Holder {}
trivial struct Operand {}
ctor Holder(value *Base) {}
dtor Holder() {}
func Accept(value *Base) {}
func Receive(this copy Operand, value *Base) {}
func operator +(left copy Operand, right *Base) copy Operand { left }
func Apply(derived *Derived, readonly *const Derived, callback *func (*Base) void, operand copy Operand) *Base {
  var initialized *Base := derived;
  var readonly_base *const Base := readonly;
  var assigned *Base;
  assigned := derived;
  assigned = derived;
  Accept(derived);
  callback(derived);
  operand.Receive(derived);
  var holder := Holder(derived);
  operand + derived;
  derived
})");
}

TEST_F(SemaTest, RejectsUnsafeObjectPointerConversions) {
  Analyze(R"(trivial struct Base {}
trivial struct Derived : Base {}
func Need(value *Base) {}
func Reject(readonly *const Derived, nested **Derived) {
  var removes *Base := readonly;
  var unsafe **const Derived := nested;
  var recursive **Base := nested;
  Need(readonly);
})");

  ExpectError(4, 23,
              "cannot initialize variable 'removes': conversion from '*const Derived' to '*Base' would discard const",
              8);
  ExpectError(5, 32,
              "cannot initialize variable 'unsafe': no implicit conversion from '**Derived' to '**const Derived'", 6);
  ExpectError(6, 26, "cannot initialize variable 'recursive': no implicit conversion from '**Derived' to '**Base'", 6);
  ExpectError(7, 2, "no matching function for call to 'Need'", 14);
  ExpectNote(2, 0,
             "candidate function is not viable: conversion from '*const Derived' to '*Base' would discard const for "
             "argument 1",
             0);
}

TEST_F(SemaTest, SelectsObjectPointerOverloadsByCxxConversionOrdering) {
  Analyze(R"(trivial struct Base {}
trivial struct Middle : Base {}
trivial struct Derived : Middle {}
func Exact(value *Derived) i32 { 1 }
func Exact(value *const Derived) bool { true }
func Qualify(value *const Derived) i32 { 1 }
func Qualify(value *Middle) bool { true }
func Near(value *const Middle) i32 { 1 }
func Near(value *Base) bool { true }
func Layer(value *const *Derived) i32 { 1 }
func Layer(value *const *const Derived) bool { true }
func Check(value *Derived, nested **Derived) {
  var exact i32 := Exact(value);
  var qualified i32 := Qualify(value);
  var near i32 := Near(value);
  var layered i32 := Layer(nested);
})");
}

TEST_F(SemaTest, ReportsCrossArgumentAmbiguityForObjectPointerConversions) {
  Analyze(R"(trivial struct Base {}
trivial struct Middle : Base {}
trivial struct Derived : Middle {}
func Choose(left *Middle, right *Base) {}
func Choose(left *Base, right *Middle) {}
func Check(left *Derived, right *Derived) {
  Choose(left, right);
})");

  ExpectError(6, 2, "call to 'Choose' is ambiguous", 19);
  ExpectNote(3, 0, "candidate function", 0);
  ExpectNote(4, 0, "candidate function", 0);
}

TEST_F(SemaTest, ReadsObjectPointerBeforeImplicitConversion) {
  Analyze(R"(trivial struct Base {}
trivial struct Derived : Base {}
func Check() {
  var pointer *Derived;
  var base *const Base := pointer;
})");

  ExpectError(4, 26, "use of uninitialized variable 'pointer'", 7);
  ExpectError(4, 6, "cannot initialize before preceding variable 'pointer' is fully initialized", 4);
}

TEST_F(SemaTest, FormsRawPointerDereferenceAsPointeeLvalue) {
  Analyze("func f(pointer *i32) { *pointer = 1; }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:39> f 'func (*i32) void'
  |-ParmVarDecl {{address:pointer}} <col:8, col:20> pointer '*i32'
  | `-PointerType {{address}} <col:16, col:20>
  |   `-BuiltinType {{address}} <col:17, col:20> 'i32'
  `-CompoundStmt {{address}} <col:22, col:39>
    `-ExprStmt {{address}} <col:24, col:37>
      `-BinaryOperator {{address}} <col:24, col:36> 'i32' lvalue '='
        |-UnaryOperator {{address}} <col:24, col:32> 'i32' lvalue '*'
        | `-ImplicitCastExpr {{address}} <col:25, col:32> '*i32' pure-rvalue <LValueToRValue>
        |   `-DeclRefExpr {{address}} <col:25, col:32> '*i32' lvalue ParmVar {{address:pointer}} 'pointer' '*i32'
        `-ImplicitCastExpr {{address}} <col:35, col:36> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
          `-IntegerLiteral {{address}} <col:35, col:36> 'comptime_int' 1)");
}

TEST_F(SemaTest, DiagnosesInvalidDereferencesAndPreservesPointeeConst) {
  Analyze(R"(func invalid(number i32, pointer *void) {
*number;
*pointer;
}
func preserve(pointer *const i32) {
*pointer = 1;
})");

  ExpectError(1, 0, "unary operator '*' requires a pointer operand, not 'i32'", 7);
  ExpectError(2, 0, "unary operator '*' requires a pointer to an object, not '*void'", 8);
  ExpectError(5, 0, "assignment target must be a modifiable lvalue, not 'const i32'", 8);
}

TEST_F(SemaTest, FormsObjectAddressesAndPreservesPointeeConst) {
  Analyze(R"(func Inspect(mutable i32, readonly copy i32, link mut i32, source move i32,
             pointer *const i32) {
&mutable;
&readonly;
&link;
&source;
&*pointer;
&(mutable = 1);
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:9:2> Inspect 'func (i32, copy i32, mut i32, move i32, *const i32) void'
  |-ParmVarDecl {{address:mutable}} <line:1:14, col:25> mutable 'i32'
  | `-BuiltinType {{address}} <col:22, col:25> 'i32'
  |-ParmVarDecl {{address:readonly}} <col:27, col:44> readonly 'copy i32'
  | `-ReferenceType {{address}} <col:36, col:44> 'copy'
  |   `-BuiltinType {{address}} <col:41, col:44> 'i32'
  |-ParmVarDecl {{address:link}} <col:46, col:58> link 'mut i32'
  | `-ReferenceType {{address}} <col:51, col:58> 'mut'
  |   `-BuiltinType {{address}} <col:55, col:58> 'i32'
  |-ParmVarDecl {{address:source}} <col:60, col:75> source 'move i32'
  | `-ReferenceType {{address}} <col:67, col:75> 'move'
  |   `-BuiltinType {{address}} <col:72, col:75> 'i32'
  |-ParmVarDecl {{address:pointer}} <line:2:14, col:32> pointer '*const i32'
  | `-PointerType {{address}} <col:22, col:32>
  |   `-ConstType {{address}} <col:23, col:32>
  |     `-BuiltinType {{address}} <col:29, col:32> 'i32'
  `-CompoundStmt {{address}} <col:34, line:9:2>
    |-ExprStmt {{address}} <line:3:1, col:10>
    | `-UnaryOperator {{address}} <col:1, col:9> '*i32' pure-rvalue '&'
    |   `-DeclRefExpr {{address}} <col:2, col:9> 'i32' lvalue ParmVar {{address:mutable}} 'mutable' 'i32'
    |-ExprStmt {{address}} <line:4:1, col:11>
    | `-UnaryOperator {{address}} <col:1, col:10> '*const i32' pure-rvalue '&'
    |   `-DeclRefExpr {{address}} <col:2, col:10> 'const i32' lvalue ParmVar {{address:readonly}} 'readonly' 'copy i32'
    |-ExprStmt {{address}} <line:5:1, col:7>
    | `-UnaryOperator {{address}} <col:1, col:6> '*i32' pure-rvalue '&'
    |   `-DeclRefExpr {{address}} <col:2, col:6> 'i32' lvalue ParmVar {{address:link}} 'link' 'mut i32'
    |-ExprStmt {{address}} <line:6:1, col:9>
    | `-UnaryOperator {{address}} <col:1, col:8> '*i32' pure-rvalue '&'
    |   `-DeclRefExpr {{address}} <col:2, col:8> 'i32' lvalue ParmVar {{address:source}} 'source' 'move i32'
    |-ExprStmt {{address}} <line:7:1, col:11>
    | `-UnaryOperator {{address}} <col:1, col:10> '*const i32' pure-rvalue '&'
    |   `-UnaryOperator {{address}} <col:2, col:10> 'const i32' lvalue '*'
    |     `-ImplicitCastExpr {{address}} <col:3, col:10> '*const i32' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:3, col:10> '*const i32' lvalue ParmVar {{address:pointer}} 'pointer' '*const i32'
    `-ExprStmt {{address}} <line:8:1, col:16>
      `-UnaryOperator {{address}} <col:1, col:15> '*i32' pure-rvalue '&'
        `-ParenExpr {{address}} <col:2, col:15> 'i32' lvalue
          `-BinaryOperator {{address}} <col:3, col:14> 'i32' lvalue '='
            |-DeclRefExpr {{address}} <col:3, col:10> 'i32' lvalue ParmVar {{address:mutable}} 'mutable' 'i32'
            `-ImplicitCastExpr {{address}} <col:13, col:14> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
              `-IntegerLiteral {{address}} <col:13, col:14> 'comptime_int' 1)");
}

TEST_F(SemaTest, RejectsAddressOfNonLvaluesWithoutPartialResults) {
  Analyze(R"(func Make() i32 { 1 }
func Sink() {}
func Inspect(value i32) {
  &(move value);
  &1;
  &Make();
  &Sink();
})");

  ExpectError(3, 2, "unary operator '&' requires an object lvalue operand", 13);
  ExpectError(4, 2, "unary operator '&' requires an object lvalue operand", 2);
  ExpectError(5, 2, "unary operator '&' requires an object lvalue operand", 7);
  ExpectError(6, 2, "unary operator '&' requires an object lvalue operand", 7);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-FunctionDecl {{address:make}} <test.cw:1:1, col:22> Make 'func () i32'
| |-ReturnVarDecl {{address:return}} <col:13, col:16> 'i32'
| | `-BuiltinType {{address}} <col:13, col:16> 'i32'
| `-CompoundStmt {{address}} <col:17, col:22>
|   `-ImplicitResultInitializationExpr {{address}} <col:19, col:20> 'void' ReturnVar {{address:return}} 'i32'
|     `-ImplicitCastExpr {{address}} <col:19, col:20> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
|       `-IntegerLiteral {{address}} <col:19, col:20> 'comptime_int' 1
|-FunctionDecl {{address:sink}} <line:2:1, col:15> Sink 'func () void'
| `-CompoundStmt {{address}} <col:13, col:15>
`-FunctionDecl {{address}} <line:3:1, line:8:2> Inspect 'func (i32) void' contains-errors
  |-ParmVarDecl {{address:value}} <line:3:14, col:23> value 'i32'
  | `-BuiltinType {{address}} <col:20, col:23> 'i32'
  `-CompoundStmt {{address}} <col:25, line:8:2> contains-errors
    |-ExprStmt {{address}} <line:4:3, col:17> contains-errors
    | `-UnaryOperator {{address}} <col:3, col:16> '&' contains-errors
    |   `-ParenExpr {{address}} <col:4, col:16> 'i32' move-lvalue
    |     `-UnaryOperator {{address}} <col:5, col:15> 'i32' move-lvalue 'move'
    |       `-DeclRefExpr {{address}} <col:10, col:15> 'i32' lvalue ParmVar {{address:value}} 'value' 'i32'
    |-ExprStmt {{address}} <line:5:3, col:6> contains-errors
    | `-UnaryOperator {{address}} <col:3, col:5> '&' contains-errors
    |   `-ImplicitCastExpr {{address}} <col:4, col:5> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    |     `-IntegerLiteral {{address}} <col:4, col:5> 'comptime_int' 1
    |-ExprStmt {{address}} <line:6:3, col:11> contains-errors
    | `-UnaryOperator {{address}} <col:3, col:10> '&' contains-errors
    |   `-CallExpr {{address}} <col:4, col:10> 'i32' pure-rvalue
    |     `-DeclRefExpr {{address}} <col:4, col:8> 'func () i32' Function {{address:make}} 'Make' 'func () i32'
    `-ExprStmt {{address}} <line:7:3, col:11> contains-errors
      `-UnaryOperator {{address}} <col:3, col:10> '&' contains-errors
        `-CallExpr {{address}} <col:4, col:10> 'void'
          `-DeclRefExpr {{address}} <col:4, col:8> 'func () void' Function {{address:sink}} 'Sink' 'func () void')");
}

TEST_F(SemaTest, PreventsMutationThroughAddressOfConstObject) {
  Analyze(R"(func Inspect(readonly copy i32) {
  var pointer := &readonly;
  *pointer = 1;
})");

  ExpectError(2, 2, "assignment target must be a modifiable lvalue, not 'const i32'", 8);
}

// Pointer null values, equality, and conditional results.

TEST_F(SemaTest, FormsPointerNullWithoutRetypingItsLiteral) {
  Analyze("var p *i32 := null;");
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-VarGroupDecl {{address}} <test.cw:1:1, col:20>
  |-VarDecl {{address}} <col:5, col:11> p '*i32'
  | `-PointerType {{address}} <col:7, col:11>
  |   `-BuiltinType {{address}} <col:8, col:11> 'i32'
  `-ImplicitCastExpr {{address}} <col:15, col:19> '*i32' pure-rvalue <NullToPointer>
    `-NullLiteral {{address}} <col:15, col:19> '<null>')");
}

TEST_F(SemaTest, PreservesNullEqualityAndRequiredPointerReadsInAst) {
  Analyze(R"(func Check(p *i32) {
p == null;
null != p;
null == null;
null != null;
})");
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:6:2> Check 'func (*i32) void'
  |-ParmVarDecl {{address:p}} <line:1:12, col:18> p '*i32'
  | `-PointerType {{address}} <col:14, col:18>
  |   `-BuiltinType {{address}} <col:15, col:18> 'i32'
  `-CompoundStmt {{address}} <col:20, line:6:2>
    |-ExprStmt {{address}} <line:2:1, col:11>
    | `-BinaryOperator {{address}} <col:1, col:10> 'bool' pure-rvalue '=='
    |   |-ImplicitCastExpr {{address}} <col:1, col:2> '*i32' pure-rvalue <LValueToRValue>
    |   | `-DeclRefExpr {{address}} <col:1, col:2> '*i32' lvalue ParmVar {{address:p}} 'p' '*i32'
    |   `-ImplicitCastExpr {{address}} <col:6, col:10> '*i32' pure-rvalue <NullToPointer>
    |     `-NullLiteral {{address}} <col:6, col:10> '<null>'
    |-ExprStmt {{address}} <line:3:1, col:11>
    | `-BinaryOperator {{address}} <col:1, col:10> 'bool' pure-rvalue '!='
    |   |-ImplicitCastExpr {{address}} <col:1, col:5> '*i32' pure-rvalue <NullToPointer>
    |   | `-NullLiteral {{address}} <col:1, col:5> '<null>'
    |   `-ImplicitCastExpr {{address}} <col:9, col:10> '*i32' pure-rvalue <LValueToRValue>
    |     `-DeclRefExpr {{address}} <col:9, col:10> '*i32' lvalue ParmVar {{address:p}} 'p' '*i32'
    |-ExprStmt {{address}} <line:4:1, col:14>
    | `-BinaryOperator {{address}} <col:1, col:13> 'bool' pure-rvalue '=='
    |   |-NullLiteral {{address}} <col:1, col:5> '<null>'
    |   `-NullLiteral {{address}} <col:9, col:13> '<null>'
    `-ExprStmt {{address}} <line:5:1, col:14>
      `-BinaryOperator {{address}} <col:1, col:13> 'bool' pure-rvalue '!='
        |-NullLiteral {{address}} <col:1, col:5> '<null>'
        `-NullLiteral {{address}} <col:9, col:13> '<null>')");
}

TEST_F(SemaTest, MaterializesNullPointerReferenceArgumentsAfterFormation) {
  Analyze(R"(func TakeMove(value move *func () void) {}
func TakeCopy(value copy *func () void) {}
func Use() {
  TakeMove(null);
  TakeCopy(null);
})");
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-FunctionDecl {{address:take_move}} <test.cw:1:1, col:43> TakeMove 'func (move *func () void) void'
| |-ParmVarDecl {{address}} <col:15, col:39> value 'move *func () void'
| | `-ReferenceType {{address}} <col:21, col:39> 'move'
| |   `-PointerType {{address}} <col:26, col:39>
| |     `-FunctionType {{address}} <col:27, col:39>
| |       `-BuiltinType {{address}} <col:35, col:39> 'void'
| `-CompoundStmt {{address}} <col:41, col:43>
|-FunctionDecl {{address:take_copy}} <line:2:1, col:43> TakeCopy 'func (copy *func () void) void'
| |-ParmVarDecl {{address}} <col:15, col:39> value 'copy *func () void'
| | `-ReferenceType {{address}} <col:21, col:39> 'copy'
| |   `-PointerType {{address}} <col:26, col:39>
| |     `-FunctionType {{address}} <col:27, col:39>
| |       `-BuiltinType {{address}} <col:35, col:39> 'void'
| `-CompoundStmt {{address}} <col:41, col:43>
`-FunctionDecl {{address}} <line:3:1, line:6:2> Use 'func () void'
  `-CompoundStmt {{address}} <line:3:12, line:6:2>
    |-ExprStmt {{address}} <line:4:3, col:18>
    | `-CallExpr {{address}} <col:3, col:17> 'void'
    |   |-DeclRefExpr {{address}} <col:3, col:11> 'func (move *func () void) void' Function {{address:take_move}} 'TakeMove' 'func (move *func () void) void'
    |   `-MaterializeTemporaryExpr {{address}} <col:12, col:16> '*func () void' move-lvalue
    |     `-ImplicitCastExpr {{address}} <col:12, col:16> '*func () void' pure-rvalue <NullToPointer>
    |       `-NullLiteral {{address}} <col:12, col:16> '<null>'
    `-ExprStmt {{address}} <line:5:3, col:18>
      `-CallExpr {{address}} <col:3, col:17> 'void'
        |-DeclRefExpr {{address}} <col:3, col:11> 'func (copy *func () void) void' Function {{address:take_copy}} 'TakeCopy' 'func (copy *func () void) void'
        `-ImplicitCastExpr {{address}} <col:12, col:16> 'const *func () void' move-lvalue <NoOp>
          `-MaterializeTemporaryExpr {{address}} <col:12, col:16> '*func () void' move-lvalue
            `-ImplicitCastExpr {{address}} <col:12, col:16> '*func () void' pure-rvalue <NullToPointer>
              `-NullLiteral {{address}} <col:12, col:16> '<null>')");
}

TEST_F(SemaTest, UsesNullAcrossPointerInitializationAssignmentArgumentsAndResults) {
  Analyze(R"(trivial struct Owner {}
trivial struct Fields {
  pointer *i32;
  callback *func () void;
  slot virtual *func (mut Owner) void;
}
var global *i32 := null;
var grouped *i32, callback *func () void := { null, null }
func ReturnNull() *i32 { null }
func Take(value *i32) {}
func TakeCopy(value copy *i32) {}
func TakeMove(value move *i32) {}
func TakeSlot(value copy virtual *func (mut Owner) void) {}
func TakeSlotMove(value move virtual *func (mut Owner) void) {}
func Use(index usize) {
  var pointer *i32 := null;
  var nested **const i32 := (null);
  var qualified *const *const i32 := null;
  var fixed const *i32 := null;
  var values [2] *i32 := [2] *i32 { null, (null) };
  var fields Fields;
  fields.pointer := null;
  fields.callback := null;
  fields.slot := null;
  var reference mut *i32 := pointer;
  reference = null;
  global = null;
  callback = null;
  values[index] = null;
  fields.pointer = null;
  fields.callback = null;
  fields.slot = null;
  Take(null);
  TakeCopy(null);
  TakeMove(null);
  TakeSlot(null);
  TakeSlotMove(null);
  var indirect *func (*i32) void := &Take;
  indirect(null);
  Take(ReturnNull());
  var formed Fields := Fields();
  formed.pointer == null;
  formed.callback != null;
  formed.slot == null;
})");
}

TEST_F(SemaTest, AllowsPointerEqualityAndCommonConditionalTargetsSymmetrically) {
  Analyze(R"(trivial struct Base {}
trivial struct Derived : Base {}
func Common(value move *const *const i32) {}
func BaseValue(value move *const Base) {}
func Check(flag bool, p *i32, cp *const i32, pp **i32, cpp **const i32,
           base *Base, derived *const Derived, callback *func () void,
           slot virtual *func (mut Base) void) {
  p == p;
  p != p;
  p == cp;
  cp == p;
  p != cp;
  cp != p;
  pp == cpp;
  cpp != pp;
  derived == base;
  base != derived;
  callback == null;
  null == callback;
  callback != null;
  null != callback;
  slot == null;
  null == slot;
  slot != null;
  null != slot;
  (null) == (null);
  (null) != null;
  Common(flag ? pp : cpp);
  Common(flag ? cpp : pp);
  BaseValue(flag ? base : derived);
  BaseValue(flag ? derived : base);
  var selected := flag ? p : null;
  var reversed := flag ? null : p;
  var same mut *i32 := flag ? selected : reversed;
  same = null;
  var selected_callback := flag ? callback : null;
  var selected_slot := flag ? null : slot;
  selected_callback == null;
  selected_slot != null;
  var same_callback mut *func () void := flag ? callback : selected_callback;
  same_callback = null;
})");
}

TEST_F(SemaTest, OrdersNullReferenceModesAndOtherArgumentsThroughOrdinaryOverloadRules) {
  Analyze(R"(func NeedInteger(value i32) {}
func Ref(value copy *i32) bool { false }
func Ref(value move *i32) i32 { 1 }
func Other(value *i32, test bool) bool { false }
func Other(value *const i32, test i32) i32 { 1 }
func Reverse(value *const i32, test i32) i32 { 1 }
func Reverse(value *i32, test bool) bool { false }
func Typed(value *i32) i32 { 1 }
func Typed(value *const i32) bool { false }
func Use() {
  NeedInteger(Ref(null));
  NeedInteger(Other(null, 0));
  NeedInteger(Reverse(null, 0));
  var pointer *i32 := null;
  NeedInteger(Typed(pointer));
})");
}

TEST_F(SemaTest, RecordsCommonPointerConversionsInsideComparisonAndConditionalOperands) {
  Analyze(R"(func Check(p **i32, q **const i32, flag bool) {
p == q;
flag ? p : q;
flag ? null : p;
})");
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:5:2> Check 'func (**i32, **const i32, bool) void'
  |-ParmVarDecl {{address:p}} <line:1:12, col:19> p '**i32'
  | `-PointerType {{address}} <col:14, col:19>
  |   `-PointerType {{address}} <col:15, col:19>
  |     `-BuiltinType {{address}} <col:16, col:19> 'i32'
  |-ParmVarDecl {{address:q}} <col:21, col:34> q '**const i32'
  | `-PointerType {{address}} <col:23, col:34>
  |   `-PointerType {{address}} <col:24, col:34>
  |     `-ConstType {{address}} <col:25, col:34>
  |       `-BuiltinType {{address}} <col:31, col:34> 'i32'
  |-ParmVarDecl {{address:flag}} <col:36, col:45> flag 'bool'
  | `-BuiltinType {{address}} <col:41, col:45> 'bool'
  `-CompoundStmt {{address}} <col:47, line:5:2>
    |-ExprStmt {{address}} <line:2:1, col:8>
    | `-BinaryOperator {{address}} <col:1, col:7> 'bool' pure-rvalue '=='
    |   |-ImplicitCastExpr {{address}} <col:1, col:2> '*const *const i32' pure-rvalue <Qualification>
    |   | `-ImplicitCastExpr {{address}} <col:1, col:2> '**i32' pure-rvalue <LValueToRValue>
    |   |   `-DeclRefExpr {{address}} <col:1, col:2> '**i32' lvalue ParmVar {{address:p}} 'p' '**i32'
    |   `-ImplicitCastExpr {{address}} <col:6, col:7> '*const *const i32' pure-rvalue <Qualification>
    |     `-ImplicitCastExpr {{address}} <col:6, col:7> '**const i32' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:6, col:7> '**const i32' lvalue ParmVar {{address:q}} 'q' '**const i32'
    |-ExprStmt {{address}} <line:3:1, col:14>
    | `-ConditionalOperator {{address}} <col:1, col:13> '*const *const i32' pure-rvalue
    |   |-ImplicitCastExpr {{address}} <col:1, col:5> 'bool' pure-rvalue <LValueToRValue>
    |   | `-DeclRefExpr {{address}} <col:1, col:5> 'bool' lvalue ParmVar {{address:flag}} 'flag' 'bool'
    |   |-ImplicitCastExpr {{address}} <col:8, col:9> '*const *const i32' pure-rvalue <Qualification>
    |   | `-ImplicitCastExpr {{address}} <col:8, col:9> '**i32' pure-rvalue <LValueToRValue>
    |   |   `-DeclRefExpr {{address}} <col:8, col:9> '**i32' lvalue ParmVar {{address:p}} 'p' '**i32'
    |   `-ImplicitCastExpr {{address}} <col:12, col:13> '*const *const i32' pure-rvalue <Qualification>
    |     `-ImplicitCastExpr {{address}} <col:12, col:13> '**const i32' pure-rvalue <LValueToRValue>
    |       `-DeclRefExpr {{address}} <col:12, col:13> '**const i32' lvalue ParmVar {{address:q}} 'q' '**const i32'
    `-ExprStmt {{address}} <line:4:1, col:17>
      `-ConditionalOperator {{address}} <col:1, col:16> '**i32' pure-rvalue
        |-ImplicitCastExpr {{address}} <col:1, col:5> 'bool' pure-rvalue <LValueToRValue>
        | `-DeclRefExpr {{address}} <col:1, col:5> 'bool' lvalue ParmVar {{address:flag}} 'flag' 'bool'
        |-ImplicitCastExpr {{address}} <col:8, col:12> '**i32' pure-rvalue <NullToPointer>
        | `-NullLiteral {{address}} <col:8, col:12> '<null>'
        `-ImplicitCastExpr {{address}} <col:15, col:16> '**i32' pure-rvalue <LValueToRValue>
          `-DeclRefExpr {{address}} <col:15, col:16> '**i32' lvalue ParmVar {{address:p}} 'p' '**i32')");
}

TEST_F(SemaTest, RecordsPointerBaseAdjustmentBeforeQualificationForEquality) {
  Analyze(R"(trivial struct Base {}
trivial struct Derived : Base {}
func Check(d *Derived, b *const Base) {
d == b;
})");
  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address:base}} <test.cw:1:1, col:23> Base trivial
|-StructDecl {{address}} <line:2:1, col:33> Derived trivial : 'Base'
| `-BaseType 'Base' Struct {{address:base}} 'Base'
`-FunctionDecl {{address}} <line:3:1, line:5:2> Check 'func (*Derived, *const Base) void'
  |-ParmVarDecl {{address:d}} <line:3:12, col:22> d '*Derived'
  | `-PointerType {{address}} <col:14, col:22>
  |   `-NamedType {{address}} <col:15, col:22> 'Derived'
  |-ParmVarDecl {{address:b}} <col:24, col:37> b '*const Base'
  | `-PointerType {{address}} <col:26, col:37>
  |   `-ConstType {{address}} <col:27, col:37>
  |     `-NamedType {{address}} <col:33, col:37> 'Base'
  `-CompoundStmt {{address}} <col:39, line:5:2>
    `-ExprStmt {{address}} <line:4:1, col:8>
      `-BinaryOperator {{address}} <col:1, col:7> 'bool' pure-rvalue '=='
        |-ImplicitCastExpr {{address}} <col:1, col:2> '*const Base' pure-rvalue <Qualification>
        | `-ImplicitCastExpr {{address}} <col:1, col:2> '*Base' pure-rvalue <DerivedToBase> path Struct {{address:base}} 'Base'
        |   `-ImplicitCastExpr {{address}} <col:1, col:2> '*Derived' pure-rvalue <LValueToRValue>
        |     `-DeclRefExpr {{address}} <col:1, col:2> '*Derived' lvalue ParmVar {{address:d}} 'd' '*Derived'
        `-ImplicitCastExpr {{address}} <col:6, col:7> '*const Base' pure-rvalue <LValueToRValue>
          `-DeclRefExpr {{address}} <col:6, col:7> '*const Base' lvalue ParmVar {{address:b}} 'b' '*const Base')");
}

TEST_F(SemaTest, PreservesPointerConditionalCategoriesAndMergesDeeperConstBarriers) {
  Analyze(R"(func Common(value move *const *const *const i32) {}
func Copy(value copy *i32) {}
func Move(value move *i32) {}
func Use(flag bool, p *i32, fixed copy *i32, deep *const **i32, deeper ***const i32) {
  Common(flag ? deep : deeper);
  Common(flag ? deeper : deep);
  Copy(flag ? p : fixed);
  Move(flag ? move p : move p);
  Move(flag ? fixed : null);
})");
}

TEST_F(SemaTest, StillRequiresPointerInitializationBeforeNullChecks) {
  Analyze(R"(func Use() {
var p *i32;
p == null;
})");
  ExpectError(2, 0, "use of uninitialized variable 'p'", 1);
}

TEST_F(SemaTest, RejectsNullObjectInferenceInLocalAndGlobalDeclarations) {
  Analyze(R"(var global := null;
func Use() {
var local := (null);
})");
  ExpectError(0, 14, "cannot infer an object type from expression of type '<null>'", 4);
  ExpectError(2, 13, "cannot infer an object type from expression of type '<null>'", 6);
}

TEST_F(SemaTest, RejectsNullConversionsToNonPointersAndIntegerZeroToPointer) {
  Analyze(R"(func Integer() { var n i32 := null; }
func Boolean() { var b bool := null; }
func Zero() { var p *i32 := 0; })");
  ExpectError(0, 30, "cannot initialize variable 'n': no implicit conversion from '<null>' to 'i32'", 4);
  ExpectError(1, 31, "cannot initialize variable 'b': no implicit conversion from '<null>' to 'bool'", 4);
  ExpectError(2, 28, "cannot initialize variable 'p': no implicit conversion from 'i32' to '*i32'", 1);
}

TEST_F(SemaTest, RejectsAggregateNullInitializationAndCrossTypeUseOfTypedNullPointers) {
  Analyze(R"(trivial struct Empty {}
func Use() {
var p *i32 := null;
var q *f64 := p;
var r Empty := null;
var a [1] *i32 := null;
var n i32 := 1;
n = null;
})");
  ExpectError(3, 14, "cannot initialize variable 'q': no implicit conversion from '*i32' to '*f64'", 1);
  ExpectError(4, 15, "cannot initialize variable 'r': no implicit conversion from '<null>' to 'Empty'", 4);
  ExpectError(5, 18, "cannot initialize variable 'a': no implicit conversion from '<null>' to '[1] *i32'", 4);
  ExpectError(7, 4, "cannot assign to target: no implicit conversion from '<null>' to 'i32'", 4);
}

TEST_F(SemaTest, RejectsTwoNullConditionalBranchesDespiteAnOuterPointerTarget) {
  Analyze(R"(func Use(flag bool) {
var p *i32 := flag ? null : null;
})");
  ExpectError(1, 21, "type '<null>' cannot be used as a conditional value result", 11);
}

TEST_F(SemaTest, RejectsUntargetedFunctionAddressAndNullConditionalBranches) {
  Analyze(R"(func F() {}
func Use(flag bool) {
var callback *func () void := flag ? &F : null;
})");
  ExpectError(
      2, 37,
      "conditional expression has no common result type for a function address without a target type and type '<null>'",
      9);
}

TEST_F(SemaTest, RejectsFunctionPointerEqualityBeyondNullChecks) {
  Analyze(R"(trivial struct Owner {}
func F() {}
func Use(f *func () void, s virtual *func (mut Owner) void) {
f == f;
f != f;
s == s;
s != s;
f == s;
f == &F;
&F != f;
&F == null;
null != &F;
var empty *func () void := null;
empty == empty;
})");
  ExpectError(3, 0, "binary operator '==' cannot be applied to types '*func () void' and '*func () void'", 6);
  ExpectError(4, 0, "binary operator '!=' cannot be applied to types '*func () void' and '*func () void'", 6);
  ExpectError(
      5, 0,
      "binary operator '==' cannot be applied to types 'virtual *func (mut Owner) void' and 'virtual *func (mut Owner) void'",
      6);
  ExpectError(
      6, 0,
      "binary operator '!=' cannot be applied to types 'virtual *func (mut Owner) void' and 'virtual *func (mut Owner) void'",
      6);
  ExpectError(
      7, 0, "binary operator '==' cannot be applied to types '*func () void' and 'virtual *func (mut Owner) void'", 6);
  ExpectError(
      8, 0,
      "binary operator '==' cannot be applied to type '*func () void' and a function address without a target type", 7);
  ExpectError(
      9, 0,
      "binary operator '!=' cannot be applied to a function address without a target type and type '*func () void'", 7);
  ExpectError(10, 0,
              "binary operator '==' cannot be applied to a function address without a target type and type '<null>'",
              10);
  ExpectError(11, 0,
              "binary operator '!=' cannot be applied to type '<null>' and a function address without a target type",
              10);
  ExpectError(13, 0, "binary operator '==' cannot be applied to types '*func () void' and '*func () void'", 14);
}

TEST_F(SemaTest, RejectsUnsupportedRawPointerComparisonsAndTruthConversions) {
  Analyze(R"(trivial struct Base {}
trivial struct Left : Base {}
trivial struct Right : Base {}
func Use(p *i32, q *f64, v *void, left *Left, right *Right, b **Base, d **Left) {
p == q;
q != p;
p == v;
left == right;
b == d;
d != b;
p == 0;
0 != p;
p < p;
p && p;
!p;
!null;
null == 0;
})");
  ExpectError(4, 0, "binary operator '==' cannot be applied to types '*i32' and '*f64'", 6);
  ExpectError(5, 0, "binary operator '!=' cannot be applied to types '*f64' and '*i32'", 6);
  ExpectError(6, 0, "binary operator '==' cannot be applied to types '*i32' and '*void'", 6);
  ExpectError(7, 0, "binary operator '==' cannot be applied to types '*Left' and '*Right'", 13);
  ExpectError(8, 0, "binary operator '==' cannot be applied to types '**Base' and '**Left'", 6);
  ExpectError(9, 0, "binary operator '!=' cannot be applied to types '**Left' and '**Base'", 6);
  ExpectError(10, 0, "binary operator '==' cannot be applied to types '*i32' and 'i32'", 6);
  ExpectError(11, 0, "binary operator '!=' cannot be applied to types 'i32' and '*i32'", 6);
  ExpectError(12, 0, "binary operator '<' cannot be applied to types '*i32' and '*i32'", 5);
  ExpectError(13, 0, "binary operator '&&' cannot be applied to types '*i32' and '*i32'", 6);
  ExpectError(14, 0, "unary operator '!' cannot be applied to type '*i32'", 2);
  ExpectError(15, 0, "unary operator '!' cannot be applied to type '<null>'", 5);
  ExpectError(16, 0, "binary operator '==' cannot be applied to types '<null>' and 'i32'", 9);
}

struct NullTargetPair {
  const char* left;
  const char* right;
};
class NullTargetOrderTest : public SemaTest, public ::testing::WithParamInterface<NullTargetPair> {};

TEST_P(NullTargetOrderTest, PreservesAmbiguityInBothDeclarationOrders) {
  const auto [left, right] = GetParam();
  std::string source = "trivial struct Base {}\ntrivial struct Derived : Base {}\n";
  source += std::string("func Pick(value ") + left + ") {}\n";
  source += std::string("func Pick(value ") + right + ") {}\n";
  source += std::string("func Reverse(value ") + right + ") {}\n";
  source += std::string("func Reverse(value ") + left + ") {}\n";
  source += "func Use() {\nPick(null);\nReverse(null);\n}";
  Analyze(source);
  ExpectError(7, 0, "call to 'Pick' is ambiguous", 10);
  ExpectNote(2, 0, "candidate function", 0);
  ExpectNote(3, 0, "candidate function", 0);
  ExpectError(8, 0, "call to 'Reverse' is ambiguous", 13);
  ExpectNote(4, 0, "candidate function", 0);
  ExpectNote(5, 0, "candidate function", 0);
}

INSTANTIATE_TEST_SUITE_P(NullTargets, NullTargetOrderTest,
                         ::testing::Values(NullTargetPair{"*i32", "*const i32"}, NullTargetPair{"*Derived", "*Base"},
                                           NullTargetPair{"*i32", "*func () void"},
                                           NullTargetPair{"*func () void", "virtual *func (mut Base) void"},
                                           NullTargetPair{"move *i32", "copy *const i32"},
                                           NullTargetPair{"*i32", "copy *i32"}, NullTargetPair{"*i32", "move *i32"},
                                           NullTargetPair{"*i32", "*f64"}, NullTargetPair{"**i32", "**const i32"}));

TEST_F(SemaTest, LeavesNullUnconvertedWhenMutableReferenceBindingFails) {
  Analyze(R"(func Use() {
var p mut *i32 := null;
})");
  ExpectError(1, 18,
              "cannot initialize variable 'p': reference type 'mut *i32' cannot bind to pure rvalue of type '*i32'", 4);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, line:3:2> Use 'func () void' contains-errors
  `-CompoundStmt {{address}} <line:1:12, line:3:2> contains-errors
    `-DeclStmt {{address}} <line:2:1, col:24> contains-errors
      `-VarGroupDecl {{address}} <col:1, col:24> contains-errors
        |-VarDecl {{address}} <col:5, col:15> p 'mut *i32'
        | `-ReferenceType {{address}} <col:7, col:15> 'mut'
        |   `-PointerType {{address}} <col:11, col:15>
        |     `-BuiltinType {{address}} <col:12, col:15> 'i32'
        `-NullLiteral {{address}} <col:19, col:23> '<null>' contains-errors)");
}

TEST_F(SemaTest, ReportsNonPointerAndMutableReferenceCandidatesAsNotViableForNull) {
  Analyze(R"(func Pick(value i32) {}
func Pick(value bool) {}
func Pick(value mut *i32) {}
func Use() { Pick(null); })");
  ExpectError(3, 13, "no matching function for call to 'Pick'", 10);
  ExpectNote(0, 0, "candidate function is not viable: no implicit conversion from '<null>' to 'i32' for argument 1", 0);
  ExpectNote(1, 0, "candidate function is not viable: no implicit conversion from '<null>' to 'bool' for argument 1",
             0);
  ExpectNote(
      2, 0,
      "candidate function is not viable: reference type 'mut *i32' cannot bind to pure rvalue of type '*i32' for argument 1",
      0);
}

// Const moving lvalues.

TEST_F(SemaTest, PreservesMovingCategoryWhenBindingCopyReferences) {
  Analyze(R"(func Copy(x copy i32) {}
func Use(x copy i32, y mut i32) {
  Copy(move x);
  Copy(move y);
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-FunctionDecl {{address:copy}} <test.cw:1:1, col:25> Copy 'func (copy i32) void'
| |-ParmVarDecl {{address}} <col:11, col:21> x 'copy i32'
| | `-ReferenceType {{address}} <col:13, col:21> 'copy'
| |   `-BuiltinType {{address}} <col:18, col:21> 'i32'
| `-CompoundStmt {{address}} <col:23, col:25>
`-FunctionDecl {{address}} <line:2:1, line:5:2> Use 'func (copy i32, mut i32) void'
  |-ParmVarDecl {{address:x}} <line:2:10, col:20> x 'copy i32'
  | `-ReferenceType {{address}} <col:12, col:20> 'copy'
  |   `-BuiltinType {{address}} <col:17, col:20> 'i32'
  |-ParmVarDecl {{address:y}} <col:22, col:31> y 'mut i32'
  | `-ReferenceType {{address}} <col:24, col:31> 'mut'
  |   `-BuiltinType {{address}} <col:28, col:31> 'i32'
  `-CompoundStmt {{address}} <col:33, line:5:2>
    |-ExprStmt {{address}} <line:3:3, col:16>
    | `-CallExpr {{address}} <col:3, col:15> 'void'
    |   |-DeclRefExpr {{address}} <col:3, col:7> 'func (copy i32) void' Function {{address:copy}} 'Copy' 'func (copy i32) void'
    |   `-UnaryOperator {{address}} <col:8, col:14> 'const i32' move-lvalue 'move'
    |     `-DeclRefExpr {{address}} <col:13, col:14> 'const i32' lvalue ParmVar {{address:x}} 'x' 'copy i32'
    `-ExprStmt {{address}} <line:4:3, col:16>
      `-CallExpr {{address}} <col:3, col:15> 'void'
        |-DeclRefExpr {{address}} <col:3, col:7> 'func (copy i32) void' Function {{address:copy}} 'Copy' 'func (copy i32) void'
        `-ImplicitCastExpr {{address}} <col:8, col:14> 'const i32' move-lvalue <NoOp>
          `-UnaryOperator {{address}} <col:8, col:14> 'i32' move-lvalue 'move'
            `-DeclRefExpr {{address}} <col:13, col:14> 'i32' lvalue ParmVar {{address:y}} 'y' 'mut i32')");
}

TEST_F(SemaTest, SelectsCopyOperationsForConstMovingObjectsWithBothOperations) {
  Analyze(R"(struct T {}
ctor T(x copy T) {}
ctor T(x move T) {}
dtor T() {}
func operator=(x mut T, y copy T) {}
func operator=(x mut T, y move T) {}
func Use(x mut T, y copy T) T {
  x = move y;
  move y
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address:t}} <test.cw:1:1, col:12> T
|-ConstructorDecl {{address:copy_ctor}} <line:2:1, col:20> T target Struct {{address:t}} 'T' 'func (copy T) void'
| |-ParmVarDecl {{address}} <col:8, col:16> x 'copy T'
| | `-ReferenceType {{address}} <col:10, col:16> 'copy'
| |   `-NamedType {{address}} <col:15, col:16> 'T'
| `-CompoundStmt {{address}} <col:18, col:20>
|-ConstructorDecl {{address:move_ctor}} <line:3:1, col:20> T target Struct {{address:t}} 'T' 'func (move T) void'
| |-ParmVarDecl {{address}} <col:8, col:16> x 'move T'
| | `-ReferenceType {{address}} <col:10, col:16> 'move'
| |   `-NamedType {{address}} <col:15, col:16> 'T'
| `-CompoundStmt {{address}} <col:18, col:20>
|-DestructorDecl {{address}} <line:4:1, col:12> T target Struct {{address:t}} 'T' 'func () void'
| `-CompoundStmt {{address}} <col:10, col:12>
|-FunctionDecl {{address:copy_assign}} <line:5:1, col:37> operator= 'func (mut T, copy T) void'
| |-ParmVarDecl {{address}} <col:16, col:23> x 'mut T'
| | `-ReferenceType {{address}} <col:18, col:23> 'mut'
| |   `-NamedType {{address}} <col:22, col:23> 'T'
| |-ParmVarDecl {{address}} <col:25, col:33> y 'copy T'
| | `-ReferenceType {{address}} <col:27, col:33> 'copy'
| |   `-NamedType {{address}} <col:32, col:33> 'T'
| `-CompoundStmt {{address}} <col:35, col:37>
|-FunctionDecl {{address:move_assign}} <line:6:1, col:37> operator= 'func (mut T, move T) void'
| |-ParmVarDecl {{address}} <col:16, col:23> x 'mut T'
| | `-ReferenceType {{address}} <col:18, col:23> 'mut'
| |   `-NamedType {{address}} <col:22, col:23> 'T'
| |-ParmVarDecl {{address}} <col:25, col:33> y 'move T'
| | `-ReferenceType {{address}} <col:27, col:33> 'move'
| |   `-NamedType {{address}} <col:32, col:33> 'T'
| `-CompoundStmt {{address}} <col:35, col:37>
`-FunctionDecl {{address}} <line:7:1, line:10:2> Use 'func (mut T, copy T) T'
  |-ParmVarDecl {{address:x}} <line:7:10, col:17> x 'mut T'
  | `-ReferenceType {{address}} <col:12, col:17> 'mut'
  |   `-NamedType {{address}} <col:16, col:17> 'T'
  |-ParmVarDecl {{address:y}} <col:19, col:27> y 'copy T'
  | `-ReferenceType {{address}} <col:21, col:27> 'copy'
  |   `-NamedType {{address}} <col:26, col:27> 'T'
  |-ReturnVarDecl {{address:result}} <col:29, col:30> 'T'
  | `-NamedType {{address}} <col:29, col:30> 'T'
  `-CompoundStmt {{address}} <col:31, line:10:2>
    |-ExprStmt {{address}} <line:8:3, col:14>
    | `-OperatorCallExpr {{address}} <col:3, col:13> 'void'
    |   |-DeclRefExpr {{address}} <col:5, col:6> 'func (mut T, copy T) void' Function {{address:copy_assign}} 'operator=' 'func (mut T, copy T) void'
    |   |-DeclRefExpr {{address}} <col:3, col:4> 'T' lvalue ParmVar {{address:x}} 'x' 'mut T'
    |   `-UnaryOperator {{address}} <col:7, col:13> 'const T' move-lvalue 'move'
    |     `-DeclRefExpr {{address}} <col:12, col:13> 'const T' lvalue ParmVar {{address:y}} 'y' 'copy T'
    `-ImplicitResultInitializationExpr {{address}} <line:9:3, col:9> 'void' ReturnVar {{address:result}} 'T'
      `-ConstructionExpr {{address}} <col:3, col:9> 'T' pure-rvalue complete-object Constructor {{address:copy_ctor}} 'T' 'func (copy T) void'
        `-UnaryOperator {{address}} <col:3, col:9> 'const T' move-lvalue 'move'
          `-DeclRefExpr {{address}} <col:8, col:9> 'const T' lvalue ParmVar {{address:y}} 'y' 'copy T')");
}

TEST_F(SemaTest, MergesConstOnMovingConditionalWithoutConvertingItsBranches) {
  Analyze(R"(func F(b bool, x mut i32, y copy i32) {
  b ? move x : move y;
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:3:2> F 'func (bool, mut i32, copy i32) void'
  |-ParmVarDecl {{address:b}} <line:1:8, col:14> b 'bool'
  | `-BuiltinType {{address}} <col:10, col:14> 'bool'
  |-ParmVarDecl {{address:x}} <col:16, col:25> x 'mut i32'
  | `-ReferenceType {{address}} <col:18, col:25> 'mut'
  |   `-BuiltinType {{address}} <col:22, col:25> 'i32'
  |-ParmVarDecl {{address:y}} <col:27, col:37> y 'copy i32'
  | `-ReferenceType {{address}} <col:29, col:37> 'copy'
  |   `-BuiltinType {{address}} <col:34, col:37> 'i32'
  `-CompoundStmt {{address}} <col:39, line:3:2>
    `-ExprStmt {{address}} <line:2:3, col:23>
      `-ConditionalOperator {{address}} <col:3, col:22> 'const i32' move-lvalue
        |-ImplicitCastExpr {{address}} <col:3, col:4> 'bool' pure-rvalue <LValueToRValue>
        | `-DeclRefExpr {{address}} <col:3, col:4> 'bool' lvalue ParmVar {{address:b}} 'b' 'bool'
        |-UnaryOperator {{address}} <col:7, col:13> 'i32' move-lvalue 'move'
        | `-DeclRefExpr {{address}} <col:12, col:13> 'i32' lvalue ParmVar {{address:x}} 'x' 'mut i32'
        `-UnaryOperator {{address}} <col:16, col:22> 'const i32' move-lvalue 'move'
          `-DeclRefExpr {{address}} <col:21, col:22> 'const i32' lvalue ParmVar {{address:y}} 'y' 'copy i32')");
}

TEST_F(SemaTest, ConsumesConstMovingFieldAndArrayProjections) {
  Analyze(R"(trivial struct S { value const i32; }
func Copy(value copy i32) {}
func Borrow(value copy i32) copy i32 { value }
func Use(object mut S, array mut [1] const i32, index usize) i32 {
  S().value;
  Copy(S().value);
  var field := (move object).value;
  var element := (move array)[index];
  var temporary := [1] const i32 { 1 }[index];
  var nested := [1] [1] const i32 { { 1 } }[index][index];
  var address *const i32 := &Borrow((move object).value);
  S().value
})");
}

TEST_F(SemaTest, PreservesConstMovingCategoryOfFieldAndElementProjections) {
  Analyze(R"(trivial struct S { x const i32; }
func F(s mut S, a mut [1] const i32, i usize) {
  (move s).x;
  (move a)[i];
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address:s_type}} <test.cw:1:1, col:34> S trivial
| `-FieldDecl {{address:x}} <col:20, col:32> x 'const i32'
|   `-ConstType {{address}} <col:22, col:31>
|     `-BuiltinType {{address}} <col:28, col:31> 'i32'
`-FunctionDecl {{address}} <line:2:1, line:5:2> F 'func (mut S, mut [1] const i32, usize) void'
  |-ParmVarDecl {{address:s}} <line:2:8, col:15> s 'mut S'
  | `-ReferenceType {{address}} <col:10, col:15> 'mut'
  |   `-NamedType {{address}} <col:14, col:15> 'S'
  |-ParmVarDecl {{address:a}} <col:17, col:36> a 'mut [1] const i32'
  | `-ReferenceType {{address}} <col:19, col:36> 'mut'
  |   `-ArrayType {{address}} <col:23, col:36>
  |     |-IntegerLiteral {{address}} <col:24, col:25> 'comptime_int' 1
  |     `-ConstType {{address}} <col:27, col:36>
  |       `-BuiltinType {{address}} <col:33, col:36> 'i32'
  |-ParmVarDecl {{address:i}} <col:38, col:45> i 'usize'
  | `-BuiltinType {{address}} <col:40, col:45> 'usize'
  `-CompoundStmt {{address}} <col:47, line:5:2>
    |-ExprStmt {{address}} <line:3:3, col:14>
    | `-MemberExpr {{address}} <col:3, col:13> 'const i32' move-lvalue .x Field {{address:x}} 'x' 'const i32'
    |   `-ParenExpr {{address}} <col:3, col:11> 'S' move-lvalue
    |     `-UnaryOperator {{address}} <col:4, col:10> 'S' move-lvalue 'move'
    |       `-DeclRefExpr {{address}} <col:9, col:10> 'S' lvalue ParmVar {{address:s}} 's' 'mut S'
    `-ExprStmt {{address}} <line:4:3, col:15>
      `-SubscriptExpr {{address}} <col:3, col:14> 'const i32' move-lvalue
        |-ParenExpr {{address}} <col:3, col:11> '[1] const i32' move-lvalue
        | `-UnaryOperator {{address}} <col:4, col:10> '[1] const i32' move-lvalue 'move'
        |   `-DeclRefExpr {{address}} <col:9, col:10> '[1] const i32' lvalue ParmVar {{address:a}} 'a' 'mut [1] const i32'
        `-ImplicitCastExpr {{address}} <col:12, col:13> 'usize' pure-rvalue <LValueToRValue>
          `-DeclRefExpr {{address}} <col:12, col:13> 'usize' lvalue ParmVar {{address:i}} 'i' 'usize')");
}

TEST_F(SemaTest, UsesConstMovingSourcesAcrossValueAndReferenceCallContexts) {
  Analyze(R"(struct T {}
ctor T(x copy T) {}
ctor T(x move T) {}
dtor T() {}
func operator=(x mut T, y copy T) {}
func operator=(x mut T, y move T) {}
func Take(x T) {}
func Read(x copy T) {}
func Rank(x move T) i64 { 1 }
func Rank(x copy T) i32 { 1 }
func Use(x mut T, y copy T, b bool, value *func (T) void, ref *func (copy T) void) i32 {
  Take(move y);
  (move y).Take();
  (move y).Read();
  value(move y);
  ref(move y);
  T(move y);
  var selected T := b ? move x : move y;
  var mixed T := b ? move x : y;
  x = b ? move x : move y;
  Rank(move y)
})");
}

TEST_F(SemaTest, CopiesConstMovingArraysAndBaseSubobjects) {
  Analyze(R"(struct Base {}
ctor Base(x copy Base) {}
ctor Base(x move Base) {}
dtor Base() {}
func operator=(x mut Base, y copy Base) {}
func operator=(x mut Base, y move Base) {}
struct Derived : Base {}
ctor Derived(x copy Base) { this.Base := x; }
dtor Derived() {}
func Read(x copy Base) {}
func Project(x copy Derived) Base {
  Read(move x);
  move x
}
func Arrays(x mut [1] [1] Base, y copy [1] [1] Base, z mut [1] [0] const Base) {
  var copied [1] [1] Base := move y;
  var empty [1] [0] const Base := move z;
  x = move y;
})");
}

TEST_F(SemaTest, MovesWholeObjectWhileCopyingItsConstMember) {
  Analyze(R"(struct Item {}
ctor Item() {}
ctor Item(x copy Item) {}
ctor Item(x move Item) {}
dtor Item() {}
struct Whole { fixed const Item; mutable Item; }
ctor Whole() { this.fixed := Item(); this.mutable := Item(); }
ctor Whole(x move Whole) {
  this.fixed := (move x).fixed;
  this.mutable := (move x).mutable;
}
dtor Whole() {}
func Use(x mut Whole) Whole { move x })");
}

TEST_F(SemaTest, RejectsMutableAndMoveReferenceBindingsFromConstMovingSources) {
  Analyze(R"(func Mut(x mut i32) {}
func Move(x move i32) {}
func Use(x copy i32) {
  Mut(move x);
  Move(move x);
})");

  ExpectError(3, 2, "no matching function for call to 'Mut'", 11);
  ExpectNote(0, 0,
             "candidate function is not viable: binding a reference of type 'mut i32' to a value of type "
             "'const i32' would discard const for argument 1",
             0);
  ExpectError(4, 2, "no matching function for call to 'Move'", 12);
  ExpectNote(1, 0,
             "candidate function is not viable: binding a reference of type 'move i32' to a value of type "
             "'const i32' would discard const for argument 1",
             0);
}

TEST_F(SemaTest, ReportsMissingCopyForConstMovingObjectsDespiteMoveOperations) {
  Analyze(R"(struct T {}
ctor T(x move T) {}
dtor T() {}
func operator=(x mut T, y move T) {}
func Use(x mut T, y copy T) T {
  x = move y;
  move y
})");

  ExpectError(5, 2, "no copy assignment declared for type 'T'", 10);
  ExpectError(6, 2, "cannot initialize return object: no copy constructor is available for 'T'", 6);
}

TEST_F(SemaTest, ReportsMissingCopyForInheritedArrayConstIncludingZeroLength) {
  Analyze(R"(struct T {}
ctor T(x move T) {}
dtor T() {}
func operator=(x mut T, y move T) {}
func Root(x mut [1] [1] T, y copy [1] [1] T) {
  var value [1] [1] T := move y;
  x = move y;
}
func Leaf(y mut [1] [0] const T) {
  var value [1] [0] const T := move y;
})");

  ExpectError(5, 25, "cannot initialize variable 'value': no copy constructor is available for '[1] [1] T'", 6);
  ExpectError(6, 2, "no copy assignment declared for array element type 'T'", 10);
  ExpectError(9, 31, "cannot initialize variable 'value': no copy constructor is available for '[1] [0] const T'", 6);
}

TEST_F(SemaTest, ChecksEachMixedConditionalBranchUsingItsOwnConstPermission) {
  Analyze(R"(struct T {}
ctor T(x move T) {}
dtor T() {}
func Use(b bool, x copy T, y mut T) {
  b ? move x : y;
  b ? move y : x;
})");

  ExpectError(4, 6, "cannot form conditional result from then branch: no copy constructor is available for 'T'", 6);
  ExpectError(5, 15, "cannot form conditional result from else branch: no copy constructor is available for 'T'", 1);
}

TEST_F(SemaTest, PreservesPointeeLvaluesWhenMovingConstPointers) {
  Analyze(R"(trivial struct S { value i32; }
func Use(p copy *S, q copy *i32) {
  (move p)->value = 1;
  *(move q) = 1;
  var address *i32 := &(move p)->value;
})");
}

TEST_F(SemaTest, RejectsModificationAddressAndRepeatedMoveOfConstMovingObjects) {
  Analyze(R"(func Use(x copy i32) {
  (move x) = 1;
  &(move x);
  move (move x);
})");

  ExpectError(1, 2, "assignment target must be a modifiable lvalue, not 'const i32'", 8);
  ExpectError(2, 2, "unary operator '&' requires an object lvalue operand", 9);
  ExpectError(3, 2, "'move' requires an lvalue of object type, not 'const i32'", 13);
}

TEST_F(SemaTest, StillRequiresInitializedObjectsForConstMove) {
  Analyze(R"(func Use() {
  var x const i32;
  move x;
})");

  ExpectError(2, 7, "use of uninitialized variable 'x'", 1);
}

// String literals.

TEST_F(SemaTest, StringLiteralsAreConstArrayLvalues) {
  Analyze(R"(func F() {
"abc";
"";
"a\0b";
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:5:2> F 'func () void'
  `-CompoundStmt {{address}} <line:1:10, line:5:2>
    |-ExprStmt {{address}} <line:2:1, col:7>
    | `-StringLiteral {{address}} <col:1, col:6> 'const [3] u8' lvalue "abc"
    |-ExprStmt {{address}} <line:3:1, col:4>
    | `-StringLiteral {{address}} <col:1, col:3> 'const [0] u8' lvalue ""
    `-ExprStmt {{address}} <line:4:1, col:8>
      `-StringLiteral {{address}} <col:1, col:7> 'const [3] u8' lvalue "a\0b")");
}

TEST_F(SemaTest, InfersOwnedArraysFromStringLiterals) {
  Analyze(R"(var g := "abc";
func F() {
var s := g;
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-VarGroupDecl {{address}} <test.cw:1:1, col:16>
| |-VarDecl {{address:g}} <col:5, col:6> g '[3] u8'
| `-ImplicitCastExpr {{address}} <col:10, col:15> '[3] u8' pure-rvalue <LValueToRValue>
|   `-StringLiteral {{address}} <col:10, col:15> 'const [3] u8' lvalue "abc"
`-FunctionDecl {{address}} <line:2:1, line:4:2> F 'func () void'
  `-CompoundStmt {{address}} <line:2:10, line:4:2>
    `-DeclStmt {{address}} <line:3:1, col:12>
      `-VarGroupDecl {{address}} <col:1, col:12>
        |-VarDecl {{address}} <col:5, col:6> s '[3] u8'
        `-ImplicitCastExpr {{address}} <col:10, col:11> '[3] u8' pure-rvalue <LValueToRValue>
          `-DeclRefExpr {{address}} <col:10, col:11> '[3] u8' lvalue Var {{address:g}} 'g' '[3] u8')");
}

TEST_F(SemaTest, PreservesStringLiteralConstnessThroughAddressAndSubscript) {
  Analyze(R"(func F(index usize) {
&"abc";
"abc"[index];
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, line:4:2> F 'func (usize) void'
  |-ParmVarDecl {{address:index}} <line:1:8, col:19> index 'usize'
  | `-BuiltinType {{address}} <col:14, col:19> 'usize'
  `-CompoundStmt {{address}} <col:21, line:4:2>
    |-ExprStmt {{address}} <line:2:1, col:8>
    | `-UnaryOperator {{address}} <col:1, col:7> '*const [3] u8' pure-rvalue '&'
    |   `-StringLiteral {{address}} <col:2, col:7> 'const [3] u8' lvalue "abc"
    `-ExprStmt {{address}} <line:3:1, col:14>
      `-SubscriptExpr {{address}} <col:1, col:13> 'const u8' lvalue
        |-StringLiteral {{address}} <col:1, col:6> 'const [3] u8' lvalue "abc"
        `-ImplicitCastExpr {{address}} <col:7, col:12> 'usize' pure-rvalue <LValueToRValue>
          `-DeclRefExpr {{address}} <col:7, col:12> 'usize' lvalue ParmVar {{address:index}} 'index' 'usize')");
}

TEST_F(SemaTest, CountsDecodedStringLiteralBytesWithoutImplicitTerminator) {
  Analyze(R"(func F() {
  var plain [3] u8 := "abc";
  var empty [0] u8 := "";
  var zero [3] u8 := "a\0b";
  var tail [4] u8 := "abc\0";
  var bytes [2] u8 := "\xFF\xFE";
  var text [3] u8 := "中";
  var joined [2] u8 := "a" "b";
  var escapes [2] u8 := "\x4" "1";
})");
}

TEST_F(SemaTest, UsesStringLiteralsThroughOrdinaryArrayConversions) {
  Analyze(R"(var global := "abc";
func Read(value copy [3] u8, index usize) u8 { value[index] }
func Echo(value [3] u8) [3] u8 { value }
func Borrow() copy [3] u8 { "abc" }
func Use(index usize) {
  var text := "abc";
  text[index] = 'x';
  text = "def";
  global[index] = 'g';
  var pointer := &"abc";
  Read(*pointer, index);
  Read("abc", index);
  var copied := Echo("abc");
  var borrowed := Borrow();
  borrowed[index] = 'b';
  var empty := "";
  empty = "";
})");
}

TEST_F(SemaTest, DiagnosesInvalidStringLiteralInitialization) {
  Analyze(R"(func F() {
var x i32 := "hello";
})");

  ExpectError(1, 13, "cannot initialize variable 'x': no implicit conversion from '[5] u8' to 'i32'", 7);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, line:3:2> F 'func () void' contains-errors
  `-CompoundStmt {{address}} <line:1:10, line:3:2> contains-errors
    `-DeclStmt {{address}} <line:2:1, col:22> contains-errors
      `-VarGroupDecl {{address}} <col:1, col:22> contains-errors
        |-VarDecl {{address}} <col:5, col:10> x 'i32'
        | `-BuiltinType {{address}} <col:7, col:10> 'i32'
        `-StringLiteral {{address}} <col:14, col:21> 'const [5] u8' lvalue "hello" contains-errors)");
}

TEST_F(SemaTest, DiagnosesInvalidStringLiteralConditionsOperatorsCallsAndReturns) {
  Analyze(R"(func G(value i32) {}
func Return() i32 { "hello" }
func F() {
if "hello" {}
"hello" + 1;
G("hello");
})");

  ExpectError(1, 20, "cannot initialize return object: no implicit conversion from '[5] u8' to 'i32'", 7);
  ExpectError(3, 3, "condition expression must have type 'bool', not 'const [5] u8'", 7);
  ExpectError(4, 0, "binary operator '+' cannot be applied to types 'const [5] u8' and 'i32'", 11);
  ExpectError(5, 0, "no matching function for call to 'G'", 10);
  ExpectNote(0, 0, "candidate function is not viable: no implicit conversion from '[5] u8' to 'i32' for argument 1", 0);
}

TEST_F(SemaTest, RejectsStringLiteralLengthChangesAndPointerDecay) {
  Analyze(R"(func F(flag bool) {
var wrong [4] u8 := "abc";
var pointer *const u8 := "abc";
flag ? "yes" : "no";
})");

  ExpectError(1, 20, "cannot initialize variable 'wrong': no implicit conversion from '[3] u8' to '[4] u8'", 5);
  ExpectError(2, 25, "cannot initialize variable 'pointer': no implicit conversion from '[3] u8' to '*const u8'", 5);
  ExpectError(3, 7, "conditional expression has no common result type for 'const [3] u8' and 'const [2] u8'", 12);
}

TEST_F(SemaTest, RejectsStringLiteralMutationAndInitialization) {
  Analyze(R"(func Mut(value mut [3] u8) {}
func F(index usize) {
"abc"[index] = 'x';
"abc" := "xyz";
Mut("abc");
})");

  ExpectError(2, 0, "assignment target must be a modifiable lvalue, not 'const u8'", 12);
  ExpectError(3, 0,
              "initialization target must be rooted in a local object, result object, or the constructor's "
              "current object",
              5);
  ExpectError(4, 0, "no matching function for call to 'Mut'", 10);
  ExpectNote(0, 0,
             "candidate function is not viable: binding a reference of type 'mut [3] u8' to a value of type "
             "'const [3] u8' would discard const for argument 1",
             0);
}

// Fixed arrays.

TEST_F(SemaTest, AcceptsFixedArrayTypeFormsAndCanonicalLengthIdentity) {
  Analyze(R"(trivial struct Value {}
func Take(value [4] i32) {}
func Types(equivalent [2 + 2] i32, zero [0] Value,
           callbacks [3] *func () void,
           slots [3] virtual *func (copy Value) void,
           nested [2] [3] const Value) {
  Take(equivalent);
})");
}

TEST_F(SemaTest, DoesNotDecayFixedArraysToPointers) {
  Analyze(R"(func Take(pointer *i32) {}
func Use(array [1] i32) { Take(array); })");

  ExpectError(1, 26, "no matching function for call to 'Take'", 11);
  ExpectNote(0, 0, "candidate function is not viable: no implicit conversion from '[1] i32' to '*i32' for argument 1",
             0);
}

TEST_F(SemaTest, AcceptsCompleteNestedAndZeroLengthArrayValues) {
  Analyze(R"(struct Value {}
ctor Value(number i32) {}
ctor Value(other copy Value) {}
ctor Value(other move Value) {}
dtor Value() {}
func NonTrivialValues() [2] Value {
  [2] Value { Value(1), Value(2) }
}
func ConstElementFallback(source mut [1] const Value) {
  var copied [1] const Value := move source;
}
func Arrays(index usize) i32 {
  var empty [0] i32 := [0] i32 {};
  var nested [2] [2] i32 := [2] [2] i32 { { 1, 2 }, { 3, 4 } };
  nested[index][index]
})");
}

TEST_F(SemaTest, FormsFunctionAddressesConversionsAndCopiesInArrayValues) {
  Analyze(R"(struct Value {}
ctor Value(other copy Value) {}
dtor Value() {}
func Select(value i32) {}
func Select(value i64) {}
func Values(source copy Value, number i32) {
  var callbacks [1] *func (i32) void := [1] *func (i32) void { &Select };
  var numbers [1] i64 := [1] i64 { number };
  var objects [1] Value := [1] Value { source };
})");
}

TEST_F(SemaTest, DiagnosesInvalidArrayLengthExpressions) {
  Analyze(R"(func Lengths(runtime usize) {
  var named [runtime] i32;
  var division [4 / 2] i32;
  var negative [-1] i32;
  var floating [1.0] i32;
  var overflow [2147483647 * 3] i32;
  var too_large [18446744073709551616] i32;
})");

  ExpectError(1, 13, "array length is not a constant integer expression", 7);
  ExpectError(2, 16, "array length constant expression may use only '+', '-', and '*' arithmetic", 5);
  ExpectError(3, 16, "array length cannot be negative", 2);
  ExpectError(4, 16, "array length expression must have integer type, not 'f64'", 3);
  ExpectError(5, 16, "array length constant expression overflows its integer type", 14);
  ExpectError(6, 17, "array length is outside the range of 'usize'", 20);
}

TEST_F(SemaTest, RejectsNonObjectArrayElementTypes) {
  Analyze("func InvalidElements(voids [1] void, refs [1] mut i32) {}");

  ExpectError(0, 31, "array element type 'void' is not an object type", 4);
  ExpectError(0, 46, "array element type 'mut i32' is not an object type", 7);
}

TEST_F(SemaTest, RejectsAbstractElementsInsideArrayPointers) {
  Analyze(R"(struct Abstract {
  virtual {
    abstract func F(this mut Abstract) void;
  }
}
ctor Abstract() {}
dtor Abstract() {}
func Valid(values [1] *Abstract) {}
func Invalid(values *[0] Abstract) {})");

  ExpectError(8, 25, "array element type 'Abstract' is abstract", 8);
}

TEST_F(SemaTest, RejectsByValueContainmentCyclesThroughZeroLengthArrays) {
  Analyze(R"(trivial struct Cycle { values [0] [1] Cycle; }
trivial struct First { second [0] Second; }
trivial struct Second { first First; })");

  ExpectError(0, 30, "by-value object containment cycle involving struct 'Cycle'", 13);
  ExpectError(2, 30, "by-value object containment cycle involving struct 'First'", 5);
}

TEST_F(SemaTest, RequiresExactArrayValueElementCounts) {
  Analyze(R"(func Counts() {
  var few [2] i32 := [2] i32 { 1 };
  var many [0] i32 := [0] i32 { 1 };
})");

  ExpectError(1, 21, "array value requires exactly 2 elements, but 1 was provided", 13);
  ExpectError(2, 22, "array value requires exactly 0 elements, but 1 was provided", 13);
}

TEST_F(SemaTest, RejectsFlatInitializersForNestedArrays) {
  Analyze(R"(func Nested() {
  var flat [2] [2] i32 := [2] [2] i32 { 1, 2, 3, 4 };
})");

  ExpectError(1, 26, "array value requires exactly 2 elements, but 4 were provided", 26);
  ExpectError(1, 40, "cannot initialize array element 0: no implicit conversion from 'i32' to '[2] i32'", 1);
  ExpectError(1, 43, "cannot initialize array element 1: no implicit conversion from 'i32' to '[2] i32'", 1);
}

TEST_F(SemaTest, AnalyzesExpressionsInsideExcessNestedArrayInitializers) {
  Analyze(R"(func Recover() {
  var value [1] [1] i32 := [1] [1] i32 { { 1 }, { { missing } } };
})");

  ExpectError(1, 27, "array value requires exactly 1 element, but 2 were provided", 38);
  ExpectError(1, 52, "use of undeclared identifier 'missing'", 7);
}

TEST_F(SemaTest, RequiresExactUsizeArraySubscripts) {
  Analyze(R"(func Index(i i32, u usize) {
  var values [1] i32 := [1] i32 { 1 };
  values[u];
  values[i];
  values[0];
})");

  ExpectError(3, 9, "array subscript must have type 'usize', not 'i32'", 1);
  ExpectError(4, 9, "array subscript must have type 'usize', not 'i32'", 1);
}

TEST_F(SemaTest, PassesAndReturnsFixedArraysByValueIncludingIndirectCalls) {
  Analyze(R"(func Echo(value [1] i32) [1] i32 { value }
func Invoke(callback *func ([1] i32) [1] i32, value mut [1] i32) [1] i32 {
  callback(value)
})");
}

TEST_F(SemaTest, DefersNonTrivialArrayFormationUntilAfterOverloadSelection) {
  Analyze(R"(struct Missing {}
ctor Missing() {}
dtor Missing() {}
func Select(value [1] Missing, rank i16) {}
func Select(value copy [1] Missing, rank i32) {}
func Use(value mut [1] Missing, rank i16) { Select(value, rank); })");

  ExpectError(5, 51,
              "cannot initialize parameter 1 of function 'Select': no copy constructor is available for '[1] "
              "Missing'",
              5);
}

TEST_F(SemaTest, AppliesObjectFormationRulesToMixedArrayConditionalBranches) {
  Analyze(R"(struct Missing {}
ctor Missing() {}
dtor Missing() {}
func Select(flag bool, existing mut [1] Missing) {
  flag ? existing : [1] Missing { Missing() };
  flag ? move existing : [1] Missing { Missing() };
})");

  ExpectError(4, 9,
              "cannot form conditional result from then branch: no copy constructor is available for '[1] Missing'", 8);
  ExpectError(
      5, 9,
      "cannot form conditional result from then branch: no move or copy constructor is available for '[1] Missing'",
      13);
}

TEST_F(SemaTest, RecordsNonTrivialArrayConstructionAndAssignmentOperations) {
  Analyze(R"(struct Value {}
ctor Value(other copy Value) {}
dtor Value() {}
func operator=(dst mut Value, src copy Value) {}
func Arrays(source mut [1] Value) {
  var copied [1] Value := move source;
  copied = move source;
})");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-StructDecl {{address:structure}} <test.cw:1:1, col:16> Value
|-ConstructorDecl {{address:copy_constructor}} <line:2:1, col:32> Value target Struct {{address:structure}} 'Value' 'func (copy Value) void'
| |-ParmVarDecl {{address:copy_source}} <col:12, col:28> other 'copy Value'
| | `-ReferenceType {{address}} <col:18, col:28> 'copy'
| |   `-NamedType {{address}} <col:23, col:28> 'Value'
| `-CompoundStmt {{address}} <col:30, col:32>
|-DestructorDecl {{address}} <line:3:1, col:16> Value target Struct {{address:structure}} 'Value' 'func () void'
| `-CompoundStmt {{address}} <col:14, col:16>
|-FunctionDecl {{address:copy_assignment}} <line:4:1, col:49> operator= 'func (mut Value, copy Value) void'
| |-ParmVarDecl {{address:assignment_target}} <col:16, col:29> dst 'mut Value'
| | `-ReferenceType {{address}} <col:20, col:29> 'mut'
| |   `-NamedType {{address}} <col:24, col:29> 'Value'
| |-ParmVarDecl {{address:assignment_source}} <col:31, col:45> src 'copy Value'
| | `-ReferenceType {{address}} <col:35, col:45> 'copy'
| |   `-NamedType {{address}} <col:40, col:45> 'Value'
| `-CompoundStmt {{address}} <col:47, col:49>
`-FunctionDecl {{address}} <line:5:1, line:8:2> Arrays 'func (mut [1] Value) void'
  |-ParmVarDecl {{address:array_source}} <line:5:13, col:33> source 'mut [1] Value'
  | `-ReferenceType {{address}} <col:20, col:33> 'mut'
  |   `-ArrayType {{address}} <col:24, col:33>
  |     |-IntegerLiteral {{address}} <col:25, col:26> 'comptime_int' 1
  |     `-NamedType {{address}} <col:28, col:33> 'Value'
  `-CompoundStmt {{address}} <col:35, line:8:2>
    |-DeclStmt {{address}} <line:6:3, col:39>
    | `-VarGroupDecl {{address}} <col:3, col:39>
    |   |-VarDecl {{address:copied}} <col:7, col:23> copied '[1] Value'
    |   | `-ArrayType {{address}} <col:14, col:23>
    |   |   |-IntegerLiteral {{address}} <col:15, col:16> 'comptime_int' 1
    |   |   `-NamedType {{address}} <col:18, col:23> 'Value'
    |   `-ArrayConstructionExpr {{address}} <col:27, col:38> '[1] Value' pure-rvalue Constructor {{address:copy_constructor}} 'Value' 'func (copy Value) void'
    |     `-UnaryOperator {{address}} <col:27, col:38> '[1] Value' move-lvalue 'move'
    |       `-DeclRefExpr {{address}} <col:32, col:38> '[1] Value' lvalue ParmVar {{address:array_source}} 'source' 'mut [1] Value'
    `-ExprStmt {{address}} <line:7:3, col:24>
      `-ArrayAssignmentExpr {{address}} <col:3, col:23> '[1] Value' lvalue Function {{address:copy_assignment}} 'operator=' 'func (mut Value, copy Value) void'
        |-DeclRefExpr {{address}} <col:3, col:9> '[1] Value' lvalue Var {{address:copied}} 'copied' '[1] Value'
        `-UnaryOperator {{address}} <col:12, col:23> '[1] Value' move-lvalue 'move'
          `-DeclRefExpr {{address}} <col:17, col:23> '[1] Value' lvalue ParmVar {{address:array_source}} 'source' 'mut [1] Value')");
}

TEST_F(SemaTest, RequiresLeafAssignmentForNestedNonTrivialArrays) {
  Analyze(R"(struct Missing {}
ctor Missing() {}
dtor Missing() {}
func Assign(dst mut [1] [1] Missing, src copy [1] [1] Missing) {
  dst = src;
})");

  ExpectError(4, 2, "no copy assignment declared for array element type 'Missing'", 9);
}

TEST_F(SemaTest, RejectsWholeArrayAssignmentWhenElementsAreConst) {
  Analyze(R"(func ConstElements(dst mut [1] const i32, src copy [1] const i32) {
  dst = src;
})");

  ExpectError(1, 2, "cannot assign an array with const-qualified element type 'const i32'", 3);
}

// Global declarations and initialization.

TEST_F(SemaTest, AnalyzesGlobalDirectInitializerSources) {
  Analyze("var global i32 := missing;");
  ExpectError(0, 18, "use of undeclared identifier 'missing'", 7);
}

TEST_F(SemaTest, AnalyzesGlobalInitializerBlockSources) {
  Analyze("var global i32 := { missing; }");
  ExpectError(0, 20, "use of undeclared identifier 'missing'", 7);
  ExpectError(0, 18, "variable 'global' is not initialized when its initializer block exits", 12);
}

TEST_F(SemaTest, RejectsInitializationOfGlobalObjectsFromFunctions) {
  Analyze(R"(var scalar i32 := 0;
trivial struct Aggregate { field i32; }
var aggregate Aggregate := Aggregate();
func use() {
  scalar := 1;
  aggregate.field := 2;
})");

  ExpectError(4, 2, "initializing a global variable from a function is not supported", 6);
  ExpectError(5, 2, "initializing a global variable from a function is not supported", 15);
}

TEST_F(SemaTest, InfersGlobalDirectInitializerType) {
  Analyze("var global := 1;");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-VarGroupDecl {{address}} <test.cw:1:1, col:17>
  |-VarDecl {{address}} <col:5, col:11> global 'i32'
  `-ImplicitCastExpr {{address}} <col:15, col:16> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    `-IntegerLiteral {{address}} <col:15, col:16> 'comptime_int' 1)");
}

TEST_F(SemaTest, ChecksGlobalInitializerListArity) {
  Analyze(R"(var first, second i32 := 1;
var value i32 := 1, 2;)");

  ExpectError(0, 11, "variable count does not match initializer count", 6);
  ExpectError(1, 20, "variable count does not match initializer count", 1);
}

TEST_F(SemaTest, RequiresExplicitTypesForLocalAndGlobalInitializerBlocks) {
  Analyze(R"(var global := { missing_global; }
func f() {
  var local := { 1 }
})");

  ExpectError(0, 4, "variable initializer block requires an explicit type", 0);
  ExpectError(0, 16, "use of undeclared identifier 'missing_global'", 14);
  ExpectError(2, 6, "variable initializer block requires an explicit type", 0);
}

TEST_F(SemaTest, FormsGlobalCallsAndConversionsInSemanticAst) {
  Analyze(R"(var first := Make();
var second i64 := first;
func Make() i32 { 7 })");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-VarGroupDecl {{address}} <test.cw:1:1, col:21>
| |-VarDecl {{address:first}} <col:5, col:10> first 'i32'
| `-CallExpr {{address}} <col:14, col:20> 'i32' pure-rvalue
|   `-DeclRefExpr {{address}} <col:14, col:18> 'func () i32' Function {{address:make}} 'Make' 'func () i32'
|-VarGroupDecl {{address}} <line:2:1, col:25>
| |-VarDecl {{address}} <col:5, col:15> second 'i64'
| | `-BuiltinType {{address}} <col:12, col:15> 'i64'
| `-ImplicitCastExpr {{address}} <col:19, col:24> 'i64' pure-rvalue <IntegerToInteger>
|   `-ImplicitCastExpr {{address}} <col:19, col:24> 'i32' pure-rvalue <LValueToRValue>
|     `-DeclRefExpr {{address}} <col:19, col:24> 'i32' lvalue Var {{address:first}} 'first' 'i32'
`-FunctionDecl {{address:make}} <line:3:1, col:22> Make 'func () i32'
  |-ReturnVarDecl {{address:result}} <col:13, col:16> 'i32'
  | `-BuiltinType {{address}} <col:13, col:16> 'i32'
  `-CompoundStmt {{address}} <col:17, col:22>
    `-ImplicitResultInitializationExpr {{address}} <col:19, col:20> 'void' ReturnVar {{address:result}} 'i32'
      `-ImplicitCastExpr {{address}} <col:19, col:20> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
        `-IntegerLiteral {{address}} <col:19, col:20> 'comptime_int' 7)");
}

TEST_F(SemaTest, KeepsGlobalExplicitAndInferredTypesIndependentInBothOrders) {
  Analyze(R"(var a, b i64 := 1, 2;
var c bool, d := true, 3;)");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
|-VarGroupDecl {{address}} <test.cw:1:1, col:22>
| |-VarDecl {{address}} <col:5, col:6> a 'i32'
| |-VarDecl {{address}} <col:8, col:13> b 'i64'
| | `-BuiltinType {{address}} <col:10, col:13> 'i64'
| |-ImplicitCastExpr {{address}} <col:17, col:18> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
| | `-IntegerLiteral {{address}} <col:17, col:18> 'comptime_int' 1
| `-ImplicitCastExpr {{address}} <col:20, col:21> 'i64' pure-rvalue <IntegerToInteger>
|   `-ImplicitCastExpr {{address}} <col:20, col:21> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
|     `-IntegerLiteral {{address}} <col:20, col:21> 'comptime_int' 2
`-VarGroupDecl {{address}} <line:2:1, col:26>
  |-VarDecl {{address}} <col:5, col:11> c 'bool'
  | `-BuiltinType {{address}} <col:7, col:11> 'bool'
  |-VarDecl {{address}} <col:13, col:14> d 'i32'
  |-BoolLiteral {{address}} <col:18, col:22> 'bool' pure-rvalue true
  `-ImplicitCastExpr {{address}} <col:24, col:25> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    `-IntegerLiteral {{address}} <col:24, col:25> 'comptime_int' 3)");
}

TEST_F(SemaTest, PreservesGlobalHeterogeneousBlockAndResultOwnershipInAst) {
  Analyze("var a i32, b bool := { 1, true }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-VarGroupDecl {{address}} <test.cw:1:1, col:33>
  |-VarDecl {{address:a}} <col:5, col:10> a 'i32'
  | `-BuiltinType {{address}} <col:7, col:10> 'i32'
  |-VarDecl {{address:b}} <col:12, col:18> b 'bool'
  | `-BuiltinType {{address}} <col:14, col:18> 'bool'
  `-CompoundStmt {{address}} <col:22, col:33>
    |-ImplicitResultInitializationExpr {{address}} <col:24, col:25> 'void' Var {{address:a}} 'a' 'i32'
    | `-ImplicitCastExpr {{address}} <col:24, col:25> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
    |   `-IntegerLiteral {{address}} <col:24, col:25> 'comptime_int' 1
    `-ImplicitResultInitializationExpr {{address}} <col:27, col:31> 'void' Var {{address:b}} 'b' 'bool'
      `-BoolLiteral {{address}} <col:27, col:31> 'bool' pure-rvalue true)");
}

TEST_F(SemaTest, RejectsDirectForwardSelfAndSameGroupGlobalReferences) {
  Analyze(R"(var first := later;
var self := self;
var left, right := 1, left;
var later := 2;)");
  ExpectError(0, 13, "use of undeclared identifier 'later'", 5);
  ExpectError(1, 12, "use of undeclared identifier 'self'", 4);
  ExpectError(2, 22, "use of undeclared identifier 'left'", 4);
}

TEST_F(SemaTest, PreservesGlobalResultsAcrossNestedScopesAndLaterDeclarations) {
  Analyze(R"(var condition := true;
var count i32, ready bool := {
  if condition {
    var helper := 1;
    count := helper;
    ready := true;
  } else {
    var helper := 2;
    count := helper;
    ready := false;
  }
}
var after := count;
var another bool := { ready }
func Use() {
  var local i32, flag bool := { count, ready }
})");
}

TEST_F(SemaTest, ChecksGlobalResultsInOrderAndReadsBeforeFormation) {
  Analyze(R"(var first i32, second bool := {
  first;
  second := true;
  first := 1;
})");
  ExpectError(1, 2, "use of uninitialized variable 'first'", 5);
  ExpectError(2, 2, "cannot initialize before preceding variable 'first' is fully initialized", 6);
}

TEST_F(SemaTest, KeepsGlobalInitializationStateAcrossDeclarationGroups) {
  Analyze(R"(var first i32 := { 1 }
var second i32 := {
  first := 2;
  first
})");
  ExpectError(2, 2, "repeated initialization of variable 'first'", 5);
}

TEST_F(SemaTest, RequiresEachGlobalBlockResultOnEveryNormalExit) {
  Analyze(R"(var condition := true;
var first i32, second bool := {
  first := 1;
  if condition { second := true; }
})");
  ExpectError(3, 2, "variable 'second' is not initialized when its initializer block exits", 32);
}

TEST_F(SemaTest, DoesNotInheritBlockResultTypesFromNeighbouringVariables) {
  Analyze(R"(var first, second bool := { second := true; }
func Use() { var local, flag bool := { flag := false; } })");
  ExpectError(0, 4, "variable initializer block requires an explicit type", 0);
  ExpectError(1, 17, "variable initializer block requires an explicit type", 0);
}

TEST_F(SemaTest, ChecksValidBlockResultsAfterAnotherResultTypeFails) {
  Analyze("var bad Missing, required bool := {}");
  ExpectError(0, 8, "unknown type 'Missing'", 7);
  ExpectError(0, 34, "variable 'required' is not initialized when its initializer block exits", 2);
}

TEST_F(SemaTest, DoesNotInferAnExplicitlyInvalidGlobalType) {
  Analyze("var bad Missing, good := 1, true;");
  ExpectError(0, 8, "unknown type 'Missing'", 7);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-VarGroupDecl {{address}} <test.cw:1:1, col:34> contains-errors
  |-VarDecl {{address}} <col:5, col:16> bad contains-errors
  | `-NamedType {{address}} <col:9, col:16> 'Missing' contains-errors
  |-VarDecl {{address}} <col:18, col:22> good 'bool'
  |-ImplicitCastExpr {{address}} <col:26, col:27> 'i32' pure-rvalue <ComptimeIntegerMaterialization>
  | `-IntegerLiteral {{address}} <col:26, col:27> 'comptime_int' 1
  `-BoolLiteral {{address}} <col:29, col:33> 'bool' pure-rvalue true)");
}

TEST_F(SemaTest, RejectsInferredAbstractGlobalAndLocalValueObjects) {
  Analyze(R"(struct Abstract { virtual { abstract func Observe(self copy Abstract); } }
ctor Abstract() {}
ctor Abstract(source copy Abstract) {}
dtor Abstract() {}
struct Concrete : Abstract { virtual { override func Observe(self copy Concrete); } }
func Observe(self copy Concrete) {}
ctor Concrete() { this.Abstract := Abstract(); }
dtor Concrete() {}
var concrete := Concrete();
func Borrow() mut Abstract { concrete }
var global := Borrow();
func Copy(source copy Abstract) { var local := source; })");
  ExpectError(10, 14, "variable type 'Abstract' is abstract", 8);
  ExpectError(11, 47, "variable type 'Abstract' is abstract", 6);
}

TEST_F(SemaTest, InfersGlobalOwnedObjectsFromReferencesWithoutAllowingGlobalReferences) {
  Analyze(R"(var source := 1;
func Borrow() mut i32 { source }
var owned := Borrow();
var link mut i32 := source;)");
  ExpectError(3, 9, "global reference variables are not currently supported", 7);
}

TEST_F(SemaTest, RequiresInitializersForEmptyNonemptyTrivialAndNontrivialGlobals) {
  Analyze(R"(trivial struct Empty {}
trivial struct Pair { value i32; }
struct Object {}
ctor Object() {}
dtor Object() {}
var scalar i32;
var empty Empty;
var pair Pair;
var object Object;)");
  ExpectError(5, 4, "global variable declaration requires an initializer", 0);
  ExpectError(6, 4, "global variable declaration requires an initializer", 0);
  ExpectError(7, 4, "global variable declaration requires an initializer", 0);
  ExpectError(8, 4, "global variable declaration requires an initializer", 0);
}

TEST_F(SemaTest, KeepsGlobalObjectStateOutOfCalledFunctionAnalysis) {
  // This deliberately exercises the current checking boundary: indirect early
  // access is not diagnosed or made safe by the intraprocedural analysis.
  Analyze(R"(var first := Read();
var later := 1;
func Read() i32 { later })");
}

TEST_P(ConfiguredSemaTest, AppliesConfiguredArgumentOrderInsideGlobalInitialization) {
  Analyze(R"(func Call(first i32, second i32) {}
var global i32 := {
  var first i32, second i32;
  Call(first, second);
  1
})");
  if (GetParam() == cw::ABIKind::Itanium) {
    ExpectError(3, 7, "use of uninitialized variable 'first'", 5);
    ExpectError(3, 14, "use of uninitialized variable 'second'", 6);
  } else {
    ExpectError(3, 14, "use of uninitialized variable 'second'", 6);
    ExpectError(3, 7, "use of uninitialized variable 'first'", 5);
  }
}

TEST_F(SemaTest, RejectsReturnFromGlobalInitializerAndContinuesSemanticAnalysis) {
  Analyze(R"(var global i32 := { return 1; }
var later := missing;
func Use() { missing_body; })");
  ExpectError(0, 20, "return is not allowed in a variable initializer block", 0);
  ExpectError(1, 13, "use of undeclared identifier 'missing'", 7);
  ExpectError(2, 13, "use of undeclared identifier 'missing_body'", 12);
}

TEST_F(SemaTest, KeepsRegisteredFunctionNameEvenWhenItsReturnTypeIsInvalid) {
  Analyze(R"(var f := 1;
func f() Missing {})");
  ExpectError(1, 9, "unknown type 'Missing'", 7);
  ExpectError(0, 4, "declaration of variable 'f' conflicts with function declaration", 0);
  ExpectNote(1, 5, "conflicting declaration is here", 0);
}

TEST_F(SemaTest, ContinuesGlobalSourceAnalysisAfterInitializerArityFailure) {
  Analyze(R"(var first i32, second bool := missing;
var after bool := missing_later;)");
  ExpectError(0, 15, "variable count does not match initializer count", 6);
  ExpectError(0, 30, "use of undeclared identifier 'missing'", 7);
  ExpectError(1, 18, "use of undeclared identifier 'missing_later'", 13);
}

// Definite initialization, control flow, and object lifetimes.

TEST_F(SemaTest, TracksFixedArraysAsWholeInitializedObjects) {
  Analyze(R"(func Whole(source [1] i32, index usize) {
  var value [1] i32;
  value[index];
  value = source;
  value := source;
  value[index] = source[index];
}
func Zero(source [0] i32) {
  var empty [0] i32;
  empty;
  empty = source;
  move empty;
})");

  ExpectError(2, 2, "use of uninitialized variable 'value'", 5);
  ExpectError(3, 2, "use of uninitialized variable 'value'", 5);
  ExpectError(9, 2, "use of uninitialized variable 'empty'", 5);
  ExpectError(10, 2, "use of uninitialized variable 'empty'", 5);
  ExpectError(11, 7, "use of uninitialized variable 'empty'", 5);
}

TEST_F(SemaTest, RejectsArrayElementInitializationTargets) {
  Analyze(R"(trivial struct Element { field i32; }
func Reject(source Element, field_source i32, index usize) {
  var values [1] Element;
  values[index] := source;
  values[index].field := field_source;
})");

  ExpectError(3, 2, "cannot initialize an array element or its subobject separately", 13);
  ExpectError(4, 2, "cannot initialize an array element or its subobject separately", 19);
}

TEST_F(SemaTest, RejectsArrayElementInitializationInConstructors) {
  Analyze(R"(struct Container { values [1] i32; }
ctor Container(source i32, index usize) {
  this.values[index] := source;
  this.values := [1] i32 { source };
}
dtor Container() {})");

  ExpectError(2, 2, "cannot initialize an array element or its subobject separately", 18);
}

TEST_F(SemaTest, EvaluatesSubexpressionsOfRejectedArrayElementInitializationTargets) {
  Analyze(R"(func Reject(source i32) {
  var values [1] i32;
  var index usize;
  values[index] := source;
})");

  ExpectError(3, 2, "cannot initialize an array element or its subobject separately", 13);
  ExpectError(3, 9, "use of uninitialized variable 'index'", 5);
}

TEST_F(SemaTest, RequiresWholeArrayInitializationBeforeReadingElementDescendants) {
  Analyze(R"(trivial struct Element { field i32; }
func Read(index usize) {
  var values [1] Element;
  values[index].field;
})");

  ExpectError(3, 2, "use of uninitialized variable 'values'", 6);
}

TEST_F(SemaTest, AcceptsInitializationAndAssignmentOnAllReachablePaths) {
  Analyze(R"(func f(condition bool, source i32) i32 {
  var value i32;
  if condition {
    value := source;
  } else {
    value := 2;
  }
  value = value + 1;
  return value;
})");
}

TEST_F(SemaTest, DistinguishesInitializationAndAssignmentInSemanticAst) {
  Analyze("func f(source i32) { var target i32; target := source; target = source; }");

  ExpectAstDump(R"(TranslationUnitDecl {{address}}
`-FunctionDecl {{address}} <test.cw:1:1, col:74> f 'func (i32) void'
  |-ParmVarDecl {{address:source}} <col:8, col:18> source 'i32'
  | `-BuiltinType {{address}} <col:15, col:18> 'i32'
  `-CompoundStmt {{address}} <col:20, col:74>
    |-DeclStmt {{address}} <col:22, col:37>
    | `-VarGroupDecl {{address}} <col:22, col:37>
    |   `-VarDecl {{address:target}} <col:26, col:36> target 'i32'
    |     `-BuiltinType {{address}} <col:33, col:36> 'i32'
    |-ExprStmt {{address}} <col:38, col:55>
    | `-InitializationExpr {{address}} <col:38, col:54> 'void'
    |   |-DeclRefExpr {{address}} <col:38, col:44> 'i32' lvalue Var {{address:target}} 'target' 'i32'
    |   `-ImplicitCastExpr {{address}} <col:48, col:54> 'i32' pure-rvalue <LValueToRValue>
    |     `-DeclRefExpr {{address}} <col:48, col:54> 'i32' lvalue ParmVar {{address:source}} 'source' 'i32'
    `-ExprStmt {{address}} <col:56, col:72>
      `-BinaryOperator {{address}} <col:56, col:71> 'i32' lvalue '='
        |-DeclRefExpr {{address}} <col:56, col:62> 'i32' lvalue Var {{address:target}} 'target' 'i32'
        `-ImplicitCastExpr {{address}} <col:65, col:71> 'i32' pure-rvalue <LValueToRValue>
          `-DeclRefExpr {{address}} <col:65, col:71> 'i32' lvalue ParmVar {{address:source}} 'source' 'i32')");
}

TEST_F(SemaTest, ReportsReadOfUninitializedVariable) {
  Analyze(R"(func f() {
  var value i32;
  value;
})");

  ExpectError(2, 2, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, ChecksOnlyTheSelectedBaseRangeForDerivedToBaseReferenceBinding) {
  Analyze(R"(trivial struct Base { initialized i32; }
trivial struct Derived : Base { pending i32; }
func ReadBase(value copy Base) {}
func Check(source i32) {
  var object Derived;
  object.Base.initialized := source;
  ReadBase(object);
  object;
})");

  ExpectError(7, 2, "use of uninitialized variable 'object'", 6);
}

TEST_F(SemaTest, ReportsAddressOfUninitializedObject) {
  Analyze(R"(func Inspect() {
  var value i32;
  &value;
})");

  ExpectError(2, 3, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, ChecksAddressOperandSubexpressionsForInitialization) {
  Analyze(R"(trivial struct Box { value i32; }
func Inspect() {
  var object Box;
  var pointer *i32;
  &object.value;
  &*pointer;
})");

  ExpectError(4, 3, "use of uninitialized variable 'object'", 6);
  ExpectError(5, 4, "use of uninitialized variable 'pointer'", 7);
}

TEST_F(SemaTest, ChecksReachableConditionalAddressTargetsForInitialization) {
  Analyze(R"(func Inspect(condition bool) {
  var first i32;
  var second i32;
  &(condition ? first : second);
})");

  ExpectError(3, 16, "use of uninitialized variable 'first'", 5);
  ExpectError(3, 24, "use of uninitialized variable 'second'", 6);
}

TEST_F(SemaTest, ReadsAddressedAssignmentLhsAsAnOrdinaryUse) {
  Analyze(R"(func Inspect() {
  var value i32;
  &(value = 1);
})");

  ExpectError(2, 4, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, ChecksObjectUseInsideErroneousAddressExpression) {
  Analyze(R"(func Inspect() {
  var value i32;
  &(move value);
})");

  ExpectError(2, 2, "unary operator '&' requires an object lvalue operand", 13);
  ExpectError(2, 9, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, ReportsUninitializedUseOnAssignmentLhs) {
  Analyze(R"(func f() {
  var value i32;
  value = 1;
})");

  ExpectError(2, 2, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, ReadsPointerObjectWhenAssigningThroughDereference) {
  Analyze(R"(func f() {
  var pointer *i32;
  *pointer = 1;
})");

  ExpectError(2, 3, "use of uninitialized variable 'pointer'", 7);
}

TEST_F(SemaTest, ReportsRepeatedInitialization) {
  Analyze(R"(func f() {
  var value i32;
  value := 1;
  value := 2;
})");

  ExpectError(3, 2, "repeated initialization of variable 'value'", 5);
}

TEST_F(SemaTest, ReadsInitializationSourceBeforeCompletingTarget) {
  Analyze(R"(func f() {
  var value i32;
  value := value;
})");

  ExpectError(2, 11, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, RejectsNestedInitializationWithoutApplyingItsStateEffect) {
  Analyze(R"(func f() {
  var first i32;
  var second i32;
  first = (second := 1);
  second;
})");

  ExpectError(3, 11, "initialization expression must be used directly as an expression statement", 11);
  ExpectError(3, 2, "use of uninitialized variable 'first'", 5);
  ExpectError(4, 2, "use of uninitialized variable 'second'", 6);
}

TEST_F(SemaTest, RejectsGroupedInitializationWithoutApplyingItsStateEffect) {
  Analyze(R"(func f(source i32) {
  var value i32;
  (value := source);
  value;
})");

  ExpectError(2, 3, "initialization expression must be used directly as an expression statement", 15);
  ExpectError(3, 2, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, RejectsParenthesesInInitializationTargetsWithoutApplyingTheirStateEffect) {
  Analyze(R"(trivial struct Pair { field i32; }
func f(object mut Pair, source i32) {
  var value i32;
  (value) := source;
  (object).field := source;
  (object.field) := source;
  value;
})");

  ExpectError(3, 2, "initialization target must not contain grouping parentheses", 7);
  ExpectError(4, 2, "initialization target must not contain grouping parentheses", 14);
  ExpectError(5, 2, "initialization target must not contain grouping parentheses", 14);
  ExpectError(6, 2, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, AllowsParenthesesInInitializationSourcesAndAssignmentTargets) {
  Analyze(R"(func f(source i32, callback *func (i32) void) {
  var value i32;
  value := (source);
  (value) = source;
  (callback)(value);
})");
}

TEST_F(SemaTest, SupportsDelayedConstInitializationButRejectsAssignment) {
  Analyze(R"(func f(source i32) {
  var value const i32;
  value := source;
  value = source;
})");

  ExpectError(3, 2, "assignment target must be a modifiable lvalue, not 'const i32'", 5);
}

TEST_F(SemaTest, RequiresInitializedReferentForDelayedReferenceBinding) {
  Analyze(R"(func f() {
  var value i32;
  var link mut i32;
  link := value;
})");

  ExpectError(3, 10, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, RejectsAssignmentThroughCopyReference) {
  Analyze(R"(func f(link copy i32, source i32) {
  link = source;
})");

  ExpectError(1, 2, "assignment target must be a modifiable lvalue, not 'const i32'", 4);
}

TEST_F(SemaTest, AppliesConversionsToStandaloneInitializationAndAssignment) {
  Analyze(R"(func f() {
  var value u8;
  value := 1;
  value = 2;
})");

  ExpectWarning(2, 11, "implicit integer conversion from 'i32' to 'u8' may truncate value", 1);
  ExpectWarning(3, 10, "implicit integer conversion from 'i32' to 'u8' may truncate value", 1);
}

TEST_F(SemaTest, ReportsIndependentInitializationAndAssignmentConversionFailures) {
  Analyze(R"(func f() {
  var value bool;
  value := 1;
  value = 2;
})");

  ExpectError(2, 11, "cannot initialize variable 'value': no implicit conversion from 'i32' to 'bool'", 1);
  ExpectError(3, 10, "cannot assign to target: no implicit conversion from 'i32' to 'bool'", 1);
}

TEST_F(SemaTest, ReadsInvalidConditionalInitializationTarget) {
  Analyze("func f(c bool) { var x i32; (c ? x : 1) := 2; }");

  ExpectError(0, 28, "initialization target must not contain grouping parentheses", 11);
  ExpectError(0, 33, "use of uninitialized variable 'x'", 1);
}

TEST_F(SemaTest, DoesNotReadLvalueConditionalInitializationTarget) {
  Analyze("func f(c bool) { var x i32; var y i32; (c ? x : y) := 1; }");

  ExpectError(0, 39, "initialization target must not contain grouping parentheses", 11);
}

TEST_F(SemaTest, ReportsConflictingInitializationStatesAtMerge) {
  Analyze(R"(func f(condition bool) {
  var value i32;
  if condition {
    value := 1;
  }
  value;
})");

  ExpectError(2, 2, "initialization state of variable 'value' differs across control-flow paths", 0);
}

TEST_F(SemaTest, DoesNotApplyStateEffectsInUnreachableCode) {
  Analyze(R"(func f() i32 {
  return 1;
  var value i32;
  value;
})");
}

TEST_F(SemaTest, ReportsLoopHeaderInitializationConflictOnce) {
  Analyze(R"(func f(condition bool) {
  var value i32;
  while condition {
    value := 1;
  }
})");

  ExpectError(2, 8, "initialization state of variable 'value' differs across control-flow paths", 9);
}

TEST_F(SemaTest, MergesInitializationStatesIndependentlyOfPredecessorOrder) {
  Analyze(
      R"(func a(c bool, p bool, q bool) { var x i32; while c { if p { if q { x := 1; } break; } x := 1; break; } x; }
func b(c bool, p bool, q bool) { var x i32; while c { if p { x := 1; break; } if q { x := 1; } break; } x; })");

  ExpectError(0, 61, "initialization state of variable 'x' differs across control-flow paths", 16);
  ExpectError(0, 44, "initialization state of variable 'x' differs across control-flow paths", 59);
  ExpectError(1, 78, "initialization state of variable 'x' differs across control-flow paths", 16);
  ExpectError(1, 44, "initialization state of variable 'x' differs across control-flow paths", 59);
}

TEST_F(SemaTest, ReportsMissingFunctionResultOnItsNormalExit) {
  Analyze(R"(func f(condition bool) i32 {
  if condition {
    return 1;
  }
})");

  ExpectError(1, 2, "function return object is not initialized on this path", 0);
}

TEST_F(SemaTest, ReportsMissingVariableInitializerBlockResultOnItsExit) {
  Analyze(R"(func f(condition bool) {
  var value i32 := {
    if condition {
      value := 1;
    }
  }
})");

  ExpectError(2, 4, "variable 'value' is not initialized when its initializer block exits", 0);
}

TEST_F(SemaTest, AcceptsSequentialMultiResultTailInitialization) {
  Analyze(R"(func f() {
  var first i32, second i32 := {
    1, first
  }
  first;
  second;
})");
}

TEST_F(SemaTest, AcceptsForwardedTailIfInitialization) {
  Analyze(R"(func f(condition bool) i32 {
  if condition {
    1
  } else {
    2
  }
})");
}

TEST_F(SemaTest, AcceptsNamedReturnInitializationAssignmentAndEmptyReturn) {
  Analyze(R"(func f() var result i32 {
  result := 1;
  result = 2;
  return;
})");
}

TEST_F(SemaTest, ReportsImplicitResultAfterExplicitInitialization) {
  Analyze(R"(func f() var result i32 {
  result := 1;
  2
})");

  ExpectError(2, 2, "repeated initialization of variable 'result'", 1);
}

TEST_F(SemaTest, AcceptsDelayedReferenceBindingAndReferentAssignment) {
  Analyze(R"(func f(source i32) {
  var link mut i32;
  link := source;
  link = 2;
})");
}

TEST_F(SemaTest, RejectsFieldInitializationThroughTransparentReferences) {
  Analyze(R"(trivial struct Pair { value i32; }
func bind(source Pair) {
  var link mut Pair;
  link := source;
}
func update(pair mut Pair) {
  pair.value := 1;
  pair.value = 2;
})");

  ExpectError(6, 2, "cannot initialize a subobject through a reference", 10);
}

TEST_F(SemaTest, ReportsUseOfUnboundReference) {
  Analyze(R"(func f() {
  var link mut i32;
  link;
})");

  ExpectError(2, 2, "use of uninitialized variable 'link'", 4);
}

TEST_F(SemaTest, KeepsInitializationStateAfterErroneousSource) {
  Analyze(R"(func f() {
  var value i32;
  value := missing;
  value := 1;
})");

  ExpectError(2, 11, "use of undeclared identifier 'missing'", 7);
  ExpectError(3, 2, "repeated initialization of variable 'value'", 5);
}

TEST_F(SemaTest, RecoversExplicitDeclarationGroupAsInitialized) {
  Analyze(R"(func f() {
  var first, second i32 := 1;
  second := 2;
})");

  ExpectError(1, 13, "variable count does not match initializer count", 6);
  ExpectError(2, 2, "repeated initialization of variable 'second'", 6);
}

TEST_F(SemaTest, DiagnosesLoopControlOutsideLoops) {
  Analyze(R"(func f() {
  break;
  continue;
})");

  ExpectError(1, 2, "break is only allowed inside a loop", 6);
  ExpectError(2, 2, "continue is only allowed inside a loop", 9);
}

TEST_F(SemaTest, AcceptsLoopControlInsideLoops) {
  Analyze(R"(func f(condition bool) {
  while condition {
    if condition {
      break;
    }
    continue;
  }
})");
}

TEST_F(SemaTest, RecoversInferredDeclarationAsInitializedAfterSourceFailure) {
  Analyze(R"(func f() {
  var value := missing;
  value := 1;
})");

  ExpectError(1, 15, "use of undeclared identifier 'missing'", 7);
  ExpectError(2, 2, "repeated initialization of variable 'value'", 5);
}

TEST_F(SemaTest, ReportsOuterMissingResultAfterNestedInitializerBlock) {
  Analyze(R"(func f() i32 {
  var first i32, second i32 := { 1, 2 }
})");

  ExpectError(0, 13, "function return object is not initialized on this path", 0);
}

TEST_F(SemaTest, SuppressesMissingResultAfterTailArityError) {
  Analyze(R"(func f() i32 { 1, 2 }
func g() {
  var first i32, second i32 := { 1 }
})");

  ExpectError(0, 15, "function result block must have exactly one tail expression", 1);
  ExpectError(2, 33, "variable result block requires exactly 2 tail expressions", 1);
}

TEST_F(SemaTest, ChecksEachConditionalAssignmentTargetPath) {
  Analyze(R"(func f(condition bool) {
  var first i32 := 1;
  var second i32;
  (condition ? first : second) = 2;
})");

  ExpectError(3, 23, "use of uninitialized variable 'second'", 6);
}

TEST_F(SemaTest, OrdersNestedConditionalAssignmentTargetsBySource) {
  Analyze(R"(func f(c bool, d bool) {
  var x i32;
  var y i32;
  var z i32;
  (c ? (d ? x : y) : z) = 1;
})");

  ExpectError(4, 12, "use of uninitialized variable 'x'", 1);
  ExpectError(4, 16, "use of uninitialized variable 'y'", 1);
  ExpectError(4, 21, "use of uninitialized variable 'z'", 1);
}

TEST_F(SemaTest, OrdersDirectThenCompoundConditionalAssignmentTarget) {
  Analyze(R"(trivial struct S { value i32; }
func f(c bool) {
  var x i32;
  var y S;
  (c ? x : y.value) = 1;
})");

  ExpectError(4, 7, "use of uninitialized variable 'x'", 1);
  ExpectError(4, 11, "use of uninitialized variable 'y'", 1);
}

TEST_F(SemaTest, OrdersCompoundThenDirectConditionalAssignmentTarget) {
  Analyze(R"(trivial struct S { value i32; }
func f(c bool) {
  var x S;
  var y i32;
  (c ? x.value : y) = 1;
})");

  ExpectError(4, 7, "use of uninitialized variable 'x'", 1);
  ExpectError(4, 17, "use of uninitialized variable 'y'", 1);
}

TEST_F(SemaTest, ReportsEachConditionalAssignmentLhsUse) {
  Analyze(R"(func f(c bool, d bool) {
  var x i32;
  (c ? (d ? x : x) : x) = 1;
})");

  ExpectError(2, 12, "use of uninitialized variable 'x'", 1);
  ExpectError(2, 16, "use of uninitialized variable 'x'", 1);
  ExpectError(2, 21, "use of uninitialized variable 'x'", 1);
}

TEST_F(SemaTest, AcceptsConditionalAssignmentWhenBothTargetsAreInitialized) {
  Analyze(R"(func f(condition bool) {
  var first i32 := 1;
  var second i32 := 2;
  (condition ? first : second) = 3;
})");
}

TEST_F(SemaTest, ReportsMissingResultOnIncompleteTailIfBranchWithoutMergeConflict) {
  Analyze(R"(func f(condition bool) i32 {
  if condition {
    1
  } else {
  }
})");

  ExpectError(3, 9, "function return object is not initialized on this path", 0);
}

TEST_F(SemaTest, ReportsEachDistinctMissingResultExit) {
  Analyze(R"(func f(first bool, second bool) i32 {
  if first {
    if second {
      return 1;
    }
  }
})");

  ExpectError(2, 4, "function return object is not initialized on this path", 0);
  ExpectError(1, 2, "function return object is not initialized on this path", 0);
}

TEST_F(SemaTest, OrdersEachFunctionBranchBodyBeforeItsResultExit) {
  Analyze(R"(func f(condition bool) i32 {
  if condition {
    var first i32;
    first;
  } else {
    var second i32;
    second;
  }
})");

  ExpectError(3, 4, "use of uninitialized variable 'first'", 5);
  ExpectError(1, 15, "function return object is not initialized on this path", 0);
  ExpectError(6, 4, "use of uninitialized variable 'second'", 6);
  ExpectError(4, 9, "function return object is not initialized on this path", 0);
}

TEST_F(SemaTest, OrdersEachVariableBranchBodyBeforeItsResultExit) {
  Analyze(R"(func f(condition bool) {
  var result i32 := {
    if condition {
      var first i32;
      first;
    } else {
      var second i32;
      second;
    }
  }
})");

  ExpectError(4, 6, "use of uninitialized variable 'first'", 5);
  ExpectError(2, 17, "variable 'result' is not initialized when its initializer block exits", 0);
  ExpectError(7, 6, "use of uninitialized variable 'second'", 6);
  ExpectError(5, 11, "variable 'result' is not initialized when its initializer block exits", 0);
}

TEST_F(SemaTest, EmitsDefiniteInitializationFindingsInSourceOrder) {
  Analyze(R"(func f(condition bool) {
  var first bool;
  var second bool;
  var third bool;
  condition ? (condition && first) : second;
  third;
})");

  ExpectError(4, 28, "use of uninitialized variable 'first'", 5);
  ExpectError(4, 37, "use of uninitialized variable 'second'", 6);
  ExpectError(5, 2, "use of uninitialized variable 'third'", 5);
}

TEST_F(SemaTest, OrdersEmptyMergeConflictBeforeFollowingControlFlow) {
  Analyze(R"(func f(first bool, second bool) {
  var value i32;
  var later i32;
  if first {
    value := 1;
  }
  while second {}
  later;
})");

  ExpectError(3, 2, "initialization state of variable 'value' differs across control-flow paths", 0);
  ExpectError(7, 2, "use of uninitialized variable 'later'", 5);
}

TEST_F(SemaTest, OrdersNestedAssignmentFindingsByProgramPoint) {
  Analyze(R"(func f() {
  var first i32;
  var second i32;
  first = second = 1;
})");

  ExpectError(3, 10, "use of uninitialized variable 'second'", 6);
  ExpectError(3, 2, "use of uninitialized variable 'first'", 5);
}

TEST_F(SemaTest, OrdersNestedAssignmentInsideGenericRegionByOperatorSemantics) {
  Analyze(R"(func f() {
  var first i32;
  var second i32;
  0 + (first = second = 1);
})");

  ExpectError(3, 15, "use of uninitialized variable 'second'", 6);
  ExpectError(3, 7, "use of uninitialized variable 'first'", 5);
}

TEST_F(SemaTest, ChecksConditionalAssignmentTargetsInsideGenericRegion) {
  Analyze(R"(func f(c bool) {
  var first i32;
  var second i32;
  ((c ? first : second) = 1) + 0;
})");

  ExpectError(3, 8, "use of uninitialized variable 'first'", 5);
  ExpectError(3, 16, "use of uninitialized variable 'second'", 6);
}

TEST_F(SemaTest, ReadsInvalidConditionalAssignmentTargetInsideGenericRegion) {
  Analyze(R"(func f(c bool) {
  var value i32;
  ((c ? value : 1) = 2) + 0;
})");

  ExpectError(2, 3, "assignment target must be a modifiable lvalue, not 'i32'", 15);
  ExpectError(2, 8, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, DoesNotRepeatUninitializedUseForAssignmentResult) {
  Analyze(R"(func f() {
  var value i32;
  (value = 1) = 2;
})");

  ExpectError(2, 3, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, KeepsUserAssignmentResultIdentityOpaqueInChainedAssignment) {
  Analyze(R"(struct Value {}
ctor Value() {}
dtor Value() {}
func operator=(dst mut Value, src copy Value) mut Value { return dst; }
func Chain(second copy Value, third copy Value) {
  var first Value;
  (first = second) = third;
})");

  ExpectError(6, 3, "use of uninitialized variable 'first'", 5);
}

TEST_F(SemaTest, OrdersReadBeforeNaturalResultExitFinding) {
  Analyze(R"(func f() i32 {
  var value i32;
  value;
})");

  ExpectError(2, 2, "use of uninitialized variable 'value'", 5);
  ExpectError(0, 13, "function return object is not initialized on this path", 0);
}

TEST_F(SemaTest, ReadsConditionalBranchesWhenAssignmentTargetIsNotAnLValue) {
  Analyze(R"(func f(condition bool) {
  var value i32;
  (condition ? value : 1) = 2;
})");

  ExpectError(2, 2, "assignment target must be a modifiable lvalue, not 'i32'", 23);
  ExpectError(2, 15, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, ChecksAssignmentLhsUseWhenItsTypeIsInvalid) {
  Analyze(R"(func f() {
  var value Missing;
  value = 1;
})");

  ExpectError(1, 12, "unknown type 'Missing'", 7);
  ExpectError(2, 2, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, ChecksFinalIfMergeInVoidFunction) {
  Analyze(R"(func f(condition bool) {
  var value i32;
  if condition {
    value := 1;
  }
})");

  ExpectError(2, 2, "initialization state of variable 'value' differs across control-flow paths", 0);
}

TEST_F(SemaTest, TracksTrivialStructFieldsAcrossNestingAndInheritance) {
  Analyze(R"(trivial struct Inner { left i32; right i32; }
trivial struct Base { inherited i32; }
trivial struct Aggregate : Base { inner Inner; tail i32; }
func Complete() {
  var value Aggregate;
  value.inherited := 1;
  value.inner.left := 2;
  value.inner.right := 3;
  value.tail := 4;
  value;
}
func Missing() {
  var value Aggregate;
  value.inner.left := 1;
  value.inner.left;
  value.inner;
})");

  ExpectError(13, 2, "cannot initialize subobject of 'value' before preceding subobjects are fully initialized", 16);
  ExpectError(15, 2, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, ChecksReferenceBindingBeforeTransparentFieldAccess) {
  Analyze(R"(trivial struct Pair { x i32; }
func ReadBound(pair mut Pair) { pair.x; }
func ReadUnbound() {
  var pair mut Pair;
  pair.x;
}
func AssignUnbound() {
  var pair mut Pair;
  pair.x = 1;
})");

  ExpectError(4, 2, "use of uninitialized variable 'pair'", 4);
  ExpectError(8, 2, "use of uninitialized variable 'pair'", 4);
}

TEST_F(SemaTest, TreatsNonTrivialFieldsAndConstructorBasesAsAtomicLeaves) {
  Analyze(R"(struct Item { value i32; }
ctor Item(value i32) { this.value := value; }
dtor Item() {}
struct Holder { item Item; }
ctor Holder(value i32) {
  this.item.value;
  this.item := Item(value);
  this.item.value;
}
dtor Holder() {}
struct Base { value i32; }
ctor Base(value i32) { this.value := value; }
dtor Base() {}
struct Derived : Base { own i32; }
ctor Derived(value i32) {
  this.Base := Base(this.value);
  this.value;
  this.own := value;
}
dtor Derived() {})");

  ExpectError(5, 2, "use of uninitialized variable 'this'", 4);
  ExpectError(15, 20, "use of uninitialized variable 'this'", 4);
}

TEST_F(SemaTest, TracksStructFieldsInResultObjectsBranchesAndLoops) {
  Analyze(R"(trivial struct Pair { first i32; second i32; }
func Make(value i32) var result Pair {
  result.first := value;
  result.second := value;
  return;
}
func Block(condition bool) {
  var result Pair := {
    result.first := 1;
    if condition { result.second := 2; } else { result.second := 3; }
  }
  result;
}
func BranchConflict(condition bool) {
  var result Pair;
  if condition { result.first := 1; }
  result.first;
}
func LoopConflict(condition bool) {
  var result Pair;
  while condition { result.first := 1; }
})");

  ExpectError(15, 2, "initialization state of variable 'result' differs across control-flow paths", 35);
  ExpectError(20, 8, "initialization state of variable 'result' differs across control-flow paths", 9);
}

TEST_F(SemaTest, TracksNamedTrivialBaseSubobjectRanges) {
  Analyze(R"(trivial struct Base { value i32; }
trivial struct Derived : Base { own i32; }
func Read() {
  var object Derived;
  object.Base;
}
func Initialize(source Base) {
  var object Derived;
  object.Base := source;
  object.own := 1;
  object;
  object.Base := source;
})");

  ExpectError(4, 2, "use of uninitialized variable 'object'", 6);
  ExpectError(11, 2, "repeated initialization of variable 'object'", 11);
}

TEST_F(SemaTest, RequiresFormationForEmptyTrivialObjectsAndAllowsEmptyDelegation) {
  Analyze(R"(trivial struct Empty {}
func Value() {
  var value Empty;
  value;
  value := value;
}
struct Object {}
ctor Object(value i32) {}
ctor Object() { this := Object(0); }
dtor Object() {})");

  ExpectError(3, 2, "use of uninitialized variable 'value'", 5);
  ExpectError(4, 11, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, RecoversEmptyDelegationAfterSourceFailure) {
  Analyze(R"(struct Object {}
ctor Object(value i32) {}
ctor Object() { this := Object(missing); }
dtor Object() {})");

  ExpectError(2, 31, "use of undeclared identifier 'missing'", 7);
}

TEST_F(SemaTest, ReportsIncompleteConstructorThisAtNormalExit) {
  Analyze(R"(struct Object { first i32; second i32; }
ctor Object() {
  this.first := 1;
}
dtor Object() {})");

  ExpectError(1, 14, "object 'this' is not fully initialized on this path", 0);
}

TEST_F(SemaTest, EvaluatesSpecialAssignmentSourceBeforeCheckingItsTarget) {
  Analyze(R"(struct Object {}
func operator=(dst mut Object, src copy Object) {}
ctor Object() {}
dtor Object() {}
func Assign() {
  var target Object;
  var source Object;
  target = source;
})");

  ExpectError(7, 11, "use of uninitialized variable 'source'", 6);
  ExpectError(7, 2, "use of uninitialized variable 'target'", 6);
}

TEST_F(SemaTest, CommitsAValidFieldTargetAfterItsSourceFails) {
  Analyze(R"(trivial struct Pair { first i32; second i32; }
func Initialize() {
  var value Pair;
  value.first := missing;
  value.first;
  value.second;
})");

  ExpectError(3, 17, "use of undeclared identifier 'missing'", 7);
  ExpectError(5, 2, "use of uninitialized variable 'value'", 5);
}

TEST_F(SemaTest, InitializesAggregateRangesAtomically) {
  Analyze(R"(trivial struct Pair { first i32; second i32; }
func Initialize(source copy Pair) {
  var target Pair;
  target.first := 1;
  target := source;
  target.second;
})");

  ExpectError(4, 2, "repeated initialization of variable 'target'", 6);
  ExpectError(5, 2, "use of uninitialized variable 'target'", 6);
}

TEST_F(SemaTest, AnalyzesExpressionBeforeInvalidReturnLeavesInitializerBlock) {
  Analyze(R"(func f() {
  var source i32;
  var result i32 := {
    return source;
  }
})");

  ExpectError(3, 4, "return is not allowed in a variable initializer block", 0);
  ExpectError(3, 11, "use of uninitialized variable 'source'", 6);
}

TEST_F(SemaTest, RequiresActualFormationOfEmptyLocalsAndSubobjects) {
  Analyze(R"(trivial struct Empty {}
trivial struct Pair { first Empty; second Empty; }
func Use() {
  var empty Empty;
  empty;
  empty := Empty();
  empty := Empty();
  var pair Pair;
  pair.second := Empty();
  pair.first := Empty();
  pair;
})");
  ExpectError(4, 2, "use of uninitialized variable 'empty'", 5);
  ExpectError(6, 2, "repeated initialization of variable 'empty'", 5);
  ExpectError(8, 2, "cannot initialize subobject of 'pair' before preceding subobjects are fully initialized", 11);
}

TEST_F(SemaTest, RequiresEmptyReturnAndInitializerBlockResults) {
  Analyze(R"(trivial struct Empty {}
func Make() Empty {}
func Block() { var value Empty := {} })");
  ExpectError(1, 18, "function return object is not initialized on this path", 2);
  ExpectError(2, 34, "variable 'value' is not initialized when its initializer block exits", 2);
}

TEST_F(SemaTest, ChecksAllLocalValueObjectsInDeclarationOrder) {
  Analyze(R"(trivial struct Empty {}
trivial struct Pair { field i32; }
func Direct() {
  var first i32;
  var second i32 := 1;
}
func Delayed() {
  var first Empty;
  var second i32;
  second := 1;
}
func Subobject() {
  var first i32;
  var second Pair;
  second.field := 1;
})");
  ExpectError(4, 6, "cannot initialize before preceding variable 'first' is fully initialized", 6);
  ExpectError(9, 2, "cannot initialize before preceding variable 'first' is fully initialized", 6);
  ExpectError(14, 2, "cannot initialize before preceding variable 'first' is fully initialized", 12);
}

TEST_F(SemaTest, KeepsLexicalQueuesIndependentAndExcludesReferenceBindings) {
  Analyze(R"(func Use(source mut i32, condition bool) {
  var first i32;
  var reference mut i32 := source;
  {
    var nested i32 := 1;
  }
  var second i32;
  if condition { first := 1; second := 2; }
  else { first := 3; second := 4; }
  var unbound mut i32;
  var third i32 := 5;
})");
}

TEST_F(SemaTest, FormsGroupedAndInitializerBlockResultsInOrder) {
  Analyze(R"(func Use() {
  var a i32, b i32 := 1, 2;
  var c i32, d i32 := { 3, 4 }
  var e i32, f i32 := { e := 5; f := 6; }
})");
}

TEST_F(SemaTest, ChecksInitializerBlockResultsAgainstOuterPredecessors) {
  Analyze(R"(func Use() {
  var first i32;
  var second i32 := { 1 }
})");
  ExpectError(2, 22, "cannot initialize before preceding variable 'first' is fully initialized", 1);
}

TEST_F(SemaTest, ChecksPrecedingSubobjectsThroughNestedFieldProjections) {
  Analyze(R"(trivial struct Inner { first i32; second i32; }
trivial struct Base { base i32; }
trivial struct Value : Base { inner Inner; tail i32; }
func Use() {
  var value Value;
  value.inner.first := 1;
  value.base := 2;
  value.tail := 3;
  value.inner.second := 4;
})");
  ExpectError(5, 2, "cannot initialize subobject of 'value' before preceding subobjects are fully initialized", 17);
  ExpectError(7, 2, "cannot initialize subobject of 'value' before preceding subobjects are fully initialized", 10);
}

TEST_F(SemaTest, KeepsConstructorLocalsIndependentAndChecksEmptyFieldObligations) {
  Analyze(R"(trivial struct Empty {}
struct Object { first Empty; second i32; }
ctor Object() {
  var helper i32 := 1;
  this.second := helper;
  this.first := Empty();
}
dtor Object() {}
struct Missing { empty Empty; }
ctor Missing() {}
dtor Missing() {})");
  ExpectError(4, 2, "cannot initialize subobject of 'this' before preceding subobjects are fully initialized", 11);
  ExpectError(9, 15, "object 'this' is not fully initialized on this path", 2);
}

TEST_F(SemaTest, KeepsZeroLengthArraysUninitializedUntilWholeFormation) {
  Analyze(R"(func Use() {
  var empty [0] i32;
  empty;
  var next i32 := 1;
  empty := [0] i32 {};
  empty := [0] i32 {};
})");
  ExpectError(2, 2, "use of uninitialized variable 'empty'", 5);
  ExpectError(3, 6, "cannot initialize before preceding variable 'empty' is fully initialized", 4);
  ExpectError(5, 2, "repeated initialization of variable 'empty'", 5);
}

// Configured argument evaluation order.

TEST_P(ConfiguredSemaTest, EvaluatesArgumentsIncludingReceiverInConfiguredOrder) {
  Analyze(R"(func Call(first i32, second i32) {}
func Use() {
  var first i32, second i32;
  Call(first, second);
  first.Call(second);
})");
  if (GetParam() == cw::ABIKind::Itanium) {
    ExpectError(3, 7, "use of uninitialized variable 'first'", 5);
    ExpectError(3, 14, "use of uninitialized variable 'second'", 6);
    ExpectError(4, 2, "use of uninitialized variable 'first'", 5);
    ExpectError(4, 13, "use of uninitialized variable 'second'", 6);
  } else {
    ExpectError(3, 14, "use of uninitialized variable 'second'", 6);
    ExpectError(3, 7, "use of uninitialized variable 'first'", 5);
    ExpectError(4, 13, "use of uninitialized variable 'second'", 6);
    ExpectError(4, 2, "use of uninitialized variable 'first'", 5);
  }
}

TEST_P(ConfiguredSemaTest, KeepsArgumentControlFlowBetweenOrderedSiblings) {
  Analyze(R"(func Call(first i32, second i32) {}
func Use(condition bool) {
  var first i32, second i32, third i32;
  Call(condition ? first : second, third);
})");
  if (GetParam() == cw::ABIKind::Microsoft) {
    ExpectError(3, 35, "use of uninitialized variable 'third'", 5);
  }
  ExpectError(3, 19, "use of uninitialized variable 'first'", 5);
  ExpectError(3, 27, "use of uninitialized variable 'second'", 6);
  if (GetParam() == cw::ABIKind::Itanium) {
    ExpectError(3, 35, "use of uninitialized variable 'third'", 5);
  }
}

TEST_P(ConfiguredSemaTest, KeepsAssignmentRightFirstAndArrayElementsLeftFirst) {
  Analyze(R"(func Use() {
  var first i32, second i32;
  first = second;
  [2] i32 { first, second };
})");
  ExpectError(2, 10, "use of uninitialized variable 'second'", 6);
  ExpectError(2, 2, "use of uninitialized variable 'first'", 5);
  ExpectError(3, 12, "use of uninitialized variable 'first'", 5);
  ExpectError(3, 19, "use of uninitialized variable 'second'", 6);
}

TEST_P(ConfiguredSemaTest, AppliesArgumentOrderToConstructorsAndCallableObjects) {
  Analyze(R"(struct Object {}
ctor Object(first i32, second i32) {}
dtor Object() {}
trivial struct Callable {}
func operator()(receiver copy Callable, value i32) {}
func Construct() {
  var first i32, second i32;
  Object(first, second);
}
func Invoke() {
  var receiver Callable;
  var value i32;
  receiver(value);
})");
  if (GetParam() == cw::ABIKind::Itanium) {
    ExpectError(7, 9, "use of uninitialized variable 'first'", 5);
    ExpectError(7, 16, "use of uninitialized variable 'second'", 6);
    ExpectError(12, 2, "use of uninitialized variable 'receiver'", 8);
    ExpectError(12, 11, "use of uninitialized variable 'value'", 5);
  } else {
    ExpectError(7, 16, "use of uninitialized variable 'second'", 6);
    ExpectError(7, 9, "use of uninitialized variable 'first'", 5);
    ExpectError(12, 11, "use of uninitialized variable 'value'", 5);
    ExpectError(12, 2, "use of uninitialized variable 'receiver'", 8);
  }
}

TEST_P(ConfiguredSemaTest, AppliesArgumentOrderToOperatorsButKeepsAssignmentException) {
  Analyze(R"(trivial struct Value {}
func operator+(first copy Value, second copy Value) {}
func Use() {
  var first Value, second Value;
  first + second;
  first = second;
})");
  if (GetParam() == cw::ABIKind::Itanium) {
    ExpectError(4, 2, "use of uninitialized variable 'first'", 5);
    ExpectError(4, 10, "use of uninitialized variable 'second'", 6);
  } else {
    ExpectError(4, 10, "use of uninitialized variable 'second'", 6);
    ExpectError(4, 2, "use of uninitialized variable 'first'", 5);
  }
  ExpectError(5, 10, "use of uninitialized variable 'second'", 6);
  ExpectError(5, 2, "use of uninitialized variable 'first'", 5);
}

TEST_P(ConfiguredSemaTest, OrdersShortCircuitArgumentAndArrowReceiverOnce) {
  Analyze(R"(func Call(first bool, second bool) {}
func Use(condition bool) {
  var first bool, second bool;
  var pointer *bool;
  Call(condition && first, second);
  pointer->Call(second);
})");
  if (GetParam() == cw::ABIKind::Itanium) {
    ExpectError(4, 20, "use of uninitialized variable 'first'", 5);
    ExpectError(4, 27, "use of uninitialized variable 'second'", 6);
    ExpectError(5, 2, "use of uninitialized variable 'pointer'", 7);
    ExpectError(5, 16, "use of uninitialized variable 'second'", 6);
  } else {
    ExpectError(4, 27, "use of uninitialized variable 'second'", 6);
    ExpectError(4, 20, "use of uninitialized variable 'first'", 5);
    ExpectError(5, 16, "use of uninitialized variable 'second'", 6);
    ExpectError(5, 2, "use of uninitialized variable 'pointer'", 7);
  }
}

// Cross-stage error suppression and diagnostic ordering.

TEST_F(SemaTest, ChecksIndependentVirtualFunctionRulesAfterStructTypeErrors) {
  Analyze(R"(struct S { virtual { func bad() var result void; } field Missing; }
struct T { virtual { func f(var(bad) value i32) var result void; } })");

  ExpectError(0, 57, "unknown type 'Missing'", 7);
  ExpectError(0, 32, "void function cannot declare a named return object", 15);
  ExpectError(1, 48, "void function cannot declare a named return object", 15);
  ExpectError(1, 32, "unknown attribute 'bad'", 3);
}

TEST_F(SemaTest, AnalyzesBodyWhenFunctionSignatureContainsErrors) {
  Analyze(R"(func f(value Missing) {
  var local i32;
  local;
  missing_body;
})");

  ExpectError(0, 13, "unknown type 'Missing'", 7);
  ExpectError(3, 2, "use of undeclared identifier 'missing_body'", 12);
  ExpectError(2, 2, "use of uninitialized variable 'local'", 5);
}

TEST_F(SemaTest, ChecksValidReturnObjectWhenParameterTypeContainsErrors) {
  Analyze("func f(value Missing) i32 {}");

  ExpectError(0, 13, "unknown type 'Missing'", 7);
  ExpectError(0, 26, "function return object is not initialized on this path", 2);
}

TEST_F(SemaTest, AnalyzesGlobalInitializersAndRecoversParseErrors) {
  Analyze("var g i32 := missing_global; func bad() { missing_body; var ; } func good() { missing_good; }");

  ExpectError(0, 60, "expected identifier", 1);
  ExpectError(0, 13, "use of undeclared identifier 'missing_global'", 14);
  ExpectError(0, 42, "use of undeclared identifier 'missing_body'", 12);
  ExpectError(0, 78, "use of undeclared identifier 'missing_good'", 12);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-VarGroupDecl {{address}} <test.cw:1:1, col:29> contains-errors
| |-VarDecl {{address}} <col:5, col:10> g 'i32'
| | `-BuiltinType {{address}} <col:7, col:10> 'i32'
| `-DeclRefExpr {{address}} <col:14, col:28> 'missing_global' contains-errors
|-FunctionDecl {{address}} <col:30, col:64> bad 'func () void' contains-errors
| `-CompoundStmt {{address}} <col:41, col:64> contains-errors
|   |-ExprStmt {{address}} <col:43, col:56> contains-errors
|   | `-DeclRefExpr {{address}} <col:43, col:55> 'missing_body' contains-errors
|   `-DeclStmt {{address}} <col:57, col:60> contains-errors
|     `-VarGroupDecl {{address}} <col:57, col:60> contains-errors
`-FunctionDecl {{address}} <col:65, col:94> good 'func () void' contains-errors
  `-CompoundStmt {{address}} <col:77, col:94> contains-errors
    `-ExprStmt {{address}} <col:79, col:92> contains-errors
      `-DeclRefExpr {{address}} <col:79, col:91> 'missing_good' contains-errors)");
}

TEST_F(SemaTest, CollectsGlobalNameFromDeclarationWithParseErrors) {
  Analyze(R"(var value := ;
func value() {})");

  ExpectError(
      0, 13,
      "expected one of identifier, 'null', boolean literal, integer literal, character literal, floating literal, "
      "string literal, 'move', 'operator', 'this', 'ctor', 'dtor', 'nonvirtual', '&', '*', '+', '++', "
      "'-', '--', '~', '!', '(', '['",
      1);
  ExpectError(0, 4, "declaration of variable 'value' conflicts with function declaration", 0);
  ExpectNote(1, 5, "conflicting declaration is here", 0);
}

TEST_F(SemaTest, SuppressesShapeDiagnosticsForDeclarationWithParseErrors) {
  Analyze(R"(ctor S() { var ; }
struct S {}
dtor S() {})");

  ExpectError(0, 15, "expected identifier", 1);
}

TEST_F(SemaTest, CollectsCompleteNameFromDeclarationWithParseErrors) {
  Analyze(R"(func f() { var ; }
trivial struct f {})");

  ExpectError(0, 15, "expected identifier", 1);
  ExpectError(0, 5, "declaration of function 'f' conflicts with type declaration", 0);
  ExpectNote(1, 15, "conflicting declaration is here", 0);
}

TEST_F(SemaTest, EmitsDiagnosticsInStageOrder) {
  Analyze(R"(func() {}
trivial struct S {}
trivial struct S {})");

  ExpectError(2, 15, "redefinition of type 'S'", 0);
  ExpectNote(1, 15, "previous declaration is here", 0);
  ExpectError(0, 0, "function declaration requires a name or operator", 0);
}

TEST_F(SemaTest, ReportsUnknownTypesBeforeSkippingLaterDeclarationChecks) {
  Analyze(R"(func() MissingReturn {}
trivial struct S : MissingBase {
field **MissingField;
})");

  ExpectError(1, 19, "unknown type 'MissingBase'", 11);
  ExpectError(2, 8, "unknown type 'MissingField'", 12);
  ExpectError(0, 7, "unknown type 'MissingReturn'", 13);
  ExpectError(0, 0, "function declaration requires a name or operator", 0);

  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
|-FunctionDecl {{address}} <test.cw:1:1, col:24> contains-errors
| |-ReturnVarDecl {{address}} <col:8, col:21> contains-errors
| | `-NamedType {{address}} <col:8, col:21> 'MissingReturn' contains-errors
| `-CompoundStmt {{address}} <col:22, col:24>
`-StructDecl {{address}} <line:2:1, line:4:2> S trivial : 'MissingBase' contains-errors
  `-FieldDecl {{address}} <line:3:1, col:22> field contains-errors
    `-PointerType {{address}} <col:7, col:21> contains-errors
      `-PointerType {{address}} <col:8, col:21> contains-errors
        `-NamedType {{address}} <col:9, col:21> 'MissingField' contains-errors)");
}

TEST_F(SemaTest, SuppressesSemanticDiagnosticsForIncompleteTypeSyntax) {
  Analyze("func f() * {}");

  ExpectError(0, 11,
              "expected one of '[', 'virtual', 'const', 'mut', 'copy', 'move', '*', 'func', built-in type, identifier",
              1);
  ExpectAstDump(R"(TranslationUnitDecl {{address}} contains-errors
`-FunctionDecl {{address}} <test.cw:1:1, col:14> f contains-errors
  |-ReturnVarDecl {{address}} <col:10, col:11> contains-errors
  | `-PointerType {{address}} <col:10, col:11> contains-errors
  `-CompoundStmt {{address}} <col:12, col:14>)");
}
