from pwn import *

string1 = "1c0111001f010100061a024b53535009181c"
string2 = "686974207468652062756c6c277320657965"

output_compare = "746865206b696420646f6e277420706c6179"

string1 = bytes.fromhex(string1)
string2 = bytes.fromhex(string2)

xor_res = xor(string1, string2)

if output_compare == xor_res.hex():
    print("Match")
else:
    print("Not a match")
