#!/usr/bin/env bash


# Build the *full* manifest file
cat > main.manifest <<EOF
{ "main" : "main.bc"
, "binary"  : "main_slash"
, "modules"    : []
, "native_libs" : []
, "static_args"    : []
, "name"    : "main"
}
EOF

#make the bitcode
CC=gclang make
get-bc main


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}

slash --enable-config-prime \
      --no-strip \
      --work-dir=slash main.manifest

cp slash/main_slash main_slash

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
