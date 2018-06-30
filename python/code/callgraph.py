import sys

from stringbuffer import StringBuffer


def isSystemCall(name):
    """returns a tuple consisting of the boolean and the cleaned up name.
    """
    if name and ord(name[0]) == 1:
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

    def toDotString(self, attributes = False, fill = None):
        cr = r'\n'
        sb = StringBuffer()
        has_attribute = False
        highlight = 'yellow'
        sb.append(self.nid).append(' [label="').append(self.name)
        if attributes:
            if isinstance(attributes, list):
                for key in self.attributes:
                    if key in attributes:
                        has_attribute = True
                        sb.append(cr).append(key).append(' = ').append(self.attributes[key])
            else:
                for key in self.attributes:
                    #has_attribute = True
                    sb.append(cr).append(key).append(' = ').append(self.attributes[key])
        sb.append('"')
        if fill:
            sb.append(', color=').append(fill).append(',style=filled')
        elif has_attribute:
            sb.append(', color=').append(highlight).append(',style=filled')

        sb.append('];')
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
        # set of externals
        self.declarations = set()
        # what to do here?
        self.calls = 0
        self.indirect_calls = 0
        self.bitcasts = 0

    @staticmethod
    def fromModule(gname, module, skip_system_calls = False):
        callgraph = CallGraph(gname)


        def resolve_callee(call_inst):
            """Tries to resolve the function called in the call instruction, returns None if it can't."""
            callee = None
            called = instruction.get_called()
            fname = called.get_name()
            if fname:
                callee = fname
            elif called.is_a_load_inst():
                #print("No callee name: LOAD")
                callgraph.indirect_calls += 1
            elif called.is_a_bit_cast_inst():
                #print("No callee name: BITCAST")
                callgraph.bitcasts += 1
            elif called.is_a_constant():
                opcode = called.get_const_opcode()
                assert(opcode == 41) #is there a llvmcpy constant for this? what happened to all the enums?
                nops = called.get_num_operands()
                assert(nops == 1)
                callee = called.get_operand(0).get_name()
            else:
                print("No callee name: unhandled case")
                asssert(False)
                #print("Called: ", called)
                #print("Called: ", called.print_value_to_string())
                #print("Instr: ", instruction.print_value_to_string())
                pass

            return callee



        for function in module.iter_functions():

            name = function.get_name()

            (isSysCall, name) = isSystemCall(name)

            node = callgraph.addNode(name, None, function.type_of().print_type_to_string())
            node_id = node.nid

            if function.is_declaration():
                callgraph.declarations.add(node.nid)
                continue

            basic_blocks = 0
            instructions = 0


            callees = set()
            for bb in function.iter_basic_blocks():
                basic_blocks += 1
                for instruction in bb.iter_instructions():
                    instructions += 1
                    if instruction.is_a_call_inst():
                        callgraph.calls += 1
                        #print(instruction.print_value_to_string())
                        #print(instruction.get_called().get_name())
                        callee = resolve_callee(instruction)
                        (isSysCall, callee) = isSystemCall(callee)
                        #ignore instrinsics and ...
                        if callee and not isIntrinsic(callee):
                            if not (skip_system_calls and isSysCall):
                                callees.add(callee)

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
        statistics = (self.gname, len(nids), len(eset), self.calls, self.indirect_calls + self.bitcasts)
        return "CallGraph {0} with {1} nodes and {2} edges.\t({3} calls, {4} unresolved calls)\n".format(*statistics)


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

    def getNodes(self, nids=None):

        if nids is None:
            return set(self.name_to_node.keys())
        else:
            retval = set()
            for nid in nids:
                retval.add(self.nid_to_node[nid].name)
            return retval

    def getNIDs(self):
        return set(self.nid_to_node.keys())

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


    def toDotString(self, nodes = None, attributes = False, highlights = None, fill = None):
        """produces the dot for either the entire graph, or just restricted to the nodes passed in.
        """

        highighted_nids = set() if highlights is None else self.toNidSet(highlights)

        nids = set(self.nid_to_node.keys()) if nodes is None else self.toNidSet(nodes)

        sb = StringBuffer()
        sb.append('digraph ').append(self.gname).append(' {\n')
        #sb.append('\tnode [shape=box];\n')
        for name in self.name_to_node:
            node = self.name_to_node[name]
            node_id = node.nid
            if node_id not in nids:
                continue
            if fill and (node_id in highighted_nids):
                sb.append('\t').append(node.toDotString(attributes, fill)).append('\n')
            else:
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
