#!/usr/bin/env python

# ------------------------------------------------------------------------------
# OCCAM
#
# Copyright (c) 2011-2012, SRI International
#
#  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of SRI International nor the names of its contributors may
#   be used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ------------------------------------------------------------------------------

import subprocess, os

def which(name):
    proc = subprocess.Popen(['which', name], stdout=subprocess.PIPE)
    return proc.stdout.read().strip()

def llvm(name):
    llvmdir = os.getenv('LLVM_HOME')
    if llvmdir is not None:
        return os.path.join(llvmdir, 'bin', name)
    else:
        proc = subprocess.Popen(['which', name], stdout=subprocess.PIPE)
        return proc.stdout.read().strip()

def occam(name):
    occamdir = os.getenv('OCCAM_HOME')
    if occamdir is not None:
        return os.path.join(occamdir, 'bin', name)
    else:
        proc = subprocess.Popen(['which', name], stdout=subprocess.PIPE)
        return proc.stdout.read().strip()

ENV = {
    'clang'      :  'LLVM_CC_NAME',
    'clang++'    :  'LLVM_CXX_NAME',  
    'llvm-link'  :  'LLVM_LINK_NAME',    
    'llvm-ar'    :  'LLVM_AR_NAME',    
    'llvm-as'    :  'LLVM_AS_NAME',    
    'llvm-ld'    :  'LLVM_LD_NAME',    
    'llc'        :  'LLVM_LLC_NAME',    
    'opt'        :  'LLVM_OPT_NAME',    
    'llvm-nm'    :  'LLVM_NM_NAME',    
    'clang-cpp'  :  'LLVM_CPP_NAME',  
}


def env_version(name):
    env_name = None
    if name in ENV:
        env_name = os.getenv(ENV[name])
    if env_name:
        name = env_name
    return name

def std(name):
    return env_version(name)

if __name__ == '__main__':
    print """LOGFILE='%s/../log'""" % os.path.abspath(os.path.dirname(__file__))
    libprevirt = os.getenv('OCCAM_LIB') + '/libprevirt.so'
    print "OCCAM_LIB='%s'" % libprevirt
#    dragonegg = os.getenv('DRAGONEGG')
#    print "DRAGONEGG='%s'" % dragonegg
    print """
LLVM = { 'link'    : "%s"
       , 'as'      : "%s"
       , 'ar'      : "%s"
       , 'ld'      : "%s"
       , 'opt'     : "%s"
       , 'clang'   : "%s"
       , 'clang++' : "%s"
       , 'clang-cpp' : "%s"
       , 'nm'      : "%s"
       , 'llc'     : "%s"
       }""" % (std('llvm-link'), std('llvm-as'), std('llvm-ar'), 
               std('llvm-ld'), std('opt'), std('clang'),
               std('clang++'), std('clang-cpp'), std('llvm-nm'),
               std('llc'))
#% (llvm('llvm-link'), llvm('llvm-as'), llvm('llvm-ar'), 
#               llvm('llvm-ld'), llvm('opt'), llvm('clang'),
#               llvm('clang++'), llvm('llvm-nm'))
    print """
STD =  { 'as'   : "%s"
       , 'ar'   : "%s"
       , 'nm'   : "%s"
       , 'ld'   : "%s"
       , 'clang'  : "%s"
       , 'clang++'  : "%s"
       , 'clang-cpp' : "%s"
       , 'install' : "%s"
       , 'ranlib' : "%s"
       , 'cp' : "%s"
       , 'mv' : "%s"
       , 'cpp' : "%s"
       , 'file' : "%s"
       , 'chmod' : "%s"
       , 'ln' : "%s"
       , 'rm' : "%s"
       , 'unlink' : "%s"
       }""" % (std("as"),
               std("ar"),
               std("nm"),
               std("ld"),
               std("clang"),
               std("clang++"),
               std("clang-cpp"),
               std('install'),
               std("ranlib"),
               std('cp'),
               std('mv'),
               std("cpp"),
               std('file'),
               std('chmod'),
               std('ln'),
               std('rm'),
               std('unlink'))
    print """
def getStdTool(tool):
    if STD.has_key(tool):
        return STD[tool]
    return tool

def getLLVMTool(tool):
    if LLVM.has_key(tool):
        return LLVM[tool]
    return tool
"""
