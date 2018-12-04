#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e

#check that the require dependencies are built
declare -a bitcode=("tree.bc")

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



echo "Linking tree_from_bc"
clang++ tree.bc -o tree_from_bc

export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log

rm -rf slash

slash --inter-spec-policy=none --no-strip --stats --devirt --work-dir=slash tree.manifest.constraints

cp slash/tree tree_slashed
