#!/bin/bash -x
# Make sure we exit if there is a failure
set -e

mkdir -p travis_build/occam
mkdir -p travis_build/Repositories

## Ubuntu adds suffixes to the LLVM tools that we rely on.
#export the suffix	    
export LLVM_SUFFIX=-3.8

#run the suffix additions script
. ${BUILD_HOME}/scripts/env.sh

#now set up the environment
. ${BUILD_HOME}/.travis/bash_profile

cd ${REPOS}
git clone https://github.com/SRI-CSL/whole-program-llvm.git 
cd ${BUILD_HOME}
make 
make install
#for some reason the install of occam is not being picked up...
#cd examples/hello
#make clean
#make
RETURN="$?"


if [ "${RETURN}" != "0" ]; then
    echo "Building OCCAM failed!"
    exit 1
fi
