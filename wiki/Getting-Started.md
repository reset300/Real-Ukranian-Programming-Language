# Getting Started

This page describes how to build compiler version `0.0.2` and run `.ukr` programs.

## Requirements

The compiler is written in Zig.

The project currently targets a Zig `0.17` development build. Using a substantially older Zig release may require API changes.

## Build

From the repository root:

```console
zig build
```

On Windows, the executable is produced at:

```text
zig-out\bin\compiler.exe
```

## UTF-8 in Windows Command Prompt

`.ukr` source files are UTF-8.

Classic `cmd.exe` may display Ukrainian output incorrectly unless its active code page is UTF-8.

Run:

```console
chcp 65001
```

Then execute the compiler.

## Check the compiler version

```console
compiler --version
```

Expected version:

```text
0.0.2
```

## Show command-line help

```console
compiler --help
```

## Run a source file

```console
compiler examples\basic.ukr
```

## First program

Create `hello.ukr`:

```text
вивести("Привіт")
```

Run:

```console
compiler hello.ukr
```

Expected output:

```text
Привіт
```

## Declare a variable

Version `0.0.2` deliberately distinguishes declaration from reassignment.

Declaration:

```text
мінливе число став 10
```

Reassignment:

```text
число стає 20
```

The one-letter difference is part of the language grammar.

## Function example

```text
чин додати бере ліве, праве
зачин
    віддати ліве додати праве
край

мінливе сума став вжити додати з 20, 22
вивести("сума:", сума)
```

Output:

```text
сума: 42
```

## Range loop

```text
перебрати число від 0 до 5
зачин
    вивести(число)
край
```

## Switch-like branching

```text
мінливе стан став 2

розсуд стан
зачин
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

Continue with [[Language Overview]].
