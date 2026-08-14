# Functions and Scopes

Functions are new in compiler 0.0.2.

## Declaration

```text
чин додати бере ліве, праве
зачин
    віддати ліве додати праве
край
```

A function with no parameters still uses `бере`:

```text
чин привіт бере
зачин
    вивести("Привіт")
край
```

## Calling

```text
вжити додати з 2, 3
```

A call is an expression:

```text
мінливе сума став вжити додати з 20, 22
вивести(вжити додати з 1, 2)
```

## Returning

```text
віддати expression
```

Bare `віддати` returns an internal empty value.

## Scopes

Function parameters are local. Nested blocks also create local scopes.

Top-level functions are registered before normal top-level execution, so recursion and calling a later top-level declaration are possible.
