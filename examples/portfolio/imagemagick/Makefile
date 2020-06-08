IMGDIR= $(shell pwd)

MANIFEST=imagemagick.manifest

#LLVMCC=wllvm
#LLVMGET=extract-bc
SLASH_ARGS ?=''
LLVMCC ?=gclang
LLVMCXX ?=gclang++
LLVMGET=get-bc

PREFIX ?= install

IMG_MAGICK_VERSION=7.0.8-68
IMG_MAGICK=ImageMagick-${IMG_MAGICK_VERSION}
IMG_MAGICK_TARBALL=${IMG_MAGICK}.tar.xz
IMG_MAGICK_URL=https://imagemagick.org/download/releases/${IMG_MAGICK_TARBALL}
IMG_MAGICK_INSTALL=${IMGDIR}/${PREFIX}

#iam: producing the library varies from OS to OS
OS   =  $(shell uname)
ifeq (Darwin, $(findstring Darwin, ${OS}))
#  DARWIN
LIBEXT=dylib
else
LIBEXT=so
endif

bitcode=magick.bc libMagickCore.bc libMagickWand.bc

all: bitcode 

${IMG_MAGICK_TARBALL}:
	wget ${IMG_MAGICK_URL}

${IMG_MAGICK_INSTALL}/bin/convert: ${IMG_MAGICK_TARBALL}
	tar -xvf ${IMG_MAGICK_TARBALL}
	cd ${IMG_MAGICK}; ./buildconf; CC=${LLVMCC} CXX=${LLVMCXX} ./configure --enable-static --prefix=${IMG_MAGICK_INSTALL}/; make -j4; make install


bitcode: ${IMG_MAGICK_INSTALL}/bin/convert
	cd ${IMG_MAGICK_INSTALL}/bin/ && \
	${LLVMGET} convert &&\
	cp ./magick.bc ${IMGDIR}

	cd ${IMG_MAGICK_INSTALL}/lib 	&& \
	${LLVMGET} libMagickCore-7.Q16HDRI.${LIBEXT}.6.0.0 && \
	${LLVMGET} libMagickWand-7.Q16HDRI.${LIBEXT}.6.0.0 && \
	cp libMagickCore-7.Q16HDRI.${LIBEXT}.6.0.0.bc ${IMGDIR}/libMagickCore.bc &&  \
	cp libMagickWand-7.Q16HDRI.${LIBEXT}.6.0.0.bc ${IMGDIR}/libMagickWand.bc

clean:
	rm -rf ${IMG_MAGICK}
	rm -f ${IMG_MAGICK_TARBALL}
realclean:
	make clean
	rm -f libMagickCore.bc	
	rm -f libMagickWand.bc
	rm -f magick.bc
	rm -f imagemagick.manifest
	rm -rf ${IMG_MAGICK_INSTALL}
	rm -rf slash
