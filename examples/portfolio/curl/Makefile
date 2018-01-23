CURLDIR= $(shell pwd)



curlgit:
	git clone https://github.com/curl/curl.git curlgit


install/bin/curl:
	cd curlgit; ./buildconf; CC=gclang ./configure --prefix=${CURLDIR}/install/; make; make install

curl.bc: install/bin/curl
	get-bc install/bin/curl
	mv install/bin/curl.bc .



curl.bc:




