#!/usr/bin/env bash

WORKDIR=slash


export OCCAM_LOGFILE=${PWD}/${WORKDIR}/occam.log
export OCCAM_LOGLEVEL=INFO

mkdir -p ${WORKDIR}

# Build the manifest file
cat > yices_smt2_release_mcsat.manifest <<EOF
{ "main" : "yices_smt2_release_mcsat.bc"
, "binary"  : "yices_smt2_release_mcsat_previrt"
, "modules"    : ["libpoly.so.bc"]
, "native-libs" : ["-lgmp"]
, "name"    : "yices_smt2_release_mcsat"
}
EOF

# Previrtualize
slash --work-dir=${WORKDIR} yices_smt2_release_mcsat.manifest


#debugging stuff below:
for bitcode in ${WORKDIR}/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done
