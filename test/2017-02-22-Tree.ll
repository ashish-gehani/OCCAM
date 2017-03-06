; RUN: cd %tree &&  %tree/build.sh
; RUN: %llvm_as < %tree/slash/main.o-final.ll | %llvm_dis | FileCheck %s

; ModuleID = 'slash/main.o-final.bc'
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.11.0"

%0 = type { i8*, i32, i32, i16, i16, %2, i32, i8*, i32 (i8*)*, i32 (i8*, i8*, i32)*, i64 (i8*, i64, i32)*, i32 (i8*, i8*, i32)*, %2, %1*, i32, [3 x i8], [1 x i8], %2, i32, i64 }
%1 = type opaque
%2 = type { i8*, i32 }

@__stderrp = external global %0*
@0 = private unnamed_addr constant [19 x i8] c"main returning %d\0A\00", align 1
@1 = private constant [5 x i8] c"8181\00"

; Function Attrs: alwaysinline nounwind ssp uwtable
define private i32 @2(i32, i8** nocapture readonly) #0 {
  %3 = icmp eq i32 %0, 2
  br i1 %3, label %6, label %4

; <label>:4                                       ; preds = %2
  %5 = tail call i32 @libcall(i32 %0, i32 %0) #3
  br label %23

; <label>:6                                       ; preds = %2
  %7 = getelementptr inbounds i8** %1, i64 1
  %8 = load i8** %7, align 8
  %9 = tail call i64 @atol(i8* %8) #3
  %10 = trunc i64 %9 to i32
  ; CHECK: "libcall(?,0x1)"
  %11 = tail call i32 @"libcall(?,0x1)"(i32 %10) #3
  %12 = load i8** %7, align 8
  %13 = tail call i64 @atol(i8* %12) #3
  %14 = trunc i64 %13 to i32
  ; CHECK: "libcall(?,0x2)"    
  %15 = tail call i32 @"libcall(?,0x2)"(i32 %14) #3
  %16 = mul nsw i32 %15, %11
  ; CHECK: "internal_api(0x3,?,S:B9A)"
  %17 = tail call i32 @"internal_api(0x3,?,S:B9A)"(i8* bitcast (i32 (i32, i8**)* @2 to i8*)) #3
  %18 = mul nsw i32 %16, %17
  ; CHECK: "internal_api(0x4,null,?)"
  %19 = tail call i32 @"internal_api(0x4,null,?)"(i8* bitcast (i32 (i32, i8**)* @2 to i8*)) #3
  %20 = mul nsw i32 %18, %19
  ; CHECK: "internal_api(0x5,?,?)"
  %21 = tail call i32 @"internal_api(0x5,?,?)"(i8* bitcast (i32 (i32, i8**)* @2 to i8*), i8* bitcast (i32 (i32, i8**)* @2 to i8*)) #3
  %22 = mul nsw i32 %20, %21
  br label %23

; <label>:23                                      ; preds = %6, %4
  %.0 = phi i32 [ %5, %4 ], [ %22, %6 ]
  %24 = load %0** @__stderrp, align 8
  %25 = tail call i32 (%0*, i8*, ...)* @fprintf(%0* %24, i8* getelementptr inbounds ([19 x i8]* @0, i64 0, i64 0), i32 %.0) #3
  ret i32 %.0
}

declare i32 @libcall(i32, i32) #1

declare i64 @atol(i8*) #1

declare i32 @fprintf(%0*, i8*, ...) #1

; Function Attrs: nounwind ssp
define i32 @main(i32, i8** nocapture readnone) #2 {
  %3 = tail call i64 @atol(i8* getelementptr inbounds ([5 x i8]* @1, i64 0, i64 0)) #3
  %4 = trunc i64 %3 to i32
  %5 = tail call i32 @"libcall(?,0x1)"(i32 %4) #3
  %6 = tail call i64 @atol(i8* getelementptr inbounds ([5 x i8]* @1, i64 0, i64 0)) #3
  %7 = trunc i64 %6 to i32
  %8 = tail call i32 @"libcall(?,0x2)"(i32 %7) #3
  %9 = mul nsw i32 %8, %5
  %10 = tail call i32 @"internal_api(0x3,?,S:B9A)"(i8* bitcast (i32 (i32, i8**)* @2 to i8*)) #3
  %11 = mul nsw i32 %9, %10
  %12 = tail call i32 @"internal_api(0x4,null,?)"(i8* bitcast (i32 (i32, i8**)* @2 to i8*)) #3
  %13 = mul nsw i32 %11, %12
  %14 = tail call i32 @"internal_api(0x5,?,?)"(i8* bitcast (i32 (i32, i8**)* @2 to i8*), i8* bitcast (i32 (i32, i8**)* @2 to i8*)) #3
  %15 = mul nsw i32 %13, %14
  %16 = load %0** @__stderrp, align 8
  %17 = tail call i32 (%0*, i8*, ...)* @fprintf(%0* %16, i8* getelementptr inbounds ([19 x i8]* @0, i64 0, i64 0), i32 %15) #3
  ret i32 %15
}

declare i32 @"internal_api(0x5,?,?)"(i8*, i8*)

declare i32 @"internal_api(0x4,null,?)"(i8*)

declare i32 @"internal_api(0x3,?,S:B9A)"(i8*)

declare i32 @"libcall(?,0x2)"(i32)

declare i32 @"libcall(?,0x1)"(i32)

attributes #0 = { alwaysinline nounwind ssp uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind ssp }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
