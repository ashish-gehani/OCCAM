#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y emacs24 dbus-x11 
sudo apt-get install -y git subversion wget libprotobuf-dev python-protobuf protobuf-compiler
sudo apt-get install -y llvm-3.5 libclang-3.5-dev clang-3.5 tree 
sudo apt-get install -y python-pip
sudo pip install wllvm

cd /home/vagrant &&  \
    git clone https://github.com/SRI-CSL/OCCAM.git && \
    cp /vagrant/bash_profile  .bash_profile && \
    .  .bash_profile && \
    cd OCCAM && \
    CC=clang CXX=clang++ make && \
    sudo -E make install 

       


