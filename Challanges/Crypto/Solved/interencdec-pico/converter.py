import base64

encoded_data = b'd3BqdkpBTXtqaGx6aHlfazNqeTl3YTNrXzc4MjUwaG1qfQ=='

try:
  decoded_bytes = base64.b64decode(encoded_data)
  decoded_string = decoded_bytes.decode('utf-8')  # Assuming UTF-8 encoding
  print(f"Decoded string: {decoded_string}")
except UnicodeDecodeError:
  print("Decoding might require a different encoding scheme.")
except base64.b64decodeError:
  print("Invalid base64 data.")

