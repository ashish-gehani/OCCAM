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

from occam import watchparse, watchparse2
from occam import target

import sys

def readFile(fn):
    if fn == '-':
        return sys.stdin.read()
    else:
        return open(fn, 'r').read()

class ReadTool (target.Target):
    def usage(self):
        return "%s <watch2|watch|iface|rw> <files>+" % self.name
    def desc(self):
        return """  Parse the given file and produce a protocol buffer.
               """

    def run(self, cfg, flags, args):
        if len(args) < 2:
            self.help()
            return -1
        
        if args[0] == 'hook' or args[0] == 'watch':
            result = None
            for x in args[1:]:
                if result is None:
                    result = watchparse.parse(readFile(x))
                else:
                    watchparse.parseInto(result, readFile(x))
            if not (result is None):
                sys.stdout.write(result.SerializeToString())
            return 0
        elif args[0] == 'hook2' or args[0] == 'watch2':
            result = None
            for x in args[1:]:
                if result is None:
                    result = watchparse2.parse(readFile(x))
                else:
                    watchparse.parseInto(result, readFile(x))
            if not (result is None):
                sys.stdout.write(result.SerializeToString())
            return 0
        elif args[0] == 'iface':
            assert False
        elif args[0] == 'rw':
            assert False
        else:
            self.help()
            return -1

target.register('parse', ReadTool('parse'))
