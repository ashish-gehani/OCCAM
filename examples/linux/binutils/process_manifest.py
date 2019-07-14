#!/usr/bin/env python

import os.path
import sys




class Manifest:

    def __init__(self, manifest):
        self.paths = []
        self.files = []
        self.directories = []
        self.unique_names = []
        # gotta be careful with duplicate files names (but different paths)
        # maps duplicate basenames to their indexes in the list.
        self.duplicates = {}
        # all the indexes that need care
        self.range_of_duplicates = []
        with open(manifest) as fp:
            cindex = 0
            for path in fp:
                path = path.strip()
                if path:
                    self.paths.append(path)
                    (directory, basename) = os.path.split(path)
                    if basename in self.files:
                        #print(basename)
                        for index, f in enumerate(self.files):
                            if basename == f:
                                if basename not in self.duplicates:
                                    self.duplicates[basename] = [index]
                                    self.range_of_duplicates.append(index)
                                self.duplicates[basename].append(cindex)
                                self.range_of_duplicates.append(cindex)
                    self.files.append(basename)
                    self.directories.append(directory)
                    cindex += 1
        self.unique_names = [None] * len(self.paths)
        # set them to their default names; then fix any duplicates
        for i, path in enumerate(self.paths):
            (directory, basename) = os.path.split(path)
            self.unique_names[i] = basename[1:]
        for duplicate in self.duplicates:
            clashes = self.duplicates[duplicate]
            paths = [os.path.split(self.paths[index])[0].split(os.path.sep) for index in clashes]
            for path in paths:
                path.reverse()
            count = len(clashes)
            names = [duplicate[1:]] * count
            index = 0
            while len(set(names)) < count:
                for i in range(count):
                    names[i] = "{0}_{1}".format(paths[i][index], names[i])  #paths[i] might not be long enough
            for i in range(count):
                self.unique_names[clashes[i]] = names[i]



    def dump(self):
        print(len(self.paths))
        print(len(set(self.files)))
        print(self.duplicates)
        print(self.range_of_duplicates)


    def print_moves(self):
        for index, path in enumerate(self.paths):
            print('\tcp {0} {1}'.format(path, self.unique_names[index]))



def main():
    if len(sys.argv) != 3:
        print("Usage:\n\t{0} <llvm.manifest file>  <0: moves,1,2>".format(sys.argv[0]))
        exit(1)
    manifest = Manifest(sys.argv[1])

    if sys.argv[2] == '?':
        manifest.dump()
    elif sys.argv[2] == '0':
        #manifest.get_unique_name('.stabs.o.bc')
        manifest.print_moves()

if __name__ == "__main__":
    main()
