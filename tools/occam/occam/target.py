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

from . import config
import os
import logging
import targets
import driver

TOOLS = {}

class ArgError (Exception):
    def __init__(self):
        pass

class Target:
    def __init__(self, name):
        self.name = name
    def opts(self, args):
        return ([], args)

    def usage(self):
        return  "...document %s!!!..." % self.name
    def desc(self):
        return ''
    def args(self):
        return []
    def help(self, verbose=False):
        print self.usage()
        print self.desc()
        if verbose:
            print self.args()

    def run(self, cfg, flags, args):
        assert False
        return None

class Configuration:
    def getStdTool(self, n):
        return config.getStdTool(n)
    def getLLVMTool(self, n):
        return config.getLLVMTool(n)
    def log(self, msg, args):
        logging.getLogger().info(msg, args)


def flag(flags, f, default=None):
    for (x,y) in flags:
        if x == f:
            return y
        return default

def usage():
    for t in TOOLS.values():
        t.help()
        print ""

# TODO: Lazy module loading is probably better, the python script
# seems to take a long time to start up

def loadAll():
    for x in targets.__all__:
        __import__('occam.targets.%s' % x)

def run(args, tool=None):
    if tool is None and (len(args) == 0 or args[0] == '-h'):
        usage()
        return -1
    if tool is None:
        tool = args[0]
        args = args[1:]

    try:
        defFile = targets.__map__[tool]
        __import__('occam.targets.%s' % defFile) # SM
        x = TOOLS[tool]
    except:
        #loadAll()
        if not TOOLS.has_key(tool):
            if 'OCCAM_PROTECT_PATH' in os.environ:
                return driver.runUnknown(tool,args)
            else:
		print "checking os env", os.environ
                logging.getLogger().error("ERROR: failed to load tool %s", tool)
                print "Bad command '%s'" % tool
                return -1
    
        x = TOOLS[tool]

    # if '-h' in args or '--help' in args:
    #     x.help(True)
    #     return 0

    (flags, args) = x.opts(args)
    try:
        cfg = Configuration()
        return x.run(cfg, flags, args)
    except ArgError,e:
        print e
        print x.usage()
        return -1

def register(name, tool):
    assert not TOOLS.has_key(name)
    #iam
    #print "target.py registering name '%s' to tool '%s'" % (name, tool)
    tool.name = name
    TOOLS[name] = tool
