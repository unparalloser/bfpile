type Command = enum
  MoveRight, MoveLeft, Add, Sub, Write, Read, LoopStart, LoopEnd

const bufferLen = 4096

proc tokenize(code: Stream): seq[Command] =
  var buffer: array[bufferLen, char]

  while not code.atEnd():
    let readLen = code.readData(addr(buffer), bufferLen)

    for c in buffer[0..readLen-1]:
      let cmd = case c:
        of '>': some(MoveRight)
        of '<': some(MoveLeft)
        of '+': some(Add)
        of '-': some(Sub)
        of '.': some(Write)
        of ',': some(Read)
        of '[': some(LoopStart)
        of ']': some(LoopEnd)
        else: none(Command)

      if cmd.isSome:
        result.add(cmd.get)
