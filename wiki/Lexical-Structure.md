# Lexical Structure

This page describes source tokenization in compiler version `0.0.2`.

## Encoding

Source files are UTF-8.

## Whitespace

Spaces, tabs, and carriage returns separate tokens.

Newlines are significant and normally terminate statements.

Blank lines are permitted.

## Comments

A line comment starts with `//`.

```text
// comment
мінливе число став 10
```

## Integers

Decimal integer literals are sequences of ASCII digits:

```text
0
10
1250
```

## Strings

Strings use ASCII double quotes:

```text
"Привіт"
"https://example.com"
```

Latin characters are allowed inside strings.

Escape sequences are not yet implemented.

## Identifiers

Identifiers are source words that are not recognized keywords.

Examples:

```text
число
лічильник
сума
готово
```

ASCII Latin letters are rejected outside strings.

## Punctuation

The language currently recognizes:

| Character | Purpose |
|---|---|
| `(` | grouped expression or argument list |
| `)` | close grouped expression or argument list |
| `,` | separate arguments or parameters |

There are no braces or semicolons.

## Keywords

See [[Keyword Reference]] for the complete `0.0.2` list.
