Still need to get this to work smoothly on OSX (libtool issue and clang++ issue).

But it should work fine on linux.

There are quite a few duplicate symbols in curl.bc and libcurl.so.bc.

So instead of:

clang++ curl.bc libcurl.so.bc -o curl -lz -lcrypto -lssl -lpthread

we build in the ability to essentially do:

llvm-link -override curl.bc libcurl.so.bc -o almalgamation.bc

followed by

clang++ almalgamation.bc -o curl -lz -lcrypto -lssl -lpthread

This was achieved by adding the command line option  --amalgamate=<file_path> to slash.
