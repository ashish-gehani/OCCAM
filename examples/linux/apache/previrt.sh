#!/usr/bin/env bash

# clang-3.5 linked_httpd.bc -o linked_httpd -lpthread -ldl -lcrypt

# Build the manifest file
cat > httpd.manifest <<EOF
{ "modules" : ["httpd.bc"]
, "binary"  : "httpd"
, "libs"    : ["libapr-1.so.bc", "libaprutil-1.so.bc", "libpcre.so.bc", "libexpat.so.bc"]
, "native-libs" : ["-lcrypt", "-ldl", "-lpthread"]
, "args"    : ["-d", "/vagrant/www"]
, "search"  : ["/usr/lib/x86_64-linux-gnu/"]
, "name"    : "httpd"
}
EOF

# Previrtualize
${OCCAM_HOME}/bin/occam previrt --work-dir=previrt httpd.manifest

llvm-link-3.5 httpd.bc libapr-1.so.bc libaprutil-1.so.bc libpcre.so.bc libexpat.so.bc -o linked_httpd.bc

# Build the manifest file
cat > linked_httpd.manifest <<EOF
{ "modules" : ["linked_httpd.bc"]
, "binary"  : "linked_httpd"
, "native-libs" : ["-lcrypt", "-ldl", "-lpthread"]
, "args"    : ["-d", "/vagrant/www"]
, "search"  : ["/usr/lib/x86_64-linux-gnu/"]
, "name"    : "linked_httpd"
}
EOF

# Previrtualize
${OCCAM_HOME}/bin/occam previrt --work-dir=linked_previrt linked_httpd.manifest
