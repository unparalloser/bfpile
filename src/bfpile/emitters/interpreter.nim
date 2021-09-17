type Interpreter = ref object of Emitter
  cells: array[cellsLen, int]
  i: int

method writeInstruction(self: Interpreter, instr: Instruction, i: var int) =
  case instr.command:
    of MoveRight:
      self.i += instr.n
    of MoveLeft:
      self.i -= instr.n
    of Add:
      self.cells[self.i] += instr.n
    of Sub:
      self.cells[self.i] -= instr.n
    of Write:
      for n in 1..instr.n:
        stdout.write(chr(self.cells[self.i]))
    of Read:
      for n in 1..instr.n:
        self.cells[self.i] = ord(stdin.readChar)
    of LoopStart:
      if self.cells[self.i] == 0:
        i = instr.i
    of LoopEnd:
      if self.cells[self.i] != 0:
        i = instr.i
