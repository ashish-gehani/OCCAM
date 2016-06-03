[![Build Status](https://travis-ci.org/SRI-CSL/OCCAM.svg?branch=master)](https://travis-ci.org/SRI-CSL/OCCAM)


Introduction
============



Prerequisites
============

OCCAM currently works fine on Linux, OS X, and FreeBSD. You will
need an installation of llvm-3.5. If you want to generate application bitcode, 
you will want an install of [wllvm.](https://github.com/SRI-CSL/whole-program-llvm.git)


Building and Installing
=======================

Set where OCCAM's library will be stored:
```
  export OCCAM_HOME={path to location in your home directory}
```

Point to your LLVM's location, if non-standard:
```
  export LLVM_HOME=/usr/local/llvm-3.5
  export LLVM_CONFIG=llvm-config-3.5
```

Set where system libraries, including Google Protocol Buffers, are located:
```
  export LD_FLAGS='-L/usr/local/lib'
```

Build and install OCCAM with:

```
  make
  make install
```

Using OCCAM
===========

You can choose to record logs from the OCCAM 
tool by setting the following variables:

```
  export OCCAM_LOGFILE={absolute path to log location}
  export OCCAM_LOGLEVEL={INFO, WARNING, or ERROR}
```
