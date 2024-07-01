encoded_string = "16_10_13_x_6t_4_1o_9_1j_7_9_1j_1o_3_6_c_1o_6r"
segments = encoded_string.split('_')

decoded_chars = [chr(int(segment, 36) + 10) for segment in segments]
decoded_string = ''.join(decoded_chars)

print(decoded_string)

