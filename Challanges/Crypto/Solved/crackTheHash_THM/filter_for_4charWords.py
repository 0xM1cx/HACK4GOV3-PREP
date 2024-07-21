input_file = '/usr/share/wordlists/rockyou.txt'
output_file = 'rockyou_4char.txt'

with open(input_file, 'r', encoding='latin-1') as infile, open(output_file, 'w', encoding='latin-1') as outfile:
    for line in infile:
        word = line.strip()
        if len(word) == 4:
            outfile.write(word + '\n')

