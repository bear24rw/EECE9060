import sys
import constants

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

    labels = {}
    jumps = []

    for _ in range(constants.reset_vector):
        bytes.append(0)

    for line in asm_file:

        line = line.upper().strip()

        if ';' in line:
            line = line[:line.find(';')]
            continue

        if ":" in line:
            labels[line.replace(':','')] = len(bytes)
            continue

        if line == 'HALT':
            bytes.append(constants.op_codes[line])
            bytes.append(0)
            bytes.append(0)
            bytes.append(0)
            continue

        op, args = line.split()

        bytes.append(constants.op_codes[op])

        if op in ('JMP'):
            jumps.append({'addr': len(bytes), 'label': args})
            bytes.append(0)
            bytes.append(0)
            bytes.append(0)
            continue

        args = [int(x) for x in args.split(",")]

        if op in ('LD', 'ST'):
            d, addr = args
            bytes.append(d)
            bytes.append(h_byte(addr))
            bytes.append(l_byte(addr))
            continue

        if op in ('LDI'):
            d, value = args
            bytes.append(d)
            bytes.append(value)
            bytes.append(0)
            continue

        if op in ('MOV'):
            d, a = args
            bytes.append(d)
            bytes.append(a)
            bytes.append(0)
            continue

        d, a, b = args
        bytes.append(d)
        bytes.append(a)
        bytes.append(b)

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

