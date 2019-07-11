TAR=netperf-2.7.0.tar.gz
URL=https://github.com/HewlettPackard/netperf/archive/${TAR}
SRC=netperf-netperf-2.7.0


all: netperf.bc

${TAR}:
	wget ${URL}

${SRC}: ${TAR}
	tar xvfz ${TAR}

${SRC}/src/netperf: ${SRC}
	cd ${SRC}; CC=gclang ./configure; make

netperf.bc: ${SRC}/src/netperf modules
	cd ${SRC}/src; get-bc -m netperf; mv netperf.bc netperf.bc.llvm.manifest ../../


modules: ${SRC}/src/netperf
	cp ./netperf-netperf-2.7.0/src/.netperf.o.bc         netperf.o.bc 
	cp ./netperf-netperf-2.7.0/src/.netlib.o.bc          netlib.o.bc
	cp ./netperf-netperf-2.7.0/src/.netsh.o.bc           netsh.o.bc
	cp ./netperf-netperf-2.7.0/src/.nettest_bsd.o.bc     nettest_bsd.o.bc 
	cp ./netperf-netperf-2.7.0/src/.nettest_dlpi.o.bc    nettest_dlpi.o.bc
	cp ./netperf-netperf-2.7.0/src/.nettest_unix.o.bc    nettest_unix.o.bc
	cp ./netperf-netperf-2.7.0/src/.nettest_xti.o.bc     nettest_xti.o.bc
	cp ./netperf-netperf-2.7.0/src/.nettest_sctp.o.bc    nettest_sctp.o.bc
	cp ./netperf-netperf-2.7.0/src/.nettest_sdp.o.bc     nettest_sdp.o.bc
	cp ./netperf-netperf-2.7.0/src/.nettest_omni.o.bc    nettest_omni.o.bc
	cp ./netperf-netperf-2.7.0/src/.net_uuid.o.bc        net_uuid.o.bc 
	cp ./netperf-netperf-2.7.0/src/.dscp.o.bc            dscp.o.bc    
	cp ./netperf-netperf-2.7.0/src/.netcpu_procstat.o.bc netcpu_procstat.o.bc


test: modules
	clang netperf.o.bc netlib.o.bc netsh.o.bc nettest_bsd.o.bc nettest_dlpi.o.bc nettest_unix.o.bc nettest_xti.o.bc nettest_sctp.o.bc nettest_sdp.o.bc nettest_omni.o.bc net_uuid.o.bc dscp.o.bc  netcpu_procstat.o.bc -o netperf_from_bitcode -lm


clean:
	rm -rf *.bc *.llvm.manifest netperf_from_bitcode netperf_slashed  slash_specialized

spotless:
	rm -rf ${SRC} ${TAR}



.PHONY: modules
