cp ../previrt/nweb*-final.bc  nweb-final.bc
cp ../previrt/*libc.so-final.bc libc.so-final.bc

llvm-link nweb-final.bc libc.so-final.bc -o static.bc

llc -filetype=obj static.bc

MUSL=../../../../../musllvm
SRC=${MUSL}/src


clang -nostdlib static.o ${SRC}/internal/LLVM/syscall.s ${SRC}/setjmp/LLVM/setjmp.s ${SRC}/setjmp/LLVM/longjmp.s ${SRC}/thread/LLVM/clone.s ${SRC}/thread/LLVM/syscall_cp.s ${SRC}/thread/LLVM/__set_thread_area.s ${SRC}/thread/LLVM/__unmapself.s main.s -o static.exe



#clang -nostdlib static.o ../../../../../musllvm/src/internal/LLVM/syscall.s ../../../../../musllvm/src/setjmp/LLVM/setjmp.s ../../../../../musllvm/src/setjmp/LLVM/longjmp.s ../../../../../musllvm/src/thread/LLVM/clone.s ../../../../../musllvm/src/thread/LLVM/syscall_cp.s ../../../../../musllvm/src/thread/LLVM/__set_thread_area.s ../../../../../musllvm/src/thread/LLVM/__unmapself.s main.s -o static.exe ../../../../../musllvm/src/string/.memcpy.bc
