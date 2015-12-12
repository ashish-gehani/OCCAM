#!/usr/local/bin/bash

set -e

export LOGFILE=log.txt

# Compile - debug version
#echo "llvm-gcc -std=c99 -g -emit-llvm main.c -O0 -c"
#llvm-gcc -std=c99 -g -emit-llvm main.c -O0 -c
echo "clang -g main.c -O0 -c"
clang -g main.c -O0 -c

# Compile the hooks
echo "occam2 parse hook2 main.hooks > main.watch"
occam2 parse hook2 main.hooks > main.watch

# Instrument the code
echo "occam2 watch -o main.watch.bc main.bc main.watch"
occam2 watch -o main.watch.bc main.bc.o main.watch

# Optimize the code
echo "opt -O3 main.watch.bc -o=main.opt.bc"
opt -O3 main.watch.bc -o=main.opt.bc

# Compile the hooks
#echo "llvm-gcc -std=c99 -O3 -emit-llvm hooks.c -c"
#llvm-gcc -std=c99 -O3 -emit-llvm hooks.c -c
echo "clang -O3 hooks.c -c"
clang -O3 hooks.c -c

# Build the basic executable
echo "llvm-ld -native main.bc -o main.unwatched"
llvm-ld -native main.bc.o -o main.unwatched

# Build the watched executable
echo "llvm-ld -native main.watch.bc hooks.bc.o -o main.watched"
llvm-ld -native main.watch.bc hooks.bc.o -o main.watched
