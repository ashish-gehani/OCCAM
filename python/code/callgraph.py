import sys

from stringbuffer import StringBuffer



def isSystemCall(name):
    """returns a tuple consisting of the boolean and the cleaned up name.
    """
    if ord(name[0]) == 1:
        return (True, name[1:])
    else:
        return (False, name)

#I think there ia a LLVM C-API call for this. Maybe also the system call thingy.
def isIntrinsic(name):
    return name.startswith('llvm.')



class Node(object):

    def __init__(self, name, nid, prototype=None):
        self.name = name
        self.nid = nid
        self.prototype = prototype
        self.attributes = {}

    def set_attribute(self, key, val):
        self.attributes[key] = val

    def get_attribute(self, key, default=None):
        self.attributes.get(key, default)

    def toDotString(self, attributes = False):
        cr = r'\n'
        sb = StringBuffer()
        sb.append(self.nid).append(' [label="').append(self.name)
        if attributes:
            if isinstance(attributes, list):
                for key in self.attributes:
                    if key in attributes:
                        sb.append(cr).append(key).append(' = ').append(self.attributes[key])
            else:
                for key in self.attributes:
                    sb.append(cr).append(key).append(' = ').append(self.attributes[key])
        sb.append('"];')
        return str(sb)




class CallGraph(object):

    def __init__(self, gname):
        self.id_counter = 0
        self.gname = gname
        # the maps node_ids to nodes
        self.nid_to_node = {}
        # maps the name to nodes
        self.name_to_node = {}
        # the set of edges
        self.edges = set()
        # maps nodes to the set of edges that they participate in.
        self.nids_to_edges = {}

    @staticmethod
    def fromModule(gname, module, skip_system_calls = False):
        callgraph = CallGraph(gname)

        for function in module.iter_functions():
            name = function.get_name()

            if function.is_declaration():
                continue

            basic_blocks = 0
            instructions = 0

            node = callgraph.addNode(name, None, function.type_of().print_type_to_string())
            node_id = node.nid

            callees = set()
            for bb in function.iter_basic_blocks():
                basic_blocks += 1
                for instruction in bb.iter_instructions():
                    instructions += 1
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

            node.set_attribute('basic_blocks', basic_blocks)
            node.set_attribute('instructions', instructions)

        return callgraph


    def __str__(self):
        return self.graphInfo()


    def graphInfo(self, nodes = None):
        nids = set(self.nid_to_node.keys()) if nodes is None else self.toNidSet(nodes)
        eset = set()
        for e in self.edges:
            if (e[0] in nids) and (e[1] in nids):
                eset.add(e)
        return "CallGraph {0} with {1} nodes and {2} edges\n".format(self.gname, len(nids), len(eset))


    def addNode(self, name, id=None, prototype=None):
        """creates and adds the node to graph (if necessary), and returns it.

        if you happen to know its id you can set that too (useful for making subgraphs).
        """
        node = None
        if name not in self.name_to_node:
            nid = self.id_counter if id is None else id
            node = Node(name, nid, prototype)
            self.name_to_node[name] = node
            self.nids_to_edges[nid] = set()
            self.nid_to_node[nid] = node
            self.id_counter += 1
        else:
            node = self.name_to_node[name]
        return node

    def getNodes(self):
        return set(self.name_to_node.keys())

    def addEdge(self, source, target):
        """adds the edge from the (id of) source to the (id of) target.

        if the source or target is an integer it is treated as the id,
        if it is a string it is presumed to be the name of a node.
        """
        src_id = source if isinstance(source, int) else self.addNode(source).nid
        tgt_id = target if isinstance(target, int) else self.addNode(target).nid
        edge = (src_id, tgt_id)
        self.edges.add(edge)

        self.nids_to_edges[src_id].add(edge)
        self.nids_to_edges[tgt_id].add(edge)


        return edge


    def toDotString(self, nodes = None, attributes = False):
        """produces the dot for either the entire graph, or just restricted to the nodes passed in.
        """
        nids = set(self.nid_to_node.keys()) if nodes is None else self.toNidSet(nodes)

        sb = StringBuffer()
        sb.append('digraph ').append(self.gname).append(' {\n')
        #sb.append('\tnode [shape=box];\n')
        for name in self.name_to_node:
            node = self.name_to_node[name]
            node_id = node.nid
            if node_id not in nids:
                continue
            sb.append('\t').append(node.toDotString(attributes)).append('\n')

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

    def annotate(self, annotation, mapping):
        for name in mapping.keys():
            node = self.name_to_node.get(name, None)
            if node is not None:
                val = mapping[name]
                #print('node: {0} annotation: {1} value: {2}'.format(name, annotation, val))
                node.attributes[annotation] = val
            else:
                sys.stderr.write("skipping {0}\n".format(name))



    def remove_isolated(self, name):
        subgraph = CallGraph(self.name)
        has_an_edge = set()
        for edge in self.edges:
            has_an_edge.add(edge[0])
            has_an_edge.add(edge[1])

        for node, node_id in self.name_to_node.iteritems():
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
            if node in self.name_to_node:
                node_id = self.name_to_node[node]
                node_ids.add(subgraph.addNode(node, node_id).nid)

        for edge in self.edges:
            if (edge[0] in node_ids) and (edge[1] in node_ids):
                subgraph.addEdge(edge[0], edge[1])

        return subgraph



    def toNidSet(self, nodes):
        """converts an iterable of nodes (name, node, or nid) to a set of node ids."""
        answer = set()
        for node in nodes:
            if isinstance(node, Node):
                answer.add(node.nid)
            elif isinstance(node, int):
                answer.add(node)
            elif node in self.name_to_node:
                answer.add(self.name_to_node[node].nid)
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
                candidates = self.nids_to_edges[nid]
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
                candidates = self.nids_to_edges[nid]
                for e in candidates:
                    if e[0] == nid:
                        answer.add(e[1])
            after = len(answer)
            new = after > before
        return answer


    def dump_prototypes(self, path, nids = None):

        nids = set(self.nid_to_node.keys()) if nids is None else nids

        try:
            with open(path, 'w') as fp:
                for nid in nids:
                    node = self.nid_to_node[nid]
                    if node.prototype is not None:
                        fp.write(node.name)
                        fp.write(" :  ")
                        fp.write(node.prototype)
                        fp.write("\n")
        except Exception as e:
            print(e)
            sys.stderr.write('dump_prototypes("{0}") threw {1}\n'.format(path, str(e)))
