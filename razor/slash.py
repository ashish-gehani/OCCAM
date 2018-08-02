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
    template = '{0} [--work-dir=<dir>]  [--force] [--no-strip]  [--debug] [--debug-manager=] [--debug-pass=] [--devirt] [--llpe] [--help] [--ipdse] [--stats] [--verbose] [--no-specialize] [--keep-external=<file>] <manifest>\n'
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


        profile_map_before = collections.OrderedDict()
        profile_map_after = collections.OrderedDict()

        #watches were inserted here ...

        #Collect some stats before we start optimizing/debloating
        if show_stats is not None:
            for m in files.values():
                _, name = tempfile.mkstemp()
                profile_map_before[m.get()] = name
            def _profile_before(m):
                "Profiling before specialization"
                passes.profile(m.get(), profile_map_before[m.get()])
            pool.InParallel(_profile_before, files.values(), self.pool)


        def _show_stats(f, v, when):
            sys.stderr.write('\nStatistics for {0} {1} specialization\n'.format(f, when))
            fd = open(v, 'r')
            for line in fd:
                sys.stderr.write('\t')
                sys.stderr.write(line)
            fd.close()
            os.remove(v)


        # in this case we just want to show the stats and exit
        if info is not None:
            print len(profile_map_before)
            for (f, v)in profile_map_before.iteritems():
                _show_stats(f, v, 'before')
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

        #Collect stats after the whole optimization/debloating process finished
        if show_stats is not None:
            for m in files.values():
                _, name = tempfile.mkstemp()
                profile_map_after[m.get()] = name
            def _profile_after(m):
                "Profiling after specialization"
                passes.profile(m.get(), profile_map_after[m.get()])
            pool.InParallel(_profile_after, files.values(), self.pool)

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
        try:
            driver.linker(final_module, binary, linker_args)
            sys.stderr.write('\ndone.\n')
        except Exception as e:
            sys.stderr.write('\nFAILED. Modify the manifest to add libraries and/or linker flags.\n\n')
            import traceback
            traceback.print_exc()

        pool.shutdownDefaultPool()
        #Print stats before and after
        if show_stats is not None:
            for (f1,v1), (f2,v2) in zip(profile_map_before.iteritems(), \
                                        profile_map_after.iteritems()) :

                #sys.stderr.write('f1 = {0}\nf2 = {1}\n'.format(f1, f2))
                def _splitext(abspath):
                    #Given abspath of the form basename.ext1.ext2....extn
                    #return basename
                    base = os.path.basename(abspath)
                    res = base.split(os.extsep)
                    assert(len(res) > 1)
                    #ext = res[1]
                    return res[0]

                f1 = _splitext(f1)
                f2 = _splitext(f2)
                #print('f1 = {0}\nf2 = {1}'.format(f1, f2))
                assert (f1 == f2)
                _show_stats(f1, v1, 'before')
                _show_stats(f2, v2, 'after')

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
