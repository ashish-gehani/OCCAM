#!/usr/bin/env bash

export OCCAM_LOGLEVEL=INFO

make clean

mkdir previrt

ROOT=`pwd`/root

# Build the manifest file
cat > nweb.manifest <<EOF
{ "modules" : ["nweb.bc"]
, "binary"  : "nweb"
, "libs"    : []
, "native_libs" : ["-lc", "-lpthread"]
, "search"  : ["/usr/lib", "/usr/local/lib"]
, "args"    : ["8181", "${ROOT}"]
, "name"    : "nweb"
}
EOF

#make the bitcode
wllvm nweb.c -o nweb
extract-bc nweb

# Previrutalize
export OCCAM_LOGFILE=${PWD}/previrt/occam.log

slash --work-dir=slash nweb.manifest

# Link link the binary into the current directory
# (it was created in previrt)
echo "linking nweb to previrt/nweb"
rm -f nweb
mv previrt/nweb .

# Now build the non-previrt application
echo "building the non-previrt application bitcode"
opt -O3 nweb.bc -o nweb.opt.bc

echo "creating the non-previrt application object file"
llc -filetype=obj -o nweb.opt.o nweb.opt.bc

echo "producing the non-previrt executable: nweb-base"
clang nweb.opt.o -o nweb-base 


#debugging stuff below:
for bitcode in previrt/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done

# for testing:
# curl 127.0.0.1:8181
