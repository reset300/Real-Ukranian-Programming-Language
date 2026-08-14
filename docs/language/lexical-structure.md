# Lexical Structure

## Encoding

Source files are UTF-8 text.

## Identifiers

Identifiers name variables. They are expected to use Ukrainian Cyrillic text.

```text
мінливе кількість стає 10
```

Latin letters are rejected outside string literals.

```text
мінливе count стає 10
```

is invalid.

## Whitespace

Spaces and tabs separate tokens. Newlines terminate ordinary statements. Blank lines are allowed.

## Comments

A line comment begins with `//` and runs to the end of the line.

```text
// ignored
мінливе число стає 10
```

## Strings

Strings currently use double quotes.

```text
"Привіт"
```

## Blocks

The language does not use `{` or `}`. A block is written as:

```text
зачин
    ...
край
```
