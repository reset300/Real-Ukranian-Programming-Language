# Real Ukrainian Programming Language

Experimental Ukrainian programming language and interpreter written in Zig.

Current compiler version: **0.0.2**.

```text
мінливе число став 10

позаяк число перевищує 5
зачин
    вивести("число:", число)
край
```

The language deliberately avoids C-style braces and symbolic operators. Blocks use `зачин` / `край`, declarations use `став`, reassignment uses `стає`, and most operators are Ukrainian words.

Documentation is available in [`docs/`](docs/index.md). GitHub Wiki-ready copies live in [`wiki/`](wiki/Home.md).

## Build

```console
zig build
```

## Run

```console
compiler examples/basic.ukr
```

On classic Windows Command Prompt, enable UTF-8 first:

```console
chcp 65001
```

## CLI

```console
compiler --version
compiler --help
compiler --tokens examples/basic.ukr
```
