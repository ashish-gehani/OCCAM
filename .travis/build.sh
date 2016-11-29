#!/bin/bash -x
# Make sure we exit if there is a failure
set -e

wllvm-sanity-checker

mkdir -p travis_build/occam
mkdir -p travis_build/Repositories

#now set up the environment
. ${BUILD_HOME}/.travis/bash_profile

cd ${REPOS}
git clone https://github.com/SRI-CSL/whole-program-llvm.git 
cd ${BUILD_HOME}
make 
make install
RETURN="$?"


if [ "${RETURN}" != "0" ]; then
    echo "Building OCCAM failed!"
    exit 1
fi


### down here we want to check that running slash on multiple actually works.
### AND specializes; so we do not go a year or so with a broken previrt AGAIN.

