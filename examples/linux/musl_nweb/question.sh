opt -Oz -dce libc.so.bc -o libc-opt.so.bc
llvm-dis libc-opt.so.bc

