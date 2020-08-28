include Makefile.config

CXX_FLAGS += -I../include -I/usr/local/include  -I../../../include
CXX_FLAGS += -DGOOGLE_PROTOBUF_NO_RTTI
CXX_FLAGS += -fPIC 
CXX_FLAGS += -Ianalysis/sea-dsa/include

CONFIG_PRIME_LIBDIR = $(shell ${LLVM_CFG} --libdir)
CONFIG_PRIME_LIBS += -L${CONFIG_PRIME_LIBDIR} -lLLVMExecutionEngine -lffi

LIBRARYNAME=libprevirt

ifeq (Darwin, $(findstring Darwin, ${OS}))
#  DARWIN
LIBRARY = ${LIBRARYNAME}.dylib
LIBFLAGS = -dynamiclib
OTHERLIBS = -lpthread -lprotobuf -lcurses  
LD_FLAGS += -undefined suppress -flat_namespace
CXX_FLAGS += -DHAVE_FFI_FFI_H
else ifeq (FreeBSD, $(findstring FreeBSD, ${OS}))
# FreeBSD
LIBRARY = ${LIBRARYNAME}.so
LIBFLAGS = -shared -Wl,-soname,${LIBRARY}
OTHERLIBS = -L/usr/local/lib -lpthread -lprotobuf
else
# LINUX
LIBRARY = ${LIBRARYNAME}.so
LIBFLAGS = -shared -Wl,-soname,${LIBRARY} 
OTHERLIBS =  -lpthread -lprotobuf
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

all: ${LIBRARY}

libSeaDsa:
	$(MAKE) -C analysis -f Makefile.sea-dsa install INSTALL_DIR=${OCCAM_LIB}

${LIBRARY}: libSeaDsa ${SOURCES}
	echo "The source is being built according to ${LLVM_CFG}"
	$(MAKE) protoc	
	$(MAKE) lib

lib: ${OBJECTS} 
	$(CXX) ${OBJECTS} ${LIBFLAGS} -o ${LIBRARY} ${CXX_FLAGS} ${LD_FLAGS} \
	${OTHERLIBS} ${CONFIG_PRIME_LIBS}

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
	rm -rf ${OBJECTS} proto ${LIBRARY} 
	$(MAKE) -C analysis -f Makefile.sea-dsa clean

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
