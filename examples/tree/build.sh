#!/usr/bin/env bash

export OCCAM_LOGLEVEL=INFO

LIBRARY='library'

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   LIBRARY='library.so'
elif [[ "$unamestr" == 'Darwin' ]]; then
   LIBRARY='library.dylib'
fi


# Build the manifest file  (FIXME: dylib not good for linux)
cat > simple.manifest <<EOF
{ "main" : "main.o.bc"
, "binary"  : "main"
, "modules"    : ["${LIBRARY}.bc", "subdir/module.o.bc"]
, "args"    : ["8181"]
, "name"    : "main"
}
EOF

#make the bitcode
CC=wllvm make 
extract-bc main.o
cd subdir; extract-bc module.o; cd ..
extract-bc ${LIBRARY}


export OCCAM_LOGFILE=${PWD}/previrt/occam.log

slash --work-dir=slash simple.manifest


#debugging stuff below:
for bitcode in previrt/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done

