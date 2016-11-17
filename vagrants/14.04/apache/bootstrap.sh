#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y emacs24 dbus-x11 libgmp-dev
sudo apt-get install -y git subversion wget libprotobuf-dev python-protobuf protobuf-compiler
sudo apt-get install -y llvm-3.5 libclang-3.5-dev clang-3.5 tree 
sudo apt-get install -y python-pip
sudo pip install wllvm

mkdir Repositories  && \
    cd Repositories &&  \
    git clone https://github.com/SRI-CSL/OCCAM.git && \
    cp /vagrant/bash_profile  /home/vagrant/.bash_profile && \
    .  /home/vagrant/.bash_profile && \
    cd OCCAM && \
    make && \
    sudo -E make install 

       


