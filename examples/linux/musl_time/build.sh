#!/usr/bin/env bash

export OCCAM_LOGFILE=${PWD}/slash/occam.log
export OCCAM_LOGLEVEL=INFO

if [ -z "$LLVM_LINK_NAME" ]; then
    LLVM_LINK=$LLVM_LINK_NAME
else
    LLVM_LINK=llvm-link-5.0
fi

ROOT=`pwd`/root

function create_dynamic_manifest() {
    cat > main.dynamic.manifest <<EOF
{ "main" :  "main.o.bc"
, "binary"  : "main_slash"
, "modules"    : ["libc.a.bc"]
, "native_libs" : ["crt1.o", "libc.a", "/usr/lib/gcc/x86_64-linux-gnu/7/libgcc.a"]
, "ldflags" : ["-static", "-nostdlib", "-g"]
, "args"    : []
, "name"    : "main"
}
EOF
}

function create_static_manifest() {
    $LLVM_LINK main.o.bc libc.a.bc -o main.merged.o.bc
    cat > main.static.manifest <<EOF
{ "main" :  "main.merged.o.bc"
, "binary"  : "main_slash"
, "modules"    : []
, "native_libs" : ["crt1.o", "libc.a", "/usr/lib/gcc/x86_64-linux-gnu/7/libgcc.a"]
, "ldflags" : ["-static", "-nostdlib", "-g"]
, "args"    : []
, "name"    : "main"
}
EOF
}


# make libc.a.o
echo "llc -filetype=obj  libc.a.bc"
llc -filetype=obj libc.a.bc

# make a reference executable
echo "Making a reference executable ..."
clang -static -nostdlib main.o libc.a.o crt1.o libc.a /usr/lib/gcc/x86_64-linux-gnu/7/libgcc.a -o main_static

LINK_MODE="dynamic"
#LINK_MODE="static"
if [[ "${LINK_MODE}" != "dynamic"  &&  "${LINK_MODE}" != "static" ]]; then
    echo "error: link mode can only be dynamic or static"
    exit 1
fi
if [ "${LINK_MODE}" == "dynamic" ]; then
    create_dynamic_manifest
    MANIFEST=main.dynamic.manifest
else
    create_static_manifest
    MANIFEST=main.static.manifest    
fi

# Previrtualize: can do eitther of these:
#slash --no-strip --work-dir=slash --keep-external=untouchables.funs.txt ${MANIFEST}
slash --no-strip --stats --use-pointer-analysis \
      --disable-inlining --inter-spec-policy=nonrec-aggressive \
      --work-dir=slash --keep-external=untouchables.vars.txt ${MANIFEST}
      
#debugging stuff below:
#echo "disassembling bitcode"
#for bitcode in slash/*.bc; do
#    llvm-dis  "$bitcode" &> /dev/null
#done
cp slash/libc.a-final.ll ./
cp slash/libc.a.ll ./
cp slash/main.o-final.ll  ./
cp slash/main.o.ll  ./
