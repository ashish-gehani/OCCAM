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
import json
import os
import re
import sys
import shutil
import logging

from . import provenance
from . import config

def checkOccamLib():
    occamlib = config.get_occamlib_path()
    if occamlib is None  or not os.path.exists(occamlib):
        sys.stderr.write('The occam library was not found. RTFM.\n')
        return False
    return True


def get_flag(flags, flag, default=None):
    for (x, y) in flags:
        if x == '--{0}'.format(flag):
            return y
    return default

def get_work_dir(flags):
    d = get_flag(flags, 'work-dir')
    if d is None:
        return os.getcwd()
    return os.path.abspath(d)


def get_whitelist(flags):
    wl = get_flag(flags, 'keep-external')
    if wl is not None:
        return os.path.abspath(wl)
    return None

def get_amalgamation(flags):
    amalg = get_flag(flags, 'amalgamate')
    if amalg is not None:
        return os.path.abspath(amalg)
    return None


def get_manifest(args):
    manifest = None
    if not args:
        sys.stderr.write('\nNo manifest file specified\n\n')
        return manifest
    try:
        manifest_file = args[0]
        if not os.path.exists(manifest_file):
            sys.stderr.write('\nManifest file {0} not found\n\n'.format(manifest_file))
        elif  not os.path.isfile(manifest_file):
            sys.stderr.write('\nManifest file {0} not a file\n\n'.format(manifest_file))
        else:
            manifest = json.load(open(manifest_file, 'r'))
    except Exception:
        sys.stderr.write('\nReading and parsing the manifest file {0} failed\n\n'.format(args[0]))
    return manifest


def make_work_dir(d):
    if not os.path.exists(d):
        sys.stderr.write('making working directory... "{0}"\n'.format(d))
        os.mkdir(d)
    if not os.path.isdir(d):
        sys.stderr.write('working directory  "{0}" is not a directory\n'.format(d))
        return False
    return True


def sanity_check_manifest(manifest):
    """ Nurse maid the users.
    """
    manifest_keys = ['ldflags', 'args', 'name', 'native_libs', 'binary', 'modules']

    old_manifest_keys = ['modules', 'libs', 'search', 'shared']

    new_manifest_keys = ['main', 'binary', 'constraints']

    dodo_manifest_keys = ['watch']

    replaces = {'modules': 'main', 'libs': 'modules', 'search': 'ldflags'}

    warnings = [False]

    def cr(warnings):
        """ I like my warnings to stand out.
        """
        if not warnings[0]:
            warnings[0] = True
            sys.stderr.write('\n')

    if manifest is None:
        sys.stderr.write('\nManifest is None.\n')
        return False

    if not isinstance(manifest, dict):
        sys.stderr.write('\nManifest is not a dictionary: {0}.\n'.format(type(manifest)))
        return False

    for key in manifest:
        if key in manifest_keys:
            continue

        if key in dodo_manifest_keys:
            cr(warnings)
            sys.stderr.write('Warning: "{0}" is no longer supported; ignoring.\n'.format(key))
            continue


        if key in old_manifest_keys:
            cr(warnings)
            sys.stderr.write('Warning: old style key "{0}" is DEPRECATED, use {1}.\n'.format(key, replaces[key]), )
            continue

        if not key in new_manifest_keys:
            cr(warnings)
            sys.stderr.write('Warning: "{0}" is not a recognized key; ignoring.\n'.format(key))
            continue

    return True

def check_manifest(manifest):

    ok = sanity_check_manifest(manifest)

    if not ok:
        return (False, )

    main = manifest.get('main')
    if main is None:
        sys.stderr.write('No modules in manifest\n')
        return (False, )

    binary = manifest.get('binary')
    if binary is None:
        sys.stderr.write('No binary in manifest\n')
        return (False, )

    modules = manifest.get('modules')
    if modules is None:
        sys.stderr.write('No libs in manifest\n')
        modules = []

    native_libs = manifest.get('native_libs')
    if native_libs is None:
        native_libs = []

    ldflags = manifest.get('ldflags')
    if ldflags is None:
        ldflags = []

    args = manifest.get('args')

    constraints = manifest.get('constraints')
    if constraints is None:
        constraints = ('-1', [])
    else:
        constraints = (constraints[0], constraints[1:])


    name = manifest.get('name')
    if name is None:
        sys.stderr.write('No name in manifest\n')
        return (False, )

    return (True, main, binary, modules, native_libs, ldflags, args, name, constraints)


