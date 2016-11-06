import getopt, sys, os

from . import utils

from . import passes

from . import interface

from . import provenance

from . import pool


def main():
    """This is the main entry point

    razor [--work-dir=<dir>] <manifest>
    
    
    """
    return Slash(sys.argv).run() if utils.checkOccamLib() else 1

class Slash(object):
    
    def __init__(self, argv):
        utils.setLogger()
        (self.flags, self.args) = getopt.getopt(argv[1:], None, ['work-dir='])
        self.manifest = utils.get_manifest(self.args)
        if self.manifest is None:
            self.usage(argv[0])
            self.ok = False
            return
        self.work_dir = utils.get_work_dir(self.flags)
        self.ok = True
        
    def  usage(self, exe):
        sys.stderr.write('{0} [--work-dir=<dir>] <manifest>\n'.format(exe))


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
        pool.InParallel(_references, vals)
        
        def _internalize((m,i)):
            "Internalizing from references"
            pre = i.get()
            post = i.new('i')
            passes.intern(pre, post, 
                         [refs[f].get() for f in refs.keys() if f != m] +
                         ['main.iface'])
        pool.InParallel(_internalize, vals)

        # Strip everything
        # This is safe because external names are not stripped
        def _strip(m):
            "Stripping symbols"
            pre = m.get()
            post = m.new('x')
            passes.strip(pre, post)
        if utils.get_flag(self.flags, 'no-strip', None) is None:
            pool.InParallel(_strip, files.values())


        return 0
