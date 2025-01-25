add_library(
  cw.lang
  STATIC 
  lang/Grammar.h lang/Grammar.cpp
  lang/LRParseTable.h lang/LRParseTable.cpp
  lang/LRStateMachine.h lang/LRStateMachine.cpp
  lang/GrammarAnalyzer.h lang/GrammarAnalyzer.cpp
)

target_link_libraries(cw.lang PUBLIC Boost::boost)
target_include_directories(cw.lang PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../)

add_executable(
  cw_expr_parse_table
  ExprGrammar.h
  cw_expr_parse_table.cpp
)
target_link_libraries(cw_expr_parse_table cw.lang Boost::boost)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/ExprParseTable.h
  COMMAND cw_expr_parse_table --header > ${CMAKE_CURRENT_BINARY_DIR}/ExprParseTable.h
  DEPENDS cw_expr_parse_table
)

add_library(
  cw
  STATIC
  ${CMAKE_CURRENT_BINARY_DIR}/ExprParseTable.h
  Source.h
  ExprGrammar.h
  ExprParser.h ExprParser.cpp
  Token.h Token.cpp
  Lexer.h Lexer.cpp
  Parser.h Parser.cpp
  Exception.h Exception.cpp
)
target_link_libraries(cw PUBLIC cw.lang)
target_include_directories(cw PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../ ${CMAKE_CURRENT_BINARY_DIR})

