set(CWC_TEST_RUNNER "${CMAKE_CURRENT_SOURCE_DIR}/run_cwc_case.cmake")
set(CWC_TEST_WORK_ROOT "${CMAKE_CURRENT_BINARY_DIR}/cases")

find_program(CWC_WASM_INSPECTOR NAMES obj2yaml llvm-readobj
  HINTS "${LLVM_TOOLS_BINARY_DIR}" NO_DEFAULT_PATH NO_CACHE)
find_program(CWC_SYMBOL_INSPECTOR NAMES llvm-nm
  HINTS "${LLVM_TOOLS_BINARY_DIR}" NO_DEFAULT_PATH NO_CACHE)

set(cwc_test_supported FALSE)
if(APPLE)
  string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" cwc_system_processor)
  if(cwc_system_processor STREQUAL "")
    string(TOLOWER "${CMAKE_HOST_SYSTEM_PROCESSOR}" cwc_system_processor)
  endif()
  if(cwc_system_processor MATCHES "^(arm64|aarch64)$")
    set(cwc_test_supported TRUE)
  endif()
endif()

if(NOT cwc_test_supported)
  message(STATUS "cwc driver tests disabled: native macOS arm64 is required")
  return()
endif()

function(add_cwc_program_case name expected_status)
  add_test(
    NAME "cwc.program.${name}"
    COMMAND
      "${CMAKE_COMMAND}"
      "-DCWC_EXECUTABLE=$<TARGET_FILE:cwc>"
      "-DCASE_MODE=program"
      "-DCASE_NAME=${name}"
      "-DCASE_SOURCE=${CMAKE_CURRENT_SOURCE_DIR}/program_cases/${name}.cw"
      "-DTEST_WORK_DIRECTORY=${CWC_TEST_WORK_ROOT}/program/${name}"
      "-DEXPECTED_PROGRAM_STATUS=${expected_status}"
      -P "${CWC_TEST_RUNNER}"
  )
  set_tests_properties("cwc.program.${name}" PROPERTIES LABELS "cwc;program" TIMEOUT 30)
endfunction()

function(add_cwc_driver_case name scenario)
  set(case_source "${CMAKE_CURRENT_SOURCE_DIR}/driver_cases/basic.cw")
  if(ARGC GREATER 2)
    set(case_source "${ARGV2}")
  endif()
  set(case_source_2 "")
  if(ARGC GREATER 3)
    set(case_source_2 "${ARGV3}")
  endif()
  add_test(
    NAME "cwc.driver.${name}"
    COMMAND
      "${CMAKE_COMMAND}"
      "-DCWC_EXECUTABLE=$<TARGET_FILE:cwc>"
      "-DCASE_MODE=driver"
      "-DCASE_NAME=${name}"
      "-DDRIVER_SCENARIO=${scenario}"
      "-DCASE_SOURCE=${case_source}"
      "-DCASE_SOURCE_2=${case_source_2}"
      "-DWASM_INSPECTOR=${CWC_WASM_INSPECTOR}"
      "-DSYMBOL_INSPECTOR=${CWC_SYMBOL_INSPECTOR}"
      "-DARCHIVER=${CMAKE_AR}"
      "-DCXX_COMPILER=${CMAKE_CXX_COMPILER}"
      "-DTEST_WORK_DIRECTORY=${CWC_TEST_WORK_ROOT}/driver/${name}"
      -P "${CWC_TEST_RUNNER}"
  )
  set_tests_properties("cwc.driver.${name}" PROPERTIES LABELS "cwc;driver" TIMEOUT 30)
endfunction()

set(wasm_driver_case_dir "${CMAKE_CURRENT_SOURCE_DIR}/driver_cases/wasm32-unknown-unknown")
set(interface_driver_case_dir "${CMAKE_CURRENT_SOURCE_DIR}/driver_cases/interface")
set(linking_driver_case_dir "${CMAKE_CURRENT_SOURCE_DIR}/driver_cases/linking")

foreach(case IN ITEMS calls lifetimes virtuals)
  add_cwc_driver_case("stable_link_${case}" stable_link
    "${linking_driver_case_dir}/${case}_provider.cw" "${linking_driver_case_dir}/${case}_consumer.cw")
endforeach()
add_cwc_driver_case(stable_object_symbols stable_symbols "${linking_driver_case_dir}/calls_provider.cw")
set_tests_properties("cwc.driver.stable_object_symbols" PROPERTIES
  SKIP_REGULAR_EXPRESSION "^-- cannot locate llvm-nm")
add_cwc_driver_case(stable_entries stable_entries)
add_cwc_driver_case(stable_duplicates stable_duplicates)
add_cwc_driver_case(stable_wasm_export stable_wasm_export)
set_tests_properties("cwc.driver.stable_wasm_export" PROPERTIES SKIP_REGULAR_EXPRESSION "cannot locate wasm-ld")

add_cwc_program_case(namespace_initialization 7)
add_cwc_program_case(namespace_operations 42)
add_cwc_program_case(return_constant 7)
add_cwc_program_case(local_value 7)
add_cwc_program_case(arithmetic_result 42)
add_cwc_program_case(function_call 11)
add_cwc_program_case(conditional_result 2)
add_cwc_program_case(global_initialization 7)
add_cwc_program_case(virtual_dispatch 2)
add_cwc_program_case(main_arguments 1)
add_cwc_program_case(pointer_round_trip 19)
add_cwc_program_case(base_subobject_conversion 20)
add_cwc_program_case(aggregate_values 15)
add_cwc_program_case(scope_lifetime 1)
add_cwc_program_case(temporary_lifetime 1)
add_cwc_program_case(conditional_lifetime 1)

