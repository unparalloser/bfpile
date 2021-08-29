import sys
import getch

cells = [0] * 10000

f = open(sys.argv[1], 'r')
code = f.read()

pointer = 0
code_i = 0
brackets = {}

matching_queue = []
for i, c in enumerate(code):
    if c == '[':
        matching_queue.append(i)
    elif c == ']':
        opening_bracket = matching_queue.pop()
        brackets[i] = opening_bracket
        brackets[opening_bracket] = i

while code_i < len(code):
    c = code[code_i]
    if c == '>':
        pointer += 1
    elif c == '<':
        pointer -= 1
    elif c == '+':
        cells[pointer] += 1
    elif c == '-':
        cells[pointer] -= 1
    elif c == '.':
        print(chr(cells[pointer]), end='')
    elif c == ',':
        cells[pointer] = ord(getch.getch())
    elif c == '[' and cells[pointer] == 0:
        code_i = brackets[code_i]
    elif c == ']' and cells[pointer] != 0:
        code_i = brackets[code_i]
    code_i += 1
