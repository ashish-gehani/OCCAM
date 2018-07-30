#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e

#check that the require dependencies are built
declare -a bitcode=("mcf.bc")

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

rm -rf slash mcf_slashed

# Build the manifest file
cat > mcf.manifest <<EOF
{ "main" : "mcf.bc"
, "binary"  : "mcf_slashed"
, "modules"    : []
, "native_libs" : []
, "name"    : "mcf"
}
EOF


# Run OCCAM
cp ./mcf ./mcf_orig
slash --stats --devirt --work-dir=slash mcf.manifest
cp ./slash/mcf_slashed .
