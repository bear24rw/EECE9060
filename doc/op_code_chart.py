import sys
for line in open(sys.argv[1]):
    if not "OP_" in line: continue
    _, name, value = line.strip().split()
    name = name.replace("OP_", "")
    print "%s & description & %s 00000000 00000000 00000000 \\\\" % (name, bin(int(value)).replace("0b","").zfill(8))
