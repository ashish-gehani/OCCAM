CURLDIR= $(shell pwd)

#MANIFEST=curl.manifest.previrt
MANIFEST=curl.manifest.specialized

all: slash


curlgit:
	git clone https://github.com/curl/curl.git curlgit


install/bin/curl:
	cd curlgit; ./buildconf; CC=gclang ./configure --prefix=${CURLDIR}/install/; make; make install

bitcode: curl.bc libcurl.4.dylib.bc


curl.bc: install/bin/curl
	get-bc install/bin/curl
	mv install/bin/curl.bc .

libcurl.4.dylib.bc: install/bin/curl
	get-bc install/lib/libcurl.4.dylib
	mv install/lib/libcurl.4.dylib.bc .



slash: curl.bc libcurl.4.dylib.bc
	slash --no-strip --work-dir=slash $(MANIFEST)
	cp slash/curl curl_slash
	cp install/bin/curl curl_orig


clean:
	rm -rf  slash




