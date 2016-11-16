#!/usr/bin/env bash

make

export OCCAM_LOGLEVEL=INFO
export OCCAM_LOGFILE=${PWD}/slash/occam.log


# Build the manifest file
cat > httpd.manifest <<EOF
{ "modules" : ["httpd.bc"]
, "binary"  : "httpd"
, "libs"    : ["libapr-1.so.bc", "libaprutil-1.so.bc", "libpcre.so.bc"]
, "native_libs" : ["-lcrypt", "-ldl", "-lpthread"]
, "args"    : ["-d", "/vagrant/www"]
, "search"  : ["/usr/lib/x86_64-linux-gnu/"]
, "name"    : "httpd"
}
EOF
#, "libexpat.so.bc"

# Previrtualize
slash --work-dir=slash httpd.manifest

llvm-link httpd.bc libapr-1.so.bc libaprutil-1.so.bc libpcre.so.bc -o linked_httpd.bc
#libexpat.so.bc 

# Build the manifest file
cat > linked_httpd.manifest <<EOF
{ "modules" : ["linked_httpd.bc"]
, "binary"  : "linked_httpd"
, "libs"    : []
, "native_libs" : ["-lcrypt", "-ldl", "-lpthread"]
, "args"    : ["-d", "/vagrant/www"]
, "search"  : ["/usr/lib/x86_64-linux-gnu/"]
, "name"    : "linked_httpd"
}
EOF

export OCCAM_LOGFILE=${PWD}/linked_slash/occam.log

# Previrtualize
slash --work-dir=linked_slash linked_httpd.manifest
