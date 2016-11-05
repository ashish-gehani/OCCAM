import re, sys

#iam: will need to generate the  proto buffer stuff
from proto import Previrt_pb2 as proto


def emptyInterface():
    return proto.ComponentInterface()

def parseInterface(filename):
    result = proto.ComponentInterface()
    if filename == '-':
        result.ParseFromString(sys.stdin.read())
    else:
        result.ParseFromString(open(filename, 'rb').read())
    return result

def writeInterface(iface, filename):
    if type(filename) == type(""):
        if filename == '-':
            f = sys.stdout
        else:
            f = open(filename, 'wb')
    else:
        f = filename
    f.write(iface.SerializeToString())
    f.close()

def mainInterface():
    main = proto.ComponentInterface()
    c = main.calls.add(name='main', count=1)
    c.args.add(type=proto.U)
    c.args.add(type=proto.U)
    main.references.extend('main')

    atexit = main.calls.add(name='atexit', count=1)
    atexit.args.add(type=proto.U)
    main.references.extend('atexit')

    inittls = main.calls.add(name='_init_tls', count=1)
    main.references.extend('_init_tls')

    exitr = main.calls.add(name='exit', count=1)
    exitr.args.add(type=proto.U)
    main.references.extend('exit')

    return main

def joinInterfaces(into, merge):
    result = False
    for mc in merge.calls:
        for c in [c for c in into.calls if c.name == mc.name]:
            if len(mc.args) != len(c.args):
                continue
            if c.args == mc.args:
                c.count += mc.count
                break
        else:
            into.calls.add(name=mc.name,args=mc.args,count=mc.count)
            result = True
    for mr in merge.references:
        if mr in into.references:
            continue
        else:
            into.references.append(mr)
            result = True
    return result

def readInterfaceFromText(f):
    ptrn_rest = r'(?:\s*,\s*(.*))?'
    ptrn_call = re.compile(r'([^(]+)\(([^)]*)\)\s*(?::\s*([0-9]+))?')
    ptrn_int  = re.compile(r'i([0-9]+)\s+([0-9]+)' + ptrn_rest)
    ptrn_str  = re.compile(r'^"((?:[^"\\]|(?:\\"))+)"' + ptrn_rest)
    ptrn_unknown = re.compile(r'^\?' + ptrn_rest)

    result = proto.ComponentInterface()

    for line in [x.strip() for x in f.readlines()]:
        if len(line) == 0:
            continue
        if line.startswith('#'):
            continue
        mtch = ptrn_call.match(line)
        if mtch:
            v = result.calls.add(name=mtch.group(1))
            if mtch.group(3):
                v.count = int(mtch.group(3))
            args = mtch.group(2).strip()
            while args and not args == '':
                args = args.strip()
                m = ptrn_unknown.match(args)
                if m:
                    args.add(type=proto.U)
                    args = m.group(1)
                else:
                    m = ptrn_int.match(args)
                    if m:
                        a = v.args.add(type=proto.I)
                        a.int.value = hex(int(m.group(2)))[2:]
                        a.int.bits = int(m.group(1))
                        args = m.group(3)
                    else:
                        m = ptrn_str.match(args)
                        if m:
                            a = v.args.add(type=proto.S)
                            a.str.data = m.group(1)
                            args = m.group(2)
                        else:
                            assert False
        else:
            print "skipping line '%s'" % line
    return result


