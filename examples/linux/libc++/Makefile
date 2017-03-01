LLVM="http://llvm.org/svn/llvm-project/llvm/trunk"
LIBCXX="http://llvm.org/svn/llvm-project/libcxx/trunk"
LIBCXXABI="http://llvm.org/svn/llvm-project/libcxxabi/trunk"

all:  libc++.a.bc 

llvm:
	svn co ${LLVM} llvm

llvm/projects/libcxx: llvm
	cd llvm/projects/; svn co ${LIBCXX} libcxx

llvm/projects/libcxxabi: llvm/projects/libcxx
	cd llvm/projects/; svn co ${LIBCXXABI}  libcxxabi

build: llvm/projects/libcxxabi
	mkdir build; cd build; CC=wllvm CXX=wllvm++ cmake -DLIBCXX_ENABLE_SHARED=OFF  -DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=OFF ../llvm; make cxx; 


libc++.a.bc: build
	cd build/lib; extract-bc -b libc++.a; cp libc++.a.bc ../../


check:   build
	cd build; make check-libcxx check-libcxxabi

clean:
	rm -rf build

spotless: clean
	rm -rf llvm


.PHONY: clean check spotless

