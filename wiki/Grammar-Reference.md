# Grammar Reference

This page documents parser syntax for compiler version `0.0.2`.

The notation is descriptive EBNF-like notation rather than a machine-readable grammar.

## Program

```text
program :=
    newline* statement* EOF
```

## Statements

```text
statement :=
      variable-declaration
    | assignment
    | print-statement
    | expression-statement
    | if-statement
    | while-statement
    | range-loop
    | switch-statement
    | function-declaration
    | return-statement
    | break-statement
    | continue-statement
```

## Variable declaration

```text
variable-declaration :=
    "мінливе" identifier "став" expression line-end
```

Using `стає` in this position is a dedicated syntax error.

## Assignment

```text
assignment :=
    identifier "стає" expression line-end
```

Using `став` after an existing identifier is a dedicated syntax error.

## Output

```text
print-statement :=
    "вивести" "(" argument-list? ")" line-end

argument-list :=
    expression ("," expression)*
```

## Expression statement

The currently supported expression statement begins with a function call:

```text
expression-statement :=
    call-expression line-end
```

## Conditional

```text
if-statement :=
    "позаяк" expression block
    ("одначе" "позаяк" expression block)*
    ("одначе" block)?
```

## While loop

```text
while-statement :=
    "допоки" expression block
```

## Range loop

```text
range-loop :=
    "перебрати" identifier
    "від" expression
    "до" expression
    block
```

## Break and continue

```text
break-statement :=
    "перервати" line-end

continue-statement :=
    "далі" line-end
```

## Switch-like statement

```text
switch-statement :=
    "розсуд" expression
    "зачин"
    newline*
    switch-branch*
    "край"
```

```text
switch-branch :=
      "нагода" expression block
    | "решта" block
```

Only one `решта` branch is allowed.

## Function declaration

```text
function-declaration :=
    "чин" identifier
    "бере" parameter-list?
    block
```

```text
parameter-list :=
    identifier ("," identifier)*
```

## Return

```text
return-statement :=
    "віддати" expression? line-end
```

## Function call

```text
call-expression :=
    "вжити" identifier "з" call-arguments?
```

```text
call-arguments :=
    expression ("," expression)*
```

## Block

```text
block :=
    newline*
    "зачин"
    newline*
    statement*
    "край"
```

## Expressions

```text
expression :=
    or-expression
```

```text
or-expression :=
    and-expression
    ("або" and-expression)*
```

```text
and-expression :=
    equality-expression
    ("і" equality-expression)*
```

```text
equality-expression :=
    comparison-expression
    (("дорівнює" | "недорівнює") comparison-expression)*
```

```text
comparison-expression :=
    additive-expression
    (
        (
            "перевищує"
          | "менше"
          | "щонайменше"
          | "щонайбільше"
        )
        additive-expression
    )*
```

```text
additive-expression :=
    multiplicative-expression
    (("додати" | "відняти") multiplicative-expression)*
```

```text
multiplicative-expression :=
    unary-expression
    (
        (
            "помножити"
          | "поділити"
          | "остача"
        )
        unary-expression
    )*
```

```text
unary-expression :=
      "не" unary-expression
    | primary
```

```text
primary :=
      integer
    | string
    | "авжеж"
    | "ані"
    | identifier
    | call-expression
    | "(" expression ")"
```

## Current limitations

Version `0.0.2` does not yet define syntax for:

- explicit types
- arrays
- imports
- structs or records
- user-defined operators
- anonymous functions
- native modules
