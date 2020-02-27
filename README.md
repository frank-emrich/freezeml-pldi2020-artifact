Getting Started Guide
=====================

We provide the file `freezeml-pldi2020.ova`, which is virtual machine stored in the
Open Virtual Appliance format supported by most virtualization software.  Use
your favourite virtualization solution (VirtualBox, VMWare) to import the
virtual machine file.  After booting up the virtual machine log in as "user"
with password "user".  You will be automatically taken to the `~/freezeml/`
directory, which contains a copy of this README file.  You can view the readme
inside the virtual machine by issuing the following command:

    less README.md

or continue reading this file.

The root password for the virtual machine is "pldi2020".  The operating system
inside the VM is a Debian Linux 10 and comes with Emacs and Vim editors already
installed.

We have implemented FreezeML in [Links](https://links-lang.org/), a
functional programming language with a rich set of features.

The following section, "Reproducing the Paper Results" gives a quick introduction
on how to validate that Links implements FreezeML. The subsequent section gives
some background information.

Reproducing the Paper Results
=============================


The freeze operator is implemented as `~` in Links, meaning that a variable `x`
is frozen by writing `~x`.  Instantiation and generalisation are written as e@
and $e, respectively, as in the paper. Here, e can be an arbitrary Links
expression, potentially enclosed in parentheses.

The FreezeML paper contains a large set of example programs in Table 14 in
Appendix A. The easiest way to verify that Links implements FreezeML is by
checking that for each program in Table 14 there exists a corresponding version
in Links of the same type, modulo minor differences described later on.

Note that those examples in Table 14 marked with X (i.e., A8, E1, and
E3) do not type-check in FreezeML and do not type-check in Links, either. The
examples from Table 14 rely on the functions given in Figure 15 with their
respective types.

Thus, we provide two separate files in the `~/freezeml` directory:
  * `environment.links` contains the functions shown in Figure 15. This is a
    valid Links source file.
  * `examples.txt` contains the examples from Table 14, which in turn use the
    functions from `environment.links`

Note that `examples.txt` does not contain a tenth example in the "FreezeML
programs" section, meaning that program F10 from Table 14 is missing in
`examples.txt`. This is due to an error we only discovered after submitting the
paper. Program F10 only type-checks in a version of FreezeML that does not obey
the value restriction. We will clarify this in the final version of the paper.


## Reading examples.txt


The file `examples.txt` contains several blocks of consecutive lines, separated
by an empty line. Each such block represents one example from
Table 14. Intuitively, all lines starting with `#` contain extra information; the
lines not starting with `#` contain the actual example programs, either as
literal Links programs or paths to a file containing the program.

The first line in each block starts with `#` and contains a description,
indicating which example from Table 14 the current block represents.

The second line usually contains the actual Links code. Alternatively, in some
cases, the second line contains a path to a `.links` file containing the actual
code. Note that the paths given in the second line are relative to the directory
`~/freezeml/links`. For clarity, we have also added the *full* path to the first
line of such blocks.

The syntax of Links differs from FreezeML. See section "Differences
between Links and FreezeML" below for a brief description of the syntactic
differences.

Finally, the lines from the third onward give extra information about the
expected output of the program:

This includes
  * The messages printed  (`stdout :` and `stdout :`)
  * The exit code, if non-zero ( `exit :`)
  * If the second line contained a path rather than a program (`filemode :`)

Note that for type-checking programs the `stdout :` entry contains the expected
type. See the section "Differences between Links and FreezeML" below for a
description of the (minor) differences between the types shown by Links and
those shown in Table 14.

There are two ways to verify that the programs from `examples.txt` type-check in
Links with the correct types:

### Testing via REPL

You can start the Links REPL by invoking `linx --config=freezeml.config` from
the `~/freezeml` directory. This loads the config file `freezeml.config` and
starts the REPL. The settings in `freezeml.config` implicitly load
`environment.links` and make its bindings available. Further, it sets certain
options that make the behavior of Links more similar to the behavior of
FreezeML. See the section "Differences between Links and FreezeML" below for an
explanation of these settings.

After starting the REPL, you can copy-paste a given example program, followed by
`;;` and pressing enter. This will process the snippet and show its type.

Files containing programs can be loaded by issuing the following in
the REPL: `@load filepath/goes/here ;;`.



### Running the Test Suite

Alternatively, you can invoke `./run-tests.sh` from the `~/freezeml`
directory. This converts `examples.txt` into a file readable by Links' internal
test suite, contained in the `links` subdirectory. It runs each example program
individually and verifies that the actual output and/or return code matches the
expected information.


## Background Information: Differences between Links and FreezeML

### Syntax
The syntax of FreezeML and Links differ as follows:

* Function applications require parentheses in Links. Hence, the FreezeML
  program `f x` becomes `f(x)` in Links. This also holds when applying multiple,
  curried arguments: `f x y` becomes `f(x)(y)`.
* Functions are defined with the `fun` keyword in Links. The FreezeML function
  `lambda x. x` becomes `fun (x) {x}`. Likewise, `lambda x y. x` becomes `fun
  (x)(y) {x}`. Named functions can be defined by stating their name before the
  parameters, e.g.  by writing `fun foo(x) {x}`
* Links does not have `let` bindings of the form `let x = M in N`. Instead,
  variables are bound with the `var` keyword, the binding is terminated by
  `;`. Hence, the `let` binding above would be written as `var x = M; N` in
  Links
* Function types always require parenthesis on the parameter in Links. For
  example, the FreezeML type `a -> b` is written as `(a) -> b` in Links
* Links supports annotations on binders and overall bindings. For example, we
   can write `fun inc (x : Int) {x + 1}` or alternatively
    ```
    sig inc : Int -> Int
    fun inc(x) {x + 1}
    ```
    where `sig` denotes a type signature, which must immediately precede the
    binding it applies to.  Such signatures can also be used with `var`
    bindings.


For more information on Links' syntax, see
[its documentation](https://links-lang.org/quick-help.html).

### Typing

The main differences between Links and FreezeML are the following:

#### Row typing
Links uses a type-effect system based on Rémy-style row polymorphism. This means
that a function type `(a) -> b` in Links is actually syntactic sugar for
`(a) {|c}-> b`,
where `{|c}` is an empty effect row ending with the *fresh* effect
variable `c`. Here, fresh means that the variable occurs nowhere else. The same
type can be written as `(a) -c-> b`, which is also just syntactic sugar for
`(a) {|c} -> b`.

This leads to small differences between the types shown in Table 14 and the
types shown by Links for the corresponding Links program.  For instance, the
example A1• is shown to have type forall a b. a -> b -> b in Table 14. However,
the corresponding Links program has type `forall
a,b::Row,c::(Any,Any),d::Row.(a) -b-> (c::Any) -d-> c::Any` (see line 6 in `examples.txt`) in
`examples.txt`.

The only difference is that in the latter type, the row variables `b` and `d`
are also quantified over. For the purposes of comparing FreezeML with its
implementation in Links, you can simply ignore all row variables, e.g. variables
like `c` appearing as `c::Row` after the `forall` and appearing inside a
function arrow, as in `-c->`. These row variables have no counterpart in
FreezeML.

#### Scoping of type variables
For compatibility reasons with legacy code, the scoping behavior of type
variables works differently in Links than in FreezeML. In Links, one can omit
quantifiers at the top of a type annotation. Consider the following two versions
of the same function

```
sig f1 : forall a. (a) -> a
fun f1(x) {x}
```
and

```
sig f2 : (a) -> a
fun f2(x) {x}
```
The only difference is that in f1, the type variable `a` is explicitly quantified,
whereas in `f2` the type signature just states `(a) -> a`, without the annotation.
However, both functions are still given the same type, as the type variables of
the signature of `f2` are implicitly generalised.
The two versions only differ in whether or not `a` is bound in the body of the
function is not. The rule is that if the type annotation explicitly states the
`forall` quantifier, then the type variables are not bound in the body.

Hence, the following version of `f1` is illegal:

```
sig f1 : forall a. (a) -> a
fun f1(x) {x : a}
```
as `a` is unbound.

However, the following version of `f2` is legal:
```
sig f2 : (a) -> a
fun f2(x) {x : a}
```

This differs from FreezeML, where `let (x : forall a. A) = M in N ` binds a in
`M`, if `M` is generalisable.


### Default settings
The file `freezeml.config` mentioned earlier contains the following settings,
which make Links behave closer to FreezeML:
* `prelude=environment.links` For simplicity, we do not use Links' usual prelude
  of builtin functions, but only use `environment.links`. This means that this
  file is evaluated at startup and its bindings are available.
* `show_quantifiers=true` By default, Links doesn't show quantifiers of
  polymorphic functions/values. Instead of `forall a. a -> a`, Links would show
  only `a -> a` by default. Enabling this setting shows the former, fully
  qualified type.
* `hide_fresh_type_vars=false` By default, Links hides type variables that are
  fresh (i.e., only occur in a single location). This setting evokes that all
  type variables are shown.
* `generalise_toplevel=false` By default, the Links REPL generalises any overall
  expression entered, if the expression is generalisable. For instance, entering
  `fun (x) {x}` into the REPL would yield type `forall a. a -> a`. By setting
  `generalise_toplevel=false`, we prevent this generalisation, and the
  expression would be given type `b -> b` for some flexible type variable `b`.
