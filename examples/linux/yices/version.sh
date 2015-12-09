#!/usr/bin/env bash

#unzip the bitcode
gunzip -k yices_main.bc.gz
gunzip -k libpoly.so.bc.gz 

# Build the manifest file
cat > yices_smt2.manifest <<EOF
{ "modules" : ["yices_smt2_static.bc"]
, "binary"  : "yices_smt2"
, "libs"    : []
, "native_libs" : ["-lc", "-lgmp"]
, "search"  : ["/usr/lib", "/usr/local/lib", "/usr/lib/x86_64-linux-gnu/"]
, "args"    : ["--version"]
, "name"    : "yices_smt2_version"
}
EOF

# Previrtualize
${OCCAM_HOME}/bin/occam previrt --work-dir=previrt yices_smt2.manifest


