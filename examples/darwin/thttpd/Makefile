SRC="http://acme.com/software/thttpd/thttpd-2.27.tar.gz"

all: thttpd.bc

thttpd-2.27.tar.gz:
	curl -L ${SRC} > thttpd-2.27.tar.gz


thttpd-2.27.tar: thttpd-2.27.tar.gz
	gunzip -k thttpd-2.27.tar.gz

thttpd-2.27: thttpd-2.27.tar
	tar xvf thttpd-2.27.tar
	cd thttpd-2.27; patch -R < ../config.sub.diff; patch -R < ../config.guess.diff

thttpd.bc: thttpd-2.27
	cd thttpd-2.27; CC=wllvm ./configure; make; extract-bc thttpd; mv thttpd.bc ..
	cp thttpd-2.27/thttpd thttpd


clean:
	rm -rf thttpd-2.27 thttpd-2.27.tar thttpd.bc thttpd

spotless: clean
	rm  -f thttpd-2.27.tar.gz

.PHONY: clean distclean
