CC=gclang
BC_EXTRACT=get-bc

cat > manifest <<EOF
{ "main" : ".main.o.bc"
, "binary"  : "main_spec"
, "modules"    : []
, "native_libs" : []
, "ldflags" : [ "-O2" ]
, "name"    : "main.o"
, "static_args"    : ["rafae"]
, "lib_spec": [".testlib.o.bc"]
}
EOF

$CC main.c -Xclang -disable-O0-optnone -c -o main.o
$CC testlib.c -Xclang -disable-O0-optnone -c -o testlib.o

$BC_EXTRACT main.o
$BC_EXTRACT testlib.o


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log

slash --no-strip --intra-spec-policy=aggressive --work-dir=slash  manifest

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done



