#Ian's Makefile -- point to the llvm-config of the version you want
# to build against and type make. Simple!

# BD: made all things dependent on LLVM_HOME
# (set in .bashrc)

LLVM_CONFIG = $(LLVM_HOME)/bin/llvm-config

#binaries version: /usr/local/llvm/bin/llvm-config
#built from source:
#debug    /usr/local/llvm-debug/bin/llvm-config
#release  /usr/local/llvm-release/bin/llvm-config

LLVM_INCLUDE = $(shell ${LLVM_CONFIG} --includedir)   

CXX_FLAGS = $(shell  ${LLVM_CONFIG} --cxxflags)  -I../include -I/usr/local/include

C_FLAGS = $(shell  ${LLVM_CONFIG} --cflags)

CPP_FLAGS = $(shell  ${LLVM_CONFIG} --cppflags)

PROTOC = $(shell which protoc)

LIBRARYNAME=libprevirt

OBJECTS := $(patsubst %.cpp,%.o,$(wildcard *.cpp)) proto/Previrt.pb.o  proto/Watch.pb.o 

INSTALL = install

all: ${LIBRARYNAME}.so

${LIBRARYNAME}.so: ${OBJECTS}
	$(CXX) ${OBJECTS} -shared -Wl,-soname,${LIBRARYNAME}.so -o ${LIBRARYNAME}.so ${CXX_FLAGS} ${LDFLAGS} -lpthread -lprotobuf


%.o: %.cpp protoc
	$(CXX) -I. ${CXX_FLAGS} $< -c 

proto/%.o: proto/%.cc proto/%.h protoc
	$(CXX)   -DGOOGLE_PROTOBUF_NO_RTTI ${CXX_FLAGS} $< -c -o $@


protoc: Watch.proto Previrt.proto
	mkdir -p proto
	${PROTOC} Watch.proto --cpp_out=proto
	${PROTOC} Previrt.proto --cpp_out=proto

clean: 
	rm -rf ${OBJECTS} proto ${LIBRARYNAME}.so


install: $(LIBRARYNAME).so
	$(INSTALL) -m 664 $(LIBRARYNAME).so $(OCCAM_LIB)
