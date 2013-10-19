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

from occam.target import ArgError
from occam import target
from occam import toolchain, driver, passes
import getopt

class SpecializeTool (target.Target):
    def opts(self, args):
        return getopt.getopt(args, 'o:', ['rw='])

    def usage(self):
        return "%s -o <output.bc> --rw <output.rw> <input.bc> <interfaces>+" % self.name
    def desc(self):
        return '\n'.join(
            ["  simplify input.bc with respect to the given interfaces.",
             "  generates a simplified module (output.bc) and a rewrite",
             "  specification for taking programs with the old specification",
             "  and rewriting them for the new specification."])
    def args(self):
        return [('--in', "place checks inside the function"),
                ('--out', "place checks at function calls"), 
                ('-o', "the output file")]

    def run(self, cfg, flags, args):
        if len(args) < 2:
            raise ArgError()
        input_file = args[0]
        interfaces = args[1:]
        
        output_file = target.flag(flags, '-o')
        rw_file = target.flag(flags, '--rw')

        return passes.specialize(input_file, output_file, 
                                 rw_file, interfaces)

target.register('specialize', SpecializeTool('specialize'))
            
