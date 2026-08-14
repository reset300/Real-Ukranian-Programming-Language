# Interpreter

The interpreter executes the AST produced by the parser.

Compiler version `0.0.2` adds functions, scopes, loop control, range loops, and switch-like execution.

## Values

Runtime values remain:

```text
integer
string
boolean
```

## Variables and scopes

Variables live in environments/scopes.

A declaration creates a binding in the current environment.

Assignment resolves an existing variable and replaces its value.

Function calls create local bindings for parameters and function-local variables.

## Function storage

Function declarations are registered by name.

A call:

```text
вжити додати з 20, 22
```

looks up the corresponding function, evaluates arguments, binds parameters, and executes the function body.

## Return propagation

`віддати` stops execution of the current function body and propagates an optional returned value back to the caller.

## Loop control

`перервати` and `далі` are represented as control-flow results rather than ordinary values.

They propagate through nested statements until handled by the active loop.

## Range loops

`перебрати` evaluates its start and end expressions and executes the body for the generated iteration values.

The loop variable is bound in the loop's execution scope.

## Switch-like branching

`розсуд` evaluates its subject expression once.

Each `нагода` expression is compared against it.

The first matching branch executes.

If no case matches, the optional `решта` block executes.

## Boolean operators

`і` and `або` use short-circuit behavior in `0.0.2`.

This means the right-hand side is only evaluated when required.

## Runtime type checks

The language is dynamically checked at runtime.

Arithmetic expects integers.

Control-flow conditions expect booleans.

Invalid runtime combinations return errors rather than silently converting values.
