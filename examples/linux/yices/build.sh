#!/usr/bin/env bash

# Build the manifest file
cat > yices_smt2.manifest <<EOF
{ "modules" : ["yices_smt2.bc"]
, "binary"  : "yices_smt2_previrt"
, "libs"    : ["libpoly.so.bc"]
, "native-libs" : ["-lgmp"]
, "search"  : ["/usr/lib", "/usr/local/lib", "/usr/lib/x86_64-linux-gnu/"]
, "args"    : ["--mcsat"]
, "name"    : "yices_smt2"
}
EOF

# Build the manifest file
cat > yices_smt2_release_mcsat.manifest <<EOF
{ "modules" : ["yices_smt2_release_mcsat.bc"]
, "binary"  : "yices_smt2_mcsat_previrt"
, "libs"    : ["libpoly.so.bc"]
, "native-libs" : ["-lgmp"]
, "search"  : ["/usr/lib", "/usr/local/lib", "/usr/lib/x86_64-linux-gnu/"]
, "name"    : "yices_smt2_release_mcsat"
}
EOF

# Build the manifest file
cat > linked_yices_smt2_mcsat.manifest <<EOF
{ "modules" : ["linked_yices_smt2_mcsat.bc"]
, "binary"  : "linked_yices_smt2_mcsat_previrt"
, "libs"    : []
, "native-libs" : ["-lgmp"]
, "search"  : ["/usr/lib", "/usr/local/lib", "/usr/lib/x86_64-linux-gnu/"]
, "name"    : "linked_yices_smt2_mcsat"
}
EOF

# Previrtualize
${OCCAM_HOME}/bin/occam previrt --work-dir=previrt yices_smt2_release_mcsat.manifest


