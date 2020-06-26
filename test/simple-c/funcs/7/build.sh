#!/usr/bin/env bash

if [ -z ${1+x} ]; then
    # default directory name if $1 is unset
    WORKDIR=slash
else    
    ## directory name 
    WORKDIR=$1
fi      

# Build the manifest file
cat > multiple.manifest <<EOF
{ "main" : "main.o.bc"
, "binary"  : "main"
, "modules"    : ["library.o.bc"]
, "native_libs" : []
, "args"    : ["one"]
, "name"    : "main"
}
EOF

#make the bitcode
# XXX: gclang already generates bitcode without calling explictly get-bc
CC=gclang make

mv .library.o.bc library.o.bc
mv .main.o.bc main.o.bc

export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/${WORKDIR}/occam.log
export PATH=${LLVM_HOME}/bin:${PATH}

slash --use-pointer-analysis --work-dir=${WORKDIR} multiple.manifest

#debugging stuff below:
for bitcode in ${WORKDIR}/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done

exit 0
