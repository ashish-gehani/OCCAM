#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e

#FIXME avoid rebuilding.
#make
function usage() {
    echo "Usage: $0 [--disable-inlining] [--ipdse] [--ai-dce] [--use-pointer-analysis] [--inter-spec VAL] [--intra-spec VAL] [--link dynamic|static] [--help]"
    echo "       VAL=none|aggressive|nonrec-aggressive|onlyonce"
}


#default values
LINK="dynamic"
INTER_SPEC="onlyonce"
INTRA_SPEC="onlyonce"
OPT_OPTIONS=""

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -link|--link)
	LINK="$2"
	shift # past argument
	shift # past value
	;;    
    -inter-spec|--inter-spec)
	INTER_SPEC="$2"
	shift # past argument
	shift # past value
	;;
    -intra-spec|--intra-spec)
	INTRA_SPEC="$2"
	shift # past argument
	shift # past value
	;;
    -disable-inlining|--disable-inlining)
	OPT_OPTIONS="${OPT_OPTIONS} --disable-inlining"
	shift # past argument
	;;
    -ipdse|--ipdse)
	OPT_OPTIONS="${OPT_OPTIONS} --ipdse"
	shift # past argument
	;;
    -ai-dce|--ai-dce)
	OPT_OPTIONS="${OPT_OPTIONS} --ai-dce"
	shift # past argument
	;;            
    -use-pointer-analysis|--use-pointer-analysis)
	OPT_OPTIONS="${OPT_OPTIONS} --use-pointer-analysis"
	shift # past argument
	;;        
    -help|--help)
	usage
	exit 0
	;;
    *)    # unknown option
	POSITIONAL+=("$1") # save it in an array for later
	shift # past argument
	;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Check user inputs
if [[ "${LINK}" != "dynamic"  &&  "${LINK}" != "static" ]]; then
    echo "error: link can only be dynamic or static"
    exit 1
fi    

#check that the required dependencies are built
declare -a bitcode=("njs.bc" "libnjs.a.bc")

for bc in "${bitcode[@]}"
do
    if [ -a  "$bc" ]
    then
        echo "Found $bc"
    else
        echo "Error: $bc not found. Try \"make\"."
        exit 1
    fi
done

SLASH_OPTS="--inter-spec-policy=${INTER_SPEC} --intra-spec-policy=${INTRA_SPEC} --stats  $OPT_OPTIONS"

# OCCAM with program and libraries dynamically linked
function dynamic_link() {
    
    export OCCAM_LOGLEVEL=INFO
    export OCCAM_LOGFILE=${PWD}/slash/occam.log
    
    # Build the manifest file
    cat > njs.manifest <<EOF
{ "main" : "njs.bc"
, "binary"  : "njs_slashed"
, "modules"    : ["libnjs.a.bc"]
, "native_libs" : ["-lpcre", "-lreadline"]
, "static_args"    : ["-d", "hello_world.njs"]
, "name"    : "njs"
}
EOF

    echo "============================================================"
    echo "Running njs with libraries"
    echo "slash options ${SLASH_OPTS}"
    echo "============================================================"
    slash ${SLASH_OPTS} --work-dir=slash njs.manifest

    status=$?
    if [ $status -ne 0 ]
    then
	echo "Something failed while running slash"
	exit 1
    fi     
    cp slash/njs_slashed .
 }

# OCCAM with program and libraries statically linked
function static_link() {
    llvm-link njs.bc libnjs.a.bc -o linked_njs.bc

    # Build the manifest file
    cat > linked_njs.manifest <<EOF
{ "main" : "linked_njs.bc"
, "binary"  : "njs_static_linked_slashed"
, "modules"    : []
, "native_libs" : ["-lpcre", "-lreadline"]
, "static_args"    : ["-d", "hello_world.njs"]
, "name"    : "njs_linked"
}
EOF

    export OCCAM_LOGFILE=${PWD}/linked_slash/occam.log

    # OCCAM
    echo "============================================================"
    echo "Running njs with libraries statically linked"
    echo "slash options ${SLASH_OPTS}"
    echo "============================================================"
    slash ${SLASH_OPTS} --work-dir=linked_slash linked_njs.manifest
    status=$?
    if [ $status -ne 0 ]
    then
	echo "Something failed while running slash"
	exit 1
    fi
    cp linked_slash/njs_static_linked_slashed .
}

if [ "${LINK}" == "dynamic" ]; then
    dynamic_link 
else
    static_link
fi    
