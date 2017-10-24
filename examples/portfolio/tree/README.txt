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



    
