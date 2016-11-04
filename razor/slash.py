import getopt, sys

from .utils import *

def main():
    setLogger()
    Slash(sys.argv).run()
    return 0



class Slash(object):
    
    def __init__(self, argv):
        (flags, args) = getopt.getopt(argv[1:], None, ['work-dir='])
        self.manifest = get_manifest(args)
        if self.manifest is None:
            self.usage(argv[0])
            self.ok = False
            return
        self.work_dir = get_work_dir(flags)
        self.ok = True
        
    def  usage(self, exe):
        sys.stderr.write('{0} [--work-dir=<dir>] <manifest>\n'.format(exe))


    def run(self):
        
        if not self.ok: return

        if not make_work_dir(self.work_dir): return

        (ok, module, binary, libs, args, name) = check_manifest(self.manifest)

        if not ok: return

        files = populate_work_dir(module, libs, self.work_dir)

        os.chdir(self.work_dir)

        #specialize the arguments ...
        specialize_args(files[module], args, name)

        
        
        

