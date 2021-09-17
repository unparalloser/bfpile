# Compile, transpile and interpret Brainfuck with bfpile!

This project was created by [Tanya Nevskaya](https://github.com/unparalloser) with the guidance and help of [Yana Timoshenko](https://github.com/abelianring) <3

All Brainfuck commands are optimized in bfpile, meaning if the same Brainfuck command is repeated more than once, only one instruction will be passed to an apropriate emitter.

## How to build

This project can be built with [Nimble](https://github.com/nim-lang/nimble) that comes with [Nim](https://nim-lang.org). Just run `nimble build`.

## How to use

### Compilation

To compile Brainfuck to a desired target, enter:

`bfpile -t TARGET filename.bf`

or

`bfpile --target TARGET filename.bf`

Supported compiler targets:

| Target          | Description
|-----------------|------------
| `aarch64-linux` | Linux AArch64 (Arm 64-bit)
| `riscv64-linux` | Linux RISC-V 64-bit
| `wasm32-wasi`   | WebAssembly System Interface (WASI)
| `x86_64-linux`  | Linux x86-64 (AMD64)

### Transpilation

To transpile Brainfuck to a desired language, enter:

`bfpile -l LANGUAGE filename.bf`

or

`bfpile --lang LANGUAGE filename.bf`

Supported transpiler languages:

| Language | Description
|----------|------------
| `c`      | C

Rust and Zig are currently in development!

### Interpretation

To interpret Brainfuck, enter:

`bfpile -i filename.bf`

If no option is provided, bfpile defaults to compiling to Linux x86-64.

## Tests

You can run bfpile with any of the tests contained in `vendor` folder. `mandelbrot.bf` is mainly used for benchmarking.

## Contributing

All contributions are very welcome! Found a confusing comment? Know a better way to write some part of the program? Want to submit an additional emmiter? Feel free to create issues and pull requests to [bfpile repository](https://github.com/unparalloser/bfpile)!
