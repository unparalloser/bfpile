import std/enumerate
import std/os
import std/strformat
import std/tables

let code = readFile(paramStr(1))

var loops = initTable[int, int]()
var loop_matches: seq[int]
for i, c in enumerate(code):
  if c == '[':
    loop_matches.add(i)
  elif c == ']':
    let loop_start_i = loop_matches.pop()
    loops[i] = loop_start_i
    loops[loop_start_i] = i

echo """
  .data
  cells:
    .space 30000

  .text
  main:
    la s0, cells
"""

for i, c in code:
  case c:
    of '>':
      echo """
        addi s0, s0, 1   # move the pointer 1 cell to the right
      """
    of '<':
      echo """
        addi s0, s0, -1  # move the pointer 1 cell to the left
      """
    of '+':
      echo """
        lbu s1, (s0)     # put the first byte at the pointer into s1 register
        addi s1, s1, 1   # add 1 to the byte
        sb s1, (s0)      # write the changes back into the cell
      """
    of '-':
      echo """
        lbu s1, (s0)
        addi s1, s1, -1
        sb s1, (s0)
      """
    of '.':
      echo """
        lbu a0, (s0)
        li a7, 11        # put the function 'write'(11) into a7 register
        ecall            # execute it
      """
    of ',':
      echo """
        li a7, 12        # put the function 'read' (12) into a7 register
        ecall            # execute it, storing the result in a0 register
        sb a0, (s0)
      """
    of '[':
      echo fmt"""
        loop_{i}:                   # custom label to indicate the start of a loop
          lbu s1, (s0)
          beqz s1, loop_{loops[i]}  # if s1 == 0, jump to the label corresponding to the end of the loop
      """
    of ']':
      echo fmt"""
        loop_{i}:
          lbu s1, (s0)
          bnez s1, loop_{loops[i]}  # if s1 != 0, jump to the label corresponding to the start of the loop
      """
    else: discard
