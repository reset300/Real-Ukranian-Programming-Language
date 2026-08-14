# Getting Started

## Build the compiler

```text
zig build
```

On Windows the executable is installed as:

```text
zig-out\\bin\\compiler.exe
```

## Run a source file

```text
compiler program.ukr
```

## First program

```text
вивести("Привіт")
```

## Variable

```text
мінливе число стає 10
вивести(число)
```

## Conditional

```text
мінливе число стає 15

позаяк число перевищує 10
зачин
    вивести("велике")
край
одначе
зачин
    вивести("мале")
край
```

## Loop

```text
мінливе число стає 0

допоки число менше 5
зачин
    вивести(число)
    число стає число додати 1
край
```
