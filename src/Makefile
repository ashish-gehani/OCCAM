include Makefile.config

# use previrt rather than occam for historical reasons
LIBRARYNAME=libprevirt

### ================================================================== ###
CXX_FLAGS += -I../include -I/usr/local/include  -I../../../include
CXX_FLAGS += -DGOOGLE_PROTOBUF_NO_RTTI
CXX_FLAGS += -fPIC 
CXX_FLAGS += -Ianalysis/sea-dsa/include

LLVM_LIB_DIR = $(shell ${LLVM_CFG} --libdir)

CONFIG_PRIME_LIBS += -L${LLVM_LIB_DIR} -lLLVMExecutionEngine -lffi 
DEMANGLE_LIB += -lLLVMDemangle

ifeq (Darwin, $(findstring Darwin, ${OS}))
#  DARWIN
OCCAM_LIBRARY = ${LIBRARYNAME}.dylib
LIBFLAGS = -dynamiclib
OTHERLIBS = -lpthread -lprotobuf -lcurses  
LD_FLAGS += -undefined suppress -flat_namespace
CXX_FLAGS += -DHAVE_FFI_FFI_H
else ifeq (FreeBSD, $(findstring FreeBSD, ${OS}))
# FreeBSD
OCCAM_LIBRARY = ${LIBRARYNAME}.so
LIBFLAGS = -shared -Wl,-soname,${OCCAM_LIBRARY}
OTHERLIBS = -L/usr/local/lib -lpthread -lprotobuf 
else
# LINUX
OCCAM_LIBRARY = ${LIBRARYNAME}.so
LIBFLAGS = -shared -Wl,-soname,${OCCAM_LIBRARY} 
OTHERLIBS = -L/usr/local/lib -lpthread -lprotobuf 
CXX_FLAGS += -DHAVE_FFI_H
endif


PROTOC = $(shell which protoc)

SOURCES = $(wildcard *.cpp) 

SOURCES += $(wildcard analysis/*.cpp)

SOURCES += $(wildcard transforms/*.cpp)

SOURCES += $(wildcard transforms/utils/*.cpp)

SOURCES += $(wildcard interpreter/*.cpp)

SOURCES += $(wildcard utils/*.cpp)

OBJECTS := proto/Previrt.pb.o $(patsubst %.cpp,%.o,${SOURCES}) 

INSTALL = install

all: ${OCCAM_LIBRARY} seadsa seaopt

#===
# Create a dynamic library containing all the occam stuff
#===
${OCCAM_LIBRARY}: ${SOURCES}
	echo "The source is being built according to ${LLVM_CFG}"
	$(MAKE) protoc	
	$(MAKE) lib

#===
# Create dynamic library containing all the seadsa stuff
#===
seadsa:
	$(MAKE) -C analysis -f Makefile.sea-dsa install \
	INSTALL_DIR=${OCCAM_LIB}

#===
# Create a binary opt (similar to LLVM opt but with some tweaks)
#===
seaopt: seadsa
	$(MAKE) -C tools -f Makefile.llvm-seahorn install \
	INSTALL_BINDIR=${OCCAM_BIN} INSTALL_LIBDIR=${OCCAM_LIB}

lib: ${OBJECTS} 
	$(CXX) ${OBJECTS} ${LIBFLAGS} -o ${OCCAM_LIBRARY} ${CXX_FLAGS} ${LD_FLAGS} \
	${OTHERLIBS} ${CONFIG_PRIME_LIBS} ${DEMANGLE_LIB}

analysis/%.o: analysis/%.cpp 
	$(CXX) ${CXX_FLAGS} $< -c -o $@

transforms/%.o: transforms/%.cpp 
	$(CXX) ${CXX_FLAGS} $< -c -o $@

transforms/utils/%.o: transforms/utils/%.cpp 
	$(CXX) ${CXX_FLAGS} $< -c -o $@

interpreter/%.o: interpreter/%.cpp 
	$(CXX) ${CXX_FLAGS} $< -c -o $@

utils/%.o: utils/%.cpp 
	$(CXX) ${CXX_FLAGS} $< -c -o $@

%.o: %.cpp
	$(CXX) -I. ${CXX_FLAGS} $< -c 

proto/%.o: proto/%.cc proto/%.h 
	$(CXX)  ${CXX_FLAGS} $< -c -o $@

protoc: Previrt.proto
	mkdir -p proto
	${PROTOC} Previrt.proto --cpp_out=proto

clean: 
	rm -rf ${OBJECTS} proto ${OCCAM_LIBRARY}
	$(MAKE) -C analysis -f Makefile.sea-dsa clean
	$(MAKE) -C tools -f Makefile.llvm-seahorn clean

install: check-occam-lib ${OCCAM_LIBRARY}
	$(INSTALL) -m 664 ${OCCAM_LIBRARY} $(OCCAM_LIB)

uninstall_occam_lib:
	rm -f $(OCCAM_LIB)/${OCCAM_LIBRARY}

#
# Check for OCCAM_LIB
#
check-occam-lib:
ifeq ($(OCCAM_LIB),)
	$(error OCCAM_LIB is undefined)
endif
