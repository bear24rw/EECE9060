import sys
import constants

def bits(number, byte_num=0):
    number = int(number)
    number = number >> (8*byte_num)
    s = bin(number)[2:].zfill(8)[-8:]
    return s

if __name__ == "__main__":

    asm_filename = sys.argv[1]
    rom_filename = sys.argv[1].replace("asm", "rom")
    txt_filename = sys.argv[1].replace("asm", "txt")

    asm_file = open(asm_filename)
    rom_file = open(rom_filename, 'wb')
    txt_file = open(txt_filename, 'w')

    num_bytes = 0

    labels = {}

    def write_byte(x):
        global num_bytes
        txt_file.write(x+'\n')
        rom_file.write(chr(eval('0b'+x)))
        num_bytes += 1

    for _ in range(constants.reset_vector):
        write_byte(bits(0))

    for line in asm_file:

        line = line.upper().strip()

        if ';' in line:
            line = line[:line.find(';')]
            continue

        if ":" in line:
            labels[line.replace(':','')] = num_bytes
            continue

        if line == 'HALT':
            write_byte(bits(constants.op_codes[line]))
            write_byte(bits(0))
            write_byte(bits(0))
            write_byte(bits(0))
            continue

        op, args = line.split()

        write_byte(bits(constants.op_codes[op]))

        if op in ('JMP'):
            write_byte(bits(labels[args], 1))
            write_byte(bits(labels[args], 0))
            write_byte(bits(0))
            continue

        if op in ('LD', 'ST'):
            d, addr = args.split(',')
            write_byte(bits(d))
            write_byte(bits(addr, 1))
            write_byte(bits(addr, 0))
            continue

        if op in ('LDI'):
            d, addr = args.split(',')
            write_byte(bits(d))
            write_byte(bits(addr))
            write_byte(bits(0))
            continue

        if op in ('MOV'):
            d, a = args.split(',')
            write_byte(bits(d))
            write_byte(bits(a))
            write_byte(bits(0))
            continue

        d, a, b = args.split(',')
        write_byte(bits(d))
        write_byte(bits(a))
        write_byte(bits(b))

    for _ in range(constants.ram_size - num_bytes):
        write_byte(bits(0))
