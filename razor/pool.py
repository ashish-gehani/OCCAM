""" Thread pool for processing modules in parallel.
"""
from Queue import Queue
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


class ThreadPool(object):
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
        result = [None for i in range(0, len(args))]
        sem = threading.Semaphore(0)
        def func(i):
            def rf():
                try:
                    result[i] = f(args[i])
                except Exception:
                    print "Exception in worker for %s:" % f.func_doc
                    print '-'*60
                    traceback.print_exc(file=sys.stderr)
                    print '-'*60
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
    sys.stderr.write("Starting %s...\n" % f.func_doc)
    if pool is None:
        pool = getDefaultPool()
    result = pool.map(f, args)
    sys.stderr.write("done\n")
    return result


def shutdownDefaultPool():
    POOL.shutdown()
