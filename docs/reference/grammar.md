# Grammar Reference

This is the grammar implemented by the current parser.

- `A | B` means A or B.
- `X*` means zero or more X.
- `X?` means optional X.
- quoted text is a literal token.

```text
program := newline* statement* EOF

statement :=
      variable-declaration
    | assignment
    | print-statement
    | if-statement
    | while-statement

variable-declaration :=
    "мінливе" identifier "стає" expression line-end

assignment :=
    identifier "стає" expression line-end

print-statement :=
    "вивести" "(" argument-list? ")" line-end

argument-list :=
    expression ("," expression)*

if-statement :=
    "позаяк" expression block
    ("одначе" "позаяк" expression block)*
    ("одначе" block)?

while-statement :=
    "допоки" expression block

block :=
    newline*
    "зачин"
    newline*
    statement*
    "край"

expression := or-expression
or-expression := and-expression ("або" and-expression)*
and-expression := equality-expression ("і" equality-expression)*
equality-expression := comparison-expression (("дорівнює" | "недорівнює") comparison-expression)*
comparison-expression := additive-expression (("перевищує" | "менше" | "щонайменше" | "щонайбільше") additive-expression)*
additive-expression := multiplicative-expression (("додати" | "відняти") multiplicative-expression)*
multiplicative-expression := unary-expression (("помножити" | "поділити" | "остача") unary-expression)*
unary-expression := "не" unary-expression | primary
primary := integer | string | "авжеж" | "ані" | identifier | "(" expression ")"
```
