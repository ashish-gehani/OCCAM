#iam 7/13/2018

LLVMCC ?= gclang
LLVMCXX ?= gclang++
LLVMGET ?= get-bc


all: Makefile_httpd
	make -f Makefile_httpd LLVMCC=${LLVMCC} LLVMCXX=${LLVMCXX} LLVMGET=${LLVMGET}

Makefile_httpd:
	$(error Makefile_httpd is missing but required)


clean: Makefile_httpd
	make -f Makefile_httpd clean

very_clean: Makefile_httpd
	make -f Makefile_httpd very_clean

spotless: Makefile_httpd
	make -f Makefile_httpd spotless
	rm -rf install




