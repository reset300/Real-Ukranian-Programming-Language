# Parser

The parser lives in `src/parser.zig` and uses recursive descent.

Statements currently include variable declaration, assignment, output, conditionals, and while loops.

Expression precedence is implemented as separate parsing levels rather than evaluating tokens strictly left to right.
