# ------------------------------------------------------------------------------
# OCCAM
#
# Copyright © 2011-2012, SRI International
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

from occam import toolchain, driver
from occam.targets import par
from occam import target
import os, shutil

def parse_args(args, opts, fn):
    i = 0
    nargs = []
    flags = []
    while i < len(args):
        if args[i] in opts:
            flags.append(args[i])
            flags.append(args[i+1])
            i += 1
        elif args[i].startswith('-'):
            flags.append(args[i])
        else:
            r = fn(args[i])
            if r is not None:
                nargs.append(r)
        i += 1
    return (flags,nargs)

def remove_dups(args):
    return [x for (x,i) in zip(args, range(0, len(args)))
            if args.index(x) == i]
    

class InstallTool (par.ParallelTool):
    def occam(self, cfg, args):
        def modify(p):
            if p.startswith('-'):
                return p
            if os.path.isdir(p):
                return p
            if os.path.exists(self.fixinputname(p)):
                return self.fixinputname(p)
            return None
        (flags,nargs) = parse_args(args, ['-m', '-o', '-g'], modify)
        nargs = remove_dups(nargs)
        if len(nargs) == 0:
            return 0
        elif len(nargs) == 1:
            if os.path.isdir(args[-1]):
                return 0
            else:
                nargs += [self.fixinputname(args[-1])]
        return driver.run(cfg.getStdTool('install'),
                          flags + nargs)

target.register('install', InstallTool('install'))
