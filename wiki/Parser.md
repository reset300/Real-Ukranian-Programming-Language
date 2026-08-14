# Parser

The parser is implemented in `src/parser.zig`.

Compiler version `0.0.2` uses recursive descent and builds the AST defined in `src/ast.zig`.

## Statement dispatch

The parser currently recognizes statements beginning with:

```text
мінливе
вивести
позаяк
допоки
перебрати
розсуд
чин
віддати
перервати
далі
вжити
```

An identifier followed by `стає` is parsed as assignment.

An identifier followed by `став` triggers the dedicated `BecameOnlyForDeclaration` diagnostic.

## Variable syntax validation

After `мінливе`, the parser expects:

```text
identifier став expression
```

If it sees `стає`, it reports `DeclarationRequiresBecame`.

This distinction is enforced syntactically rather than left to the interpreter.

## Blocks

The parser requires:

```text
зачин
...
край
```

Nested blocks recursively contain statement slices.

## Functions

Function declarations parse:

```text
чин <name> бере <parameters> <block>
```

Calls parse as primary expressions beginning with:

```text
вжити
```

## Range loops

Range loops parse:

```text
перебрати <identifier> від <expression> до <expression> <block>
```

## Switch statements

`розсуд` contains a sequence of:

```text
нагода <expression> <block>
```

plus an optional:

```text
решта <block>
```

The parser rejects multiple default branches.

## Expression parser

Precedence levels remain:

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

Function calls are now primary expressions.

## Diagnostics

The parser stores the token associated with the most recent parse failure.

The command-line layer uses its line, column, and lexeme to produce source-oriented diagnostics.
