# Variables and Values

Compiler version `0.0.2` distinguishes variable declaration from reassignment.

## Declaration

A mutable variable is declared with:

```text
мінливе <name> став <expression>
```

Example:

```text
мінливе число став 10
```

The initializer expression is evaluated and stored in a newly created variable.

## Reassignment

An existing variable is changed with:

```text
<name> стає <expression>
```

Example:

```text
число стає число додати 5
```

## `став` versus `стає`

These are separate language tokens.

Correct:

```text
мінливе число став 10
число стає 20
```

Incorrect declaration:

```text
мінливе число стає 10
```

This produces the parser error:

```text
DeclarationRequiresBecame
```

Incorrect reassignment:

```text
число став 20
```

This produces:

```text
BecameOnlyForDeclaration
```

The similarity between the two forms is intentional.

## Duplicate declarations

Declaring a name that already exists in the same scope produces:

```text
VariableAlreadyExists
```

## Unknown variables

Reading or assigning an unknown name produces:

```text
UnknownVariable
```

## Runtime value kinds

### Integer

Integers are currently represented as signed 64-bit values.

```text
мінливе число став 42
```

### String

```text
мінливе назва став "Україна"
```

Strings currently reference text from the original source buffer.

### Boolean

The two boolean literals are:

```text
авжеж
ані
```

They correspond to true and false.

## Variable types

The current language does not have explicit source-level type annotations.

Type checks happen dynamically in the interpreter.

A future release may add a static type system.
