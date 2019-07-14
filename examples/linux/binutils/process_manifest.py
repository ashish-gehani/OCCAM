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


    def print_moves(self, target_dir):
        for index, path in enumerate(self.paths):
            print('\tcp {0} {2}/{1}'.format(path, self.unique_names[index], target_dir))

    def print_json(self, target_dir):
        for index, path in enumerate(self.paths):
            print('\t"{1}/{0}",'.format(self.unique_names[index], target_dir))



def main():
    if len(sys.argv) != 4:
        print("Usage:\n\t{0} <llvm.manifest file>  <0: moves,1: json,2>  <target dir>".format(sys.argv[0]))
        exit(1)
    manifest = Manifest(sys.argv[1])
    target_dir = sys.argv[3]
    if sys.argv[2] == '?':
        manifest.dump()
    elif sys.argv[2] == '0':
        manifest.print_moves(target_dir)
    elif sys.argv[2] == '1':
        manifest.print_json(target_dir)


if __name__ == "__main__":
    main()
