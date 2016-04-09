#!/usr/bin/env bash

make clean

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


llvm-dis previrt/main-final.bc -o main-final.ll

llvm-dis previrt/library.dylib-final.bc -o library.dylib-final.ll


