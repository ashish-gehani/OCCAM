#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e

#check that the require dependencies are built
declare -a bitcode=("milc.bc")

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
cat > milc.manifest <<EOF
{ "main" : "milc.bc"
, "binary"  : "milc_slashed"
, "modules"    : []
, "native_libs" : []
, "name"    : "milc"
}
EOF


# Run OCCAM
slash --stats --devirt --work-dir=slash milc.manifest

cp ./slash/milc_slashed .
