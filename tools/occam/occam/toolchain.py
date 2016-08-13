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

from . import driver
from . import target
from . import config
import shutil, os
import tempfile, logging
import json
import subprocess
import collections
import sys

def assemble(input_file, output_file, args):
    return driver.run(config.getLLVMTool('as'),
                      [input_file, '-o=%s' % output_file])


def compile(input_files, output_file, args, tool='clang'):
    ok = driver.run(config.getLLVMTool(tool),
                    ['-emit-llvm'] + args + ['-c'] + input_files +
                    ['-o', output_file])
    return ok

def archive(action, inputs, ar):
    while action.startswith('-'):
        action = action[1:]
    return driver.run(config.getStdTool('ar'),
                      [action, ar] + inputs)

def archive_contents(archive):
    p = subprocess.Popen([config.getStdTool('ar'), 't', archive],
                         stdout=subprocess.PIPE)
    # don't forget to remove the trailing \n
    return [x.strip('\n\r') for x in p.stdout.readlines()]

def symbols(obj):
    p = subprocess.Popen([config.getLLVMTool('nm'), '--format=posix', obj],
                         stdout=subprocess.PIPE)
    # don't forget to remove the trailing \n
    result = collections.defaultdict(set)
    for x in p.stdout.readlines():
        x = x.strip()
        entry = x.split(' ',2)
        [sym,ty] = entry[:2]
        result[ty].add(sym)
    p.wait()
    return result


def extract_archive(input_file, minimal=None):

    SCACHE = {}
    def syms(s):
        if not SCACHE.has_key(s):
            SCACHE[s] = symbols(s)
        return SCACHE[s]
    DCACHE = {}
    def defined(s):
        if not DCACHE.has_key(s):
            ss = syms(s)
            DCACHE[s] = ss['T'].union(ss['t']).union(ss['d']).union(ss['D']).union(ss['W']).union(ss['C'])
        return DCACHE[s]
    UCACHE = {}
    def undefined(s):
        if not UCACHE.has_key(s):
            ss = syms(s)
            UCACHE[s] = ss['U'].union(ss['u']).difference(defined(s))
        return UCACHE[s]

    d = tempfile.mkdtemp()
    contents = archive_contents(input_file)
 	
    for c in contents:
        try:
            os.makedirs(os.path.join(d, os.path.dirname(c)))
        except:
            pass

    #+ extracting bitcode files from the bitcode archive 			
    driver.run("ar", ['x', os.path.abspath(input_file)], wd=d)
    
    if not (minimal is None):
        all_contents = contents
        undef_symbols = set()
        for x in minimal:
            undef_symbols = undef_symbols.union(undefined(x)).difference(defined(x))
        contents = []
        progress = True
        while progress:
            progress = False
            for x in all_contents:
		s = os.path.join(d, x)
                if not (x in contents):
                    defed = defined(s)
		    if not undef_symbols.isdisjoint(defed):
                        contents = contents + [x]
                        undef_symbols = undef_symbols.union(undefined(s)).difference(defed)
                	progress = True
    
    return (d, contents)


def archive_to_module(input_file, output_file, minimal=None):
      
    #+ extract-bc extracts the bitcode archive (.bca file) from the native archive (.a file)     
    proc = subprocess.Popen(["extract-bc"] + [input_file], stderr=subprocess.PIPE, shell=False)
    retcode = proc.wait()  
    if retcode != 0:
        return False	  
   		
    #+ The extracted bitcode archive has a .bca extension
    input_file = input_file[:-2] + '.bca'    
    output_file = os.path.abspath(output_file)
    (d, contents) = extract_archive(input_file, minimal)
    if len(contents) > 0:
        driver.run(config.getLLVMTool('link'), ['-o=%s' % output_file] + \
               [os.path.join(d, x) for x in contents])
        shutil.rmtree(d)
        return True
    else:
        return False

def llvmLDWrapper(output, inputs, found_libs, searchflags, shared, xlinker_start, native_libs, xlinker_end, flags):
    new_inputs = []
    inputs_in_bc = [i for i in inputs if i.endswith('.bc') or i.endswith('.bc.o')]
    for input in inputs_in_bc:
        tout = tempfile.NamedTemporaryFile(suffix='.o', delete=False)
        tout.close()
        tout = tout.name
        driver.run(config.getLLVMTool('llc'), ['-filetype=obj', '-o=%s' % tout, input])
        new_inputs.append(tout)
    inputs_in_bc_a = [i for i in inputs if i.endswith('.bc.a')]
    for input in inputs_in_bc_a:
        (d, contents) = extract_archive(input, None)
        new_contents = []
        for c in contents:
            tout = tempfile.NamedTemporaryFile(suffix='.o', delete=False)
            tout.close()
            tout = tout.name
            driver.run(config.getLLVMTool('llc'), ['-filetype=obj', '-o=%s' % tout, os.path.join(d, c)])
            new_contents.append(tout)
        archive('rcs', new_contents, '%s_bc.a' % input[:-5])
        new_inputs.append('%s_bc.a' % input[:-5])
        shutil.rmtree(d)
    for input in inputs:
        if input not in inputs_in_bc and input not in inputs_in_bc_a:
            new_inputs.append(input)
    args = new_inputs + found_libs + searchflags + shared + xlinker_start + native_libs + xlinker_end
    for (a,b) in flags:
        if a == '-O':
            args += ['-O%s' % b]
    args += ['-o %s' % output]
    return driver.run(config.getLLVMTool('clang++'), args)

