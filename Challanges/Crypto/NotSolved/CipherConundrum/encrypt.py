import base64
from string import punctuation

alphabet = list(punctuation)
data = "0CTF{}"
def main():
    key = ('1JjVq9W81a7Vk9Sd1YfVhdWN1J/VgdWF1JvVm9W31YHUn9W31YbVjdSb1YzUndW31ZzUmNW31YrUm9W31YvUmNWF1ZjVhNSb1ZDVlQ==')
    encrypted = ''.join([chr(ord(x) ^ int(key, 16)) for x in data])
    encrypted_data_base64 = base64.b64encode(encrypted.encode()).decode()
    
    print(encrypted_data_base64)

main()
