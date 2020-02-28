Getting Started Guide
=====================

We provide the file `freezeml-pldi2020.ova`, which is a virtual machine stored
in the Open Virtual Appliance format supported by most virtualisation software.
Use your favourite virtualisation solution (VirtualBox, VMWare) to import the
virtual machine file.  After booting up the virtual machine log in as "user"
with password "user".  You will be automatically taken to the `~/freezeml/`
directory, which contains a copy of this README file.  You can view the readme
inside the virtual machine by issuing the following command:

    less README.md

or continue reading this file.  If you decide to read this file inside the
virtual machine it is recommended that you log into the second terminal so that
you can run the examples without closing the readme.  Use Alt+F1 / Alt+F2 to
switch to the first and second terminal respectively.

The root password for the virtual machine is "pldi2020".  The operating system
inside the VM is a Debian Linux 10 and comes with Emacs and Vim editors already
installed.


Implementation
==============

We have implemented FreezeML in [Links](https://links-lang.org/), a
functional programming language with a rich set of features.

The freeze operator is implemented as `~` in Links, meaning that a variable `x`
is frozen by writing `~x`.  Instantiation and generalisation are written as `e@`
and `$e`, respectively, as in the paper.  Here, `e` can be an arbitrary Links
expression, potentially enclosed in parentheses.

There are several differences between Links and FreezeML.  These are either
cosmetic (slightly different syntax) or orthogonal to the system presented in
the paper, e.g. Links has a more powerful type system based on row typing but
this does not interact with first-class polymorphism.  See section "Differences
between Links and FreezeML" below for a description of the most important
differences.


Reproducing the Paper Results
=============================

The FreezeML paper contains a large set of example programs in Table 14 in
Appendix A.  The easiest way to verify that Links implements FreezeML is by
checking that for each program in Table 14 there exists a corresponding version
in Links of the same type, modulo minor differences described later on.

Note that those examples in Table 14 marked with X (i.e., A8, E1, and
E3) do not type-check in FreezeML and do not type-check in Links, either. The
examples from Table 14 rely on the functions given in Figure 15 with their
respective types.

Thus, we provide two separate files in the `~/freezeml` directory:

  * `environment.links` contains the definitions of functions shown in Figure
    15.  This is a valid Links source file.

  * `examples.tests` contains the examples from Table 14, which in turn use the
    functions from `environment.links`


The file `examples.tests` contains verbatim translations of the corresponding
programs from Figure 14, with the following special cases:

1. The examples A11\*, A12\*, C6\*, E3, and E3• exhibit the interaction of
   FreezeML and Links' inference of linearity, which we described in section 6
   of the paper: In these examples, we need to annotate function parameters with
   their kind to prevent Links from inferring that the parameter is linear.
   However, the *types* of the function parameters are still inferred.

2. We have discovered that examples F3 and F4 need an annotation on the
   variable `x`, which we will fix in the final version of the paper.

3. We have omitted example F10.  This is due to an error we only discovered
   after submitting the paper.  Program F10 only type-checks in a version of
   FreezeML that does not obey the value restriction.  We will clarify this
   in the final version of the paper.


Reading examples.tests
----------------------

The file `examples.tests` contains several blocks of consecutive lines,
separated by an empty line.  Each such block represents one example from Table
14.

The first line in each block contains a description, indicating which example
from Table 14 the current block represents.

The second line in most cases contains the actual Links code.  Alternatively, in
some cases, the second line contains a path to a `.links` file containing the
actual code.  Note that the paths given in the second line are relative to the
`~/freezeml` directory.

Finally, the lines from the third onward give extra information about the
expected output of the program.  This includes:

  * The messages printed  (`stdout :` and `stderr :`)
  * The exit code, if non-zero ( `exit :`)
  * Flag to read a program from a file (`filemode :`)

Note that for type-checking programs the `stdout :` entry contains the expected
type.  Section "Differences between Links and FreezeML" explains the differences
between the types displayed by Links and those shown in Table 14.

There are two ways to verify that the programs from `examples.tests` type-check
in Links with the correct types.


Testing via REPL
----------------

You can start the Links REPL by invoking `links --config=freezeml.config` from
the `~/freezeml` directory.  This loads the config file `freezeml.config` and
starts the REPL.  The settings in `freezeml.config` implicitly load
`environment.links` and make its bindings available.  Further, it sets certain
options to align the behaviour of Links with that of FreezeML.  See the section
"Differences between Links and FreezeML" below for an explanation of these
settings.

After starting the REPL, you can type in a given example program, followed by
`;;` and pressing enter.  This will process the snippet and show its type.

Files containing programs can be loaded by issuing the following in the REPL:
`@load "filepath/goes/here" ;;`.  Note that example programs A8, E1, and E3 are
(deliberately) ill-typed and loading/typing them into the REPL will produce a
type error.


For more information about using the REPL, see the corresponding section below.


Running the Test Suite
----------------------

Alternatively, you can invoke `./run-examples.py` from the `~/freezeml`
directory.  This will run each example program individually and verify that the
actual output and/or return code matches the expected information.


Using the REPL
==============

As stated earlier, you can start the REPL via `links --config=freezeml.config`
from the ~/freezeml directory.

Here are some programs you may enter into the REPL. Note that there is a brief
description of the Links syntax in section "Differences between Links and
FreezeML" below. The Links REPL has a command history (similar to normal
shells), which you can access by pressing the up arrow and down arrow keys.

