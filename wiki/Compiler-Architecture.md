# Compiler Architecture — 0.0.2

The current project is still an interpreter, but the front end is organized like a compiler.

```text
.ukr source
    ↓
lexer.zig
    ↓
Token[]
    ↓
parser.zig
    ↓
ast.zig
    ↓
interpreter.zig
```

## Files

| File | Responsibility |
|---|---|
| `main.zig` | CLI, source loading, diagnostics |
| `lexer.zig` | UTF-8 tokenization and keyword recognition |
| `parser.zig` | recursive-descent parsing |
| `ast.zig` | statement/expression representation and cleanup |
| `value.zig` | runtime values |
| `interpreter.zig` | scopes, functions, control flow, expression evaluation |
| `root.zig` | version and compiler tests |

0.0.2 separates AST ownership from the parser so the parser no longer also owns recursive cleanup logic.
