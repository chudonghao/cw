/// \file codegen_test.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include <cstddef>
#include <filesystem>
#include <fstream>
#include <iterator>
#include <memory>
#include <ostream>
#include <sstream>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Verifier.h>
#include <llvm/MC/TargetRegistry.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/Target/TargetMachine.h>

#include <gtest/gtest.h>

#include "cw/ASTContext.h"
#include "cw/CodeGen.h"
#include "cw/Diagnostic.h"
#include "cw/Lexer.h"
#include "cw/Parser.h"
#include "cw/Sema.h"
#include "cw/Source.h"

class CodeGenTest : public ::testing::Test {
  std::vector<cw::Source> sources_;
  cw::DiagnosticEngine frontend_diagnostic_engine_;
  cw::DiagnosticEngine codegen_diagnostic_engine_;
  llvm::LLVMContext llvm_context_;
  cw::TargetInfo target_info_{cw::TargetInfo::CreateNative().value()};
  std::unique_ptr<llvm::TargetMachine> target_;
  std::unique_ptr<llvm::Module> module_;
  std::size_t next_diagnostic_ = 0;
  bool generated_ = false;

 protected:
  void SetUp() override {
    target_ = cw::CodeGen::CreateTarget(target_info_, codegen_diagnostic_engine_);
    ASSERT_NE(target_, nullptr) << Diagnostics();
    EXPECT_EQ(target_->getTargetTriple().getArch(), llvm::Triple::aarch64);
    EXPECT_TRUE(target_->getTargetTriple().isMacOSX());
    EXPECT_EQ(target_->createDataLayout().getPointerSize(), 8u);
  }

  std::string Diagnostics() const {
    std::ostringstream output;
    frontend_diagnostic_engine_.Dump(output);
    codegen_diagnostic_engine_.Dump(output);
    return output.str();
  }

  void Generate(std::string source, std::string path = "test.cw", const llvm::TargetMachine* target = nullptr) {
    ASSERT_FALSE(generated_);
    generated_ = true;

    sources_ = {{std::move(path), std::move(source)}};
    frontend_diagnostic_engine_.SetSources(&sources_);
    codegen_diagnostic_engine_.SetSources(&sources_);
    cw::ASTContext ast_context(target_info_);
    cw::Lexer lexer;
    cw::Parser parser;
    lexer.Reset(&sources_);
    parser.SetLexer(&lexer);
    parser.SetASTContext(&ast_context);
    parser.SetDiagnosticEngine(&frontend_diagnostic_engine_);
    parser();
    ASSERT_FALSE(frontend_diagnostic_engine_.HasErrors()) << Diagnostics();
    cw::Sema sema;
    sema.SetASTContext(&ast_context);
    sema.SetDiagnosticEngine(&frontend_diagnostic_engine_);
    sema();
    ASSERT_FALSE(frontend_diagnostic_engine_.HasErrors()) << Diagnostics();
    cw::CodeGen codegen;
    codegen.SetASTContext(&ast_context);
    codegen.SetDiagnosticEngine(&codegen_diagnostic_engine_);
    codegen.SetLLVMContext(&llvm_context_);
    codegen.SetTargetMachine(target ? target : target_.get());
    // Verification and printing happen after the frontend and generator have been destroyed.
    module_ = codegen(sources_.front().path.string());
  }

  void ExpectIRText(const std::string& actual, std::string_view expected, std::string_view source_name) {
    // Check environment-dependent headers separately; compare every remaining byte literally.
    const std::string headers[] = {
        "; ModuleID = '" + std::string(source_name) + "'", "source_filename = \"" + std::string(source_name) + "\"",
        "target datalayout = \"" + target_->createDataLayout().getStringRepresentation() + "\"",
        "target triple = \"" + target_->getTargetTriple().str() + "\"", ""};
    std::istringstream input(actual);
    for (const auto& expected_header : headers) {
      std::string line;
      ASSERT_TRUE(std::getline(input, line)) << "missing IR header: " << expected_header;
      EXPECT_EQ(line, expected_header);
    }
    const std::string body{std::istreambuf_iterator<char>(input), std::istreambuf_iterator<char>()};
    EXPECT_EQ(body, expected);
  }

