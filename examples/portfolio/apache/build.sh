#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e

#FIXME avoid rebuilding.
#make
function usage() {
    echo "Usage: $0 [--disable-inlining] [--ipdse] [--ai-dce] [--devirt VAL1] [--inter-spec VAL2] [--intra-spec VAL2] [--link dynamic|static] [--help]"
    echo "       VAL1=none|sea_dsa"
    echo "       VAL2=none|aggressive|nonrec-aggressive|onlyonce"
}


#default values
LINK="dynamic"
INTER_SPEC="onlyonce"
INTRA_SPEC="onlyonce"
DEVIRT="sea_dsa"
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

# Check user inputs
if [[ "${LINK}" != "dynamic"  &&  "${LINK}" != "static" ]]; then
    echo "error: link can only be dynamic or static"
    exit 1
fi

#check that the required dependencies are built
declare -a bitcode=("httpd.bc" "libapr-1.shared.bc" "libaprutil-1.shared.bc" "libpcre.shared.bc" "libexpat.shared.bc")

echo "Checking all the bitcode files are available ..."
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
echo "OK!"

SLASH_OPTS="--inter-spec-policy=${INTER_SPEC} --intra-spec-policy=${INTRA_SPEC} --devirt=${DEVIRT} --stats $OPT_OPTIONS"

# OCCAM with program and libraries dynamically linked
function dynamic_link() {

    export OCCAM_LOGLEVEL=INFO
    export OCCAM_LOGFILE=${PWD}/slash/occam.log

    # Build the manifest file
    cat > httpd.manifest <<EOF
{ "main" : "httpd.bc"
, "binary"  : "httpd_slashed"
, "modules"    : ["libapr-1.shared.bc", "libaprutil-1.shared.bc", "libpcre.shared.bc","libexpat.shared.bc"]
, "native_libs" : ["-liconv", "-ldl", "-lpthread"]
, "args"    : ["-d", "/vagrant/www"]
, "name"    : "httpd"
}
EOF

    echo "============================================================"
    echo "Running slash ${SLASH_OPTS} --work-dir=slash httpd.manifest "
    echo "                                                            "    
    cat httpd.manifest
    echo "                                                            "
    echo "============================================================"
    slash ${SLASH_OPTS} --work-dir=slash httpd.manifest

    status=$?
    if [ $status -ne 0 ]
    then
	echo "Something failed while running slash"
	exit 1
    fi
    cp slash/httpd_slashed .
 }

# OCCAM with program and libraries statically linked
function static_link() {
    
    llvm-link httpd.bc libapr-1.shared.bc libaprutil-1.shared.bc \
	      libpcre.shared.bc libexpat.shared.bc -o combined_httpd.bc

    # Build the manifest file
    cat > combined_httpd.manifest <<EOF
{ "main" : "combined_httpd.bc"
, "binary"  : "httpd_static_combined_slashed"
, "modules"    : []
, "native_libs" : ["-liconv", "-ldl", "-lpthread"]
, "args"    : ["-d", "/vagrant/www"]
, "name"    : "httpd_combined"
}
EOF

    export OCCAM_LOGFILE=${PWD}/combined_slash/occam.log

    # OCCAM
    echo "============================================================"
    echo "Running slash ${SLASH_OPTS} --work-dir=combined_slash combined_httpd.manifest "
    echo "                                                            "    
    cat combined_httpd.manifest
    echo "                                                            "
    echo "============================================================"    
    slash ${SLASH_OPTS} --work-dir=combined_slash combined_httpd.manifest
    
    status=$?
    if [ $status -ne 0 ]
    then
	echo "Something failed while running slash"
	exit 1
    fi
    cp combined_slash/httpd_static_combined_slashed .
}

if [ "${LINK}" == "dynamic" ]; then
    dynamic_link
else
    static_link
fi
