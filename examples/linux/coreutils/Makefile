#iam: change 'em check 'em both
COREUTILS=coreutils-8.24
COREURL=http://ftp.gnu.org/gnu/coreutils/${COREUTILS}.tar.xz

LLVMCC=gclang

all: ${COREUTILS}_build

${COREUTILS}.tar.xz:
	wget ${COREURL}

${COREUTILS}.tar: ${COREUTILS}.tar.xz
	unxz -k ${COREUTILS}.tar.xz

${COREUTILS}: ${COREUTILS}.tar
	tar xvf ${COREUTILS}.tar

${COREUTILS}_build: ${COREUTILS}
	mkdir -p ${COREUTILS}_build                                          && \
	cd ${COREUTILS}_build                                                && \
	CC=${LLVMCC} ../${COREUTILS}/configure --prefix=/vagrant/coreutils   && \
	CC=${LLVMCC} make

clean:
	rm -rf ${COREUTILS}_build

very_clean: clean
	rm -rf ${COREUTILS}


spotless: very_clean
	rm -f ${COREUTILS}.tar.xz ${COREUTILS}.tar
