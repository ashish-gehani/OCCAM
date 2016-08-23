SRC="http://acme.com/software/thttpd/thttpd-2.27.tar.gz"

all: thttpd

thttpd-2.27.tar.gz:
	curl -L ${SRC} > thttpd-2.27.tar.gz


thttpd-2.27.tar: thttpd-2.27.tar.gz
	gunzip -k thttpd-2.27.tar.gz

thttpd-2.27: thttpd-2.27.tar
	tar xvf thttpd-2.27.tar

thttpd.bc: thttpd-2.27
	cd thttpd-2.27; CC=wllvm ./configure; make; extract-bc thttpd; mv thttpd.bc ..


thttpd: thttpd.bc
	make -C ../musllvm
	cp ../musllvm/libc.a.bc ../musllvm/crt1.o ../musllvm/libc.a .
	clang -static -nostdlib thttpd.bc libc.a.bc crt1.o libc.a -o thttpd

clean:
	rm -rf thttpd-2.27 thttpd-2.27.tar thttpd.bc thttpd

distclean: clean
	rm  -f thttpd-2.27.tar.gz libc.a.bc crt1.o libc.a

.PHONY: clean distclean





