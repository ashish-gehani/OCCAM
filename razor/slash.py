import getopt, sys, os

from . import utils

from . import passes

from . import interface

from . import provenance

from . import pool


def main():
    """This is the main entry point

    razor [--work-dir=<dir>] <manifest>

    Previrtualize a compilation unit based on its manifest.

        --work-dir       : Output intermediate files to the given location
        --no-strip       : Leave symbol information in the binary
        --force          : Proceed after dependency warnings
        --no-specialize  : Do not specialize any itermodule calls
   
    
    """
    return Slash(sys.argv).run() if utils.checkOccamLib() else 1

class Slash(object):
    
    def __init__(self, argv):
        utils.setLogger()
        (self.flags, self.args) = getopt.getopt(argv[1:], None, ['work-dir=','force','no-strip', 'no-specialize'])
        self.manifest = utils.get_manifest(self.args)
        if self.manifest is None:
            self.usage(argv[0])
            self.ok = False
            return
        self.work_dir = utils.get_work_dir(self.flags)
        self.pool = pool.getDefaultPool()
        self.ok = True
        
    def  usage(self, exe):
        sys.stderr.write('{0} [--work-dir=<dir>]  [--force] [--no-strip] [--no-specialize] <manifest>\n'.format(exe))


    def run(self):
        
        if not self.ok: return 1

        if not utils.make_work_dir(self.work_dir): return 1

        (ok, module, binary, libs, args, name) = utils.check_manifest(self.manifest)

        #<delete this once done>
        new_libs = []
        for lib in libs:
            new_libs.append(os.path.realpath(lib))
                            
        libs = new_libs
        #</delete this once done>


        if not ok: return 1

        files = utils.populate_work_dir(module, libs, self.work_dir)

        os.chdir(self.work_dir)

        #specialize the arguments ...
        if not (args is None):
            main = files[module]
            pre = main.get()
            post = main.new('a')
            passes.specialize_program_args(pre, post, args, 'arguments', name=name)
            
        
        #watches were inserted here ... 

        # Internalize everything that we can
        # We can never internalize main
        interface.writeInterface(interface.mainInterface(), 'main.iface')



        # First compute the simple interfaces
        vals = files.items()
        refs = dict([(k, provenance.VersionedFile(utils.prevent_collisions(k[:k.rfind('.bc')]), 'iface'))
                     for (k,_) in vals])

        def _references((m,f)):
            "Computing references"
            name = refs[m].new()
            passes.interface(f.get(), name, [])

        pool.InParallel(_references, vals, self.pool)
        
        def _internalize((m,i)):
            "Internalizing from references"
            pre = i.get()
            post = i.new('i')
            passes.intern(pre, post, 
                         [refs[f].get() for f in refs.keys() if f != m] +
                         ['main.iface'])

        pool.InParallel(_internalize, vals, self.pool)

        # Strip everything
        # This is safe because external names are not stripped
        def _strip(m):
            "Stripping symbols"
            pre = m.get()
            post = m.new('x')
            passes.strip(pre, post)

        if utils.get_flag(self.flags, 'no-strip', None) is None:
            pool.InParallel(_strip, files.values(), self.pool)

        # Begin main loop
        iface_before_file = provenance.VersionedFile('interface_before', 'iface')
        iface_after_file = provenance.VersionedFile('interface_after', 'iface')
        progress = True
        rewrite_files = {}
        for m in files.keys():
            base = utils.prevent_collisions(m[:m.rfind('.bc')])
            rewrite_files[m] = provenance.VersionedFile(base, 'rw')
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
                pre_base = os.path.basename(pre)
                post = m.new('p')
                post_base = os.path.basename(post)
                fn = 'previrt_%s-%s' % (pre_base, post_base)
                print '%s === passes.peval ===> %s' % (pre_base, post_base)
                passes.peval(pre, post, log=open(fn, 'w'))

            pool.InParallel(intra, files.values(), self.pool)

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
            iface = passes.deep([x.get() for x in files.values()],
                               ['main.iface'])
            interface.writeInterface(iface, iface_after_file.new())

            # Prune
            def prune(m):
                "Pruning dead code/variables"
                pre = m.get()
                post = m.new('occam')
                passes.intern(pre, post, [iface_after_file.get()])
            pool.InParallel(prune, files.values(), self.pool)
        
        # Make symlinks for the "final" versions
        for x in files.values():
            trg = x.base('-final')
            if os.path.exists(trg):
                os.unlink(trg)
            os.symlink(x.get(), trg)


        pool.shutdownDefaultPool()
            
        return 0
