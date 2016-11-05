from Queue import Queue
import threading, os, traceback, sys

class Worker (threading.Thread):
    def __init__(self, q):
        threading.Thread.__init__(self)
        self.daemon = True
        self._q = q
    def run(self):
        while True:
            f = self._q.get(True)
            f()


class ThreadPool:
    def __init__(self, count=3):
        self._q = Queue()
        self._workers = None
        self._count = count

    def _start(self):
        if self._workers is None:
            self._workers = [Worker(self._q)]
            for w in self._workers:
                w.start()

    def map(self, f, args):
        self._start()
        result = [None for i in range(0, len(args))]
        sem = threading.Semaphore(0)
        def func(i):
            def rf():
                try:
                    result[i] = f(args[i])
                except Exception,e:
                    print "Exception in worker for %s:" % f.func_doc
                    print '-'*60
                    traceback.print_exc(file=sys.stderr)
                    print '-'*60
                    os._exit(1)
                finally:
                    sem.release()
            return rf
        for i in range(0, len(args)):
            self._q.put(func(i))
        for _ in args:
            sem.acquire(True)
        return result        

    def shutdown(self):
        pass

POOL = None

def getDefaultPool():
    global POOL
    if POOL is None:
        POOL = ThreadPool(3)
    return POOL

def InParallel(f, args, pool=None):
    sys.stderr.write("Starting %s...\n" % f.func_doc)
    if pool is None:
        pool = defaultPool()
    result = pool.map(f, args)
    sys.stderr.write("done\n")
    return result


 def shutdownDefaultPool():       
     if not (POOL is None):
         POOL.shutdown()
