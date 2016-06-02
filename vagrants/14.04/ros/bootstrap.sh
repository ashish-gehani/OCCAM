#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y emacs24 dbus-x11 libgmp-dev
sudo apt-get install -y git subversion wget libprotobuf-dev python-protobuf protobuf-compiler
sudo apt-get install -y llvm-3.5 libclang-3.5-dev clang-3.5 tree


mkdir Repositories  && \
    cd Repositories &&  \
    git clone https://github.com/SRI-CSL/OCCAM.git && \
    git clone https://github.com/SRI-CSL/whole-program-llvm.git && \
    cp /vagrant/bash_profile  /home/vagrant/.bash_profile && \
    .  /vagrant/bash_profile && \
    cd OCCAM && \
    make && \
    make install 

#ros bootstrap dependencies
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) restricted universe multiverse"
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 0xB01FA116
sudo apt-get update
sudo apt-get install -y python-rosdep python-rosinstall-generator python-wstool python-rosinstall build-essential

sudo rosdep init
rosdep update
mkdir /home/vagrant/ros_catkin_ws
cd  /home/vagrant/ros_catkin_ws
#ROS-Comm: (Bare Bones) ROS package, build, and communication libraries. No GUI tools.
#Leonard recommends ROS desktop
#Turtlebot 2
#segway looks a better bet than turtlebot (shankar has one)
rosinstall_generator ros_comm --rosdistro jade --deps --wet-only --tar > jade-ros_comm-wet.rosinstall
wstool init -j8 src jade-ros_comm-wet.rosinstall

rosdep install --from-paths src --ignore-src --rosdistro jade -y

CC=wllvm CXX=wllvm++ ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release

cd install_isolated/bin/
extract-bc rospack
extract-bc rosstack

mkdir -p /vagrant/bitcode/

cp *.bc /vagrant/bitcode/

cd ../lib
extract-bc libcpp_common.so
extract-bc libmessage_filters.so
extract-bc librosbag.so
extract-bc librosbag_storage.so
extract-bc librosconsole_backend_interface.so
extract-bc librosconsole_log4cxx.so
extract-bc librosconsole.so
extract-bc libroscpp_serialization.so
extract-bc libroscpp.so
extract-bc libroslib.so
extract-bc libroslz4.so
extract-bc librospack.so
extract-bc librostime.so
extract-bc libtopic_tools.so
extract-bc libxmlrpcpp.so


cp *.bc /vagrant/bitcode/
