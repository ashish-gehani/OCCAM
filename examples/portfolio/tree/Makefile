MANIFEST=tree.manifest.constraints

all: tree_slash


COMPILER=wllvm
EXTRACT_BC=extract-bc

#COMPILER=gclang
#EXTRACT_BC=get-bc


tree:
	git clone git://anonscm.debian.org/collab-maint/tree.git


compile: tree
	cp Makefile.darwin tree
	cd tree; CC=${COMPILER} make -f Makefile.darwin

tree.bc: compile_tweaked
	${EXTRACT_BC} tree/tree
	mv tree/tree.bc .


slash: tree.bc
	slash --no-strip --work-dir=slash $(MANIFEST)

tree_slash: slash
	cp slash/tree tree_slash
	cp tree/tree tree_orig

compile_tweaked: tree
	cp Makefile.darwin tree
	cp tree_tweaked.c tree/tree.c
	cd tree; CC=${COMPILER} make -f Makefile.darwin

compile_tweaked_2: tree
	cp tree_tweaked_2.c tree/tree.c
	cd tree; CC=${COMPILER} make -f Makefile.darwin

tree_slash_tweaked: clean compile_tweaked slash
	cp slash/tree tree_slash_tweaked



clean:
	rm -rf tree.bc slash
	make -C tree clean

very_clean: clean
	rm -rf tree_slash tree_orig tree_slash_tweaked
	make -C tree clean
	rm -rf tree
