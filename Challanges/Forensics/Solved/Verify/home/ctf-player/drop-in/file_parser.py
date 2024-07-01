import hashlib
import os

def lines_files(directory):
    try:
        files = os.listdir(directory)
        return files
    except Exception as e:
        print(e)

def get_Checksums():
    files = lines_files("./files")
    checksums = dict()

    for file in files:
        checksum = hashlib.sha256(open(os.path.join("./files", file), 'rb').read()).hexdigest()
        checksums[file] = checksum
    
    return checksums

def find_Checksum_Match():
    checksums = get_Checksums()

    with open("checksum.txt", "r") as f:
        original_checksum = f.read().strip()
        for key, val in checksums.itemitems():
            if val == original_checksum:
                print("Checksums match")
                print(f"Original file is {key}")
                break
        else:
            print("Checksums do not match")


find_Checksum_Match()





