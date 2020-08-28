#!/usr/bin/env bash

#make the bitcode
CC=gclang make
get-bc main.o
get-bc library.o

export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}

### PROGRAM AND LIBRARY
# Build the manifest file
cat > multiple.manifest <<EOF
{ "main" : "main.o.bc"
, "binary"  : "main"
, "modules"    : ["library.o.bc"]
, "native_libs" : []
, "static_args"    : []
, "name"    : "main"
}
EOF

slash --no-strip --use-pointer-analysis --force-inline-spec --inter-spec-policy=nonrec-aggressive --intra-spec-policy=nonrec-aggressive --work-dir=slash multiple.manifest 

### NO LIBRARY
llvm-link main.o.bc library.o.bc -o main_static.bc
export OCCAM_LOGFILE=${PWD}/slash/occam_static.log
### PROGRAM AND LIBRARY
# Build the manifest file
cat > multiple.manifest <<EOF
{ "main" : "main_static.bc"
, "binary"  : "main_static"
, "modules"    : []
, "native_libs" : []
, "static_args"    : []
, "name"    : "main_static"
}
EOF

slash --no-strip --use-pointer-analysis --work-dir=slash-static multiple.manifest


#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
