

from stringbuffer import StringBuffer

class CallGraph(object):

    def __init__(self, name):
        self.id_counter = 0
        self.name = name
        # maps the name to id
        self.nodes = {}
        self.edges = set()


    @staticmethod
    def fromModule(name, module):
        callgraph = CallGraph(name)

        for function in module.iter_functions():
            node = function.get_name()
            node_id = callgraph.addNode(node)
            if not function.is_declaration():
                callees = set()
                for bb in function.iter_basic_blocks():
                    for instruction in bb.iter_instructions():
                        if instruction.is_a_call_inst():
                            callee = instruction.get_called().get_name()
                            #ignore instrinsics and ...
                            if callee and not callee.startswith('llvm.'): # and not callee.startswith('\x01.'):
                                callees.add(callee)
                            #print(instruction.print_value_to_string())
                            #print(instruction.get_called().get_name())
                for callee in callees:
                    callgraph.addEdge(node_id, callee)

        return callgraph


    def __str__(self):
        return "CallGraph {0} with {1} nodes and {2} edges\n".format(self.name, len(self.nodes), len(self.edges))


    def addNode(self, node, id=None):
        """adds the node to graph (if necessary), and returns it's id.

        if you happen to know its id you can set that too (useful for making subgraphs).
        """
        retval = None
        if node not in self.nodes:
            retval = self.id_counter if id is None else id
            self.nodes[node] = retval
            self.id_counter += 1
        else:
            retval = self.nodes[node]
        return retval

    def getNodes(self):
        return set(self.nodes.keys())

    def addEdge(self, source, target):
        """adds the edge from the (id of) source to the (id of) target.

        if the source or target is an integer it is treated as the id,
        if it is a string it is presumed to be the name of a node.
        """
        src_id = source if isinstance(source, int) else self.addNode(source)
        tgt_id = target if isinstance(target, int) else self.addNode(target)
        self.edges.add((src_id, tgt_id))

    def toDotString(self):
        sb = StringBuffer()
        sb.append('digraph ').append(self.name).append(' {\n')
        #sb.append('\tnode [shape=box];\n')
        for node in self.nodes:
            node_id = self.nodes[node]
            sb.append('\t').append(node_id).append(' [label="').append(node).append('"];\n')

        for edge in self.edges:
            sb.append('\t').append(edge[0]).append(' -> ').append(edge[1]).append(';\n')

        sb.append('}\n')
        return str(sb)


    def remove_isolated(self, name):
        subgraph = CallGraph(self.name)
        has_an_edge = set()
        for edge in self.edges:
            has_an_edge.add(edge[0])
            has_an_edge.add(edge[1])

        for node, node_id in self.nodes.iteritems():
            if node_id in has_an_edge:
                subgraph.addNode(node, node_id)

        for edge in self.edges:
            subgraph.addEdge(*edge)

        return subgraph


    def restrict(self, name, nodes):
        """returns a subgraph with given name whose nodes must belong to the given set.

        """
        subgraph = CallGraph(name)

        node_ids = set()

        for node in nodes:
            if node in self.nodes:
                node_id = self.nodes[node]
                node_ids.add(subgraph.addNode(node, node_id))

        for edge in self.edges:
            if (edge[0] in node_ids) and (edge[1] in node_ids):
                subgraph.addEdge(edge[0], edge[1])

        return subgraph
