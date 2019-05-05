#!/usr/bin/env bash


# Build the manifest file  (FIXME: dylib not good for linux)
cat > simple.manifest <<EOF
{ "main" : "harness.o.bc"
, "binary"  : "harness"
, "modules"    : ["memcmpO3fixed.bc"]
, "native_libs" : []
, "args"    : ["foo", "foo", "4"]
, "name"    : "harness"
}
EOF

#make the bitcode
CC=gclang make
get-bc harness.o

llvm-as memcmpO3fixed.ll


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}

slash --work-dir=slash simple.manifest

#debugging stuff below:
for bitcode in slash/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done

exit 0
