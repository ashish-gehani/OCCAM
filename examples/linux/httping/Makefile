# sudo apt-get install gettext
SRC=httping-2.5
TAR=${SRC}.tgz
URL=https://www.vanheusden.com/httping/${TAR}


all: httping_from_bitcode

${TAR}:
	wget ${URL}

${SRC}: ${TAR}
	tar xvfz ${TAR}

${SRC}/httping: ${SRC}
	cd ${SRC}; CC=gclang ./configure; CC=gclang make

httping.bc: ${SRC}/httping
	get-bc -m -o httping.bc ${SRC}/httping


httping_modules:
	mkdir httping_modules
	cp ${SRC}/.gen.o.bc httping_modules/gen.o.bc
	cp ${SRC}/.http.o.bc httping_modules/http.o.bc
	cp ${SRC}/.io.o.bc httping_modules/io.o.bc
	cp ${SRC}/.error.o.bc httping_modules/error.o.bc
	cp ${SRC}/.utils.o.bc httping_modules/utils.o.bc
	cp ${SRC}/.main.o.bc httping_modules/main.o.bc
	cp ${SRC}/.tcp.o.bc httping_modules/tcp.o.bc
	cp ${SRC}/.res.o.bc httping_modules/res.o.bc
	cp ${SRC}/.socks5.o.bc httping_modules/socks5.o.bc
	cp ${SRC}/.kalman.o.bc httping_modules/kalman.o.bc
	cp ${SRC}/.cookies.o.bc httping_modules/cookies.o.bc
	cp ${SRC}/.help.o.bc httping_modules/help.o.bc
	cp ${SRC}/.colors.o.bc httping_modules/colors.o.bc
	cp ${SRC}/.mssl.o.bc httping_modules/mssl.o.bc

httping_from_bitcode: httping_modules
	clang httping_modules/*.bc -lm -lssl -lcrypto -o httping_from_bitcode

clean:
	rm -rf *.bc *.bca *.manifest httping_from_bitcode httping_modules
	rm -rf slash_specialized
	make -C ${SRC} clean


spotless: clean
	rm -rf ${SRC} ${TAR}
