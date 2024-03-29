message = input("Message: ")
distance = -18

encrypted = ""
for char in message:
    a = ord(char)
    value = ord(char) + distance
    if value <= 33: # non-printable characters in ascii
        value -= 33
    encrypted += chr(value % 128) #128 for ASCII


print(encrypted)