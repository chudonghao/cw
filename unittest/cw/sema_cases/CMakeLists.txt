find_program(SEMA_CASE_CLANG_EXECUTABLE NAMES clang)
find_package(Python3 QUIET COMPONENTS Interpreter)

if(NOT SEMA_CASE_CLANG_EXECUTABLE OR NOT Python3_Interpreter_FOUND)
  message(STATUS "Clang AST reference targets disabled: Clang and Python 3 are required")
  return()
endif()

add_custom_target(sema_case_clang_ast_all)

function(add_sema_case_clang_ast name)
  set(source_file "${CMAKE_CURRENT_SOURCE_DIR}/${name}.cpp")
  set(raw_ast_file "${source_file}.ast")
  set(normalized_ast_file "${raw_ast_file}.txt")
  set(target_name "sema_case_clang_ast_${name}")

  add_custom_target(${target_name}
    COMMAND
      "${CMAKE_COMMAND}"
      "-DCLANG_EXECUTABLE=${SEMA_CASE_CLANG_EXECUTABLE}"
      "-DPYTHON_EXECUTABLE=${Python3_EXECUTABLE}"
      "-DNORMALIZER=${CMAKE_CURRENT_SOURCE_DIR}/normalize_ast.py"
      "-DCASE_DIRECTORY=${CMAKE_CURRENT_SOURCE_DIR}"
      "-DSOURCE_FILE=${source_file}"
      "-DRAW_AST_FILE=${raw_ast_file}"
      "-DNORMALIZED_AST_FILE=${normalized_ast_file}"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/generate_clang_ast.cmake"
    COMMENT "Generate normalized Clang AST for ${name}"
    VERBATIM
  )

  add_dependencies(sema_case_clang_ast_all ${target_name})
endfunction()

add_sema_case_clang_ast(variable_declaration)
add_sema_case_clang_ast(local_integer_initialization)
add_sema_case_clang_ast(numeric_arithmetic)
add_sema_case_clang_ast(builtin_comparison)
add_sema_case_clang_ast(boolean_logic)
add_sema_case_clang_ast(boolean_control_flow)
add_sema_case_clang_ast(conditional_expression)
add_sema_case_clang_ast(reference_binding)
add_sema_case_clang_ast(struct_fields)
add_sema_case_clang_ast(member_access)
add_sema_case_clang_ast(receiver_call)
add_sema_case_clang_ast(function_definition)
add_sema_case_clang_ast(function_type)
add_sema_case_clang_ast(function_pointer_call)
add_sema_case_clang_ast(function_address)
add_sema_case_clang_ast(object_address)
add_sema_case_clang_ast(lexical_scope)
add_sema_case_clang_ast(single_inheritance)
add_sema_case_clang_ast(derived_to_base_reference_binding)
add_sema_case_clang_ast(object_pointer_conversion)
add_sema_case_clang_ast(function_overloading)
add_sema_case_clang_ast(named_type_parameter)
add_sema_case_clang_ast(construction)
add_sema_case_clang_ast(copy_move_construction)
add_sema_case_clang_ast(explicit_destruction)
add_sema_case_clang_ast(constructor_this)
add_sema_case_clang_ast(operator_expression)
add_sema_case_clang_ast(operator_function_address)
add_sema_case_clang_ast(operator_function_call)
add_sema_case_clang_ast(virtual_functions)
add_sema_case_clang_ast(covariant_return)
add_sema_case_clang_ast(virtual_interface_pointer)
add_sema_case_clang_ast(nonvirtual_call)
add_sema_case_clang_ast(callable_object)
add_sema_case_clang_ast(fixed_array)
