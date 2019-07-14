#!/usr/bin/env bash

# Make sure we exit if there is a failure
set -e


function usage() {
    echo "Usage: $0 [--disable-inlining] [--ipdse] [--ai-dce] [--devirt VAL1] [--inter-spec VAL2] [--intra-spec VAL2] [--link dynamic|static] [--help]"
    echo "       VAL1=none|dsa|cha_dsa"
    echo "       VAL2=none|aggressive|nonrec-aggressive"
}

#default values
INTER_SPEC="none"
INTRA_SPEC="none"
DEVIRT="none"
OPT_OPTIONS=""

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -inter-spec|--inter-spec)
	INTER_SPEC="$2"
	shift # past argument
	shift # past value
	;;
    -intra-spec|--intra-spec)
	INTRA_SPEC="$2"
	shift # past argument
	shift # past value
	;;
    -disable-inlining|--disable-inlining)
	OPT_OPTIONS="${OPT_OPTIONS} --disable-inlining"
	shift # past argument
	;;
    -ipdse|--ipdse)
	OPT_OPTIONS="${OPT_OPTIONS} --ipdse"
	shift # past argument
	;;
    -ai-dce|--ai-dce)
	OPT_OPTIONS="${OPT_OPTIONS} --ai-dce"
	shift # past argument
	;;
    -devirt|--devirt)
	DEVIRT="$2"
	shift # past argument
	shift # past value
	;;
    -help|--help)
	usage
	exit 0
	;;
    *)    # unknown option
	POSITIONAL+=("$1") # save it in an array for later
	shift # past argument
	;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


