# Prereqs: Make sure OCCAM envirnment is setup and WLLVM is installed
# env vars should be setup

# set CC to clang. Dragonegg works too
export LLVM_COMPILER=clang
export WLLVM_OUTPUT=WARNING

# download and fetch source
wget http://lighttpd.net/download/lighttpd-1.4.13.tar.gz
tar -zxf lighttpd-1.4.13.tar.gz
cd lighttpd-1.4.13

# configure without shared libs...will save headaches
CC=wllvm ./configure --without-openssl --without-pcre --without-zlib --without-bzip2 

CC=wllvm make

# extract bitcode
cd src
extract-bc lighttpd

# set up manifests
 cat > lhttpd.manifest <<EOF
{ "main" : "lighttpd.bc"
, "binary"  : "lighthttpd"
, "args"    : ["-D", "-m", "/", "-f", "myconf.conf"]
, "name"    : "lighttpd"
}

EOF

# finally...build specialized version
export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log

slash --work-dir=slash lhttpd.manifest

cp slash/lighthttpd lighthttpd_slash

# all done
