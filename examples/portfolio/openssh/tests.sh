#!/bin/bash -x
# Make sure we exit if there is a failure
set -e

#test passing in the LLVMCC and LLVMGET
rm -rf ./install
make clean
LLVMCC=wllvm LLVMGET=extract-bc make

rm -rf ./install
make clean
LLVMCC=gclang LLVMGET=get-bc make

