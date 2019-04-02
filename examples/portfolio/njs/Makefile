COMPILER=gclang
EXTRACT_BC=get-bc
CURDIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

all: njs.bc 

njs:
	git clone https://github.com/nginx/njs.git

njs/njs: njs
	cd njs; CC=${COMPILER} ./configure ; make

njs.bc: njs/njs
	cd njs/build; \
	${EXTRACT_BC} njs; \
	${EXTRACT_BC} -b libnjs.a; \
	cp .njs.bc ../../njs.bc; \
	cp libnjs.a.bc ../../

##XXX: libnjs contains all the file that libnxt contains.
# njs.bc: njs/njs
# 	cd njs/build; \
# 	${EXTRACT_BC} njs; \
# 	${EXTRACT_BC} -b libnjs.a; \
# 	${EXTRACT_BC} -b libnxt.a; \
# 	cp .njs.bc ../../njs.bc; \
# 	cp libnjs.a.bc ../../; \
# 	cp libnxt.a.bc ../../

.PHONY: slash
slash:
	${CURDIR}/build.sh

clean:
	rm -rf slash
	rm -f *.bc
	rm -f njs.manifest
	rm -f njs_slashed njs_static_linked_slashed

distclean: clean
	rm -rf njs.bc njs_slash njs
