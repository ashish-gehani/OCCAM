#!/bin/bash -x
# Make sure we exit if there is a failure
set -e

mkdir -p travis_build/occam
mkdir -p travis_build/Repositories

#now set up the environment
. ${BUILD_HOME}/.travis/bash_profile

cd ${BUILD_HOME}
make
make install
RETURN="$?"


if [ "${RETURN}" != "0" ]; then
    echo "Building OCCAM failed!"
    exit 1
fi

make test
RETURN="$?"


if [ "${RETURN}" != "0" ]; then
    echo "The testing harness is dicky!"
    exit 1
fi
