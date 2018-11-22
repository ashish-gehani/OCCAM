#!/usr/bin/env bash

wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-5.0 main"
sudo apt-get update
sudo apt-get install -y emacs24 dbus-x11 libgmp-dev libelf-dev
sudo apt-get install -y build-essential vim curl bison flex bc libcap-dev git cmake libboost-all-dev libncurses5-dev python-minimal python-pip unzip 
sudo apt-get install -y git subversion wget libprotobuf-dev python-protobuf protobuf-compiler libboost-all-dev
sudo apt-get install -y llvm-5.0 libclang-5.0-dev clang-5.0 tree 
sudo apt-get install -y python-pip

echo "success : initial packages installed"

# rename llvm packages
sudo cp /usr/bin/clang-5.0 /usr/bin/clang
sudo cp /usr/bin/clang++-5.0 /usr/bin/clang++
sudo cp /usr/bin/llvm-link-5.0 /usr/bin/llvm-link
sudo cp /usr/bin/llvm-dis-5.0 /usr/bin/llvm-dis
sudo cp /usr/bin/llvm-ar-5.0 /usr/bin/llvm-ar
sudo cp /usr/bin/llvm-as-5.0 /usr/bin/llvm-as
sudo cp /usr/bin/llc-5.0 /usr/bin/llc
sudo cp /usr/bin/opt-5.0 /usr/bin/opt
sudo cp /usr/bin/llvm-nm-5.0 /usr/bin/llvm-nm

echo "success : renamed"

# env vars
cp /vagrant/bash_profile  /home/vagrant/.bash_profile && .  /home/vagrant/.bash_profile

# gllvm
    wget https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.11.2.linux-amd64.tar.gz
    go get github.com/SRI-CSL/gllvm/cmd/...
    sudo cp $GOPATH/bin/* /usr/bin

echo "success : gllvm installed"

mkdir Repositories
# OCCAM
    cd $HOME/Repositories/
    git clone --recurse-submodules https://github.com/SRI-CSL/OCCAM && \
    # automatically fixing bug in llpe codebase
    cd OCCAM/src/analysis/llpe/ && \
    perl -pi -e 's/{LIB}/{LIBRARY}/g' utils/Makefile  main/Makefile driver/Makefile && \
    #
    cd $HOME/Repositories/OCCAM && \
    make && \
    sudo -E make install

echo "success : OCCAM installed"

# musllvm
    cd $HOME/Repositories/
    git clone https://github.com/SRI-CSL/musllvm && \
    cd musllvm && \
    CC=gclang WLLVM_CONFIGURE_ONLY=1  ./configure --target=LLVM --build=LLVM && \
    make && \
    cd lib && \
    get-bc -b libc.a 

echo "success : musllvm"

# kernel specialization
    cd $HOME/Repositories/
    git clone https://github.com/SRI-CSL/kernel-specialization

echo "Now login to the virtual machine and execute the script generate_kernel_specialized_for_thttpd.sh present at $HOME/Repositories/OCCAM/vagrants/16.04/kernel-specialization/"