#iam: used to be just os.path.basename; but now when we are processing trees
# the leaf names are not necessarily unique.
def prevent_collisions(x):
    folders = []
    path = x
    while 1:
        path, folder = os.path.split(path)

        if folder != "":
            folders.append(folder)

        if path == "" or path == os.sep:
            break

    folders.reverse()
    return "_".join(folders)

bit_code_pattern = re.compile(r'\.bc$', re.IGNORECASE)


def populate_work_dir(module, libs, work_dir):
    files = {}

    for x in [module] + libs:
        if bit_code_pattern.search(x):
            bn = prevent_collisions(x)
            target = os.path.join(work_dir, bn)
            if os.path.abspath(x) != target:
                shutil.copyfile(x, target)
            idx = target.rfind('.bc')
            files[x] = provenance.FileStream(target[:idx], 'bc')
        else:
            sys.stderr.write('Ignoring {0}\n'.format(x))


    return files


def makeLogfile(logfile):
    if not os.path.exists(logfile):
        _, path_filename = os.path.splitdrive(logfile)
        path, _ = os.path.split(path_filename)
        if not os.path.exists(path):
            os.mkdir(path)

def setLogger():
    logfile = config.get_logfile()
    logger = logging.getLogger()

    makeLogfile(os.path.realpath(logfile))

    hdlr = logging.FileHandler(logfile)
    hdlr.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(hdlr)

    levels = {'CRITICAL' : logging.CRITICAL,
              'ERROR'    : logging.ERROR,
              'WARNING'  : logging.WARNING,
              'INFO'     : logging.INFO,
              'DEBUG'    : logging.DEBUG}

    level = os.getenv('OCCAM_LOGLEVEL', None)
    if level is not None:
        level = levels[level]
    if level is None:
        level = logging.WARNING
    logger.setLevel(level)
    logger.info(">> %s\n", ' '.join(sys.argv))

def write_timestamp(msg):
    import datetime
    dt = datetime.datetime.now ().strftime ('%d/%m/%Y %H:%M:%S')
    sys.stderr.write("[%s] %s...\n" % (dt, msg))
    
def is_exec (fpath):
    if fpath == None: return False
    return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

def which(program):
    fpath, _ = os.path.split(program)
    if fpath:
        if is_exec (program): return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            exe_file = os.path.join(path, program)
            if is_exec (exe_file): return exe_file
    return None

# seaopt is a customized version of LLVM opt that is more 
# friendly to tools like crab and seahorn.
def found_seaopt():
    opt = which('seaopt')
    if opt is not None:
        return True
    else:
        return False
    
def get_opt(use_seaopt = False):
    opt = None
    if use_seaopt:
        opt = which('seaopt')
    if opt is None:
        opt = config.get_llvm_tool('opt')
    if opt is None:
        raise IOError('opt was not found')
    return opt
    
# Try to find ROPgadget binary
def get_ropgadget():
    ropgadget = None
    if 'ROPGADGET' in os.environ: ropgadget = os.environ ['ROPGADGET']
    if not is_exec(ropgadget): ropgadget = which('ropgadget')
    if not is_exec(ropgadget): ropgadget = which('ROPgadget.py')
    return ropgadget

# Try to find seahorn binary
def get_seahorn():
    seahorn = None
    if 'SEAHORN' in os.environ: seahorn = os.environ ['SEAHORN']
    if not is_exec(seahorn): seahorn = which('sea')
    return seahorn

# Try to find crabllvm binary
def get_crabllvm():
    crabllvm = None
    if 'CRABLLVM' in os.environ: crabllvm = os.environ ['CRABLLVM']
    if not is_exec(crabllvm): crabllvm = which('crabllvm')
    return crabllvm
