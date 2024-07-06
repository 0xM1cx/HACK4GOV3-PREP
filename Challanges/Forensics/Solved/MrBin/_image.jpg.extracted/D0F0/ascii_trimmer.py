with open("bin", "r") as f:
    big_line = f.read()
    counter = 1
    with open("output.txt", "w") as out:
        for char in big_line:
            if counter != 600:
                out.write(char)
                counter += 1
            else:
                out.write(char + "\n")
                counter = 1

