# Prereqs: Make sure OCCAM envirnment is setup and WLLVM is installed
# env vars should be setup

# set CC to clang. Dragonegg works too
export LLVM_COMPILER=clang
export WLLVM_OUTPUT=WARNING

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL_DIR=${WORKING_DIR}/install

if [ -d "$INSTALL_DIR" ];
then
    echo "Install directory already exists. Skipped compilation ..."
else
    # download and fetch source
    wget http://lighttpd.net/download/lighttpd-1.4.13.tar.gz
    tar -zxf lighttpd-1.4.13.tar.gz
    cd lighttpd-1.4.13
    # configure without shared libs...will save headaches
    CC=gclang ./configure --without-openssl --without-pcre --without-zlib --without-bzip2 --prefix=${WORKING_DIR}/install
    CC=gclang make
    make install
fi

# Extract bitcode
get-bc ${INSTALL_DIR}/sbin/lighttpd 
mv ${INSTALL_DIR}/sbin/lighttpd.bc ${WORKING_DIR}

## Run Occam

cd ${WORKING_DIR}

# set up manifests
 cat > lhttpd.manifest <<EOF
{ "main" : "lighttpd.bc"
, "binary"  : "lighthttpd"
, "args"    : ["-D", "-m", "/", "-f", "myconf.conf"]
, "name"    : "lighttpd"
, "modules" : []
, "ldflags" : ["-flat_namespace", "-undefined", "suppress", "-ldl"] 
}

EOF

# finally...build specialized version
export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log

function usage() {
    echo "Usage: $0 [--disable-inlining] [--ipdse] [--ai-dce] [--devirt VAL1] [--inter-spec VAL2] [--intra-spec VAL2] [--enable-config-prime] [--help]"
    echo "       VAL1=none|dsa|cha_dsa"    
    echo "       VAL2=none|aggressive|nonrec-aggressive"
}

#default values
INTER_SPEC="none"
INTRA_SPEC="none"
DEVIRT="dsa"
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

INTRA_SPEC=none
INTER_SPEC=none
DEVIRT=none
SLASH_OPTS="--inter-spec-policy=${INTER_SPEC} --intra-spec-policy=${INTRA_SPEC} --devirt=${DEVIRT} --no-strip --stats $OPT_OPTIONS"

echo "=================================================================================="
echo " Running \"slash\" ${SLASH_OPTS} --work-dir=slash lhttpd.manifest "
echo "=================================================================================="

slash ${SLASH_OPTS} --work-dir=slash lhttpd.manifest 

status=$?
if [ $status -eq 0 ]
then
    cp slash/lighthttpd lighthttpd_slash
else
    echo "Something failed while running slash"
fi    
