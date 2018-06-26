CURLDIR= $(shell pwd)

MANIFEST_PREVIRT=curl.manifest.previrt
MANIFEST_SPECIALIZED=curl.manifest.specialized

#LLVMCC=wllvm
#LLVMGET=extract-bc

LLVMCC=gclang
LLVMGET=get-bc

all: previrt

CURL=curl-7.60.0
CURLURL=https://curl.haxx.se/download/${CURL}.tar.gz

curlgit:
	git clone https://github.com/curl/curl.git curlgit


install/bin/curl: curlgit
	cd curlgit; ./buildconf; CC=${LLVMCC} ./configure --enable-static --prefix=${CURLDIR}/install/; make; make install

bitcode: curl.bc libcurl.4.dylib.bc


curl.bc: install/bin/curl
	${LLVMGET} install/bin/curl
	mv install/bin/curl.bc .

libcurl.4.dylib.bc: install/bin/curl
	${LLVMGET} install/lib/libcurl.4.dylib
	mv install/lib/libcurl.4.dylib.bc .

specialized: bitcode_specialized slash_specialized

bitcode_specialized: curl.bc

.PHONY: slash_specialized
slash_specialized: 
	slash --no-strip --devirt --stats --work-dir=slash_specialized $(MANIFEST_SPECIALIZED)
	cp slash_specialized/curl curl_slash_specialized

previrt: bitcode_previrt slash_previrt

bitcode_previrt: curl.bc libcurl.4.dylib.bc

.PHONY: slash_previrt
slash_previrt: 
	slash --no-strip --devirt --stats --work-dir=slash_previrt $(MANIFEST_PREVIRT)
	cp slash_previrt/curl curl_slash_previrt


curl_orig:
	cp install/bin/curl curl_orig


test:
	./curl_slash_specialized http://apache.cs.utah.edu/httpd/httpd-2.4.33.tar.gz > httpd-2.4.33.tar.gz


clean:
	rm -rf slash_specialized slash_previrt httpd-2.4.33.tar.gz


very_clean:
	rm -rf curl_orig curl_slash curl_slash_specialized install
	make -C curlgit clean


spotless: very_clean
	rm -rf  *.bc curlgit ${CURLDIR}/install
