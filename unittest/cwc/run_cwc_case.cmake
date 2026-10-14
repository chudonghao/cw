foreach(variable CWC_EXECUTABLE CASE_MODE CASE_NAME TEST_WORK_DIRECTORY)
  if(NOT DEFINED ${variable} OR "${${variable}}" STREQUAL "")
    message(FATAL_ERROR "Missing required variable: ${variable}")
  endif()
endforeach()

if(NOT EXISTS "${CWC_EXECUTABLE}")
  message(FATAL_ERROR "cwc executable does not exist: ${CWC_EXECUTABLE}")
endif()

file(REMOVE_RECURSE "${TEST_WORK_DIRECTORY}")
file(MAKE_DIRECTORY "${TEST_WORK_DIRECTORY}")

function(assert_nonempty_file path description)
  if(NOT EXISTS "${path}" OR IS_DIRECTORY "${path}")
    message(FATAL_ERROR "${description} is not a regular file: ${path}")
  endif()
  file(SIZE "${path}" size)
  if(size LESS 1)
    message(FATAL_ERROR "${description} is empty: ${path}")
  endif()
endfunction()

function(assert_file_contents path expected)
  if(NOT EXISTS "${path}" OR IS_DIRECTORY "${path}")
    message(FATAL_ERROR "${CASE_NAME}: missing file ${path}")
  endif()
  file(READ "${path}" actual)
  if(NOT "${actual}" STREQUAL "${expected}")
    message(FATAL_ERROR "${CASE_NAME}: unexpected contents in ${path}\nExpected:\n${expected}\nActual:\n${actual}")
  endif()
endfunction()

function(assert_absent path)
  if(EXISTS "${path}" OR IS_SYMLINK "${path}")
    message(FATAL_ERROR "${CASE_NAME}: unexpected output ${path}")
  endif()
endfunction()

function(assert_contains value needle description)
  string(FIND "${value}" "${needle}" position)
  if(position EQUAL -1)
    message(FATAL_ERROR
      "${description} does not contain '${needle}':\n${value}\n"
      "work directory: ${TEST_WORK_DIRECTORY}")
  endif()
endfunction()

function(assert_wasm_module path description expected_export)
  assert_nonempty_file("${path}" "${description}")
  file(READ "${path}" magic LIMIT 4 OFFSET 0 HEX)
  string(TOLOWER "${magic}" magic)
  if(NOT "${magic}" STREQUAL "0061736d")
    message(FATAL_ERROR "${description} does not start with the WebAssembly magic: ${magic}")
  endif()
  file(READ "${path}" version LIMIT 4 OFFSET 4 HEX)
  string(TOLOWER "${version}" version)
  if(NOT "${version}" STREQUAL "01000000")
    message(FATAL_ERROR "${description} does not use WebAssembly version 1: ${version}")
  endif()
  if(DEFINED WASM_INSPECTOR AND NOT "${WASM_INSPECTOR}" STREQUAL "" AND EXISTS "${WASM_INSPECTOR}")
    get_filename_component(inspector_name "${WASM_INSPECTOR}" NAME)
    if("${inspector_name}" STREQUAL "obj2yaml")
      execute_process(
        COMMAND "${WASM_INSPECTOR}" "${path}"
        RESULT_VARIABLE inspector_result
        OUTPUT_VARIABLE inspector_output
        ERROR_VARIABLE inspector_error
      )
      if(NOT "${inspector_result}" STREQUAL "0")
        message(FATAL_ERROR "${description} inspector failed:\n${inspector_error}")
      endif()
      assert_contains("${inspector_output}" "Type:            EXPORT" "${description} export section")
      # obj2yaml may quote a scalar; match the complete name rather than a prefix.
      foreach(export_name IN ITEMS "${expected_export}" "'${expected_export}'" "\"${expected_export}\"")
        string(FIND "${inspector_output}" "Name:            ${export_name}\n" export_position)
        if(NOT export_position EQUAL -1)
          return()
        endif()
      endforeach()
      message(FATAL_ERROR "${description} does not export '${expected_export}':\n${inspector_output}")
    else()
      execute_process(
        COMMAND "${WASM_INSPECTOR}" --file-headers --sections "${path}"
        RESULT_VARIABLE inspector_result
        OUTPUT_VARIABLE inspector_output
        ERROR_VARIABLE inspector_error
      )
      if(NOT "${inspector_result}" STREQUAL "0")
        message(FATAL_ERROR "${description} inspector failed:\n${inspector_error}")
      endif()
      assert_contains("${inspector_output}" "Format: WASM" "${description} format")
    endif()
  endif()
endfunction()

function(execute_cwc expected_status)
  execute_process(
    COMMAND "${CWC_EXECUTABLE}" ${ARGN}
    WORKING_DIRECTORY "${TEST_WORK_DIRECTORY}"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
  )
  if(NOT "${result}" STREQUAL "${expected_status}")
    message(FATAL_ERROR
      "${CASE_NAME}: cwc returned '${result}', expected '${expected_status}'\n"
      "stdout:\n${output}\n"
      "stderr:\n${error}\n"
      "work directory: ${TEST_WORK_DIRECTORY}")
  endif()
  set(CWC_OUTPUT "${output}" PARENT_SCOPE)
  set(CWC_ERROR "${error}" PARENT_SCOPE)
endfunction()

function(execute_program expected_status path)
  execute_process(
    COMMAND "${path}"
    WORKING_DIRECTORY "${TEST_WORK_DIRECTORY}"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
  )
  if(NOT "${result}" STREQUAL "${expected_status}")
    message(FATAL_ERROR
      "${CASE_NAME}: generated program returned '${result}', expected '${expected_status}'\n"
      "stdout:\n${output}\n"
      "stderr:\n${error}\n"
      "work directory: ${TEST_WORK_DIRECTORY}")
  endif()
endfunction()

