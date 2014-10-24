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

from occam import toolchain
from occam import target
from occam import driver
from occam.targets import argparser
from occam.targets import par
import logging
import tempfile
import os

def clang_default_o(input_file):
    last_dir = input_file.rfind('/')
    output_file = input_file[last_dir+1:input_file.rfind('.')] + '.o'
    return output_file

def useAsm(flags):
    try:
        return 'assembler' in flags[flags.index('-x')+1] 
    except ValueError,e:
        return False

class ClangTool (par.ParallelTool, argparser.ArgParser):
    def flags(self): return [
        'E', 'fsyntax-only', 'S', 'c', 'analyze', 'ansi', 'pg', 'p',
        'ObjC++', 'ObjC', 'trigraphs', 'ffreestanding', 'fwrapv', 
        'fno-builtin', 'fmath-errno', 'fpascal-strings',
        'fms-extensions', 'fborland-extensions', 'fwritable-strings',
        'flax-vector-conversions', 'fblocks', 'fobjc-gc-only',
        'fobjc-gc', 'fobjc-nonfragile-abi', 'fno-objc-nonfragile-abi',
        'miphoneos-version-min', 'O0', 'O1', 'O2', 'Os', 'Oz',
        'O3', 'O4', 'g', 'fexceptions', 'ftrapv', 'fvisibility', 'frename-registers', 
        'fcommon', 'flto', 'emit-llvm', '###', 'help',
        'Qunused-arguments', 'print-libgcc-file-name',
        'print-search-dirs', 'save-temps', 'integrated-as',
        'no-integrated-as', 'time', 'ftime-report', 'v',
        'fshow-column', 'fshow-source-location', 'fcaret-diagnostics',
        'fdiagnostics-fixit-info', 'fdiagnostics-parseable-fixits',
        'fdiagnostics-print-source-range-info', 'fprint-source-range-info',
        'fdiagnostics-show-option', 'fmessage-length', 'nostdinc', 'nostdlib',
        'nostdlibinc', 'nobuiltininc', 'M', 'pipe', 'fno-exceptions',
        'static', 'fno-rtti', 'fpic', 'fPIC', 'fstack-protector',
        'w', 'fno-omit-frame-pointer', 'finhibit-size-directive',
        'fno-inline-functions', 'nodefaultlibs', 'shared', 
        'fno-zero-initialized-in-bss', 'fno-toplevel-reorder',
        'fno-asynchronous-unwind-tables', 'g0', 'fnon-call-exceptions',
        'fno-builtin-rint', 'fno-builtin-rintl', 'fno-builtin-rintf',
        'mno-mmx', 'mno-3dnow', 'mno-sse', 'mno-sse2', 'mno-sse3', 'msoft-float', 'm32',
        'fno-implicit-templates', 'ffunction-sections', 'fdata-sections',
        'fno-guess-branch-probability', 'fno-unit-at-a-time',
        'mno-align-long-strings', 'mrtd', 'ffreestanding', 'fomit-frame-pointer',
        'fno-strict-aliasing', 'fshort-wchar', 'undef', 'fno-builtin-strftime',
        'funsigned-char', 'mmmx', 'msse', 'msse2', 'fformat-extensions',
        'fno-common', 'C', 'dM', 'fvisibility-inlines-hidden', 'pthread', 'version',
        'verbose'
        ]
    def shortWithOpt(self): return [
        'x', 'arch', 'Wa,', 'Wl,', 'Wp,', 'o', 'D', 'U', 'I', 'F', 'Ttext',
        'l', 'L', 'W', 'param', 'include', 'mllvm', 'Tdata', 'Tbss', 'e', 'm',
        'isystem', 'B', 'T', 'rpath'
        ]
    def longWithOpt(self): return [
        'std', 'stdlib', 'fmsc-version', 'fobjc-abi-version',
        'fobjc-nonfragile-abi-version', 'mmacosx-version-min',
        'march', 'Xanalyzer', 'Xassembler', 'Xlinker', 'Xpreprocessor',
        'print-file-name', 'print-prog-name', 'library',
        'fvisibility', 'frandom-seed', 'mpreferred-stack-boundary',
        'mregparm', 'mstack-alignment'
        ]

    def opts(self, args):
        return ([], args)

    def occam(self, cfg, args):
        tool = self.name
        #(input_files, output_file, flags) = parse_gcc_args(args)
        (input_files, output_file, flags) = self.parse_args(args)
        # TODO: this seems to have side effects, but since I'm duplicating
        #      stdin it shouldn't, right?
        cfg.log("%(in)s\n%(out)s\n%(fl)s\n",
                 { 'in' : input_files.__repr__()
                 , 'out' : output_file.__repr__()
                 , 'fl' : flags.__repr__() })

        if '-' in input_files:
