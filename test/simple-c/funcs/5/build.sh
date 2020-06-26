#!/usr/bin/env bash


LIBRARY='library'

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   LIBRARY='library.so'
elif [[ "$unamestr" == 'Darwin' ]]; then
   LIBRARY='library.dylib'
fi

#make the bitcode
CC=gclang make
get-bc main
get-bc ${LIBRARY}


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}


### PROGRAM AND LIBRARY
# Build the manifest file
cat > multiple.manifest <<EOF
{ "main" : "main.bc"
, "binary"  : "main"
, "modules"    : ["${LIBRARY}.bc"]
, "native_libs" : []
, "args"    : ["one"]
, "name"    : "main"
}
EOF

slash --use-pointer-analysis --work-dir=slash multiple.manifest --inter-spec-policy=nonrec-aggressive --intra-spec-policy=nonrec-aggressive --no-strip
cp slash/main main_slash

### NO LIBRARY
llvm-link main.bc ${LIBRARY}.bc -o main_static.bc
export OCCAM_LOGFILE=${PWD}/slash/occam_static.log
### PROGRAM AND LIBRARY
# Build the manifest file
cat > multiple.manifest <<EOF
{ "main" : "main_static.bc"
, "binary"  : "main_static"
, "modules"    : []
, "native_libs" : []
, "args"    : ["one"]
, "name"    : "main_static"
}
EOF



slash --use-pointer-analysis --work-dir=slash multiple.manifest --no-strip
cp slash/main main_static_slash

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
