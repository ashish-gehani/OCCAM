#!/usr/local/bin/bash

export PATH=/usr/obj/usr/src/tmp/usr/bin:/home/moore/bin:$PATH
export LOGFILE=occam.log

OCCAM=/home/moore/occam/bin/occam

rm -Rf previrt occam.log hello-std hello-std.bc hello hello-static
$OCCAM clang -c main.c -o main.o
mv main.bc.o main.bc
$OCCAM occam-build hello.manifest hello-std
$OCCAM occam2 previrt --no-strip --work-dir previrt hello.manifest
ln -s previrt/hello hello
cd previrt
mkdir tmp
cd tmp
cp ../libcrt.bc.a .
cp ../libc-final.bc .
cp ../main-final.bc .
llvm-ld -v -o=hello -native -Xlinker=-static -Xlinker=-nostdlib -L. -lc libcrt.bc.a libc-final.bc main-final.bc 
cd ../..
ln -s previrt/tmp/hello hello-static
