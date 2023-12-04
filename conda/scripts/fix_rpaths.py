import os
import subprocess
import re
import sys

if len(sys.argv) < 1 or "-h" in sys.argv:
    print("Usage: python fix_rpaths.py <scan_path> [-r]")
    sys.exit(1)

scan_path = os.path.abspath(os.path.expanduser(sys.argv[1]))
recursive = "-r" in sys.argv

print(f"Scanning dir: {scan_path}")

def get_lc_paths(output):
    if "is not an object file" in output:
        return []

    result = []
    matches = re.finditer(r'cmd LC_RPATH', output)
    for match in matches:
        pos = match.start(0)

        path_match = re.search(r'path (.*) \(offset.+?\)', output[pos:])
        result.append(path_match.group(1))

    return result

def remove_rpath(file_path, rpath):
    subprocess.run(['install_name_tool', '-delete_rpath', rpath, file_path])
    print(f'\nRemoved rpath {rpath} from {file_path}')

def scan_directory(directory, recursive=False):
    for filename in os.listdir(directory):
        full_path = os.path.join(directory, filename)
        if recursive and os.path.isdir(full_path):
            scan_directory(full_path, recursive)
            continue
        elif not os.path.isfile(full_path) or os.path.islink(full_path):
            continue

        try:
            output = subprocess.check_output(['otool', '-l', full_path], text=True)
            lc_paths = get_lc_paths(output)
        except:
            continue

        # if any(os.path.isabs(path) for path in lc_paths):
        #     print(full_path, lc_paths)

        file_dir = os.path.dirname(full_path)
        for rpath in lc_paths:
            if os.path.isabs(rpath) and os.path.samefile(file_dir, rpath):
                remove_rpath(full_path, rpath)

scan_directory(scan_path, recursive)
print("Done removing problematic rpaths.")
