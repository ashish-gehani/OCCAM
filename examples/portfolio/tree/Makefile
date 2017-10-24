
all: tree.bc


tree:
	git clone git://anonscm.debian.org/collab-maint/tree.git


compile: tree
	cp Makefile.darwin tree
	cd tree; CC=gclang make -f Makefile.darwin

tree.bc: compile
	get-bc tree/tree
	mv tree/tree.bc .

clean:
	rm tree.bc
	make -C tree clean
