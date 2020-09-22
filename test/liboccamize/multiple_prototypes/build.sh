CC=gclang
CPP=gclang++
BC_EXTRACT=get-bc

cat > manifest <<EOF
{ "main" : ".testlib.bc"
, "binary"  : "testlib"
, "modules"    : []
, "native_libs" : []
, "ldflags" : [ "-O2" ]
, "name"    : "testlib"
, "static_args"    : []
, "lib_spec": []
}
EOF

$CPP testlib.cpp -Xclang -disable-O0-optnone -c -o testlib
$BC_EXTRACT testlib


export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log

slash --no-strip --intra-spec-policy=aggressive --work-dir=slash --entry-point=add manifest

#debugging stuff below:
for bitcode in slash/*.bc; do
    ${LLVM_HOME}/bin/llvm-dis  "$bitcode" &> /dev/null
done



