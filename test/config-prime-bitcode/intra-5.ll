; RUN: cd %intra-5 && %intra-5/build.sh
; RUN: %llvm_as < slash/main-final.ll | %llvm_dis | FileCheck %s
; CHECK-NOT: You should not see this message
