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
LIBS="-load=${OCCAM_HOME}/lib/libSeaDsa.dylib -load=${OCCAM_HOME}/lib/libprevirt.dylib"

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
