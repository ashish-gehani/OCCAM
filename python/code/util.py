import llvmcpy.llvm as llvm


def fileToModule(path):
    buffer = llvm.create_memory_buffer_with_contents_of_file(path)
    context = llvm.get_global_context()
    module = context.parse_ir(buffer)
    return module


def file2Array(path):
    retval = []
    try:
        with open(path, 'r') as fp:
            for entry in fp.readlines():
                entry = entry.strip()
                if entry and entry[0] != '#':
                    retval.append(entry)
    except Exception as e:
        sys.stderr.write('file2Array("{0}") threw {1}\n'.format(path, str(e)))
    return retval
