import os, platform, sys


class cfgObj(object):

    def  __init__(self, libfile):
        self._occamlib = libfile
        
        self._env = { 'clang'        :  'LLVM_CC_NAME'
                      , 'clang++'    :  'LLVM_CXX_NAME'  
                      , 'llvm-link'  :  'LLVM_LINK_NAME'    
                      , 'llvm-ar'    :  'LLVM_AR_NAME'    
                      , 'llvm-as'    :  'LLVM_AS_NAME'    
                      , 'llvm-ld'    :  'LLVM_LD_NAME'    
                      , 'llc'        :  'LLVM_LLC_NAME'    
                      , 'opt'        :  'LLVM_OPT_NAME'    
                      , 'llvm-nm'    :  'LLVM_NM_NAME'   
                      , 'clang-cpp'  :  'LLVM_CPP_NAME'  
                  }
        
    def env_version(self, name):
        env_name = None
        if name in self._env:
            env_name = os.getenv(self._env[name])
        return env_name if env_name else name

    def getOccamLib(self):
        return self._occamlib

    def getLogfile(self):
        logfile = os.getenv('OCCAM_LOGFILE')
        if not logfile:
            logfile = '/tmp/occam.log'
        return logfile

    def getLLVMTool(self, tool):
        return self.env_version(tool)

def getOccamLibPath():
    home = os.getenv('OCCAM_HOME')
    if home is None:
        return None
    system = platform.system()
    if system == 'Linux':
        return os.path.join(home, 'lib', 'libprevirt.so')
    elif system == 'Darwin':
        return os.path.join(home, 'lib', 'libprevirt.dylib')
    else:
        sys.stderr.write('Unsupported platform: {0}\n'.format(system))
        return None
    


theConfig = cfgObj(getOccamLibPath())

def getOccamLib():
    return theConfig.getOccamLib()

def getLogfile():
    return theConfig.getLogfile()

def getLLVMTool(tool):
    return theConfig.getLLVMTool(tool)

    
