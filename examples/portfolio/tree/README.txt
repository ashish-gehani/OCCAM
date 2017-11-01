The source package Makefile needs to be edited:

hardcoded gcc needs to be deleted.
platform stuff needs to be uncommented.


Ian chose this example because it is a nice visual program.
Lots of command line options.
Uses a homegrown commandline parsing routine.

can specialize tree to stree:

"tree -J -h"  #list in json format, include sizes

which outputs in json format.  The resulting progarm
still has useful options. If we conflate the extra command line options
into one -XXXX we only need a specialized argc of 1.

Examples:

stree -d    #list only directories

stree -dl   #list only directories (follow links)


stree -dlf  #list only directories (full paths)

The tree program has three output modes:

- json
- html
- xml

We specialized with -J option so the output should be in json. This
works. However, if we pass the -X flag to the specialized program
turns the output to xml. This should not happen with the specialized
version. The reason is that there is a switch case that when a flag is
enabled the rest are not disabled, even if they are supposed to be
mutually exclusive. This avoids specialization removing code that
depends on the unused flags. We have tweaked the program so that each
time a output flag is enabled the rest of mutually exclusive output
flags are disabled. This solves our problem.

A last problem is that even if our tweaked specialized program does
not output html or xml format anymore we have not seen an elimination of the
html or xml routines. The problem is that the flags are global
variables in llvm bitcode and therefore they are pointers. Dead code
elimination and constant propagation passed do not reason about such
objects. Therefore they do not remove that code.

The solution is something on which we are currently work. Extend these
LLVM passes so that they can reason about some memory locations.



    
