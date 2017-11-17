MANIFEST=tree.manifest.constraints

all: tree_slash


tree:
	git clone git://anonscm.debian.org/collab-maint/tree.git


compile: tree
	cp Makefile.darwin tree
	cd tree; CC=gclang make -f Makefile.darwin

tree.bc: compile
	get-bc tree/tree
	mv tree/tree.bc .


slash: tree.bc
	slash --no-strip --work-dir=slash $(MANIFEST)

tree_slash: slash
	cp slash/tree tree_slash
	cp tree/tree tree_orig

compile_tweaked: tree
	cp tree_tweaked.c tree/tree.c
	cd tree; CC=gclang make -f Makefile.darwin

compile_tweaked_2: tree
	cp tree_tweaked_2.c tree/tree.c
	cd tree; CC=gclang make -f Makefile.darwin

tree_slash_tweaked: clean compile_tweaked slash
	cp slash/tree tree_slash_tweaked



clean:
	rm -rf tree.bc slash 
	make -C tree clean

very_clean: clean
	rm -rf tree_slash tree_orig tree_slash_tweaked
	make -C tree clean
