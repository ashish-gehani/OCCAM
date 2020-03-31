#!/usr/bin/env bash


# Build the manifest file
cat > multiple.manifest <<EOF
{ "main" : "main.bc"
, "binary"  : "main"
, "modules"    : []
, "native_libs" : []
, "args"    : []
, "name"    : "main"
}
EOF

#make the bitcode
CXX=gclang++ make
get-bc main


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}

slash  --work-dir=slash --devirt=cha_dsa --inter-spec-policy=none --intra-spec-policy=none multiple.manifest

cp slash/main main_slash

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
