# Changelog

## 0.0.2

### Language

- Split declaration and reassignment into `став` and `стає`.
- Added functions with `чин`, `бере`, `віддати`, `вжити`, and `з`.
- Added function-local scopes and nested block scopes.
- Added range loops with `перебрати ... від ... до ...`.
- Added `перервати` and `далі` loop control.
- Added `розсуд`, `нагода`, and `решта` multi-way branching.
- Added expression statements for function calls.
- Added internal `порожньо` value for functions that return without a value.
- Added short-circuit evaluation for `і` and `або`.

### Compiler

- Moved AST definitions and recursive cleanup into `src/ast.zig`.
- Added source locations to parser diagnostics.
- Added declaration-specific hints for accidental `став` / `стає` confusion.
- Added `--version`, `--help`, and `--tokens`.
- Added parser tests for 0.0.2 syntax.
- Updated package version to `0.0.2`.

## 0.0.1

- Initial working interpreter.
- Variables and reassignment.
- Integer, string, and boolean values.
- Arithmetic and comparisons.
- `позаяк`, `одначе позаяк`, `одначе`, and `допоки`.
- `зачин` / `край` blocks.
- `вивести(...)` output.
