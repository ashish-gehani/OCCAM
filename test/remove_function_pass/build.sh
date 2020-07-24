CC=wllvm
BC_EXTRACT=extract-bc

cat > manifest <<EOF
{ "main" : "main.bc"
, "binary"  : "main"
, "modules"    : []
, "native_libs" : []
, "ldflags" : [ "-O2" ]
, "name"    : "main"
, "args"    : []
}
EOF

$CC main.c -Xclang -disable-O0-optnone -c -o main
$BC_EXTRACT main


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log

slash --no-strip --intra-spec-policy=aggressive --work-dir=slash --remove-functions=fun,sun,done manifest

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done



