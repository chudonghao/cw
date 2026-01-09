# CW (C Wonder) 编程语言

## 语言概述

**C Wonder** 希望设计一门现代化的系统级编程语言，旨在继承 **C++** 的高性能和控制力，同时解决 **C++** 学习路径陡峭、语法设计陈旧等问题。它的设计目标是创建一门既适合系统编程，又易于学习和使用的语言。

> 鉴于 **C Wonder** 不太好读，我建议口语化名称为 **C One** ，中文为 **C 1** 。

## 设计理念

结合 C++ ，CW 推出以下设计理念：

* 内存抽象与 C++ 一致，包括：
    * 内存布局
    * 函数调用
    * 多态 
* 无未定义行为（UB）
    * 变量默认初始化
* RAII

### 备忘录

* ABI规范
* 内存泄露、内存越界、性能分析等问题的方案支持 
* 并发模型
* 错误处理规范
* 工具链
* 包管理
* 不支持引用
* const

> 语言设计不是“我能不能做到”，而是“我能不能永远维护这个决定”。

## 语法规则

### 基本要求

文法限制在 LL1 文法和 LR1 文法

可读性 > 简单 > 简洁

### 类型定义

```
struct <类型名>
{
  <成员变量定义>
}
```

#### 成员变量定义

```
struct <类型名>
{
  a int;
  b int;
}
```

#### 构造函数定义

```
constructor (*<类型名>, <参数列表>)
{
  <函数体>
}
```

#### 析构函数定义

```
destructor (*<类型名>)
{
  <函数体>
}
```

#### 继承定义

```
struct <派生类型名> : <基类型名>
{
}
```

#### 虚函数定义

```
struct <类型名>
{
  virtual
  {
    func <函数名>(*<类型名>, <参数列表>) <返回类型>;
  }
  <变量定义>
}

virtual <函数名>(*<类型名>, <参数列表>) <返回类型>
{
  <函数体>
}
```

#### 类成员函数

```
func <函数名> (*<类型名>, <参数列表>) <返回类型>
{
  <函数体>
}
```

### 函数定义

```
func <函数名> (<参数列表>) <返回类型>
{
  <函数体>
}
```

### 变量定义

```
var <变量名> = <表达式>;
var <变量名>
{
  <表达式>
}
var <变量名1>, <变量名2> = <表达式1>, <表达式2>;
var <变量名1>, <变量名2>
{
  <表达式1>, <表达式2>
}
```

### 主函数定义

```
func main(argc int, argv **uint8) int
{
  <函数体>
}
```

## 示例代码

```

// 结构体定义
struct Foo
{
  a int;
  b int;
}

// 构造函数定义
constructor (*Foo, a int, b int)
{
  this->a = a;
  this->b = b;
}

// 成员函数定义
func foo (*Foo, c int) int
{
  return this->a + this->b + c;
}

// 主函数
func main(argc int, argv **char) int
{
  // 变量定义方式 1: 直接赋值
  var foo0 = Foo(1, 2);
  
  // 变量定义方式 2: 块级赋值
  var foo1
  {
    Foo(1, 2)
  }
  
  // 变量定义方式 3: 多变量赋值
  var foo2, foo3 = Foo(1, 2), Foo(1, 2);
  
  // 变量定义方式 4: 多变量块级赋值
  var foo4, foo5
  {
    Foo(1, 2), Foo(1, 2)
  }
  
  // 变量定义方式 5: 先声明后赋值
  var foo6
  foo6 = Foo(1, 2);

  return foo0.foo(3);
}

// 带虚函数的基类
struct Bar
{
  virtual
  {
    func bar(*Bar, a int) int
  }
}

// 虚函数实现
virtual bar(*Bar, a int) int
{
}

// 继承自 Bar 的派生类
struct Kar : Bar
{
  virtual
  {
    func kar(*Kar, a int) int;
  }
}

// 重写基类虚函数
virtual bar(*Kar, a int) int
{
}

// 实现派生类自己的虚函数
virtual kar(*Kar, a int) int
{
}

```
