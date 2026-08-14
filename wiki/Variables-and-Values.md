# Variables and Values

## Declaration

```text
мінливе число став 10
```

`став` is mandatory for initialization in 0.0.2.

## Reassignment

```text
число стає число додати 1
```

`стає` is mandatory for reassignment.

The compiler has dedicated diagnostics for mixing these two forms.

## Runtime values

- signed 64-bit integer
- string
- boolean
- internal empty value for functions that return no expression

## Scopes

Blocks create nested local scopes. Functions create local parameter scopes.

An inner declaration can shadow an outer variable. Assignment searches outward for the nearest existing binding.
