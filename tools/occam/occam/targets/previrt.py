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

from occam import pool
from occam.provenance import VersionedFile, FileStream
from occam import toolchain, interface, passes, target
from occam import driver, config
from occam.target import ArgError
import getopt
import json
import os, shutil, tempfile, sys

def get_flag(flags, flag, default=None):
    for (x,y) in flags:
        if x == '--%s' % flag:
            return y
    return default

def get_work_dir(flags):
    d = get_flag(flags, 'work-dir')
    if d is None:
        return None
    return os.path.abspath(d)

def collect_files(mani):
    return []

class NotFound (Exception):
    def __init__(self, name):
        self._name = name
    def __str__(self):
        return self._name

def get_library(lib, paths):
    if lib.startswith('-l'):
        lib = lib[2:]
        for p in paths:
            full_path = os.path.join(p, 'lib%s.bc.a' % lib)
            if os.path.exists(full_path):
                return (full_path, True)
            full_path = os.path.join(p, 'lib%s.a' % lib)
            if os.path.exists(full_path):
                return (full_path, False)
        raise NotFound(lib)
    else:
        full_path = os.path.abspath(lib)
        if os.path.exists(full_path):
            return (full_path, '.bc' in full_path) #driver.isLLVM(full_path))
        raise NotFound(full_path)

def get_default(obj, key, default):
    if obj.has_key(key):
        return obj[key]
    else:
        return default

POOL = None

def defaultPool():
    global POOL
    if POOL is None:
        POOL = pool.ThreadPool(3)
    return POOL

def InParallel(f, args, pool=None):
    sys.stderr.write("Starting %s..." % f.func_doc)
    pool = defaultPool()
    result = pool.map(f, args)
    sys.stderr.write("done\n")
    return result

def occamRoot():
    occam_home = os.getenv('OCCAM_HOME')
    if occam_home is not None:
        return os.path.join(occam_home, 'root')
    else:
        sys.stderr.write("ERROR: 'OCCAM_HOME' must be set before calling 'occam2 previrt'\n")
        sys.exit(1)

