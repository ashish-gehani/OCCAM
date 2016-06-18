wllvm ../nweb.c -o nweb
extract-bc nweb

llvm-link nweb.bc ../libc.so.bc -o static.bc

llc -filetype=obj static.bc

MUSL=../../../../../musllvm
SRC=${MUSL}/src

clang -nostdlib static.o ${SRC}/internal/LLVM/syscall.s ${SRC}/setjmp/LLVM/setjmp.s ${SRC}/setjmp/LLVM/longjmp.s ${SRC}/thread/LLVM/clone.s ${SRC}/thread/LLVM/syscall_cp.s ${SRC}/thread/LLVM/__set_thread_area.s ${SRC}/thread/LLVM/__unmapself.s main.s -o static.exe



