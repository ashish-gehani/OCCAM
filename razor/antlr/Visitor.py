""" The Visitor class that calls into antlr4.
"""

from ArgvVisitor import ArgvVisitor
from ParseError import ParseError


class Visitor(ArgvVisitor):

    def __init__(self, filename):
        self.argc = '-1'
        self.result = []
        self.filename = filename

    def visitConstraint(self, ctx):
        self.visitChildren(ctx)
        return self.result

    def visitAtom(self, ctx):
            
        integer = ctx.INTEGER()
        if integer is None:
            raise ParseError("Misunderstood atom 1")
        index = int(integer.getSymbol().text)

        if ctx.ARGC() is not None:
            self.argc = index
        else:
            value_node = ctx.STRING()
            if value_node is None:
                raise ParseError("Misunderstood atom 2")
            value = str(value_node.getSymbol().text)
            atom = (index, value)
            self.result.append(atom)
