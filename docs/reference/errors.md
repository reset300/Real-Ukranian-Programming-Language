# Errors

The current compiler reports short Zig error names. More detailed source diagnostics can be added later.

## Lexing

- `LatinLetterForbidden`: Latin source text appeared outside a string.
- `UnterminatedString`: a string was not closed.
- `UnexpectedCharacter`: the lexer could not classify the current input.

## Parsing

Common parser errors include:

- `ExpectedStatement`
- `ExpectedVariableName`
- `ExpectedBecomes`
- `ExpectedLeftParen`
- `ExpectedRightParen`
- `ExpectedBegin`
- `ExpectedEnd`
- `ExpectedExpression`
- `ExpectedLineEnd`

## Runtime

- `VariableAlreadyExists`
- `UnknownVariable`
- `ExpectedBoolean`
- `ExpectedInteger`
