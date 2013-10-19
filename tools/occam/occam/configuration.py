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

import ConfigParser
import os

class OccamConfig:
    def __init__(self, fn=None):
        self._cfg = ConfigParser.SafeConfigParser(allow_no_value=True)
        if not (fn is None):
            self._cfg.read(fn)

    def getRoot(self):
        if self._cfg.has_section('fs') and self._cfg.has_option('fs', 'root'):
            return self._cfg.get('fs','root')
        return "/"
    def getPath(self):
        if self._cfg.has_option('paths', 'path'):
            return self._cfg.get('paths','path')
        return os.getenv('PATH')
    def getLlvmLibSearchPath(self):
        if self._cfg.has_option('paths', 'llvm-lib-search'):
            return self._cfg.get('paths','llvm-lib-search')
        return os.getenv('LLVM_LIB_SEARCH_PATH')
    def getLibSearchPath(self):
        if self._cfg.has_option('paths', 'lib-search'):
            return self._cfg.get('paths','lib-search')
        return os.getenv('LIB_SEARCH')

    def allVars(self):
        # TODO
        return []

CONFIG = None
FOUND_CONFIG = False

def foundConfig():
    return FOUND_CONFIG

def defaultConfig():
    return OccamConfig()

def getConfig():
    global CONFIG
    if not (CONFIG is None):
        return CONFIG

    FOUND_CONFIG = True
    p = os.getcwd()
    
    while p != '/':
        if os.path.exists(os.path.join(p, '.occam')):
            CONFIG = OccamConfig(os.path.join(p, '.occam'))
            return CONFIG
        p = os.path.dirname(p)
    
    p = os.path.join(os.getenv('HOME'), '.occam')
    if os.path.exists(p):
        CONFIG = OccamConfig(p)
        return CONFIG

    CONFIG = defaultConfig()
    FOUND_CONFIG = False
    return CONFIG
