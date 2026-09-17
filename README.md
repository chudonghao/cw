# CW (C Wonder) Programming Language

English | [中文](README.zh.md)

## Language Overview

**C Wonder** aims to design a modern system-level programming language that inherits the high performance and control of **C++**, while addressing issues such as C++'s steep learning curve and outdated syntax design. Its design goal is to create a language that is both suitable for system programming and easy to learn and use.

> Since **C Wonder** is not very easy to pronounce, I suggest the colloquial name **C One**, which is **C 1** in Chinese.

## Language Documentation

- [Language reference manual (Chinese)](LANGUAGE_REFERENCE_MANUAL.zh.md) — normative language rules
- [EBNF grammar overview](EBNF.md) — auxiliary syntax documentation

## Design Philosophy

Combining with C++, CW introduces the following design philosophies:

* Memory abstraction consistent with C++, including:
    * Memory layout
    * Function calls
    * Polymorphism
* No undefined behavior (UB)
    * Variables must be initialized before use
* RAII

Avoiding C++'s excessive complexity and freedom:

* Preprocessing
* Forward declarations
* Namespaces

Grammar is limited to LL1 grammar and LR1 grammar

Readability > Simplicity > Conciseness

> Language design is not about "whether I can do it", but "whether I can maintain this decision forever".
