# Grammar Reference — 0.0.2

This is the implemented grammar in compact EBNF-like notation.

```text
program := newline* statement* EOF

statement :=
      variable-declaration
    | assignment
    | print-statement
    | expression-statement
    | if-statement
    | while-statement
    | for-statement
    | switch-statement
    | function-declaration
    | return-statement
    | break-statement
    | continue-statement

variable-declaration :=
    "мінливе" identifier "став" expression line-end

assignment :=
    identifier "стає" expression line-end

print-statement :=
    "вивести" "(" argument-list? ")" line-end

expression-statement :=
    call-expression line-end

if-statement :=
    "позаяк" expression block
    ("одначе" "позаяк" expression block)*
    ("одначе" block)?

while-statement :=
    "допоки" expression block

for-statement :=
    "перебрати" identifier "від" expression "до" expression block

switch-statement :=
    "розсуд" expression newline* "зачин" newline*
    switch-case*
    default-case?
    "край"

switch-case :=
    "нагода" expression block newline*

default-case :=
    "решта" block newline*

function-declaration :=
    "чин" identifier "бере" parameter-list? block

parameter-list :=
    identifier ("," identifier)*

return-statement :=
    "віддати" expression? line-end

break-statement :=
    "перервати" line-end

continue-statement :=
    "далі" line-end

block :=
    newline* "зачин" newline* statement* "край"

argument-list :=
    expression ("," expression)*

expression := or-expression
or-expression := and-expression ("або" and-expression)*
and-expression := equality-expression ("і" equality-expression)*
equality-expression := comparison-expression (("дорівнює" | "недорівнює") comparison-expression)*
comparison-expression := additive-expression (("перевищує" | "менше" | "щонайменше" | "щонайбільше") additive-expression)*
additive-expression := multiplicative-expression (("додати" | "відняти") multiplicative-expression)*
multiplicative-expression := unary-expression (("помножити" | "поділити" | "остача") unary-expression)*
unary-expression := "не" unary-expression | primary

primary :=
      integer
    | string
    | "авжеж"
    | "ані"
    | identifier
    | call-expression
    | "(" expression ")"

call-expression :=
    "вжити" identifier "з" argument-list?
```

`line-end` is a newline, EOF, or a block boundary accepted by the parser.
