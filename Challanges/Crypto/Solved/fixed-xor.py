def xor_shit(dataOne, dataTwo):
    b = bytes(a ^ b for a, b in zip(dataOne, dataTwo)) 
    return b    

output = "746865206b696420646f6e277420706c6179"
dataOne =  "1c0111001f010100061a024b53535009181c"
dataOne_bytes = bytes.fromhex(dataOne)
dataTwo = "686974207468652062756c6c277320657965"
dataTwo_bytes = bytes.fromhex(dataTwo)


res = xor_shit(dataOne_bytes, dataTwo_bytes)
if res.hex() == output:
    print("Match")
else:
    print("Not a Match")