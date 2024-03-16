from pwn import xor
import base64

d1 = "xD6kfO2UrE5SnLQ6WgESK4kvD/Y/rDJPXNU45k/p"
D1 = base64.b64decode(d1)

d2 = "h2riEIj13iAp29VUPmB+TadtZppdw3AuO7JRiDyU"
D2 = base64.b64decode(d2)

result = []
for i in range(0, len(D1)):
	result.append(chr(D1[i] ^ D2[i]))


print(''.join(result))

