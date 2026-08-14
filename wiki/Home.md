# Real Ukrainian Programming Language

> Experimental Ukrainian programming language and interpreter.

**Compiler version:** `0.0.2`  
**Status:** experimental

The project is written in Zig and currently consists of a lexer, recursive-descent parser, AST, scoped interpreter, diagnostics, examples, and command-line tooling.

The language deliberately avoids looking like a translated C-family language. Blocks use `зачин` / `край`, most operators are words, declarations and reassignment are intentionally different, and control-flow constructs use Ukrainian syntax.

## Example

```text
чин парне бере число
зачин
    віддати число остача 2 дорівнює 0
край

мінливе число став 0

допоки число менше 10
зачин
    позаяк вжити парне з число
    зачин
        вивести("парне", число)
    край
    одначе
    зачин
        вивести("непарне", число)
    край

    число стає число додати 1
край
```

## What changed in 0.0.2

Version `0.0.2` expands the language substantially:

- `став` is now used for variable declaration initialization.
- `стає` is reserved for reassignment.
- Functions are supported with `чин`, `бере`, `вжити`, `з`, and `віддати`.
- Function calls may be used as expressions.
- Functions have local scopes.
- Range loops are supported through `перебрати ... від ... до ...`.
- Loops support `перервати` and `далі`.
- Switch-like branching is supported through `розсуд`, `нагода`, and `решта`.
- Lexer and parser diagnostics now retain source locations.
- The command line supports `--help`, `--version`, and `--tokens`.

## Documentation

### Learn the language

- [[Getting Started]]
- [[Language Overview]]
- [[Lexical Structure]]
- [[Variables and Values]]
- [[Expressions and Operators]]
- [[Control Flow]]
- [[Functions and Scopes]]
- [[Output]]

### Exact reference

- [[Grammar Reference]]
- [[Keyword Reference]]
- [[Error Reference]]

### Compiler internals

- [[Compiler Architecture]]
- [[Lexer]]
- [[Parser]]
- [[Interpreter]]
