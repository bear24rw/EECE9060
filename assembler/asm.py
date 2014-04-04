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

def bits(number, byte_num=1):
    number = int(number)
    s = bin(number)[2:]
    s = s.zfill(8*byte_num)
    return s[-8*byte_num:len(s)-8*byte_num+8]

if __name__ == "__main__":

    asm_filename = sys.argv[1]
    rom_filename = sys.argv[1].replace("asm", "rom")

    asm_file = open(asm_filename)
    rom_file = open(rom_filename, 'w')

    for line in asm_file:
        line = line.upper().strip()
        op, args = line.split()
        print (op, args)

        rom_file.write("%s\n" % bits(op_codes[op]))

        if op in ('JMP'):
            rom_file.write(bits(args, 1)+'\n')
            rom_file.write(bits(args, 0)+'\n')
            continue

        if op in ('LDI', 'ST'):
            a, addr = args.split(',')
            rom_file.write(bits(a)+'\n')
            rom_file.write(bits(addr, 1)+'\n')
            rom_file.write(bits(addr, 0)+'\n')
            continue

        if op in ('MOV'):
            a, b = args.split(',')
            rom_file.write(bits(a)+'\n')
            rom_file.write(bits(b)+'\n')
            continue

        a, b, d = args.split(',')
        rom_file.write(bits(a)+'\n')
        rom_file.write(bits(b)+'\n')
        rom_file.write(bits(d)+'\n')
