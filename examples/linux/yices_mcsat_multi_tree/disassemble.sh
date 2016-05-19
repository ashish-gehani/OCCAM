#!/usr/bin/env bash

WORKDIR=previrt


#debugging stuff below:
for bitcode in ${WORKDIR}/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done


