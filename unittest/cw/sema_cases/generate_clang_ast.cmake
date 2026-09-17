foreach(variable
        CLANG_EXECUTABLE
        PYTHON_EXECUTABLE
        NORMALIZER
        CASE_DIRECTORY
        SOURCE_FILE
        RAW_AST_FILE
        NORMALIZED_AST_FILE)
  if(NOT DEFINED ${variable})
    message(FATAL_ERROR "Missing required variable: ${variable}")
  endif()
endforeach()

execute_process(
  COMMAND
    "${CLANG_EXECUTABLE}"
    -std=c++17
    -Wno-unused-value
    -fno-color-diagnostics
    -Xclang -ast-dump
    -fsyntax-only
    "${SOURCE_FILE}"
  WORKING_DIRECTORY "${CASE_DIRECTORY}"
  RESULT_VARIABLE clang_result
  OUTPUT_FILE "${RAW_AST_FILE}"
  ERROR_VARIABLE clang_error
)

if(NOT clang_result EQUAL 0)
  file(REMOVE "${RAW_AST_FILE}")
  message(FATAL_ERROR "Clang AST generation failed:\n${clang_error}")
endif()

execute_process(
  COMMAND
    "${PYTHON_EXECUTABLE}"
    "${NORMALIZER}"
    "${RAW_AST_FILE}"
    "${NORMALIZED_AST_FILE}"
  WORKING_DIRECTORY "${CASE_DIRECTORY}"
  RESULT_VARIABLE normalize_result
  ERROR_VARIABLE normalize_error
)

if(NOT normalize_result EQUAL 0)
  message(FATAL_ERROR "Clang AST normalization failed:\n${normalize_error}")
endif()
