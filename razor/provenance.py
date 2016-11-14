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
        else:
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
        else:
            return self._base + mod + '.' + self._suffix

    def __len__(self):
        return len(self._versions)
