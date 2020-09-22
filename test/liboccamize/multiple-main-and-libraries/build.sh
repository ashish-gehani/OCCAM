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
, "lib_spec": [".testlib1.o.bc",".testlib2.o.bc"]
, "main_spec": [".main1.o.bc",".main2.o.bc"]
}
EOF

$CC main.c -Xclang -disable-O0-optnone -c -o main.o
$CC main1.c -Xclang -disable-O0-optnone -c -o main1.o
$CC main2.c -Xclang -disable-O0-optnone -c -o main2.o
$CC testlib1.c -Xclang -disable-O0-optnone -c -o testlib1.o
$CC testlib2.c -Xclang -disable-O0-optnone -c -o testlib2.o


$BC_EXTRACT main.o
$BC_EXTRACT main1.o
$BC_EXTRACT main2.o
$BC_EXTRACT testlib1.o
$BC_EXTRACT testlib2.o



export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log

slash --no-strip --intra-spec-policy=aggressive --work-dir=slash  manifest

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done



