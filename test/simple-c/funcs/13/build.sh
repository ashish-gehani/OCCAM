#!/usr/bin/env bash

#make the bitcode
CC=gclang make
get-bc main.o

export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}

### PROGRAM 
# Build the manifest file
cat > multiple.manifest <<EOF
{ "main" : "main.o.bc"
, "binary"  : "main"
, "modules"    : []
, "native_libs" : []
, "args"    : []
, "name"    : "main"
}
EOF

slash --no-strip --use-pointer-analysis  --inter-spec-policy=none --intra-spec-policy=none --work-dir=slash multiple.manifest 

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
