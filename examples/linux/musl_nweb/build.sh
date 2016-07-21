#!/usr/bin/env bash

export OCCAM_LOGFILE=${PWD}/previrt/occam.log
export OCCAM_LOGLEVEL=INFO

make clean

make libc.a.bc

mkdir previrt

. ../../../scripts/env.sh

cp ../musllvm/libc.so.bc .
cp ../musllvm/libc.a .


ROOT=`pwd`/root

# Build the manifest file
cat > nweb.manifest <<EOF
{ "modules" : ["nweb.bc"]
, "binary"  : "nweb"
, "libs"    : ["libc.so.bc"]
, "native_libs" : []
, "search"  : []
, "args"    : ["8181", "${ROOT}"]
, "name"    : "nweb"
}
EOF

#make the bitcode

wllvm nweb.c -o nweb
extract-bc nweb

#wllvm -nostdlib nweb.c -c -o nweb.o
#extract-bc nweb.o
#mv nweb.o.bc nweb.bc


# Previrutalize
${OCCAM_HOME}/bin/occam previrt --work-dir=previrt nweb.manifest


# Link link the binary into the current directory
# (it was created in previrt)
echo "linking nweb to previrt/nweb"
rm -f nweb
ln -s previrt/nweb .

# Now build the non-previrt application
echo "building the non-previrt application bitcode"
${LLVM_OPT_NAME} -O3 nweb.o.bc -o nweb.opt.bc

echo "creating the non-previrt application object file"
${LLVM_LLC_NAME} -filetype=obj -o nweb.opt.o nweb.opt.bc

echo "producing the non-previrt executable: nweb-base"
${LLVM_CC_NAME} nweb.opt.o -o nweb-base 

#debugging stuff below:
for bitcode in previrt/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done
