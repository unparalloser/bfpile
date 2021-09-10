import std/os
import std/strformat

type
  Command = enum
    MoveRight, MoveLeft, Add, Sub, Write, Read, LoopStart, LoopEnd

  Instruction = ref object
    case command: Command
      of LoopStart, LoopEnd: index: int
      else: times: int

var commands: seq[Command]

let code = readFile(paramStr(1))

for i, c in code:
  case c:
    of '>':
      commands.add(MoveRight)
    of '<':
      commands.add(MoveLeft)
    of '+':
      commands.add(Add)
    of '-':
      commands.add(Sub)
    of '.':
      commands.add(Write)
    of ',':
      commands.add(Read)
    of '[':
      commands.add(LoopStart)
    of ']':
      commands.add(LoopEnd)
    else: discard

var instructions: seq[Instruction]

var times_acc = 1
var loop_matches: seq[Instruction]

for i, c in commands:
  # add the let binding because nim is silly (TODO: report the bug to nim later)
  let command = c
  case command:
    of LoopStart:
      # the index added to LoopStart at this point is temporary, will be used for LoopEnd instead
      let instruction = Instruction(command: command, index: instructions.len)
      instructions.add(instruction)
      loop_matches.add(instruction)
    of LoopEnd:
      let loop_start = loop_matches.pop
      instructions.add(Instruction(command: command, index: loop_start.index))
      # here the index of the LoopStart is updated to point to the end of the loop
      loop_start.index = instructions.len - 1
    else:
      if i == commands.len - 1 or c != commands[i + 1]:
        instructions.add(Instruction(command: command, times: times_acc))
        times_acc = 1
      else:
        times_acc += 1

echo """
  .data
  cells:
    .space 30000

  .text
  main:
    la s0, cells
"""

for i, c in instructions:
  case c.command:
    of MoveRight:
      echo fmt"""
        addi s0, s0, {c.times}   # move the pointer c.times cells to the right
      """
    of MoveLeft:
      echo fmt"""
        addi s0, s0, {-c.times}  # move the pointer c.times cells to the left
      """
    of Add:
      echo fmt"""
        lbu s1, (s0)             # put the first byte at the pointer into s1 register
        addi s1, s1, {c.times}   # add c.times to the byte
        sb s1, (s0)              # write the changes back into the cell
      """
    of Sub:
      echo fmt"""
        lbu s1, (s0)
        addi s1, s1, {-c.times}
        sb s1, (s0)
      """
    of Write:
      echo """
        lbu a0, (s0)
        li a7, 11                # put the function 'write'(11) into a7 register
      """
      for i in 1..c.times:
        echo "ecall"             # execute it c.times
    of Read:
      echo "li a7, 12"           # put the function 'read' (12) into a7 register
      for i in 1..c.times:
        echo "ecall"             # execute it c.times, storing the intermediate result in a0 register
      echo "sb a0, (s0)"
    of LoopStart:
      echo fmt"""
        loop_{i}:                   # custom label to indicate the start of a loop
          lbu s1, (s0)
          beqz s1, loop_{c.index}  # if s1 == 0, jump to the label corresponding to the end of the loop
      """
    of LoopEnd:
      echo fmt"""
        loop_{i}:
          lbu s1, (s0)
          bnez s1, loop_{c.index}  # if s1 != 0, jump to the label corresponding to the start of the loop
      """
