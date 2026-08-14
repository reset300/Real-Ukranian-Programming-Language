# Compiler Architecture

The current implementation is an interpreter with a compiler-style front end.

```text
.ukr source
    |
    v
Lexer
    |
    v
Token stream
    |
    v
Parser
    |
    v
Statement and expression tree
    |
    v
Interpreter
```

The lexer handles source spelling. The parser handles grammar. The interpreter handles meaning and runtime state.

This separation is intentional: a native code-generation backend can later replace the interpreter without rewriting the lexer and parser.
