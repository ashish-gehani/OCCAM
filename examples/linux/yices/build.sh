#!/usr/bin/env bash

# Build the manifest file
cat > yices_smt2.manifest <<EOF
{ "modules" : ["yices_smt2.bc"]
, "binary"  : "yices_smt2"
, "libs"    : ["libpoly.so.bc"]
, "native-libs" : ["-lgmp"]
, "search"  : ["/usr/lib", "/usr/local/lib", "/usr/lib/x86_64-linux-gnu/"]
, "args"    : ["--mcsat"]
, "name"    : "yices_smt2"
}
EOF

# Previrtualize
${OCCAM_HOME}/bin/occam previrt --work-dir=previrt yices_smt2.manifest


