#!/usr/bin/env bash

# Install GLLVM / OCCAM dependencies
sudo apt-get update
sudo apt-get install -y clang-10 clang-format-10 cmake git golang-go
sudo apt-get install -y libboost-dev libgmp-dev libprotobuf-dev llvm-10 
sudo apt-get install -y protobuf-compiler python python-pip python-protobuf
sudo apt-get install -y software-properties-common wget
pip install setuptools --upgrade
pip install wheel
pip install protobuf
pip install lit

# Download OCCAM
git clone --recurse-submodules https://github.com/SRI-CSL/OCCAM.git occam

# Set environment variables
cp occam/vagrants/18.04/basic/bash_profile $HOME/.bash_profile
. .bash_profile

# Install GLLVM
mkdir "$GOPATH"
cd "$GOPATH"
go get github.com/SRI-CSL/gllvm/cmd/...

# Build OCCAM
cd $OCCAM_HOME
make -j16
make install
make test
