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

import ply.lex as lex
import os
PARSE_DIR=os.path.join(os.path.dirname(__file__), 'ply')

reserved = {
    'if'      : "IF",
    'then'    : "THEN",
    'else'    : "ELSE",
    'fail'    : "FAIL",
    'forward' : "FORWARD",
    'call'    : "CALL",
    'hook'    : "HOOK",
    '...'     : "ELIPSIS",
    'undef'   : "UNDEF",
    'return'  : "RETURN",
    'exclude' : "EXCLUDE"
}

tokens = [ 
    "VAR" ,
    "MVAR" ,
    "REL" ,
    "RE" ,
    "STR" ,
    "INT"
] + list(reserved.values())

literals = "[](){},;:"

def t_STR(t):
    r'"([^\"]|\\|\\")*?"'
    t.value = t.value[1:-1]
    return t

def t_RE(t):
    r'/([^\/]|\\|\/)+?/'
    t.value = t.value[1:-1]
    return t

def t_INT(t):
    r'-?\d+'
    t.value = int(t.value)
    return t

def t_ID(t):
    r'[a-zA-Z_][a-zA-Z0-9_]*'
    t.type = reserved.get(t.value, 'ID')
    return t

def t_VAR(t):
    r'%(-?\d+|[a-zA-Z_][a-zA-Z0-9_]*)'
    try:
        t.value = int(t.value[1:])
    except:
        t.value = t.value[1:]
    return t

def t_MVAR(t):
    r'\$(-?\d+|[a-zA-Z_][a-zA-Z0-9_]*)'
    try:
        t.value = int(t.value[1:])
    except:
        t.value = t.value[1:]
    return t

def t_REL(t):
    r'=='
    return t

t_ignore_COMMENT=r'\#.*'
t_ignore = ' \r\n\t'

def t_error(t):
    print "Illegal character '%s'" % t.value[0]
    t.lexer.skip(1)

lexer = lex.lex(lextab='watchlex2',outputdir=PARSE_DIR)

import ply.yacc as yacc

import proto.Previrt_pb2 as pproto
import proto.Watch_pb2 as wproto

def p_watches(p):
    """
    watches : watch
    watches : watch watches
    """
    if len(p) == 2:
        p[0] = [p[1]]
    else:
        p[0] = [p[1]] + p[2]

def p_pattern(p):
    """
    pattern : RE 
    pattern : RE match_pred
    """
    p[0] = wproto.PatternExpr()
    p[0].function_name = p[1]
    if len(p) == 3:
        p[0].MergeFrom(p[2])

def p_strings(p):
    """
    strings : 
    strings : STR
    strings : STR ',' strings
    """
    if len(p) == 1:
        p[0] = []
    elif len(p) == 2:
        p[0] = [p[1]]
    elif len(p) == 4:
        p[0] = [p[1]] + p[3]
    else:
        assert False

def p_match_pred(p):
    """
    match_pred : ':' EXCLUDE '[' strings ']'
    """
    p[0] = wproto.PatternExpr()
    for ex in p[4]:
        p[0].exclude.append(ex)

def p_watch(p):
    "watch : HOOK pattern '(' args ')' action"
    p[0] = ('watch', p[2], compileHook(p[2], p[4], p[6]))

def p_action_forward(p):
    "action : FORWARD"
    p[0] = wproto.ActionTree()
    p[0].forward.CopyFrom(wproto.ActionTree.Forward())

def p_action_fail(p):
    "action : FAIL"
    p[0] = wproto.ActionTree()
    p[0].fail.CopyFrom(wproto.ActionTree.Fail())

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
        p[0] = [p[1]] + p[3]

def p_action_seq(p):
    """
    action_seq : action ';' action_seq
    action_seq : action
    """
    if len(p) == 2:
        p[0] = [p[1]]
    else:
        p[0] = [p[1]] + p[3]
        

def p_action_block(p):
    """
    action : '{' action_seq '}'
    """
    if len(p[2]) == 1:
        p[0] = p[2][0]
    else:
        p[0] = wproto.ActionTree()
        for act in p[2]:
            p[0].Seq.add().CopyFrom(act)

