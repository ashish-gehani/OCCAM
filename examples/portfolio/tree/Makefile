
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
	slash --work-dir=slash tree.manifest

tree_slash: slash
	cp slash/tree tree_slash



clean:
	rm -rf tree.bc slash tree_slash *~
	make -C tree clean