  void ExpectIR(std::string_view expected) {
    ASSERT_NE(module_, nullptr) << Diagnostics();
    std::string verification;
    llvm::raw_string_ostream verification_stream(verification);
    ASSERT_FALSE(llvm::verifyModule(*module_, &verification_stream)) << verification;
    std::string ir;
    llvm::raw_string_ostream output(ir);
    module_->print(output, nullptr);
    ExpectIRText(ir, expected, sources_.front().path.string());
  }

  void GenerateLanguageFeature(std::string_view name) {
    const std::filesystem::path case_directory{CW_CODEGEN_CASE_DIR};
    const std::filesystem::path source_path = case_directory / (std::string(name) + ".cw");
    const std::filesystem::path expected_path = case_directory / (std::string(name) + ".cw.ll");
    SCOPED_TRACE(source_path.string());

    std::ifstream source_stream(source_path, std::ios::binary);
    ASSERT_TRUE(source_stream.is_open()) << "failed to open " << source_path;
    std::ifstream expected_stream(expected_path, std::ios::binary);
    ASSERT_TRUE(expected_stream.is_open()) << "failed to open " << expected_path;

    std::string source((std::istreambuf_iterator<char>(source_stream)), std::istreambuf_iterator<char>());
    std::string expected((std::istreambuf_iterator<char>(expected_stream)), std::istreambuf_iterator<char>());
    Generate(std::move(source), source_path.filename().string());
    ExpectIR(expected);
  }

  void ExpectFailure() {
    EXPECT_EQ(module_, nullptr);
    EXPECT_TRUE(codegen_diagnostic_engine_.HasErrors());
  }

  void ExpectErrorWithoutLocation(std::string_view message) {
    const auto& diagnostics = codegen_diagnostic_engine_.Diagnostics();
    ASSERT_LT(next_diagnostic_, diagnostics.size()) << "missing expected diagnostic";

    const auto& actual = diagnostics[next_diagnostic_++];
    EXPECT_EQ(actual.severity, cw::kErrorDiagnostic);
    EXPECT_EQ(actual.message, std::string(message));
    EXPECT_FALSE(actual.location.has_value());
  }

  void TearDown() override {
    EXPECT_EQ(next_diagnostic_, codegen_diagnostic_engine_.Diagnostics().size()) << "unexpected diagnostic\n"
                                                                                 << Diagnostics();
  }
};

TEST_F(CodeGenTest, ProducesNativeModuleIndependentOfFrontend) {
  Generate("func Entry() i32 { 7 }");
  ExpectIR(R"(define noundef i32 @Entry() {
entry:
  %.result = alloca i32, align 4
  store i32 7, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}
)");
}

TEST_F(CodeGenTest, ReportsTargetMismatchWithoutSourceLocation) {
  const llvm::Triple triple("aarch64-unknown-linux-gnu");
  std::string error;
  const auto* target = llvm::TargetRegistry::lookupTarget(triple, error);
  ASSERT_NE(target, nullptr) << error;
  const std::unique_ptr<llvm::TargetMachine> target_machine(
      target->createTargetMachine(triple, "generic", "", llvm::TargetOptions(), llvm::Reloc::PIC_));
  ASSERT_NE(target_machine, nullptr);
  Generate("func Entry() i32 { 1 }", "test.cw", target_machine.get());

  ExpectFailure();
  ExpectErrorWithoutLocation("code generation target does not match the semantic target");
  EXPECT_EQ(Diagnostics(), "error: code generation target does not match the semantic target\n");
}

struct LanguageFeatureCase {
  const char* file_stem;
  const char* test_name;
};

void PrintTo(const LanguageFeatureCase& test, std::ostream* output) { *output << test.test_name; }

class LanguageFeatureTest : public CodeGenTest, public ::testing::WithParamInterface<LanguageFeatureCase> {};

TEST_P(LanguageFeatureTest, MatchesExpectedIR) { GenerateLanguageFeature(GetParam().file_stem); }

std::string LanguageFeatureCaseName(const ::testing::TestParamInfo<LanguageFeatureCase>& information) {
  return information.param.test_name;
}

