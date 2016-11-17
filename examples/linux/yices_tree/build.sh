#!/usr/bin/env bash

WORKDIR=slash


export OCCAM_LOGFILE=${PWD}/${WORKDIR}/occam.log
export OCCAM_LOGLEVEL=INFO

mkdir -p ${WORKDIR}


# Previrtualize
slash --work-dir=${WORKDIR} yices.manifest

echo "done previrtualizing"

#debugging stuff below:
for bitcode in ${WORKDIR}/*.bc; do
    #echo "llvm-dis  $bitcode"
    llvm-dis  "$bitcode" &> /dev/null
done
