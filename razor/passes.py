import os, tempfile, shutil, logging, subprocess

from . import config

from . import driver

from . import interface as inter

def interface(input_file, output_file, wrt, **opts):
    return driver.previrt(input_file, '/dev/null',
                          ['-Pinterface2', '-Pinterface2-output', output_file] +
                          driver.all_args('-Pinterface2-entry', wrt),
                          **opts)

def specialize(input_file, output_file, rewrite_file, interfaces, **opts):
    "inter module specialization, rewrite_file and output_file and the file names for the output files"
    args = ['-Pspecialize']
    if not (rewrite_file is None):
        args += ['-Pspecialize-output', rewrite_file]
    if output_file is None:
        output_file = '/dev/null'
    return driver.previrt(input_file, output_file,
                   args + driver.all_args('-Pspecialize-input', interfaces), 
                   **opts)

def rewrite(input_file, output_file, rewrites, debug=None, **opts):
    "inter module rewriting"
    return driver.previrt_progress(input_file, output_file,
                            ['-Prewrite'] + 
                            driver.all_args('-Prewrite-input', rewrites), 
                            **opts)


def intern(input_file, output_file, interfaces, **opts):
    "strips unused symbols"
    return driver.previrt_progress(input_file, output_file,
                            ['-Poccam'] + 
                            driver.all_args('-Poccam-input', interfaces), 
                            **opts)

def strip(input_file, output_file, **opts):
    args=[input_file, '-o', output_file,
          '-strip',
          '-globaldce',
          '-globalopt',
          '-strip-dead-prototypes',
          ]
    return driver.run(config.get_llvm_tool('opt'), args, **opts)

def peval(input_file, output_file, log=None, trail=None, **opts):
    "intra module previrtualization"
    if not trail:
        opt  = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
        pre  = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
        done = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
        opt.close()
        pre.close()
        done.close()
        
        out = ['']
        
        shutil.copy(input_file, done.name)
        while True:
            retcode = optimize(done.name, opt.name, **opts)
            if retcode != 0:
                # TODO: an error occurred
                shutil.copy(done.name, output_file)
                return retcode

            if driver.previrt_progress(opt.name, done.name, ['-Ppeval'], output=out):
                print "previrt successful"
                if log is not None:
                    log.write(out[0])
            else:
                break

        shutil.move(opt.name, output_file)

        try:
            os.unlink(done.name)
            os.unlink(pre.name)
        except:
            pass
        return retcode
    else:
        assert False

def optimize(input_file, output_file, **opts):
    return driver.run(config.get_llvm_tool('opt'),
               ['-disable-simplify-libcalls', input_file, '-o', output_file, '-O3'], **opts)

def specialize_program_args(input_file, output_file, args, fn=None, name=None):
    "fix the program arguments"
    if fn is None:
        arg_file = tempfile.NamedTemporaryFile(delete=False)
        arg_file.close()
        arg_file = arg_file.name
    else:
        arg_file = fn
    f = open(arg_file, 'w')
    for x in args:
        f.write(x + '\n')
    f.close()
    
    extra_args = []
    if not (name is None):
        extra_args = ['-Parguments-name', name]
    driver.previrt(input_file, output_file, 
            ['-Parguments', '-Parguments-input', arg_file] + extra_args)

    if fn is None:
        os.unlink(arg_file)

def deep(libs, ifaces):
    "compute interfaces across modules"
    tf = tempfile.NamedTemporaryFile(suffix='.iface', delete=False)
    tf.close()
    iface = inter.parseInterface(ifaces[0])
    for i in ifaces[1:]:
        inter.joinInterfaces(iface, inter.parseInterface(i))

    inter.writeInterface(iface, tf.name)

    progress = True
    while progress:
        progress = False
        for l in libs:
            interface(l, tf.name, [tf.name], quiet=True)
            x = inter.parseInterface(tf.name)
            progress = inter.joinInterfaces(iface, x) or progress
            inter.writeInterface(iface, tf.name)

    os.unlink(tf.name)
    return iface
