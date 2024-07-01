from pwn import *
string = "0e0b213f26041e480b26217f27342e175d0e070a3c5b103e2526217f27342e175d0e077e263451150104"


string_ord = [o for o in bytes.fromhex(string)] # converted the hex string to ord
flag_key = "crypto{".encode()

key = bytes(a ^ b for a, b in zip(string_ord, flag_key))

flag = bytes(a ^ b for a,b in zip(string_ord, key))
print(flag)
