import getopt, sys

from utils import get_work_dir, get_manifest

def main():
    Slash(sys.argv).run()
    return 0



class Slash(object):
    
    def __init__(self, argv):
        (flags, args) = getopt.getopt(argv[1:], ['work-dir='])
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
        if self.ok:
            print 'run'

