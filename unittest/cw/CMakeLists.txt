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

add_executable(codegen_test codegen_test.cpp)
target_link_libraries(codegen_test GTest::gtest_main cw)
target_compile_definitions(codegen_test PRIVATE CW_CODEGEN_CASE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/codegen_cases")
gtest_discover_tests(codegen_test)

# Resolve Clang from the current LLVM installation, including after reconfiguration.
unset(CLANG_EXECUTABLE CACHE)
find_program(CLANG_EXECUTABLE NAMES clang++
  HINTS "${LLVM_TOOLS_BINARY_DIR}" NO_DEFAULT_PATH NO_CACHE)

add_subdirectory(sema_cases)
add_subdirectory(codegen_cases)
