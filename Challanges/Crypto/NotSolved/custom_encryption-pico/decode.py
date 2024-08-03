def dynamic_xor_encrypt(plaintext, text_key):
     cipher_text = ""
     key_length = len(text_key)
     for i, char in enumerate(plaintext[::-1]):
         key_char = text_key[i % key_length]
         encrypted_char = chr(ord(char) ^ ord(key_char))
         cipher_text += encrypted_char
     return cipher_text

def decrypt(cipher, key):
    decrypted_text = ""
    for num in cipher:
        decrypted_num = num // (key * 311)
        decrypted_text += chr(decrypted_num)

    return decrypted_text

a = 95
b = 21
p = 27
g = 31
cipher = [33588, 276168, 261240, 302292, 343344, 328416, 242580, 85836, 82104, 156744, 0, 309756, 78372, 18660, 253776, 0, 82104, 320952, 3732, 231384, 89568, 100764, 22392, 22392, 63444, 22392, 97032, 190332, 119424, 182868, 97032, 26124, 44784, 63444]

u = pow(g, a, p)
v = pow(g, b, p)

shared_key = pow(v, a, p)
intermed_cipher = decrypt(cipher, shared_key)
flag = dynamic_xor_encrypt(intermed_cipher, 'trudeau')

print(f"DECODED FLAG: {flag}")

