add_library(
  cw_lang
  STATIC 
  lang/Grammar.h lang/Grammar.cpp
  lang/GrammarAnalyzer.h lang/GrammarAnalyzer.cpp
  Token.cpp Token.h
  Lexer.h Lexer.cpp
  Parser.h Parser.cpp
)

target_link_libraries(cw_lang PUBLIC Boost::boost)
target_include_directories(cw_lang PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../)
