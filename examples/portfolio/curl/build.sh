#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e

function usage() {
    echo "Usage: $0 [--disable-inlining] [--ipdse] [--ai-dce] [--devirt VAL1] [--inter-spec VAL2] [--intra-spec VAL2] [--enable-config-prime] [--link dynamic|static] [--help]"
    echo "       VAL1=none|sea_dsa"    
    echo "       VAL2=none|aggressive|nonrec-aggressive|onlyonce"
}

#default values
INTER_SPEC="onlyonce"
INTRA_SPEC="onlyonce"
DEVIRT="sea_dsa"
OPT_OPTIONS=""

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
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
    -enable-config-prime|--enable-config-prime)
	OPT_OPTIONS="${OPT_OPTIONS} --enable-config-prime"
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
    -devirt|--devirt)
	DEVIRT="$2"
	shift # past argument
	shift # past value
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

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    LIBCURL="libcurl.so.bc"    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    LIBCURL="libcurl.dylib.bc"
else
    # some default value 
    LIBCURL="libcurl.so.bc"    
fi     

#check that the required dependencies are built
declare -a bitcode=("curl.bc" ${LIBCURL})

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


SLASH_OPTS="--inter-spec-policy=${INTER_SPEC} --intra-spec-policy=${INTRA_SPEC} --devirt=${DEVIRT} --stats $OPT_OPTIONS"

# OCCAM with program and libraries dynamically linked
function dynamic_link() {

    export OCCAM_LOGLEVEL=INFO
    export OCCAM_LOGFILE=${PWD}/slash_specialized/occam.log

    rm -rf slash_specialized curl_slashed

    # Build the manifest file
    cat > curl.manifest.specialized <<EOF
{ "main" : "curl.bc"
, "binary"  : "curl"
, "modules"    : [ "${LIBCURL}" ]
, "native_libs" : [ ]
, "ldflags" : [ "-O2", "-lpthread", "-lz", "-lcrypto", "-lssl" ]
, "name"    : "curl"
, "constraints" : [1, "curl", "--compressed", "--http1.1", "--ipv4"]
}
EOF

    echo "============================================================"
    echo "Running httpd with dynamic libraries "
    echo "slash options ${SLASH_OPTS}"
    echo "============================================================"
    slash ${SLASH_OPTS} --work-dir=slash_specialized \
	  --amalgamate=slash_specialized/amalgamation.bc \
	  curl.manifest.specialized
    status=$?
    if [ $status -ne 0 ]
    then
	echo "Something failed while running slash"
	exit 1
    fi     
    cp ./slash_specialized/curl_slashed .
}

dynamic_link
