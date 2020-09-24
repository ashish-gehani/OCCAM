#pragma once

namespace llvm {
class Module;
class Function;
template <typename PtrType, unsigned SmallSize> class SmallPtrSet;
}

namespace previrt {
namespace utils {

// Force to inline a function only if it belongs to inlined_functions.
bool inlineOnly(llvm::Module &M,
                const llvm::SmallPtrSet<llvm::Function *, 8> &inline_functions);
}
}
