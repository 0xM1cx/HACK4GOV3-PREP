with open('ports.txt') as f:
    lines = f.read().split("\n")
    for line in lines:
        if len(line) > 0:
            print(chr(int(line[1:])), end="")
