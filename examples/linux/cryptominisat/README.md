To build the bc:
```
make
```


To test the bc:

```
llvm-link cryptominisat5.bc libc.so.bc -o cryptominisat5_app.bc
opt -O3 cryptominisat5_app.bc -o cryptominisat5_app_o3.bc
llc -filetype=obj cryptominisat5_app_o3.bc
clang -static -nostdlib cryptominisat5_app_o3.o crt1.o libc.a -o cryptominisat5_app_o3
```