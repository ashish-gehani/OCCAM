#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e

#check that the require dependencies are built
declare -a bitcode=("h264ref.bc")

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

rm -rf slash h264ref_slashed

# Build the manifest file
cat > h264ref.manifest <<EOF
{ "main" : "h264ref.bc"
, "binary"  : "h264ref_slashed"
, "modules"    : []
, "native_libs" : []
, "name"    : "h264ref"
}
EOF


# Run OCCAM
cp ./h264ref ./h264ref_orig
slash --stats --devirt --work-dir=slash h264ref.manifest
cp ./slash/h264ref_slashed .
