
def checkLines(line):

    numOfZero = 0
    numOfOne = 0

    for digit in line:
        if digit == "0":
            numOfZero += 1

        if digit == "1":
            numOfOne += 1 

    if numOfZero % 3 == 0 or numOfOne % 2 == 0:
        return True
    else:
        return False




def main():
    num_ofLines = 0
    lines = []
    with open("data.dat", "r") as f:
        for line in f.readlines():
            lines.append(line.strip())

    for line in lines:
        if(checkLines(line)):
            num_ofLines += 1




    print(num_ofLines)
if __name__ == "__main__":
    main()