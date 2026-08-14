# Expressions and Operators

Expressions produce runtime values.

Compiler version `0.0.2` also allows function calls as expressions.

## Arithmetic

| Operator | Meaning | Conventional equivalent |
|---|---|---|
| `додати` | addition | `+` |
| `відняти` | subtraction | `-` |
| `помножити` | multiplication | `*` |
| `поділити` | integer division | `/` |
| `остача` | remainder | `%` |

Examples:

```text
10 додати 5
20 відняти 3
4 помножити 8
20 поділити 4
17 остача 5
```

Arithmetic requires integer operands.

## Equality

```text
дорівнює
недорівнює
```

Examples:

```text
число дорівнює 10
готово недорівнює ані
```

## Ordering

| Operator | Conventional equivalent |
|---|---|
| `перевищує` | `>` |
| `менше` | `<` |
| `щонайменше` | `>=` |
| `щонайбільше` | `<=` |

Ordering currently requires integer operands.

## Boolean logic

```text
і
або
не
```

Example:

```text
готово і не вимкнено
```

`і` and `або` are evaluated with short-circuit behavior in version `0.0.2`.

## Function call expressions

```text
вжити <function-name> з <arguments>
```

Example:

```text
вжити додати з 2, 3
```

A call may appear inside a larger expression:

```text
вжити додати з 2, 3 помножити 4
```

The exact grouping follows normal expression precedence.

## Parentheses

Parentheses group expressions:

```text
(2 додати 3) помножити 4
```

## Precedence

Highest to lowest:

1. primary expressions and grouped expressions
2. `не`
3. `помножити`, `поділити`, `остача`
4. `додати`, `відняти`
5. `перевищує`, `менше`, `щонайменше`, `щонайбільше`
6. `дорівнює`, `недорівнює`
7. `і`
8. `або`

Therefore:

```text
2 додати 3 помножити 4
```

is parsed as:

```text
2 додати (3 помножити 4)
```

## Division by zero

Division or remainder by zero produces `DivisionByZero`.
