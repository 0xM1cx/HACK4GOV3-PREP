import os
import tarfile

def extract_tar_file(tar_file_path, extract_path):
    """
    Extracts a .tar file to the specified directory.

    :param tar_file_path: Path to the .tar file.
    :param extract_path: Path to the directory where the contents will be extracted.
    """
    try:
        with tarfile.open(tar_file_path, 'r') as tar:
            tar.extractall(path=extract_path)
            print(f"Extracted {tar_file_path} to {extract_path}")
    except Exception as e:
        print(f"An error occurred while extracting {tar_file_path}: {e}")

def delete_tar_file(tar_file_path):
    """
    Deletes the specified .tar file.

    :param tar_file_path: Path to the .tar file.
    """
    try:
        os.remove(tar_file_path)
        print(f"Deleted {tar_file_path}")
    except Exception as e:
        print(f"An error occurred while deleting {tar_file_path}: {e}")

def recursive_extract(start_tar_file):
    """
    Recursively extracts .tar files starting from the given file, looking for the next file in sequence.

    :param start_tar_file: The starting .tar file (e.g., '1000.tar').
    """
    current_tar_file = start_tar_file
    current_directory = os.getcwd()

    while True:
        # Create the path for the current .tar file
        current_tar_path = os.path.join(current_directory, current_tar_file)

        if not os.path.exists(current_tar_path):
            print(f"{current_tar_path} does not exist. Stopping recursion.")
            break

        # Extract the current .tar file
        extract_tar_file(current_tar_path, current_directory)

        # Delete the current .tar file
        delete_tar_file(current_tar_path)

        # Calculate the next .tar file name
        next_tar_number = int(current_tar_file.replace('.tar', '')) - 1
        if next_tar_number < 0:
            break
        current_tar_file = f"{next_tar_number}.tar"

# Example usage
start_tar_file = '1000.tar'  # Starting .tar file

# Start the recursive extraction
recursive_extract(start_tar_file)

