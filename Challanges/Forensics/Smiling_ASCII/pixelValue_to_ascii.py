from PIL import Image

im = Image.open('smiling.png', 'r')

capital = [chr(x) for x in range(65, 91)]
lowercase = [chr(y) for y in range(97, 123)]

pixel_val = list(im.getdata())
pixel_val_flat = [x for sets in pixel_val for x in sets]

for char in pixel_val_flat:
	if chr(int(char)) in capital or chr(int(char)) in lowercase or chr(int(char)) == '=':
		print(chr(int(char)), end="")
		if chr(int(char)) == '=':
			print("\n")