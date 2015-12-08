# Ian's Makefile -- point to the llvm-config of the version you want
# to build against (using the LLVM_CONFIG environment variable) and
# type make.
#
# Simple!
#
# but set the default if there is no environment version there...
ifeq ($(LLVM_CONFIG),)
	LLVM_CONFIG=llvm-config
endif

# BD: made all things dependent on LLVM_HOME

LLVM_CFG = $(LLVM_HOME)/bin/$(LLVM_CONFIG)

LLVM_INCLUDE = $(shell ${LLVM_CFG} --includedir)

CXX_FLAGS = $(shell  ${LLVM_CFG} --cxxflags) -I${LLVM_INCLUDE} -I../include -I/usr/local/include

C_FLAGS = $(shell  ${LLVM_CFG} --cflags)

CPP_FLAGS = $(shell  ${LLVM_CFG} --cppflags)

LIBDIR = $(shell  ${LLVM_CFG} --libdir)

LLVMLIBS = $(shell  ${LLVM_CFG} --libs)


#iam: producing the library varies from OS to OS
OS   =  $(shell uname)

LIBRARYNAME=libprevirt

ifeq (Darwin, $(findstring Darwin, ${OS}))
#  DARWIN
LIB = ${LIBRARYNAME}.dylib
LIBFLAGS = -dynamiclib
OTHERLIBS =  -lpthread -lprotobuf -lcurses
else
# LINUX
LIB = ${LIBRARYNAME}.so
LIBFLAGS = -shared -Wl,-soname,${LIB}
OTHERLIBS =  -lpthread -lprotobuf 
endif

PROTOC = $(shell which protoc)

OBJECTS := proto/Previrt.pb.o proto/Watch.pb.o $(patsubst %.cpp,%.o,$(wildcard *.cpp)) 

INSTALL = install

all: ${LIB}

${LIB}: 
	$(MAKE) protoc 
	$(MAKE) lib

lib: ${OBJECTS}
	$(CXX) ${OBJECTS} ${LIBFLAGS} -o ${LIB} ${CXX_FLAGS} -L${LIBDIR} ${LLVMLIB} ${LLVMLIBS} ${OTHERLIBS}

%.o: %.cpp
	$(CXX) -I. ${CXX_FLAGS} $< -c 

proto/%.o: proto/%.cc proto/%.h 
	$(CXX)   -DGOOGLE_PROTOBUF_NO_RTTI ${CXX_FLAGS} $< -c -o $@

protoc: Watch.proto Previrt.proto
	mkdir -p proto
	${PROTOC} Watch.proto --cpp_out=proto
	${PROTOC} Previrt.proto --cpp_out=proto

clean: 
	rm -rf ${OBJECTS} proto ${LIB}


install: check-occam-lib ${LIB}
	$(INSTALL) -m 664 ${LIB} $(OCCAM_LIB)

#
# Check for OCCAM_LIB
#
check-occam-lib:
ifeq ($(OCCAM_LIB),)
	$(error OCCAM_LIB is undefined)
endif
