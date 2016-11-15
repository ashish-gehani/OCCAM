#!/usr/bin/env bash

export OCCAM_LOGFILE=${PWD}/slash/occam.log
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
{ "modules" : ["main.o.bc"]
, "binary"  : "main"
, "libs"    : ["${LIBRARY}.bc",  "module.o.bc"]
, "native_libs" : []
, "search"  : []
, "args"    : ["8181"]
, "name"    : "main"
}
EOF

#make the bitcode
CC=wllvm make 
extract-bc main.o
extract-bc module.o
extract-bc ${LIBRARY}


# slash
slash --work-dir=slash simple.manifest
cp slash/main main_slash

#debugging stuff below:
for bitcode in slash/*.bc; do
    llvm-dis  "$bitcode" &> /dev/null
done

