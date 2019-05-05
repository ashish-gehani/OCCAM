;; build.sh relies on relative paths so that's why we don't run
;; directly %multiple/build.sh.
;
; RUN: cd %multiple &&  %multiple/build.sh 
; RUN: %llvm_as < %multiple/slash/main-final.ll | %llvm_dis | FileCheck %s

; ModuleID = 'slash/main-final.bc'
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.11.0"

%0 = type { i8*, i32, i32, i16, i16, %2, i32, i8*, i32 (i8*)*, i32 (i8*, i8*, i32)*, i64 (i8*, i64, i32)*, i32 (i8*, i8*, i32)*, %2, %1*, i32, [3 x i8], [1 x i8], %2, i32, i64 }
%1 = type opaque
%2 = type { i8*, i32 }

@global2 = external global i32
@__stderrp = external global %0*
@0 = private unnamed_addr constant [19 x i8] c"main returning %d\0A\00", align 1
@1 = private constant [5 x i8] c"8181\00"

declare i32 @libcall_int(i32, i32) #0

declare i64 @atol(i8*) #0

declare i64 @strlen(i8*) #0

declare i32 @libcall_global_pointer(i32, i8*) #0

declare i32 @fprintf(%0*, i8*, ...) #0

; Function Attrs: nounwind ssp
define i32 @main(i32, i8** nocapture readnone) #1 {
  %3 = tail call i64 @atol(i8* getelementptr inbounds ([5 x i8]* @1, i64 0, i64 0)) #2
  %4 = trunc i64 %3 to i32
  ; CHECK: "__occam_spec.libcall_int(0x1,?)"
  %5 = tail call i32 @"__occam_spec.libcall_int(0x1,?)"(i32 %4) #2
  %6 = tail call i64 @atol(i8* getelementptr inbounds ([5 x i8]* @1, i64 0, i64 0)) #2
  %7 = trunc i64 %6 to i32
  ; CHECK: "__occam_spec.libcall_int(0x2,?)"
  %8 = tail call i32 @"__occam_spec.libcall_int(0x2,?)"(i32 %7) #2
  %9 = mul nsw i32 %8, %5
  %10 = tail call i64 @atol(i8* getelementptr inbounds ([5 x i8]* @1, i64 0, i64 0)) #2
  %11 = trunc i64 %10 to i32
  ; CHECK: "__occam_spec.libcall_int(0x29A,?)"
  %12 = tail call i32 @"__occam_spec.libcall_int(0x29A,?)"(i32 %11) #2
  %13 = mul nsw i32 %9, %12
  %14 = load i32* @global2, align 4
  %15 = tail call i64 @atol(i8* getelementptr inbounds ([5 x i8]* @1, i64 0, i64 0)) #2
  %16 = trunc i64 %15 to i32
  %17 = tail call i32 @libcall_int(i32 %14, i32 %16) #2
  %18 = mul nsw i32 %13, %17
  %19 = tail call i64 @strlen(i8* getelementptr inbounds ([5 x i8]* @1, i64 0, i64 0)) #2
  %20 = trunc i64 %19 to i32
  ; CHECK: "__occam_spec.libcall_float(?,0x1p-1)"
  %21 = tail call i32 @"__occam_spec.libcall_float(?,0x1p-1)"(i32 %20) #2
  %22 = mul nsw i32 %18, %21
  %23 = tail call i64 @strlen(i8* getelementptr inbounds ([5 x i8]* @1, i64 0, i64 0)) #2
  %24 = trunc i64 %23 to i32
  ; CHECK: "__occam_spec.libcall_double(?,0x1.8p-1)"
  %25 = tail call i32 @"__occam_spec.libcall_double(?,0x1.8p-1)"(i32 %24) #2
  %26 = mul nsw i32 %22, %25
  ; CHECK: "__occam_spec.libcall_null_pointer(0x4,null)"
  %27 = tail call i32 @"__occam_spec.libcall_null_pointer(0x4,null)"() #2
  %28 = mul nsw i32 %26, %27
  ; CHECK: "__occam_spec.libcall_string(0x5,S:B9A)"
  %29 = tail call i32 @"__occam_spec.libcall_string(0x5,S:B9A)"() #2
  %30 = mul nsw i32 %28, %29
  %31 = tail call i64 @strlen(i8* getelementptr inbounds ([5 x i8]* @1, i64 0, i64 0)) #2
  %32 = trunc i64 %31 to i32
  %33 = tail call i32 @libcall_global_pointer(i32 %32, i8* bitcast (i32 (i32, i8*)* @libcall_global_pointer to i8*)) #2
  %34 = mul nsw i32 %30, %33
  %35 = tail call i64 @strlen(i8* getelementptr inbounds ([5 x i8]* @1, i64 0, i64 0)) #2
  %36 = trunc i64 %35 to i32
  %37 = tail call i32 @libcall_global_pointer(i32 %36, i8* null) #2
  %38 = load %0** @__stderrp, align 8
  %39 = tail call i32 (%0*, i8*, ...)* @fprintf(%0* %38, i8* getelementptr inbounds ([19 x i8]* @0, i64 0, i64 0), i32 %34) #2
  ret i32 %34
}

declare i32 @"__occam_spec.libcall_double(?,0x1.8p-1)"(i32)

declare i32 @"__occam_spec.libcall_float(?,0x1p-1)"(i32)

declare i32 @"__occam_spec.libcall_int(0x29A,?)"(i32)

declare i32 @"__occam_spec.libcall_int(0x2,?)"(i32)

declare i32 @"__occam_spec.libcall_int(0x1,?)"(i32)

declare i32 @"__occam_spec.libcall_null_pointer(0x4,null)"()

declare i32 @"__occam_spec.libcall_string(0x5,S:B9A)"()

attributes #0 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind ssp }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
