# CW (C Wonder) Programming Language

English | [中文](README.zh.md)

## Language Overview

**C Wonder** aims to design a modern system-level programming language that inherits the high performance and control of **C++**, while addressing issues such as C++'s steep learning curve and outdated syntax design. Its design goal is to create a language that is both suitable for system programming and easy to learn and use.

> Since **C Wonder** is not very easy to pronounce, I suggest the colloquial name **C One**, which is **C 1** in Chinese.

## Design Philosophy

Combining with C++, CW introduces the following design philosophies:

* Memory abstraction consistent with C++, including:
    * Memory layout
    * Function calls
    * Polymorphism
* No undefined behavior (UB)
    * Variables are initialized by default
* RAII

### Notes

* ABI specifications
* Support for solutions to issues like memory leaks, memory overflows, and performance analysis
* Concurrency model
* Error handling specifications
* Toolchain
* Package management
* No support for references
* const

> Language design is not about "whether I can do it", but "whether I can maintain this decision forever".

## Syntax Rules

### Basic Requirements

Grammar is limited to LL1 grammar and LR1 grammar

Readability > Simplicity > Conciseness

### Type Definition

```
struct <type name>
{
  <member variable definitions>
}
```

#### Member Variable Definitions

```
struct <type name>
{
  a int;
  b int;
}
```

#### Constructor Definition

```
constructor (*<type name>, <parameter list>)
{
  <function body>
}
```

#### Destructor Definition

```
destructor (*<type name>)
{
  <function body>
}
```

#### Inheritance Definition

```
struct <derived type name> : <base type name>
{
}
```

#### Virtual Function Definition

```
struct <type name>
{
  virtual
  {
    func <function name>(*<type name>, <parameter list>) <return type>;
  }
  <variable definitions>
}

virtual <function name>(*<type name>, <parameter list>) <return type>
{
  <function body>
}
```

#### Class Member Functions

```
func <function name> (*<type name>, <parameter list>) <return type>
{
  <function body>
}
```

### Function Definition

```
func <function name> (<parameter list>) <return type>
{
  <function body>
}
```

### Variable Definition

```
var <variable name> = <expression>;
var <variable name>
{
  <expression>
}
var <variable name1>, <variable name2> = <expression1>, <expression2>;
var <variable name1>, <variable name2>
{
  <expression1>, <expression2>
}
```

### Main Function Definition

```
func main(argc int, argv **uint8) int
{
  <function body>
}
```

## Example Code

```

// Struct definition
struct Foo
{
  a int;
  b int;
}

// Constructor definition
constructor (*Foo, a int, b int)
{
  this->a = a;
  this->b = b;
}

// Member function definition
func foo (*Foo, c int) int
{
  return this->a + this->b + c;
}

// Main function
func main(argc int, argv **char) int
{
  // Variable definition method 1: Direct assignment
  var foo0 = Foo(1, 2);
  
  // Variable definition method 2: Block assignment
  var foo1
  {
    Foo(1, 2)
  }
  
  // Variable definition method 3: Multiple variable assignment
  var foo2, foo3 = Foo(1, 2), Foo(1, 2);
  
  // Variable definition method 4: Multiple variable block assignment
  var foo4, foo5
  {
    Foo(1, 2), Foo(1, 2)
  }
  
  // Variable definition method 5: Declare first, assign later
  var foo6
  foo6 = Foo(1, 2);

  return foo0.foo(3);
}

// Base class with virtual functions
struct Bar
{
  virtual
  {
    func bar(*Bar, a int) int
  }
}

// Virtual function implementation
virtual bar(*Bar, a int) int
{
}

// Derived class inheriting from Bar
struct Kar : Bar
{
  virtual
  {
    func kar(*Kar, a int) int;
  }
}

// Override base class virtual function
virtual bar(*Kar, a int) int
{
}

// Implement derived class's own virtual function
virtual kar(*Kar, a int) int
{
}

```