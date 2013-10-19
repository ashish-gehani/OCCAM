# ------------------------------------------------------------------------------
# OCCAM
#
# Copyright (c) 2011-2012, SRI International
#
#  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of SRI International nor the names of its contributors may
#   be used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ------------------------------------------------------------------------------

from Queue import Queue
import threading
import os, traceback, sys

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

class DummyPool:
    def __init__(self, count=1):
        pass
    def map(self, f, args):
        return [f(x) for x in args]
    def shutdown(self):
        pass
