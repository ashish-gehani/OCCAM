#!/usr/bin/env bash

WORKDIR=previrt_nostrip

mkdir -p ${WORKDIR}

# Build the manifest file
cat > yices_smt2.manifest <<EOF
{ "modules" : ["yices_smt2.bc"]
, "binary"  : "yices_smt2_previrt"
, "libs"    : ["libpoly.so.bc"]
, "native-libs" : ["-lgmp"]
, "search"  : ["/usr/lib", "/usr/local/lib", "/usr/lib/x86_64-linux-gnu/"]
, "name"    : "yices_smt2"
}
EOF
#, "args"    : ["--mcsat"]

# Build the manifest file
cat > yices_smt2_release_mcsat.manifest <<EOF
{ "modules" : ["yices_smt2_release_mcsat.bc"]
, "binary"  : "yices_smt2_release_mcsat_previrt"
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

#WORKDIR=previrt_nostrip
WORKDIR=previrt

# Previrtualize   [--work-dir=<dir>] [--force] [--no-strip] <manifest>
#${OCCAM_HOME}/bin/occam previrt --no-strip --work-dir=${WORKDIR} yices_smt2_release_mcsat.manifest
${OCCAM_HOME}/bin/occam previrt --work-dir=${WORKDIR} yices_smt2_release_mcsat.manifest


# Build the manifest file
cat > yices_smt2_release.manifest <<EOF
{ "modules" : ["yices_smt2_release.bc"]
, "binary"  : "yices_smt2_release"
, "libs"    : ["libpoly.so.bc"]
, "native-libs" : ["-lgmp"]
, "search"  : ["/usr/lib", "/usr/local/lib", "/usr/lib/x86_64-linux-gnu/"]
, "name"    : "yices_smt2_release"
}
EOF

# Previrtualize
#${OCCAM_HOME}/bin/occam previrt --work-dir=previrt_release yices_smt2.manifest
