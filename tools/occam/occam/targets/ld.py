# ------------------------------------------------------------------------------
# OCCAM
#
# Copyright © 2011-2012, SRI International
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

def ld_default_o(input_file):
    return 'a.out'

def useAsm(flags):
    try:
        return 'assembler' in flags[flags.index('-x')+1] 
    except ValueError,e:
        return False

class LdTool (par.ParallelTool, argparser.ArgParser):
    def flags(self): return [
        'demangle', 'unique',
        'trace-symbol', 'aarchive', 'ashared', 'adefault', 'd', 'dc', 'dp',
        'E', 'export-dynamic', 'EB', 'EL', 'f', 'i', 'memulation', 'M',
        'print-map', 'n', 'nmagic', 'N', 'omagic', 'no-omagic', 'q',
        'emit-relocs', 'force-dynamic', 'r', 'relocatable', 's', 'strip-all',
        'S', 'strip-debug', 't', 'trace', 'Ur', 'v', 'version', 'V', 'x',
        'discard-all', 'X', 'discard-locals', 'accept-unknown-input-arch',
        'no-accept-unknown-input-arch', 'as-needed', 'no-as-needed',
        'add-needed', 'no-add-needed', 'Bdynamic', 'dy', 'call_shared',
        'Bgroup', 'Bstatic', 'dn', 'non_shared', 'static', 'Bsymbolic',
        'dynamic-list-cpp-typeinfo', 'check-sections', 'no-check-sections',
        'cref', 'no-define-common', 'no-demangle', 'fatal-warnings',
        'force-exe-suffix', 'gc-sections', 'no-gc-sections',
        'print-gc-sections', 'no-print-gc-sections', 'help', 'target-help',
        'no-keep-memory', 'no-undefined', 'allow-multiple-definition',
        'allow-shlib-undefined', 'no-allow-shlib-undefined',
        'no-undefined-version', 'default-symver', 'default-imported-symver',
        'no-warn-mismatch', 'no-whole-archive', 'noinhibit-exec', 'nostdlib',
        'pie', 'pic-executable', 'qmagic', 'Qy', 'relax', 'shared',
        'Bshareable', 'sort-common', 'stats', 'traditional-format',
        'dll-verbose', 'verbose', 'warn-common', 'warn-constructors',
        'warn-multiple-gp', 'warn-once', 'warn-section-align',
        'warn-shared-textrel', 'warn-unresolved-symbols',
        'error-unresolved-symbols', 'whole-archive', 'eh-frame-hdr',
        'enable-new-dtags', 'disable-new-dtags', 'reduce-memory-overheads',
        'add-stdcall-alias', 'dll', 'enable-stdcall-fixup',
        'disable-stdcall-fixup', 'export-all-symbols', 'file-alignment',
        'kill-at', 'large-address-aware', 'enable-auto-image-base',
        'disable-auto-image-base', 'enable-auto-import',
        'disable-auto-import', 'enable-runtime-pseudo-reloc',
        'disable-runtime-pseudo-reloc', 'enable-extra-pe-debug',
        'section-alignment', 'no-trampoline' 
        ]
    def shortWithOpt(self): return [
        'b', 'c', 'e', 'F', 'O', 'R', 'Ttext', 'Tbss', 'Tdata',
        'u', 'y', 'Y', 'm', 'z', 'o', 'A', 'h', 'G', 'T', 'dynamic-linker'
        ]
    def longWithOpt(self): return [
        'architecture', 'format', 'mri-script', 'entry', 'gpsize', 'soname',
        'just-symbols', 'script', 'undefined', 'unique', 'trace-symbol',
        'dynamic-list', 'demangle', 'sysroot', 'unresolved-symbols',
        'version-script', 'hash-size', 'hash-style', 'auxiliary', 'filter',
        'fini', 'init', 'assert', 'defsym', 'dynamic-linker', 'Map',
        'oformat', 'retain-symbols-file', 'rpath', 'rpath-link',
        'sort-section', 'split-by-file', 'split-by-reloc', 'section-start',
        'Tbss', 'Tdata', 'Text', 'wrap', 'base-file', 'image-base',
        'major-image-version', 'major-os-version', 'major-subsystem-version',
        'minor-image-version', 'minor-os-version', 'minor-subsystem-version',
        'output-def', 'out-implib', 'dll-search-prefix', 'subsystem',
        'bank-window', 'output'
        ]

    def opts(self, args):
        return ([], args)

    def occam(self, cfg, args):
        tool = self.name
        #(input_files, output_file, flags) = parse_ld_args(args)
        (input_files, output_file, flags) = self.parse_args(args)
        print "ld input files: " + ' '.join(input_files)
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

        if len(input_files) == 0:
            return 0
        elif '-Wl,--help' in flags:
            # this is just help
            return 0
        elif '-Wl,-shared' in flags:
            # LLVM doesn't do shared...
            return 0
        elif '-Wl,-r' in flags or '-Wl,-i' in flags or '-Wl,--relocatable' in flags:
            # this is essentially linking as a library
            if output_file is None:
                output_file = ld_default_o(input_files[0])
            retcode = toolchain.bundle(self.fixname(output_file), 
                                       map(self.fixinputname,input_files),
                                       [x for x in flags if x.startswith('-l')],
                                       [x[2:] for x in flags if x.startswith('-L')])
            return retcode
        else:
            if output_file is None:
                output_file = ld_default_o(input_files[0])
            retcode = toolchain.link(map(self.fixinputname,input_files),
                                     self.fixname(output_file),
                                     flags + ['-lc'], 
                                     save='%s_main.bc' % output_file,
                                     link=True)
            return retcode

for x in ['ld']:
    target.register(x, LdTool(x))

