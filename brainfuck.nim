import std/enumerate
import std/tables
import std/terminal
import std/os

let code = readFile(paramStr(1))

var cells: array[30000, int]
var cells_i = 0
var code_i = 0

var loops = initTable[int, int]()
var loop_matches: seq[int]
for i, c in enumerate(code):
  if c == '[':
    loop_matches.add(i)
  elif c == ']':
    let loop_start_i = loop_matches.pop()
    loops[i] = loop_start_i
    loops[loop_start_i] = i

while code_i < len(code):
  var c = code[code_i]
  case c:
    of '>':
      cells_i += 1
    of '<':
      cells_i -= 1
    of '+':
      cells[cells_i] += 1
    of '-':
      cells[cells_i] -= 1
    of '.':
      stdout.write(chr(cells[cells_i]))
    of ',':
      cells[cells_i] = ord(getch())
    of '[':
      if cells[cells_i] == 0:
        code_i = loops[code_i]
    of ']':
      if cells[cells_i] != 0:
        code_i = loops[code_i]
    else: discard
  code_i += 1
