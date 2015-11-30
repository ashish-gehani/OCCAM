#!/bin/bash -x
# Make sure we exit if there is a failure
set -e

mkdir Repositories  
cd Repositories
git clone https://github.com/SRI-CSL/OCCAM.git
git clone https://github.com/SRI-CSL/whole-program-llvm.git
ls
echo `pwd`
cd OCCAM
make
make install 
RETURN="$?"


if [ "${RETURN}" != "0" ]; then
    echo "Building OCCAM failed!"
    exit 1
fi