For your convenience, we have setup the REPL in a way such that the programs
below are part of the command history already. Thus, instead of typing them into
the REPL, you can just press the up arrow key after starting the REPL for the
first time.


1) The identity function as an anynoymlus function. Note the trailing `;;`
   to terminate REPL input.
   ```
     fun (x) {x} ;;
   ```


2) A named version of the same function
   ```
     fun f(x) {x} ;;
   ```

3) The same function, but with a signature that gives the parameter `x` the
   polymorphic type `forall a. a`.
   Further, the signature evokes that the return type is instantiated to be
   `forall a. a`, too.
   Note that REPL input can span multiple lines, as it must be terminated by `;`.
   For clarity, in the pre-installed command history, we have put all functions
   on a single line each.
   ```
     sig g : (forall a. a) -> (forall a. a)
     fun g (x) {x} ;;
   ```


4) A version of `g` that freezes `x`, hence resulting in the same polymorphic
   return type as before
   ```
     sig h : (forall a. a) -> (forall a. a)
     fun h (x) {~x} ;;
   ```

5) Using the parameter as a function
   ```
     sig i : (forall a. a) -> (forall a. a)
     fun i (x) {x(~x)} ;;
   ```


6) Version of `i` that switches the location of the freeze operatior, which leads
   to an ill-typed program.
   ```
     sig j : (forall a. a) -> (forall a. a)
     fun j (x) {~x(x)} ;;
   ```

7) This doesn't work on its own
   ```
     fun k(x) {x(x)} ;;
    ```

8) Neitherr does this...
   ```
     fun l(x) {x(~x)} ;;
   ```


9) Creates a variable whose value is [], since writing ~[] doesn't work on its
   own
   ```
     var nil = [] ;;
   ```


10) Creates a list of three polymorphic nils
    ```
      map (fun (x) {~nil})([1,2,3]) ;;
    ```





Differences between Links and FreezeML
======================================

Syntax
------

The syntax of FreezeML and Links differ as follows:

  * Function applications require parentheses in Links.  Hence, the FreezeML
    program `f x` becomes `f(x)` in Links.  This also holds when applying
    multiple, curried arguments: `f x y` becomes `f(x)(y)`.

  * Functions are defined with the `fun` keyword in Links.  The FreezeML
    function `lambda x. x` becomes `fun (x) {x}`.  Likewise, `lambda x y. x`
    becomes `fun (x)(y) {x}`.  Named functions can be defined by stating their
    name before the parameters, e.g.  by writing `fun foo(x) {x}`

  * Links does not have `let` bindings of the form `let x = M in N`.  Instead,
    variables are bound with the `var` keyword, the binding is terminated by
    `;`.  Hence, the `let` binding above would be written as `var x = M; N` in
    Links.

  * Function types always require parenthesis on the parameter in Links.  For
    example, the FreezeML type `a -> b` is written as `(a) -> b` in Links.

  * Links supports annotations on binders and overall bindings.  For example, we
    can write `fun inc (x : Int) {x + 1}` or alternatively:
    ```
    sig inc : Int -> Int
    fun inc(x) {x + 1}
    ```
    where `sig` denotes a type signature, which must immediately precede the
    binding it applies to.  Such signatures can also be used with `var`
    bindings.

