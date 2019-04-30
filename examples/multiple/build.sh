#!/usr/bin/env bash


LIBRARY='library'

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   LIBRARY='library.so'
elif [[ "$unamestr" == 'Darwin' ]]; then
   LIBRARY='library.dylib'
fi


# Build the manifest file
cat > multiple.manifest <<EOF
{ "main" : "main.bc"
, "binary"  : "main"
, "modules"    : ["${LIBRARY}.bc"]
, "native_libs" : []
, "args"    : ["8181"]
, "name"    : "main"
}
EOF

#make the bitcode
CC=gclang make
get-bc main
get-bc ${LIBRARY}


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}

slash --intra-spec-policy=nonrec-aggressive --inter-spec-policy=nonrec-aggressive \
      --work-dir=slash multiple.manifest

cp slash/main main_slash

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