add_cwc_driver_case(help help)
add_cwc_driver_case(invalid_arguments invalid_arguments)
add_cwc_driver_case(missing_option_value missing_option_value)
add_cwc_driver_case(removed_alias removed_alias)
add_cwc_driver_case(option_boundary option_boundary)
add_cwc_driver_case(xlinker_boundary xlinker_boundary)
add_cwc_driver_case(output_leading_dash output_leading_dash)
add_cwc_driver_case(explicit_output explicit_output)
add_cwc_driver_case(object_output object_output)
add_cwc_driver_case(llvm_ir_output llvm_ir_output)
add_cwc_driver_case(wasm_ir_output wasm_ir_output)
add_cwc_driver_case(wasm_object_output wasm_object_output)
add_cwc_driver_case(wasm_aggregate_ir wasm_aggregate_ir
                       "${wasm_driver_case_dir}/aggregate_values.cw")
add_cwc_driver_case(wasm_global_ir wasm_global_ir
                       "${wasm_driver_case_dir}/global_initialization.cw")
add_cwc_driver_case(wasm_virtual_slot_ir wasm_virtual_slot_ir
                       "${wasm_driver_case_dir}/virtual_pointers.cw")
add_cwc_driver_case(wasm_link wasm_link)
set_tests_properties("cwc.driver.wasm_link" PROPERTIES SKIP_REGULAR_EXPRESSION "cannot locate wasm-ld")
add_cwc_driver_case(wasm_multi_source_link wasm_multi_source_link
                       "${CMAKE_CURRENT_SOURCE_DIR}/driver_cases/basic.cw"
                       "${wasm_driver_case_dir}/aggregate_values.cw")
set_tests_properties("cwc.driver.wasm_multi_source_link" PROPERTIES SKIP_REGULAR_EXPRESSION "cannot locate wasm-ld")
add_cwc_driver_case(wasm_global_link wasm_global_link
                       "${wasm_driver_case_dir}/global_initialization.cw")
set_tests_properties("cwc.driver.wasm_global_link" PROPERTIES SKIP_REGULAR_EXPRESSION "cannot locate wasm-ld")
add_cwc_driver_case(wasm_link_failure_preserves_output wasm_link_failure_preserves_output)
set_tests_properties("cwc.driver.wasm_link_failure_preserves_output" PROPERTIES
  SKIP_REGULAR_EXPRESSION "cannot locate wasm-ld")
add_cwc_driver_case(wasm_unsupported_link_option wasm_unsupported_link_option)
add_cwc_driver_case(wasm_external_input wasm_external_input)
add_cwc_driver_case(unsupported_target unsupported_target)
add_cwc_driver_case(output_identity_protection output_identity_protection)
add_cwc_driver_case(missing_link_input missing_link_input)
add_cwc_driver_case(native_input_modes native_input_modes)
add_cwc_driver_case(native_library_inputs native_library_inputs)
add_cwc_driver_case(native_mixed_inputs native_mixed_inputs)
add_cwc_driver_case(native_initialization_order native_initialization_order)
add_cwc_driver_case(native_link_failures native_link_failures)
add_cwc_driver_case(native_output_protection native_output_protection)
add_cwc_driver_case(native_temporary_files native_temporary_files)

add_cwc_driver_case(namespace_multi_source namespace_multi_source
  "${CMAKE_CURRENT_SOURCE_DIR}/driver_cases/namespace_first.cw"
  "${CMAKE_CURRENT_SOURCE_DIR}/driver_cases/namespace_second.cw")

add_cwc_driver_case(interface_declarations interface_contents
  "${interface_driver_case_dir}/declarations.cw")
add_cwc_driver_case(interface_types interface_contents
  "${interface_driver_case_dir}/types.cw")
add_cwc_driver_case(interface_virtual interface_contents
  "${interface_driver_case_dir}/virtual.cw")
add_cwc_driver_case(interface_namespaces interface_contents
  "${interface_driver_case_dir}/namespaces_first.cw"
  "${interface_driver_case_dir}/namespaces_second.cw")
add_cwc_driver_case(import_roundtrip import_roundtrip
  "${interface_driver_case_dir}/declarations.cw" "${interface_driver_case_dir}/consumer.cw")
add_cwc_driver_case(import_object_output import_object_output
  "${CMAKE_CURRENT_SOURCE_DIR}/../cw/codegen_cases/import_virtual.cw"
  "${CMAKE_CURRENT_SOURCE_DIR}/../cw/codegen_cases/import_covariance.cw")
add_cwc_driver_case(import_symbols import_symbols
  "${CMAKE_CURRENT_SOURCE_DIR}/../cw/codegen_cases/import_virtual.cw")
set_tests_properties("cwc.driver.import_symbols" PROPERTIES SKIP_REGULAR_EXPRESSION "^-- cannot locate llvm-nm")
add_cwc_driver_case(import_link_modes import_link_modes)
add_cwc_driver_case(import_input_rules import_input_rules)
add_cwc_driver_case(import_wasm_link import_wasm_link)
set_tests_properties("cwc.driver.import_wasm_link" PROPERTIES SKIP_REGULAR_EXPRESSION "cannot locate wasm-ld")
add_cwc_driver_case(interface_naming interface_naming)
add_cwc_driver_case(interface_empty interface_empty)
add_cwc_driver_case(interface_stdout interface_stdout)
add_cwc_driver_case(interface_modes interface_modes)
add_cwc_driver_case(interface_input_protection interface_input_protection)
add_cwc_driver_case(interface_output_conflict interface_output_conflict)
add_cwc_driver_case(interface_frontend_failure interface_frontend_failure)
add_cwc_driver_case(interface_open_failure interface_open_failure)
add_cwc_driver_case(interface_prepare_failure interface_prepare_failure)
add_cwc_driver_case(interface_write_failure interface_write_failure)
