MANIFEST=tree.manifest.constraints

all: tree_slash

THISDIR =  $(shell pwd)
OS      =  $(shell uname)
ARCH    =  $(shell uname -p)


TREE_VERSION ?= 1.7.0

TREE=tree-${TREE_VERSION}
TREE_TARBALL=${TREE_VERSION}.tar.gz
TREE_URL=https://github.com/SRI-CSL/tree/archive/${TREE_TARBALL}
TREE_INSTALL=${THISDIR}/install/zlib

https://github.com/SRI-CSL/tree/archive/1.7.0.tar.gz

LLVMCC ?= gclang
LLVMGET ?= get-bc

ifeq (Darwin, $(findstring Darwin, ${OS}))

LIBEXT=dylib
MAKEFILE=Makefile.darwin

else

LIBEXT=so
MAKEFILE=Makefile.darwin

endif


BITCODE = tree.bc

all: ${BITCODE}

${TREE_TARBALL}:
	wget ${TREE_URL}

${TREE}: ${TREE_TARBALL}
	tar xvfz ${TREE_TARBALL}

${TREE}/tree: ${TREE}
	cp Makefile.darwin ${TREE}
	cp tree_tweaked.c ${TREE}/tree.c
	cd ${TREE}; CC=${LLVMCC} make -f ${MAKEFILE}

tree.bc: ${TREE}/tree
	${LLVMGET} ${TREE}/tree
	cp ${TREE}/tree.bc .


slash: tree.bc
	slash --no-strip --stats --devirt --work-dir=slash ${MANIFEST}

tree_slash: slash
	cp slash/tree tree_slash
	cp ${TREE}/tree tree_orig

#compile_tweaked: tree
#	cp Makefile.darwin tree
#	cp tree_tweaked.c ${TREE}/tree.c
#	cd ${TREE}; CC=${LLVMCC} make -f Makefile.darwin

#compile_tweaked_2: tree
#	cp tree_tweaked_2.c ${TREE}/tree.c
#	cd ${TREE}; CC=${LLVMCC} make -f Makefile.darwin

#tree_slash_tweaked: clean compile_tweaked slash
#	cp slash/tree tree_slash_tweaked


clean:
	rm -rf tree.bc slash

very_clean: clean
	rm -rf tree_slash tree_orig tree_slash_tweaked
	make -C ${TREE} clean
	rm -rf ${TREE}

spotless: very_clean
	rm -rf ${TREE_TARBALL}
