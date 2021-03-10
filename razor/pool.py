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


 Thread pool for processing modules in parallel.

"""
from queue import Queue
import datetime
import threading
import traceback
import sys

class Worker(threading.Thread):
    """ A daemon worker thread.
    """
    def __init__(self, q):
        """ Initializes a thread in the queue q.
        """
        threading.Thread.__init__(self)
        self.daemon = True
        self.queue = q
    def run(self):
        """ The thread main.
        """
        while True:
            f = self.queue.get(True)
            f()


class ThreadPool:
    """ A pool of daemon worker threads.
    """
    def __init__(self, count=3):
        """ Initializes a pool queue.
        """
        self.queue = Queue()
        self.workers = None
        self.count = count

    def _start(self):
        if self.workers is None:
            self.workers = [Worker(self.queue)]
            for w in self.workers:
                w.start()

    def map(self, f, args):
        self._start()
        args = list(args)
        result = [None for i in range(0, len(args))]
        sem = threading.Semaphore(0)
        def func(i):
            def rf():
                try:
                    result[i] = f(args[i])
                except Exception:
                    seperator = '-' * 60
                    print("Exception in worker for {0}:".format(f.__doc__))
                    print(seperator)
                    traceback.print_exc(file=sys.stderr)
                    print(seperator)
                    sys.exit(1)  #iam: was _exit; but are we really that low level?
                finally:
                    sem.release()
            return rf
        for i in range(0, len(args)):
            self.queue.put(func(i))
        for _ in args:
            sem.acquire(True)
        return result

    def shutdown(self):
        pass

POOL = ThreadPool(3)

def getDefaultPool():
    return POOL

def InParallel(f, args, pool=None):
    dt = datetime.datetime.now ().strftime ('%d/%m/%Y %H:%M:%S')
    sys.stderr.write("[%s] Starting %s...\n" % (dt, f.__doc__))
    if pool is None:
        pool = getDefaultPool()
    result = pool.map(f, args)
    sys.stderr.write("done\n")
    return result


def shutdownDefaultPool():
    POOL.shutdown()
