#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e


function usage() {
    echo "Usage: $0 [--disable-inlining] [--ipdse] [--ai-dce] [--use-pointer-analysis] [--inter-spec VAL] [--intra-spec VAL] [--link dynamic|static] [--help]"
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


#check that the required dependencies are built
declare -a bitcode=(
	"readelf_modules/readelf.o.bc"
	"readelf_modules/version.o.bc"
	"readelf_modules/unwind-ia64.o.bc"
	"readelf_modules/dwarf.o.bc"
	"readelf_modules/elfcomm.o.bc"
	"readelf_modules/argv.o.bc"
	"readelf_modules/concat.o.bc"
	"readelf_modules/dwarfnames.o.bc"
	"readelf_modules/lbasename.o.bc"
	"readelf_modules/lrealpath.o.bc"
	"readelf_modules/safe-ctype.o.bc"
	"readelf_modules/xexit.o.bc"
	"readelf_modules/xmalloc.o.bc"
	"readelf_modules/xstrdup.o.bc"
	"readelf_modules/libz_a-inflate.o.bc"
	"readelf_modules/libz_a-inftrees.o.bc"
	"readelf_modules/libz_a-zutil.o.bc"
	"readelf_modules/libz_a-adler32.o.bc"
	"readelf_modules/libz_a-crc32.o.bc"
	"readelf_modules/libz_a-inffast.o.bc"
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

SLASH_OPTS="--inter-spec-policy=${INTER_SPEC} --intra-spec-policy=${INTRA_SPEC} --use-pointer-analysis --stats $OPT_OPTIONS"

# OCCAM with program and libraries dynamically linked
function dynamic_link() {

    export OCCAM_LOGLEVEL=INFO
    export OCCAM_LOGFILE=${PWD}/readelf_slash_specialized/occam.log

    rm -rf readelf_slash_specialized readelf_slashed

    echo "============================================================"
    echo "Running httpd with dynamic libraries "
    echo "slash options ${SLASH_OPTS}"
    echo "============================================================"
    slash ${SLASH_OPTS} --work-dir=readelf_slash_specialized \
	  --amalgamate=readelf_slash_specialized/amalgamation.bc \
	  readelf.json
    status=$?
    if [ $status -ne 0 ]
    then
	echo "Something failed while running slash"
	exit 1
    fi
    cp ./readelf_slash_specialized/readelf_slashed .
}

dynamic_link
