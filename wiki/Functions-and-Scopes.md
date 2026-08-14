# Functions and Scopes

Functions were introduced in compiler version `0.0.2`.

## Function declaration

A function begins with `чин`.

Syntax:

```text
чин <name> бере <parameter-list>
зачин
    <statements>
край
```

Example:

```text
чин додати бере ліве, праве
зачин
    віддати ліве додати праве
край
```

Parameters are comma-separated identifiers.

## Function with one parameter

```text
чин парне бере число
зачин
    віддати число остача 2 дорівнює 0
край
```

## Function calls

A call begins with `вжити`, followed by the function name and `з`.

```text
вжити додати з 20, 22
```

Calls are expressions, so they may appear inside declarations, output arguments, conditions, and other expressions.

```text
мінливе сума став вжити додати з 20, 22
вивести("сума:", сума)
```

Nested use is valid wherever the parser accepts an expression.

## Return: `віддати`

`віддати` returns from the current function.

With a value:

```text
віддати ліве додати праве
```

A return statement may also omit the expression when it appears at a statement boundary.

## Local scopes

Function calls execute in a local environment.

Parameters are bound as local variables for the duration of the call.

Variables declared inside the function do not become ordinary variables in the caller's scope.

## Nested blocks

Control-flow blocks also participate in scoped execution in the current interpreter design.

## Argument count

The runtime checks function argument count.

Calling a function with the wrong number of arguments produces an error.

## Unknown functions

Calling a function that has not been declared produces a runtime error.

## Current limitations

Version `0.0.2` does not yet support:

- explicit parameter types
- explicit return types
- function overloading
- closures
- first-class function values
- anonymous functions
