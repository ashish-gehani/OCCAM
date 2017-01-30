#!/usr/bin/env bash

export OCCAM_LOGFILE=${PWD}/slash/occam.log
export OCCAM_LOGLEVEL=INFO

ROOT=`pwd`/root

OPT=${LLVM_OPT_NAME:-opt}
LLC=${LLVM_LLC_NAME:-llc}
CC=${LLVM_CC_NAME:-clang}
# Build the manifest file
cat > nweb.manifest <<EOF
{ "main" : "nweb.bc"
, "binary"  : "nweb"
, "native_libs" : ["-lc", "-lpthread"]
, "args"    : ["8181", "${ROOT}"]
, "name"    : "nweb"
}
EOF

#make the bitcode
wllvm nweb.c -o nweb
extract-bc nweb

# Previrutalize
slash --work-dir=slash nweb.manifest

# Copy the specialized binary into the current directory
# (it was created in slash)
echo "copying nweb_slash from slash/nweb"
rm -f nweb_slash
ln -s slash/nweb nweb_slash

# Now build the non-previrt application
echo "building the non-previrt application bitcode"
${OPT} -O3 nweb.bc -o nweb.opt.bc

echo "creating the non-previrt application object file"
${LLC} -filetype=obj -o nweb.opt.o nweb.opt.bc

echo "producing the non-previrt executable: nweb"
${CC} nweb.opt.o -o nweb

#debugging stuff below:
for bitcode in previrt/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done
