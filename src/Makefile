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

CXX_FLAGS += $(shell  ${LLVM_CFG} --cxxflags) -I${LLVM_INCLUDE} -I../include -I/usr/local/include  -DGOOGLE_PROTOBUF_NO_RTTI -fPIC -g

CXX_FLAGS += -Ianalysis/sea-dsa/include

C_FLAGS = $(shell  ${LLVM_CFG} --cflags)

CPP_FLAGS += $(shell  ${LLVM_CFG} --cppflags) -I${LLVM_INCLUDE} -I../include -I/usr/local/include

#iam: producing the library varies from OS to OS
OS   =  $(shell uname)

LIBRARYNAME=libprevirt

ifeq (Darwin, $(findstring Darwin, ${OS}))
#  DARWIN
LIBRARY = ${LIBRARYNAME}.dylib
LIBFLAGS = -dynamiclib
OTHERLIBS = -lpthread -lprotobuf -lcurses  
LD_FLAGS += -undefined suppress -flat_namespace
else ifeq (FreeBSD, $(findstring FreeBSD, ${OS}))
# FreeBSD
LIBRARY = ${LIBRARYNAME}.so
LIBFLAGS = -shared -Wl,-soname,${LIB}
OTHERLIBS = -L/usr/local/lib -lpthread -lprotobuf 
else
# LINUX
LIBRARY = ${LIBRARYNAME}.so
LIBFLAGS = -shared -Wl,-soname,${LIB}
OTHERLIBS =  -lpthread -lprotobuf 
endif

PROTOC = $(shell which protoc)

SOURCES = $(wildcard *.cpp) 

SOURCES += $(wildcard analysis/*.cpp)

SOURCES += $(wildcard transforms/*.cpp)

OBJECTS := proto/Previrt.pb.o proto/Watch.pb.o $(patsubst %.cpp,%.o,${SOURCES}) 

INSTALL = install

all: ${LIBRARY}

libSeaDsa:
	$(MAKE) -C analysis/sea-dsa install INSTALL_DIR=${OCCAM_LIB}

extern_libs: libSeaDsa

${LIBRARY}: extern_libs ${SOURCES}
	echo "The source is being built according to ${LLVM_CFG}"
	$(MAKE) protoc	
	$(MAKE) lib

lib: ${OBJECTS} 
	$(CXX) ${OBJECTS} ${LIBFLAGS} -o ${LIBRARY} ${CXX_FLAGS} ${LD_FLAGS} ${OTHERLIBS}

analysis/%.o: analysis/%.cpp 
	$(CXX) ${CXX_FLAGS} $< -c -o $@

transforms/%.o: transforms/%.cpp 
	$(CXX) ${CXX_FLAGS} $< -c -o $@

%.o: %.cpp
	$(CXX) -I. ${CXX_FLAGS} $< -c 

proto/%.o: proto/%.cc proto/%.h 
	$(CXX)  ${CXX_FLAGS} $< -c -o $@


protoc: Watch.proto Previrt.proto
	mkdir -p proto
	${PROTOC} Watch.proto --cpp_out=proto
	${PROTOC} Previrt.proto --cpp_out=proto

clean: 
	rm -rf ${OBJECTS} proto ${LIBRARY} 


install: check-occam-lib ${LIBRARY}
	$(INSTALL) -m 664 ${LIBRARY} $(OCCAM_LIB)

uninstall_occam_lib:
	rm -f $(OCCAM_LIB)/${LIBRARY}

#
# Check for OCCAM_LIB
#
check-occam-lib:
ifeq ($(OCCAM_LIB),)
	$(error OCCAM_LIB is undefined)
endif
