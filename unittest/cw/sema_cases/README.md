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

`explicit_numeric_conversion` compares zero initialization, explicit numeric conversions, same-type reads,
and nested size-integer conversions. CW's `FunctionalCastExpr` owns the numeric conversion directly;
Clang may represent it with an additional implicit conversion child.

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
4. `explicit_numeric_conversion`
5. `builtin_comparison`
6. `boolean_logic`
7. `boolean_control_flow`
8. `conditional_expression`
9. `reference_binding`
10. `struct_fields`
11. `member_access`
12. `receiver_call`
13. `function_definition`
14. `function_type`
15. `function_pointer_call`
16. `function_address`
17. `object_address`
18. `lexical_scope`
19. `single_inheritance`
20. `derived_to_base_reference_binding`
21. `object_pointer_conversion`
22. `function_overloading`
23. `named_type_parameter`
24. `construction`
25. `copy_move_construction`
26. `explicit_destruction`
27. `constructor_this`
28. `base_result_initialization`
29. `operator_expression`
30. `operator_function_address`
31. `operator_function_call`
32. `virtual_functions`
33. `covariant_return`
34. `virtual_interface_pointer`
35. `nonvirtual_call`
36. `callable_object`
37. `fixed_array`

## Generating Clang References

Configure the project with tests enabled, then generate one reference:

```text
cmake --build build/default --target sema_case_clang_ast_variable_declaration
```

Or generate all references:

```text
cmake --build build/default --target sema_case_clang_ast_all
```

These non-default targets require Clang and Python 3 and are not run by normal builds or tests.

CMake invokes Clang to dump the complete translation unit, writes the raw `.ast`, and runs `normalize_ast.py` to update `.ast.txt`. The script only normalizes an existing AST file and never reads CW files.

The normalizer removes top-level implicit built-in declarations while preserving source declarations and their nested implicit nodes. It replaces an address that occurs once with `{{address}}`. Repeated addresses receive numbered `{{address:N}}` placeholders in first-use order, and every later reference reuses the same placeholder. It replaces the absolute case source path with a stable relative path. Normalization writes atomically, so a failure does not overwrite an existing reference.

## Adding a Case

1. Choose one accepted language feature and a snake_case stem.
2. Author the C++ source and generate its normalized Clang reference.
3. Independently author the equivalent CW source and normative CW AST.
4. Add a case-specific Clang AST target to `CMakeLists.txt`.
5. Register the stem and PascalCase test name in `sema_test.cpp`.
6. Review all four tracked files together.
