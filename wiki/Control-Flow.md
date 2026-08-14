# Control Flow

Compiler version `0.0.2` supports conditionals, while-style loops, range loops, loop control, and switch-like branching.

## Conditional: `позаяк`

```text
позаяк <condition>
зачин
    <statements>
край
```

Example:

```text
позаяк число перевищує 10
зачин
    вивести("велике")
край
```

The condition must evaluate to a boolean.

## Else-if: `одначе позаяк`

```text
позаяк число перевищує 10
зачин
    вивести("велике")
край
одначе позаяк число дорівнює 10
зачин
    вивести("десять")
край
```

Any number of `одначе позаяк` branches may be used.

## Else: `одначе`

```text
позаяк готово
зачин
    вивести("так")
край
одначе
зачин
    вивести("ні")
край
```

## While-style loop: `допоки`

```text
мінливе число став 0

допоки число менше 5
зачин
    вивести(число)
    число стає число додати 1
край
```

## Range loop: `перебрати`

Syntax:

```text
перебрати <name> від <start-expression> до <end-expression>
зачин
    <statements>
край
```

Example:

```text
перебрати число від 0 до 10
зачин
    вивести(число)
край
```

The loop introduces its iteration variable inside the loop scope.

## Continue: `далі`

`далі` skips the rest of the current loop iteration.

```text
перебрати число від 0 до 10
зачин
    позаяк число дорівнює 3
    зачин
        далі
    край

    вивести(число)
край
```

## Break: `перервати`

`перервати` exits the nearest active loop.

```text
перебрати число від 0 до 10
зачин
    позаяк число дорівнює 8
    зачин
        перервати
    край

    вивести(число)
край
```

## Switch-like branching: `розсуд`

```text
розсуд <expression>
зачин
    нагода <expression>
    зачин
        <statements>
    край

    решта
    зачин
        <statements>
    край
край
```

Example:

```text
мінливе стан став 2

розсуд стан
зачин
    нагода 0
    зачин
        вивести("нуль")
    край

    нагода 1
    зачин
        вивести("один")
    край

    нагода 2
    зачин
        вивести("два")
    край

    решта
    зачин
        вивести("невідомо")
    край
край
```

Only one `решта` branch is permitted.

## Condition values

The interpreter does not use generic truthiness.

Conditions must evaluate to booleans. An integer or string used directly as a condition produces `ExpectedBoolean`.