class LibNotFound (Exception):
    def __init__(self, lib, path):
        self._lib = lib
        self._path = path

    def __str__(self):
        return "Could not find library %s on path %s" % (self._lib, ':'.join(self._path))

def getSearchPath():
    args = [config.getLLVMTool('clang'), '-print-search-dirs']
    proc = subprocess.Popen(args, 
                            stderr=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stdin=subprocess.PIPE)
    (stdout,stderr) = proc.communicate()
    for line in stdout.splitlines():
        if line.startswith('libraries: ='):
            return line[12:]
    return None

def findlib(l, paths):
    if l.startswith('-l'):
        return l
    #HOME = os.getenv('OCCAM_HOME')
    #paths += ['',
    #          '%s/root/lib' % HOME,
    #          '%s/root/usr/lib' % HOME]
    #if 'OCCAM_LIB_PATH' in os.environ:
    #    for libpath in os.environ['OCCAM_LIB_PATH'].split(os.pathsep):
    #        paths.append(libpath)
    if 'OCCAM_LIB_PATH' in os.environ:
        paths.extend(os.environ['OCCAM_LIB_PATH'].split(os.pathsep))
    for p in paths:
        if p == '':
            path = l
        else:
            path = os.path.join(p, 'lib%s.a' % l)
        if os.path.exists(path):
            return path
    search = getSearchPath()
    if search is not None:
        paths = search.split(os.pathsep)
        for p in paths:
            if p == '':
                path = l
            else:
                path = os.path.join(p, 'lib%s.a' % l)
            if os.path.exists(path):
                return path
    logging.getLogger().warning("Couldn't find bitcode library %s", l)
    return None
#    raise LibNotFound(l,paths)

def bundle(output, inputs, libs, paths):
    args = ['-o', output]
    inputs_in_bc = [i for i in inputs if i.endswith('.bc') or i.endswith('.bc.o')]
    for input in inputs_in_bc:
        tout = tempfile.NamedTemporaryFile(suffix='.o', delete=False)
        tout.close()
        tout = tout.name
        driver.run(config.getLLVMTool('llc'), ['-filetype=obj', '-o=%s' % tout, input])
        args.append(tout)
    libinputs = [x for x in [findlib(x, paths) for x in libs] if not (x is None)]
    inputs_in_bc_a = [i for i in (inputs + libinputs) if i.endswith('.bc.a')]
    for input in inputs_in_bc_a:
        (d, contents) = extract_archive(input, None)
        new_contents = []
        for c in contents:
            tout = tempfile.NamedTemporaryFile(suffix='.o', delete=False)
            tout.close()
            tout = tout.name
            driver.run(config.getLLVMTool('llc'), ['-filetype=obj', '-o=%s' % tout, os.path.join(d, c)])
            new_contents.append(tout)
        archive('rcs', new_contents, '%s_bc.a' % input[:-5])
        args.append('%s_bc.a' % input[:-5])
        shutil.rmtree(d)
    for input in inputs:
        if input not in inputs_in_bc and input not in inputs_in_bc_a:
            args.append(input)
    for lib in libinputs:
        if lib not in args:
            args.append(lib)
    args += ['-L%s' % path for path in paths]
    return driver.run(config.getLLVMTool('clang++'), args)

def bundle_bc(output, inputs):
    inputs_in_bc = [i for i in inputs if i.endswith('.bc') or i.endswith('.bc.o')]
    inputs_in_bc_a = [i for i in inputs if i.endswith('.bc.a')]
    for input in inputs_in_bc_a:
        tout = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
        tout.close()
        tout = tout.name
        archive_to_module(input, tout, None)
        inputs_in_bc.append(tout)
    if len(inputs_in_bc) > 0:
        return driver.run(config.getLLVMTool('link'), ['-o=%s' % output] + inputs_in_bc)

def clean(input_file, output_file):
    # TODO: I shouldn't need to do this, but I'm getting \01 characters
    #       on some of my symbol names...
    return driver.previrt(input_file, output_file, ['-Pfix-1function'])
    # shutil.copyfile(input_file, output_file)
    # return 0

NATIVE_LIBS=['pthread'] #'c','m','resolv','nsl','crypt','pthread','dl', 'rt']

