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
import getopt
import sys
import os
import tempfile
import collections

from . import utils

from . import passes

from . import interface

from . import provenance

from . import pool

from . import driver

from . import config

instructions = """slash has three modes of use:

    slash --help

    slash --tool=<llvm tool>

    slash [options] <manifest>

    Previrtualize a compilation unit based on its manifest.

        --help                  : Print this.

        --tool=<tool>           : Print the path to the tool and exit.

        --work-dir <dir>        : Output intermediate files to the given location <dir>
        --info                  : Display info stats and exit
        --stats                 : Show some stats before and after specialization
        --no-strip              : Leave symbol information in the binary
        --verbose               : Print the calls to the llvm tools prior to running them.
        --debug-manager=<type>  : Debug opt's pass manager (<type> should be either Structure or Details)
        --debug-pass=<tag>      : Debug opt's pass (<tag> should be the debug pragma string of the pass)
        --debug                 : Pass the debug flag into all calls to opt (too much information usually)
        --devirt                : Devirtualize indirect function calls
        --llpe                  : Use Smowton's LLPE for intra-module prunning
        --ipdse                 : Apply inter-procedural dead store elimination (experimental)
        --precise-dce           : Use model-checking to perform intra-module dead code elimination
        --no-specialize         : Do not specialize any intermodule calls
        --keep-external=<file>  : Pass a list of function names that should remain external.

    """

def entrypoint():
    """This is the main entry point.

    slash [--work-dir=<dir>] <manifest>

    For more info:

    slash --help

    """
    return Slash(sys.argv).run() if utils.checkOccamLib() else 1


def  usage(exe):
    template = '{0} [--work-dir=<dir>]  [--force] [--no-strip]  [--debug] [--debug-manager=] [--debug-pass=] [--devirt] [--llpe] [--help] [--ipdse] [--precise-dce] [--stats] [--verbose] [--no-specialize] [--keep-external=<file>] <manifest>\n'
    sys.stderr.write(template.format(exe))


