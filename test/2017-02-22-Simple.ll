; RUN: cd %simple &&  %simple/build.sh
; RUN: %llvm_as < %simple/slash/main-final.ll | %llvm_dis | FileCheck %s

; ModuleID = 'slash/main-final.bc'
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.11.0"

%0 = type { i8*, i32, i32, i16, i16, %2, i32, i8*, i32 (i8*)*, i32 (i8*, i8*, i32)*, i64 (i8*, i64, i32)*, i32 (i8*, i8*, i32)*, %2, %1*, i32, [3 x i8], [1 x i8], %2, i32, i64 }
%1 = type opaque
%2 = type { i8*, i32 }

@__stderrp = external global %0*
@0 = private unnamed_addr constant [19 x i8] c"main returning %d\0A\00", align 1
@1 = private constant [5 x i8] c"8181\00"

declare i64 @atol(i8*) #0

declare i32 @fprintf(%0*, i8*, ...) #0

; Function Attrs: nounwind ssp
define i32 @main(i32, i8** nocapture readnone) #1 {
  %3 = tail call i64 @atol(i8* getelementptr inbounds ([5 x i8]* @1, i64 0, i64 0)) #2
  %4 = trunc i64 %3 to i32
  ; CHECK: "libcall(?,0x1)"
  %5 = tail call i32 @"libcall(?,0x1)"(i32 %4) #2
  %6 = tail call i64 @atol(i8* getelementptr inbounds ([5 x i8]* @1, i64 0, i64 0)) #2
  %7 = trunc i64 %6 to i32
  ; CHECK: "libcall(?,0x2)"
  %8 = tail call i32 @"libcall(?,0x2)"(i32 %7) #2
  %9 = mul nsw i32 %8, %5
  %10 = load %0** @__stderrp, align 8
  %11 = tail call i32 (%0*, i8*, ...)* @fprintf(%0* %10, i8* getelementptr inbounds ([19 x i8]* @0, i64 0, i64 0), i32 %9) #2
  ret i32 %9
}

declare i32 @"libcall(?,0x2)"(i32)

declare i32 @"libcall(?,0x1)"(i32)

attributes #0 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind ssp }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
