let
  nixpkgs = import <nixpkgs> {};
in

with nixpkgs;

mkShell {
  buildInputs = [
    nim
    qemu
    wasmtime
    zig
  ];
}
