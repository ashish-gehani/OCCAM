#!/usr/bin/env bash

# Build the manifest file
cat > multiple.manifest <<EOF
{ "main" : "main.o.bc"
, "binary"  : "main"
, "modules"    : ["library.o.bc"]
, "native_libs" : []
, "args"    : ["one"]
, "name"    : "main"
}
EOF

#make the bitcode
CC=gclang make
extract-bc main.o
extract-bc library.o

export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}

slash --devirt=dsa --work-dir=slash multiple.manifest

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
