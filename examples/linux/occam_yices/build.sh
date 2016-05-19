#!/usr/bin/env bash

WORKDIR=previrt


export OCCAM_LOGFILE=${PWD}/${WORKDIR}/occam.log
export OCCAM_LOGLEVEL=INFO

mkdir -p ${WORKDIR}


# Previrtualize
${OCCAM_HOME}/bin/occam previrt --work-dir=previrt yices.manifest


#debugging stuff below:
for bitcode in ${WORKDIR}/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done


