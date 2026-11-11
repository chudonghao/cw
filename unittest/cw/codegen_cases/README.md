# Code Generation Cases

This directory contains positive, source-driven language feature cases for comparing C++ and CW code generation. Cases describe public language behavior; compiler phases and implementation details are not case categories.

## Files

Each case uses one snake_case stem and four tracked files:

- `<name>.cpp`: C++ source expressing the language intent.
- `<name>.cpp.ll`: complete Clang IR reference, preceded by compiler version and generation command comments.
- `<name>.cw`: corresponding CW source.
- `<name>.cw.ll`: complete CW IR body expected after Parser, Sema and CodeGen.

The CW expectation excludes ModuleID, source filename, target triple and DataLayout, which the test checks separately. Every byte of the remaining IR is compared, and LLVM verifies the complete module after the frontend and generator have been destroyed.

C++ and CW IR preserve their real structures. They are reviewed for corresponding language behavior, not textual or structural equality.

## Normative Boundary

CW IR expectations are independently authored and reviewed. Never automatically overwrite `<name>.cw.ll` from the current CW compiler output. A justified code generation change can change the expectation without changing the language design; review the reason and the complete IR change before updating it.

Clang references are generated artifacts for human comparison. They are not cross-version test goldens and do not define CW's expected output. Preserve the complete Clang IR, including attributes and metadata.

Only accepted, valid language features belong here. Diagnostics, failure behavior and public interface contracts remain inline in `codegen_test.cpp`. Normal tests read existing files without invoking Clang, running generated programs or writing temporary files.

Use direct C++ counterparts where possible. CW receiver calls map to free-function calls with the receiver as the first argument; block results and named return objects use ordinary C++ scopes, local variables and returns. Explain relevant language differences in short English comments beside the affected source.

CW requires left-to-right argument evaluation. C++17 does not prescribe the order between arguments. The `call_evaluation` reference shows this Clang's choice; Clang 23.1.1 also emits `-Wunsequenced` for its conditional-argument example. The source comment records this difference, and reference generation reports the diagnostic.

CW also evaluates ordinary binary operands completely from left to right. The `arithmetic_evaluation` C++ reference uses explicit temporaries to preserve that order. Its cases cover reads before mutations, single evaluation of division operands, conditional and short-circuit operands, and effects in discarded or constant-result expressions.

CW signed arithmetic wraps, while C++ signed overflow is undefined. The `integer_arithmetic` reference uses unsigned arithmetic and representable signed conversions for the wrapping constants. The `integer_division` reference explicitly handles `INT_MIN / -1` and `INT_MIN % -1`, whose results CW defines. Division cases cover nonzero divisors; runtime division-by-zero handling remains deferred. Other C++ arithmetic references state the input restrictions needed for defined C++ behavior.

CW keeps narrow integer operations at their semantic common type width; C++ promotes narrow operands to `int`. The integer width and conversion references use explicit casts where needed to preserve CW's results. In C++17, out-of-range conversions to signed types are implementation-defined; the native Clang references use the same low-bit interpretation that CW defines. `isize/usize` correspond to this target's 64-bit `long/unsigned long`. Narrow scalar parameters and returns carry the target's required `signext/zeroext` attributes, while references remain pointers.

Floating-point references use native Clang's binary32/binary64 arithmetic and rounding. C++ floating-to-integer conversion is undefined when the truncated value cannot be represented; `floating_to_integer` explicitly handles CW's saturation and NaN-to-zero rules before casting. Compound arithmetic references use `#pragma clang fp contract(off)` to preserve separate multiplication and addition rounding. The `floating_evaluation` reference uses explicit temporaries where needed to preserve CW's evaluation order.

`explicit_numeric_conversion` covers zero values, conversions involving size integers, floating conversions,
and single evaluation of sources, including discarded results. Its C++ reference guards floating-to-integer
conversion to match CW's saturation and NaN-to-zero rules.

