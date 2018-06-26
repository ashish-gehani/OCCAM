#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e

#check that the require dependencies are built
declare -a bitcode=("bzip2.bc")

for bc in "${bitcode[@]}"
do
    if [ -a  "$bc" ]
    then
        echo "Found $bc"
    else
        echo "Error: $bc not found. Try \"make\"."
        exit 1
    fi
done

export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log

rm -rf slash ssh_slashed

# Build the manifest file
cat > bzip2.manifest <<EOF
{ "main" : "bzip2.bc"
, "binary"  : "bzip2_slashed"
, "modules"    : []
, "native_libs" : []
, "name"    : "bzip2"
}
EOF


# Run OCCAM
slash --stats --devirt --work-dir=slash bzip2.manifest

cp ./slash/bzip2_slashed .
