WORKDIR=OCCAM

export OCCAM_LOGFILE=${PWD}/${WORKDIR}/occam.log
export OCCAM_LOGLEVEL=INFO

rm -rf ${WORKDIR}
mkdir -p ${WORKDIR}


cat > test.manifest <<EOF
{ "main" : ".main.o.bc"
, "binary"  : "main"
, "modules"    : [".test.o.bc"]
, "native_libs" : []
, "name"    : "main"
, "ldflags" : ["-O2"]
, "constraints" : ["1", "main"]
}
EOF

slash --stats --work-dir=${WORKDIR} test.manifest
