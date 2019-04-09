#!/usr/bin/env bash


# Use .so regardless OS to make easier running tests
LIBRARY='library.so'

# Build the manifest file  
cat > manifest <<EOF
{ "main" : "main.bc"
, "binary"  : "main"
, "modules"    : ["${LIBRARY}.bc"]
, "native_libs" : []
, "args"    : ["15"]
, "name"    : "main"
}
EOF

#make the bitcode
CC=gclang make
get-bc main
get-bc ${LIBRARY}


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log


slash --no-strip \
      --intra-spec-policy=aggressive \
      --inter-spec-policy=aggressive \
      --work-dir=slash manifest

cp slash/main main_slash

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
