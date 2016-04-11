[![Build Status](https://travis-ci.org/SRI-CSL/OCCAM.svg?branch=master)](https://travis-ci.org/SRI-CSL/OCCAM)


Introduction
============



Prerequisites
============

Occam currently works fine on linux, mac os x, and freeBSD. You will
need an installation of llvm-3.5 and if you want to generate bitcode
an install of [wllvm.](https://github.com/SRI-CSL/whole-program-llvm.git)


Building and Installing
=======================

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
