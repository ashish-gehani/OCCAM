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
from occam import driver
from occam import target
from occam.targets import par
import os

# TODO

class StripTool (par.ParallelTool):
    def opts(self, args):
        return ({}, args)
    
    def occam(self, cfg, args):
        # "opt -strip %s -o %s" % (input_file, intput_file)
        return driver.run(cfg.getLlvmTool('opt'), 
                          ['-strip', input_file, '-o=%s' % output_file])

class RanlibTool (par.ParallelTool):
    def opts(self, args):
        return ({}, args)
    
    def occam(self, cfg, args):
        def modify(p):
            if p.startswith('-'):
                return p
            else:
                return self.fixinputname(p)
        args = map(modify,args)
        return driver.run(cfg.getStdTool('ranlib'), args)
        
class ChmodTool (par.ParallelTool):
    def opts(self, args):
        return ({}, args)
    
    def occam(self, cfg, args):
        def modify(p):
            if p.startswith('-'):
                return p
            else:
                return self.fixinputname(p)
        args = map(modify,args)
        return driver.run(cfg.getStdTool('chmod'), args)

target.register('strip', StripTool('strip'))
target.register('ranlib', RanlibTool('ranlib'))
target.register('chmod', ChmodTool('chmod'))

