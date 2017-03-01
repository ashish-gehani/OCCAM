#iam: change 'em check 'em both
GMP=gmp-6.1.1
GMPURL=https://gmplib.org/download/gmp/${GMP}.tar.xz

all: ${GMP}_build

${GMP}.tar.xz:
	wget ${GMPURL}

${GMP}.tar: ${GMP}.tar.xz
	unxz -k ${GMP}.tar.xz

${GMP}: ${GMP}.tar
	tar xvf ${GMP}.tar

${GMP}_build: ${GMP}
	mkdir -p ${GMP}_build                                      && \
	cd ${GMP}_build                                            && \
	CC=wllvm ../${GMP}/configure  --disable-assembly           && \
	CC=wllvm make 	                                                 

clean:
	rm -rf ${GMP}_build 

very_clean: clean
	rm -rf ${GMP}


spotless: very_clean
	rm -f ${GMP}.tar.xz ${GMP}.tar

