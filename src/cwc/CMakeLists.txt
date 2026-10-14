find_program(CWC_LLVM_TBLGEN_EXECUTABLE NAMES llvm-tblgen
  HINTS "${LLVM_TOOLS_BINARY_DIR}" REQUIRED)

set(LLVM_TABLEGEN_EXE "${CWC_LLVM_TBLGEN_EXECUTABLE}")
set(LLVM_TABLEGEN_TARGET "")
include("${LLVM_CMAKE_DIR}/TableGen.cmake")
set(LLVM_TARGET_DEFINITIONS "${CMAKE_CURRENT_SOURCE_DIR}/Options.td")
tablegen(LLVM CWCOptions.inc -gen-opt-parser-defs EXTRA_INCLUDES "${LLVM_INCLUDE_DIRS}")
set(CWC_OPTIONS_INC "${CMAKE_CURRENT_BINARY_DIR}/CWCOptions.inc")
add_custom_target(cwc_options_tablegen DEPENDS "${CWC_OPTIONS_INC}")

add_executable(
  cwc
  ${CWC_OPTIONS_INC}
  main.cpp
  DriverOptions.h
  DriverOptions.cpp
  Options.td
  DarwinToolChain.h
  DarwinToolChain.cpp
  WebAssemblyToolChain.h
  WebAssemblyToolChain.cpp
)

add_dependencies(cwc cwc_options_tablegen)
target_include_directories(cwc PRIVATE ${CMAKE_CURRENT_BINARY_DIR} ${LLVM_INCLUDE_DIRS})
target_compile_options(cwc PRIVATE "SHELL:${LLVM_DEFINITIONS}")
target_link_libraries(cwc PRIVATE cw LLVMOption)