def libarg(l, paths):
    lib = findlib('%s.bc' % l, paths)
    if lib is not None:
        return lib
    else:
        return '-l%s' % l

def haveBitcode(l, paths):
    return findlib('%s.bc' % l, paths) is not None

def manifest(filename, exe, lib, libs=[], nativelibs=[], search=[], shared=[]):
    data = { 'binary' : exe
           , 'modules' : lib
           , 'libs'   : libs
           , 'native-libs' : nativelibs
           , 'search' : search
           , 'shared' : shared
           }
    mani = open(filename, 'w')
    mani.write(json.dumps(data,indent=0))
    mani.close()

def link(inputs, output_file, args, save=None, link=True):
    #assert not link
    paths = [x[2:] for x in args if x.startswith('-L')]
    if save is None:
        save = output_file + '.manifest'
    #libraries = [libarg(x[2:], paths) for x in args if x.startswith('-l')]
    #nativelibs = [x for x in libraries if x.startswith('-l')]
    #libraries = [x for x in libraries if x not in set(nativelibs)]

    libraries = [x for x in args if x.startswith('-l')]
    nativelibs = [x for x in libraries if not x]
    if '-lc' in args:
        nativelibs.append('-lc')
    if '-lstdc++' in args:
        nativelibs.append('-lstdc++')
    if '-lpthread' in args or '-pthread' in args:
        nativelibs.extend(['-lpthread'])
    libraries = [x for x in libraries if x not in set(nativelibs)]

    #temporary = False
    retcode = 0
    if len(libraries) > 0 or len(inputs) > 1:
        #tout = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
        #tout.close()
        #tout = tout.name
        #temporary = True
        
        #inputs = inputs
        if not (save is None):
            main_name = save
            # Bundle the non-library inputs into a single module
            # Not doing this anymore because we get multiply defined symbol errors
            # retcode = bundle_bc(main_name, inputs)
            # if retcode != 0:
            #     return retcode
            if 'OCCAM_LIB_PATH' in os.environ:
                paths.extend(os.environ['OCCAM_LIB_PATH'].split(os.pathsep))
            search = getSearchPath()
            if search is not None:
                paths.extend(search.split(os.pathsep))
            def soTolFlag(so):
                libname = os.path.basename(x)[:-3]
                if libname.startswith('lib'):
                    libname = "-l%s" % libname[3:]
                return libname
            shared = [soTolFlag(x) for x in inputs if x.endswith('.so')]
            # logging.getLogger().info("Bundled executable '%(exe)s' into '%(mod)s' from %(libs)s",
            #                          {'exe' : output_file,
            #                           'mod' : main_name,
            #                           'libs' : inputs.__str__() })
            manifest('%s.manifest' % main_name,
                     output_file,
                     [i for i in inputs if not i.endswith('.so')],
                     libs = libraries,
                     nativelibs = nativelibs,
                     search = paths,
                     shared = shared)
#                     shared=['%s.bc.a' % x[:-3] for x in args if x.endswith('.so')])
        #retcode = bundle(tout, inputs, libraries, paths)
        #if retcode != 0:
        #    return retcode
    #else:
        #temporary = False
        #tout = inputs[0]

            if link and '.o' not in output_file:
                args = ["%s.manifest" % main_name, "%s" % output_file]
                logging.getLogger().info("Calling build with %s" % ' '.join(args))
                retcode = target.run(args, tool='build')
#        def linker_option(x):
#            if x.startswith('-O') or x.startswith('-D') or x.startswith('-I'):
#                return None
#            if x.startswith('-Wl'):
#                return x[4:]
#            if x.startswith('-l') and x[2:] in NATIVE_LIBS:
#                return x
#            if x.startswith('-l'):
#                # This was included with a direct path
#                return None
#            if x in ['-pthread','-pthreads']:
#                return '-lpthread'
#            if x in ['--export-dynamic', '-export-dynamic']:
#                return x
#            return None
#        cmd = ['-native', '-o=%s.llvm' % output_file, tout] + \
#              [linker_option(x) for x in args
#               if not (linker_option(x) is None)]
#    
#        retcode = driver.run(config.getLLVMTool('ld'), cmd)
    #if temporary:
    #    os.unlink(tout)
    return retcode
    
def watch(input_file, output_file, watches, 
          local=False, fancy=False, failName='exit'):
    def to_bool(x, s):
        if x:
            return [s]
        else:
            return []
    extra_args  = to_bool(local, '-Pwatch2-local') + \
                  to_bool(fancy, '-Pwatch2-fancy') + \
                  ['-Pwatch2-fail', failName]

    return driver.previrt(input_file, output_file, 
                          ['-Pwatch2'] + 
                          driver.all_args('-Pwatch2-input', watches) +
                          extra_args)

def callgraph(input_file, output_file):
    return driver.previrt(input_file, '/dev/null',
                          ['-dot-callgraph-output', output_file])
