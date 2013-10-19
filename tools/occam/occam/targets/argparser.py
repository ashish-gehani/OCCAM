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

import logging
import os

class UnknownArgument (Exception):
    def __init__(self, arg, cmd):
        self._arg = arg
        self._cmd = cmd
    def __str__(self):
        return "Unknown argument: %s\n\twhile parsing %s" % (self._arg, ' '.join(self._cmd))

class AmbiguousParse (Exception):
    def __init__(self, arg, cmd):
        self._arg = arg
        self._cmd = cmd
    def __str__(self):
        return "Ambiguous parse of argument: %s\n\twhile parsing %s" % (self._arg, ' '.join(self._cmd))

class ArgParser:
    def flags(self): return []
    def shortWithOpt(self): return []
    def longWithOpt(self): return []

    def extractFlag(self,string):
        if string.startswith('--'):
            string = string[2:]
        elif string.startswith('-'):
            string = string[1:]
        else:
            return None
        if '=' in string:
            string = string[:string.index('=')]
        return string
            
    def parse_args(self,args):
        '''Returns a triple (input_files, output_file, flags)'''
        input_files = []
        output_file = None
        flags = []
        i = 0
        while i < len(args):
            curFlag = self.extractFlag(args[i])
            if curFlag is not None:
                matchingShortOpts = filter(curFlag.startswith,self.shortWithOpt())
                matchingShortOpts.sort(key=(lambda s: (-len(s), s)))
                if curFlag in self.flags():
                    flags.append(args[i])
                    i += 1
                elif len(matchingShortOpts) > 0:
                    shortOpt = matchingShortOpts[0]
                    if shortOpt == curFlag:
                        shortOptArg = args[i+1]
                        shortCount = 2
                    else:
                        shortOptArg = curFlag[len(shortOpt):]
                        shortCount = 1
                    if shortOpt == 'o':
                        output_file = shortOptArg
                    else:
                        flags.extend(args[i:i+shortCount])
                    i += shortCount
                elif curFlag in self.longWithOpt():
                    if not '=' in args[i]:
                        logging.getLogger().error('ERROR: longWithOpt argument %s without \'=\'\n\twhile parsing %s', 
                                                    args[i], args)
                    longOptArg = args[i][args[i].index('=')+1:]
                    if curFlag == 'output':
                        output_file = longOptArg
                    else:
                        flags.append(args[i])
                    i += 1
                elif args[i].startswith('-') and args[i] != '-':
                    logging.getLogger().error('ERROR: unrecognized argument %s\n\twhile parsing %s', 
                                                args[i], args)
                    raise UnknownArgument(args[i], args)
                else:
                    input_files.append(args[i])
                    i += 1
            else:
                if args[i].startswith('@'):
                    logging.getLogger().warning('WARNING: using @file option %s\n\twhile parsing %s',
                                                args[i], args)
                    flags.append(args[i])
                else:
                    input_files.append(args[i])
                i += 1
        return (input_files,output_file,flags)
