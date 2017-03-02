#!/bin/bash -x
# Make sure we exit if there is a failure
set -e

sudo cat <<EOF >> /etc/apt/sources.list
deb http://apt.llvm.org/trusty/ llvm-toolchain-trusty main
deb-src http://apt.llvm.org/trusty/ llvm-toolchain-trusty main
# 3.9
deb http://apt.llvm.org/trusty/ llvm-toolchain-trusty-3.9 main
deb-src http://apt.llvm.org/trusty/ llvm-toolchain-trusty-3.9 main
# 4.0
deb http://apt.llvm.org/trusty/ llvm-toolchain-trusty-4.0 main
deb-src http://apt.llvm.org/trusty/ llvm-toolchain-trusty-4.0 main
EOF

wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
sudo apt-get update
sudo apt-get install clang-3.9 lldb-3.9

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
    echo "The test harness is dicky!"
    exit 1
fi
