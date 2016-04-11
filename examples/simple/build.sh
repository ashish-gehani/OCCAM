#!/usr/bin/env bash



export OCCAM_LOGFILE=${PWD}/previrt/occam.log
export OCCAM_LOGLEVEL=INFO

make clean

mkdir previrt

# Build the manifest file
cat > simple.manifest <<EOF
{ "modules" : ["main.bc"]
, "binary"  : "main"
, "libs"    : ["library.dylib.bc"]
, "native_libs" : []
, "search"  : []
, "args"    : ["8181"]
, "name"    : "main"
}
EOF

#make the bitcode
CC=wllvm make 
extract-bc main
extract-bc library.dylib


# Previrtualize
${OCCAM_HOME}/bin/occam previrt --work-dir=previrt simple.manifest


#debugging stuff below:
for bitcode in previrt/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done

