#!/usr/bin/env bash

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
make clean
CC=wllvm make 
extract-bc main
extract-bc library.dylib


# Previrtualize
${OCCAM_HOME}/bin/occam previrt --work-dir=previrt simple.manifest


llvm-dis previrt/main-final.bc -o main-final.ll


