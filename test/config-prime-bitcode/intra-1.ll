; RUN: cd %intra-1 && %intra-1/build.sh
; RUN: %llvm_as < slash/main-final.ll | %llvm_dis | FileCheck %s
; CHECK-NOT: You should not see this message

; ModuleID = 'slash/main-final.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@str.2 = private unnamed_addr constant [28 x i8] c"You should see this message\00", align 1

; Function Attrs: nofree nounwind
define i32 @main(i32 %0, i8** nocapture readonly %1) local_unnamed_addr #0 {
entry:
  %2 = icmp eq i32 %0, 1
  br i1 %2, label %tail, label %incorrect_argc

incorrect_argc:                                   ; preds = %tail, %entry
  %merge = phi i32 [ 1, %entry ], [ 0, %tail ]
  ret i32 %merge

tail:                                             ; preds = %entry
  %puts4 = tail call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([28 x i8], [28 x i8]* @str.2, i64 0, i64 0))
  br label %incorrect_argc
}

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #0

attributes #0 = { nofree nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1}

!0 = !{!"clang version 10.0.0 "}
!1 = !{i32 1, !"wchar_size", i32 4}
