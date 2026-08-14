# Lexical Structure

Source files are UTF-8.

## Newlines

Ordinary statements end at newlines. Semicolons are not part of the language.

## Comments

```text
// comment
```

## Strings

```text
"Привіт"
"https://example.com"
```

Latin letters are allowed inside strings but rejected elsewhere by the current lexer.

## Identifiers

```text
мінливе кількість став 10
```

ASCII Latin identifiers such as `count` are rejected.

## Punctuation

The current punctuation vocabulary is deliberately small: `(`, `)`, and `,`.

Most operations are represented by words. See [[Keyword Reference]].