The `pointer_evaluation` and `indirect_evaluation` references use explicit temporaries where needed to preserve pointer reads before later mutations and left-to-right argument evaluation. Indirect calls retain the callee value before evaluating arguments that can modify the function pointer object.

Pointer arithmetic references are generated with `-fwrapv-pointer`, matching CW's offsets without in-bounds or no-wrap flags. `pointer_arithmetic` covers offsets, compound assignment and increments over scalar, struct, array, pointer, function pointer and virtual interface pointer pointees. `pointer_difference` covers qualification merging and element strides. Clang's `sdiv exact` assumes both operands point into one array; CW divides without that assumption and truncates other differences, which execution tests cover. `pointer_arithmetic_evaluation` covers evaluating the offset before the pointer in `n + p`, forming the compound source before the target, postfix old values and single target evaluation.

Array references use trivial C++ wrappers where whole-array copying, assignment or value results require them. Existing assignment sources retain their object identity; an explicit value result forms before the target is evaluated. The `array_zero_size` reference uses Clang's zero-length array extension. Array accesses use valid indices.

CW string literals are static const arrays of their decoded `u8` content, with no implicit terminator. The direct C++ literal references retain `char` elements and their extra zero; content accesses exclude that extra element. Whole-array string operations use explicit unsigned byte arrays and trivial C++ wrappers, with Clang's zero-length extension for empty arrays. CW reuses identical content within a module without making literal address equality a language guarantee.

Struct references use corresponding C++ classes for field initialization, default values, member access and aggregate operations. CW and Clang use the same target layout: complete empty classes occupy one byte, while zero-length arrays retain zero size and element alignment. The `struct_zero_size` reference uses Clang's zero-length array extension where needed.

Aggregate value calls preserve independent parameters, result formation, reference bindings and the effects of zero-sized arguments. C++ references use trivial wrappers for whole-array values and explicit captures where CW requires a callee or argument value before later effects. Basic types and trivial aggregates permit call-boundary transport temporaries; their named result addresses need not equal the caller's receiving object address. The `aggregate_results` assignment reference forms the right-hand value before evaluating the target.

Inheritance references use C++ inheritance directly, including eligible base tail-padding reuse and empty-base address constraints. The cases cover base initialization and assignment, inherited field selection, reference and null-preserving pointer conversions, call results, and evaluation through function pointers. Direct base construction acts on the base subobject; a factory or conditional value first forms a complete temporary and then initializes the base. `empty_base_layout` checks nested empty members and a base whose data size differs from its nonvirtual size. `layout_classification` checks floating and pointer aggregates independently of their LLVM storage representation.

User operator calls preserve the selected function, parameter formation and result behavior of ordinary calls. Assignment syntax evaluates the source before the target; explicit operator function calls retain left-to-right argument evaluation. C++ callable references use member `operator()` for CW's free operator with an explicit first parameter; source comments identify temporary-binding differences. Evaluation references explicitly capture values and object references where needed to express CW's fixed order. Zero-sized operands and discarded results retain required calls and side effects.

Nontrivial object cases cover construction, destruction, normal scope exits and full-expression boundaries. Value parameters remain independent objects and are destroyed by the caller at the enclosing full-expression boundary on this target. Ordinary results form in the receiving object's storage; base initialization retains the complete-result boundary described above. Constructors and destructors use an implicit target address and return that address under the Apple arm64 ABI. Clang references retain their complete and base variants and exception paths; the comparison covers successful construction and normal cleanup.

Source comments identify C++ adaptations for deferred local initialization, initialization blocks and whole-array values. Empty objects and zero-sized arrays retain required construction and destruction; array cleanup follows element counts. Conditional temporaries survive subsequent arguments until the enclosing full expression ends, using the original formation condition even if later effects change the source variable.

Virtual cases cover inherited and overridden calls, qualified ordinary calls, covariant pointer and reference results, and unbound virtual interface pointers. Their Clang references use `-fno-rtti`. The lifetime case distinguishes CW's activation after the last initialization's full-expression cleanup and exit before member destruction from C++'s different dispatch stages. Abstract interfaces retain the runtime error entry even when an ordinary definition supports `nonvirtual` calls.