def p_prim_expr_str(p):
    "prim_expr : STR"
    p[0] = wproto.PrimExpr()
    p[0].str=p[1]
def p_prim_expr_int(p):
    "prim_expr : INT ':' INT"
    p[0] = wproto.PrimExpr()
    p[0].lit.type = pproto.I
    p[0].lit.int.bits = p[3]
    p[0].lit.int.value = hex(p[1])[2:]
def p_prim_expr_var(p):
    "prim_expr : VAR"
    p[0] = wproto.PrimExpr(var=p[1])
def p_prim_expr_mvar(p):
    "prim_expr : MVAR"
    p[0] = wproto.PrimExpr(match=p[1])

def p_prim_expr_list(p):
    """
    prim_expr_list : prim_expr
    prim_expr_list : prim_expr prim_expr_list
    """
    if len(p) == 2:
        p[0] = [p[1]]
    elif len(p) == 3:
        p[0] = [p[1]] + p[2]
    else:
        assert False


def p_prim_exprs_prim_expr(p):
    """
    prim_exprs : prim_expr
    """
    p[0] = wproto.PrimExprs(one=p[1])

def p_prim_exprs(p):
    """
    prim_exprs : ELIPSIS
    prim_exprs : INT ELIPSIS INT
    """
    p[0] = wproto.PrimExprs()
    p[0].Args()
    if len(p) == 4:
        p[0].start = p[1]
        p[0].end = p[3]

def p_prim_exprs_list(p):
    """
    prim_exprs_list : 
    prim_exprs_list : prim_exprs
    prim_exprs_list : prim_exprs ',' prim_exprs_list
    """
    if len(p) == 1:
        p[0] = []
    elif len(p) == 2:
        p[0] = [p[1]]
    elif len(p) == 4:
        p[0] = [p[1]] + p[3]
    else:
        assert False

def p_action_return1(p):
    """
    action : RETURN prim_expr
    """
    p[0] = wproto.ActionTree()
    r = p[0].__getattribute__('return')
    r.value.CopyFrom(p[2])

def p_action_return(p):
    """
    action : RETURN
    action : RETURN UNDEF
    """
    p[0] = wproto.ActionTree()
    r = p[0].__getattribute__('return')
    r.undef = True

def p_action_call(p):
    """
    action : CALL prim_expr '(' prim_exprs_list ')'
    action : CALL '[' prim_expr_list ']' '(' prim_exprs_list ')'
    """
    p[0] = wproto.ActionTree()
    evt = p[0].call
    if len(p) == 6:
        args = p[4]
        evt.target.add().CopyFrom(p[2])
    else:
        args = p[6]
        for x in p[3]:
            evt.target.add().CopyFrom(x)
    for x in args:
        evt.args.add().CopyFrom(x)

def p_action_if(p):
    """
    action : IF '(' VAR REL INT ')' THEN action
    action : IF '(' VAR REL INT ')' THEN action ELSE action
    """
    p[0] = wproto.ActionTree()
    case = p[0].__getattribute__('if')
    case.var = p[3]
    assert p[4] == '=='
    case.test.type = pproto.I
    case.test.int.value = hex(p[5])[2:]
    case.test.int.bits = 32
    case._then.CopyFrom(p[8])
    if len(p) == 11:
        case._else.CopyFrom(p[10])

def p_error(p):
    print "Syntax error in input! '%s'" % p.__repr__()

parser = yacc.yacc(outputdir=PARSE_DIR,debug=0)

def compileHook(name, args, body):
    # TODO: substitute variables that are bound in args
    # TODO: sanity check everything
    return body

def build_interface(watches, into):
    # print watches
    for (ty, name, action) in watches:
        y = into.hooks.add()
        y.action.CopyFrom(action)
        y.pattern.CopyFrom(name)
    assert into.IsInitialized()
    return into

def parse(s):
    return parseInto(wproto.WatchInterface(), s)

def parseInto(proto, s):
    return build_interface(parser.parse(s), proto)
