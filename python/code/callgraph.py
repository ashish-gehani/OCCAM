

from stringbuffer import StringBuffer

class CallGraph(object):

    def __init__(self, name):
        self.id_counter = 0
        self.name = name
        # maps the name to id
        self.nodes = {}
        self.edges = set()

    def __str__(self):
        return "CallGraph {0} with {1} nodes and {2} edges\n".format(self.name, len(self.nodes), len(self.edges))


    def addNode(self, node):
        """adds the node to graph (if necessary), and returns it's id.
        """
        retval = None
        if node not in self.nodes:
            retval = self.id_counter
            self.nodes[node] = retval
            self.id_counter += 1
        else:
            retval = self.nodes[node]
        return retval


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
