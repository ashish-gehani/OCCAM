# Benchmark runner for OCCAM #

To run OCCAM on a set of benchmarks and show statistics, type:

	runbench.py 
	runbench.py --rop
	runbench.py --cpu=60 --mem=4096
	
By default, `runbench.py` runs OCCAM on the benchmarks and displays
the number of functions, number of instructions, etc. before and after
the specialization takes place.

The option `--rop` shows also the number of ROP, JOP, and SYS gadgets,
before and after specialization.

The options `--cpu` and `--mem` set limits on CPU (in seconds) and
memory (in MB) for running OCCAM. The compilation of the programs is
unlimited.

`runbench.py` reads from the `*.set` files to select which benchmarks
to run.  Each `*.set` file has a line per benchmark. Each line is a
relative path, wrt environment `OCCAM_HOME` variable, to a
directory. That directory must contain `Makefile` and `build.sh`. The
makefile generates the bitcode for the benchmark, and `build.sh` runs
OCCAM on it. The assumption is that after running `build.sh` two
executables are generated: one with suffix `_orig` and the other with
suffix `_slashed`. The executables are used by option `--rop` so it is
important to follow this convention.

For instance, the output of `runbench.py` might look like this:

```
Attack Surface Reduction: (B:before and A:after OCCAM)

Program    B Fun   A Fun   % Fun Red   B Ins    A Ins   % Ins Red   B Mem Ins   A Mem Ins   % Mem Ins Red
tree         106      93          12    7409     8921         -20        1615        1186              26
readelf      384     281          26   83390   111227         -33        6117        7714             -26
bzip2         92      41          55   22047    19055          13        4761        4303               9
mcf           43      22          48    2592     2388           7         654         488              25

Gadget Reduction: (B:before and A:after OCCAM)

Program    B ROP   A ROP   % ROP Red   B SYS   A SYS   % SYS Red   B JOP   A JOP   % JOP Red
tree         313     256          18       0       0           0      64      39          39
readelf     4007    3868           3       1       3        -200    2276     873          61
bzip2        479     971        -102       0       0           0      60     140        -133
mcf          168     115          31       0       0           0       0       0           0

```

`Red` means reduction. If the percentage is negative then it means
that there was an increase.


## Benchmark categories ## 

- `spec2006`: SPEC 2006 benchmarks
- `portfolio`: some real applications 
 


