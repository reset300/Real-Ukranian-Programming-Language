# Lexer

The lexer is implemented in `src/lexer.zig`.

It converts UTF-8 source text into a sequence of tokens.

## Token structure

Each token stores:

```zig
pub const Token = struct {
    tag: TokenTag,
    lexeme: []const u8,
    line: usize,
    column: usize,
};
```

## Example

Source:

```text
мінливе число став 10
```

Conceptual tokens:

```text
keyword_mutable
identifier("число")
keyword_became
integer("10")
newline
eof
```

Reassignment:

```text
число стає 20
```

uses a different token:

```text
keyword_becomes
```

## New 0.0.2 keywords

The lexer now recognizes tokens for:

- `став`
- `перебрати`
- `від`
- `до`
- `перервати`
- `далі`
- `розсуд`
- `нагода`
- `решта`
- `чин`
- `бере`
- `віддати`
- `вжити`
- `з`

## UTF-8 strategy

Ukrainian lexemes are preserved as slices of the original UTF-8 source.

The current lexer does not need to decode every Unicode scalar to distinguish ordinary words from ASCII separators.

## Latin-letter restriction

ASCII Latin letters are rejected outside strings.

Strings may contain Latin text.

## Comments

`//` starts a line comment.

Comments are skipped and do not enter the token stream.

## Diagnostics

The lexer stores the line and column of a lexical failure in a diagnostic structure.

This information is consumed by the command-line diagnostic output.
