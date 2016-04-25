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

from . import formats
from driver import previrt, previrt_progress, run, all_args
import interface as inter
from . import config
import os, tempfile, shutil, logging, subprocess

def interface(input_file, output_file, wrt, **opts):
    return previrt(input_file, '/dev/null',
                   ['-Pinterface2', '-Pinterface2-output', output_file] +
                   all_args('-Pinterface2-entry', wrt),
                   **opts)

def specialize(input_file, output_file, rewrite_file, interfaces, **opts):
    "inter module specialization, rewrite_file and output_file and the file names for the output files"
    args = ['-Pspecialize']
    if not (rewrite_file is None):
        args += ['-Pspecialize-output', rewrite_file]
    if output_file is None:
        output_file = '/dev/null'
    return previrt(input_file, output_file,
                   args + all_args('-Pspecialize-input', interfaces), 
                   **opts)

def rewrite(input_file, output_file, rewrites, debug=None, **opts):
    "inter module rewriting"
    return previrt_progress(input_file, output_file,
                            ['-Prewrite'] + 
                            all_args('-Prewrite-input', rewrites), 
                            **opts)


def intern(input_file, output_file, interfaces, **opts):
    "strips unused symbols"
    return previrt_progress(input_file, output_file,
                            ['-Poccam'] + 
                            all_args('-Poccam-input', interfaces), 
                            **opts)

def strip(input_file, output_file, **opts):
    args=[input_file, '-o', output_file,
          '-strip',
          '-globaldce',
          '-globalopt',
          '-strip-dead-prototypes',
          ]
    return run(config.getLLVMTool('opt'), args, **opts)

def enforce(input_file, output_file, interfaces, inside, **opts):
    if inside:
        tkn = 'inside'
    else:
        tkn = 'outside'
    return previrt(input_file, output_file,
                   ['-Penforce-%s' % tkn] +
                   all_args('-Penforce-%s-input' % tkn, interfaces), 
                   **opts)

def peval(input_file, output_file, log=None, trail=None, **opts):
    "intra module previrtualization"
    if not trail:
        opt  = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
        pre  = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
        done = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
        opt.close()
        pre.close()
        done.close()
        
#        pre_args=[config.getLLVMTool('opt'), '-load=%s' % config.getOccamLib(),
#                  opt.name, '-o=%s' % done.name,
#                  '-Ppeval']
        
        out = ['']
        
        shutil.copy(input_file, done.name)
        while True:
            retcode = optimize(done.name, opt.name, **opts)
            if retcode != 0:
                # TODO: an error occurred
                shutil.copy(done.name, output_file)
                return retcode

            if previrt_progress(opt.name, done.name, ['-Ppeval'], output=out):
                print "previrt successful"
                if log is not None:
                    log.write(out[0])
            else:
                break

        print "Moving %s to %s" % (opt.name, output_file)
        shutil.move(opt.name, output_file)
        try:
            os.unlink(done.name)
            os.unlink(pre.name)
        except:
            pass
        return retcode
    else:
        assert False

def callgraph(input_file, output_file, **opts):
    args=[input_file, '-o', '/dev/null', '-dot-callgraph']
    x = run(config.getLLVMTool('opt'), args, **opts)
    if x == 0:
        shutil.move('callgraph.dot', output_file)
    return x

def optimize(input_file, output_file, **opts):
    return run(config.getLLVMTool('opt'),
               ['-disable-simplify-libcalls', input_file, '-o', output_file, '-O3'], **opts)

def specialize_program_args(input_file, output_file, args, fn=None, name=None):
    "fix the program arguments"
    if fn is None:
        arg_file = tempfile.NamedTemporaryFile(delete=False)
        arg_file.close()
        arg_file = arg_file.name
    else:
        arg_file = fn
    f = open(arg_file, 'w')
    for x in args:
        f.write(x + '\n')
    f.close()
    
    extra_args = []
    if not (name is None):
        extra_args = ['-Parguments-name', name]
    previrt(input_file, output_file, 
            ['-Parguments', '-Parguments-input', arg_file] + extra_args)

    if fn is None:
        os.unlink(arg_file)

def deep(libs, ifaces):
    "compute interfaces across modules"
    tf = tempfile.NamedTemporaryFile(suffix='.iface', delete=False)
    tf.close()
    iface = inter.parseInterface(ifaces[0])
    for i in ifaces[1:]:
        inter.joinInterfaces(iface, inter.parseInterface(i))

    inter.writeInterface(iface, tf.name)

    progress = True
    while progress:
        progress = False
        for l in libs:
            interface(l, tf.name, [tf.name], quiet=True)
            x = inter.parseInterface(tf.name)
            progress = inter.joinInterfaces(iface, x) or progress
            inter.writeInterface(iface, tf.name)
            # print '-' * 30
            # print "after reading %s" % l
            # formats.InterfaceFormat().show(iface)


    os.unlink(tf.name)
    return iface
