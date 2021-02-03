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
CRABOPT=${OCCAM_HOME}/bin/crabopt
DIS=${LLVM_HOME}/bin/llvm-dis

dirpath=$(dirname "$1")
filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"


IN=$1
OUT=$dirpath/$filename.bc
$CLANG -Wno-nullability-completeness -c -emit-llvm -O0 -Xclang -disable-O0-optnone $IN -o $OUT
IN=$OUT
OUT=$dirpath/$filename.o.bc
$CRABOPT -Pcrab-enable-warnings=false -Pcrab-log=clam-insert-invariants $IN -o $OUT
$DIS $OUT -o $1.output # for lit
