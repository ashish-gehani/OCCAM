opt -Oz -dce libc.so.bc -o libc-opt.so.bc
llvm-dis libc-opt.so.bc

opt -Oz -dce libc-no-asm.so.bc -o libc-no-asm-opt.so.bc
llvm-dis libc-no-asm-opt.so.bc

