#http://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.gz

SRC=binutils-2.32
TAR=${SRC}.tar.gz
URL=http://ftp.gnu.org/gnu/binutils/${TAR}


all: readelf.bc objdump.bc


${TAR}:
	wget ${URL}


${SRC}: ${TAR}
	tar xvfz ${TAR}

${SRC}/binutils/readelf: ${SRC}
	cd ${SRC}; CC=gclang ./configure; CC=gclang make;

${SRC}/binutils/objdump: ${SRC}
	cd ${SRC}; CC=gclang ./configure; CC=gclang make;

readelf.bc: ${SRC}/binutils/readelf
	cd ${SRC}/binutils/; get-bc -m readelf; cp readelf.bc readelf.bc.llvm.manifest ../../

objdump.bc: ${SRC}/binutils/objdump
	cd ${SRC}/binutils/; get-bc -m objdump; cp objdump.bc objdump.bc.llvm.manifest ../../


readelf_modules:
	cp ${SRC}/binutils/.readelf.o.bc 	readelf.o.bc
	cp ${SRC}/binutils/.version.o.bc 	version.o.bc
	cp ${SRC}/binutils/.unwind-ia64.o.bc 	unwind-ia64.o.bc
	cp ${SRC}/binutils/.dwarf.o.bc 	dwarf.o.bc
	cp ${SRC}/binutils/.elfcomm.o.bc 	elfcomm.o.bc
	cp ${SRC}/libiberty/.argv.o.bc 	argv.o.bc
	cp ${SRC}/libiberty/.concat.o.bc 	concat.o.bc
	cp ${SRC}/libiberty/.dwarfnames.o.bc 	dwarfnames.o.bc
	cp ${SRC}/libiberty/.lbasename.o.bc 	lbasename.o.bc
	cp ${SRC}/libiberty/.lrealpath.o.bc 	lrealpath.o.bc
	cp ${SRC}/libiberty/.safe-ctype.o.bc 	safe-ctype.o.bc
	cp ${SRC}/libiberty/.xexit.o.bc 	xexit.o.bc
	cp ${SRC}/libiberty/.xmalloc.o.bc 	xmalloc.o.bc
	cp ${SRC}/libiberty/.xstrdup.o.bc 	xstrdup.o.bc
	cp ${SRC}/zlib/.libz_a-inflate.o.bc 	libz_a-inflate.o.bc
	cp ${SRC}/zlib/.libz_a-inftrees.o.bc 	libz_a-inftrees.o.bc
	cp ${SRC}/zlib/.libz_a-zutil.o.bc 	libz_a-zutil.o.bc
	cp ${SRC}/zlib/.libz_a-adler32.o.bc 	libz_a-adler32.o.bc
	cp ${SRC}/zlib/.libz_a-crc32.o.bc 	libz_a-crc32.o.bc
	cp ${SRC}/zlib/.libz_a-inffast.o.bc 	libz_a-inffast.o.bc


