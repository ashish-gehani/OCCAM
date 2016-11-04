import json, os, re, sys, shutil

from .filestream import FileStream
from .passes import *
from .config import *

def get_flag(flags, flag, default=None):
    for (x,y) in flags:
        if x == '--{0}'.format(flag):
            return y
    return default

def get_work_dir(flags):
    d = get_flag(flags, 'work-dir')
    if d is None:
        return os.getcwd()
    return os.path.abspath(d)

    
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
    except:
        sys.stderr.write('\nReading and parsing the manifest file {0} failed\n\n'.format(args[0]))
    return manifest
    

def make_work_dir(d):
    if not os.path.exists(d):
        sys.stderr.write('making working directory... "{0}"\n'.format(d))
        os.mkdir(d)
    if not os.path.isdir(d):
        sys.stderr.write("working directory '%s' is not a directory\n" % work_dir)
        return False
    else:
        return True

def check_manifest(manifest):

    #assume we will only have one module (will be called module eventually)
    modules = manifest.get('modules')
    if modules is None: 
        sys.stderr.write('No modules in manifest\n')
        return (False, )
    [module] = modules

    binary = manifest.get('binary')
    if binary is None:
        sys.stderr.write('No binary in manifest\n')
        return (False, )

    libs = manifest.get('libs')
    if libs is None:
        sys.stderr.write('No libs in manifest\n')
        return (False, )

    args = manifest.get('args')

    name = manifest.get('name')
    if name is None:
        sys.stderr.write('No name in manifest\n')
        return (False, )
    
    return (True, module, binary, libs, args, name)


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

bit_code_pattern =  re.compile('\.bc$', re.IGNORECASE)


def populate_work_dir(module, libs, work_dir):
    files = {}

    for x in [module] + libs:
        if bit_code_pattern.search(x):
            bn = prevent_collisions(x)
            target = os.path.join(work_dir, bn)
            if os.path.abspath(x) != target:
                shutil.copyfile(x, target)
            idx = target.rfind('.bc')
            files[x] = FileStream(target[:idx], 'bc')
        else:
            sys.stderr.write('Ignoring {0}\n'.format(x))
            

    return files

def specialize_args(main, args, name):
    if not (args is None):
        # We need to specialize main for program arguments
        pre = main.get()
        post = main.new('a')
        specialize_program_args(pre, post, args, 'arguments', name=name)



def setLogger():
    logfile = getLogfile()
    logger = logging.getLogger()
    hdlr = logging.FileHandler(logfile)
    hdlr.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(hdlr)
    
    levels = {'CRITICAL' : logging.CRITICAL,
              'ERROR' : logging.ERROR,
              'WARNING' : logging.WARNING,
              'INFO' : logging.INFO,
              'DEBUG' : logging.DEBUG
              }

    level = None
    if os.environ.has_key('OCCAM_LOGLEVEL'):
        level = levels[os.environ['OCCAM_LOGLEVEL']]
    if level is None:
        level = logging.WARNING        
    logger.setLevel(level)
    logger.info(">> %s\n" % ' '.join(sys.argv))
