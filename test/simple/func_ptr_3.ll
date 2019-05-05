; RUN: cd %funcs3 &&  %funcs3/build.sh 
; RUN: %llvm_as < %funcs3/slash/main-final.ll | %llvm_dis | FileCheck %s

; ModuleID = 'slash/main-final.bc'
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.11.0"

@0 = private unnamed_addr constant [4 x i8] c"one\00", align 1
@1 = private constant [4 x i8] c"two\00", align 1
@2 = private unnamed_addr constant [6 x i8] c"three\00", align 1
@3 = private unnamed_addr constant [17 x i8] c"Final retval=%d\0A\00", align 1

declare i64 @strlen(i8*) #0

declare i32 @strncmp(i8*, i8*, i64) #0

declare i32 @printf(i8*, ...) #0

; Function Attrs: nounwind ssp
define i32 @main(i32, i8** nocapture readnone) #1 {
  %3 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8]* @1, i64 0, i64 0)) #2
  %4 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8]* @0, i64 0, i64 0)) #2
  %5 = icmp ult i64 %3, %4
  br i1 %5, label %6, label %8

; <label>:6                                       ; preds = %2
  %7 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8]* @1, i64 0, i64 0)) #2
  br label %.exit

; <label>:8                                       ; preds = %2
  %9 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8]* @0, i64 0, i64 0)) #2
  br label %.exit

.exit:                                            ; preds = %8, %6
  %10 = phi i64 [ %7, %6 ], [ %9, %8 ]
  %sext.i = shl i64 %10, 32
  %11 = ashr exact i64 %sext.i, 32
  %12 = tail call i32 @strncmp(i8* getelementptr inbounds ([4 x i8]* @1, i64 0, i64 0), i8* getelementptr inbounds ([4 x i8]* @0, i64 0, i64 0), i64 %11) #2
  %13 = icmp eq i32 %12, 0
  br i1 %13, label %.thread11, label %.exit4

.exit4:                                           ; preds = %.exit
  %14 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8]* @1, i64 0, i64 0)) #2
  %15 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8]* @1, i64 0, i64 0)) #2
  %16 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8]* @1, i64 0, i64 0)) #2
  %sext.i3 = shl i64 %16, 32
  %17 = ashr exact i64 %sext.i3, 32
  %18 = tail call i32 @strncmp(i8* getelementptr inbounds ([4 x i8]* @1, i64 0, i64 0), i8* getelementptr inbounds ([4 x i8]* @1, i64 0, i64 0), i64 %17) #2
  %19 = icmp eq i32 %18, 0
  br i1 %19, label %.thread, label %20

; <label>:20                                      ; preds = %.exit4
  %21 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8]* @1, i64 0, i64 0)) #2
  %22 = tail call i64 @strlen(i8* getelementptr inbounds ([6 x i8]* @2, i64 0, i64 0)) #2
  %23 = icmp ult i64 %21, %22
  br i1 %23, label %24, label %26

; <label>:24                                      ; preds = %20
  %25 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8]* @1, i64 0, i64 0)) #2
  br label %.exit6

; <label>:26                                      ; preds = %20
  %27 = tail call i64 @strlen(i8* getelementptr inbounds ([6 x i8]* @2, i64 0, i64 0)) #2
  br label %.exit6

.exit6:                                           ; preds = %26, %24
  %28 = phi i64 [ %25, %24 ], [ %27, %26 ]
  %sext.i5 = shl i64 %28, 32
  %29 = ashr exact i64 %sext.i5, 32
  %30 = tail call i32 @strncmp(i8* getelementptr inbounds ([4 x i8]* @1, i64 0, i64 0), i8* getelementptr inbounds ([6 x i8]* @2, i64 0, i64 0), i64 %29) #2
  %31 = icmp eq i32 %30, 0
  br i1 %31, label %34, label %.exit7

.thread11:                                        ; preds = %.exit
  ; CHECK: "__occam_spec.add_one(0x5,0x2)"
  %32 = tail call i32 @"__occam_spec.add_one(0x5,0x2)"() #2
  br label %.exit7

.thread:                                          ; preds = %.exit4
  ; CHECK: "__occam_spec.add_two(0x5,0x2)"
  %33 = tail call i32 @"__occam_spec.add_two(0x5,0x2)"() #2
  br label %.exit7

; <label>:34                                      ; preds = %.exit6
  ; CHECK: "__occam_spec.add_three(0x5,0x2)"
  %35 = tail call i32 @"__occam_spec.add_three(0x5,0x2)"() #2
  br label %.exit7

.exit7:                                           ; preds = %34, %.thread, %.thread11, %.exit6
  %.02 = phi i32 [ 0, %.exit6 ], [ %32, %.thread11 ], [ %33, %.thread ], [ %35, %34 ]
  %36 = tail call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([17 x i8]* @3, i64 0, i64 0), i32 %.02) #2
  ret i32 %.02
}


declare i32 @"__occam_spec.add_one(0x5,0x2)"()

declare i32 @"__occam_spec.add_three(0x5,0x2)"()

declare i32 @"__occam_spec.add_two(0x5,0x2)"()

attributes #0 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind ssp }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
