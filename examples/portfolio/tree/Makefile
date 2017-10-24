


tree:
	git clone git://anonscm.debian.org/collab-maint/tree.git


compile: tree
	cp Makefile.darwin tree
	cd tree; CC=gclang make -f Makefile.darwin

clean:
	make -C tree clean
