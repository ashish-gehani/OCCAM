#!/usr/bin/env python

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

from . import config
from . import driver
import tempfile
import re
import os, sys
import subprocess
import logging

class Ptrn1:
    def __init__(self, name, p):
        self._ptrn = re.compile(r'%s\((.+)\)' % name)
        self._proc = p

    def __call__(self, s):
        mtch = self._ptrn.match(s)
        if mtch:
            f = self._proc
            return apply(f, [mtch.group(1)])
        return None

class Ptrn2:
    def __init__(self, name, p):
        self._ptrn = re.compile(r'%s\(([^\s]+)\s*,\s*([^\s]+)\)' % name)
        self._proc = p

    def __call__(self, s):
        mtch = self._ptrn.match(s)
        if mtch:
            f = self._proc
            return apply(f, [(mtch.group(1), mtch.group(2))])
        return None


MACROS=[]
# Ptrn1('libc_hidden_def',
#               lambda x: ".global __GI_%s ; .hidden __GI_%s ; .set __GI_%s,%s" % (x,x,x,x)),
#         Ptrn1('libc_hidden_weak',
#               lambda x: ".hidden __GI_%s ; .weak __GI_%s ; .set __GI_%s,%s" % (x,x,x,x)),
#         Ptrn2('weak_alias',
#               lambda (x,y): ".weak %s ; .set %s,%s" % (y,y,x)),
#         Ptrn2('strong_alias',
#               lambda (x,y): ".global %s ; .set %s,%s" % (y,y,x))]

def removeComments(f):
    if '/*' in f:
        idx = f.find('/*')
        idx2 = f.find('*/', idx)
        return f[0:idx] + removeComments(f[idx2+2:])
    else:
        return f

ptrn = re.compile(r'\/\*.+?\*\/', re.MULTILINE)

CPP_OPTS = ['-fPIC', '-fpic']

def getcppargs(args):
    result = []
    i = 0
    while i < len(args):
        x = args[i]
        if x.startswith("-D") or x.startswith("-I"):
            result += [x]
            i += 1
            continue
        if x in CPP_OPTS:
            result += [x]
        if x == '-include' or x == '-isystem':
            result += [x,args[i+1]]
            i += 2
            continue
        i += 1
    return result

import tempfile

def getLabels(input_file, args):
    "compute the undefined labels in assembly code file 'input_file'"
    tf = tempfile.NamedTemporaryFile(delete=False)
    tf.close()
    proc_compiler = subprocess.Popen([config.getStdTool('clang'), '-c',
                                 input_file, '-o', tf.name] + args)
    proc_compiler.wait()
    proc_nm = subprocess.Popen([config.getStdTool('nm'), tf.name],
                               stdout=subprocess.PIPE)
    out = proc_nm.stdout.read()
    os.unlink(tf.name)
    return {'U' : re.compile(r'U\s+([^\s]+)').findall(out),
            'T' : re.compile(r'T\s+([^\s]+)').findall(out)}

def writeRequiredProvided(out, sym, ls):
    out.write('@%s = appending global [%d x i8*] [\n' % (sym, len(ls)))
    more = len(ls)
    for x in ls:
        more -= 1
        if more > 0:
            out.write('  i8* @%s,\n' % x)
        else:
            out.write('  i8* @%s\n' % x)

    out.write('], section "llvm.metadata"\n')

def assemble(input_file, output_file, args):
    cpp_args = getcppargs(args)
    
    logging.getLogger().log(logging.INFO, "%(input)s",
                            {'input' : driver.open_input(input_file).read() })

    fd = driver.open_input(input_file)

    p = subprocess.Popen([config.STD['cpp'], input_file] + cpp_args,
                         stdout=subprocess.PIPE,
                         stdin=fd)
    data = [x for x in p.stdout.readlines() if not x.startswith('#')]
    retcode = p.wait()

    logging.getLogger().log(logging.INFO, 'EXECUTING: %(cmd)s => %(code)d', 
                            {'cmd'  : ' '.join([config.STD['cpp'], input_file] + cpp_args),
                             'code' : retcode})
    
    tname = os.path.basename(input_file)

    out = open('/tmp/%s.ll' % tname, 'w')

    out.write("; ModuleID = '%s'\n" % tname)
    out.write("target datalayout = \"\"\n")
#e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:32:32-n8:16:32\"\n")
    out.write("target triple = \"x86_64-pc-linux-gnu\"\n")
    out.write("\n")

    def fixline(line):
        line = line.rstrip().replace("\"", '\\' + hex(ord('"')))
        for p in MACROS:
            v = p(line)
            if v:
                return v
        return line

    for x in data:
        x = fixline(x)
        if not (x is None):
            out.write('module asm "%s"\n' % x)

    def sanitize(symb):
        return symb.replace('@','_')

    labels = getLabels(input_file, args)
    provided = map(sanitize,labels['T'])
    required = map(sanitize,labels['U'])
    

    # TYPES={'__syscall_error' : ('void', []),
    #        '__sigjmp_save'   : ('i32', ['@sigjmp_buf','i32']),
    #        '__sigsetjmp'     : ('i32', ['@sigjmp_buf','i32']),
    #        '__libc_multiple_threads' : ('i32', None),
    #        '_dl_linux_resolver' : ('i64', []) }

    def typesig(p):
        if p.startswith('@'):
            return '%' + p[1:]
        else:
            return p

    if len(required) != 0:
        out.write('\n')
        for x in required:
            logging.getLogger().info("Declaring %s" % x)
            # (r,p) = TYPES[x]
            out.write('@%s = extern_weak global i8\n' % x)
            # out.write('declare %s @%s(%s)\n' % (r,x,','.join(map(typesig,p))))
            # for y in [y for y in p if y.startswith('@')]:
            #     print "opaque %s" % y
            #     out.write("%%%s = type opaque\n" % y[1:])
        
        out.write('\n')

        writeRequiredProvided(out, 'llvm.used', required)

    if len(provided) != 0:
        out.write('\n')
        for x in provided:
            logging.getLogger().info("Declaring %s" % x)
            out.write('@%s = extern_weak hidden global i8\n' % x)
        out.write('\n')
        writeRequiredProvided(out, 'llvm.provided', provided)

            
            

    out.close()

    res = driver.run(config.LLVM['as'],
                     ['/tmp/%s.ll' % tname, '-o', '%s' % output_file])
    if res == 0:
        os.unlink('/tmp/%s.ll' % tname)

    return 0
