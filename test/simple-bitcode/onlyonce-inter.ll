; RUN: cd %onlyonce && %onlyonce/build.sh
; RUN: %llvm_as < slash/main-final.ll | %llvm_dis | FileCheck %s

; ModuleID = 'slash/main-final.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [13 x i8] c"%d %d %d %d\0A\00", align 1

declare i32 @libcall1(i32, i32) local_unnamed_addr #0

declare i32 @printf(i8*, ...) local_unnamed_addr #0

; Function Attrs: nounwind
define i32 @main(i32, i8** nocapture readnone) local_unnamed_addr #1 {
  ; CHECK-NOT: "__occam_spec.libcall2(0x1,0x2)"
  %call.i = tail call i32 @libcall1(i32 1, i32 2) #1
  ; CHECK: "__occam_spec.libcall2(0x3,0x4)"
  %call1.i1 = tail call i32 @"__occam_spec.libcall2(0x3,0x4)"() #1
  ; CHECK-NOT: "__occam_spec.libcall2(0x5,0x6)"  
  %call2.i = tail call i32 @libcall1(i32 5, i32 6) #1
  ; CHECK-NOT: "__occam_spec.libcall2(0x7,0x8)"  
  %call3.i = tail call i32 @libcall1(i32 7, i32 8) #1
  %call4.i = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str, i64 0, i64 0), i32 %call.i, i32 %call1.i1, i32 %call2.i, i32 %call3.i) #1
  ret i32 0
}

declare i32 @"__occam_spec.libcall2(0x3,0x4)"() local_unnamed_addr

attributes #0 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1}

!0 = !{!"clang version 5.0.2 (tags/RELEASE_502/final)"}
!1 = !{i32 1, !"wchar_size", i32 4}
