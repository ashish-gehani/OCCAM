#!/usr/bin/env bash

WORKDIR=slash


export OCCAM_LOGFILE=${PWD}/${WORKDIR}/occam.log
export OCCAM_LOGLEVEL=INFO

mkdir -p ${WORKDIR}

# Build the manifest file
cat > yices_smt2_gmp.manifest <<EOF
{ "main" : "yices_smt2.bc"
, "binary"  : "yices_smt2_gmp"
, "modules"    : ["libgmp.so.bc"]
, "native-libs" : []
, "name"    : "yices_smt2_gmp"
}
EOF

# Previrtualize
slash --work-dir=${WORKDIR} yices_smt2_gmp.manifest


#debugging stuff below:
for bitcode in ${WORKDIR}/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done
