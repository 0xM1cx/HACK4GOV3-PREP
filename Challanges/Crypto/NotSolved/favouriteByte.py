string = "73626960647f6b206821204f21254f7d694f7624662065622127234f726927756d"

string_ord = [o for o in bytes.fromhex(string)] # converted the hex string to ord

for num in range(256): # to try possible numbers to xor with every number in the string ord. range from 0-255
    pos_flag_ord = [num ^ i for i in string_ord] # xor the number with every number in the string
    pos_flag = "".join([chr(i) for i in pos_flag_ord])
    if pos_flag.startswith("crypto"):
        flag = pos_flag
        break

print(flag)
