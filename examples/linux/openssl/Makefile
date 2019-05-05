SRC="https://www.openssl.org/source/openssl-1.0.2h.tar.gz"

all: libcrypto.bca libssl.bca

openssl-1.0.2h.tar.gz:
	curl -L ${SRC} > openssl-1.0.2h.tar.gz

openssl-1.0.2h.tar: openssl-1.0.2h.tar.gz
	gunzip -k openssl-1.0.2h.tar.gz

openssl-1.0.2h: openssl-1.0.2h.tar
	tar xvf openssl-1.0.2h.tar

openssl: openssl-1.0.2h
	cd openssl-1.0.2h; CC=gclang ./config no-asm no-shared; make

libcrypto.bca: openssl
	cd openssl-1.0.2h; get-bc libcrypto.a; mv libcrypto.bca ../

libssl.bca: openssl
	cd openssl-1.0.2h; get-bc libssl.a; mv libssl.bca ../


clean:
	rm -rf openssl-1.0.2h openssl-1.0.2h.tar *.bca


spotless: clean
	rm openssl-1.0.2h.tar.gz
