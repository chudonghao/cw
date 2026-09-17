include(GoogleTest)

add_executable(lang_test lang_test.cpp)
target_link_libraries(lang_test GTest::gtest_main cw.lang)
gtest_discover_tests(lang_test)

add_executable(lexer_test lexer_test.cpp)
target_link_libraries(lexer_test GTest::gtest_main cw)
gtest_discover_tests(lexer_test)

add_executable(literal_test literal_test.cpp)
target_link_libraries(literal_test GTest::gtest_main cw)
gtest_discover_tests(literal_test)

add_executable(parser_test parser_test.cpp)
target_link_libraries(parser_test GTest::gtest_main cw)
gtest_discover_tests(parser_test)

add_executable(sema_test sema_test.cpp)
target_link_libraries(sema_test GTest::gtest_main cw)
target_compile_definitions(sema_test PRIVATE CW_SEMA_CASE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/sema_cases")
gtest_discover_tests(sema_test)

add_subdirectory(sema_cases)
