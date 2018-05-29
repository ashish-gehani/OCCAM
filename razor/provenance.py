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
"""

class VersionedFile(object):
    def __init__(self, base, suffix, digits=2):
        self._base = base
        self._suffix = suffix
        self._version = 0
        self._format = "%s.%%0%dd.%s" % (base, digits, suffix)
    def new(self):
        self._version += 1
        return self.get()
    def get(self):
        if self._version == 0:
            return "%s.%s" % (self._base, self._suffix)
        return self._format % self._version

class FileStream(object):
    def __init__(self, base, suffix):
        self._base = base
        self._suffix = suffix
        self._versions = []

    def new(self, ver=''):
        self._versions += [ver]
        return self.get()

    def get(self):
        return self._base + '.' + '.'.join(self._versions + [self._suffix])

    def __str__(self):
        return self.get()

    def base(self, mod=None):
        if mod is None:
            return self._base + '.' + self._suffix
        return self._base + mod + '.' + self._suffix

    def __len__(self):
        return len(self._versions)
