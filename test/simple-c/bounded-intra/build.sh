#!/usr/bin/env bash


# Build the manifest file
cat > multiple.manifest <<EOF
{ "main" : "main.bc"
, "binary"  : "main"
, "modules"    : []
, "native_libs" : []
, "static_args"    : ["8181"]
, "name"    : "main"
}
EOF

#make the bitcode
CC=gclang make
get-bc main


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}

slash --intra-spec-policy=bounded \
      --max-bounded-spec=2 \
      --no-strip \
      --work-dir=slash multiple.manifest

cp slash/main main_slash

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