#             num = os.dup(0)
#             fd = os.fdopen(num,'r')
#             cfg.log("compiling stdin\n%(msg)s", {'msg' : fd.read()})
#             fd.close()
             return 0 # IAM: Could also check that output is /dev/null

        if '/dev/null' == output_file:
            cfg.log("skipping output /dev/null", {})
            return 0

        if not os.getenv('VERBOSE') is None:
            try:
#                logging.getLogger().info("SOURCE FILE = %s", open(input_files[0]).read())
#                logging.getLogger().info("confdefs.h = %s", open("confdefs.h").read())
                pass
            except:
                pass
        if len(input_files) == 0 or ('-print-libgcc-file-name' in args):
            return 0
        elif '--help' in args:
            # this is just help
            return 0
        elif tool == 'clang-cpp' or ('-E' in args and output_file is None):
            # this is just cpp
            return 0
        elif '-shared' in args:
            # LLVM doesn't do shared...
            return 0
        elif '-r' in args:
            # this is essentially linking
            if output_file is None:
                output_file = clang_default_o(input_files[0])
            toolchain.bundle(self.fixname(output_file), input_files, 
                             [x for x in flags if x.startswith('-l')],
                             [x[2:] for x in flags if x.startswith('-L')])
            return 0
        elif '-c' in args or '-S' in args:
            if output_file is None:
                output_file = clang_default_o(input_files[0])

            if input_files[0].lower().endswith('.s') or useAsm(flags):
                # XXX
                return toolchain.compile(input_files,
                                          self.fixname(output_file), 
                                         flags, 
                                         tool=tool)
            elif input_files[0] == '-':
                return toolchain.compile(input_files, self.fixname(output_file), 
                                         flags,
                                         tool=tool)
            else:
                # print input_files
                # c_file = [x for x in input_files 
                #           if x.endswith('.c') or x.endswith('.cpp') 
                #           or x.endswith('.cxx') or x.endswith('.cc')]
                c_file = input_files[0]
                return toolchain.compile([c_file] + [x for x in input_files if x != c_file],
                                         self.fixname(output_file), 
                                         flags,
                                         tool=tool)
        else:
            assert not useAsm(flags) # NOT IMPLEMENTED
            # if any(map(lambda x: '.so' in x, input_files)):
            #     logging.getLogger().info("got .so, skipping")
            stdlibs = ['-lc']
            if self.name == 'clang++':
                stdlibs.append('-lstdc++')

            def needsCompiling(f):
                return f == '-' or f.endswith('.c') or f.endswith('.cpp') or f.endswith('.cxx')
            toCompile = filter(needsCompiling,input_files)
            if toCompile:
                o_files = []
                for fileToCompile in toCompile:
                    tf = tempfile.NamedTemporaryFile(delete=False)
                    retcode = toolchain.compile([fileToCompile], 
                                                self.fixname(tf.name),
                                                flags, tool=tool)
                    o_files.append(tf.name)
                    if retcode != 0:
                        map(os.unlink,o_files)
                        return retcode
                if output_file is None:
                    output_file = 'a.out'
                toLink = [x for x in input_files if x not in toCompile]
                try:
                    retcode = toolchain.link(map(self.fixname,o_files) +
                                             map(self.fixinputname,toLink),
                                             self.fixname(output_file),
                                             flags + stdlibs,
                                             link=True,
                                             save='%s_mani' % output_file)
                except driver.ReturnCode,ex:
                    logging.getLogger().warn("WARNING: manifest link failed for %s" % output_file)
                    logging.getLogger().warn("%s" % ex)
                    retcode = 0
                map(os.unlink,o_files)
            else:
                if output_file is None:
                    output_file = 'a.out'
                try:
                    retcode = toolchain.link(map(self.fixinputname,input_files),
                                             self.fixname(output_file),
                                             flags + stdlibs, 
                                             save='%s_main.bc' % output_file,
                                             link=True)
                except driver.ReturnCode,ex:
                    logging.getLogger().warn("WARNING: manifest link failed for %s" % output_file)
                    logging.getLogger().warn("%s" % ex)
                    retcode = 0
            return retcode

for x in ['clang', 'clang++', 'clang-cpp']:
    target.register(x, ClangTool(x))

