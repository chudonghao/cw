# Language Feature Cases

This directory contains positive, source-driven language feature cases for comparing C++ and CW syntax and ASTs. Cases describe public language behavior; compiler phases and implementation details are not case categories.

## Files

Each case uses one snake_case stem and four tracked files:

- `<name>.cpp`: C++ source expressing the language intent.
- `<name>.cpp.ast.txt`: normalized Clang AST reference.
- `<name>.cw`: equivalent CW source.
- `<name>.cw.ast.txt`: normative CW AST expected after Parser and Sema.

`<name>.cpp.ast` is an ignored intermediate file containing the raw Clang dump.

C++ and CW ASTs preserve their real node structures. They are reviewed for equivalent language intent, not textual or structural equality.

## Normative Boundary

The CW source and expected AST are authored and reviewed before the implementation they specify. Never generate, copy, or update `<name>.cw.ast.txt` from the current CW compiler output. Change it only when the language design changes.

Clang references are generated artifacts for human comparison. They are not cross-version test goldens. The normalizer replaces unstable addresses and source paths while preserving declaration-reference identity.

Only accepted, valid language features belong here. Diagnostics, recovery, and other negative behavior remain inline in `sema_test.cpp`.

## Naming

File stems and CMake targets use snake_case. Primary C++ and CW declarations and GTest parameter names use PascalCase. Each case has one primary language feature and only the supporting declarations needed to express it.

The cases, in registration order, are:

1. `variable_declaration`
2. `local_integer_initialization`
3. `numeric_arithmetic`
4. `builtin_comparison`
5. `boolean_logic`
6. `boolean_control_flow`
7. `conditional_expression`
8. `reference_binding`
9. `struct_fields`
10. `member_access`
11. `receiver_call`
12. `function_definition`
13. `function_type`
14. `function_pointer_call`
15. `function_address`
16. `object_address`
17. `lexical_scope`
18. `single_inheritance`
19. `derived_to_base_reference_binding`
20. `object_pointer_conversion`
21. `function_overloading`
22. `named_type_parameter`
23. `construction`
24. `copy_move_construction`
25. `explicit_destruction`
26. `constructor_this`
27. `operator_expression`
28. `operator_function_address`
29. `operator_function_call`
30. `virtual_functions`
31. `covariant_return`
32. `virtual_interface_pointer`
33. `nonvirtual_call`
34. `callable_object`
35. `fixed_array`

## Generating Clang References

Configure the project with tests enabled, then generate one reference:

```text
cmake --build build/default --target sema_case_clang_ast_variable_declaration
```

Or generate all references:

```text
cmake --build build/default --target sema_case_clang_ast_all
```

These non-default targets require Clang and Python 3 and are not run by normal builds or CI. CMake invokes Clang to dump the complete translation unit, writes the raw `.ast`, and runs `normalize_ast.py` to update `.ast.txt`. The script only normalizes an existing AST file and never reads CW files.

The normalizer removes top-level implicit built-in declarations while preserving source declarations and their nested implicit nodes. It replaces an address that occurs once with `{{address}}`. Repeated addresses receive numbered `{{address:N}}` placeholders in first-use order, and every later reference reuses the same placeholder. It replaces the absolute case source path with a stable relative path. Normalization writes atomically, so a failure does not overwrite an existing reference.

## Adding a Case

1. Choose one accepted language feature and a snake_case stem.
2. Author the C++ source and generate its normalized Clang reference.
3. Independently author the equivalent CW source and normative CW AST.
4. Add a case-specific Clang AST target to `CMakeLists.txt`.
5. Register the stem and PascalCase test name in `sema_test.cpp`.
6. Review all four tracked files together.
