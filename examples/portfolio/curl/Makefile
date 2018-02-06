CURLDIR= $(shell pwd)

MANIFEST_PREVIRT=curl.manifest.previrt
MANIFEST_SPECIALIZED=curl.manifest.specialized

#WLLVM=wllvm
#EXTRACT_BC=extract-bc
#
WLLVM=gclang
EXTRACT_BC=get-bc

all: slash_specialized slash_previrt


curlgit:
	git clone https://github.com/curl/curl.git curlgit


install/bin/curl:
	cd curlgit; ./buildconf; CC=${WLLVM} ./configure --enable-static --prefix=${CURLDIR}/install/; make -V=1; make install

bitcode: curl.bc libcurl.4.dylib.bc


curl.bc: install/bin/curl
	${EXTRACT_BC} install/bin/curl
	mv install/bin/curl.bc .

libcurl.4.dylib.bc: install/bin/curl
	${EXTRACT_BC} install/lib/libcurl.4.dylib
	mv install/lib/libcurl.4.dylib.bc .


slash_specialized: curl.bc 
	slash --no-strip --work-dir=slash_specialized $(MANIFEST_SPECIALIZED)
	cp slash_specialized/curl curl_slash_specialized

slash_previrt: curl.bc libcurl.4.dylib.bc
	slash --no-strip --work-dir=slash_previrt $(MANIFEST_PREVIRT)
	cp slash_previrt/curl curl_slash_previrt


curl_orig:
	cp install/bin/curl curl_orig

clean:
	rm -rf  slash_specialized slash_previrt




