# Error Reference

Compiler version `0.0.2` records token source locations and prints more useful diagnostics than `0.0.1`.

Exact wording may still change while the diagnostic system is experimental.

## Declaration-specific parser errors

### `DeclarationRequiresBecame`

A declaration used `стає` where `став` is required.

Incorrect:

```text
мінливе число стає 10
```

Correct:

```text
мінливе число став 10
```

### `BecameOnlyForDeclaration`

`став` was used as if it were reassignment syntax.

Incorrect:

```text
число став 20
```

Correct:

```text
число стає 20
```

## Lexical errors

### `LatinLetterForbidden`

A Latin ASCII letter appeared outside a string literal.

```text
мінливе count став 10
```

### `UnexpectedCharacter`

The lexer found a byte that could not start a supported token.

### `UnterminatedString`

A string reached newline or EOF without a closing `"`. 

## Common parser errors

The parser may report errors such as:

- `ExpectedStatement`
- `ExpectedVariableName`
- `ExpectedBecame`
- `ExpectedBecomes`
- `ExpectedLeftParen`
- `ExpectedRightParen`
- `ExpectedBegin`
- `ExpectedEnd`
- `ExpectedExpression`
- `ExpectedLineEnd`
- `ExpectedFrom`
- `ExpectedTo`
- `ExpectedCaseOrEnd`
- `DuplicateDefaultCase`
- `ExpectedTakes`
- `ExpectedWith`

## Runtime errors

Runtime failures include invalid variable access, invalid value types, bad function usage, illegal control-flow state, and arithmetic errors.

Important examples include:

### `VariableAlreadyExists`

A variable was declared twice in the same environment.

### `UnknownVariable`

A variable could not be resolved.

### `ExpectedBoolean`

A condition or boolean operator received a non-boolean value.

### `ExpectedInteger`

An arithmetic or ordering operator received a non-integer value.

### `DivisionByZero`

Division or remainder used zero as the divisor.

Function-related runtime errors may also occur for unknown functions or invalid argument counts.

## Source locations

Lexer tokens carry:

- line
- column

Parser diagnostics retain the token that caused the failure.

This allows the compiler to report the source location and display the relevant source line.

Diagnostic formatting is still being improved.
