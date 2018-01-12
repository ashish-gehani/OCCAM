[![PyPI version](https://badge.fury.io/py/razor.svg)](https://badge.fury.io/py/razor)
[![Build Status](https://travis-ci.org/SRI-CSL/OCCAM.svg?branch=master)](https://travis-ci.org/SRI-CSL/OCCAM)


Prerequisites
============

[OCCAM](https://github.com/SRI-CSL/OCCAM) currently works fine on Linux, OS X, and FreeBSD.
It depends on an installation of LLVM. The master branch currently requires llvm-5.0, and
there are branches for llvm-3.5, llvm-3.8, llvm-3.9, and llvm-4.0. We will endeavor to maintain such
correspondences. You will also need the Google protobuffer compiler `protoc` and
the corresponding python [package](https://pypi.python.org/pypi/protobuf/).

If you need to generate application bitcode,
you will want to install wllvm, either from the the pip [package](https://pypi.python.org/pypi/wllvm/) or the GitHub [repository](https://github.com/SRI-CSL/whole-program-llvm.git).

The test harness also requires [lit](https://pypi.python.org/pypi/lit/) and `FileCheck`. `FileCheck` can often
be found in the binary directory of your llvm installation, however if you built your own, you may need to
read [this.](https://bugs.llvm.org//show_bug.cgi?id=25675)

Detailed configuration instructions for Ubuntu 14.04 can be gleaned from [bootstrap.sh](https://github.com/SRI-CSL/OCCAM/blob/master/vagrants/14.04/basic/bootstrap.sh)  as well as the Travis CI scripts for each branch [.travis.yml](https://github.com/SRI-CSL/OCCAM/blob/master/.travis.yml).

Building and Installing
=======================

Set where OCCAM's library will be stored:
```
  export OCCAM_HOME={path to location in your home directory}
```

Point to your LLVM's location, if non-standard:
```
  export LLVM_HOME=/usr/local/llvm-5.0
  export LLVM_CONFIG=llvm-config-5.0
```

Set where system libraries, including Google Protocol Buffers, are located:
```
  export LD_FLAGS='-L/usr/local/lib'
```

Build and install OCCAM with:

```
  make
  make install
  make test
```


Using OCCAM
===========

You can choose to record logs from the OCCAM
tool by setting the following variables:

```
  export OCCAM_LOGFILE={absolute path to log location}
  export OCCAM_LOGLEVEL={INFO, WARNING, or ERROR}
```


Using razor
===========

`razor` is a pip package that relies on the same dynamic library as `occam`,
so you should first build and install `occam` as described above. `razor`  provides
the commandline tool `slash`.
You can either install `razor` you can from this repository, or you can just do a
```
pip install razor
```
To install an editable version from this repository:

```
make -f Makefile develop
```

This may require sudo priviliges. Either way you can now use `slash`:

```
slash [--work-dir=<dir>]  [--force] [--no-strip] [--no-specialize] <manifest>
```

`slash` also accepts the following new command line option:
```
--no-specialize
```

which will prevent any inter-module specializations.


To function correctly `slash` calls LLVM tools such as `opt` and `clang++`. These should be available in
your `PATH`, and be the currently supported version (5.0). Like `wllvm`, `slash`, will pay attention to
the environment variables `LLVM_OPT_NAME` and `LLVM_CXX_NAME`
if your version of these tools are adorned with suffixes.


The Manifest(o)
===============

The manifest for `slash` should be valid JSON. The following keys
have meaning:

+ `main` : a path to the bitcode module containing the `main` entry point.

+ `modules`: a list of paths to the other bitcode modules needed.

+ `binary` : the name of the desired executable.

+ `native_libs` : a list of flags (`-lm`, `-lc`, `-lpthread`) or paths to native objects (`.o`, `.a`, `.so`, `.dylib`)

+ `ldflags`: a list of linker flags such as `--static`, `--nostdlib`

+ `args` : the list of arguments you wish to specialize in the main of `main`.

+ `constraints` : a list consisting of a positive integer, followed by some number of strings. The
number indicates the expected number of arguments the specialized program will receive, and the
remaing strings are the specialized arguments to the original program.

Not that `args` and `constraints` are mutually exclusive. If you use one you should not use the other.

As an example, (see `examples/linux/apache`), to previrtualize apache:

```
{ "main" : "httpd.bc"
, "binary"  : "httpd_slashed"
, "modules"    : ["libapr-1.so.bc", "libaprutil-1.so.bc", "libpcre.so.bc"]
, "native_libs" : ["-lcrypt", "-ldl", "-lpthread"]
, "args"    : ["-d", "/var/www"]
, "name"    : "httpd"
}
```

Another example, (see `examples/linux/musl_nweb`), specializes `nweb` with `musl libc.c`:
```
{ "main" :  "nweb.o.bc"
, "binary"  : "nweb_razor"
, "modules"    : ["libc.a.bc"]
, "native_libs" : ["crt1.o", "libc.a"]
, "ldflags" : ["-static", "-nostdlib"]
, "args"    : ["8181", "./root"]
, "name"    : "nweb"
}
```

A third example, (see `examples/portfolio/tree`),  illustrates the use of the `constraints` field to partially specialize 
the arguments to the `tree` utility.
```
{ "main" : "tree.bc"
, "binary"  : "tree"
, "modules"    : []
, "native_libs" : []
, "ldflags" : [ "-O2" ]
, "name"    : "tree"
, "constraints" : ["1", "tree", "-J", "-h"]
}
```
the specialized program will output its results in JSON notation, that will include a human readable size field.
The specialized program expects one extra argument, either a directory, or another flag to output the contents of the
current working directory.

---

This material is based upon work supported by the National Science Foundation under Grant [ACI-1440800](http://www.nsf.gov/awardsearch/showAward?AWD_ID=1440800). Any opinions, findings, and conclusions or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the National Science Foundation.
