[![PyPI version](https://badge.fury.io/py/razor.svg)](https://badge.fury.io/py/razor)
[![Build Status](https://github.com/SRI-CSL/OCCAM/actions/workflows/occam-docker.yml/badge.svg)](https://github.com/SRI-CSL/OCCAM/actions/workflows/occam-docker.yml)


Description
============

[OCCAM](https://github.com/SRI-CSL/OCCAM) is a whole-program partial evaluator for LLVM bitcode. It can be used to debloat programs and shared/static libraries. To do so, it relies on a manifest that describes the specific deployment context. It uses LLVM version 10.

The available documentation can be found in our [wiki](https://github.com/SRI-CSL/OCCAM/wiki).

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

OCCAM works on Linux, macOS, and FreeBSD.  It depends on an installation of LLVM. OCCAM is built on the top of llvm-10.0 which requires a C++ compiler supporting c++14. You will also need the Google protocol buffer compiler `protoc` and the corresponding Python [package](https://pypi.python.org/pypi/protobuf/). Some OCCAM components (such as [sea-dsa](https://github.com/seahorn/sea-dsa) and [crab](https://github.com/seahorn/crab) require the boost library >= 1.65.

If you need to generate application bitcode (that OCCAM operates on), you may want to install WLLVM, either from the the pip [package](https://pypi.python.org/pypi/wllvm/) or the GitHub [repository](https://github.com/SRI-CSL/whole-program-llvm.git).

The test harness also requires [lit](https://pypi.python.org/pypi/lit/) and `FileCheck`. `FileCheck` can often be found in the binary directory of your LLVM installation. However, if you built your own, you may need to read [this](https://bugs.llvm.org//show_bug.cgi?id=25675). Hint: the build produces it, but does not install it. (Try `locate FileCheck`, then copy it to the `bin` directory.)

Detailed configuration instructions for Ubuntu 18.04 can be gleaned from [bootstrap.sh](https://github.com/SRI-CSL/OCCAM/blob/master/vagrants/18.04/basic/bootstrap.sh).

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

---

This material is based upon work supported by the National Science Foundation under Grant [ACI-1440800](http://www.nsf.gov/awardsearch/showAward?AWD_ID=1440800). Any opinions, findings, and conclusions or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the National Science Foundation.
