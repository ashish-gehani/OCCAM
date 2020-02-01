# Occam Interpreter #

The implementation is based on the LLVM interpreter 
`lib/ExecutionEngine/Interpreter`.

The main difference between the LLVM interpreter and ours is that the
latter allows a very limited form of non-determinism. The Occam
interpreter allows __unknown__ values as long as they are not used for
branching. If a branch depends on an unknown value the execution stops
there.

To deal with external calls, LLVM must be compiled with
`--enable-libffi`.

## Usage ## 

The name of the LLVM analysis pass is `Pconfig-prime`.  This pass
takes three parameters:

- `--Pconfig-prime-file`: the name of the program.
- `--Pconfig-prime-input-arg`: a program input. It supports multiple times
  `--Pconfig-prime-input-arg` per multiple inputs. 
- `--Pconfig-prime-unknown-args`: number of unknown parameters.

For instance, the command:

```
opt -load=/Users/E30338/Repos/SRI-CSL/OCCAM/lib/libSeaDsa.dylib \
    -load=/Users/E30338/Repos/SRI-CSL/OCCAM/lib/libDSA.dylib \
	-load=/Users/E30338/Repos/SRI-CSL/OCCAM/lib/libprevirt.dylib \
   ./tree.a.i.bc -o=/dev/null --Pconfig-prime --Pconfig-prime-file "tree" --Pconfig-prime-input-arg "./" 

```

executes the bitcode `tree.a.i.bc` with `./`. This should equivalent
to run `lli ./`, assuming FFI is enabled.

More interestingly, the Occam interpreter can be used if some input
parameters are not given. For instance, the command:

```
opt -load=/Users/E30338/Repos/SRI-CSL/OCCAM/lib/libSeaDsa.dylib \
    -load=/Users/E30338/Repos/SRI-CSL/OCCAM/lib/libDSA.dylib \
	-load=/Users/E30338/Repos/SRI-CSL/OCCAM/lib/libprevirt.dylib \
   ./tree.a.i.bc -o=/dev/null --Pconfig-prime --Pconfig-prime-file "tree" --Pconfig-prime-unknown-args=1

```

executes the bitcode `tree.a.i.bc` without making any assumption about
the directory name but it needs to know that there is only one missing
parameter (`--Pconfig-prime-unknown-args=1`).  This is the output:

```
About to interpret:   %tmp56 = icmp eq i8 %tmp55, 45
  Val=Unknown
About to interpret:   br i1 %tmp56, label %bb57, label %bb464
Stopped execution after 186 instructions
Finished execution after 186 instructions

```




