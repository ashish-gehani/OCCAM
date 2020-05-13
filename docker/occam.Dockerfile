# Dockerfile for OCCAM binary
# produces package in /occam/build
# Arguments:
#  - UBUNTU:     bionic
#  - BUILD_TYPE: debug, release

ARG UBUNTU

# Pull base image.
FROM buildpack-deps:$UBUNTU

ARG BUILD_TYPE
RUN echo "Build type set to: $BUILD_TYPE" && \
     # Install deps.
    apt-get update && \
    apt-get install -yqq software-properties-common && \
    apt-get update && \
    apt-get install -y wget libprotobuf-dev python-protobuf protobuf-compiler && \
    apt-get install -y python-pip

RUN pip --version && \
    pip install setuptools --upgrade && \
    pip install wheel && \
    pip install protobuf && \
    pip install lit
RUN apt-get install -yqq libboost-dev

RUN mkdir /go
ENV GOPATH "/go"

RUN apt-get -y install golang-go && \
    go get github.com/SRI-CSL/gllvm/cmd/...

# Install llvm10 from llvm repo since bionic comes with much older version
WORKDIR /tmp
RUN wget https://apt.llvm.org/llvm.sh && \
  chmod +x llvm.sh && \
  ./llvm.sh 10

ENV LLVM_HOME "/usr/lib/llvm-10"
ENV PATH "$LLVM_HOME/bin:/bin:/usr/bin:/usr/local/bin:/occam/utils/FileCheck_trusty:$GOPATH/bin:$PATH"

RUN cd / && rm -rf /occam && \
    git clone --recurse-submodules https://github.com/SRI-CSL/OCCAM.git occam --branch llvm10 --depth=10
    
WORKDIR /occam
ENV CC clang
ENV CXX clang++
ENV LLVM_COMPILER clang
ENV WLLVM_OUTPUT WARNING
ENV OCCAM_HOME "/occam"

# Build configuration.
RUN make
RUN make install
RUN make test
