import base64
cipher = "VmtaU1IxUXhUbFZSYXpsV1RWUnNRMVpYZEZkYWJFWTJVVmhrVlZGVU1Eaz0="
flag = True
while flag:
    try:
        cipher = base64.b64decode(cipher).decode("utf-8") 
    except:
        flag = False

print(cipher)
