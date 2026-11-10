add_library(
  cw.grammar
  STATIC 
  grammar/Grammar.h grammar/Grammar.cpp
  grammar/LRParseTable.h grammar/LRParseTable.cpp
  grammar/LRStateMachine.h grammar/LRStateMachine.cpp
  grammar/GrammarAnalyzer.h grammar/GrammarAnalyzer.cpp
)

target_link_libraries(cw.grammar PUBLIC Boost::boost)
target_include_directories(cw.grammar PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../)

add_executable(
  cw_expr_parse_table
  ExprGrammar.h
  cw_expr_parse_table.cpp
)
target_link_libraries(cw_expr_parse_table cw.grammar Boost::boost Boost::program_options)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/ExprParseTable.h
  COMMAND cw_expr_parse_table --header > ${CMAKE_CURRENT_BINARY_DIR}/ExprParseTable.h
  DEPENDS cw_expr_parse_table
)

add_library(
  cw
  STATIC
  ${CMAKE_CURRENT_BINARY_DIR}/ExprParseTable.h
  Source.h Source.cpp
  ExprGrammar.h
  ExprParser.h ExprParser.cpp
  BuiltinTypes.h BuiltinTypes.cpp
  Token.h Token.cpp
  Literal.h Literal.cpp
  Lexer.h Lexer.cpp
  Parser.h Parser.cpp
  Sema.h Sema.cpp
  SemaConversion.h SemaConversion.cpp
  SemaOverload.h SemaOverload.cpp
  NameSyntax.h NameLookup.h NameLookup.cpp
  NamespaceContext.h NamespaceContext.cpp
  ASTContext.h ASTContext.cpp
  TargetInfo.h TargetInfo.cpp
  TypeLayout.h TypeLayout.cpp
  VTableLayout.h VTableLayout.cpp
  ConstantEvaluation.h ConstantEvaluation.cpp
  Diagnostic.h Diagnostic.cpp
  CFG.h CFG.cpp
  DefiniteInitialization.h DefiniteInitialization.cpp
  ast.h ast.cpp
  ASTVisitor.h ASTVisitor.cpp
  ASTDumper.h ASTDumper.cpp
  CodeGen.h CodeGen.cpp
  CodeGenFunction.h CodeGenFunction.cpp
  Backend.h Backend.cpp
  Interface.h Interface.cpp
)
target_link_libraries(cw PUBLIC cw.grammar LLVM PRIVATE fmt::fmt Boost::charconv)
target_include_directories(cw PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../ ${CMAKE_CURRENT_BINARY_DIR})
target_include_directories(cw SYSTEM PUBLIC ${LLVM_INCLUDE_DIRS})
target_compile_options(cw PRIVATE "SHELL:${LLVM_DEFINITIONS}")
