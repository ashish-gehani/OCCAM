#!/usr/bin/env bash

export OCCAM_LOGFILE=${PWD}/slash/occam.log
export OCCAM_LOGLEVEL=INFO

ROOT=`pwd`/root

cat > main.manifest <<EOF
{ "main" :  "main.o.bc"
, "binary"  : "main_slash"
, "modules"    : ["libc.a.bc"]
, "native_libs" : ["crt1.o", "libc.a", "/usr/lib/gcc/x86_64-linux-gnu/5/libgcc.a"]
, "ldflags" : ["-static", "-nostdlib"]
, "args"    : []
, "name"    : "main"
}
EOF



# make libc.a.o
echo "llc -filetype=obj  libc.a.bc"
llc -filetype=obj libc.a.bc

# make a reference executable
echo "clang -static -nostdlib main.o libc.a.o crt1.o libc.a /usr/lib/gcc/x86_64-linux-gnu/5/libgcc.a -o main_static"
clang -static -nostdlib main.o libc.a.o crt1.o libc.a /usr/lib/gcc/x86_64-linux-gnu/5/libgcc.a -o main_static

# Previrtualize
slash --work-dir=slash main.manifest

cp slash/main_slash .

#debugging stuff below:
for bitcode in slash/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done
