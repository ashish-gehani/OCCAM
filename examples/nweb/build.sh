#!/usr/local/bin/bash

export OCCAM_LOGFILE=occam.log

ROOT=`pwd`/root

# Build the manifest file
cat > nweb.manifest <<EOF
{ "modules" : ["nweb.bc"]
, "binary"  : "nweb"
, "libs"    : ["-lc"]
, "native_libs" : ["-lpthread"]
, "search"  : ["/usr/lib", "/usr/local/lib"]
, "args"    : ["8181", "${ROOT}"]
, "name"    : "nweb"
}
EOF


# Build nweb.bc
${OCCAM_HOME}/bin/occam occam2 clang -c nweb.c
mv nweb.bc.o nweb.bc

# Previrutalize
${OCCAM_HOME}/bin/occam occam2 previrt --no-strip --work-dir previrt nweb.manifest


# Link link the binary into the current directory
# (it was created in previrt)
rm -f nweb
ln -s previrt/nweb .

# Now build the non-previrt application
opt -O3 nweb.bc -o nweb.opt.bc

llvm-ld -native -Xlinker=-static -o nweb-base nweb.opt.bc
