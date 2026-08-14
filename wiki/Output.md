# Output

`вивести` prints one or more evaluated expressions.

## Syntax

```text
вивести(<arguments>)
```

Arguments are comma-separated expressions.

## One value

```text
вивести("Привіт")
```

Output:

```text
Привіт
```

## Multiple values

```text
мінливе число став 10
вивести("число:", число)
```

Output:

```text
число: 10
```

The interpreter inserts one space between arguments and a newline after the call.

## Function calls as output arguments

Because calls are expressions, this is valid:

```text
вивести("сума:", вжити додати з 20, 22)
```

## Supported runtime values

Current printable values:

- integers
- strings
- booleans
