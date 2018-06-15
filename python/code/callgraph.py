

from stringbuffer import StringBuffer



def isSystemCall(name):
    """returns a tuple consisting of the boolean and the cleaned up name.
    """
    if ord(name[0]) == 1:
        return (True, name[1:])
    else:
        return (False, name)

def isIntrinsic(name):
    return name.startswith('llvm.')



class CallGraph(object):

    def __init__(self, name):
        self.id_counter = 0
        self.name = name
        # the set of node_ids
        self.nids = set()
        # maps the name to id
        self.nodes = {}
        # the set of edges
        self.edges = set()
        # maps nodes to the set of edges that they participate in.
        self.nodes_to_edges = {}

    @staticmethod
    def fromModule(name, module, skip_system_calls = False):
        callgraph = CallGraph(name)

        for function in module.iter_functions():
            node = function.get_name()

            if function.is_declaration():
                continue

            node_id = callgraph.addNode(node)
            if not function.is_declaration():
                callees = set()
                for bb in function.iter_basic_blocks():
                    for instruction in bb.iter_instructions():
                        if instruction.is_a_call_inst():
                            fname = instruction.get_called().get_name()
                            if fname:
                                (isSysCall, callee) = isSystemCall(fname)
                                #ignore instrinsics and ...
                                if callee and not isIntrinsic(callee):
                                    if not (skip_system_calls and isSysCall):
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
        nid = None
        if node not in self.nodes:
            nid = self.id_counter if id is None else id
            self.nodes[node] = nid
            self.nodes_to_edges[nid] = set()
            self.nids.add(nid)
            self.id_counter += 1
        else:
            nid = self.nodes[node]
        return nid

    def getNodes(self):
        return set(self.nodes.keys())

    def addEdge(self, source, target):
        """adds the edge from the (id of) source to the (id of) target.

        if the source or target is an integer it is treated as the id,
        if it is a string it is presumed to be the name of a node.
        """
        src_id = source if isinstance(source, int) else self.addNode(source)
        tgt_id = target if isinstance(target, int) else self.addNode(target)
        edge = (src_id, tgt_id)
        self.edges.add(edge)

        self.nodes_to_edges[src_id].add(edge)
        self.nodes_to_edges[tgt_id].add(edge)


        return edge


    def toDotString(self, nodes = None):
        """produces the dot for either the entire graph, or just restricted to the nodes passed in.
        """
        nids = self.nids if nodes is None else self.toNidSet(nodes)

        sb = StringBuffer()
        sb.append('digraph ').append(self.name).append(' {\n')
        #sb.append('\tnode [shape=box];\n')
        for node in self.nodes:
            node_id = self.nodes[node]
            if node_id not in nids:
                continue
            sb.append('\t').append(node_id).append(' [label="').append(node).append('"];\n')

        for edge in self.edges:
            src_id = edge[0]
            tgt_id = edge[1]
            if src_id not in nids:
                continue
            if tgt_id not in nids:
                continue
            sb.append('\t').append(src_id).append(' -> ').append(tgt_id).append(';\n')

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



    def toNidSet(self, nodes):
        answer = set()
        for node in nodes:
            if isinstance(node, int):
                answer.add(node)
            elif node in self.nodes:
                answer.add(self.nodes[node])
#            else:
#                print("Skipping {0}".format(node))
        return answer


    def close_up(self, nodes):
        # first convert the input to nids (if necessary).
        answer = self.toNidSet(nodes)
        new = True
        while new:
            before = len(answer)
            for nid in answer.copy():
                candidates = self.nodes_to_edges[nid]
                for e in candidates:
                    if e[1] == nid:
                        answer.add(e[0])
            after = len(answer)
            new = after > before
        return answer


    def close_down(self, nodes):
        # first convert the input to nids (if necessary).
        answer = self.toNidSet(nodes)
        new = True
        while new:
            before = len(answer)
            for nid in answer.copy():
                candidates = self.nodes_to_edges[nid]
                for e in candidates:
                    if e[0] == nid:
                        answer.add(e[1])
            after = len(answer)
            new = after > before
        return answer
