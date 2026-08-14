# Getting Started

This page targets compiler **0.0.2**.

## Build

```console
zig build
```

The project currently targets Zig `0.17.0-dev.1552+79dc16a0e`.

## Windows UTF-8

Classic Command Prompt may need:

```console
chcp 65001
```

## First program

```text
вивести("Привіт")
```

Run:

```console
compiler hello.ukr
```

## Declaration versus reassignment

0.0.2 distinguishes these intentionally:

```text
мінливе число став 10
число стає 20
```

`став` creates the initial binding. `стає` changes an existing one.

## Function

```text
чин додати бере а, б
зачин
    віддати а додати б
край

мінливе результат став вжити додати з 2, 3
вивести(результат)
```

## Range loop

```text
перебрати число від 0 до 5
зачин
    вивести(число)
край
```

The upper bound is exclusive.

## CLI

```console
compiler --version
compiler --help
compiler --tokens program.ukr
```

Continue with [[Language Overview]].
