def modify_sof0_segment(jpeg_path, new_width, new_height, n):
    with open(jpeg_path, "rb") as file:
        jpeg_data = bytearray(file.read())

    sof0_marker = b'\xff\xc0'
    sof0_start = jpeg_data.find(sof0_marker)

    parameter_start = sof0_start + 5
    print("Original SOF0 width : {}".format(int.from_bytes(jpeg_data[parameter_start:parameter_start + 2],"big")))
    print("Original SOF0 height : {}".format(int.from_bytes(jpeg_data[parameter_start + 2:parameter_start + 4],"big")))

    new_width_bytes = new_width.to_bytes(2, byteorder='big')
    new_height_bytes = new_height.to_bytes(2, byteorder='big')

    jpeg_data[parameter_start:parameter_start + 2] = new_width_bytes
    jpeg_data[parameter_start + 2:parameter_start + 4] = new_height_bytes

    print("New SOF0 width : {}".format(int.from_bytes(jpeg_data[parameter_start:parameter_start + 2],"big")))
    print("New SOF0 height : {}".format(int.from_bytes(jpeg_data[parameter_start + 2:parameter_start + 4],"big")))

    modified_jpeg_path = f"./out/modified_{n}.jpg"
    with open(modified_jpeg_path, "wb") as file:
        file.write(jpeg_data)
        print("==> Saved new JPEG")

for i in range(10,10000,5):
    jpeg_path = "chal_tiny_10px.jpg"
    new_width = 20
    new_height = i
    modify_sof0_segment(jpeg_path, new_width, new_height, i)
