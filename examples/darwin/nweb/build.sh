#!/usr/bin/env bash

export OCCAM_LOGLEVEL=INFO

ROOT=`pwd`/root

# Build the manifest file
cat > nweb.manifest <<EOF
{ "main" : "nweb.bc"
, "binary"  : "nweb"
, "modules"    : []
, "native_libs" : ["-lc", "-lpthread"]
, "static_args"    : ["8181", "${ROOT}"]
, "name"    : "nweb"
}
EOF

#make the bitcode
echo "building the bitcode"
gclang nweb.c -o nweb
get-bc nweb

# Previrutalize
export OCCAM_LOGFILE=${PWD}/slash/occam.log

echo "specializing nweb"
slash --work-dir=slash nweb.manifest

# Copy the specialized binary into the current directory
# (it was created in slash directory)
rm -f nweb_slash
mv slash/nweb nweb_slash

# Now build the non-previrt application
echo "building the non-previrt application bitcode"
opt -O3 nweb.bc -o nweb.opt.bc

echo "creating the non-previrt application object file"
llc -filetype=obj -o nweb.opt.o nweb.opt.bc

echo "producing the non-previrt executable: nweb"
clang nweb.opt.o -o nweb

#debugging stuff below:
for bitcode in slash/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done

# for testing:
# curl 127.0.0.1:8181
