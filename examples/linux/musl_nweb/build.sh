#!/usr/bin/env bash

export OCCAM_LOGFILE=${PWD}/previrt/occam.log
export OCCAM_LOGLEVEL=INFO

make clean

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
, "native_libs" : ["-lc", "-lpthread"]
, "search"  : ["/usr/lib", "/usr/local/lib", "/usr/lib/x86_64-linux-gnu/"]
, "args"    : ["8181", "${ROOT}"]
, "name"    : "nweb"
}
EOF

#make the bitcode
wllvm nweb.c -o nweb
extract-bc nweb

# Previrutalize
${OCCAM_HOME}/bin/occam previrt --work-dir=previrt nweb.manifest


# Link link the binary into the current directory
# (it was created in previrt)
echo "linking nweb to previrt/nweb"
rm -f nweb
ln -s previrt/nweb .

# Now build the non-previrt application
echo "building the non-previrt application bitcode"
${LLVM_OPT_NAME} -O3 nweb.bc -o nweb.opt.bc

echo "creating the non-previrt application object file"
${LLVM_LLC_NAME} -filetype=obj -o nweb.opt.o nweb.opt.bc

echo "producing the non-previrt executable: nweb-base"
${LLVM_CC_NAME} nweb.opt.o -o nweb-base 

#debugging stuff below:
for bitcode in previrt/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done
