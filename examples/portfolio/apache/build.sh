#!/usr/bin/env bash

#FIXME avoid rebuilding.
#make

export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log


# Build the manifest file
cat > httpd.manifest <<EOF
{ "main" : "httpd.bc"
, "binary"  : "httpd_slashed"
, "modules"    : ["libapr-1.so.bc", "libaprutil-1.so.bc", "libpcre.so.bc"]
, "native_libs" : ["-lcrypt", "-ldl", "-lpthread", "-lexpat"]
, "args"    : ["-d", "/vagrant/www"]
, "name"    : "httpd"
}
EOF
#, "libexpat.so.bc"

# Previrtualize
slash --stats --devirt --work-dir=slash httpd.manifest

cp slash/httpd_slashed .

llvm-link httpd.bc libapr-1.so.bc libaprutil-1.so.bc libpcre.so.bc -o linked_httpd.bc
#libexpat.so.bc

# Build the manifest file
cat > linked_httpd.manifest <<EOF
{ "main" : "linked_httpd.bc"
, "binary"  : "httpd_linked"
, "modules"    : []
, "native_libs" : ["-lcrypt", "-ldl", "-lpthread", "-lexpat"]
, "args"    : ["-d", "/vagrant/www"]
, "name"    : "httpd_linked"
}
EOF

export OCCAM_LOGFILE=${PWD}/linked_slash/occam.log

# Previrtualize
slash --work-dir=linked_slash --stats --devirt linked_httpd.manifest

cp linked_slash/httpd_linked .
