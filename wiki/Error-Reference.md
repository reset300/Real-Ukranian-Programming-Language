# Error Reference — 0.0.2

Diagnostics now include line and column information for lexer and parser errors where location data is available.

## Declaration-specific parser errors

### `DeclarationRequiresBecame`

A declaration used `стає` instead of `став`.

```text
мінливе число стає 10
```

Correct:

```text
мінливе число став 10
```

### `BecameOnlyForDeclaration`

An ordinary assignment used `став`.

```text
число став 20
```

Correct:

```text
число стає 20
```

## Lexer errors

- `LatinLetterForbidden`
- `UnexpectedCharacter`
- `UnterminatedString`

## Parser errors

Important parser errors include:

- `ExpectedStatement`
- `ExpectedVariableName`
- `ExpectedBecame`
- `ExpectedBecomes`
- `ExpectedExpression`
- `ExpectedBegin`
- `ExpectedEnd`
- `ExpectedLoopVariable`
- `ExpectedFrom`
- `ExpectedTo`
- `ExpectedCaseOrEnd`
- `DuplicateDefaultCase`
- `ExpectedFunctionName`
- `ExpectedTakes`
- `ExpectedParameterName`
- `ExpectedWith`
- `ExpectedLeftParen`
- `ExpectedRightParen`
- `ExpectedLineEnd`

## Runtime errors

- `VariableAlreadyExists`
- `UnknownVariable`
- `FunctionAlreadyExists`
- `UnknownFunction`
- `WrongArgumentCount`
- `ExpectedBoolean`
- `ExpectedInteger`
- `DivisionByZero`
- `BreakOutsideLoop`
- `ContinueOutsideLoop`
- `ReturnOutsideFunction`
- `UnsupportedUnaryOperator`
- `UnsupportedBinaryOperator`
