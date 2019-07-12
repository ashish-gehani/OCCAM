#!/usr/bin/env python

import os.path
import sys





def main():
    if len(sys.argv) != 2:
        print("Usage:\n\t{0} <llvm.manifest file>".format(sys.argv[0]))
        exit(1)
    paths = []
    files = []
    directories = []
    # gotta be careful with duplicate files names (but different paths)
    # maps duplicate basenames to their indexes in the list.
    duplicates = {}
    range_of_duplicates = []
    with open(sys.argv[1]) as fp:
        cindex = 0
        for path in fp:
            path = path.strip()
            if path:
                paths.append(path)
                (directory, file) = os.path.split(path)
                if file in files:
                    print(file)
                    for index, f in enumerate(files):
                        if file == f:
                            if file not in duplicates:
                                duplicates[file] = [index]
                                range_of_duplicates.append(index)
                            duplicates[file].append(cindex)
                            range_of_duplicates.append(cindex)
                files.append(file)
                directories.append(directory)
                cindex += 1
    print(len(paths))
    print(len(set(files)))
    print(duplicates)
    print(range_of_duplicates)

if __name__ == "__main__":
    main()
