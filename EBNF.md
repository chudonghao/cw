# CW (C Wonder) Programming Language EBNF

This document is an auxiliary overview of CW source syntax. The
[language reference manual](LANGUAGE_REFERENCE_MANUAL.zh.md) is the normative source for language rules and
resolves any conflict with this overview.

Quoted strings are terminals, `(...)` groups terms, `[...]` is optional, `{...}` is zero-or-more repetition,
and `|` separates alternatives. `Identifier` is an external lexical symbol supplied by the Lexer. `Expr` is
the external start symbol defined by [`ExprGrammar`](src/cw/ExprGrammar.h); its productions are intentionally
not duplicated here.

```ebnf
(* Translation unit *)
TranslationUnit = { TopLevelDecl } ;

TopLevelDecl = StructDecl
             | FunctionDecl
             | ConstructorDecl
             | DestructorDecl
             | VarGroupDecl ;

(* Structures and virtual interfaces *)
StructDecl =
    [ "trivial" ] , "struct" , Identifier , [ ":" , Identifier ] ,
    "{" , [ VirtualBlock ] , { FieldDecl } , "}" ;

VirtualBlock =
    "virtual" , "{" , { VirtualFunctionDecl } , "}" ;

VirtualFunctionDecl =
    [ VirtualModifierList ] , "func" , Identifier ,
    "(" , [ ParameterList ] , ")" ,
    [ ReturnDecl ] , ";" ;

VirtualModifierList =
      "abstract" , [ "override" ]
    | "override" , [ "abstract" ] ;

FieldDecl = Identifier , Type , ";" ;

(* Functions *)
FunctionDecl =
    "func" , FunctionName ,
    "(" , [ ParameterList ] , ")" ,
    [ ReturnDecl ] , CompoundStmt ;

FunctionName = Identifier
             | "operator" , OverloadableOperator ;

OverloadableOperator =
      "+" | "-" | "!" | "*" | "/" | "%"
    | "<" | "<=" | ">" | ">=" | "==" | "!=" | "="
    | "(" , ")" ;

ConstructorDecl =
    "ctor" , Identifier ,
    "(" , [ ParameterList ] , ")" , CompoundStmt ;

DestructorDecl =
    "dtor" , Identifier , "(" , ")" , CompoundStmt ;

ParameterList = ParameterDecl , { "," , ParameterDecl } ;
ParameterDecl = [ VarPrefix ] , ParameterName , Type ;
ParameterName = Identifier | "this" ;

ReturnDecl = Type
           | VarPrefix , Identifier , Type ;

VarPrefix = "var" , [ AttributeSpec ] ;
AttributeSpec = "(" , AttributeList , ")" ;
AttributeList = Identifier , { "," , Identifier } ;

(* Variables *)
VarGroupDecl =
    VarPrefix , VariableDecl , { "," , VariableDecl } ,
    ( ";" | VarGroupInitializer ) ;

VariableDecl = Identifier , [ Type ] ;

VarGroupInitializer =
    ":=" , ( Exprs , ";" | CompoundStmt ) ;

(* Statements *)
Stmt = CompoundStmt
     | DeclStmt
     | IfStmt
     | WhileStmt
     | BreakStmt
     | ContinueStmt
     | ReturnStmt
     | ExprStmt ;

CompoundStmt = "{" , { Stmt } , [ Exprs ] , "}" ;

DeclStmt = VarGroupDecl ;

IfStmt =
    "if" , Expr , CompoundStmt ,
    [ "else" , CompoundStmt ] ;

WhileStmt = "while" , Expr , CompoundStmt ;

BreakStmt = "break" , ";" ;
ContinueStmt = "continue" , ";" ;
ReturnStmt = "return" , [ Expr ] , ";" ;
ExprStmt = Expr , ";" ;

Exprs = Expr , { "," , Expr } ;

(* Types *)
Type = ConstType
     | ReferenceType
     | PointerType
     | VirtualSlotType
     | FunctionType
     | ArrayType
     | BuiltinType
     | NamedType ;

ConstType = "const" , Type ;

ReferenceType = ReferenceMode , Type ;
ReferenceMode = "mut" | "copy" | "move" ;

PointerType = "*" , Type ;

VirtualSlotType = "virtual" , "*" , FunctionType ;

FunctionType = "func" , "(" , [ TypeList ] , ")" , Type ;
TypeList = Type , { "," , Type } ;

ArrayType = "[" , Expr , "]" , Type ;

BuiltinType = "void" | "bool"
            | "i8" | "i16" | "i32" | "i64"
            | "u8" | "u16" | "u32" | "u64"
            | "f32" | "f64" | "isize" | "usize" ;

NamedType = Identifier ;

(* Fixed-array expression forms used by the external Expr grammar. *)
ArrayValue = ArrayType , ArrayInitializer ;
ArrayInitializer = "{" , [ ArrayElementList ] , "}" ;
ArrayElementList = ArrayElement , { "," , ArrayElement } ;
ArrayElement = Expr | ArrayInitializer ;

(* Identifier and Expr are external symbols described above. *)
```

Expression syntax—including unified postfix calls and chaining, receiver calls, explicit `nonvirtual` calls,
ordinary construction, the `null` literal, fixed-array values and subscripting, explicit-address construction and destruction,
assignment, and initialization—is
maintained by [`ExprGrammar`](src/cw/ExprGrammar.h). See the
[language reference manual](LANGUAGE_REFERENCE_MANUAL.zh.md) for the corresponding syntax and semantic rules.
