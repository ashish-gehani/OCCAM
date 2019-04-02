#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e

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
declare -a bitcode=("ssh.bc" "libcrypto.a.bc" "libz.a.bc")

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


#echo "Linking ssh_from_bc"
#clang++ ssh.bc libcrypto.a.bc libz.a.bc -ldl -lresolv -o ssh_from_bc

#echo "Linking sshd_from_bc"
#clang++ sshd.bc libcrypto.a.bc libz.a.bc -ldl -lresolv -o sshd_from_bc

# additional debug flags:
#  --debug-pass=sroa --verbose --debug-manager=Structure
SLASH_OPTS="--inter-spec-policy=${INTER_SPEC} --intra-spec-policy=${INTRA_SPEC} --devirt=${DEVIRT} --stats $OPT_OPTIONS"

# OCCAM with program and libraries dynamically linked
function dynamic_link() {

    export OCCAM_LOGLEVEL=INFO
    export OCCAM_LOGFILE=${PWD}/slash/occam.log

    rm -rf slash ssh_slashed

    # Build the manifest file
    cat > ssh.manifest <<EOF
{ "main" : "ssh.bc"
, "binary"  : "ssh_slashed"
, "modules"    : ["libcrypto.a.bc", "libz.a.bc"]
, "native_libs" : ["-ldl", "-lresolv"]
, "name"    : "ssh"
, "constraints" : ["1", "-Y", "-4"]
}
EOF

    echo "============================================================"
    echo "Running httpd with dynamic libraries crypto, z"
    echo "slash options ${SLASH_OPTS}"
    echo "============================================================"
    slash ${SLASH_OPTS} --work-dir=slash ssh.manifest
    status=$?
    if [ $status -ne 0 ]
    then
	echo "Something failed while running slash"
	exit 1
    fi     
    cp ./slash/ssh_slashed .
}

# OCCAM with program and libraries statically linked
function static_link() {
    llvm-link ssh.bc libcrypto.a.bc libz.a.bc -o linked_ssh.bc
    # Build the manifest file
    cat > linked_ssh.manifest <<EOF
{ "main" : "linked_ssh.bc"
, "binary"  : "ssh_static_slashed"
, "modules"    : []
, "native_libs" : ["-ldl", "-lresolv"]
, "name"    : "ssh"
, "constraints" : ["1", "-Y", "-4"]
}
EOF

    echo "============================================================"
    echo "Running httpd with libraries crypto, z statically linked"
    echo "slash options ${SLASH_OPTS}"
    echo "============================================================"
    slash ${SLASH_OPTS} --work-dir=slash linked_ssh.manifest
    status=$?
    if [ $status -ne 0 ]
    then
	echo "Something failed while running slash"
	exit 1
    fi     
    cp ./slash/ssh_static_slashed .
}

if [ "${LINK}" == "dynamic" ]; then
    dynamic_link 
else
    static_link
fi    

