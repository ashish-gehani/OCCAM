#!/usr/bin/env bash


# Build the *full* manifest file
cat > multiple.manifest <<EOF
{ "main" : "wc.bc"
, "binary"  : "wc"
, "modules"    : []
, "native_libs" : []
, "ldflags" : [ "-O2" ]
, "name"    : "wc"
, "static_args"    : ["-c"]
}
EOF

#make the bitcode
CC=gclang make
get-bc wc


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}

slash --enable-config-prime \
      --no-strip \
      --work-dir=slash multiple.manifest

cp slash/wc wc_slash

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
