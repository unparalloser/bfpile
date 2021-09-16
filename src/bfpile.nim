import options
import parseopt
import streams
import strformat
import strutils

include "help.nimf"
include "command.nim"
include "instruction.nim"
include "emitter.nim"

include "emitters/interpreter.nim"
include "emitters/compilers/arm.nimf"
include "emitters/compilers/riscv.nimf"
include "emitters/compilers/wasm.nimf"
include "emitters/compilers/x86.nimf"
include "emitters/transpilers/c.nimf"

# TODO: automatically make the user's current platform the default target
var emitter: Emitter = X86()
var filenames: seq[string]
var optParser = initOptParser(shortNoVal = {'h', 'i'}, longNoVal = @["help"])

for kind, key, val in optParser.getopt():
  case kind
    of cmdArgument:
      filenames.add(key)
    of cmdLongOption, cmdShortOption:
      let val = toLowerAscii(val)
      case key
        of "h", "help":
          printHelp()
          quit(64) # sysexits(3) EX_USAGE
        of "i":
          emitter = Interpreter()
        of "l", "lang", "language":
          emitter = case val:
            of "c": C()
            else: raise newException(ValueError, fmt"unknown language: {val}")
        of "t", "target":
          emitter = case val:
            of "aarch64-linux": Arm()
            of "riscv64-linux": RiscV()
            of "wasm32-wasi": Wasm()
            of "x86_64-linux": X86()
            else: raise newException(ValueError, fmt"unknown target: {val}")
        else: stderr.writeLine fmt"Warning: unknown option: {key}"
    of cmdEnd: discard

if filenames.len == 0:
  printHelp()

# TODO: reset the emitter for Interpreter() before each iteration
for f in filenames:
  emitter.write(parse(tokenize(newFileStream(f))))
