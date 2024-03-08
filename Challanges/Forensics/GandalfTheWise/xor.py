from pwn import xor

d1 = "xD6kfO2UrE5SnLQ6WgESK4kvD/Y/rDJPXNU45k/p"
d2 = "h2riEIj13iAp29VUPmB+TadtZppdw3AuO7JRiDyU"

print(xor(d1, d2).decode("utf-8"))
print(xor(d2, d1).decode("utf-8"))
