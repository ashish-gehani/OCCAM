#!/bin/bash -x
# Make sure we exit if there is a failure
set -e

mkdir occam
mkdir Repositories

echo "TRAVIS_HOME=${TRAVIS_HOME}"
export HOME=`pwd`
echo "HOME=${HOME}"

export OCCAM_HOME=${HOME}/occam
export REPOS=${HOME}/Repositories

######## ubuntu llvm-3.5 "namespace" #############

export LLVM_CC_NAME=clang-3.5
export LLVM_CXX_NAME=clang++-3.5
export LLVM_LINK_NAME=llvm-link-3.5
export LLVM_AR_NAME=llvm-ar-3.5
export LLVM_AS_NAME=llvm-as-3.5
export LLVM_LD_NAME=llvm-ld-3.5
export LLVM_LLC_NAME=llc-3.5
export LLVM_OPT_NAME=opt-3.5
export LLVM_NM_NAME=llvm-nm-3.5
export LLVM_CPP_NAME=clang-cpp-3.5
export LLVM_CONFIG_NAME=llvm-config-3.5

######## whole-program-llvm configuration #############

export WLLVM_HOME=${REPOS}/whole-program-llvm
export LLVM_COMPILER=clang
export WLLVM_OUTPUT=WARNING

########  Occam configuration ################

export OCCAM_SRC=${REPOS}/OCCAM/occam
export OCCAM_LOGFILE=${HOME}/.occam.log
export LLVM_HOME=/usr
export CC=${LLVM_CC_NAME}
export CXX=${LLVM_CXX_NAME}
export CPP='clang-3.5 -E'
export LLVM_CONFIG=${LLVM_CONFIG_NAME}
export PATH=${WLLVM_HOME}:${PATH}
alias occam=${OCCAM_HOME}/bin/occam


cd Repositories
git clone https://github.com/SRI-CSL/OCCAM.git 
git clone https://github.com/SRI-CSL/whole-program-llvm.git 
cd OCCAM 
make 
make install 
RETURN="$?"


if [ "${RETURN}" != "0" ]; then
    echo "Building OCCAM failed!"
    exit 1
fi
