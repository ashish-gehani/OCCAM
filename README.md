[![Build Status](https://travis-ci.org/SRI-CSL/OCCAM.svg?branch=master)](https://travis-ci.org/SRI-CSL/OCCAM)


Introduction
============

This package includes OCCAM software, available from:
<https://github.com/ashish-gehani/OCCAM/> and <https://github.com/SRI-CSL/OCCAM>

Installation / Getting Started 
==============================

Prerequisites
-------------

Occam currently works fine on Linux, Mac OS X, and FreeBSD. You will
need an installation of [LLVM-3.5](http://llvm.org/docs/GettingStarted.html) and if you want to generate bitcode,
an install of [WLLVM](https://github.com/SRI-CSL/whole-program-llvm.git "Whole Program LLVM"). OCCAM also requires [Protocol Buffers](https://github.com/google/protobuf) library.

### Installation of LLVM on Ubuntu

OCCAM requires all the [dependencies of LLVM](http://llvm.org/docs/GettingStarted.html#requirements). In particular, you should install the following programs and libraries, listed below as Ubuntu packages:
```
sudo apt-get install build-essential vim curl bison flex bc libcap-dev git cmake libboost-all-dev libncurses5-dev python-minimal python-pip unzip 
```
You will need gcc/g++ 4.8 or later installed on your system.

Install LLVM using the instructions from <http://llvm.org/docs/GettingStarted.html> or LLVM can be installed using Ubuntu apt repository, if available as below:
```
sudo apt-get install clang-3.5 llvm-3.5 llvm-3.5-dev llvm-3.5-tools  
```
You may then wish to add llvm path to your shell startup (e.g. '~/.bashrc'). Make sure LLVM bin folder is added to start of your path, so that llvm tools are not adorned with suffixes (e.g. llvm-config-3.5). Change the path as per installation of LLVM in your system:
```
  export LLVM_HOME=/usr/lib/llvm-3.5
  export PATH=${LLVM-HOME}/bin:${PATH}
```

### Installation of protobuf on Ubuntu


OCCAM requires [Protocol Buffers](https://github.com/google/protobuf) library. Its dependencies can be installed on Ubuntu with:
```
sudo apt-get install autoconf automake libtool curl make g++ unzip
```
and the quick way to install protobuf is:
```
sudo apt-get install libprotobuf-dev protobuf-compiler python-protobuf
```

**NOTE:** If you see error `"ImportError: No module named google.protobuf"` while running OCCAM, use `sudo pip install protobuf` to install protobuf. (Dependencies for pip : sudo apt-get install build-essential python-dev python-pip)

### WLLVM installation 
Add WLLVM tools to the PATH variable using:
```
    git clone https://github.com/travitch/whole-program-llvm wllvm
    cd wllvm
    export PATH=`pwd`:$PATH
    export LLVM_COMPILER=clang
    export WLLVM_OUTPUT=WARNING
```

Building and Installing
-----------------------

After all the dependencies all installed, checkout the code from repository and set OCCAM_HOME variable according to your occam home directory.
```
   git clone https://github.com/ashish-gehani/OCCAM.git occam
   cd occam
   export OCCAM_HOME=`pwd`
```

If LLVM_HOME and OCCAM_HOME variables are not set in your environment, edit the Makefile and uncomment the lines exporting LLVM_HOME and OCCAM_HOME at the top of the file according to paths in your system. Now build and install the tool using below commands from your occam root directory.
```
make
make install
```

For you ease, you can also create an alias to the 'occam' toolchain wrapper. For bash, add the following to to your shell startup:
```
  alias occam=$OCCAM_HOME/bin/occam
```

Using OCCAM
-----------

You can choose to record logs from the OCCAM tool by setting the following variables:

```
  export OCCAM_LOGFILE={absolute path to log location}
  export OCCAM_LOGLEVEL={INFO, WARNING, or ERROR}
```
To specialize the application, add a "args": ["arg1", "arg2", ...] entry to the manifest file and call the previrt tool:
```
   occam previrt --work-dir=$WORKDIR $MANIFEST_FILE
```
