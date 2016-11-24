""" The configuration object isolates access to the user's environment.
"""
import os
import platform
import sys



class ConfigObj(object):
    """All access to the environment comes through this class.
    """
    def  __init__(self, libfile):
        self._occamlib = libfile
        self._env = {'clang'      :  'LLVM_CC_NAME',
                     'clang++'    :  'LLVM_CXX_NAME',
                     'llvm-link'  :  'LLVM_LINK_NAME',
                     'llvm-ar'    :  'LLVM_AR_NAME',
                     'llvm-as'    :  'LLVM_AS_NAME',
                     'llvm-ld'    :  'LLVM_LD_NAME',
                     'llc'        :  'LLVM_LLC_NAME',
                     'opt'        :  'LLVM_OPT_NAME',
                     'llvm-nm'    :  'LLVM_NM_NAME',
                     'clang-cpp'  :  'LLVM_CPP_NAME'}

    def env_version(self, name):
        """ Returns the tool as defined in the user's environment.
        """
        env_name = None
        if name in self._env:
            env_name = os.getenv(self._env[name])
        return env_name if env_name else name

    def get_occamlib(self):
        """ Returns the path to the occam shared/dynamic library.
        """
        return self._occamlib


    def get_llvm_tool(self, tool):
        """ Returns the appropriate tool.
        """
        return self.env_version(tool)

def get_occamlib_path():
    """ Deduces the full path to the occam shared/dynamic library.
    """
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


def get_logfile():
    """ Returns the path to the occam logfile.
    """
    logfile = os.getenv('OCCAM_LOGFILE')
    if not logfile:
        logfile = '/tmp/occam.log'
    return logfile

CFG = ConfigObj(get_occamlib_path())

def get_occamlib():
    """ Returns the path to the occam logfile.
    """
    return CFG.get_occamlib()

def get_llvm_tool(tool):
    """ Returns the appropriate tool.
    """
    return CFG.get_llvm_tool(tool)
