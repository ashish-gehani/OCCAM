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
"""

import sys
import os
import tempfile
import shutil

from . import config

from . import driver

from . import interface as inter

def interface(input_file, output_file, wrt):
    """ computing the interfaces.
    """
    args = ['-Pinterface2', '-Pinterface2-output', output_file]
    args += driver.all_args('-Pinterface2-entry', wrt)
    return driver.previrt(input_file, '/dev/null', args)

def specialize(input_file, output_file, rewrite_file, interfaces):
    """ inter module specialization.
    """
    args = ['-Pspecialize']
    if not rewrite_file is None:
        args += ['-Pspecialize-output', rewrite_file]
    args += driver.all_args('-Pspecialize-input', interfaces)
    if output_file is None:
        output_file = '/dev/null'
    return driver.previrt(input_file, output_file, args)

def rewrite(input_file, output_file, rewrites, output=None):
    """ inter module rewriting
    """
    args = ['-Prewrite'] + driver.all_args('-Prewrite-input', rewrites)
    return driver.previrt_progress(input_file, output_file, args, output)


def internalize(input_file, output_file, interfaces, whitelist):
    """ marks unused symbols as internal/hidden
    """
    args = ['-Poccam'] + driver.all_args('-Poccam-input', interfaces)
    if whitelist is not None:
        args = args + ['-Pkeep-external', whitelist]
    return driver.previrt_progress(input_file, output_file, args)

def strip(input_file, output_file):
    """ strips unused symbols
    """
    args = [input_file, '-o', output_file]
    args += ['-strip', '-globaldce', '-globalopt', '-strip-dead-prototypes']
    return driver.run('opt', args)

def devirt(input_file, output_file):
    """ resolve indirect function calls
    """
    args = ['-devirt-ta',
            # XXX: this one is not, in general, sound
            #'-calltarget-ignore-external',
            '-inline']
    retcode = driver.previrt_progress(input_file, output_file, args)
    if retcode != 0:
        return retcode

    #FIXME: previrt_progress returns 0 in cases where --devirt-ta crashes.
    #Here we check that the output_file exists
    if not os.path.isfile(output_file):
        #Some return code different from zero
        return 3
    else:
        return retcode


def profile(input_file, output_file):
    """ count number of instructions, functions, memory accesses, etc.
    """
    args = ['-Pprofiler']
    args += ['-profile-outfile={0}'.format(output_file)]
    return driver.previrt(input_file, '/dev/null', args)

def peval(input_file, output_file, use_devirt, use_llpe, use_ipdse, log=None):
    """ intra module previrtualization
    """
    opt = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
    done = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
    tmp = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
    opt.close()
    done.close()
    tmp.close()

    #XXX: Optimize using standard llvm transformations before any other pass.
    #Otherwise, these passes will not be very effective.
    retcode = optimize(input_file, done.name)
    if retcode != 0:
        sys.stderr.write("ERROR: intra module optimization failed!\n")
        shutil.copy(input_file, output_file)
        return retcode
    else:
        sys.stderr.write("\tintra module optimization finished succesfully\n")

    if use_devirt is not None:
        retcode = devirt(done.name, tmp.name)
        if retcode != 0:
            sys.stderr.write("ERROR: resolution of indirect calls failed!\n")
            shutil.copy(done.name, output_file)
            return retcode

        sys.stderr.write("\tresolved indirect calls finished succesfully\n")
        shutil.copy(tmp.name, done.name)

    if use_llpe is not None:
        llpe_libs = []
        for lib in config.get_llpelibs():
            llpe_libs.append('-load={0}'.format(lib))
            args = llpe_libs + ['-loop-simplify', '-lcssa', \
                                '-llpe', '-llpe-omit-checks', '-llpe-single-threaded', \
                                done.name, '-o=%s' % tmp.name]
        retcode = driver.run('opt', args)
        if retcode != 0:
            sys.stderr.write("ERROR: llpe failed!\n")
            shutil.copy(done.name, output_file)
            #FIXME: unlink files
            return retcode
        else:
            sys.stderr.write("\tllpe finished succesfully\n")
        shutil.copy(tmp.name, done.name)

    if use_ipdse is not None:
        ##lower global initializers to store's in main (improve precision of sccp)
        passes = ['-lower-gv-init']
        ##dead store elimination (improve precision of sccp)
        passes += ['-memory-ssa', '-Pmem-ssa-local-mod','-Pmem-ssa-split-fields',
                   '-mem2reg', '-ip-dse', '-strip-memory-ssa-inst']
        ##perform sccp
        passes += ['-Psccp']
        ##cleanup after sccp
        passes += ['-dce', '-globaldce']
        retcode = driver.previrt(done.name, tmp.name, passes)
        if retcode != 0:
            sys.stderr.write("ERROR: ipdse failed!\n")
            shutil.copy(done.name, output_file)
            #FIXME: unlink files
            return retcode
        else:
            sys.stderr.write("\tipdse finished succesfully\n")
        shutil.copy(tmp.name, done.name)

    out = ['']
    iteration = 0
    while True:
        iteration += 1
        if iteration > 1 or \
           (use_llpe is not None or use_ipdse is not None):
            # optimize using standard llvm transformations
            retcode = optimize(done.name, opt.name)
            if retcode != 0:
                sys.stderr.write("ERROR: intra-module optimization failed!\n")
                break;
            else:
                sys.stderr.write("\tintra module optimization finished succesfully\n")
        else:
            shutil.copy(done.name, opt.name)

        # inlining using policies
        passes = ['-Ppeval']
        progress = driver.previrt_progress(opt.name, done.name, passes, output=out)
        sys.stderr.write("\tintra-module specialization finished\n")
        if progress:
            if log is not None:
                log.write(out[0])
        else:
            shutil.copy(opt.name, done.name)
            break

    shutil.copy(done.name, output_file)
    try:
        os.unlink(done.name)
        os.unlink(opt.name)
        os.unlink(tmp.name)
    except OSError:
        pass
    return retcode

def optimize(input_file, output_file):
    args = ['-disable-simplify-libcalls', input_file, '-o', output_file, '-O3']
    return driver.run('opt', args)

def constrain_program_args(input_file, output_file, cnstrs, filename=None):
    """ constrain the program arguments.
    """
    if filename is None:
        cnstr_file = tempfile.NamedTemporaryFile(delete=False)
        cnstr_file.close()
        cnstr_file = cnstr_file.name
    else:
        cnstr_file = filename
    f = open(cnstr_file, 'w')
    (argc, argv) = cnstrs
    f.write('{0}\n'.format(argc))
    index = 0
    for x in argv:
        f.write('{0} {1}\n'.format(index, x))
        index += 1
    f.close()

    args = ['-Pconstraints', '-Pconstraints-input', cnstr_file]
    driver.previrt(input_file, output_file, args)

    if filename is None:
        os.unlink(cnstr_file)

def specialize_program_args(input_file, output_file, args, filename=None, name=None):
    """ fix the program arguments.
    """
    if filename is None:
        arg_file = tempfile.NamedTemporaryFile(delete=False)
        arg_file.close()
        arg_file = arg_file.name
    else:
        arg_file = filename
    f = open(arg_file, 'w')
    for x in args:
        f.write(x + '\n')
    f.close()

    extra_args = []
    if not name is None:
        extra_args = ['-Parguments-name', name]
    args = ['-Parguments', '-Parguments-input', arg_file] + extra_args
    driver.previrt(input_file, output_file, args)

    if filename is None:
        os.unlink(arg_file)

def deep(libs, ifaces):
    """ compute interfaces across modules.
    """
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
            interface(l, tf.name, [tf.name])
            x = inter.parseInterface(tf.name)
            progress = inter.joinInterfaces(iface, x) or progress
            inter.writeInterface(iface, tf.name)

    os.unlink(tf.name)
    return iface
