find_package(GTest REQUIRED)

add_executable(test_grammar EXCLUDE_FROM_ALL grammar.cpp)
target_link_libraries(test_grammar GTest::gtest_main cw_lang)

