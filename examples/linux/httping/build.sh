#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e


function usage() {
    echo "Usage: $0 [--disable-inlining] [--ipdse] [--use-crabopt] [--use-pointer-analysis] [--inter-spec VAL] [--intra-spec VAL] [--link dynamic|static] [--help]"
    echo "       VAL=none|aggressive|nonrec-aggressive"
}

#default values
INTER_SPEC="none"
INTRA_SPEC="none"
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
    -ipdse|--ipdse)
	OPT_OPTIONS="${OPT_OPTIONS} --ipdse"
	shift # past argument
	;;
    -use-crabopt|--use-crabopt)
	OPT_OPTIONS="${OPT_OPTIONS} --use-crabopt"
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


#check that the required dependencies are built
declare -a bitcode=(
	"httping_modules/gen.o.bc"
	"httping_modules/http.o.bc"
	"httping_modules/io.o.bc"
	"httping_modules/error.o.bc"
	"httping_modules/utils.o.bc"
	"httping_modules/main.o.bc"
	"httping_modules/tcp.o.bc"
	"httping_modules/res.o.bc"
	"httping_modules/socks5.o.bc"
	"httping_modules/kalman.o.bc"
	"httping_modules/cookies.o.bc"
	"httping_modules/help.o.bc"
	"httping_modules/colors.o.bc"
	"httping_modules/mssl.o.bc"
)

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

SLASH_OPTS="--inter-spec-policy=${INTER_SPEC} --intra-spec-policy=${INTRA_SPEC} --stats $OPT_OPTIONS"

# OCCAM with program and libraries dynamically linked
function dynamic_link() {

    export OCCAM_LOGLEVEL=INFO
    export OCCAM_LOGFILE=${PWD}/slash_specialized/occam.log

    rm -rf slash_specialized httping_slashed

    echo "============================================================"
    echo "Running httpd with dynamic libraries "
    echo "slash options ${SLASH_OPTS}"
    echo "============================================================"
    slash ${SLASH_OPTS} --work-dir=slash_specialized \
	  --amalgamate=slash_specialized/amalgamation.bc \
	  httping.json
    status=$?
    if [ $status -ne 0 ]
    then
	echo "Something failed while running slash"
	exit 1
    fi
    cp ./slash_specialized/httping_slashed .
}

dynamic_link
