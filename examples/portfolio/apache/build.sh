#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e

#FIXME avoid rebuilding.
#make
function usage() {
    echo "Usage: $0 [--disable-inlining] [--devirt VAL1] [--inter-spec VAL2] [--intra-spec VAL2] [--link dynamic|static] [--help]"
    echo "       VAL1=none|dsa|cha_dsa"
    echo "       VAL2=none|aggressive|nonrec-aggressive"
}


#default values
LINK="dynamic"
INTER_SPEC="none"
INTRA_SPEC="none"
DEVIRT="dsa"
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
declare -a bitcode=("httpd.bc" "libapr-1.shared.bc" "libaprutil-1.shared.bc" "libpcre.shared.bc")

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
    export OCCAM_LOGFILE=${PWD}/slash/occam.log

    # Build the manifest file
    cat > httpd.manifest <<EOF
{ "main" : "httpd.bc"
, "binary"  : "httpd_slashed"
, "modules"    : ["libapr-1.shared.bc", "libaprutil-1.shared.bc", "libpcre.shared.bc"]
, "native_libs" : ["-lcrypt", "-ldl", "-lpthread", "-lexpat"]
, "args"    : ["-d", "/vagrant/www"]
, "name"    : "httpd"
}
EOF

    echo "============================================================"
    echo "Running httpd with dynamic libraries apr-1, aprutil-1 and pcre"
    echo "slash options ${SLASH_OPTS}                                 "
    echo "i.e.:                                                       "
    echo " slash ${SLASH_OPTS} --work-dir=slash httpd.manifest        "
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
    llvm-link httpd.bc libapr-1.shared.bc libaprutil-1.shared.bc libpcre.shared.bc -o linked_httpd.bc
    #FIXME: generate an executable to run ROPgadge on it
    #libexpat.shared.bc

    # Build the manifest file
    cat > linked_httpd.manifest <<EOF
{ "main" : "linked_httpd.bc"
, "binary"  : "httpd_static_linked_slashed"
, "modules"    : []
, "native_libs" : ["-lcrypt", "-ldl", "-lpthread", "-lexpat"]
, "args"    : ["-d", "/vagrant/www"]
, "name"    : "httpd_linked"
}
EOF

    export OCCAM_LOGFILE=${PWD}/linked_slash/occam.log

    # OCCAM
    echo "============================================================"
    echo "Running httpd with apr-1, aprutil-1 and pcre statically linked"
    echo "slash options ${SLASH_OPTS}"
    echo "============================================================"
    slash ${SLASH_OPTS} --work-dir=linked_slash linked_httpd.manifest
    status=$?
    if [ $status -ne 0 ]
    then
	echo "Something failed while running slash"
	exit 1
    fi
    cp linked_slash/httpd_static_linked_slashed .
}

if [ "${LINK}" == "dynamic" ]; then
    dynamic_link
else
    static_link
fi
