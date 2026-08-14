# Real Ukrainian Programming Language

> Compiler version **0.0.2** — experimental.

A Ukrainian programming language implemented in Zig with deliberately non-C-like surface syntax.

## Example

```text
чин додати бере а, б
зачин
    віддати а додати б
край

мінливе число став вжити додати з 20, 22

позаяк число дорівнює 42
зачин
    вивести("відповідь:", число)
край
```

## 0.0.2 highlights

- `став` for declaration, `стає` for reassignment
- functions and return values
- nested scopes
- range loops
- break and continue
- switch-style branching
- improved source diagnostics
- `--version`, `--help`, and `--tokens`

## Read the documentation

**Start:** [[Getting Started]] · [[Language Overview]]

**Language:** [[Variables and Values]] · [[Expressions and Operators]] · [[Control Flow]] · [[Functions and Scopes]] · [[Output]]

**Reference:** [[Grammar Reference]] · [[Keyword Reference]] · [[Error Reference]]

**Internals:** [[Compiler Architecture]] · [[Lexer]] · [[Parser]] · [[Interpreter]]
