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

import ply.lex as lex
import os
PARSE_DIR=os.path.join(os.path.dirname(__file__), 'ply')

reserved = {
    'if' : "IF",
    'then' : "THEN",
    'else' : "ELSE",
    'fail' : "FAIL",
    'forward' : "FORWARD",
    'signal'  : "SIGNAL"
}

tokens = [ 
    "VAR" ,
    "LIT" ,
    "REL" ,
    "ID"
] + list(reserved.values())

literals = "(){},;"

def t_LIT(t):
    r'\d+'
    t.value = int(t.value)
    return t

def t_ID(t):
    r'[a-zA-Z_][a-zA-Z0-9_]*'
    t.type = reserved.get(t.value, 'ID')
    return t

def t_VAR(t):
    r'%\d+'
    t.value = int(t.value[1:])
    return t

def t_REL(t):
    r'=='
    return t

t_ignore_COMMENT=r'\#.*'
t_ignore = ' \r\n\t'

def t_error(t):
    print "Illegal character '%s'" % t.value[0]
    t.lexer.skip(1)

lexer = lex.lex(lextab='watchlex',outputdir=PARSE_DIR)

import ply.yacc as yacc

import proto.Previrt_pb2 as proto

def p_watches(p):
    """
    watches : watch
    watches : watch watches
    """
    if len(p) == 2:
        p[0] = [p[1]]
    else:
        p[0] = [p[1]] + p[2]

def p_watch(p):
    "watch : ID '(' args ')' '{' action '}'"
    p[0] = ('watch', p[1], p[6])

def p_action_forward(p):
    "action : FORWARD"
    p[0] = proto.ActionTree(type=proto.FORWARD)

def p_action_fail(p):
    "action : FAIL"
    p[0] = proto.ActionTree(type=proto.FAIL)

def p_args(p):
    """
    args : 
    args : VAR
    args : VAR ',' args
    """
    if len(p) == 1:
        p[0] = []
    elif len(p) == 2:
        p[0] = [p[1]]
    else:
        print len(p)
        p[0] = [p[1]] + p[3]

def p_action_event(p):
    """
    action : SIGNAL ID '(' args ')' ';' action 
    action : SIGNAL ID '(' args ')'
    """
    p[0] = proto.ActionTree(type=proto.EVENT)
    evt = p[0].event
    evt.handler = p[2]
    evt.args.extend(p[4])
    if len(p) == 8:
        evt.then.CopyFrom(p[7])
    else:
        evt.exit = True

def p_action_if(p):
    """
    action : IF '(' VAR REL LIT ')' THEN '{' action '}' ELSE '{' action '}'
    """
    p[0] = proto.ActionTree(type=proto.CASE)
    p[0].case.var = p[3]
    assert p[4] == '=='
    case = p[0].case
    case.test.type = proto.I
    case.test.int.value = hex(p[5])[2:]
    case.test.int.bits = 32
    case._then.CopyFrom(p[9])
    case._else.CopyFrom(p[13])

def p_error(p):
    print "Syntax error in input! '%s'" % p.__repr__()

parser = yacc.yacc(outputdir=PARSE_DIR,debug=0)

def build_interface(watches, into):
    for (ty, name, action) in watches:
        into.functions.add(name=name, actions=action)
    assert into.IsInitialized()
    return into

def parse(s):
    return parseInto(proto.EnforceInterface(), s)

def parseInto(proto, s):
    return build_interface(parser.parse(s), proto)
    

if __name__ == '__main__':
    import sys
    f = open('watch', 'wb')
    f.write(parse(sys.stdin.read()).SerializeToString())
    f.close()
