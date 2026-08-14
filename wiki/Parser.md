# Parser — 0.0.2

The parser is recursive descent.

Statement dispatch now covers declarations, assignment, output, conditions, while loops, range loops, switch-style branching, functions, return, break, continue, and function-call expression statements.

Expression parsing uses precedence layers:

```text
or
and
equality
comparison
addition/subtraction
multiplication/division/remainder
unary
primary
```

The parser stores the token that caused a syntax error so `main.zig` can print a source location and excerpt.
