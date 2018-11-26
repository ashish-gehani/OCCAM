; RUN: cd %funcs4 &&  %funcs4/build.sh 
; RUN: %llvm_as < %funcs4/slash/main-final.ll | %llvm_dis | FileCheck %s

; ModuleID = 'slash/main-final.bc'
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.11.0"

@0 = private unnamed_addr constant [21 x i8] c"add_three is called\0A\00", align 1
@1 = private unnamed_addr constant [17 x i8] c"Final retval=%d\0A\00", align 1

declare i32 @printf(i8*, ...) #0

; Function Attrs: nounwind ssp
define i32 @main(i32, i8** nocapture readnone) #1 {
  ; CHECK: main
  ; CHECK-NOT: add_one
  ; CHECK: ret i32

  ; CHECK: "add_three(0x8,0x4)"
  %3 = tail call i32 @"add_three(0x8,0x4)"() #2
  %4 = tail call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([21 x i8]* @0, i64 0, i64 0)) #2
  %5 = tail call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([17 x i8]* @1, i64 0, i64 0), i32 %3) #2
  ret i32 %3
}

declare i32 @"add_three(0x8,0x4)"()

attributes #0 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind ssp }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
