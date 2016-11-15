#!/usr/bin/env bash




# Build the manifest file
cat > funcs.manifest <<EOF
{ "modules" : ["main.o.bc"]
, "binary"  : "main"
, "libs"    : ["call.o.bc"]
, "native_libs" : []
, "search"  : []
, "args"    : ["argv1"]
, "name"    : "main"
}
EOF

#make the bitcode
make


export OCCAM_LOGLEVEL=INFO

export OCCAM_LOGFILE=${PWD}/slash/occam.log

slash --work-dir=slash funcs.manifest

#debugging stuff below:

for bitcode in slash/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done
