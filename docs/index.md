# Language Documentation

This documentation describes the current experimental language implemented by this repository.

The source language uses Ukrainian keywords and identifiers. The documentation is in English so a reader does not need to know the language vocabulary before learning the syntax.

## Design rules

- Blocks start with `зачин` and end with `край`.
- Statements end at a line boundary rather than with semicolons.
- Assignment uses `стає`.
- Arithmetic and comparison operators are words.
- Conditional branches use `позаяк` and `одначе`.
- Loops use `допоки`.
- Latin letters are rejected in identifiers and keywords.
- String contents may contain arbitrary text.

## Example

```text
мінливе число стає 0

допоки число менше 10
зачин
    позаяк число остача 2 дорівнює 0
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

## Contents

- [Getting Started](getting-started.md)
- [Lexical Structure](language/lexical-structure.md)
- [Variables](language/variables.md)
- [Expressions](language/expressions.md)
- [Control Flow](language/control-flow.md)
- [Output](language/output.md)
- [Grammar Reference](reference/grammar.md)
- [Keywords and Operators](reference/keywords.md)
- [Errors](reference/errors.md)
- [Compiler Architecture](compiler/architecture.md)
