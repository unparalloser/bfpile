type Emitter = ref object of RootObj

method writeHeader(this: Emitter) {.base.} = discard
method writeInstruction(this: Emitter, instr: Instruction, i: var int) {.base.} = discard
method writeBody(this: Emitter, instructions: seq[Instruction]) {.base.} =
  var i = 0
  while i < len(instructions):
    this.writeInstruction(instructions[i], i)
    i += 1
method writeFooter(this: Emitter) {.base.} = discard

method write(this: Emitter, instructions: seq[Instruction]) {.base.} =
  this.writeHeader()
  this.writeBody(instructions)
  this.writeFooter()
