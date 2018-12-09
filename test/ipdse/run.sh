#!/bin/bash

usage () {
    echo "Usage: $0 prog.c"
}

if [ $# -ne 1 ]
then
    usage 
    exit 1
fi


CLANG=${LLVM_HOME}/bin/clang
OPT=${LLVM_HOME}/bin/opt
DIS=${LLVM_HOME}/bin/llvm-dis

if [[ $(uname -s) == Linux ]]; then
    LIB_EXT="so"
else
    if [[ $(uname -s) == Darwin ]]; then
	LIB_EXT="dylib"	
    else	 
	echo "Unsupported OS"
	exit 1
    fi
fi

LIBS="-load=${OCCAM_HOME}/lib/libSeaDsa.${LIB_EXT}"
LIBS="${LIBS} -load=${OCCAM_HOME}/lib/libDSA.${LIB_EXT}"
LIBS="${LIBS} -load=${OCCAM_HOME}/lib/libprevirt.${LIB_EXT}"             

dirpath=$(dirname "$1")
filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"


IN=$1
OUT=$dirpath/$filename.bc
echo "$CLANG -c -emit-llvm -O0 -Xclang -disable-O0-optnone $IN -o $OUT"
$CLANG -c -emit-llvm -O0 -Xclang -disable-O0-optnone $IN -o $OUT

IN=$OUT
OUT=$dirpath/$filename.memssa.bc
echo "$OPT $LIBS -mem2reg --lower-gv-init -memory-ssa -mem2reg $IN  -o $OUT"
$OPT $LIBS -mem2reg --lower-gv-init -memory-ssa -mem2reg $IN  -o $OUT

IN=$OUT
OUT=$dirpath/$filename.o.bc
echo "$OPT $LIBS -ip-dse -strip-memory-ssa-inst -globaldce -Psccp -dce -globaldce $IN -o $OUT"
$OPT $LIBS -ip-dse -strip-memory-ssa-inst -globaldce -Psccp -dce -globaldce $IN -o $OUT
$DIS $OUT -o $1.output # for lit
