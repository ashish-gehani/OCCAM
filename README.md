[![PyPI version](https://badge.fury.io/py/razor.svg)](https://badge.fury.io/py/razor)
[![Build Status](https://travis-ci.org/SRI-CSL/OCCAM.svg?branch=llvm10)](https://travis-ci.org/SRI-CSL/OCCAM)

Description
============

[OCCAM](https://github.com/SRI-CSL/OCCAM) is a whole-program partial evaluator for LLVM bitcode that aims at debloating programs and shared/static libraries running in a specific deployment context.

OCCAM architecture
==================

![OCCAM architecture](https://github.com/SRI-CSL/OCCAM/blob/master/OCCAM-arch.jpg)

Docker
======

A pre-built and installed version of OCCAM can be obtained using Docker:

```shell
docker pull sricsl/occam:bionic
docker run -v `pwd`:/host -it sricsl/occam:bionic
```
Alternatively, it can be built and installed from source as follows.

Prerequisites
============

OCCAM currently works on Linux, macOS, and FreeBSD.  It depends on an installation of LLVM. OCCAM currently is built on the top of llvm-10.0 which requires a C++ compiler supporting c++14. You will also need the Google protocol buffer compiler `protoc` and the corresponding Python [package](https://pypi.python.org/pypi/protobuf/). Some OCCAM components (such as [sea-dsa](https://github.com/seahorn/sea-dsa) and [crab](https://github.com/seahorn/crab) require the boost library >= 1.65.

If you need to generate application bitcode (that OCCAM operates on), you will want to install WLLVM, either from the the pip [package](https://pypi.python.org/pypi/wllvm/) or the GitHub [repository](https://github.com/SRI-CSL/whole-program-llvm.git).

The test harness also requires [lit](https://pypi.python.org/pypi/lit/) and `FileCheck`. `FileCheck` can often be found in the binary directory of your LLVM installation. However, if you built your own, you may need to read [this.](https://bugs.llvm.org//show_bug.cgi?id=25675) Hint: the build produces it, but does not install it. (Try `locate FileCheck`, then copy it to the `bin` directory.)

Detailed configuration instructions for Ubuntu 18.04 can be gleaned from [bootstrap.sh](https://github.com/SRI-CSL/OCCAM/blob/master/vagrants/18.04/basic/bootstrap.sh) as well as the Travis CI scripts for each branch [.travis.yml](https://github.com/SRI-CSL/OCCAM/blob/master/.travis.yml).

Building and Installing
=======================

Set where OCCAM's library will be stored:
```
  export OCCAM_HOME={path to location in your home directory}
```

Point to your LLVM's location, if non-standard:
```
  export LLVM_HOME=/usr/local/llvm-10.0
  export LLVM_CONFIG=llvm-config-10.0
```

Set where system libraries, including Google Protocol Buffers, are located:
```
  export LD_FLAGS='-L/usr/local/lib'
```

Clone, build, and install OCCAM with:

```
  git clone --recurse-submodules https://github.com/SRI-CSL/OCCAM.git
  make
  make install
  make test
```

Using OCCAM
===========

You can choose to record logs from OCCAM by setting the following variables:

```
  export OCCAM_LOGFILE={absolute path to log location}
  export OCCAM_LOGLEVEL={INFO, WARNING, or ERROR}
```

Using razor
===========

`razor` is a pip package that relies on the same dynamic library as `occam`. So you should first build and install `occam` as described above. `razor`  provides the commandline tool `slash` for end users. You can either install `razor` from this repository, or you can use:
```
pip install razor
```

To install an editable version from this repository:

```
make -f Makefile develop
```

This may require sudo privileges. Either way you can now use `slash`:

```
slash [--work-dir=<dir>]  [--force] [--no-strip] [--intra-spec-policy=<type>] [--inter-spec-policy=<type>] [--use-pointer-analysis] [--enable-config-prime] <manifest>
```

where 

```
type=none|aggressive|nonrec-aggressive|bounded|onlyonce
```

The value `none` will prevent any inter or intra-module specialization. The value `aggressive` specializes a call if any parameter is a constant. The value `nonrec-aggressive` specializes a call if the function is non-recursive and any parameter is a constant. The value `bounded` makes at most `k` copies where `k` can be chosen by option `--max-bounded-spec`. The value `onlyonce` makes a copy of a function only if the function is called exactly once.

To function correctly `slash` calls LLVM tools such as `opt` and `clang++`. These should be available in your `PATH`, and be the currently supported version (10.0). Like `wllvm`, `slash`, will pay attention to the environment variables `LLVM_OPT_NAME` and `LLVM_CXX_NAME` if your version of these tools is adorned with suffixes.

The Manifest
============

The manifest for `slash` should be valid JSON. The following keys have meaning:

+ `main` : a path to the bitcode module containing the `main` entry point.

+ `modules`: a list of paths to the other bitcode modules needed.

+ `binary` : the name of the desired executable.

+ `native_libs` : a list of flags (`-lm`, `-lc`, `-lpthread`) or paths to native objects (`.o`, `.a`, `.so`, `.dylib`)

+ `ldflags`: a list of linker flags such as `--static`, `--nostdlib`

+ `name`: the program name 

+ `static_args` : the list of static arguments you wish to specialize in the _main()_ of `main`.

+ `dynamic_args` : a number that indicates the arguments the specialized program will receive at runtime. If this key is omitted then the default value is 0 which means that the specialized program does not expect any parameter. 

+ `lib_spec`: list of library bitcode you wish to specialize with respect to `main` or a list of `main` functions given by `main_spec`. 

+ `main_spec`:  list of bitcode modules each containing a `main` function used by `lib_spec`. 

As an example, (see `examples/linux/apache`), to previrtualize apache:

```
{ "main" : "httpd.bc"
, "binary" : "httpd_slashed"
, "modules" : ["libapr-1.so.bc", "libaprutil-1.so.bc", "libpcre.so.bc"]
, "native_libs" : ["-lcrypt", "-ldl", "-lpthread"]
, "name"    : "httpd"
, "static_args" : ["-d", "/var/www"]
}
```

Another example, (see `examples/linux/musl_nweb`), specializes `nweb` with `musl libc.c`:
```
{ "main" :  "nweb.o.bc"
, "binary" : "nweb_razor"
, "modules" : ["libc.a.bc"]
, "native_libs" : ["crt1.o", "libc.a"]
, "ldflags" : ["-static", "-nostdlib"]
, "name" : "nweb"
, "static_args" : ["8181", "./root"]
, "dynamic_args" : "0"
}
```

A third example, (see `examples/portfolio/tree`),  illustrates the use of the `dynamic_args` field to partially specialize the arguments to the `tree` utility.
```
{ "main" : "tree.bc"
, "binary"  : "tree"
, "modules"    : []
, "native_libs" : []
, "ldflags" : [ "-O2" ]
, "name"    : "tree"
, "static_args" : ["-J", "-h"]
, "dynamic_args" : "1"
}
```

The specialized program will output its results in JSON notation (-J) that will include a human readable size field (-h). The specialized program expects one extra argument, either a directory or another flag to output the contents of the current working directory.

---

This material is based upon work supported by the National Science Foundation under Grant [ACI-1440800](http://www.nsf.gov/awardsearch/showAward?AWD_ID=1440800). Any opinions, findings, and conclusions or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the National Science Foundation.
