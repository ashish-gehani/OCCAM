#!/usr/bin/env bash

cat > simple.manifest <<EOF
{ "main" : "main.bc"
, "binary"  : "main"
, "modules"    : []
, "native_libs" : []
, "name"    : "main"
, "static_args" : ["hello world"]
, "dynamic_args": 1
}
EOF

#make the bitcode
CC=gclang make
get-bc main


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log


slash --intra-spec-policy=none --inter-spec-policy=none \
      --work-dir=slash simple.manifest

cp slash/main main_slash

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
