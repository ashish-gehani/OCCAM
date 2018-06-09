#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e


echo "Linking ssh_from_bc"
clang++ ssh.bc libcrypto.a.bc libz.a.bc -ldl -lresolv -o ssh_from_bc

echo "Linking sshd_from_bc"
clang++ sshd.bc libcrypto.a.bc libz.a.bc -ldl -lresolv -o sshd_from_bc

export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log

rm -rf slash ssh_slashed

# Build the manifest file
cat > ssh.manifest <<EOF
{ "main" : "ssh.bc"
, "binary"  : "ssh_slashed"
, "modules"    : ["libcrypto.a.bc", "libz.a.bc"]
, "native_libs" : ["-ldl", "-lresolv"]
, "name"    : "ssh"
, "constraints" : ["1", "-Y", "-4"]
}
EOF


# Previrtualize
#slash --stats --devirt --work-dir=slash ssh.manifest
echo "NOT DOING --devirt COZ ITS DODGEY!!!!!!!!!!!!!!!!!"
slash --stats --work-dir=slash ssh.manifest

cp slash/ssh_slashed .
echo "NOT DOING --devirt COZ ITS DODGEY!!!!!!!!!!!!!!!!!"
