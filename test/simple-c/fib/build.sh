#!/usr/bin/env bash

cat > manifest <<EOF
{ "main" : "main.bc"
, "binary"  : "main"
, "modules"    : []
, "native_libs" : []
, "static_args"    : ["10"]
, "name"    : "main"
}
EOF

#make the bitcode
CC=gclang make
get-bc main


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log

slash --no-strip --intra-spec-policy=aggressive --inter-spec-policy=none --work-dir=slash manifest

cp slash/main main_slash

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
