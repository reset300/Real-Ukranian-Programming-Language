# Compiler Architecture

Compiler version `0.0.2` is an interpreter with a compiler-style front end.

## Pipeline

```text
.ukr source
    │
    ▼
Lexer
    │
    ▼
Token stream
    │
    ▼
Parser
    │
    ▼
AST
    │
    ▼
Interpreter
```

## Main modules

```text
src/
├── main.zig
├── lexer.zig
├── parser.zig
├── ast.zig
├── interpreter.zig
├── value.zig
└── root.zig
```

## `main.zig`

The command-line entry point:

1. reads arguments;
2. handles `--help`, `--version`, and token inspection;
3. loads a source file;
4. lexes it;
5. parses the token stream;
6. prints diagnostics on failure;
7. executes the AST;
8. releases all owned allocations.

## `lexer.zig`

The lexer converts UTF-8 source bytes into `Token` values and records source positions.

See [[Lexer]].

## `parser.zig`

The parser is recursive descent.

It parses statements, blocks, function declarations, calls, range loops, switch branches, and precedence-aware expressions.

See [[Parser]].

## `ast.zig`

Version `0.0.2` moves AST definitions and recursive cleanup into a dedicated module.

The AST contains expression and statement variants used by the interpreter.

## `interpreter.zig`

The interpreter evaluates expressions and executes statements.

Version `0.0.2` adds:

- function storage and calls;
- local scopes;
- returns;
- loop break/continue propagation;
- range loops;
- switch-like branching.

See [[Interpreter]].

## `value.zig`

Runtime values currently include:

```text
integer
string
boolean
```

## Memory ownership

The source buffer remains alive while tokens and AST nodes reference slices from it.

AST expression nodes and owned statement slices are recursively released after execution.

The project previously exposed allocator leak reports during early `0.0.1` development; recursive AST cleanup was added before `0.0.2`.

## Future architecture

A later compiler may add:

```text
AST
 ↓
semantic analysis
 ↓
typed IR
 ↓
code generation
```

The existing lexer/parser separation is intended to make that possible without rewriting the complete front end.
