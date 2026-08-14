# Interpreter

The interpreter lives in `src/interpreter.zig`.

Variables are stored in a `StringHashMap(Value)`.

`Value` currently supports:

```text
integer
string
boolean
```

The interpreter recursively evaluates expression nodes and executes nested statement blocks.
