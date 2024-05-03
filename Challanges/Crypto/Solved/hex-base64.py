import base64

desiredOutput = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
hex_val = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
bytes_val = bytes.fromhex(hex_val)

base64_val = base64.b64encode(bytes_val)

if str(desiredOutput) == base64_val.decode('utf-8'):
    print("Match")
else:
    print("Not a Match")