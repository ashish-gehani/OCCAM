#iam 8/10/2018

LLVMCC ?= gclang
LLVMCXX ?= gclang++
LLVMGET ?= get-bc


all: Makefile_yices2
	make -f Makefile_yices2 LLVMCC=${LLVMCC} LLVMCXX=${LLVMCXX} LLVMGET=${LLVMGET}

Makefile_yices2:
	$(error Makefile_yices2 is missing but required)

clean: Makefile_yices2
	make -f Makefile_yices2 clean

very_clean: Makefile_yices2
	make -f Makefile_yices2 very_clean

spotless: Makefile_yices2
	make -f Makefile_yices2 spotless
	rm -rf install





