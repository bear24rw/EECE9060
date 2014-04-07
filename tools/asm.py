#!/usr/bin/env python

import sys
import constants
import re

def bits(number):
    return bin(number)[2:].zfill(8)

def h_byte(x):
    return x >> 8

def l_byte (x):
    return x & 0x00FF

if __name__ == "__main__":

    asm_filename = sys.argv[1]
    rom_filename = sys.argv[1].replace("asm", "rom")
    txt_filename = sys.argv[1].replace("asm", "txt")

    asm_file = open(asm_filename)
    rom_file = open(rom_filename, 'wb')
    txt_file = open(txt_filename, 'w')

    bytes = []

    defines = {}
    labels = {}
    jumps = []

    #
    # Pad up until the reset vector
    #
    for _ in range(constants.reset_vector):
        bytes.append(0)

    #
    # Fill out instruction bytes
    #
    for line in asm_file:

        line = line.upper().strip()

        if ';' in line:
            line = line[:line.find(';')].strip()

        if len(line) == 0: continue

        if line.startswith(".DEFINE"):
            _, original, new = line.split()
            defines[original] = new
            continue

        for word in defines:
            line = line.replace(word, defines[word])

        if ":" in line:
            name = line.replace(':','')
            if name in labels:
                print "Duplicate label: " + name
                sys.exit(1)
            labels[name] = len(bytes)
            continue

        if line == 'HALT':
            bytes.append(constants.op_codes[line])
            bytes.append(0)
            bytes.append(0)
            bytes.append(0)
            continue

        op, args = line.split(' ', 1)

        bytes.append(constants.op_codes[op])

        if op in ('JMP'):
            jumps.append({'addr': len(bytes), 'label': args})
            bytes.append(0)
            bytes.append(0)
            bytes.append(0)
            continue

        args = [x.strip() for x in args.split(",")]

        # remove the R off the register names (R5 -> 5)
        args = [re.sub(r'R(\d+)', r'\1', x) for x in args]

        for i, arg in enumerate(args):
            if arg in constants.address_names:
                args[i] = constants.address_names[arg]

        if op in ('BRZ', 'BRNZ'):
            jumps.append({'addr': len(bytes)+1, 'label': args[1]})
            bytes.append(int(args[0]))
            bytes.append(0)
            bytes.append(0)
            continue

        # convert strings of decimal, hex, or binary to ints
        for i, arg in enumerate(args):
            if not isinstance(arg, int):
                args[i] = eval(arg)

        if op in ('LD', 'ST', 'STL'):
            d, addr = args
            bytes.append(d)
            bytes.append(h_byte(addr))
            bytes.append(l_byte(addr))
            continue

        if op in ('LDL'):
            d, value = args
            bytes.append(d)
            bytes.append(value)
            bytes.append(0)
            continue

        if op in ('MOV', 'INV'):
            d, a = args
            bytes.append(d)
            bytes.append(a)
            bytes.append(0)
            continue

        if op in ('INC', 'DEC'):
            bytes.append(args[0])
            bytes.append(0)
            bytes.append(0)
            continue

        d, a, b = args
        bytes.append(d)
        bytes.append(a)
        bytes.append(b)

    #
    # Pad the rest of the rom with 0s
    #
    for _ in range(constants.ram_size - len(bytes)):
        bytes.append(0)

    #
    # Go through all the jump instructions and fill out the address
    #
    for jump in jumps:
        bytes[jump['addr']+0] = h_byte(labels[jump['label']])
        bytes[jump['addr']+1] = l_byte(labels[jump['label']])

    #
    # Write all bytes out
    #
    for byte in bytes:
        txt_file.write(bits(byte)+'\n')
        rom_file.write(chr(byte))