class PrevirtTool (target.Target):
    def opts(self, args):
        return getopt.getopt(args, ':o', ['work-dir=','force','no-strip'])

    def usage(self):
        return "%s [--work-dir=<dir>] [--force] [--no-strip] <manifest>" % self.name
    def desc(self):
        return """  Previrtualize a compilation unit based on its manifest."""
    def args(self):
        return [('--work-dir', "Output intermediate files to the given location"),
                ('--no-strip', "Leave symbol information in the binary"),
                ('--force', "Proceed after dependency warnings")]

    def run(self, cfg, flags, args):
        if len(args) != 1:
            raise ArgError()
        
        manifest_file = args[0]
        
        manifest = json.load(open(manifest_file, 'r'))

        work_dir = get_work_dir(flags)
        if work_dir is None:
            work_dir = os.getcwd()
        force = get_flag(flags, 'force', False)

        if not os.path.exists(work_dir):
            sys.stderr.write("making working directory... '%s'\n" % work_dir)
            os.mkdir(work_dir)
        if not os.path.isdir(work_dir):
            sys.stderr.write("working directory '%s' is not a directory\n" % work_dir)
            return 1
        
        modules = get_default(manifest, 'modules', [])
        if not (get_default(manifest, 'module', None) is None):
            modules += [get_default(manifest, 'module', None)]
        if len(modules) == 0:
            sys.stderr.write("The manifest file '%s' does not have a main module!\n" % manifest_file)
            return 1
        libs = get_default(manifest, 'libs', [])
        native_libs = get_default(manifest, 'native-libs', [])
        shared = get_default(manifest, 'shared', [])
        search = get_default(manifest, 'search', [])
        arguments = get_default(manifest, 'args', None)
        name = get_default(manifest, 'name', None)
        watches = [os.path.abspath(x) 
                   for x in get_default(manifest, 'watch', [])]
        binary = get_default(manifest, 'binary', modules[0] + '.exe')

        try:
            found_libs = [get_library(x, search) for x in libs]
        except NotFound,e:
            sys.stderr.write("The library '%s' could not be found. Search path:" % e.__str__())
            sys.stderr.write('\n'.join(search))
            return 1

        if not all(map(lambda x:x[1], found_libs)):
            sys.stderr.write("LLVM versions could not be found for all libraries\n")
            ok = True
            native = False
            for (x,tf) in found_libs:
                if tf and native:
                    ok = False
                if not tf:
                    native = True
                
                if tf:
                    sys.stderr.write("%s -- llvm\n" % x)
                else:
                    sys.stderr.write("%s -- native\n" % x)

            if not ok:
                sys.stderr.write("If native libraries refer to llvm libraries, this is NOT safe!\n")
                if not force:
                    return 1
        llvm_libs = [x for (x,y) in found_libs if y]
        #found_libs = llvm_libs + [x for (x,y) in found_libs if not y]

        files = {}
        all_my_modules = []
        for x in modules + llvm_libs:
            bn = os.path.basename(x)
            target = os.path.join(work_dir, os.path.basename(x))
            if os.path.abspath(x) != target:
                shutil.copyfile(x, target)
            if target.endswith('.bc.a'):
                if files.has_key(x):
                    # We've already seen this file, but we may need to pull in more symbols
                    print "don't handle linking the same file multiple times!"
                    # TODO
                    return 1
                else:
                    sys.stderr.write("got archive %s, need to convert to .bc\n" % x)
                    # Stripping the '.bc.a'
                    if target.endswith('libcrt.bc.a'):
                        toolchain.archive_to_module(target, target[:-5] + '.bc',
                                                    minimal=None)
                    else:
                        toolchain.archive_to_module(target, target[:-5] + '.bc',
                                                    minimal=all_my_modules)
                    files[x] = FileStream(target[:-5], 'bc')
            else:
                idx = target.rfind('.bc')
                if target[idx:] != '.bc':
                    shutil.copyfile(target, target[:idx] + '.bc')
                files[x] = FileStream(target[:idx], 'bc')
            all_my_modules += [files[x].get()]

        # Change directory
        os.chdir(work_dir)
        
        if not (arguments is None):
            # We need to specialize main for program arguments
            main = files[modules[0]]
            pre = main.get()
            post = main.new('a')

            passes.specialize_program_args(pre, post,
                                           arguments, 'arguments',
                                           name=name)

        if watches != []:
            def _watch(m):
                "Applying watches"
                pre = m.get()
                post = m.new('watch')
                print pre
                toolchain.watch(pre, post, watches)
            InParallel(_watch, files.values())
        else:
            print "no watches to apply"

        # Internalize everything that we can
        # We can never internalize main
        interface.writeInterface(interface.mainInterface(), 
                                 'main.iface')


        # First compute the simple interfaces
        vals = files.items()
        refs = dict([(k, VersionedFile(os.path.basename(k[:k.rfind('.bc')]), 'iface'))
                     for (k,_) in vals])
        def _references((m,f)):
            "Computing references"
            name = refs[m].new()
            passes.interface(f.get(), name, [])
        InParallel(_references, vals)
        
        def _internalize((m,i)):
            "Internalizing from references"
            pre = i.get()
            post = i.new('i')
            # sys.stderr.write("%s interfaces\n%s" % (m,  '\n'.join([refs[f].get() for f in refs.keys() if f != m] +
            #              ['main.iface'])))

            passes.intern(pre, post, 
                         [refs[f].get() for f in refs.keys() if f != m] +
                         ['main.iface'])
        InParallel(_internalize, vals)

        # Strip everything
        # This is safe because external names are not stripped
        def _strip(m):
            "Stripping symbols"
            pre = m.get()
            post = m.new('x')
            passes.strip(pre, post)
        if get_flag(flags, 'no-strip', None) is None:
            InParallel(_strip, files.values())

        # Begin main loop
        iface_before_file = VersionedFile('interface_before', 'iface')
        iface_after_file = VersionedFile('interface_after', 'iface')
        progress = True
        rewrite_files = {}
        for m in files.keys():
            base = os.path.basename(m[:m.rfind('.bc')])
            rewrite_files[m] = VersionedFile(base, 'rw')
        iteration = 0
        while progress:
            iteration += 1
            progress = False
            # Intra-module previrt
            def intra(m):
                "Intra-module previrtualization"
                # for m in files.values():
                # intra-module previrt
                pre = m.get()
                post = m.new('p')
                fn = 'previrt_%s-%s' % (os.path.basename(pre),
                                        os.path.basename(post))
                passes.peval(pre, post, log=open(fn, 'w'))
            InParallel(intra, files.values())

            # Inter-module previrt
            iface = passes.deep([x.get() for x in files.values()],
                                ['main.iface'])
            interface.writeInterface(iface, iface_before_file.new())
            
            # Specialize
            def _spec((nm, m)):
                "Inter-module module specialization"
                pre = m.get()
                post = m.new('s')
                rw = rewrite_files[nm].new()
                passes.specialize(pre, post, rw, [iface_before_file.get()])
            InParallel(_spec, files.items())

            # Rewrite
            def rewrite((nm, m)):
                "Inter-module module rewriting"
                pre = m.get()
                post = m.new('r')
                rws = [rewrite_files[x].get() for x in files.keys()
                       if x != nm]
                out = [None]
                retcode = passes.rewrite(pre, post, rws, output=out)
                fn = 'rewrite_%s-%s' % (os.path.basename(pre),
                                        os.path.basename(post))
                dbg = open(fn, 'w')
                dbg.write(out[0])
                dbg.close()
                return retcode
            rws = InParallel(rewrite, files.items())
            progress = any(rws)

            # Aggressive internalization
            InParallel(_references, vals)
            InParallel(_internalize, vals)

            # Compute the interface again
            iface = passes.deep([x.get() for x in files.values()],
                               ['main.iface'])
            interface.writeInterface(iface, iface_after_file.new())

            # Prune
            def prune(m):
                "Pruning dead code/variables"
                pre = m.get()
                post = m.new('occam')
                passes.intern(pre, post, [iface_after_file.get()])
            InParallel(prune, files.values())
        
        # Make symlinks for the "final" versions
        for x in files.values():
            trg = x.base('-final')
            if os.path.exists(trg):
                os.unlink(trg)
            os.symlink(x.get(), trg)

        final_libs = [files[x].get() for x in llvm_libs] + \
            [x for (x,y) in found_libs if not y]

        def toLflag(path):
            if os.path.exists(path):
                return "-L%s" % path
            else:
                return None
        searchflags = [x for x in map(toLflag,search) if x is not None]

        if '-lpthread' in native_libs:
            native_libs.append('-Xlinker=-pthread')
        # Link everything together
        sys.stderr.write("linking...")
        sys.stderr.write(config.LLVM['ld'])
        driver.run(config.LLVM['ld'],
                   ['-native'] +
                   ['-o=%s' % binary] +
                   [files[m].get() for m in modules] + final_libs + 
                   searchflags + shared + ['-Xlinker=-static'] + native_libs)
        sys.stderr.write("done\n")
        
        if not (POOL is None):
            POOL.shutdown()

        return 0

target.register('previrt', PrevirtTool('previrt'))
            
