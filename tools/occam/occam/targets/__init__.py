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

__all__ = ["install", "interface", "enforce", "parse", "rewrite", "slice",
           "run", "show", "strip", "previrt", "watch", "specialize", "help",
           "peval", "args", "pack",
           "build", 
           # Compile hooks 
           "clang", "as", "ar", "cp", "ld"]

__map__ = { 'ar' : 'ar',
            'args' : 'args',
            'arlink' : 'arlink',
            'as' : 'as',
            'build' : 'build',
            'cp' : 'cp',
            'mv' : 'cp',
            'enforce' : 'enforce',
            'help' : 'help',
            'install' : 'cp',
            'interface' : 'interface',
            'pack' : 'pack',
            'parse' : 'parse',
            'peval' : 'peval',
            'rewrite' : 'rewrite',
            'run' : 'run',
            'show' : 'show',
            'slice' : 'slice',
            'specialize' : 'specialize',
            'strip' : 'strip',
            'ranlib' : 'strip',
            'chmod' : 'strip',
            'ln' : 'cp', 
            'rm' : 'cp',
            'unlink' : 'cp',
            'watch' : 'watch',
            'clang' : 'clang',
            'clang++' : 'clang',
            'clang-cpp' : 'clang',
            'ld' : 'ld',
            'previrt' : 'previrt'
            }
