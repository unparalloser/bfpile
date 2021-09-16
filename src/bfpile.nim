import options
import parseopt
import streams
import strformat
import strutils

include "help.nimf"
include "command.nim"
include "instruction.nim"
include "emitter.nim"

const cellsLen = 30000

include "emitters/interpreter.nim"
include "emitters/compilers/arm.nimf"
include "emitters/compilers/risc_v.nimf"
include "emitters/compilers/wasm.nimf"
include "emitters/compilers/x86.nimf"
include "emitters/transpilers/c.nimf"

# TODO: automatically make the user's current platform the default target
let emitterDefault = func: Emitter = X86()
var emitter = emitterDefault
var filenames: seq[string]
var optParser = initOptParser(shortNoVal = {'h', 'i'}, longNoVal = @["help"])

proc usageError(msg: string) {.noReturn.} =
  stderr.writeLine("Usage error. Consult --help to learn more!")
  raise newException(ValueError, msg)

proc usageWarning(msg: string) =
  stderr.writeLine("Warning: ", msg)

proc assertEmitterDefault =
  if emitter != emitterDefault:
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
          emitter = func: Emitter = Interpreter()
        of "l", "lang", "language":
          assertEmitterDefault()
          emitter = case val:
            of "c": (func: Emitter = C())
            else: usageError(fmt"unknown language: {val}")
        of "t", "target":
          assertEmitterDefault()
          emitter = case val:
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
  emitter().write(parse(tokenize(openFileStream(f))))
