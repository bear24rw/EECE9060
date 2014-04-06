import sys
import constants

def bits(number):
    return bin(number)[2:].zfill(8)

if __name__ == "__main__":

    asm_filename = sys.argv[1]
    rom_filename = sys.argv[1].replace("asm", "rom")
    txt_filename = sys.argv[1].replace("asm", "txt")

    asm_file = open(asm_filename)
    rom_file = open(rom_filename, 'wb')
    txt_file = open(txt_filename, 'w')

    bytes = []

    labels = {}

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
            bytes.append(labels[args] >> 8)
            bytes.append(labels[args])
            bytes.append(0)
            continue

        args = [int(x) for x in args.split(",")]

        if op in ('LD', 'ST'):
            d, addr = args
            bytes.append(d)
            bytes.append(addr >> 8)
            bytes.append(addr)
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
    # Write all bytes out
    #

    for byte in bytes:
        txt_file.write(bits(byte)+'\n')
        rom_file.write(chr(byte))

