#!/usr/bin/env bash

# XXX: clean before creating manifest
make clean

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
# XXX: gclang already generates bitcode without calling explictly get-bc
CC=gclang make

mv .library.o.bc library.o.bc
mv .main.o.bc main.o.bc

export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}

slash --devirt=dsa --work-dir=slash multiple.manifest

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
