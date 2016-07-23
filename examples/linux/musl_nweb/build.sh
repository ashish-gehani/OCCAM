#!/usr/bin/env bash

export OCCAM_LOGFILE=${PWD}/previrt/occam.log
export OCCAM_LOGLEVEL=INFO

make clean

make libc.a.bc

mkdir previrt

. ../../../scripts/env.sh

ROOT=`pwd`/root

# Build the manifest file
cat > nweb.manifest <<EOF
{ "modules" : ["nweb.o.bc"]
, "binary"  : "nweb_occam"
, "libs"    : ["libc.a.bc"]
, "ldflags" : ["-static", "-nostdlib"]
, "native_libs" : ["crt1.o", "libc.a"]
, "search"  : ["${PWD}"]
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
echo "${OCCAM_HOME}/bin/occam previrt --work-dir=previrt nweb.manifest"
${OCCAM_HOME}/bin/occam previrt --work-dir=previrt nweb.manifest

exit

# Link link the binary into the current directory
# (it was created in previrt)
echo "linking nweb to previrt/nweb"
ln -s previrt/nweb_occam .


exit

# Now build the non-previrt application
echo "building the optimized non-previrt application bitcode"
${LLVM_LINK_NAME} nweb.o.bc libc.a.bc -o nweb_opt.bc
${LLVM_OPT_NAME} -O3 nweb_opt.bc -o nweb_opt_o3.bc

echo "creating the non-previrt application object file"
${LLVM_LLC_NAME} -filetype=obj nweb_opt_o3.bc -o nweb_opt_o3.o 

echo "producing the non-previrt executable: nweb-base"
${LLVM_CC_NAME} -static -nostdlib  nweb_opt_o3.o crt1.o libc.a -o nweb_opt_o3 




#debugging stuff below:
for bitcode in previrt/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done
