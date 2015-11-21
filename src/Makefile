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
# (set in .bashrc)

LLVM_CFG = $(LLVM_HOME)/bin/$(LLVM_CONFIG)

#binaries version: /usr/local/llvm/bin/llvm-config
#built from source:
#debug    /usr/local/llvm-debug/bin/llvm-config
#release  /usr/local/llvm-release/bin/llvm-config

LLVM_INCLUDE = $(shell ${LLVM_CFG} --includedir)

CXX_FLAGS = $(shell  ${LLVM_CFG} --cxxflags) -I${LLVM_INCLUDE} -I../include -I/usr/local/include

C_FLAGS = $(shell  ${LLVM_CFG} --cflags)

CPP_FLAGS = $(shell  ${LLVM_CFG} --cppflags)

PROTOC = $(shell which protoc)

LIBRARYNAME=libprevirt

OBJECTS := proto/Previrt.pb.o proto/Watch.pb.o $(patsubst %.cpp,%.o,$(wildcard *.cpp)) 

INSTALL = install

all: ${LIBRARYNAME}.so

${LIBRARYNAME}.so: 
	$(MAKE) protoc 
	$(MAKE) lib

lib: ${OBJECTS}
	$(CXX) ${OBJECTS} -shared -Wl,-soname,${LIBRARYNAME}.so -o ${LIBRARYNAME}.so ${CXX_FLAGS} ${LDFLAGS} -lpthread -lprotobuf

%.o: %.cpp
	$(CXX) -I. ${CXX_FLAGS} $< -c 

proto/%.o: proto/%.cc proto/%.h 
	$(CXX)   -DGOOGLE_PROTOBUF_NO_RTTI ${CXX_FLAGS} $< -c -o $@

protoc: Watch.proto Previrt.proto
	mkdir -p proto
	${PROTOC} Watch.proto --cpp_out=proto
	${PROTOC} Previrt.proto --cpp_out=proto

clean: 
	rm -rf ${OBJECTS} proto ${LIBRARYNAME}.so


install: check-occam-lib $(LIBRARYNAME).so
	$(INSTALL) -m 664 $(LIBRARYNAME).so $(OCCAM_LIB)

#
# Check for OCCAM_LIB
#
check-occam-lib:
ifeq ($(OCCAM_LIB),)
	$(error OCCAM_LIB is undefined)
endif
