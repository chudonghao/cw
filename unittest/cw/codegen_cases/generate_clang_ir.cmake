foreach(variable CLANG_EXECUTABLE TARGET_TRIPLE CASE_DIRECTORY CASE_NAME)
  if(NOT DEFINED ${variable} OR "${${variable}}" STREQUAL "")
    message(FATAL_ERROR "Missing required variable: ${variable}")
  endif()
endforeach()

if(NOT TARGET_TRIPLE MATCHES "^(arm64|aarch64)-apple-(darwin|macosx)")
  message(FATAL_ERROR "Clang IR references require the native macOS arm64 target")
endif()

execute_process(
  COMMAND "${CLANG_EXECUTABLE}" --version
  RESULT_VARIABLE version_result
  OUTPUT_VARIABLE clang_version
  ERROR_VARIABLE version_error
)
if(NOT version_result EQUAL 0)
  message(FATAL_ERROR "Cannot read Clang version:\n${version_error}")
endif()
string(REGEX MATCH "^[^\r\n]*" clang_version "${clang_version}")

set(options
  "--target=${TARGET_TRIPLE}"
  -std=c++17
  -O0
  -g0
  -S
  -emit-llvm
  -fno-discard-value-names
)
list(APPEND options ${CASE_OPTIONS})
execute_process(
  COMMAND "${CLANG_EXECUTABLE}" ${options} "${CASE_NAME}.cpp" -o -
  WORKING_DIRECTORY "${CASE_DIRECTORY}"
  RESULT_VARIABLE clang_result
  OUTPUT_VARIABLE clang_ir
  ERROR_VARIABLE clang_error
)
if(NOT clang_result EQUAL 0)
  message(FATAL_ERROR "Clang IR generation failed:\n${clang_error}")
endif()
if(NOT clang_error STREQUAL "")
  message(STATUS "Clang diagnostics for ${CASE_NAME}:\n${clang_error}")
endif()

string(JOIN " " command_options ${options})
set(reference_file "${CASE_DIRECTORY}/${CASE_NAME}.cpp.ll")
# Keep the complete Clang output and record the settings with each reference.
# Replace the saved reference only after compilation succeeds.
file(WRITE "${reference_file}.tmp"
  "; Reference compiler: ${clang_version}\n"
  "; Reference command: clang++ ${command_options} ${CASE_NAME}.cpp -o -\n"
  "${clang_ir}")
file(RENAME "${reference_file}.tmp" "${reference_file}")
