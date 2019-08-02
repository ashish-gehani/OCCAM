VERSION=1.60
SRC=net-tools-${VERSION}
#TAR=net-tools_1.60.orig.tar.gz
#URL=http://archive.ubuntu.com/ubuntu/pool/main/n/net-tools/net-tools_1.60.orig.tar.gz

all: netstat.bc

#need to uncomment the deb-src line in /etc/apt/sources.list
#the do an apt-get update
${SRC}: 
	apt-get source net-tools
	patch ${SRC}/hostname.c < hostname.patch
	patch ${SRC}/lib/inet_sr.c < inet_sr.patch
	cp config.h ${SRC}

${SRC}/netstat: ${SRC}
	cd ${SRC}; CC=gclang make

netstat.bc: ${SRC}/netstat
	get-bc -m -o netstat.bc ${SRC}/netstat

netstat_modules: netstat.bc
	mkdir netstat_modules
	cp ${SRC}/.netstat.o.bc netstat_modules/netstat.o.bc
	cp ${SRC}/.statistics.o.bc netstat_modules/statistics.o.bc
	cp ${SRC}/lib/.af.o.bc netstat_modules/af.o.bc
	cp ${SRC}/lib/.getroute.o.bc netstat_modules/getroute.o.bc
	cp ${SRC}/lib/.inet.o.bc netstat_modules/inet.o.bc
	cp ${SRC}/lib/.inet_gr.o.bc netstat_modules/inet_gr.o.bc
	cp ${SRC}/lib/.interface.o.bc netstat_modules/interface.o.bc
	cp ${SRC}/lib/.nstrcmp.o.bc netstat_modules/nstrcmp.o.bc
	cp ${SRC}/lib/.proc.o.bc netstat_modules/proc.o.bc
	cp ${SRC}/lib/.sockets.o.bc netstat_modules/sockets.o.bc
	cp ${SRC}/lib/.unix.o.bc netstat_modules/unix.o.bc
	cp ${SRC}/lib/.util.o.bc netstat_modules/util.o.bc
	cp ${SRC}/lib/.hw.o.bc netstat_modules/hw.o.bc
	cp ${SRC}/lib/.loopback.o.bc netstat_modules/loopback.o.bc
	cp ${SRC}/lib/.ether.o.bc netstat_modules/ether.o.bc

netstat_from_bitcode: netstat_modules
	clang netstat_modules/*.bc -o netstat_from_bitcode

clean:
	rm -rf netstat.bc  netstat.bc.llvm.manifest netstat_modules netstat_from_bitcode netstat_slashed  slash_specialized
	make -C  ${SRC} clean

spotless: clean
	rm -rf ${SRC} net-tools_1.60-26ubuntu1.diff.gz  net-tools_1.60-26ubuntu1.dsc  net-tools_1.60.orig.tar.gz
