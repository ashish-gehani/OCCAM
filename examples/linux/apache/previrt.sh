#!/usr/bin/env bash

# Build the manifest file
cat > httpd.manifest <<EOF
{ "modules" : ["httpd.bc"]
, "binary"  : "httpd"
, "libs"    : ["libapr-1.so.bc",  "libaprutil-1.so.bc",  "libpcre.so.bc"]
, "native-libs" : ["-ldl", "-lpthread"]
, "search"  : ["/usr/lib/x86_64-linux-gnu/"]
, "args"    : ["-d", "/vagrant/www"]
, "name"    : "httpd"
}
EOF

# Previrtualize
${OCCAM_HOME}/bin/occam previrt --work-dir=previrt httpd.manifest