function(run_identity_case identity_kind)
  set(case_directory "${TEST_WORK_DIRECTORY}/${identity_kind}")
  file(MAKE_DIRECTORY "${case_directory}")
  set(input "${case_directory}/input.cw")
  configure_file("${CASE_SOURCE}" "${input}" COPYONLY)
  file(READ "${input}" before)

  if(identity_kind STREQUAL "same_file")
    set(output "${input}")
  elseif(identity_kind STREQUAL "symbolic_link")
    set(output "${case_directory}/output.cw")
    file(CREATE_LINK "${input}" "${output}" SYMBOLIC RESULT link_result)
    if(NOT "${link_result}" STREQUAL "0")
      message(FATAL_ERROR "${CASE_NAME}: cannot create symbolic link: ${link_result}")
    endif()
  elseif(identity_kind STREQUAL "hard_link")
    set(output "${case_directory}/output.cw")
    file(CREATE_LINK "${input}" "${output}" RESULT link_result)
    if(NOT "${link_result}" STREQUAL "0")
      message(FATAL_ERROR "${CASE_NAME}: cannot create hard link: ${link_result}")
    endif()
  else()
    message(FATAL_ERROR "${CASE_NAME}: unknown identity case '${identity_kind}'")
  endif()

  execute_process(
    COMMAND "${CWC_EXECUTABLE}" "${input}" -o "${output}"
    WORKING_DIRECTORY "${case_directory}"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output_text
    ERROR_VARIABLE error_text
  )
  if("${result}" STREQUAL "0")
    message(FATAL_ERROR "${CASE_NAME}/${identity_kind}: output identity was accepted")
  endif()
  assert_contains("${error_text}" "refers to input" "${CASE_NAME}/${identity_kind} diagnostic")

  file(READ "${input}" after)
  if(NOT "${before}" STREQUAL "${after}")
    message(FATAL_ERROR
      "${CASE_NAME}/${identity_kind}: input content changed\n"
      "work directory: ${TEST_WORK_DIRECTORY}")
  endif()
endfunction()

if(CASE_MODE STREQUAL "program")
  if(NOT DEFINED CASE_SOURCE OR "${CASE_SOURCE}" STREQUAL "")
    message(FATAL_ERROR "${CASE_NAME}: program source is required")
  endif()
  if(NOT DEFINED EXPECTED_PROGRAM_STATUS OR "${EXPECTED_PROGRAM_STATUS}" STREQUAL "")
    message(FATAL_ERROR "${CASE_NAME}: expected program status is required")
  endif()

  execute_cwc(0 "${CASE_SOURCE}")
  set(program "${TEST_WORK_DIRECTORY}/a.out")
  assert_nonempty_file("${program}" "${CASE_NAME} executable")
  execute_program("${EXPECTED_PROGRAM_STATUS}" "${program}")

