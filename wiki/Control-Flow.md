# Control Flow

## Conditional

```text
позаяк число перевищує 10
зачин
    вивести("велике")
край
одначе позаяк число дорівнює 10
зачин
    вивести("десять")
край
одначе
зачин
    вивести("мале")
край
```

## While loop

```text
допоки число менше 10
зачин
    число стає число додати 1
край
```

## Range loop

```text
перебрати число від 0 до 10
зачин
    вивести(число)
край
```

Start is inclusive; end is exclusive. Only ascending integer ranges are implemented in 0.0.2.

## Break and continue

```text
перервати
далі
```

They operate on the nearest loop.

## Multi-way branch

```text
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

    решта
    зачин
        вивести("інше")
    край
край
```

There is no fallthrough.
