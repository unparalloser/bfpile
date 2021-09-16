type Instruction = ref object
  case command: Command
    of LoopStart, LoopEnd: i: int
    else: n: int

func parse(commands: seq[Command]): seq[Instruction] =
  var instructions: seq[Instruction]
  var loopMatches: seq[Instruction]
  var n = 1

  for i, c in commands:
    # add the let binding because nim is silly
    # TODO: report the bug to nim later
    let c = c
    case c:
      of LoopStart, LoopEnd:
        let instruction = Instruction(command: c, i: instructions.len)
        instructions.add(instruction)
        if c == LoopStart:
          loopMatches.add(instruction)
        else:
          swap(instruction.i, loopMatches.pop.i)
      else:
        if i == commands.len - 1 or c != commands[i + 1]:
          instructions.add(Instruction(command: c, n: n))
          n = 1
        else:
          n += 1

  return instructions
