""" A ParseError to raise from parsing.
"""
class ParseError(Exception):

    def __init__(self, msg):
        Exception.__init__(self)
        self.msg = msg

    def __str__(self):
        return repr(self.msg)