INSTANTIATE_TEST_SUITE_P(
    LanguageFeatures, LanguageFeatureTest,
    ::testing::Values(
        LanguageFeatureCase{"local_integer_initialization", "LocalIntegerInitialization"},
        LanguageFeatureCase{"value_parameters", "ValueParameters"},
        LanguageFeatureCase{"reference_parameters", "ReferenceParameters"},
        LanguageFeatureCase{"reference_binding", "ReferenceBinding"},
        LanguageFeatureCase{"temporary_reference_binding", "TemporaryReferenceBinding"},
        LanguageFeatureCase{"assignment_evaluation", "AssignmentEvaluation"},
        LanguageFeatureCase{"call_evaluation", "CallEvaluation"}, LanguageFeatureCase{"forward_call", "ForwardCall"},
        LanguageFeatureCase{"function_overloading", "FunctionOverloading"},
        LanguageFeatureCase{"block_results", "BlockResults"}, LanguageFeatureCase{"function_return", "FunctionReturn"},
        LanguageFeatureCase{"discarded_expression", "DiscardedExpression"},
        LanguageFeatureCase{"boolean_objects", "BooleanObjects"}, LanguageFeatureCase{"boolean_logic", "BooleanLogic"},
        LanguageFeatureCase{"while_loop", "WhileLoop"}, LanguageFeatureCase{"conditional_value", "ConditionalValue"},
        LanguageFeatureCase{"conditional_void", "ConditionalVoid"},
        LanguageFeatureCase{"conditional_reference", "ConditionalReference"},
        LanguageFeatureCase{"integer_arithmetic", "IntegerArithmetic"},
        LanguageFeatureCase{"integer_division", "IntegerDivision"},
        LanguageFeatureCase{"scalar_comparison", "ScalarComparison"},
        LanguageFeatureCase{"arithmetic_evaluation", "ArithmeticEvaluation"},
        LanguageFeatureCase{"numeric_loop", "NumericLoop"}, LanguageFeatureCase{"integer_types", "IntegerTypes"},
        LanguageFeatureCase{"integer_literals", "IntegerLiterals"},
        LanguageFeatureCase{"integer_conversions", "IntegerConversions"},
        LanguageFeatureCase{"integer_arithmetic_widths", "IntegerArithmeticWidths"},
        LanguageFeatureCase{"integer_comparison_types", "IntegerComparisonTypes"},
        LanguageFeatureCase{"integer_division_widths", "IntegerDivisionWidths"},
        LanguageFeatureCase{"integer_conversion_flow", "IntegerConversionFlow"},
        LanguageFeatureCase{"floating_types", "FloatingTypes"},
        LanguageFeatureCase{"floating_literals", "FloatingLiterals"},
        LanguageFeatureCase{"floating_arithmetic", "FloatingArithmetic"},
        LanguageFeatureCase{"floating_comparison", "FloatingComparison"},
        LanguageFeatureCase{"floating_conversions", "FloatingConversions"},
        LanguageFeatureCase{"floating_to_integer", "FloatingToInteger"},
        LanguageFeatureCase{"floating_evaluation", "FloatingEvaluation"},
        LanguageFeatureCase{"pointer_objects", "PointerObjects"},
        LanguageFeatureCase{"pointer_qualification", "PointerQualification"},
        LanguageFeatureCase{"pointer_comparison", "PointerComparison"},
        LanguageFeatureCase{"pointer_evaluation", "PointerEvaluation"},
        LanguageFeatureCase{"function_addresses", "FunctionAddresses"},
        LanguageFeatureCase{"indirect_calls", "IndirectCalls"},
        LanguageFeatureCase{"indirect_evaluation", "IndirectEvaluation"},
        LanguageFeatureCase{"array_initialization", "ArrayInitialization"},
        LanguageFeatureCase{"array_assignment", "ArrayAssignment"},
        LanguageFeatureCase{"array_references", "ArrayReferences"},
        LanguageFeatureCase{"array_conditionals", "ArrayConditionals"},
        LanguageFeatureCase{"array_evaluation", "ArrayEvaluation"}, LanguageFeatureCase{"array_loop", "ArrayLoop"},
        LanguageFeatureCase{"array_zero_size", "ArrayZeroSize"},
        LanguageFeatureCase{"string_literals", "StringLiterals"}, LanguageFeatureCase{"string_arrays", "StringArrays"},
        LanguageFeatureCase{"string_references", "StringReferences"},
        LanguageFeatureCase{"string_conditionals", "StringConditionals"},
        LanguageFeatureCase{"struct_initialization", "StructInitialization"},
        LanguageFeatureCase{"struct_members", "StructMembers"},
        LanguageFeatureCase{"struct_assignment", "StructAssignment"},
        LanguageFeatureCase{"struct_aggregates", "StructAggregates"},
        LanguageFeatureCase{"struct_conditionals", "StructConditionals"},
        LanguageFeatureCase{"struct_evaluation", "StructEvaluation"},
        LanguageFeatureCase{"struct_zero_size", "StructZeroSize"},
        LanguageFeatureCase{"aggregate_values", "AggregateValues"},
        LanguageFeatureCase{"aggregate_floats", "AggregateFloats"},
        LanguageFeatureCase{"aggregate_calls", "AggregateCalls"},
        LanguageFeatureCase{"aggregate_results", "AggregateResults"},
        LanguageFeatureCase{"aggregate_evaluation", "AggregateEvaluation"},
        LanguageFeatureCase{"aggregate_indirect_evaluation", "AggregateIndirectEvaluation"},
        LanguageFeatureCase{"aggregate_zero_size", "AggregateZeroSize"},
        LanguageFeatureCase{"inheritance_layout", "InheritanceLayout"},
        LanguageFeatureCase{"base_result_initialization", "BaseResultInitialization"},
        LanguageFeatureCase{"empty_base_layout", "EmptyBaseLayout"},
        LanguageFeatureCase{"layout_classification", "LayoutClassification"},
        LanguageFeatureCase{"inheritance_access", "InheritanceAccess"},
        LanguageFeatureCase{"inheritance_operations", "InheritanceOperations"},
        LanguageFeatureCase{"inheritance_calls", "InheritanceCalls"},
        LanguageFeatureCase{"inheritance_evaluation", "InheritanceEvaluation"},
        LanguageFeatureCase{"inheritance_zero_size", "InheritanceZeroSize"},
        LanguageFeatureCase{"operator_calls", "OperatorCalls"},
        LanguageFeatureCase{"operator_results", "OperatorResults"},
        LanguageFeatureCase{"callable_objects", "CallableObjects"},
        LanguageFeatureCase{"operator_evaluation", "OperatorEvaluation"},
        LanguageFeatureCase{"object_construction", "ObjectConstruction"},
        LanguageFeatureCase{"explicit_lifetime", "ExplicitLifetime"},
        LanguageFeatureCase{"object_results", "ObjectResults"},
        LanguageFeatureCase{"local_lifetimes", "LocalLifetimes"},
        LanguageFeatureCase{"object_destruction", "ObjectDestruction"},
        LanguageFeatureCase{"object_arguments", "ObjectArguments"},
        LanguageFeatureCase{"temporary_lifetimes", "TemporaryLifetimes"},
        LanguageFeatureCase{"object_arrays", "ObjectArrays"},
        LanguageFeatureCase{"full_expression_lifetimes", "FullExpressionLifetimes"},
        LanguageFeatureCase{"object_assignment", "ObjectAssignment"},
        LanguageFeatureCase{"object_array_assignment", "ObjectArrayAssignment"},
        LanguageFeatureCase{"array_assignment_lifetimes", "ArrayAssignmentLifetimes"},
        LanguageFeatureCase{"global_initialization", "GlobalInitialization"},
        LanguageFeatureCase{"global_lifetimes", "GlobalLifetimes"},
        LanguageFeatureCase{"global_zero_size", "GlobalZeroSize"},
        LanguageFeatureCase{"virtual_dispatch", "VirtualDispatch"},
        LanguageFeatureCase{"virtual_pointers", "VirtualPointers"},
        LanguageFeatureCase{"virtual_covariance", "VirtualCovariance"},
        LanguageFeatureCase{"virtual_lifetimes", "VirtualLifetimes"},
        LanguageFeatureCase{"abstract_dispatch", "AbstractDispatch"}),
    LanguageFeatureCaseName);
