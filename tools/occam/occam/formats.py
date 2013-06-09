#!/usr/local/bin/python

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

from proto import Previrt_pb2 as proto
import google
import os, sys

class Format:
    def make(self):
        raise Exception()
    def parse_file(self, filename):
        return self.parse_string(open(filename, 'rb').read())
    def parse_string(self, data):
        x = self.make()
        try:
            x.ParseFromString(data)
            if x.IsInitialized():
                self.show(x)
                return True
            else:
                return False
        except:
            return False
    def show(self, _):
        assert False

def cstr(s):
    return s.replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r")

def string_of_PrevirtType(pt, any_str):
    if pt.type == proto.U:
        return any_str
    elif pt.type == proto.I:
        return "i%d=%d" % (pt.int.bits, int(pt.int.value,16))
    elif pt.type == proto.S:
        return "i8x%d=\"%s\\0\"" % (len(pt.str.data),cstr(pt.str.data))
    elif pt.type == proto.V:
        data = [string_of_PrevirtType(x,"?") for x in pt.vec.value]
        return "??x%d=[%s]" % (len(pt.vec.value), ','.join(data))
    assert False

def showCall(c):
    args = [string_of_PrevirtType(x,'?') for x in c.args]
    print "%s(%s) # %d times" % (c.name.__repr__(), ','.join(args), c.count)

def showRewrite(rw):
    old_args = [string_of_PrevirtType(x,'?%d' % i)
                for (x,i) in zip(rw.call.args, range(0,100))]
    new_args = ['?%d' % x for x in rw.args]
    print "%s(%s) --> %s(%s)" % (rw.call.name.__repr__(), ','.join(old_args),
                                 rw.new_function.__repr__(), ','.join(new_args))

class InterfaceFormat (Format):    
    def make(self):
        return proto.ComponentInterface()
    def show(self, iface):
        for c in iface.calls:
            showCall(c)

class InterfaceTransformFormat (Format):    
    def make(self):
        return proto.ComponentInterfaceTransform()
    def show(self, xform):
        calls = {}
        for c in xform.calls:
            if calls.has_key(c.call.name):
                calls[c.call.name] += [c]
            else:
                calls[c.call.name] = [c]
        for v in calls.values():
            showCall(v[0].call)
            for rw in v:
                sys.stdout.write('> ')
                showRewrite(rw)

FORMATS=[InterfaceFormat(),InterfaceTransformFormat()]
         
