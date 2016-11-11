import subprocess
import sys
import os
import logging

from . import config


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
    args = ['-load={0}'.format(config.get_occamlib()),
            fin, '-o={0}'.format(fout)] + args
    return run(config.get_llvm_tool('opt'), args, **opts)

def previrt_progress(fin, fout, args, output=None):
    args = [config.get_llvm_tool('opt'),
            '-load={0}'.format(config.get_occamlib()),
            fin, '-o={0}'.format(fout)] + args
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


def linker(fin, fout, args, **opts):
    args = [fin, '-o', fout] + args
    return run(config.get_llvm_tool('clang++'), args, **opts)


# quiet being True here means(?) that in the C++ errs() goes to the logfile.
# quiet being False here means(?) that in the C++ errs() goes to stderr.
# we (iam & ashish)  like the logfile solution to be the default.
# this may not be the best place to set this flag; we are open to suggestions...
def run(prog, args, quiet=True, inp=None, pipe=True, wd=None):
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

    if pipe:
        proc = subprocess.Popen([prog] + args,
                                stderr=err,
                                stdout=subprocess.PIPE,
                                stdin=fd,
                                cwd=wd)
    else:
        proc = subprocess.Popen([prog] + args,
                                stderr=sys.stderr,
                                stdout=sys.stdout,
                                stdin=fd,
                                cwd=wd)
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
