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
import subprocess
import logging

from . import config
from . import echo
from . import stringbuffer


verbose = False

opt_debug_cmds = []

class ReturnCode(Exception):
    def __init__(self, value, cmd, proc):
        Exception.__init__(self)
        self._value = value
        self._proc = proc
        self._cmd = cmd

    def __str__(self):
        return "{0}\nreturned {1}".format(' '.join(self._cmd), self._value)

def all_args(opt, args):
    result = []
    for x in args:
        result += [opt, x]
    return result


def previrt(fin, fout, args, **opts):
    libs = ['-load={0}'.format(config.get_sea_dsalib()),
            '-load={0}'.format(config.get_llvm_dsalib()),
            '-load={0}'.format(config.get_occamlib())]

    args = opt_debug_cmds + libs + [fin, '-o={0}'.format(fout)] + args

    return run('opt', args, **opts)

def previrt_progress(fin, fout, args, output=None):
    libs = ['-load={0}'.format(config.get_sea_dsalib()),
            '-load={0}'.format(config.get_llvm_dsalib()),
            '-load={0}'.format(config.get_occamlib())]

    prog = config.get_llvm_tool('opt')

    args = opt_debug_cmds + libs + [fin, '-o={0}'.format(fout)] + args

    report(prog, args)

    log = logging.getLogger()

    sb = stringbuffer.StringBuffer()

    log.log(logging.INFO, 'EXECUTING: %s\n', ' '.join([prog] + args))

    args = [prog] + args

    proc = subprocess.Popen(args,
                            stderr=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stdin=subprocess.PIPE)

    eobj = echo.Echo(proc.stderr, log, sb)

    # wait for the echo thread to finish.
    eobj.wait()

    # this should be already finished.
    retcode = proc.wait()

    progress = str(sb)

    logging.getLogger().info('%(cmd)s => %(code)d\n%(progress)s',
                             {'cmd'  : ' '.join(args),
                              'code' : retcode,
                              'progress' : progress})
    if output != None:
        output[0] = progress
    return '...progress...' in progress


def linker(fin, fout, args):
    args = [fin, '-o', fout] + args
    return run('clang++', args)


def run(prog, args, sb=None, fail_on_error=True):

    log = logging.getLogger()

    prog = config.get_llvm_tool(prog)

    report(prog, args)


    proc = subprocess.Popen([prog] + args,
                            stderr=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stdin=subprocess.PIPE)

    log.log(logging.INFO, 'EXECUTING: %s\n', ' '.join([prog] + args))
    echo.Echo(proc.stderr, log, sb)
    if sb is not None:
        echo.Echo(proc.stdout, None, sb)


    retcode = proc.wait()

    log.log(logging.INFO, 'EXECUTED: %(cmd)s WHICH RETURNED %(code)d\n',
            {'cmd'  : ' '.join([prog] + args), 'code' : retcode })

    if fail_on_error and retcode != 0:
        ex = ReturnCode(retcode, [prog] + args, proc)
        logging.getLogger().error('ERROR: %s', ex)
        raise ex
    return retcode


def report(prog, args):
    if verbose: print 'Calling:\n\t{0}\n'.format(prog + ' ' + ' '.join(args))
