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

from occam import target, driver
from .. import config
import os, sys
import shlex
import logging

def isChild():
    cmd = open('/proc/%d/cmdline' % os.getppid(),'r').read().split('\0')[0]
    
    # sys.stderr.write('=' * 60)
    # sys.stderr.write('\n')
    # sys.stderr.write(cmd)
    # sys.stderr.write('\n')
    # sys.stderr.write('-' * 60)
    # sys.stderr.write('\n')
    # exit(1)

    dir(config)

    return ('llvm-ld' == cmd) or \
           (os.path.abspath(cmd) == os.path.abspath(config.STD['clang']))

class ParallelTool (target.Target):
    def opts(self, args):
        return ([], args)

    def occam(self, cfg, args):
        pass

    def usage(self):
        return "%s ...%s args..." % (self.name, self.name)

    def run(self, cfg, _, args):
        logging.getLogger().info('%(cwd)s', {'cwd' : os.getcwd()})
        if not isChild():
            self.occam(cfg, args)
        return driver.run(cfg.getStdTool(self.name), args, pipe=False, inp=sys.stdin, resetPath=True)
    
    def createLo(self,old,new):
        if not os.path.isfile(new):
            oldFile = open(old, 'r')
            newFile = open(new, 'w')
            newFile.write(oldFile.read().replace('.o','.bc.o'))
            oldFile.close()
            newFile.close()

    def createLa(self,old,new):
        if not os.path.isfile(new):
            oldFile = open(old, 'r')
            newFile = open(new, 'w')
            newFile.write(oldFile.read().replace('.a','.bc.a'))
            oldFile.close()
            newFile.close()

 
    def fixinputname(self, name, keep=True, create=True):
        fixed = self.fixname(name)
        if os.path.isfile(fixed):
            return fixed
        else:
            if create and name.endswith(".lo") or name.endswith(".loT"):
                self.createLo(name,fixed)
                return fixed
            elif create and name.endswith(".la") or name.endswith(".laT"):
                self.createLa(name,fixed)
                return fixed
            else:
                logging.getLogger().warning('WARNING: bitcode version of %s not found, using original\n',
                                            name)
                if not keep:
                    return None
            return name

    def fixname(self, name):
        if name == '-':
            return name
        if '.bc.' in name:
            return name
        if name.endswith(".S"):
            return name
        if name.endswith(".bin"):
            # XXX Should this be more clever or should creating
            # .bin files be handled by some target?
            return name
        if '.' in name:
            return '%s.bc%s' % (name[:name.rfind('.')],
                                name[name.rfind('.'):])
        return '%s.bc' % name
