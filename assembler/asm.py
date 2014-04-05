import sys

op_codes = {
    'HALT': 0,
    'LD': 1,
    'ST': 2,
    'LDI': 3,
    'MOV': 4,
    'ADD': 5,
    'SUB': 6,
    'AND': 7,
    'OR': 8,
    'XOR': 9,
    'ROTL': 10,
    'ROTR': 11,
    'JMP': 12,
}

def bits(number, byte_num=0):
    byte_num += 1
    number = int(number)
    s = bin(number)[2:]
    s = s.zfill(8*byte_num)
    return s[-8*byte_num:len(s)-8*byte_num+8]

if __name__ == "__main__":

    asm_filename = sys.argv[1]
    rom_filename = sys.argv[1].replace("asm", "rom")

    asm_file = open(asm_filename)
    rom_file = open(rom_filename, 'w')

    num_bytes = 0

    def write_byte(x):
        global num_bytes
        rom_file.write(x+'\n')
        num_bytes += 1

    for line in asm_file:
        line = line.upper().strip()

        if line == 'HALT':
            write_byte(bits(op_codes[line]))
            write_byte(bits(0))
            write_byte(bits(0))
            write_byte(bits(0))
            continue

        op, args = line.split()

        write_byte(bits(op_codes[op]))

        if op in ('JMP'):
            write_byte(bits(args, 1))
            write_byte(bits(args, 0))
            write_byte(bits(0))
            continue

        if op in ('LDI', 'ST'):
            a, addr = args.split(',')
            write_byte(bits(a))
            write_byte(bits(addr, 1))
            write_byte(bits(addr, 0))
            continue

        if op in ('MOV'):
            a, b = args.split(',')
            write_byte(bits(a))
            write_byte(bits(b))
            write_byte(bits(0))
            continue

        a, b, d = args.split(',')
        write_byte(bits(a))
        write_byte(bits(b))
        write_byte(bits(d))

    for _ in range(2**16 - num_bytes):
        write_byte(bits(0))
