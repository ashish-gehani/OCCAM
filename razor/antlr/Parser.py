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
        codelist = parseFromFile(sys.argv[1])
        print(codelist)
        if not verbose:
            return 0
        if codelist is None:
            return 1
        for c in codelist:
            print('str(c) = ', str(c))
            print('repr(c) = ', repr(c))
        return 0

def parseFromFile(filename):
    return parseFromStream(FileStream(filename), filename)

def parseFromString(string):
    return parseFromStream(InputStream(string), "stdin")

def parseFromStream(stream, source):
    retval = None
    try:
        lexer = ArgvLexer(stream)
        stream = CommonTokenStream(lexer)
        parser = ArgvParser(stream)
        tree = parser.constraint()
        visitor = Visitor(source)
        visitor.visit(tree)
        retval = visitor.result
        retval = sorted(retval, key=itemgetter(0), reverse=False)
    except ParseError as pe:
        print(pe)
    return retval