#check that the required dependencies are built
declare -a bitcode=(
	"objdump_modules/objdump.o.bc"
	"objdump_modules/dwarf.o.bc"
	"objdump_modules/prdbg.o.bc"
	"objdump_modules/rddbg.o.bc"
	"objdump_modules/debug.o.bc"
	"objdump_modules/binutils_stabs.o.bc"
	"objdump_modules/rdcoff.o.bc"
	"objdump_modules/bucomm.o.bc"
	"objdump_modules/version.o.bc"
	"objdump_modules/filemode.o.bc"
	"objdump_modules/elfcomm.o.bc"
	"objdump_modules/disassemble.o.bc"
	"objdump_modules/dis-init.o.bc"
	"objdump_modules/i386-dis.o.bc"
	"objdump_modules/dis-buf.o.bc"
	"objdump_modules/archive.o.bc"
	"objdump_modules/archures.o.bc"
	"objdump_modules/bfd.o.bc"
	"objdump_modules/bfdio.o.bc"
	"objdump_modules/coff-bfd.o.bc"
	"objdump_modules/compress.o.bc"
	"objdump_modules/elf-properties.o.bc"
	"objdump_modules/format.o.bc"
	"objdump_modules/hash.o.bc"
	"objdump_modules/init.o.bc"
	"objdump_modules/libbfd.o.bc"
	"objdump_modules/opncls.o.bc"
	"objdump_modules/section.o.bc"
	"objdump_modules/simple.o.bc"
	"objdump_modules/stab-syms.o.bc"
	"objdump_modules/syms.o.bc"
	"objdump_modules/targets.o.bc"
	"objdump_modules/binary.o.bc"
	"objdump_modules/ihex.o.bc"
	"objdump_modules/srec.o.bc"
	"objdump_modules/tekhex.o.bc"
	"objdump_modules/verilog.o.bc"
	"objdump_modules/elf64-x86-64.o.bc"
	"objdump_modules/elfxx-x86.o.bc"
	"objdump_modules/elf-ifunc.o.bc"
	"objdump_modules/elf-nacl.o.bc"
	"objdump_modules/elf64.o.bc"
	"objdump_modules/elf.o.bc"
	"objdump_modules/elflink.o.bc"
	"objdump_modules/elf-attrs.o.bc"
	"objdump_modules/elf-strtab.o.bc"
	"objdump_modules/elf-eh-frame.o.bc"
	"objdump_modules/dwarf1.o.bc"
	"objdump_modules/dwarf2.o.bc"
	"objdump_modules/elf32-i386.o.bc"
	"objdump_modules/elf-vxworks.o.bc"
	"objdump_modules/elf32.o.bc"
	"objdump_modules/pei-i386.o.bc"
	"objdump_modules/peigen.o.bc"
	"objdump_modules/cofflink.o.bc"
	"objdump_modules/coffgen.o.bc"
	"objdump_modules/pei-x86_64.o.bc"
	"objdump_modules/pex64igen.o.bc"
	"objdump_modules/elf64-gen.o.bc"
	"objdump_modules/elf32-gen.o.bc"
	"objdump_modules/plugin.o.bc"
	"objdump_modules/cpu-i386.o.bc"
	"objdump_modules/cpu-iamcu.o.bc"
	"objdump_modules/cpu-l1om.o.bc"
	"objdump_modules/cpu-k1om.o.bc"
	"objdump_modules/cpu-plugin.o.bc"
	"objdump_modules/archive64.o.bc"
	"objdump_modules/cache.o.bc"
	"objdump_modules/corefile.o.bc"
	"objdump_modules/linker.o.bc"
	"objdump_modules/merge.o.bc"
	"objdump_modules/reloc.o.bc"
	"objdump_modules/bfd_stabs.o.bc"
	"objdump_modules/libz_a-compress.o.bc"
	"objdump_modules/libz_a-deflate.o.bc"
	"objdump_modules/libz_a-inflate.o.bc"
	"objdump_modules/libz_a-inftrees.o.bc"
	"objdump_modules/libz_a-trees.o.bc"
	"objdump_modules/libz_a-zutil.o.bc"
	"objdump_modules/libz_a-adler32.o.bc"
	"objdump_modules/libz_a-crc32.o.bc"
	"objdump_modules/libz_a-inffast.o.bc"
	"objdump_modules/cplus-dem.o.bc"
	"objdump_modules/cp-demangle.o.bc"
	"objdump_modules/argv.o.bc"
	"objdump_modules/concat.o.bc"
	"objdump_modules/cp-demint.o.bc"
	"objdump_modules/d-demangle.o.bc"
	"objdump_modules/dwarfnames.o.bc"
	"objdump_modules/filename_cmp.o.bc"
	"objdump_modules/getpwd.o.bc"
	"objdump_modules/hashtab.o.bc"
	"objdump_modules/hex.o.bc"
	"objdump_modules/lbasename.o.bc"
	"objdump_modules/lrealpath.o.bc"
	"objdump_modules/make-relative-prefix.o.bc"
	"objdump_modules/make-temp-file.o.bc"
	"objdump_modules/objalloc.o.bc"
	"objdump_modules/rust-demangle.o.bc"
	"objdump_modules/safe-ctype.o.bc"
	"objdump_modules/unlink-if-ordinary.o.bc"
	"objdump_modules/xexit.o.bc"
	"objdump_modules/xmalloc.o.bc"
	"objdump_modules/xstrdup.o.bc"
	"objdump_modules/xstrerror.o.bc"
)

for bc in "${bitcode[@]}"
do
    if [ -a  "$bc" ]
    then
        echo "Found $bc"
    else
        echo "Error: $bc not found. Try \"make\"."
        exit 1
    fi
done

SLASH_OPTS="--inter-spec-policy=${INTER_SPEC} --intra-spec-policy=${INTRA_SPEC} --devirt=${DEVIRT} --stats $OPT_OPTIONS"

# OCCAM with program and libraries dynamically linked
function dynamic_link() {

    export OCCAM_LOGLEVEL=INFO
    export OCCAM_LOGFILE=${PWD}/objdump_slash_specialized/occam.log

    rm -rf objdump_slash_specialized objdump_slashed

    echo "============================================================"
    echo "Running httpd with dynamic libraries "
    echo "slash options ${SLASH_OPTS}"
    echo "============================================================"
    slash ${SLASH_OPTS} --work-dir=objdump_slash_specialized \
	  --amalgamate=objdump_slash_specialized/amalgamation.bc \
	  objdump.json
    status=$?
    if [ $status -ne 0 ]
    then
	echo "Something failed while running slash"
	exit 1
    fi
    cp ./objdump_slash_specialized/objdump_slashed .
}

dynamic_link