class Slash(object):

    def __init__(self, argv):
        utils.setLogger()

        try:
            cmdflags = ['work-dir=',
                        'force',
                        'no-strip',
                        'devirt',
                        'debug',
                        'debug-manager=',
                        'debug-pass=',
                        'llpe',
                        'help',
                        'ipdse',
                        'precise-dce',
                        'info',
                        'stats',
                        'no-specialize',
                        'tool=',
                        'verbose',
                        'keep-external=']
            parsedargs = getopt.getopt(argv[1:], None, cmdflags)
            (self.flags, self.args) = parsedargs

            tool = utils.get_flag(self.flags, 'tool', None)
            if tool is not None:
                tool = config.get_llvm_tool(tool)
                print('tool = {0}'.format(tool))
                sys.exit(0)

            helpme = utils.get_flag(self.flags, 'help', None)
            if helpme is not None:
                print(instructions)
                sys.exit(0)


        except Exception:
            usage(argv[0])
            self.valid = False
            return

        self.manifest = utils.get_manifest(self.args)
        if self.manifest is None:
            usage(argv[0])
            self.valid = False
            return

        self.whitelist = utils.get_whitelist(self.flags)
        if self.whitelist is not None:
            if not os.path.exists(self.whitelist) or not os.path.isfile(self.whitelist):
                msg = 'The given keep-external list "{0}" is not a file, or does not exist.'
                print(msg.format(whitelist))
                self.valid = False
                return

        self.work_dir = utils.get_work_dir(self.flags)
        self.pool = pool.getDefaultPool()
        self.valid = True



    def run(self):

        if not self.valid:
            return 1

        if not utils.make_work_dir(self.work_dir):
            return 1

        parsed = utils.check_manifest(self.manifest)

        valid = parsed[0]

        if not valid:
            return 1

        (valid, module, binary, libs, native_libs, ldflags, args, name, constraints) = parsed


        if not self.driver_config():
            return 1

        no_strip = utils.get_flag(self.flags, 'no-strip', None)

        devirt = utils.get_flag(self.flags, 'devirt', None)

        use_llpe = utils.get_flag(self.flags, 'llpe', None)

        use_ipdse = utils.get_flag(self.flags, 'ipdse', None)

        use_precise_dce = utils.get_flag(self.flags, 'precise-dce', None)

        show_stats = utils.get_flag(self.flags, 'stats', None)

        info = utils.get_flag(self.flags, 'info', None)
        if info is not None:
            show_stats = True

        no_specialize = utils.get_flag(self.flags, 'no-specialize', None)

        sys.stderr.write('\nslash working on {0} wrt {1} ...\n'.format(module, ' '.join(libs)))

        native_lib_flags = []

        #this is simplistic. we are assuming they are (possibly)
        #relative paths, if we need to use a search path then this
        #will need to be beefed up.
        new_native_libs = []
        for lib in native_libs:
            if lib.startswith('-l'):
                native_lib_flags.append(lib)
                continue
            if os.path.exists(lib):
                new_native_libs.append(os.path.realpath(lib))
        native_libs = new_native_libs

        files = utils.populate_work_dir(module, libs, self.work_dir)
        os.chdir(self.work_dir)

        #watches were inserted here ...

        profile_maps, profile_map_titles = [], []
        
        def add_profile_map(title):
            profile_map = collections.OrderedDict()
            for m in files.values():
                _, name = tempfile.mkstemp()
                profile_map[m.get()] = name
            def _profile(m):
                "Profiling "                
                passes.profile(m.get(), profile_map[m.get()])
            _profile.__doc__ += title
            pool.InParallel(_profile, files.values(), self.pool)
            profile_maps.extend([profile_map])
            profile_map_titles.extend([title])
            
        def print_profile_maps(f = lambda x: x):
            def print_file(f, v, when):
                sys.stderr.write('\nStatistics for {0} {1}\n'.format(f, when))
                fd = open(v, 'r')
                for line in fd:
                    sys.stderr.write('\t')
                    sys.stderr.write(line)
                fd.close()
                os.remove(v)
            for ll in map(lambda t: list(t),
                          zip(*map(lambda OrdDic: OrdDic.iteritems(), profile_maps))):
                k, j = None, 0
                assert (len(ll) == len(profile_map_titles))
                for (ki, vi) in ll:
                    ki = f(ki)
                    if k is None: k = ki
                    else: assert(k == ki)
                    print_file(k, vi, profile_map_titles[j])
                    j += 1

        def write_timestamp(msg):
            import datetime
            dt = datetime.datetime.now ().strftime ('%d/%m/%Y %H:%M:%S')
            sys.stderr.write("[%s] %s...\n" % (dt, msg))
            
        #Collect some stats before we start optimizing/debloating
        if show_stats is not None:
            add_profile_map('before specialization')

        # in this case we just want to show the stats and exit
        if info is not None:
            print_profile_maps()
            return

        #specialize the arguments ...
        if args is not None:
            main = files[module]
            pre = main.get()
            post = main.new('a')
            passes.specialize_program_args(pre, post, args, 'arguments', name=name)
        elif constraints:
            sys.stderr.write('Input-user specialization using the constraints: {0}\n'.format(constraints))
            main = files[module]
            pre = main.get()
            post = main.new('a')
            passes.constrain_program_args(pre, post, constraints, 'constraints')

        # Internalize everything that we can
        # We can never internalize main
        interface.writeInterface(interface.mainInterface(), 'main.iface')

        # First compute the simple interfaces
        vals = files.items()
        def mkvf(k):
            return provenance.VersionedFile(utils.prevent_collisions(k[:k.rfind('.bc')]),
                                            'iface')
        refs = dict([(k, mkvf(k)) for (k, _) in vals])

        def _references((m, f)):
            "Computing references"
            nm = refs[m].new()
            passes.interface(f.get(), nm, [])

        pool.InParallel(_references, vals, self.pool)

        def _internalize((m, i)):
            "Internalizing from references"
            pre = i.get()
            post = i.new('i')
            ifaces = [refs[f].get() for f in refs.keys() if f != m] + ['main.iface']
            passes.internalize(pre, post, ifaces, self.whitelist)

        pool.InParallel(_internalize, vals, self.pool)

        # Strip everything
        # This is safe because external names are not stripped
        if no_strip is None:
            def _strip(m):
                "Stripping symbols"
                pre = m.get()
                post = m.new('x')
                passes.strip(pre, post)

            pool.InParallel(_strip, files.values(), self.pool)

        # Begin main loop
        iface_before_file = provenance.VersionedFile('interface_before', 'iface')
        iface_after_file = provenance.VersionedFile('interface_after', 'iface')
        progress = True
        rewrite_files = {}
        for m, _ in files.iteritems():
            base = utils.prevent_collisions(m[:m.rfind('.bc')])
            rewrite_files[m] = provenance.VersionedFile(base, 'rw')

        write_timestamp("Started global fixpoint ...")
        iteration = 0
        while progress:

            iteration += 1
            progress = False

            # Intra-module pruning
            def intra(m):
                "Intra-module previrtualization"
                # for m in files.values():
                # intra-module previrt
                pre = m.get()
                pre_base = os.path.basename(pre)
                post = m.new('p')
                post_base = os.path.basename(post)
                fn = 'previrt_%s-%s' % (pre_base, post_base)
                passes.peval(pre, post, devirt, use_llpe, use_ipdse, log=open(fn, 'w'))

            pool.InParallel(intra, files.values(), self.pool)

            # Inter-module previrt
            iface = passes.deep([x.get() for x in files.values()],
                                ['main.iface'])
            interface.writeInterface(iface, iface_before_file.new())

            # Specialize
            if no_specialize is None:
                def _spec((nm, m)):
                    "Inter-module module specialization"
                    pre = m.get()
                    post = m.new('s')
                    rw = rewrite_files[nm].new()
                    passes.specialize(pre, post, rw, [iface_before_file.get()])

                pool.InParallel(_spec, files.items(), self.pool)

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

            rws = pool.InParallel(rewrite, files.items(), self.pool)
            progress = any(rws)

            # Aggressive internalization
            pool.InParallel(_references, vals, self.pool)
            pool.InParallel(_internalize, vals, self.pool)

            # Compute the interface again
            iface = passes.deep([x.get() for x in files.values()], ['main.iface'])
            interface.writeInterface(iface, iface_after_file.new())

            # Prune
            def prune(m):
                "Pruning dead code/variables"
                pre = m.get()
                post = m.new('occam')
                passes.internalize(pre, post, [iface_after_file.get()], self.whitelist)
            pool.InParallel(prune, files.values(), self.pool)

        write_timestamp("Finished global fixpoint.")        
            
        #Collect stats after the whole optimization/debloating process finished
        if show_stats is not None:
            add_profile_map('after specialization')
                
        # Make symlinks for the "final" versions
        for x in files.values():
            trg = x.base('-final')
            if os.path.exists(trg):
                os.unlink(trg)
            os.symlink(x.get(), trg)


        final_libs = [files[x].get() for x in libs]
        final_module = files[module].get()

        linker_args = final_libs + native_libs + native_lib_flags + ldflags
        link_cmd = '\nclang++ {0} -o {1} {2}\n'.format(final_module, binary, ' '.join(linker_args))

        sys.stderr.write('\nLinking ...\n')
        sys.stderr.write(link_cmd)
        linking_ok = False
        try:
            driver.linker(final_module, binary, linker_args)
            sys.stderr.write('\ndone.\n')
            linking_ok = True
        except Exception as e:
            sys.stderr.write('\nFAILED. Modify the manifest to add libraries and/or linker flags.\n\n')
            import traceback
            traceback.print_exc()

        if use_precise_dce is not None and linking_ok:
            # Perform precise dce guided by maximizing the number of
            # removed ROP gadgets
            def get_ropgadget():
                def is_exec (fpath):
                    if fpath == None: return False
                    return os.path.isfile(fpath) and os.access(fpath, os.X_OK)
                def which(program):
                    fpath, fname = os.path.split(program)
                    if fpath:
                        if is_exec (program): return program
                    else:
                        for path in os.environ["PATH"].split(os.pathsep):
                            exe_file = os.path.join(path, program)
                            if is_exec (exe_file): return exe_file
                    return None
        
                ropgadget = None
                if 'ROPGADGET' in os.environ: ROPGADGET = os.environ ['ROPGADGET']
                if not is_exec(ropgadget): ropgadget = which('ropgadget')
                if not is_exec(ropgadget): ropgadget = which('ROPgadget.py')    
                return ropgadget
            
            def precise_dce((m, ropfile)):
                "Pruning dead functions using model-checking"
                pre = m.get()
                post = m.new('precise_dse')
                try:
                    passes.precise_dce(pre, ropfile, post)
                except Exception as e:
                    sys.stderr.write("Precise dce failed on " + str(pre))
                    pass
                
            ropgadget_cmd = get_ropgadget()
            if ropgadget_cmd is not None:
                binary = os.path.join(os.path.dirname(os.path.abspath(final_module)), binary)
                ropfile = binary + '.ropgadget.txt'
                ropgadget_args = ['--binary', binary, '--silent', '--fns2lines', ropfile]
                driver.run(ropgadget_cmd, ropgadget_args)
                precise_dce_args = []
                for m in files.values():
                    precise_dce_args.append((m, ropfile))
                    
                pool.InParallel(precise_dce, precise_dce_args , self.pool)
                if show_stats is not None:
                    add_profile_map('after precise dce')
                # TODO: LINK AGAIN with the new .bc files
            else:
                sys.stderr.write("ropgadget not found. Aborting precise dce ...")
                    
            
        pool.shutdownDefaultPool()
        
        #Print stats 
        if show_stats is not None:
            def _splitext(abspath):
                #Given abspath of the form basename.ext1.ext2....extn
                #return basename
                base = os.path.basename(abspath)
                res = base.split(os.extsep)
                assert(len(res) > 1)
                #ext = res[1]
                return res[0]
            print_profile_maps(_splitext)
            
        return 0


    def driver_config(self):
        debug = utils.get_flag(self.flags, 'debug', None)
        if debug is not None:
            driver.opt_debug_cmds.append('--debug')


        debug_manager = utils.get_flag(self.flags, 'debug-manager', None)
        if debug_manager is not None:
            if debug_manager not in ('Structure', 'Details'):
                print('Unknown --debug-manager value "{0}", should be either "Structure" or "Details"'.format(debug_manager))
                return False
            driver.opt_debug_cmds.append('--debug-pass={0}'.format(debug_manager))


        debug_pass = utils.get_flag(self.flags, 'debug-pass', None)
        if debug_pass is not None:
            driver.opt_debug_cmds.append('--debug-only={0}'.format(debug_pass))


        verbose = utils.get_flag(self.flags, 'verbose', None)
        if verbose is not None:
            driver.verbose = True

        return True
