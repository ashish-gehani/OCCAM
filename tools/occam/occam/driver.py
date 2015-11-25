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
import subprocess, sys, os
import logging, tempfile
import shutil

def open_input(fn):
    if fn == '-':
        return os.fdopen(os.dup(0))
    else:
        return open(fn, 'r')

class ReturnCode (Exception):
    def __init__(self, value, cmd, proc):
        self._value = value
        self._proc = proc
        self._cmd = cmd

    def __str__(self):
        return "%s\nreturned %d" % (' '.join(self._cmd), self._value)

def runUnknown(tool,args):
    lenv = os.environ.copy()
    if lenv['OCCAM_PROTECT_PATH'] is not None:
        def which(name):
            for path in os.environ['OCCAM_PROTECTED_PATH'].split(os.pathsep):
                exe = os.path.join(path,name)
                if os.path.isfile(exe):
                    return exe
            return None
        tool = which(tool)
    cmdline = [tool] + args
    logging.getLogger().info('Calling unknown target: %s', ' '.join(cmdline))
    proc = subprocess.Popen(cmdline, env=lenv)
    retcode = proc.wait()
    logging.getLogger().info(' => %d', retcode)
    return retcode

def run(prog, args, quiet=False, inp=None,pipe=True, wd=None, resetPath=True):
    log = logging.getLogger()

    # 0 = stdin
    if inp is None:
        fd = os.fdopen(os.dup(0))
    else:
        fd = inp

    if quiet:
        err = subprocess.PIPE
    else:
        err = sys.stderr

    lenv = None
    if 'OCCAM_PROTECT_PATH' in os.environ:
        lenv = os.environ.copy()
        lenv['PATH'] = lenv['OCCAM_PROTECTED_PATH']
    elif resetPath:
        lenv = os.environ.copy()
        occam_home =  lenv["OCCAM_HOME"]
        if occam_home:
            occam_bin = os.path.join(occam_home, 'bin')
            pathelems = [e for e in lenv["PATH"].split(':') if os.path.abspath(occam_bin) != os.path.abspath(e)]
        else:
            raise Exception("OCCAM_HOME not set properly in the environment")
        #pathelems = [e for e in lenv["PATH"].split(':') if e.find("occam") == -1]
        lenv["PATH"] = ':'.join(pathelems)
        
    info = ("\nPROG ", prog, "\nPATH ", lenv["PATH"], "\nresetPath ", str(resetPath), "\n")
    log.warn("run %s", ' '.join(info))
 
    sys.stderr.write("prog %s\n" %prog)
    sys.stderr.write("args %s\n" %args)	   

    if pipe:
        proc = subprocess.Popen([prog] + args, 
                                stderr=err,
                                stdout=subprocess.PIPE,
                                stdin=fd,
                                cwd=wd,
                                env=lenv)
    else:
        proc = subprocess.Popen([prog] + args, 
                                stderr=sys.stderr,
                                stdout=sys.stdout,
                                stdin=fd,
                                cwd=wd,
                                env=lenv)
    retcode = proc.wait()
    if inp is None:
        fd.close()
    if quiet:
        log.log(logging.INFO, 'EXECUTING: %(cmd)s => %(code)d\n%(err)s', 
                {'cmd'  : ' '.join([prog] + args),
                 'code' : retcode,
                 'err'  : proc.stderr.read()})
    else:
        log.log(logging.INFO, 'EXECUTING: %(cmd)s => %(code)d', 
                {'cmd'  : ' '.join([prog] + args),
                 'code' : retcode})

    if retcode != 0:
        ex = ReturnCode(retcode, [prog] + args, proc)
        logging.getLogger().error('ERROR: %s', ex)
        raise ex
    return retcode

def all_args(opt, args):
    result = []
    for x in args:
        result += [opt, x]
    return result

def previrt(fin, fout, args, **opts):
    args = ['-load=%s' % config.getOccamLib(), 
            fin, '-o=%s' % fout] + args
    return run(config.getLLVMTool('opt'), args, **opts)

def previrt_progress(fin, fout, args, output=None, **opts):
    args = [config.getLLVMTool('opt'), '-load=%s' % config.getOccamLib(), 
            fin, '-o=%s' % fout] + args
    proc = subprocess.Popen(args, 
                            stderr=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stdin=subprocess.PIPE)
    progress = proc.stderr.read()
    retcode = proc.wait()
    logging.getLogger().info('%(cmd)s => %(code)d\n%(progress)s', 
                             {'cmd'  : ' '.join(args),
                              'code' : retcode,
                              'progress' : progress})
    if output != None:
        output[0] = progress
    return '...progress...' in progress

def isLLVM(f):
    proc = subprocess.Popen([config.getStdTool('file'), f],
                            stdout=subprocess.PIPE,
                            stdin=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    out = proc.stdout.read()
    proc.wait()
    return 'LLVM' in out
    
