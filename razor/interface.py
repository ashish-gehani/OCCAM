"""
 OCCAM

 Copyright (c) 2011-2017, SRI International

  All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

 * Neither the name of SRI International nor the names of its contributors may
   be used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


 The API to the protobuffer interface.

"""

import re
import sys

from .proto import Previrt_pb2 as pb

def emptyInterface():
    """ Returns an empty interface.
    """
    return pb.ComponentInterface()

def parseInterface(filename):
    """ Parses the filename as an interface.
    """
    result = pb.ComponentInterface()
    if filename == '-':
        result.ParseFromString(sys.stdin.read())
    else:
        result.ParseFromString(open(filename, 'rb').read())
    return result

def writeInterface(iface, filename):
    """ Writes the innterface out to the file.
    """
    if isinstance(filename, basestring):
        if filename == '-':
            f = sys.stdout
        else:
            f = open(filename, 'wb')
    else:
        f = filename
    f.write(iface.SerializeToString())
    f.close()

def mainInterface():
    """ Returns the interface for main.
    """
    main = pb.ComponentInterface()
    c = main.calls.add(name='main', count=1)
    c.args.add(type=pb.U)
    c.args.add(type=pb.U)
    main.references.extend('main')

    #iam 11/15/2016 these don't seem to be really necessary;
    # or if they are necessary, then there probably should be
    # a lot more, no?
    atexit = main.calls.add(name='atexit', count=1)
    atexit.args.add(type=pb.U)
    main.references.extend('atexit')

    #inittls = main.calls.add(name='_init_tls', count=1)
    #iam: no inittls.args.add ???
    main.calls.add(name='_init_tls', count=1)
    main.references.extend('_init_tls')

    exitr = main.calls.add(name='exit', count=1)
    exitr.args.add(type=pb.U)
    main.references.extend('exit')

    return main

def joinInterfaces(into, merge):
    """ Merges the first interface into the second.
    """
    result = False
    for mc in merge.calls:
        for c in [c for c in into.calls if c.name == mc.name]:
            if len(mc.args) != len(c.args):
                continue
            if c.args == mc.args:
                c.count += mc.count
                break
        else:
            into.calls.add(name=mc.name, args=mc.args, count=mc.count)
            result = True
    for mr in merge.references:
        if mr in into.references:
            continue
        else:
            into.references.append(mr)
            result = True
    return result

def readInterfaceFromText(f):
    """ parses the lines of f as an interface.
    """
    ptrn_rest = r'(?:\s*,\s*(.*))?'
    ptrn_call = re.compile(r'([^(]+)\(([^)]*)\)\s*(?::\s*([0-9]+))?')
    ptrn_int = re.compile(r'i([0-9]+)\s+([0-9]+)' + ptrn_rest)
    ptrn_str = re.compile(r'^"((?:[^"\\]|(?:\\"))+)"' + ptrn_rest)
    ptrn_unknown = re.compile(r'^\?' + ptrn_rest)

    result = pb.ComponentInterface()

    for line in [x.strip() for x in f.readlines()]:
        if not line:
            continue
        if line.startswith('#'):
            continue
        mtch = ptrn_call.match(line)
        if mtch:
            v = result.calls.add(name=mtch.group(1))
            if mtch.group(3):
                v.count = int(mtch.group(3))
            args = mtch.group(2).strip()
            while args and not args == '':
                args = args.strip()
                m = ptrn_unknown.match(args)
                if m:
                    args.add(type=pb.U)
                    args = m.group(1)
                else:
                    m = ptrn_int.match(args)
                    if m:
                        a = v.args.add(type=pb.I)
                        a.int.value = hex(int(m.group(2)))[2:]
                        a.int.bits = int(m.group(1))
                        args = m.group(3)
                    else:
                        m = ptrn_str.match(args)
                        if m:
                            a = v.args.add(type=pb.S)
                            a.str.data = m.group(1)
                            args = m.group(2)
                        else:
                            assert False
        else:
            print("skipping line '{0}'".format(line))
    return result
