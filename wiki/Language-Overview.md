# Language Overview

This page gives a high-level description of the language as implemented by compiler version `0.0.2`.

For exact parser syntax, see [[Grammar Reference]].

## Source files

Programs conventionally use the `.ukr` extension and UTF-8 encoding.

## Statements

Ordinary statements are separated by line boundaries. Semicolons are not used.

```text
мінливе число став 10
число стає число додати 1
вивести(число)
```

## Blocks

Blocks do not use `{` and `}`.

They use:

```text
зачин
    ...
край
```

This syntax is required for conditionals, loops, functions, switch cases, and other block bodies.

## Declaration and reassignment

The language intentionally distinguishes:

```text
мінливе число став 10
```

from:

```text
число стає 20
```

`став` initializes a new mutable variable.  
`стає` changes an existing variable.

## Values

The runtime currently supports:

| Kind | Example |
|---|---|
| Integer | `42` |
| String | `"Привіт"` |
| Boolean | `авжеж`, `ані` |

## Operators

Most operators are words:

```text
число додати 1
число остача 2
число перевищує 10
готово і дозволено
```

## Control flow

Current control-flow constructs include:

- `позаяк`
- `одначе позаяк`
- `одначе`
- `допоки`
- `перебрати`
- `перервати`
- `далі`
- `розсуд`
- `нагода`
- `решта`

## Functions

Functions are introduced with `чин`.

```text
чин додати бере а, б
зачин
    віддати а додати б
край
```

Calls are expressions:

```text
вжити додати з 2, 3
```

## Identifiers

ASCII Latin letters are rejected outside string literals.

Valid:

```text
мінливе кількість став 10
```

Rejected:

```text
мінливе count став 10
```

Latin text is allowed inside strings.

## Comments

Line comments start with `//`.

```text
// ignored by the lexer
мінливе число став 10
```

## Execution pipeline

```text
source
  ↓
lexer
  ↓
tokens
  ↓
parser
  ↓
AST
  ↓
interpreter
```

See [[Compiler Architecture]] for implementation details.
