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

from occam import toolchain
from occam import target
from occam import driver, config
from occam.target import ArgError
import getopt
import json
import os
import logging

def get_default(obj, key, default):
    if obj.has_key(key):
        return obj[key]
    else:
        return default

class NotFound (Exception):
    def __init__(self, name):
        self._name = name
    def __str__(self):
        return self._name

# Should warn if not native found
def get_library(lib, paths):
    if lib.startswith('-l'):
        lib = lib[2:]
        for p in paths:
            full_path = os.path.join(p, 'lib%s.bc.a' % lib)
            if os.path.exists(full_path):
                return full_path
            full_path = os.path.join(p, 'lib%s.a' % lib)
            if os.path.exists(full_path):
                return full_path
        raise NotFound(lib)
    else:
        full_path = os.path.abspath(lib)
        if os.path.exists(full_path):
            return full_path #driver.isLLVM(full_path))
        raise NotFound(full_path)

class BuildTool (target.Target):
    def opts(self, args):
        return getopt.getopt(args, 'O:o', ['ignore'])

    def usage(self):
        return "%s [--ignore] [-O?] <manifest> <output> [input.bc]+" % self.name
    def desc(self):
        return """Build a binary from its manifest."""
    def args(self):
        return [('--ignore', 'ignore the input file specified in the manifest'),
                ('-O?', "optimize (? = 0, 1, 2, 3)")]

    def run(self, cfg, flags, args):
        if len(args) < 2:
            raise ArgError()
        
        manifest = args[0]
        output = args[1]
        inputs = args[2:]
        
        manifest = json.load(open(manifest, 'r'))

        if not '--ignore' in map(lambda x: x[0], flags):
            inputs = get_default(manifest, 'modules', []) + inputs
        libs = get_default(manifest, 'libs', [])
        native_libs = get_default(manifest, 'native-libs', [])
        if '-lpthread' in native_libs:
            native_libs.append('-Xlinker=-pthread')
        search = get_default(manifest, 'search', [])
        def toLflag(path):
            if os.path.exists(path):
                return "-L%s" % path
            else:
                return None
        searchflags = [x for x in map(toLflag,search) if x is not None]
        shared = get_default(manifest, 'shared', [])
        try:
            found_libs = [get_library(x,search) for x in libs]
        except NotFound,e:
            logging.getLogger().error("ERROR: The library '%s' could not be found. Search path:" % e.__str__())
            logging.getLogger().error('\n'.join(search))
            return 1

        if output.endswith('.bc'):
            output = output[:-3]
        
        args = ['-native', '-o=%s' % output] + inputs + found_libs + searchflags + shared + ['-Xlinker=-static'] + native_libs
        for (a,b) in flags:
            if a == '-O':
                args += ['-O%s' % b]

        return driver.run(config.LLVM['ld'], args)

target.register('build', BuildTool('build'))
            
