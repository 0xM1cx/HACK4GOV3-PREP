from pwn import *
import string
from collections import Counter

def analyze_frequency(letters):
    listed = list(letters)
    letter_counts = Counter(listed)
    return letter_counts
letters = string.ascii_lowercase

hex_str = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"

outputs = []

for letter in letters:
    byte_letter = str.encode(letter)
    byte_str = bytes.fromhex(hex_str)

    xored = xor(byte_str, byte_letter)
    outputs.append(xored.decode('utf-8'))



for i in outputs:
    frequencies =  analyze_frequency(i)


