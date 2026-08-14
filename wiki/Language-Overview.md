# Language Overview

The language uses UTF-8 `.ukr` source files, significant newlines, word operators, and explicit word-delimited blocks.

## Blocks

```text
зачин
    ...
край
```

There are no C-style braces.

## Variables

```text
мінливе число став 10
число стає 11
```

## Values

The current runtime supports integers, strings, booleans, and an internal empty function result.

Boolean literals are:

```text
авжеж
ані
```

## Control flow

```text
позаяк ...
одначе позаяк ...
одначе ...
допоки ...
перебрати ... від ... до ...
розсуд ...
```

## Functions

```text
чин ім'я бере параметр, параметр
зачин
    віддати значення
край
```

Calls use:

```text
вжити ім'я з аргумент, аргумент
```

## Compiler pipeline

```text
source → lexer → tokens → parser → AST → interpreter
```

See [[Compiler Architecture]] for details.
