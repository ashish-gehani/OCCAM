#!/usr/bin/env bash

export OCCAM_LOGFILE=${PWD}/slash/occam.log
export OCCAM_LOGLEVEL=INFO

gclang -c main.c extern-test.c

get-bc main.o

echo "var" > keep.list

slash --work-dir=slash --keep-external=keep.list json

#debugging stuff below:
echo "disassembling bitcode"
for bitcode in slash/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done