Import cases use C++ declarations whose definitions belong to another translation unit. They compare external calls and object operations, inherited virtual implementations in local tables, covariant results, and virtual dispatch without direct implementation references. C++ has no matching per-declaration `import` or `export` marker; source comments identify the relevant visibility and representation differences. These are compile-only references and do not require linking the external definitions.

The `import_virtual` reference uses a free-function adapter for the ordinary implementation address. Its derived destructor leaves the base-vptr transition to the external base destructor, while CW also restores the imported base table in the caller. In `import_covariance`, Clang references external return-adjusting thunks and emits `Local`'s table with `linkonce_odr` linkage; CW emits private thunks shared by `Local` and `Another`, and named tables with external linkage. In `import_indirect`, Clang omits unused external declarations while CW retains them; neither creates direct references to the virtual implementations or a concrete table.

Multiple inheritance cases use C++ classes with several non-virtual bases. Most dynamic and nontrivial supporting structs are imported, so their definitions belong to another translation unit and the IR stays focused. `multiple_inheritance_layout` compares base offsets with Clang, including repeated empty bases at distinct addresses, a primary base declared after another base, tail-padding reuse and a repeated base; the LLVM struct types may differ where both represent the same offsets. `multiple_inheritance_conversions` covers nonzero-offset and null-preserving conversions, a path through a repeated base, in-place base construction and member access through a pointer, which reaches the base at its offset without a null check. `multiple_inheritance_dispatch` and `multiple_inheritance_covariance` compare vtable groups, secondary vtables and receiver- and result-adjusting thunks, including a primary-vtable entry that only adjusts the result; CW thunks are private, named `thunk(<receiver>,<result>)` and keep null pointer results with `select`. `multiple_inheritance_lifetimes` follows the virtual lifetime case: CW stores every vtable pointer of the group when Both's dispatch starts and restores each dynamic base's group before the members are destroyed. `multiple_inheritance_calls` checks call classification across several bases. In `import_multiple_inheritance`, Clang refers to the external thunk of the imported override, while CW defines a private one. `multiple_inheritance_repeated_bases` gives the two subobjects of a repeated dynamic base different final overriders, so one secondary vtable holds both a direct entry and a thunk.

The `symbol_types` case covers stable semantic identities: same-width integers, reference modes,
const at different pointer layers, evaluated array bounds, ordinary and virtual function pointers,
namespaced `main`, and UTF-8 names. Its C++ address objects retain external declarations for comparison;
CW retains imported declarations directly. CW root `main` remains the fixed entry name. Complete and
base structor entries are distinct; delegation retains the active entry, while base subobject cleanup
uses the base destructor. Named source entities do not use LLVM overload suffixes.

## Naming

File stems and CMake targets use snake_case. Primary C++ and CW declarations and GTest parameter names use PascalCase. Each case has one primary language feature and only the supporting declarations needed to express it. Related variants belong in the same case; each case has one test entry.

The cases, in registration order, are:

