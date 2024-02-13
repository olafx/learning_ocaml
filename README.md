# README

These are my notes learning OCaml (https://ocaml.org), not a tutorial, but may still be of some value.

## ML, and (from a practical perspective) Dynamic Typing vs Explicit Static Typing vs Hidnley-Milner Type System

https://www.lesswrong.com/posts/vTS8K4NBSi9iyCrPo/a-reckless-introduction-to-hindley-milner-type-inference

Some languages are designed to very much reflect how a computer works, like C, and all the languages it inspired. An alternative starting point when designing a language is the language of mathematical logic. In particular, lambda calculus. This leads to functional languages.\
An early highly influential is **ML** (Meta Language), from 1973. ML uses the **Hindley-Milner** (HM) type system, which can deduce the **most general type** of variables, function parameters, etc., without explicitly specifying the type. This is a big deal, and very different from explicit static typing or dynamic typing, and requires some thought. The HM type system has the benefit of dynamic typing in that it is implicit. But it also has the benefit of static typing in that it can be statically analyzed (which itself leads to faster compiled programs), and avoids runtime errors. It also has the additional benefit of being maximally general, essentially meaning such a type system is similar to templating in languages like C++. Say in Python we have a function
```python
def f(x): return x+x
```
We will find that `f(1)` gives `2`, and `f([1])` gives `[1, 1]`. This *generality* can be found in C++ too:
```cpp
template <typename T>
auto f(T x) { return x+x; }
```
But the HM type system is very different, and much more powerful. It deduces, **based on the entire program** the most general types, all implicitly. 
In ML, then in OCaml:
```ml
fun f x = x + x;
```
```ocaml
let f x = x + x;;
```
The HM type system makes functions **polymorphic**, i.e. they can be used in many different ways. C++ templates are also polymorphic in the general sense of the word, but as discussed, it's not the same. Syntactically, 'polymorphism' in C++ is used instead to describe runtime polymorphism, e.g. virtual functions in superclasses being specialized in subclasses leading to different behavior at runtime for different objects of the same type (in a sense). So in that sense, C++ templates are not polymorphic, because they are compile time polymorphism.
```cpp
#include <iostream>
struct A { virtual int f() { return 0; } };
struct B : A { int f() { return 1; } };
int main()
{   A a {}; B b {}; A *c[2] = {&a, &b};
    std::cout << c[0]->f() << ' ' << c[1]->f() << std::endl;
} // "0 1"
```
The type inference algorithm used by OCaml is 'algorithm W'. Practically, it's useful to know that such an algorithm has a high theoretical complexity, and so it is useful to design the language in such a way that type inference is easier, as will be seen for OCaml. This isn't like a single pass C compiler, it can require a significant amount of computation to infer the most general types. C++ can also be surprisingly slow to compile due to metaprogramming.

## The ML tree, the OCaml leaf, and other leaves

OCaml, and other ML derivatives

https://caml.inria.fr/pub/docs/oreilly-book/html/book-ora202.html

From **ML** (1973) came **Caml** (1985), as a dialect, with some changes to the type system, and adding some features. E.g. pretty printing was added, and mutable values could no longer be polymorphic. Then came **OCaml** (1996), most notably supporting object oriented programming, still within the HM type system.\
There are many other languages that evolved from ML. OCaml is a major leaf in the tree. Another major leaf is **Standard ML** (SML) (1983), which is different from ML in that it has a formal specification, and different from OCaml in that it sticks closer to its ML roots, and also adds some features. Another one is **Haskell** (1990), which is lazily evaluated, and introduces many type classes useful for succint functional programming, e.g. monads.

## OCaml infrastructure

https://ocaml.org/docs/installing-ocaml

Other than obviously a compiler, OCaml comes with more **official** infrastructure:
- **Discord** server: Always good to have some form of centralized community. https://discord.com/invite/2YkRUnC
- **opam**: A package manager. (C/C++ has no package manager, which is a major shortcoming.)
- **UTop** (Universal Toplevel): A **REPL** (Read-Eval-Print-Loop), an interactive programming environment, functionally similar to Python. https://github.com/ocaml-community/utop
- **Dune**: A build system. Allegedly also useful for small projects. https://dune.build (With an official package manager, an official build environment also makes sense. In C/C++, CMake is often used, originally also designed to deal with large projects, but mostly used because it *sort of* offers a solution to not having an official package manager. Only 'sort of', because practically it's still a disaster for specific libraries.)
- **odoc**: An automatic documentation generator. This is wildly used, it's the most popular package currently. https://github.com/ocaml/odoc
- **OCamlFormat**: An automatic formatter. https://github.com/ocaml-ppx/ocamlformat (Similar to Python's PEP 8 formatters.) There are various standard styles, see link.

## OCaml design basics

**Expressions** are evaluated. OCaml uses **double semicolons**, only for historical reasons for Caml compatibility.
```ocaml
1+2;;
1e2;;
"abc";;
true;;
```
These are of type `int`, `float`, `string`, and `bool`.\
This is not much different from C++. (It is different from C, where the `bool` type is defined in the standard library (it's not included a default type), and `true` is a macro (until C23).)\
`int` in OCaml is 64 bit signed, whereas it's 32 bit (*usually*... ew) in C/C++.\
The strings are immutable, like a `const char *` in C/C++, not `char[]`, which is also the inferred type of string literals in C/C++.\
The literal `1e2` is a 64 bit float in both OCaml and C/C++, named `float` and `double` respectively. OCaml does not support 32 bit float math, similar to Python in that aspect.
```cpp
1+2;
1e2;
"abc";
true;
```

---

So far, although there are types, there has been no type inference (in our sense of the word); the compiler just reads **literals** and understands that they belong to a certain type. The term '**type inference**' is sort of vague, but let's say lists are inferred.
```ocaml
[1; 2];;
```
(OCaml uses the word 'list', similar to Python, but different from Fortran's 'array', which is arguably the authority here, as also used by C/C++.)\
Lists are declared with a square bracket, similar to Python, except using semicolons instead of commas, similar to MATLAB's columns. (Fortran never had such a feature.)\
The list is of type `int list`. In Python it would simply be a `list`. In C/C++, there is no such type inference. This is a subtle distinction: such a list is not a literal in C/C++, instead it's an 'initializer'. And because C/C++ has no real type deduction, there is no way to have such an initializer list without types.
```cpp
auto f () { return 0; } // compiles
int main()
{   {1, 2}; // does not compile
    auto a[] = {1, 2}; // does not compile
    int b[] = {1, 2}; // compiles
    auto c = f(); // compiles
}
```
\
In C++ (and in C, since C23), the `auto` 'keyword' is *replaced* by the correct type at compile time, via a very simple set of rules. The rule is essentially to either replace it because the type is trivial (e.g. the result type of a simple function), or try to insert every possibility until something works (or nothing works), via a princple called SFINAE: substitution failure is not an error.\
It's hard to say whether the above OCaml code uses the actual HM type system, but the point is, the OCaml type system is nothing like `auto`.

In Python, `type([1])` is `list`. This hints that `[1, 'a']` is well defined, which it indeed is, but it isn't in OCaml: a list must have a singular type. Tuples however can have different types.\
The type of the below tuple is `int * char`; OCaml differentiates between strings and characters in the same way C/C++ does.
```ocaml
(1, 'a');;
```

The **empty list** is called '**nil**'. Its type is `'a`, which is a **placeholder type**. The next placeholder type will be named `'b`.
```ocaml
[];;
```
Prepending an element is done using the '**cons**' operator `::` ('cons' as in '2 colons'). This only works on lists, not tuples, which seems odd since they're both immutable.
```ocaml
let a = [2; 3];;
1 :: a;;
```

Lists of lists are possible. The internal lists may have different lengths, similar to a heap allocated `int **` in C/C++.
```ocaml
[[1]; [2; 3]];;
```

---

Variables are declared with the `let` 'construction' in OCaml, typical for functional languages, and of course without an explicit type.
```ocaml
let a = 1;;
```
However, **variables are immutable**. As discussed, this is a change Caml made to ML. This means that prepending 1 as above returns a new list, and does not mutate `a`. So `1 :: a;;` above in python would be `[1]+a`, not `a.insert(0, 1); a`. Python has tuples as immutable 'lists', but they don't have the functionality of Python lists, e.g. no `(1)+(2,3)`. In the above example, we say that '`a` is bound to `1`', highlighting the immutability.

<!-- TODO: References can be updated, can write about references here. -->
Variables are immutanble for syntactic reasons: they are defined to be mutable. There's also **references**, which are mutable, see later.

---

There's a **ternary expression**, similar to the one in C/C++ in ordering, but syntactically similar to python. It has high precedence, as usual. The problem with the one in C/C++ is that it's hard to read. The problem with the one in python is that it's of the form (branch, boolean expression, branch), which is particularly inelegant for large ternary expressions.
```ocaml
2 * if false then -1 else 1;;
```

OCaml has 2 equality operators, the **structural equality** `=` and **physical equality** `==`. `=` compares contents, `==` compares identity. So in C terms, `=` compares memory, `==` compares memory location.\
The `=` operator works on strings, lists, etc., as in Python.\
The negation of `=` is `<>` ('less than or greater than'), and the negation of `==` is `!=`; structural inequality and physical inequality.

---

OCaml can create **local variables** in expressions using `in`.
```ocaml
let y = 1 in y+y;;
```
This works recursively.
```ocaml
let a = 3 in
let b = 4 in
  a*a+b*b;;
```
This is similar to an anonymous lambda function in C++. But this is not powerful in C++, `int` can't be replaced by `auto` because it's a lambda. It's very arbitrary, but it would work (since C++20) if it was an actual function, but it's a lambda, so not even in C++20. This is called an 'abbreviated function template' in C++.\
A related limitation is that C++ can't automatically deduce the type of recursive lambdas, again quite arbitrary.\
In functional languages, all this behavior just follows from the implementation of the lambda calculus and HM type system. No arbitrary limitations, more elegant, more useful.
```cpp
[](int y = 1){ return y+y; }();
```

---

Functions are much like variables, because of course it's a functional language (with support for objects also). (Coincidentally, again much like lambdas in C++.)\
The body of the function is what it returns, so there's no set of statements ending with `return` as in C/C++.
<!-- TODO: Not sure if there's no statements in a function. -->
```ocaml
let f x = x*x;;
```
The type of this function is `int -> int`. This is because `*` is always between integers, so `int -> int` is the most general type of `f`. `*.` is used for floats. This implies OCaml has no operator overloading, which is so.\
This is done to make type inference more practical, because seeing a `*` or `+` would be sufficient to conclude we're dealing with integers, since e.g. `+` also does not mix between floats and integers; there's no implicit conversions. Similarly, there's `*.` for float multiplication and `/.` for float division. Conversion is done via `float_of_int` and `int_of_float`.
```ocaml
float_of_int 1 *. 2.0;;
int_of_float (2.0 /. 1.0);;
```

A shortcoming of C/C++ is that function calls don't include the names of variables, it's always implicit, which can be difficult to read. In Python they can be explicitly stated, with all sorts of powerful behavior via `*args` and `**kwargs`. In C/C++, it's done via comments, if it's done at all, because it's missing from the language. In C this can be done for structs at least, but not for functions.
```python
def f(a): return a+'b'
f(a='a')
```
```c
struct A { int a; } typedef A;
A a = {.a = 1};
void f(int a) {}
f(/* a */ 1);
```
In OCaml, a parameter can be **labeled**.
```ocaml
let f ~x y = x+y;;
```
Here the type is `x:int -> int -> int`. (Note also the stream-like nature of this type, typical for functional languages: `x` to `y` to `x+y`.) The fact that this type is different hints that the function is used differently. Indeed it is, it *must* be used with explicit labels. (Function calls are again stream-like, no brackets for parameters.)\
(Function calls have high precedence, e.g. `f 1+1` is `(f 1)+1`. In C/C++, commas take the role of the spaces, and the commas have the highest precedence, so that's the *opposite*.)
```ocaml
f ~x:1 2;;
```

Functions can be **anonymous**, similar to anonymous lambdas in Python and C++. The syntax changes quite a bit.
```ocaml
(fun x -> x+x) 1;;
```

Functions whose parameters are partially given become new functions, a hallmark feature of functional languages, called '**partial application**'.
```ocaml
let f x y = x+y;;
```
The type of `f 1` is `int -> int`, and `(f 1) 2` is the same as `f 1 2`. Quite elegant, it looks like an associative property.

A '**higher order function**' is a function of a function. Python, C, and C++ have this too, and it's again a hallmark of functional programming.
```ocaml
let g f x = f (f x);;
let h f x = f (f x) + 1;;
```
The type of `f` is clearly `('a -> 'a) -> 'a -> 'a`. Here `int` can't be inferred, it's too general. It can be inferred from `h`, the type of `h` is `(int -> int) -> int -> int`; the HM type system at work.
In C this would look something like the following.
```c
int h(int (*f)(int), int x)
{   return f(f(x))+1;
}
```
C23 is not out yet as of writing this so we're not sure if this would work with the C23 `auto` keyword. The way to read `int (*f)(int)` is that `f` is a function pointer with parameter `int` and returns `int`.
In C++ this can be done elegantly using `auto`, but only in C++20.
```cpp
template <typename F>
auto h(F f, auto x)
{   return f(f(x))+1;
}
auto f(auto x)
{   return x*x;
}
int main()
{   h(f, 3);
}
```
This doesn't actually compile. Here we run into some relatively arbitrary C++ `auto` type inference limitations. `x` in `f` must be `int`, then it does work. This happens because it tries to determine the type of `f` necessary to determine the type of `h`, but this requires previous information of how `h` is used. This seems logical to a human, but this is illegal according to the C++20 standard; this nonlocal logic is not implemented for type inference.

Functions like `gets` are `puts` in C (get string, put string) are OS level functions, because they deal with the terminal. (The much more frequently used versions are `scanf` and `printf`.) OCaml similarly has `read_line` and `print_endline`. The types of these functions are `unit -> string` and `string -> unit` respectively, where `unit` is sort of similar to `void` in C/C++.\
Although `void` can't be instantiated, `unit` can, with `()`. (And `()` is the only possible value of a variable of type `unit`.) The usefulness of 'instantiating `void`' is that it's useful for all functions to return something in functional languages. In functional programming, '**side effects**' are common. It's particularly common for I/O, but functional programming embraces side effects in general.

OCaml does not have loops in the same way Python and C/C++ do, instead it embraces recursion (as functional languages do), particularly **tail recursion**, and more specifically still, **tail-call  optimizable** tail recursion, where the recursive call can be compiled to what is essentially identical to a compiled `while` or `for` loop in C/C++, i.e. the hardware function call becomes a jump, with the function head staying an actual hardware function.\
A recursive function should be declared with `rec`. It's not like this in all functional languages, but it is in Caml (and thus OCaml), because functions can be redefined easily here, since they're immutable variables. A function redefinition can easily be confused for a recursive function, but not if recursive functions are explicitly declared. The details are complicated, but it amounts to different choices of how to implement the lambda calculus, and it's not something to really be concerned with from a practical standpoint. It's notable that part of this is also to make the type inference more practical.
```ocaml
let rec fac n = if n <= 1 then 1 else n*fac(n-1);;
```
https://wiki.c2.com/?TailCallOptimization\
https://stackoverflow.com/questions/28796904/whats-the-reason-of-let-rec-for-impure-functional-language-ocaml\
https://stackoverflow.com/questions/900585/why-are-functions-in-ocaml-f-not-recursive-by-default

---

An option takes the role of `None` in Python, `NULL` in C, and `NULL`/`nullptr` in C++. 
The most general type of an option is `'a option`, which is the type of the `None` literal.\
The below creates an option that is something, with value `1`, and an option with value `None`. These have types `int option` and `'a option` respectively.
```ocaml
Some 1;;
None;;
```
We can use the below to see the possible types and values of an `option`.\
The general type is `'a option`.\
We see the value can be `None`, or `Some of 'a`. E.g. `Some 1` is a value of the form of `Some of 'a`, in particular `Some of int`.
```
#show option;;
```

---

OCaml has **pattern matching**, as Python and C/C++ do, through the `match` and `switch` statements respectively.
```ocaml
let rec fac n =
  match n with
  | 0 | 1 -> 1
  | _ -> n*fac(n-1);;
```
`_` signifies an unused variable, here acting as the default result of the pattern, because anything fits.\
Below this is written in C++, requiring C++20 for the `auto` parameter. As a lambda, type inference does not work recursively. Never say never in C++, but it would at least be hacky to get this to work in a lambda.
```cpp
auto fac(auto n)
{   switch (n)
    {   case 0:
        case 1:
            return 1;
        default:
            return n*fac(n-1);
    }
}
```
\
Using the cons operator, we can **inspect** in a match statement something like `a :: b`, so that a list is separated into the first element and the remainder. This is useful for recursive functions. The following for example calculates the length of a list. Such a function works on any list, so the right type is `'a -> int`. This is a simple example of true **polymorphism**, in the HM sense.\
(This is also kind of an example of why it's useful to make `+` only work on integers. Forgetting the `1`, the `+` already implies the result type is `int`. It is clear this decision makes compilation faster, allowing OCaml to tackle larger projects, which is very much by design.)
```ocaml
let rec length u =
  match u with
  | [] -> 0
  | _ :: v -> 1+length v;;
```
\
Widely used in functional programming is the `map` function, a 2nd order function that applies a function on a list. Let's map a list to the square of the elements, like squaring a NumPy array in Python.
```ocaml
let rec map f u =
  match u with
  | [] -> []
  | u :: v -> f u :: map f v;;
map (fun x -> x*x) [1; 2; 3];;
```
Notice that `u` is redefined here, to capture the value of the function parameter `u`. The second `u` is in the function scope, similar to local `let` `in` variables.\
The type of `map` is `('a -> 'b) -> 'a list -> 'b list`, which is the most general type clearly. Because `fun x -> x*x` is `int -> int`, `map (fun x -> x*x)` is `int list -> int list`, through partial application.

Notice that the cons operator allows for the inspection of list elements via pattern matching. Similar inspection works for tuples.
```ocaml
let first u = match u with (u, _) -> u;;
```
This is a function of type `'a * 'b -> 'a`, which is clearly the most general.

Pattern matching works for anything, except functions.\
It also works for options for example. The below function returns `false` if the option `x` is `None`, and `true` if it is `Some of 'a`.
```ocaml
let f x =
  match x with
  | None -> false
  | Some _ -> true;;
f None;;
f (Some 1);;
```
Obviously this is not a great example of use of pattern matching, this can be simplified.
```ocaml
let f' x = x <> None;;
f None = f' None && f (Some 1) = f' (Some 1);;
```
The type of `f` is `'a option -> bool`, because `None` is of a general type `'a option`. This is slightly subtle, `None` is a literal of indefinite type.

Patterns ideally should be fully captured. E.g. the following throws a warning. It may be useful that it's only a warning when it's not obvious that practically, actually, it is exhaustive sometimes, when OCaml can't know the possible values, e.g. due to I/O (multiple systems communicating, where the compiler does not understand the other system).
```ocaml
fun i -> match i with 0 -> None;;
```

---

A **variant type** is similar to an enum and union type in C. If a variable with an enum type takes on a certain value, it's sort of like a union taking on a certain type and value, so unions are in a sense a generalization of enums in C.
```ocaml
type direction = L | R;;
type response = Data of string | Error of int;;
```
These are both types, not variables. It's also possible to construct variant types that are a mix of C enums and unions. The value of `direction` is `L | R`. It's remarkably elegant, the description of what direction is as returned by utop is identical to the definition of the type itself.
```ocaml
L;;
Data "abc";;
Error -1;;
```
`L` is of type `direction`, `Data "abc"` is of type `response`. So it's similar to a C union, the type of `Error(-1)` and `Data "<html></html>"` is identical. (`Error -1` does not work because `1` is a literal and `-1` is not, `-` is an operator on the `1` literal, but `Error` takes precedence, similar to a function call.)\
`Data` and `Error` are called '**constructors**', because they construct variant values. In C++, constructors are often implicitly defined from types, but OCaml is implicitly typed, but variant types are explicit, so we only now see constructors.

Variant types work with pattern matching.
```ocaml
type color = Red | Blue | Green;;
let color_to_RGB c =
  match c with
  | Red -> (0xff, 0, 0)
  | Green -> (0, 0xff, 0)
  | Blue -> (0, 0, 0xff);;
```
The type of `color_to_rgb` is `color -> int * int * int`.

Lists are variant types, in the tuple sense in C.
```
#show list;;
```
It shows the value of a list is in general `[] | (::) of 'a * 'a list`, i.e. it's either empty, or the cons operator applied to the pair `'a` and `'a list`, i.e. `'a` prepended to another `'a list`. This recursive definition is clearly valid, e.g. indeed only elements of type `'a` are contained.

---

OCaml has **records**, similar to structs in C. The types are explicitly specified. The elements are named **components**.
```ocaml
type side = Buy | Sell;;
type order = {
  id : int;
  symbol : string;
  side : side;
  size : float;
  time_filled : int option;
};;
let my_order = {
  symbol = "META";
  id = 42;
  side = Buy;
  time_filled = None;
  size = 3.;
};;
```
The record `my_order` is automatically associated to the type `order` based on the component names *and* types (not order).

Records work with pattern matching. Unlike for tuples, not the entire record needs to be inspected.
```ocaml
let order_side o = match o with { side = s; _ } -> s;;
my_order.side;;
```
The type of `order_side` is `order -> side`, because it uses the most recent record type with a `side` component. `order_side my_order` is equivalent to `my_order.side`, that's how components are accessed.

---

OCaml has **exceptions**. They can be raised, and expressions can be tried.
```ocaml
1 / 0;;
let assert_even n =
  match n mod 2 with
  | 0 -> true
  | _ -> raise (Failure "odd");;
try assert_even 1 with Failure _ -> false;;
```
The type of `assert_even` is `int -> bool`, i.e. there is no throw clause. C++ experimented with these, but it's not worth discussing.\
We can make the factorial function slightly better now.
```ocaml
let rec fac n =
  match n with
  | n when n < 0 -> raise (Failure "factorial of negative number")
  | 0 | 1 -> 1
  | _ -> n*fac(n-1);;
```
Here `n when n < 0` is the set of negative integers. `n` here is redefined. So `n` from `match n with` is matched against the set of negative integers when this `n` is a negative integer. These functional languages read like mathematics.

The type `result` is a variant type intended to wrap results which may be exceptions, with constructors `Ok` and `Error`. The fully type is `('a, 'b) result`. The C++ equivalent is a templated union, quite niche.
```ocaml
let assert_even n =
  match n mod 2 with
  | 0 -> Ok true
  | _ -> Error "odd";;
assert_even 1;;
```
The type of `assert_even` is `int -> (bool, string) result`.

---

**References** are like variables, but mutable.
```ocaml
let x = ref 1;;
!x;;
x := 2;;
```
Here the expression `!x` gives an `int`, and the `int ref` `x` is mutable.\
The walrus operator `:=` is called the **assignment** operator, and we say that `x` **receives** `2`. All expressions evaluate to something, so naturally `x := 2;;` evaluates to unit `()`.\
The assignment operator can be seen as having a side effect. In fact, it's the most basic kind of side effect there is, allowing for imperative programming.

---

A semicolon may combine multiple expressions. Each must return something. 
```ocaml
let x = ref 1.;;
x := !x*.(!x); x := !x/.2.;;
```
It acts here as essentially a `unit -> unit -> unit` function.

---

OCaml has **modules**, like Python modules, for organizational purposes. Also somewhat similar to C++ namespaces. OCaml has a standard library, made up of modules.\
Whereas `option` is a variant type, `Option` is a module.
```
#show Option
```
This shows the contents of the `Option` module. This is called the **module interface**.\
Module functions are used in the obvious way.
```ocaml
List.map (fun x -> x*x) [1; 2; 3];;
```
The result is an `int list` with value `[1; 4; 9]`. We implemented `map` earlier, so as with any language, use the standard library!

## Compilation and Projects

The OCaml package manager opam has **switches**, similar to Python virtual environments, to separate dependencies.\
The default switch is a global one.\
Updating the list of packages and upgrading them is done in the usual way. Also showing a list of installed packages, and their versions.
```
opam update
opam upgrade
opam list
```
A specific package can be upgraded/installed in the usual way.
```
opam upgrade <package name>
opam install <package name>
```
\
Similar to Swift, OCaml can both compile binaries and compile bytecode. This bytecode is ran with the OCaml interpreter.

Initializing a dune project creates a number of files, e.g. `/<project name>/bin/main.ml`, which is a hello world program by default. (A basic OCaml file still uses the ML extension.)\
The default hello world program allows us to already compile also.
```
dune init proj <project name>
cd <project name>
dune build
dune exec <project name>
```
It's not necessary to explicitly build each time, just `dune exec <project name>` will rebuild modified files, like GNU Make.\
The file `<project name>.opam` contains info about the project, like a Python `setup.py`. This file contains a bunch of automatically generated nonsense, it should be edited by default, just like `main.ml`.\
The folder `bin` conains `main.ml` (in general, executables) and `dune`. The `dune` file is like a CMake file, describing how the contents of this `bin` folder should be compiled, in this case just `main.ml`.\
By default, dune will compile to bytecode.

OCaml has no main function as in C/C++, it's instead similar to Python, just executing the file. The name `main.ml` is not a special main file, it's just marked as an executable in the `dune` file, and it's the only executable.\
However, it's common practice to let the (apparent) variable unit `()` act as the entry point. (It's 'apparent' in that it isn't actually assigned, it's not a usable variable.) It just marks (unenforced) the expression on the right as the starting point.\
The default file `main.ml` executes print_endline in this way. Double semicolons are not necessary outside of the toplevel.
```ocaml
let () = print_endline "Hello, World!"
```
\
A module is created as a separate `.ml` file, this time in the folder `lib`. This folder is the library of this project. Modules don't need to be added to this library, it's implicit.\
The `main.ml` file, marked as an executable, is already built against this library. So nothing needs to change. It can be compiled against additional libraries by adding them in the `dune` file, i.e. `(libraries <project library> <other library> <another library>)`.\
A project may have multiple libraries. So a function in `main.ml` is referred to by both the library and module.\
The library name is the project name, except capitalized. (This is by default at least, it's editable in `/lib/dune`, but we'll call it the project name here.) The module name is the name of the module file, except captalized.\
So a `fac` factorial function added to `<module>.ml` can be used in `main.ml` via `<capitalized project name>.<capitalized module name>.fac`. Let's also use the `Printf` standard library module containing the `printf` function.
```ocaml
let () = Printf.printf "%d\n" (Project_name.Module.fac 1)
```
It's clear by now modules don't need to be included, it's all implicit.\
The `<module>` module interface can be listed in the usual way in the toplevel. This requires running `dune utop`, so that the modules are included in utop.
```
#show <capitalized project name>.<capitalized module name>
```
If a module in `lib` has the same name as the library, it will be seen as the library, rather than a module of the library. To fix this, add `module <capitalized module name> = <capitalized module name>` to the module named after the library.

Module interfaces can be made explicitly with `.mli` files associated to `.ml` module files, containing declarations, similar to a C/C++ header file of some code defined in a `.c` or `.cpp` file (or whatever other extension).\
This is useful for having private functions. E.g. in the `irulan` example project, the string `"factorial of negative number"` used as the error message in the factorial function of the `combinatorics` module is private.\

Dune also creates a default test file `/test/test_irulan`. Files here can be ran with `dune test`. Additional tests must be added to the `/test/dune` file, similarly to executables in `/bin` (test files are also executables).
