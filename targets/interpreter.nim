import os
import terminal

type Interpreter = ref object of Target

var cells: array[30000, int]
var cells_i = 0

method emit(this: Interpreter, instr: Instruction, i: var int) =
  let c = instr.command
  case c:
    of MoveRight:
      cells_i += instr.times
    of MoveLeft:
      cells_i -= instr.times
    of Add:
      cells[cells_i] += instr.times
    of Sub:
      cells[cells_i] -= instr.times
    of Write:
      for n in 1..instr.times:
        stdout.write(chr(cells[cells_i]))
    of Read:
      for n in 1..instr.times:
        cells[cells_i] = ord(getch())
    of LoopStart:
      if cells[cells_i] == 0:
        i = instr.index
    of LoopEnd:
      if cells[cells_i] != 0:
        i = instr.index
