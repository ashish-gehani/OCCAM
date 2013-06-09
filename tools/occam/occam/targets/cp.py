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

from occam import toolchain
from occam import target
from occam.targets import par
from occam import driver
import os, shutil

class CpTool (par.ParallelTool):
    def opts(self, args):
        return ({}, args)
    
    def occam(self, cfg, args):
        flags = []
        nargs = []
        i = 0
        while i < len(args):
            if self.name == 'install' and args[i] in ['-B', '-f', '-g', '-m', '-o']:
                flags.extend(args[i:i+2])
                i += 1
            elif args[i].startswith('-'):
                flags.append(args[i])
            else:
                nargs.append(args[i])
            i += 1
        cmdline = flags
        def fixarg(arg): return self.fixinputname(arg,keep=False,create=self.name not in ['unlink','rm'])
        inputs = filter(None,map(fixarg,nargs[0:len(nargs)-1]))
        if not inputs:
            return 0
        last = nargs[len(nargs)-1]
        if len(nargs) > 1 and os.path.isdir(last) and self.name not in ['unlink', 'rm']:
            output = last
        else:
            output = self.fixname(last)
        cmdline = flags + inputs + [output]
        if self.name == 'ln' and os.path.exists(output):
            return 0
        return driver.run(cfg.getStdTool(self.name), cmdline)


target.register('cp', CpTool('cp'))
target.register('mv', CpTool('mv'))
target.register('ln', CpTool('cp'))
target.register('install', CpTool('install'))
target.register('unlink', CpTool('unlink'))
target.register('rm', CpTool('rm'))
