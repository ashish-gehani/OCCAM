#!/usr/bin/env bash

WORKDIR=previrt


export OCCAM_LOGFILE=${PWD}/${WORKDIR}/occam.log
export OCCAM_LOGLEVEL=INFO

mkdir -p ${WORKDIR}

# Build the manifest file
cat > yices_smt2_release_mcsat.manifest <<EOF
{ "modules" : ["yices_smt2_release_mcsat.bc"]
, "binary"  : "yices_smt2_release_mcsat_previrt"
, "libs"    : ["libpoly.so.bc"]
, "native-libs" : ["-lgmp"]
, "search"  : ["/usr/lib", "/usr/local/lib", "/usr/lib/x86_64-linux-gnu/"]
, "name"    : "yices_smt2_release_mcsat"
}
EOF

# Previrtualize
${OCCAM_HOME}/bin/occam previrt --work-dir=previrt yices_smt2_release_mcsat.manifest


#debugging stuff below:
for bitcode in ${WORKDIR}/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done
