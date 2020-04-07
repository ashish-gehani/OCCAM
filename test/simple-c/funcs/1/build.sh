#!/usr/bin/env bash

# Build the manifest file
cat > funcs.manifest <<EOF
{ "main" : "main.o.bc"
, "binary"  : "main"
, "modules"    : ["call.o.bc"]
, "native_libs" : []
, "ldflags"  : []
, "args"    : ["argv1"]
, "name"    : "main"
}
EOF

#make the bitcode
make

export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}

slash --intra-spec-policy=nonrec-aggressive --inter-spec-policy=nonrec-aggressive \
      --no-strip --work-dir=slash funcs.manifest

cp slash/main main_slash

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
