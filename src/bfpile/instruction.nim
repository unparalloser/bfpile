import command

type Instruction* = ref object
  case command*: Command
    of LoopStart, LoopEnd: i*: int
    else: n*: int

func parse(commands: seq[Command]): seq[Instruction] =
  var loopMatches: seq[Instruction]
  var n = 1

  for i, cmd in commands:
    # add the let binding because nim is silly
    # TODO: report the bug to nim later
    let cmd = cmd
    case cmd:
      of LoopStart, LoopEnd:
        let instruction = Instruction(command: cmd, i: result.len)
        result.add(instruction)
        if cmd == LoopStart:
          loopMatches.add(instruction)
        else:
          swap(instruction.i, loopMatches.pop.i)
      else:
        if i == commands.len - 1 or cmd != commands[i + 1]:
          result.add(Instruction(command: cmd, n: n))
          n = 1
        else:
          n += 1

export parse