1. `local_integer_initialization`
2. `value_parameters`
3. `reference_parameters`
4. `reference_binding`
5. `temporary_reference_binding`
6. `assignment_evaluation`
7. `call_evaluation`
8. `forward_call`
9. `function_overloading`
10. `block_results`
11. `function_return`
12. `discarded_expression`
13. `boolean_objects`
14. `boolean_logic`
15. `while_loop`
16. `conditional_value`
17. `conditional_void`
18. `conditional_reference`
19. `integer_arithmetic`
20. `integer_division`
21. `scalar_comparison`
22. `arithmetic_evaluation`
23. `numeric_loop`
24. `integer_types`
25. `integer_literals`
26. `integer_conversions`
27. `explicit_numeric_conversion`
28. `integer_arithmetic_widths`
29. `integer_comparison_types`
30. `integer_division_widths`
31. `integer_conversion_flow`
32. `floating_types`
33. `floating_literals`
34. `floating_arithmetic`
35. `floating_comparison`
36. `floating_conversions`
37. `floating_to_integer`
38. `floating_evaluation`
39. `pointer_objects`
40. `pointer_qualification`
41. `pointer_comparison`
42. `pointer_evaluation`
43. `pointer_arithmetic`
44. `pointer_difference`
45. `pointer_arithmetic_evaluation`
46. `function_addresses`
47. `indirect_calls`
48. `indirect_evaluation`
49. `array_initialization`
50. `array_assignment`
51. `array_references`
52. `array_conditionals`
53. `array_evaluation`
54. `array_loop`
55. `array_zero_size`
56. `string_literals`
57. `string_arrays`
58. `string_references`
59. `string_conditionals`
60. `struct_initialization`
61. `struct_members`
62. `struct_assignment`
63. `struct_aggregates`
64. `struct_conditionals`
65. `struct_evaluation`
66. `struct_zero_size`
67. `aggregate_values`
68. `aggregate_floats`
69. `aggregate_calls`
70. `aggregate_results`
71. `aggregate_evaluation`
72. `aggregate_indirect_evaluation`
73. `aggregate_zero_size`
74. `inheritance_layout`
75. `base_result_initialization`
76. `empty_base_layout`
77. `layout_classification`
78. `inheritance_access`
79. `inheritance_operations`
80. `inheritance_calls`
81. `inheritance_evaluation`
82. `inheritance_zero_size`
83. `operator_calls`
84. `operator_results`
85. `callable_objects`
86. `operator_evaluation`
87. `object_construction`
88. `explicit_lifetime`
89. `object_results`
90. `local_lifetimes`
91. `object_destruction`
92. `object_arguments`
93. `temporary_lifetimes`
94. `object_arrays`
95. `full_expression_lifetimes`
96. `object_assignment`
97. `object_array_assignment`
98. `array_assignment_lifetimes`
99. `global_initialization`
100. `global_lifetimes`
101. `global_zero_size`
102. `virtual_dispatch`
103. `virtual_pointers`
104. `virtual_covariance`
105. `virtual_lifetimes`
106. `abstract_dispatch`
107. `import_calls`
108. `import_virtual`
109. `import_covariance`
110. `import_indirect`
111. `symbol_types`
112. `constructor_body_initialization`
113. `multiple_inheritance_layout`
114. `multiple_inheritance_conversions`
115. `multiple_inheritance_dispatch`
116. `multiple_inheritance_covariance`
117. `multiple_inheritance_lifetimes`
118. `multiple_inheritance_calls`
119. `import_multiple_inheritance`
120. `multiple_inheritance_repeated_bases`

## Generating Clang References

Configure the project with tests enabled, then generate one reference:

```text
cmake --build build/default --target codegen_case_clang_ir_local_integer_initialization
```

Or generate all references:

```text
cmake --build build/default --target codegen_case_clang_ir_all
```

These non-default targets require Clang and are not run by normal builds or tests.

The current cases target native macOS arm64. Generation uses the project's LLVM host triple and `-std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names`; Clang may print a canonical macOS spelling of the triple. The compiler version, explicit target and options are recorded with each reference.

CMake invokes Clang with a relative source path from this directory and saves its complete output. No Python interpreter or IR normalizer is required. Generation replaces the saved reference atomically after compilation succeeds, so a failure does not overwrite an existing reference. Review source and IR changes together, including compiler or target changes.

## Adding a Case

1. Choose one accepted language feature and a snake_case stem.
2. Author the C++ source and generate its Clang reference.
3. Independently author the corresponding CW source and expected IR body; explain relevant language differences.
4. Add a case-specific Clang IR target to `CMakeLists.txt`.
5. Register the stem and PascalCase test name in `codegen_test.cpp`.
6. Review all four tracked files together and run `codegen_test`.