elseif(CASE_MODE STREQUAL "driver")
  if(NOT DEFINED DRIVER_SCENARIO OR "${DRIVER_SCENARIO}" STREQUAL "")
    message(FATAL_ERROR "${CASE_NAME}: driver scenario is required")
  endif()

  if(DRIVER_SCENARIO STREQUAL "help")
    execute_cwc(0 --help)
    assert_contains("${CWC_OUTPUT}" "Usage: cwc" "${CASE_NAME} help output")
    assert_contains("${CWC_OUTPUT}" "native linking also works without source inputs" "native input help")

  elseif(DRIVER_SCENARIO STREQUAL "invalid_arguments")
    execute_cwc(1 --not-a-cwc-option)
    assert_contains("${CWC_ERROR}" "error:" "${CASE_NAME} diagnostic")

  elseif(DRIVER_SCENARIO STREQUAL "missing_option_value")
    execute_cwc(1 -Xlinker)
    assert_contains("${CWC_ERROR}" "requires an argument" "${CASE_NAME} diagnostic")

  elseif(DRIVER_SCENARIO STREQUAL "removed_alias")
    execute_cwc(1 --c)
    assert_contains("${CWC_ERROR}" "unknown argument '--c'" "${CASE_NAME} diagnostic")

  elseif(DRIVER_SCENARIO STREQUAL "option_boundary")
    foreach(input IN ITEMS "-Wl,--no-entry" "-Xlinker")
      configure_file("${CASE_SOURCE}" "${TEST_WORK_DIRECTORY}/${input}" COPYONLY)
      set(output "${TEST_WORK_DIRECTORY}/${input}.ll")
      execute_cwc(0 -S -emit-llvm --target=wasm32-unknown-unknown -o "${output}" -- "${input}")
      assert_nonempty_file("${output}" "${CASE_NAME} LLVM IR")
    endforeach()

  elseif(DRIVER_SCENARIO STREQUAL "xlinker_boundary")
    execute_cwc(1 -S -emit-llvm "${CASE_SOURCE}" -Xlinker --)
    assert_contains("${CWC_ERROR}" "linker options require executable output" "${CASE_NAME} diagnostic")

  elseif(DRIVER_SCENARIO STREQUAL "output_leading_dash")
    set(output "-Wl,example")
    execute_cwc(0 -S -emit-llvm --target=wasm32-unknown-unknown "${CASE_SOURCE}" -o "${output}")
    assert_nonempty_file("${TEST_WORK_DIRECTORY}/${output}" "${CASE_NAME} LLVM IR")

  elseif(DRIVER_SCENARIO STREQUAL "explicit_output")
    set(output "${TEST_WORK_DIRECTORY}/explicit.out")
    execute_cwc(0 "${CASE_SOURCE}" -o "${output}")
    assert_nonempty_file("${output}" "${CASE_NAME} executable")

  elseif(DRIVER_SCENARIO STREQUAL "object_output")
    set(output "${TEST_WORK_DIRECTORY}/basic.o")
    execute_cwc(0 -c "${CASE_SOURCE}" -o "${output}")
    assert_nonempty_file("${output}" "${CASE_NAME} object")

  elseif(DRIVER_SCENARIO STREQUAL "llvm_ir_output")
    set(output "${TEST_WORK_DIRECTORY}/basic.ll")
    execute_cwc(0 -S -emit-llvm "${CASE_SOURCE}" -o "${output}")
    assert_nonempty_file("${output}" "${CASE_NAME} LLVM IR")

  elseif(DRIVER_SCENARIO MATCHES "^stable_")
    include("${CMAKE_CURRENT_LIST_DIR}/stable_symbols.cmake")

  elseif(DRIVER_SCENARIO MATCHES "^native_")
    include("${CMAKE_CURRENT_LIST_DIR}/native_link.cmake")

  elseif(DRIVER_SCENARIO STREQUAL "namespace_multi_source")
    set(object "${TEST_WORK_DIRECTORY}/combined.o")
    set(program "${TEST_WORK_DIRECTORY}/combined")
    execute_cwc(0 -c "${CASE_SOURCE}" "${CASE_SOURCE_2}" -o "${object}")
    execute_cwc(0 "${object}" -o "${program}")
    execute_program(42 "${program}")
    execute_cwc(0 "${CASE_SOURCE}" "${CASE_SOURCE_2}" -o "${program}")
    execute_program(42 "${program}")
    execute_cwc(0 --target=wasm32-unknown-unknown -S -emit-llvm "${CASE_SOURCE}" "${CASE_SOURCE_2}" -o combined.ll)
    file(READ "${TEST_WORK_DIRECTORY}/combined.ll" ir)
    assert_contains("${ir}" "Shared::Run" "qualified wasm function")
    assert_contains("${ir}" "@llvm.global_ctors" "namespace globals")

  elseif(DRIVER_SCENARIO STREQUAL "wasm_ir_output")
    set(output "${TEST_WORK_DIRECTORY}/basic.wasm.ll")
    execute_cwc(0 --target=wasm32-unknown-unknown -S -emit-llvm "${CASE_SOURCE}" -o "${output}")
    assert_nonempty_file("${output}" "${CASE_NAME} LLVM IR")
    file(READ "${output}" ir)
    assert_contains("${ir}" "target triple = \"wasm32-unknown-unknown\"" "${CASE_NAME} target triple")

  elseif(DRIVER_SCENARIO STREQUAL "wasm_object_output")
    set(output "${TEST_WORK_DIRECTORY}/basic.wasm.o")
    execute_cwc(0 --target=wasm32-unknown-unknown -c "${CASE_SOURCE}" -o "${output}")
    assert_nonempty_file("${output}" "${CASE_NAME} object")

  elseif(DRIVER_SCENARIO STREQUAL "wasm_aggregate_ir")
    set(output "${TEST_WORK_DIRECTORY}/aggregate.wasm.ll")
    execute_cwc(0 --target=wasm32-unknown-unknown -S -emit-llvm "${CASE_SOURCE}" -o "${output}")
    assert_nonempty_file("${output}" "${CASE_NAME} LLVM IR")
    file(READ "${output}" ir)
    assert_contains("${ir}" "define i8 @\"cw:Small:func(Byte)Byte\"(i8" "${CASE_NAME} singleton scalar ABI")
    assert_contains("${ir}" "define void @\"cw:Three:func(Odd)Odd\"(ptr sret(%struct.Odd)" "${CASE_NAME} aggregate return ABI")

  elseif(DRIVER_SCENARIO STREQUAL "wasm_global_ir")
    set(output "${TEST_WORK_DIRECTORY}/global.wasm.ll")
    execute_cwc(0 --target=wasm32-unknown-unknown -S -emit-llvm "${CASE_SOURCE}" -o "${output}")
    assert_nonempty_file("${output}" "${CASE_NAME} LLVM IR")
    file(READ "${output}" ir)
    assert_contains("${ir}" "@llvm.global_ctors = appending global" "${CASE_NAME} global constructor registration")
    assert_contains("${ir}" "define internal void @\"cw:global_init\"" "${CASE_NAME} global initialization")

  elseif(DRIVER_SCENARIO STREQUAL "wasm_virtual_slot_ir")
    set(output "${TEST_WORK_DIRECTORY}/virtual-pointers.wasm.ll")
    execute_cwc(0 --target=wasm32-unknown-unknown -S -emit-llvm "${CASE_SOURCE}" -o "${output}")
    assert_nonempty_file("${output}" "${CASE_NAME} LLVM IR")
    file(READ "${output}" ir)
    assert_contains("${ir}" "define void @\"cw:Identity:func(virtual *func(&copy Item)i32)virtual *func(&copy Item)i32\"(ptr sret({ i32, i32 })" "${CASE_NAME} virtual slot ABI")
    assert_contains("${ir}" "getelementptr i8, ptr %" "${CASE_NAME} target index ABI")

  elseif(DRIVER_SCENARIO STREQUAL "wasm_link")
    set(output "${TEST_WORK_DIRECTORY}/module.wasm")
    execute_cwc(0 --target=wasm32-unknown-unknown "${CASE_SOURCE}"
                   -Wl,--no-entry,--export=main -o "${output}")
    assert_wasm_module("${output}" "${CASE_NAME} module" "main")

  elseif(DRIVER_SCENARIO STREQUAL "wasm_multi_source_link")
    if(NOT DEFINED CASE_SOURCE_2 OR "${CASE_SOURCE_2}" STREQUAL "")
      message(FATAL_ERROR "${CASE_NAME}: second source is required")
    endif()
    set(output "${TEST_WORK_DIRECTORY}/module.wasm")
    execute_cwc(0 --target=wasm32-unknown-unknown "${CASE_SOURCE}" "${CASE_SOURCE_2}"
                   -Wl,--no-entry,--export=main -o "${output}")
    assert_wasm_module("${output}" "${CASE_NAME} module" "main")

  elseif(DRIVER_SCENARIO STREQUAL "wasm_global_link")
    set(output "${TEST_WORK_DIRECTORY}/global.wasm")
    execute_cwc(0 --target=wasm32-unknown-unknown "${CASE_SOURCE}"
                   -Wl,--no-entry,--export=__wasm_call_ctors -o "${output}")
    assert_wasm_module("${output}" "${CASE_NAME} module" "__wasm_call_ctors")

  elseif(DRIVER_SCENARIO STREQUAL "wasm_link_failure_preserves_output")
    set(output "${TEST_WORK_DIRECTORY}/existing.wasm")
    file(WRITE "${output}" "keep this module\n")
    file(READ "${output}" before)
    execute_cwc(1 --target=wasm32-unknown-unknown "${CASE_SOURCE}"
                   -Wl,--entry=missing_entry -o "${output}")
    message(STATUS "${CWC_ERROR}")
    file(READ "${output}" after)
    if(NOT "${before}" STREQUAL "${after}")
      message(FATAL_ERROR "${CASE_NAME}: existing output changed after linker failure")
    endif()

  elseif(DRIVER_SCENARIO STREQUAL "wasm_unsupported_link_option")
    execute_cwc(1 --target=wasm32-unknown-unknown "${CASE_SOURCE}" -Wl,--start-group -o module.wasm)
    assert_contains("${CWC_ERROR}" "unsupported Wasm linker option" "${CASE_NAME} diagnostic")

  elseif(DRIVER_SCENARIO STREQUAL "wasm_external_input")
    execute_cwc(1 --target=wasm32-unknown-unknown "${CASE_SOURCE}" "${TEST_WORK_DIRECTORY}/external.o"
                   -Wl,--no-entry -o module.wasm)
    assert_contains("${CWC_ERROR}" "accepts CW source files only" "${CASE_NAME} diagnostic")

  elseif(DRIVER_SCENARIO STREQUAL "unsupported_target")
    execute_cwc(1 --target=x86_64-unknown-linux-gnu -S -emit-llvm "${CASE_SOURCE}")
    assert_contains("${CWC_ERROR}" "unsupported target" "${CASE_NAME} diagnostic")

  elseif(DRIVER_SCENARIO STREQUAL "output_identity_protection")
    run_identity_case(same_file)
    run_identity_case(symbolic_link)
    run_identity_case(hard_link)

  elseif(DRIVER_SCENARIO STREQUAL "missing_link_input")
    set(input "${TEST_WORK_DIRECTORY}/input.cw")
    configure_file("${CASE_SOURCE}" "${input}" COPYONLY)
    set(output "${TEST_WORK_DIRECTORY}/existing.out")
    file(WRITE "${output}" "keep this output\n")
    file(READ "${output}" before)
    set(missing "${TEST_WORK_DIRECTORY}/missing.o")
    execute_cwc(1 "${input}" "${missing}" -o "${output}")
    assert_contains("${CWC_ERROR}" "cannot read link input" "${CASE_NAME} diagnostic")
    file(READ "${output}" after)
    if(NOT "${before}" STREQUAL "${after}")
      message(FATAL_ERROR
        "${CASE_NAME}: existing output content changed\n"
        "work directory: ${TEST_WORK_DIRECTORY}")
    endif()

  elseif(DRIVER_SCENARIO STREQUAL "interface_contents")
    get_filename_component(source_directory "${CASE_SOURCE}" DIRECTORY)
    get_filename_component(source_name "${CASE_SOURCE}" NAME_WE)
    file(READ "${source_directory}/${source_name}.cwi" first_expected)
    set(expected "${first_expected}")
    set(sources "${CASE_SOURCE}")
    if(NOT "${CASE_SOURCE_2}" STREQUAL "")
      get_filename_component(second_name "${CASE_SOURCE_2}" NAME_WE)
      file(READ "${source_directory}/${second_name}.cwi" second_expected)
      string(APPEND expected "${second_expected}")
      list(APPEND sources "${CASE_SOURCE_2}")
    endif()
    foreach(target IN ITEMS native wasm)
      set(target_args "")
      if(target STREQUAL "wasm")
        set(target_args --target=wasm32-unknown-unknown)
      endif()
      foreach(repetition RANGE 1 2)
        execute_cwc(0 ${target_args} -c ${sources} -o "${target}.o")
        assert_nonempty_file("${TEST_WORK_DIRECTORY}/${target}.o" "${CASE_NAME} object")
        assert_file_contents("${TEST_WORK_DIRECTORY}/${target}.cwi" "${expected}")
      endforeach()
      execute_cwc(0 ${target_args} -c "${target}.cwi" -o "${target}-read.o")
      assert_nonempty_file("${TEST_WORK_DIRECTORY}/${target}-read.o" "read-back object")
      assert_file_contents("${TEST_WORK_DIRECTORY}/${target}-read.cwi" "")
    endforeach()
    if(NOT "${CASE_SOURCE_2}" STREQUAL "")
      execute_cwc(0 -c "${CASE_SOURCE_2}" "${CASE_SOURCE}" -o reversed.o)
      assert_file_contents("${TEST_WORK_DIRECTORY}/reversed.cwi" "${second_expected}${first_expected}")
    endif()

  elseif(DRIVER_SCENARIO STREQUAL "import_roundtrip")
    foreach(target IN ITEMS native wasm)
      set(target_args "")
      if(target STREQUAL "wasm")
        set(target_args --target=wasm32-unknown-unknown)
      endif()
      execute_cwc(0 ${target_args} -c "${CASE_SOURCE}" -o "${target}-provider.o")
      execute_cwc(0 ${target_args} -c "${target}-provider.cwi" "${CASE_SOURCE_2}" -o "${target}-consumer.o")
      assert_nonempty_file("${TEST_WORK_DIRECTORY}/${target}-consumer.o" "consumer object")
      assert_file_contents("${TEST_WORK_DIRECTORY}/${target}-consumer.cwi" "import func Consume() i32;\n")
      execute_cwc(0 ${target_args} -c "${CASE_SOURCE_2}" "${target}-provider.cwi" -o "${target}-reversed.o")
      assert_file_contents("${TEST_WORK_DIRECTORY}/${target}-reversed.cwi" "import func Consume() i32;\n")
      execute_cwc(0 ${target_args} -S -emit-llvm "${CASE_SOURCE_2}" "${target}-provider.cwi" -o -)
      assert_contains("${CWC_OUTPUT}" "declare noundef ptr @\"cw:Handle:ctor(i32):complete\"" "imported constructor")
      assert_contains("${CWC_OUTPUT}" "declare noundef ptr @\"cw:Handle:dtor():complete\"" "imported destructor")
      assert_contains("${CWC_OUTPUT}" "call void @\"cw:Flush:func()void\"()" "imported void call")
    endforeach()

  elseif(DRIVER_SCENARIO STREQUAL "import_object_output")
    execute_cwc(0 -c "${CASE_SOURCE}" -o imports.o)
    assert_nonempty_file("${TEST_WORK_DIRECTORY}/imports.o" "native virtual imports")
    execute_cwc(0 --target=wasm32-unknown-unknown -c "${CASE_SOURCE}" -o imports-wasm.o)
    assert_nonempty_file("${TEST_WORK_DIRECTORY}/imports-wasm.o" "Wasm virtual imports")
    execute_cwc(0 --target=wasm32-unknown-unknown -c "${CASE_SOURCE_2}" -o covariance-wasm.o)
    assert_nonempty_file("${TEST_WORK_DIRECTORY}/covariance-wasm.o" "Wasm imported covariance")

  elseif(DRIVER_SCENARIO STREQUAL "import_symbols")
    if(DEFINED SYMBOL_INSPECTOR AND NOT "${SYMBOL_INSPECTOR}" STREQUAL "" AND EXISTS "${SYMBOL_INSPECTOR}")
      execute_cwc(0 -c "${CASE_SOURCE}" -o imports.o)
      execute_process(COMMAND "${SYMBOL_INSPECTOR}" imports.o
        WORKING_DIRECTORY "${TEST_WORK_DIRECTORY}"
        RESULT_VARIABLE result OUTPUT_VARIABLE symbols ERROR_VARIABLE error)
      if(NOT "${result}" STREQUAL "0")
        message(FATAL_ERROR "${SYMBOL_INSPECTOR} returned '${result}' while inspecting import object symbols:\n${error}")
      endif()
      assert_contains("${symbols}" " U _cw:api::Base:vtable" "imported base table reference")
      assert_contains("${symbols}" " U _cw:api::Hidden:func(&copy api::Base)i32" "implicit virtual implementation reference")
      assert_contains("${symbols}" " U _cw:api::Keep:func(&copy api::Base)i32" "shared ordinary and virtual implementation")
      assert_contains("${symbols}" " S _cw:Derived:vtable" "exported derived table definition")
    else()
      message(STATUS "cannot locate llvm-nm; skipping import symbol inspection")
    endif()

  elseif(DRIVER_SCENARIO STREQUAL "import_link_modes")
    file(WRITE "${TEST_WORK_DIRECTORY}/allowed.cw" [=[
import struct Base { virtual { func Read(this &copy Base) i32; } }
import dtor Base();
import func Unused();
func Dispatch(value &copy Base) i32 { value.Read() }
func main() i32 { 7 }
]=])
    execute_cwc(0 allowed.cw -o allowed)
    execute_program(7 "${TEST_WORK_DIRECTORY}/allowed")
    file(WRITE "${TEST_WORK_DIRECTORY}/direct.cw"
      "import func External() i32; func main() i32 { External() }")
    file(WRITE "${TEST_WORK_DIRECTORY}/address.cw"
      "import func External() i32; func Address() *func() i32 { &External } func main() i32 { 0 }")
    file(WRITE "${TEST_WORK_DIRECTORY}/cleanup.cw"
      "import struct Box {} import dtor Box(); func Cleanup(factory *func() Box) { var value := factory(); } func main() i32 { 0 }")
    file(WRITE "${TEST_WORK_DIRECTORY}/virtual.cw" [=[
import struct Base { virtual { func Read(this &copy Base) i32; } }
import ctor Base();
import dtor Base();
struct Derived : Base {}
ctor Derived() { this.Base := Base(); }
dtor Derived() {}
func main() i32 { 0 }
]=])
    foreach(source IN ITEMS direct address cleanup virtual)
      execute_cwc(0 -c "${source}.cw" -o "${source}.o")
      execute_cwc(0 -S -emit-llvm "${source}.cw" -o "${source}.ll")
      file(WRITE "${TEST_WORK_DIRECTORY}/protected" "old executable")
      execute_cwc(1 "${source}.cw" -o protected)
      assert_contains("${CWC_ERROR}" "linker command failed" "unresolved import link diagnostic")
      assert_contains("${CWC_ERROR}" "cw:" "unresolved stable symbol")
      assert_file_contents("${TEST_WORK_DIRECTORY}/protected" "old executable")
    endforeach()

  elseif(DRIVER_SCENARIO STREQUAL "import_input_rules")
    file(WRITE "${TEST_WORK_DIRECTORY}/api.cwi" "import func External() i32;\n")
    file(WRITE "${TEST_WORK_DIRECTORY}/consumer.cw" "func Use() i32 { External() }\n")
    execute_cwc(0 -c api.cwi consumer.cw -o consumer.o)
    assert_file_contents("${TEST_WORK_DIRECTORY}/consumer.cwi" "")
    execute_cwc(1 -c api.cwi)
    assert_contains("${CWC_ERROR}" "refers to input" "interface input protection")
    assert_file_contents("${TEST_WORK_DIRECTORY}/api.cwi" "import func External() i32;\n")
    execute_cwc(1 -c api.cwi api.cwi -o duplicate.o)
    assert_contains("${CWC_ERROR}" "redefinition of function 'External'" "duplicate input declaration")
    file(CREATE_LINK "${TEST_WORK_DIRECTORY}/api.cwi" "${TEST_WORK_DIRECTORY}/alias.cwi" SYMBOLIC)
    execute_cwc(1 -c api.cwi alias.cwi -o alias.o)
    assert_contains("${CWC_ERROR}" "redefinition of function 'External'" "aliased input declaration")
    execute_process(COMMAND "${CWC_EXECUTABLE}" -c - consumer.cw -o stdin.o
      WORKING_DIRECTORY "${TEST_WORK_DIRECTORY}" INPUT_FILE "${TEST_WORK_DIRECTORY}/api.cwi"
      RESULT_VARIABLE result ERROR_VARIABLE error)
    if(NOT "${result}" STREQUAL "0")
      message(FATAL_ERROR "interface from stdin failed: ${error}")
    endif()
    assert_nonempty_file("${TEST_WORK_DIRECTORY}/stdin.o" "stdin consumer object")
    file(WRITE "${TEST_WORK_DIRECTORY}/mixed.cwi"
      "import func External() i32; export func Local() i32 { External() }")
    execute_cwc(0 -c mixed.cwi -o mixed-output.o)
    assert_file_contents("${TEST_WORK_DIRECTORY}/mixed-output.cwi" "import func Local() i32;\n")

  elseif(DRIVER_SCENARIO STREQUAL "import_wasm_link")
    file(WRITE "${TEST_WORK_DIRECTORY}/import.cw" "import func External() i32; func Entry() i32 { External() }")
    execute_cwc(1 --target=wasm32-unknown-unknown import.cw -o import.wasm -Xlinker --no-entry -Xlinker "--export=cw:Entry:func()i32")
    if("${CWC_ERROR}" MATCHES "cannot locate wasm-ld")
      message("${CWC_ERROR}")
    else()
      assert_contains("${CWC_ERROR}" "undefined symbol: cw:External:func()i32" "Wasm unresolved import")
      assert_absent("${TEST_WORK_DIRECTORY}/import.wasm")
    endif()

  elseif(DRIVER_SCENARIO STREQUAL "interface_naming")
    execute_cwc(0 -c "${CASE_SOURCE}")
    assert_nonempty_file("${TEST_WORK_DIRECTORY}/basic.o" "default object")
    assert_file_contents("${TEST_WORK_DIRECTORY}/basic.cwi" "")
    file(MAKE_DIRECTORY "${TEST_WORK_DIRECTORY}/out")
    execute_cwc(0 -c "${CASE_SOURCE}" -o out/module.custom)
    assert_nonempty_file("${TEST_WORK_DIRECTORY}/out/module.custom" "explicit object")
    assert_file_contents("${TEST_WORK_DIRECTORY}/out/module.cwi" "")
    # Existing output symlinks continue to address their targets, including new targets.
    file(CREATE_LINK "${TEST_WORK_DIRECTORY}/actual-object" "${TEST_WORK_DIRECTORY}/alias.o" SYMBOLIC)
    file(CREATE_LINK "${TEST_WORK_DIRECTORY}/actual-interface" "${TEST_WORK_DIRECTORY}/alias.cwi" SYMBOLIC)
    execute_cwc(0 -c "${CASE_SOURCE}" -o alias.o)
    assert_nonempty_file("${TEST_WORK_DIRECTORY}/actual-object" "symlink object")
    assert_file_contents("${TEST_WORK_DIRECTORY}/actual-interface" "")
    if(NOT IS_SYMLINK "${TEST_WORK_DIRECTORY}/alias.o" OR NOT IS_SYMLINK "${TEST_WORK_DIRECTORY}/alias.cwi")
      message(FATAL_ERROR "output symlinks were replaced")
    endif()
    foreach(stdin_name IN ITEMS explicit default)
      set(output_args -o stdin.o)
      set(output_name stdin)
      if(stdin_name STREQUAL "default")
        set(output_args "")
        set(output_name "-")
      endif()
      execute_process(
        COMMAND "${CWC_EXECUTABLE}" -c - ${output_args}
        INPUT_FILE "${CASE_SOURCE}"
        WORKING_DIRECTORY "${TEST_WORK_DIRECTORY}"
        RESULT_VARIABLE result ERROR_VARIABLE error)
      if(NOT "${result}" STREQUAL "0")
        message(FATAL_ERROR "standard input compilation failed: ${error}")
      endif()
      assert_nonempty_file("${TEST_WORK_DIRECTORY}/${output_name}.o" "stdin object")
      assert_file_contents("${TEST_WORK_DIRECTORY}/${output_name}.cwi" "")
    endforeach()
    file(WRITE "${TEST_WORK_DIRECTORY}/empty.cw" "")
    execute_cwc(1 -c "${CASE_SOURCE}" empty.cw)
    assert_contains("${CWC_ERROR}" "multiple inputs require an explicit -o" "multi-input diagnostic")

  elseif(DRIVER_SCENARIO STREQUAL "interface_empty")
    foreach(source IN ITEMS "" "namespace Hidden { namespace Nested { func Private() {} } }")
      file(WRITE "${TEST_WORK_DIRECTORY}/empty.cw" "${source}")
      file(WRITE "${TEST_WORK_DIRECTORY}/empty.cwi" "stale declarations\n")
      execute_cwc(0 -c empty.cw)
      assert_nonempty_file("${TEST_WORK_DIRECTORY}/empty.o" "empty unit object")
      assert_file_contents("${TEST_WORK_DIRECTORY}/empty.cwi" "")
    endforeach()

  elseif(DRIVER_SCENARIO STREQUAL "interface_stdout")
    execute_cwc(1 -c "${CASE_SOURCE}" -o -)
    assert_contains("${CWC_ERROR}" "-c -o - is not supported" "object stdout diagnostic")
    if(NOT "${CWC_OUTPUT}" STREQUAL "")
      message(FATAL_ERROR "rejected object stdout was not empty")
    endif()
    execute_cwc(0 -S -emit-llvm "${CASE_SOURCE}" -o -)
    assert_contains("${CWC_OUTPUT}" "@main()" "LLVM IR stdout")
    assert_absent("${TEST_WORK_DIRECTORY}/-.cwi")

  elseif(DRIVER_SCENARIO STREQUAL "interface_modes")
    file(WRITE "${TEST_WORK_DIRECTORY}/entry.cw" "export func main() i32 { 3 }\n")
    execute_cwc(0 -S -emit-llvm entry.cw -o only.ll)
    assert_absent("${TEST_WORK_DIRECTORY}/only.cwi")
    execute_cwc(0 entry.cw -o only)
    assert_absent("${TEST_WORK_DIRECTORY}/only.cwi")
    execute_program(3 "${TEST_WORK_DIRECTORY}/only")
    file(WRITE "${TEST_WORK_DIRECTORY}/only.cwi" "keep interface\n")
    execute_cwc(0 -S -emit-llvm entry.cw -o only.ll)
    execute_cwc(0 entry.cw -o only)
    assert_file_contents("${TEST_WORK_DIRECTORY}/only.cwi" "keep interface\n")

  elseif(DRIVER_SCENARIO STREQUAL "interface_input_protection")
    file(READ "${CASE_SOURCE}" source)
    foreach(artifact IN ITEMS object interface)
      foreach(alias IN ITEMS direct symbolic hard)
        set(directory "${TEST_WORK_DIRECTORY}/${artifact}_${alias}")
        file(MAKE_DIRECTORY "${directory}")
        set(input "${directory}/input.cwi")
        set(object "${directory}/module.o")
        set(interface "${directory}/module.cwi")
        file(WRITE "${input}" "${source}")
        if(alias STREQUAL "direct")
          if(artifact STREQUAL "object")
            set(input "${directory}/input.cw")
            file(WRITE "${input}" "${source}")
            set(object "${input}")
          else()
            set(object "${directory}/input.o")
          endif()
        else()
          if(artifact STREQUAL "object")
            set(destination "${object}")
          else()
            set(destination "${interface}")
          endif()
          set(link_kind "")
          if(alias STREQUAL "symbolic")
            set(link_kind SYMBOLIC)
          endif()
          file(CREATE_LINK "${input}" "${destination}" ${link_kind})
        endif()
        execute_cwc(1 -c "${input}" -o "${object}")
        assert_contains("${CWC_ERROR}" "refers to input" "input protection diagnostic")
        assert_file_contents("${input}" "${source}")
        if(artifact STREQUAL "interface")
          assert_absent("${object}")
        endif()
      endforeach()
    endforeach()

    file(WRITE "${TEST_WORK_DIRECTORY}/stdin.cwi" "${source}")
    execute_process(
      COMMAND "${CWC_EXECUTABLE}" -c - -o stdin.o
      INPUT_FILE "${TEST_WORK_DIRECTORY}/stdin.cwi"
      WORKING_DIRECTORY "${TEST_WORK_DIRECTORY}"
      RESULT_VARIABLE result ERROR_VARIABLE error)
    if(NOT "${result}" STREQUAL "1")
      message(FATAL_ERROR "standard input was accepted as interface output: ${error}")
    endif()
    assert_contains("${error}" "refers to input '-'" "stdin protection diagnostic")
    assert_file_contents("${TEST_WORK_DIRECTORY}/stdin.cwi" "${source}")
    assert_absent("${TEST_WORK_DIRECTORY}/stdin.o")

  elseif(DRIVER_SCENARIO STREQUAL "interface_output_conflict")
    execute_cwc(1 -c "${CASE_SOURCE}" -o same.cwi)
    assert_contains("${CWC_ERROR}" "same path" "output path conflict")
    assert_absent("${TEST_WORK_DIRECTORY}/same.cwi")
    file(WRITE "${TEST_WORK_DIRECTORY}/same.cwi" "old output\n")
    execute_cwc(1 -c "${CASE_SOURCE}" -o same.cwi)
    assert_file_contents("${TEST_WORK_DIRECTORY}/same.cwi" "old output\n")
    foreach(alias IN ITEMS symbolic hard)
      set(object "${TEST_WORK_DIRECTORY}/${alias}.o")
      set(interface "${TEST_WORK_DIRECTORY}/${alias}.cwi")
      file(WRITE "${object}" "old output\n")
      set(link_kind "")
      if(alias STREQUAL "symbolic")
        set(link_kind SYMBOLIC)
      endif()
      file(CREATE_LINK "${object}" "${interface}" ${link_kind})
      execute_cwc(1 -c "${CASE_SOURCE}" -o "${object}")
      assert_contains("${CWC_ERROR}" "refer to the same file" "output identity conflict")
      assert_file_contents("${object}" "old output\n")
      assert_file_contents("${interface}" "old output\n")
    endforeach()

  elseif(DRIVER_SCENARIO STREQUAL "interface_frontend_failure")
    foreach(source IN ITEMS "export func Broken( {" "export func Broken() i32 { missing }")
      file(WRITE "${TEST_WORK_DIRECTORY}/broken.cw" "${source}")
      file(WRITE "${TEST_WORK_DIRECTORY}/broken.o" "old object\n")
      file(WRITE "${TEST_WORK_DIRECTORY}/broken.cwi" "old interface\n")
      execute_cwc(1 -c broken.cw)
      assert_file_contents("${TEST_WORK_DIRECTORY}/broken.o" "old object\n")
      assert_file_contents("${TEST_WORK_DIRECTORY}/broken.cwi" "old interface\n")
    endforeach()

  elseif(DRIVER_SCENARIO STREQUAL "interface_open_failure")
    file(MAKE_DIRECTORY "${TEST_WORK_DIRECTORY}/blocked.cwi")
    file(WRITE "${TEST_WORK_DIRECTORY}/blocked.cwi/keep" "keep directory\n")
    execute_cwc(1 -c "${CASE_SOURCE}" -o blocked.o)
    assert_contains("${CWC_ERROR}" "cannot open output 'blocked.cwi'" "interface open diagnostic")
    assert_absent("${TEST_WORK_DIRECTORY}/blocked.o")
    file(WRITE "${TEST_WORK_DIRECTORY}/blocked.o" "old object\n")
    execute_cwc(1 -c "${CASE_SOURCE}" -o blocked.o)
    assert_file_contents("${TEST_WORK_DIRECTORY}/blocked.o" "old object\n")
    assert_file_contents("${TEST_WORK_DIRECTORY}/blocked.cwi/keep" "keep directory\n")
    file(MAKE_DIRECTORY "${TEST_WORK_DIRECTORY}/blocked-object.o")
    file(WRITE "${TEST_WORK_DIRECTORY}/blocked-object.cwi" "old interface\n")
    execute_cwc(1 -c "${CASE_SOURCE}" -o blocked-object.o)
    assert_file_contents("${TEST_WORK_DIRECTORY}/blocked-object.cwi" "old interface\n")
    execute_cwc(1 -c "${CASE_SOURCE}" -o missing/module.o)
    assert_absent("${TEST_WORK_DIRECTORY}/missing")

  elseif(DRIVER_SCENARIO STREQUAL "interface_prepare_failure")
    configure_file("${CASE_SOURCE}" "${TEST_WORK_DIRECTORY}/input.cw" COPYONLY)
    file(READ "${TEST_WORK_DIRECTORY}/input.cw" source)
    # Resolving an opened output's real path on macOS needs another descriptor.
    # Limits of 4 and 5 fail preparation of the object and interface, respectively.
    foreach(limit IN ITEMS 4 5)
      set(failing_path module.o)
      if(limit EQUAL 5)
        set(failing_path module.cwi)
      endif()
      foreach(layout IN ITEMS new existing new_symlink existing_symlink)
        set(directory "${TEST_WORK_DIRECTORY}/${limit}_${layout}")
        file(MAKE_DIRECTORY "${directory}")
        set(object "${directory}/module.o")
        set(interface "${directory}/module.cwi")
        if(layout MATCHES "symlink$")
          set(object "${directory}/actual-object")
          set(interface "${directory}/actual-interface")
          file(CREATE_LINK "${object}" "${directory}/module.o" SYMBOLIC)
          file(CREATE_LINK "${interface}" "${directory}/module.cwi" SYMBOLIC)
        endif()
        if(layout MATCHES "^existing")
          file(WRITE "${object}" "old object\n")
          file(WRITE "${interface}" "old interface\n")
        endif()
        execute_process(
          COMMAND /bin/sh -c [=[ulimit -n "$1" || exit 99; shift; exec "$@"]=]
                  cwc-descriptor-limit "${limit}" "${CWC_EXECUTABLE}" --target=wasm32-unknown-unknown
                  -c "${TEST_WORK_DIRECTORY}/input.cw" -o module.o
          WORKING_DIRECTORY "${directory}"
          RESULT_VARIABLE result
          OUTPUT_VARIABLE output
          ERROR_VARIABLE error
        )
        if(NOT "${result}" STREQUAL "1")
          message(FATAL_ERROR "${CASE_NAME}/${limit}/${layout}: preparation returned '${result}': ${error}")
        endif()
        assert_contains("${error}" "cannot prepare output '${failing_path}'" "preparation failure diagnostic")
        assert_contains("${error}" "Too many open files" "descriptor exhaustion diagnostic")
        if(layout MATCHES "^existing")
          assert_file_contents("${object}" "old object\n")
          assert_file_contents("${interface}" "old interface\n")
        else()
          assert_absent("${object}")
          assert_absent("${interface}")
        endif()
        if(layout MATCHES "symlink$")
          if(NOT IS_SYMLINK "${directory}/module.o" OR NOT IS_SYMLINK "${directory}/module.cwi")
            message(FATAL_ERROR "${CASE_NAME}/${limit}/${layout}: preparation failure removed an output symlink")
          endif()
        endif()
      endforeach()
    endforeach()
    assert_file_contents("${TEST_WORK_DIRECTORY}/input.cw" "${source}")

  elseif(DRIVER_SCENARIO STREQUAL "interface_write_failure")
    # A large type-only interface has a small object. RLIMIT_FSIZE can therefore fail
    # the interface write after object generation, without internal compiler hooks.
    set(source "export trivial struct Large {\n")
    foreach(index RANGE 1 600)
      string(APPEND source "  field_with_a_long_name_for_output_failure_${index} i32;\n")
    endforeach()
    string(APPEND source "}\n")
    file(WRITE "${TEST_WORK_DIRECTORY}/large.cw" "${source}")
    execute_cwc(0 -c large.cw -o size.o)
    file(SIZE "${TEST_WORK_DIRECTORY}/size.o" object_size)
    file(SIZE "${TEST_WORK_DIRECTORY}/size.cwi" interface_size)
    if(object_size GREATER_EQUAL 4096 OR interface_size LESS_EQUAL 8192)
      message(FATAL_ERROR "file size limit fixture no longer separates the two outputs")
    endif()
    foreach(failing_artifact IN ITEMS object interface object_symlink interface_symlink)
      set(limit 0)
      set(failing_path limited.o)
      if(failing_artifact MATCHES "^interface")
        set(limit 8)
        set(failing_path limited.cwi)
      endif()
      file(WRITE "${TEST_WORK_DIRECTORY}/limited.o" "old object\n")
      file(WRITE "${TEST_WORK_DIRECTORY}/limited.cwi" "old interface\n")
      if(failing_artifact MATCHES "symlink$")
        file(REMOVE "${TEST_WORK_DIRECTORY}/${failing_path}")
        file(WRITE "${TEST_WORK_DIRECTORY}/linked-output" "old linked output\n")
        file(CREATE_LINK "${TEST_WORK_DIRECTORY}/linked-output" "${TEST_WORK_DIRECTORY}/${failing_path}" SYMBOLIC)
      endif()
      execute_process(
        COMMAND /bin/sh -c [=[trap '' XFSZ; ulimit -f "$1" || exit 99; shift; exec "$@"]=]
                cwc-size-limit "${limit}" "${CWC_EXECUTABLE}" -c large.cw -o limited.o
        WORKING_DIRECTORY "${TEST_WORK_DIRECTORY}"
        RESULT_VARIABLE result OUTPUT_VARIABLE output ERROR_VARIABLE error)
      if(NOT "${result}" STREQUAL "1")
        message(FATAL_ERROR "limited ${failing_artifact} write returned '${result}': ${error}")
      endif()
      assert_contains("${error}" "cannot write output '${failing_path}'" "write failure diagnostic")
      if(failing_artifact MATCHES "symlink$")
        assert_absent("${TEST_WORK_DIRECTORY}/linked-output")
        if(NOT IS_SYMLINK "${TEST_WORK_DIRECTORY}/${failing_path}")
          message(FATAL_ERROR "failed output cleanup replaced its symlink")
        endif()
        file(REMOVE "${TEST_WORK_DIRECTORY}/${failing_path}")
      endif()
      assert_absent("${TEST_WORK_DIRECTORY}/limited.o")
      assert_absent("${TEST_WORK_DIRECTORY}/limited.cwi")
      assert_file_contents("${TEST_WORK_DIRECTORY}/large.cw" "${source}")
    endforeach()

    # Existing writable files can be opened in a read-only directory, but cleanup
    # cannot unlink them. Restore permissions before checking results or reporting.
    set(cleanup_directory "${TEST_WORK_DIRECTORY}/cleanup-blocked")
    file(MAKE_DIRECTORY "${cleanup_directory}")
    file(WRITE "${cleanup_directory}/module.o" "old object\n")
    file(WRITE "${cleanup_directory}/module.cwi" "old interface\n")
    file(CHMOD "${cleanup_directory}" PERMISSIONS OWNER_READ OWNER_EXECUTE)
    execute_process(
      COMMAND /bin/sh -c [=[trap '' XFSZ; ulimit -f 0 || exit 99; exec "$@"]=]
              cwc-size-limit "${CWC_EXECUTABLE}" -c large.cw -o cleanup-blocked/module.o
      WORKING_DIRECTORY "${TEST_WORK_DIRECTORY}"
      RESULT_VARIABLE result ERROR_VARIABLE error)
    file(CHMOD "${cleanup_directory}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
    if(NOT "${result}" STREQUAL "1")
      message(FATAL_ERROR "cleanup failure returned '${result}': ${error}")
    endif()
    assert_contains("${error}" "cannot write output 'cleanup-blocked/module.o'" "write failure diagnostic")
    foreach(extension IN ITEMS o cwi)
      assert_contains("${error}" "cannot remove incomplete output '${cleanup_directory}/module.${extension}'"
                      "cleanup failure diagnostic")
      assert_file_contents("${cleanup_directory}/module.${extension}" "")
    endforeach()
    assert_file_contents("${TEST_WORK_DIRECTORY}/large.cw" "${source}")

  else()
    message(FATAL_ERROR "${CASE_NAME}: unknown driver scenario '${DRIVER_SCENARIO}'")
  endif()

else()
  message(FATAL_ERROR "${CASE_NAME}: unknown test mode '${CASE_MODE}'")
endif()

file(REMOVE_RECURSE "${TEST_WORK_DIRECTORY}")
