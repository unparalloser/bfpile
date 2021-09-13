let
  nixpkgs = import <nixpkgs> {};
in

with nixpkgs;

mkShell {
  buildInputs = [
    qemu
    wasmtime
    zig
  ];
}