objdump_modules:
	cp ${SRC}/binutils/.objdump.o.bc 	objdump.o.bc
	cp ${SRC}/binutils/.dwarf.o.bc 	dwarf.o.bc
	cp ${SRC}/binutils/.prdbg.o.bc 	prdbg.o.bc
	cp ${SRC}/binutils/.rddbg.o.bc 	rddbg.o.bc
	cp ${SRC}/binutils/.debug.o.bc 	debug.o.bc
	cp ${SRC}/binutils/.stabs.o.bc 	stabs.o.bc
	cp ${SRC}/binutils/.rdcoff.o.bc 	rdcoff.o.bc
	cp ${SRC}/binutils/.bucomm.o.bc 	bucomm.o.bc
	cp ${SRC}/binutils/.version.o.bc 	version.o.bc
	cp ${SRC}/binutils/.filemode.o.bc 	filemode.o.bc
	cp ${SRC}/binutils/.elfcomm.o.bc 	elfcomm.o.bc
	cp ${SRC}/opcodes/.disassemble.o.bc 	disassemble.o.bc
	cp ${SRC}/opcodes/.dis-init.o.bc 	dis-init.o.bc
	cp ${SRC}/opcodes/.i386-dis.o.bc 	i386-dis.o.bc
	cp ${SRC}/opcodes/.dis-buf.o.bc 	dis-buf.o.bc
	cp ${SRC}/bfd/.archive.o.bc 	archive.o.bc
	cp ${SRC}/bfd/.archures.o.bc 	archures.o.bc
	cp ${SRC}/bfd/.bfd.o.bc 	bfd.o.bc
	cp ${SRC}/bfd/.bfdio.o.bc 	bfdio.o.bc
	cp ${SRC}/bfd/.coff-bfd.o.bc 	coff-bfd.o.bc
	cp ${SRC}/bfd/.compress.o.bc 	compress.o.bc
	cp ${SRC}/bfd/.elf-properties.o.bc 	elf-properties.o.bc
	cp ${SRC}/bfd/.format.o.bc 	format.o.bc
	cp ${SRC}/bfd/.hash.o.bc 	hash.o.bc
	cp ${SRC}/bfd/.init.o.bc 	init.o.bc
	cp ${SRC}/bfd/.libbfd.o.bc 	libbfd.o.bc
	cp ${SRC}/bfd/.opncls.o.bc 	opncls.o.bc
	cp ${SRC}/bfd/.section.o.bc 	section.o.bc
	cp ${SRC}/bfd/.simple.o.bc 	simple.o.bc
	cp ${SRC}/bfd/.stab-syms.o.bc 	stab-syms.o.bc
	cp ${SRC}/bfd/.syms.o.bc 	syms.o.bc
	cp ${SRC}/bfd/.targets.o.bc 	targets.o.bc
	cp ${SRC}/bfd/.binary.o.bc 	binary.o.bc
	cp ${SRC}/bfd/.ihex.o.bc 	ihex.o.bc
	cp ${SRC}/bfd/.srec.o.bc 	srec.o.bc
	cp ${SRC}/bfd/.tekhex.o.bc 	tekhex.o.bc
	cp ${SRC}/bfd/.verilog.o.bc 	verilog.o.bc
	cp ${SRC}/bfd/.elf64-x86-64.o.bc 	elf64-x86-64.o.bc
	cp ${SRC}/bfd/.elfxx-x86.o.bc 	elfxx-x86.o.bc
	cp ${SRC}/bfd/.elf-ifunc.o.bc 	elf-ifunc.o.bc
	cp ${SRC}/bfd/.elf-nacl.o.bc 	elf-nacl.o.bc
	cp ${SRC}/bfd/.elf64.o.bc 	elf64.o.bc
	cp ${SRC}/bfd/.elf.o.bc 	elf.o.bc
	cp ${SRC}/bfd/.elflink.o.bc 	elflink.o.bc
	cp ${SRC}/bfd/.elf-attrs.o.bc 	elf-attrs.o.bc
	cp ${SRC}/bfd/.elf-strtab.o.bc 	elf-strtab.o.bc
	cp ${SRC}/bfd/.elf-eh-frame.o.bc 	elf-eh-frame.o.bc
	cp ${SRC}/bfd/.dwarf1.o.bc 	dwarf1.o.bc
	cp ${SRC}/bfd/.dwarf2.o.bc 	dwarf2.o.bc
	cp ${SRC}/bfd/.elf32-i386.o.bc 	elf32-i386.o.bc
	cp ${SRC}/bfd/.elf-vxworks.o.bc 	elf-vxworks.o.bc
	cp ${SRC}/bfd/.elf32.o.bc 	elf32.o.bc
	cp ${SRC}/bfd/.pei-i386.o.bc 	pei-i386.o.bc
	cp ${SRC}/bfd/.peigen.o.bc 	peigen.o.bc
	cp ${SRC}/bfd/.cofflink.o.bc 	cofflink.o.bc
	cp ${SRC}/bfd/.coffgen.o.bc 	coffgen.o.bc
	cp ${SRC}/bfd/.pei-x86_64.o.bc 	pei-x86_64.o.bc
	cp ${SRC}/bfd/.pex64igen.o.bc 	pex64igen.o.bc
	cp ${SRC}/bfd/.elf64-gen.o.bc 	elf64-gen.o.bc
	cp ${SRC}/bfd/.elf32-gen.o.bc 	elf32-gen.o.bc
	cp ${SRC}/bfd/.plugin.o.bc 	plugin.o.bc
	cp ${SRC}/bfd/.cpu-i386.o.bc 	cpu-i386.o.bc
	cp ${SRC}/bfd/.cpu-iamcu.o.bc 	cpu-iamcu.o.bc
	cp ${SRC}/bfd/.cpu-l1om.o.bc 	cpu-l1om.o.bc
	cp ${SRC}/bfd/.cpu-k1om.o.bc 	cpu-k1om.o.bc
	cp ${SRC}/bfd/.cpu-plugin.o.bc 	cpu-plugin.o.bc
	cp ${SRC}/bfd/.archive64.o.bc 	archive64.o.bc
	cp ${SRC}/bfd/.cache.o.bc 	cache.o.bc
	cp ${SRC}/bfd/.corefile.o.bc 	corefile.o.bc
	cp ${SRC}/bfd/.linker.o.bc 	linker.o.bc
	cp ${SRC}/bfd/.merge.o.bc 	merge.o.bc
	cp ${SRC}/bfd/.reloc.o.bc 	reloc.o.bc
	cp ${SRC}/bfd/.stabs.o.bc 	stabs.o.bc
	cp ${SRC}/zlib/.libz_a-compress.o.bc 	libz_a-compress.o.bc
	cp ${SRC}/zlib/.libz_a-deflate.o.bc 	libz_a-deflate.o.bc
	cp ${SRC}/zlib/.libz_a-inflate.o.bc 	libz_a-inflate.o.bc
	cp ${SRC}/zlib/.libz_a-inftrees.o.bc 	libz_a-inftrees.o.bc
	cp ${SRC}/zlib/.libz_a-trees.o.bc 	libz_a-trees.o.bc
	cp ${SRC}/zlib/.libz_a-zutil.o.bc 	libz_a-zutil.o.bc
	cp ${SRC}/zlib/.libz_a-adler32.o.bc 	libz_a-adler32.o.bc
	cp ${SRC}/zlib/.libz_a-crc32.o.bc 	libz_a-crc32.o.bc
	cp ${SRC}/zlib/.libz_a-inffast.o.bc 	libz_a-inffast.o.bc
	cp ${SRC}/libiberty/.cplus-dem.o.bc 	cplus-dem.o.bc
	cp ${SRC}/libiberty/.cp-demangle.o.bc 	cp-demangle.o.bc
	cp ${SRC}/libiberty/.argv.o.bc 	argv.o.bc
	cp ${SRC}/libiberty/.concat.o.bc 	concat.o.bc
	cp ${SRC}/libiberty/.cp-demint.o.bc 	cp-demint.o.bc
	cp ${SRC}/libiberty/.d-demangle.o.bc 	d-demangle.o.bc
	cp ${SRC}/libiberty/.dwarfnames.o.bc 	dwarfnames.o.bc
	cp ${SRC}/libiberty/.filename_cmp.o.bc 	filename_cmp.o.bc
	cp ${SRC}/libiberty/.getpwd.o.bc 	getpwd.o.bc
	cp ${SRC}/libiberty/.hashtab.o.bc 	hashtab.o.bc
	cp ${SRC}/libiberty/.hex.o.bc 	hex.o.bc
	cp ${SRC}/libiberty/.lbasename.o.bc 	lbasename.o.bc
	cp ${SRC}/libiberty/.lrealpath.o.bc 	lrealpath.o.bc
	cp ${SRC}/libiberty/.make-relative-prefix.o.bc 	make-relative-prefix.o.bc
	cp ${SRC}/libiberty/.make-temp-file.o.bc 	make-temp-file.o.bc
	cp ${SRC}/libiberty/.objalloc.o.bc 	objalloc.o.bc
	cp ${SRC}/libiberty/.rust-demangle.o.bc 	rust-demangle.o.bc
	cp ${SRC}/libiberty/.safe-ctype.o.bc 	safe-ctype.o.bc
	cp ${SRC}/libiberty/.unlink-if-ordinary.o.bc 	unlink-if-ordinary.o.bc
	cp ${SRC}/libiberty/.xexit.o.bc 	xexit.o.bc
	cp ${SRC}/libiberty/.xmalloc.o.bc 	xmalloc.o.bc
	cp ${SRC}/libiberty/.xstrdup.o.bc 	xstrdup.o.bc
	cp ${SRC}/libiberty/.xstrerror.o.bc 	xstrerror.o.bc


clean:
	rm -rf *~ *.bc *.llvm.manifest
	make -C ${SRC} clean


spotless: clean
	rm -rf ${TAR} ${SRC}

