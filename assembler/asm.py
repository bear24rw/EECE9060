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

reset_vector = 20

ram_size = 2**13

def bits(number, byte_num=0):
    byte_num += 1
    number = int(number)
    s = bin(number)[2:]
    s = s.zfill(8*byte_num)
    return s[-8*byte_num:len(s)-8*byte_num+8]

if __name__ == "__main__":

    asm_filename = sys.argv[1]
    rom_filename = sys.argv[1].replace("asm", "rom")
    txt_filename = sys.argv[1].replace("asm", "txt")

    asm_file = open(asm_filename)
    rom_file = open(rom_filename, 'wb')
    txt_file = open(txt_filename, 'w')

    num_bytes = 0
    filling = False

    labels = {}

    def write_byte(x):
        global num_bytes
        txt_file.write(x+'\n')
        if not filling: rom_file.write(chr(eval('0b'+x)))
        num_bytes += 1

    for _ in range(reset_vector):
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
            write_byte(bits(op_codes[line]))
            write_byte(bits(0))
            write_byte(bits(0))
            write_byte(bits(0))
            continue

        op, args = line.split()

        write_byte(bits(op_codes[op]))

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

    filling = True

    for _ in range(ram_size - num_bytes):
        write_byte(bits(0))
