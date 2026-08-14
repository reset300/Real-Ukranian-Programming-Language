# Lexer

The lexer lives in `src/lexer.zig`.

For example:

```text
мінливе число стає 10
```

becomes conceptually:

```text
keyword_mutable
identifier("число")
keyword_becomes
integer("10")
newline
```

The lexer does not decide whether those tokens form a valid statement. That is the parser's job.
