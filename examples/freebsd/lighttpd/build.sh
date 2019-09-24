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
, "ldflags" : ["-flat_namespace", "-undefined", "suppress"] 
}

EOF

# finally...build specialized version
export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log

INTRA_SPEC=none
INTER_SPEC=none
DEVIRT=none
SLASH_OPTS="--inter-spec-policy=${INTER_SPEC} --intra-spec-policy=${INTRA_SPEC} --devirt=${DEVIRT} --no-strip --stats"

echo "=================================================================================="
echo " Running \"slash\" ${SLASH_OPTS} --work-dir=slash lhttpd.manifest "
echo "=================================================================================="

slash ${SLASH_OPTS} --work-dir=slash lhttpd.manifest 

cp slash/lighthttpd lighthttpd_slash

# all done
