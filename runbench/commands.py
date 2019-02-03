#!/usr/bin/env python

import sys
import os
import os.path
import subprocess as sub
import datetime 
import threading
import signal

curdir = os.path.dirname(os.path.realpath(__file__))
# For informative error messages
signal_codes = dict((k, v) for v, k in reversed(sorted(signal.__dict__.items()))
               if v.startswith('SIG') and not v.startswith('SIG_'))

def raise_error(msg):
    print "Error: " + msg
    sys.exit(1)
    
def warning(msg):
    print "Warning: " + msg
    
def is_exec (fpath):
    if fpath == None: return False
    return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

def which(program):
    fpath, fname = os.path.split(program)
    if fpath:
        if is_exec (program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            exe_file = os.path.join(path, program)
            if is_exec (exe_file):
                return exe_file
    return None

def create_work_dir (dname=None, save=False, prefix='tmp-'):
    import tempfile
    import atexit
    import shutil
    
    if dname is None:
        workdir = tempfile.mkdtemp (prefix=prefix)
    else:
        if not os.path.isdir (dname): os.mkdir (dname)
        workdir = dname

    if not save:
        atexit.register (shutil.rmtree, path=workdir)
    return workdir

def run_limited_cmd(cmd, outfd, errfd, benchmark_name, directory = None, cpu = -1, mem = -1):
    import resource

    if directory is not None:
        os.chdir(directory)
        
    timeout = False
    out_of_memory = False
    segfault = False
    returnvalue = 0
    
    def set_limits ():
        # The maximum amount of CPU time the process can use.
        # If it runs for longer than this, it gets a signal: SIGXCPU.
        # The value is measured in seconds.
        # if cpu > 0:
        #     resource.setrlimit (resource.RLIMIT_CPU, [cpu, cpu])
        os.setsid()
        # The maximum size of the process's virtual memory (address space) in
        # bytes. This limit affects calls to brk(2), mmap(2) and mremap(2),
        # which fail with the error ENOMEM upon exceeding this limit. Also
        # automatic stack expansion will fail (and generate a SIGSEGV that kills
        # the process if no alternate stack has been made available via
        # sigaltstack(2)).
        if mem > 0:
            mem_bytes = mem * 1024 * 1024
            resource.setrlimit (resource.RLIMIT_AS, [mem_bytes, mem_bytes])

    def kill (proc):
        print "Timeout reached!"
        os.killpg(os.getpgid(proc.pid), 15)

    dt = datetime.datetime.now ().strftime ('%d/%m/%Y %H:%M:%S')
    print "[" + dt + "] " + "RUN " + ' '.join(cmd) + " on " + benchmark_name 
    sys.stdout.flush()

    ## WARNING: The use of preexec_fn is unsafe because it can lead to deadlocks
    p = sub.Popen (cmd, stdout=outfd, stderr=errfd, preexec_fn=set_limits)        
    #global running_process
    #running_process = p
    timer = threading.Timer(cpu, kill, [p])
    if cpu > 0:
        timer.start ()
        
    try:
        #option = os.WNOHANG
        option = 0
        (pid, status, ru_child) = os.wait4 (p.pid, option)
        outfd, errfd = p.communicate()
        ## assert pid == p.pid
        signal = status & 0xff    ## signal number that killed the process
        returnvalue = status >> 8 ## exit status
        if signal <> 0 :
            if signal > 127:
                # if the high bit of the low byte is set then a core file was produced
                segfault = True
            else:
                signal_name = signal_codes.get(signal)
                if signal_name is not None:
                    print "** Killed by signal: " + signal_name
                    if signal_name == 'SIGTERM' or signal_name == 'SIGALRM' or signal_name == 'SIGKILL':
                        ## kill sends SIGTERM by default.
                        ## The timer set above uses kill to stop the process.
                        timeout = True
                    else:
                        # FIXME: we decide to classify it as segfault
                        # but it might be due to other reasons
                        segfault = True
                else:
                    print "** Killed by unknown signal code: " + str(signal)
                    # FIXME: we decide to classify it as segfault
                    # but it might be due to other reasons
                    segfault = True
        sys.stdout.flush()                
        #running_process = None
    except OSError as e:
        print "** OS Error: " + str(e)
        if os.errno.errorcode[e.errno] == 'ECHILD':
            ## The children has been killed. We assume it has been killed by the timer.
            ## But I think it can be killed by others
            timeout = True
        if os.errno.errorcode[e.errno] == 'ENOMEM':
            out_of_memory = True
        returnvalue = e.errno
        sys.stdout.flush()
    finally:
        ## kill the timer if the process has terminated already
        if timer.isAlive (): timer.cancel ()

        
    dt = datetime.datetime.now ().strftime ('%d/%m/%Y %H:%M:%S')
    if timeout:
        print "[TIMEOUT --- " + dt + "]"
    elif out_of_memory:
        print "[MEMORY-OUT --- " + dt + "]"
    elif segfault:
        print "[SEGFAULT --- " + dt + "]"
    elif returnvalue <> 0:
            print "[RETURNVALUE=" + str(returnvalue) + " --- " + dt + "]"
    sys.stdout.flush()

    if directory is not None:
        os.chdir(curdir)
    
    return (returnvalue, timeout, out_of_memory, segfault)
