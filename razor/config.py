"""
 OCCAM

 Copyright (c) 2011-2017, SRI International

  All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

 * Neither the name of SRI International nor the names of its contributors may
   be used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  The configuration object isolates access to the user's environment.

"""
import os
import platform
import sys



class ConfigObj(object):
    """All access to the environment comes through this class.
    """
    def  __init__(self, libfile, dsalib):
        self._occamlib = libfile
        self._dsalib = dsalib
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

    def get_dsalib(self):
        """ Returns the path to the DSA library.
        """
        return self._dsalib    

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

def get_dsalib_path():
    """ Deduces the full path to the DSA shared/dynamic library.
    """
    home = os.getenv('OCCAM_HOME')
    if home is None:
        return None
    system = platform.system()
    if system == 'Linux':
        return os.path.join(home, 'lib', 'libSeaDsa.so')
    elif system == 'Darwin':
        return os.path.join(home, 'lib', 'libSeaDsa.dylib')
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

CFG = ConfigObj(get_occamlib_path(), get_dsalib_path())

def get_occamlib():
    """ Returns the path to the occam shared/dynamic library.
    """
    return CFG.get_occamlib()

def get_dsalib():
    """ Returns the path to the DSA shared/dynamic library.
    """
    return CFG.get_dsalib()

def get_llvm_tool(tool):
    """ Returns the appropriate tool.
    """
    tool = CFG.get_llvm_tool(tool)
    llvm_home = os.getenv('LLVM_HOME')
    if llvm_home:
        return os.path.join(llvm_home, 'bin', tool)
    else:
        return tool
