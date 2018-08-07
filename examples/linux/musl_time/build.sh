#!/usr/bin/env bash

export OCCAM_LOGFILE=${PWD}/slash/occam.log
export OCCAM_LOGLEVEL=INFO

ROOT=`pwd`/root

cat > main.manifest <<EOF
{ "main" :  "main.o.bc"
, "binary"  : "main_slash"
, "modules"    : ["libc.a.bc"]
, "native_libs" : ["crt1.o", "libc.a", "/usr/lib/gcc/x86_64-linux-gnu/5/libgcc.a"]
, "ldflags" : ["-static", "-nostdlib", "-g"]
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
slash --no-strip --work-dir=slash --keep-external=untouchables.txt main.manifest

cp slash/main_slash .

#debugging stuff below:
echo "disassembling bitcode"
for bitcode in slash/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done
cp slash/libc.a-final.ll ./
cp slash/libc.a.ll ./
cp slash/main.o-final.ll  ./
cp slash/main.o.ll  ./
