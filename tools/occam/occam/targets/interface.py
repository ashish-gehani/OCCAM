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

from occam import passes
from occam import interface, formats
from occam import target
import sys
import getopt
import tempfile

def deep(libs, iface):
    tf = tempfile.NamedTemporaryFile(suffix='.iface', delete=False)
    tf.close()
    if not (iface is None):
        interface.writeInterface(iface, tf.name)
    else:
        iface = interface.emptyInterface()

    progress = True
    while progress:
        progress = False
        for l in libs:
            passes.interface(l, tf.name, [tf.name], quiet=True)
            x = interface.parseInterface(tf.name)
            progress = interface.joinInterfaces(iface, x) or progress
            interface.writeInterface(iface, tf.name)

    tf.unlink(tf.name)
    return iface

def shallow(libs, iface):
    tf = tempfile.NamedTemporaryFile(suffix='.iface', delete=False)
    tf.close()
    if not (iface is None):
        interface.writeInterface(iface, tf.name)
    else:
        iface = interface.emptyInterface()

    for l in libs:
        passes.interface(l, tf.name, [tf.name], quiet=True)
        x = interface.parseInterface(tf.name)
        interface.joinInterfaces(iface, x)

    tf.unlink(tf.name)
    return iface

def parse(fn):
    if fn == '@main':
        return interface.mainInterface()
    else:
        print fn
        return interface.parseInterface(fn)

class InterfaceTool (target.Target):
    def opts(self, args):
        return getopt.getopt(args, 'o:', ['deep', 'join'])

    def usage(self):
        return '\n'.join(
            ["%s [-o <output.iface>] <interface.iface> <input.bc>+" % self.name,
             "%s [-o <output.iface>] --deep <interface.iface> <input.bc>+" % self.name,
             "%s [-o <output.iface>] --join <interfaces.iface>+" % self.name])

    def desc(self):
        return '\n'.join(
            ["  This tool computes the minimal interfaces accross all libraries.",
             "  !main! can be used as any interface file name and it will insert",
             "  the interface that has a single call to main(?,?)",
             "  which is the default entry point.",
             "  NOTE: This is only safe if there are no calls into these",
             "        libraries from modules that are not listed.",
             "  The tool supports the following usages:",
             "%s <output.iface> <input.bc> [<interfaces.iface>+]" % self.name,
             "  compute the functions required for input.bc given the",
             "  calls in the given interface files are the entry points",
             "%s --deep <output.iface> <input.bc>+ --with <interfaces.iface>+" % self.name,
             "  recursively compute the minimal interfaces needed for the input",
             "  bc files and write the cumulative interface to output.iface.",
             "  The --with parameters specify input interfaces",
             "%s --join <output.iface> <interfaces.iface>+" % self.name,
             "  Join the given interfaces into a single interface,",
             "  write the combined interface to stdout"])

    def run(self, cfg, flags, args):
        output = target.flag(flags, '-o', '-')
        if ('--join','') in flags:
            if len(args) < 1:
                raise target.ArgError()
            ifs = [parse(x) for x in args]
            result = ifs[0]
            for x in ifs[1:]:
                interface.joinInterfaces(result, x)
        else:
            # This is computing the interface
            if len(args) < 1:
                raise target.ArgError()
            if args[0] == '@*':
                iface = None
            else:
                iface = parse(args[0])
            libs = args[1:]
            
            if '--deep' in flags:
                result = deep(libs, iface)
            else:
                result = shallow(libs, iface)

        interface.writeInterface(result, output)
        return 0            

target.register('interface', InterfaceTool('interface'))
