#sudo apt-get install build-essential autoconf automake libtool pkg-config libnl-3-dev libnl-genl-3-dev libssl-dev ethtool shtool rfkill zlib1g-dev libpcap-dev libsqlite3-dev libpcre3-dev libhwloc-dev libcmocka-dev


TAR=1.5.2.tar.gz
URL=https://github.com/aircrack-ng/aircrack-ng/archive/${TAR}
SRC=aircrack-ng-1.5.2

all: airtun-ng.bc

${TAR}:
	wget ${URL}

${SRC}: ${TAR}
	tar xvfz ${TAR}

${SRC}/src/.libs/airtun-ng: ${SRC}
	cd ${SRC}; autoreconf -i; CC=gclang ./configure; make

airtun-ng.bc: ${SRC}/src/.libs/airtun-ng modules
	get-bc -m -o airtun-ng.bc ${SRC}/src/.libs/airtun-ng

libaircrack-osdep-1.3.0.so.bc:
	get-bc -m -b -o libaircrack-osdep-1.3.0.so.bc ${SRC}/src/aircrack-osdep/.libs/libaircrack-osdep-1.3.0.so



modules: airtun-ng.bc libaircrack-osdep-1.3.0.so.bc
#airtun-ng.bc
	cp ${SRC}/src/.airtun_ng-airtun-ng.o.bc airtun_ng-airtun-ng.o.bc
	cp ${SRC}/src/.libs/.libaclib_la-crypto.o.bc libaclib_la-crypto.o.bc
	cp ${SRC}/src/aircrack-util/.libs/.libaircrack_util_la-common.o.bc libaircrack_util_la-common.o.bc
#libaircrack-osdep-1.3.0.so:
	cp ${SRC}/src/aircrack-osdep/.libs/.libaircrack_osdep_la-osdep.o.bc libaircrack_osdep_la-osdep.o.bc
	cp ${SRC}/src/aircrack-osdep/.libs/.libaircrack_osdep_la-network.o.bc libaircrack_osdep_la-network.o.bc
	cp ${SRC}/src/aircrack-osdep/.libs/.libaircrack_osdep_la-file.o.bc libaircrack_osdep_la-file.o.bc
	cp ${SRC}/src/aircrack-osdep/.libs/.libaircrack_osdep_la-linux.o.bc libaircrack_osdep_la-linux.o.bc
	cp ${SRC}/src/aircrack-osdep/.libs/.libaircrack_osdep_la-linux_tap.o.bc libaircrack_osdep_la-linux_tap.o.bc
	cp ${SRC}/src/aircrack-osdep/.libs/.libaircrack_osdep_la-common.o.bc libaircrack_osdep_la-common.o.bc
	cp ${SRC}/src/aircrack-osdep/radiotap/.libs/.radiotap.o.bc radiotap.o.bc


test: modules
	clang airtun_ng-airtun-ng.o.bc libaclib_la-crypto.o.bc libaircrack_util_la-common.o.bc libaircrack_osdep_la-osdep.o.bc libaircrack_osdep_la-network.o.bc libaircrack_osdep_la-file.o.bc libaircrack_osdep_la-linux.o.bc libaircrack_osdep_la-linux_tap.o.bc libaircrack_osdep_la-common.o.bc radiotap.o.bc -lm -lcrypto -ldl -lnl-3 -lnl-genl-3 -o airtun_ng_from_bitcode

clean:
	rm -rf *.bc *.llvm.manifest airtun_ng_from_bitcode slash_specialized
	make -C  ${SRC} clean


spotless: clean
	rm -rf ${SRC} ${TAR}

.PHONY: modules clean  spotless
