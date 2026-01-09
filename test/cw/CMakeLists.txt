add_executable(test_lang EXCLUDE_FROM_ALL lang.cpp)
target_link_libraries(test_lang GTest::gtest_main cw.lang)

add_executable(test_lexer EXCLUDE_FROM_ALL lexer.cpp)
target_link_libraries(test_lexer GTest::gtest_main cw)

add_executable(test_parser EXCLUDE_FROM_ALL parser.cpp)
target_link_libraries(test_parser GTest::gtest_main cw)
