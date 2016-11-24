#!/usr/bin/env bash

export OCCAM_LOGFILE=${PWD}/slash/occam.log
export OCCAM_LOGLEVEL=INFO

make libc.a.bc

ROOT=`pwd`/root

cat > nweb.razor.manifest <<EOF
{ "main" :  "nweb.o.bc"
, "binary"  : "nweb_razor"
, "modules"    : ["libc.a.bc"]
, "native_libs" : ["crt1.o", "libc.a"]
, "ldflags" : ["-static", "-nostdlib"]
, "args"    : ["8181", "${ROOT}"]
, "name"    : "nweb"
}
EOF



# make the bitcode

echo "wllvm nweb.c -c"
wllvm nweb.c -c

echo "extract-bc nweb.o"
extract-bc nweb.o

# make libc.a.o
echo "llc -filetype=obj  libc.a.bc"
llc -filetype=obj libc.a.bc

# make a reference executable
echo "clang -static -nostdlib nweb.o libc.a.o crt1.o libc.a -o nweb_static"
clang -static -nostdlib nweb.o libc.a.o crt1.o libc.a -o nweb_static

# Previrtualize
slash --work-dir=slash nweb.razor.manifest

#debugging stuff below:
for bitcode in slash/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done
