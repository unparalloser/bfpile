import parseopt, streams, strformat, strutils

import bfpile/command, bfpile/instruction, bfpile/emitter

const cellsLen = 30000

include "bfpile/help.nimf"

include "bfpile/emitters/interpreter.nim"
include "bfpile/emitters/compilers/arm.nimf"
include "bfpile/emitters/compilers/risc_v.nimf"
include "bfpile/emitters/compilers/wasm.nimf"
include "bfpile/emitters/compilers/x86.nimf"
include "bfpile/emitters/transpilers/c.nimf"
include "bfpile/emitters/transpilers/rust.nimf"
include "bfpile/emitters/transpilers/zig.nimf"

let emitterGenDefault = func: Emitter = X86()
var emitterGen = emitterGenDefault
var filenames: seq[string]
var optParser = initOptParser(shortNoVal = {'h', 'i'}, longNoVal = @["help"])

proc usageError(msg: string) {.noReturn.} =
  stderr.writeLine("Usage error. Consult --help to learn more!")
  raise newException(ValueError, msg)

proc usageWarning(msg: string) =
  stderr.writeLine("Warning: ", msg)

proc assertEmitterDefault =
  if emitterGen != emitterGenDefault:
    usageError("can do only one operation at a time (compile, interpret or transpile)")

for kind, key, val in optParser.getopt():
  case kind
    of cmdArgument:
      filenames.add(key)
    of cmdLongOption, cmdShortOption:
      let val = toLowerAscii(val)
      case key
        of "h", "help":
          printHelp()
          quit(64) # EX_USAGE
        of "i":
          assertEmitterDefault()
          emitterGen = func: Emitter = Interpreter()
        of "l", "lang", "language":
          assertEmitterDefault()
          emitterGen = case val:
            of "c": (func: Emitter = C())
            of "rust": (func: Emitter = Rust())
            of "zig": (func: Emitter = Zig())
            else: usageError(fmt"unknown language: {val}")
        of "t", "target":
          assertEmitterDefault()
          emitterGen = case val:
            of "aarch64-linux": (func: Emitter = Arm())
            of "riscv64-linux": (func: Emitter = RiscV())
            of "wasm32-wasi": (func: Emitter = Wasm())
            of "x86_64-linux": (func: Emitter = X86())
            else: usageError(fmt"unknown target: {val}")
        else: usageWarning(fmt"unknown option: {key}")
    of cmdEnd: discard

if filenames.len == 0:
  printHelp()

for f in filenames:
  emitterGen().write(parse(tokenize(openFileStream(f))))
