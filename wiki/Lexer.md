# Lexer — 0.0.2

The lexer produces tokens containing a tag, source slice, line, and column.

New 0.0.2 keywords include `став`, `перебрати`, `розсуд`, `чин`, `віддати`, and function-call syntax words.

The lexer rejects ASCII Latin letters outside string literals. It scans Ukrainian lexemes as UTF-8 source slices and uses ASCII delimiters to find token boundaries.

The CLI option `--tokens` exposes the produced token stream for debugging:

```console
compiler --tokens examples/basic.ukr
```
