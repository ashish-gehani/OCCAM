#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e


clang++ ssh.bc libcrypto.a.bc libz.a.bc -ldl -lresolv -o ssh_from_bc


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log

# Build the manifest file
cat > ssh.manifest <<EOF
{ "main" : "ssh.bc"
, "binary"  : "ssh_slashed"
, "modules"    : ["libcrypto.a.bc", "libz.a.bc"]
, "native_libs" : ["-ldl", "-lresolv"]
, "args"    : []
, "name"    : "ssh"
}
EOF


# Previrtualize
slash --stats --devirt --work-dir=slash ssh.manifest

cp slash/ssh_slashed .

