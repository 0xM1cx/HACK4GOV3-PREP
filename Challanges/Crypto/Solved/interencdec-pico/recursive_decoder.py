import base64

def decode_b64_recursive(b64_string):
  """
  Recursively decodes a base64 string.

  Args:
      b64_string: The base64 string to decode.

  Returns:
      The decoded string, or None if the decoding fails.
  """

  try:
    # Attempt base64 decoding (might fail if there are padding issues)
    decoded_bytes = base64.b64decode(b64_string)

    # Check if the decoded bytes are valid UTF-8 (common scenario)
    try:
      decoded_string = decoded_bytes.decode('utf-8')
      return decoded_string
    except UnicodeDecodeError:
      pass

    # If UTF-8 fails, recursively try decoding assuming additional padding
      # This handles cases where the original string might have missing padding.
      padded_string = b64_string + b'=' * (len(b64_string) % 4)
      return decode_b64_recursive(padded_string)

  except (base64.b64decodeError, UnicodeDecodeError):
    # Handle decoding errors (invalid base64 or invalid encoding)
    return None

with open('enc_flag', 'r') as f:
    b64_data = f.read()
    decoded_string = decode_b64_recursive(b64_data)

    if decoded_string:
        print(f"Decoded string: {decoded_string}")
    else:
        print("Decoding failed.")

