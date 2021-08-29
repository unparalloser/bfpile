#!/usr/bin/env python

from sys import argv
from getch import getch

def brainfuck(code):
    cells = [0] * 30000

    cells_i = 0
    code_i = 0
    loops = {}

    loop_matches = []
    for i, c in enumerate(code):
        if c == '[':
            loop_matches.append(i)
        elif c == ']':
            loop_start_i = loop_matches.pop()
            loops[i] = loop_start_i
            loops[loop_start_i] = i

    while code_i < len(code):
        c = code[code_i]
        if c == '>':
            cells_i += 1
        elif c == '<':
            cells_i -= 1
        elif c == '+':
            cells[cells_i] += 1
        elif c == '-':
            cells[cells_i] -= 1
        elif c == '.':
            print(chr(cells[cells_i]), end='')
        elif c == ',':
            cells[cells_i] = ord(getch())
        elif c == '[' and cells[cells_i] == 0:
            code_i = loops[code_i]
        elif c == ']' and cells[cells_i] != 0:
            code_i = loops[code_i]
        code_i += 1

if __name__ == '__main__':
    with open(argv[1], 'r') as f:
        code = f.read()
        brainfuck(code)
