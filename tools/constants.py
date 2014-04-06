op_codes = {}
reset_vector = 0
ram_size = 0

vfile = open("../rtl/constants.v")

for line in vfile:

    if not "define" in line: continue

    _, name, value = line.strip().split()

    value = int(value)

    if name.startswith("OP_"):
        name = name.replace("OP_", "")
        op_codes[name] = value
        continue

    if name == "RESET_VECTOR":
        reset_vector = value
        continue

    if name == "RAM_ADDR_BITS":
        ram_size = 2**value
