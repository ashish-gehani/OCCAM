#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e

#check that the require dependencies are built
declare -a bitcode=("sjeng.bc")

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
cat > sjeng.manifest <<EOF
{ "main" : "sjeng.bc"
, "binary"  : "sjeng_slashed"
, "modules"    : []
, "native_libs" : []
, "name"    : "sjeng"
}
EOF


# Run OCCAM
cp ./sjeng ./sjeng_orig
slash --stats --devirt --work-dir=slash sjeng.manifest
cp ./slash/sjeng_slashed .