For more information on Links' syntax, see [its
documentation](https://links-lang.org/quick-help.html).


Typing
------

The main differences between the type systems of Links and FreezeML are the
following:


### Row typing

Links uses a type-effect system based on Rémy-style row polymorphism.  This
means that a function type `(a) -> b` in Links is actually syntactic sugar for
`(a) {|c}-> b`, where `{|c}` is an empty effect row ending with the *fresh*
effect variable `c`.  Here, fresh means that the variable occurs nowhere else.
The same type can be written as `(a) -c-> b`, which is also just syntactic sugar
for `(a) {|c} -> b`.

This leads to small differences between the types shown in Table 14 and the
types shown by Links for the corresponding FreezeML program.  For instance, the
example A1• is shown to have type `forall a b. a -> b -> b` in Table 14.
However, the corresponding Links program has type `forall
a,b::Row,c::(Any,Any),d::Row.(a) -b-> (c::Any) -d-> c::Any` (see line 7 in
`examples.tests`).

The difference between FreezeML and Links is that the latter quantifies the row
variables `b` and `d`.  For the purposes of comparing FreezeML with its
implementation in Links, you can simply ignore all row variables, e.g. variables
like `b` appearing as `b::Row` after the `forall` and appearing inside a
function arrow, as in `-b->`.  These row variables have no counterpart in
FreezeML.


### Scoping of type variables

For compatibility reasons with legacy code, the scoping behaviour of type
variables works differently in Links than in FreezeML.  In Links, one can omit
quantifiers at the top of a type annotation.  Consider the following two
versions of the same function

```
sig f1 : forall a,e::Row. (a) -e-> a
fun f1(x) {x}
```
and

```
sig f2 : (a) -e-> a
fun f2(x) {x}
```

The only difference is that in `f1` the type variable `a` and row variable `e`
are explicitly quantified, whereas in `f2` the type signature just states `(a)
-e-> a`, without a quantifier.
However, both functions are still given the same type, as the type variables in
the signature of `f2` are implicitly quantified.
The two versions only differ in whether or not `a` and `e` are bound in the body
of the function.  The rule is that if the type annotation explicitly states the
`forall` quantifier, then the type variables are not bound in the body.
**Note:** this is the exact opposite of how scoped type variables behave in
Haskell.

Hence, the following version of `f1` is illegal:

```
sig f1 : forall a, e::Row. (a) -e-> a
fun f1(x) {x : a}
```

as `a` is unbound.

However, the following version of `f2` is legal:

```
sig f2 : (a) -e-> a
fun f2(x) {x : a}
```

This differs from FreezeML, where `let (x : forall a. A) = M in N ` binds a in
`M`, if `M` is generalisable.


Default settings
----------------

The file `freezeml.config` mentioned earlier contains the following settings,
which make Links behave closer to FreezeML:

  * `prelude=environment.links`

    For simplicity, we do not use Links' usual prelude of builtin functions, but
    only use `environment.links`, which contains definitions of functions from
    Table 15 (Appendix A).  This file is evaluated at startup and its bindings
    become globally available.

  * `show_quantifiers=true`

    By default, Links doesn't show quantifiers of polymorphic functions/values.
    Instead of `forall a. (a::Any) -> a::Any`, Links would show only `(a::Any)
    -> a::Any` by default.  Enabling this setting shows the former, fully
    qualified type.

  * `hide_fresh_type_vars=false`

    By default, Links hides type variables that are fresh (i.e., only occur in a
    single location).  This setting evokes that all type variables are shown.

  * `generalise_toplevel=false`

    By default, the Links REPL generalises any expression entered, if the
    expression is generalisable.  For instance, entering `fun (x) {x}` into the
    REPL would yield type `forall a. (a) -> a`.  The above setting prevents this
    generalisation, and the expression would be given type `(a) -> a`.  This
    setting ensures that no implicit generalisation occurs.
