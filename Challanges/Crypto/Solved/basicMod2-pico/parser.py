import string
letters = string.ascii_uppercase + string.digits + "_"
flag = []
with open('message.txt') as f:
    lines = f.read().split(" ")
    for line in lines:
        if len(line) > 0:
            i = pow(int(line), -1, 41)
            try:
                flag.append(letters[i - 1])
            except:
                pass


print("picoCTF{"+''.join(flag)+"}")
