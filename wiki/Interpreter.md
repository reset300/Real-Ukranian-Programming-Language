# Interpreter — 0.0.2

The interpreter evaluates the AST directly.

## Environments

Global values live in a global `StringHashMap(Value)`. Nested scopes are represented by a stack of local hash maps.

Lookup searches local scopes from innermost to outermost, then the global map. Assignment follows the same search order.

## Functions

Top-level functions are registered before ordinary top-level statements execute. A function call evaluates arguments in the caller, creates a local scope, binds parameters, executes the body, and propagates `віддати` back to the caller.

## Control signals

Return, break, and continue are propagated internally with an execution signal rather than being modeled as ordinary runtime values.

## Short-circuit logic

`і` and `або` are short-circuited in 0.0.2, so the right-hand expression is evaluated only when required.
