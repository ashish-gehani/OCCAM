""" Entry points into the antlr4 parser.
"""
from __future__ import print_function

import sys

from operator import itemgetter

from antlr4 import FileStream, InputStream, CommonTokenStream

from ArgvLexer import ArgvLexer

from ArgvParser import ArgvParser

from Visitor import Visitor

from ParseError import ParseError



def main(verbose=False):
    if len(sys.argv) != 2:
        print('Usage: {0} <constraint file>'.format(sys.argv[0]))
    else:
        (argc, argv)  = parseFromFile(sys.argv[1])
        print(argc)
        print(argv)
        if not verbose:
            return 0
        if argv is None:
            return 1
        for c in argv:
            print('str(c) = ', str(c))
            print('repr(c) = ', repr(c))
        return 0

def parseFromFile(filename):
    return parseFromStream(FileStream(filename), filename)

def parseFromString(string):
    return parseFromStream(InputStream(string), "stdin")

def parseFromStream(stream, source):
    argc = '-1'
    argv = None
    try:
        lexer = ArgvLexer(stream)
        stream = CommonTokenStream(lexer)
        parser = ArgvParser(stream)
        tree = parser.constraint()
        visitor = Visitor(source)
        visitor.visit(tree)
        argv = sorted(visitor.result, key=itemgetter(0), reverse=False)
        argc = visitor.argc
    except ParseError as pe:
        print(pe)
    return (argc, argv)
