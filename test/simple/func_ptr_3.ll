; RUN: cd %funcs3 &&  %funcs3/build.sh 
; RUN: %llvm_as < %funcs3/slash/main-final.ll | %llvm_dis | FileCheck %s

; ModuleID = 'slash/main-final.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@0 = private unnamed_addr constant [4 x i8] c"one\00", align 1
@1 = private constant [4 x i8] c"two\00", align 1
@2 = private unnamed_addr constant [6 x i8] c"three\00", align 1
@3 = private unnamed_addr constant [17 x i8] c"Final retval=%d\0A\00", align 1
@4 = private constant [5 x i8] c"main\00"

; Function Attrs: nounwind readonly
declare i64 @strlen(i8*) local_unnamed_addr #0

; Function Attrs: nounwind readonly
declare i32 @strncmp(i8*, i8*, i64) local_unnamed_addr #0

declare i32 @printf(i8*, ...) local_unnamed_addr #1

define i32 @main(i32 %0, i8** nocapture readnone %1) local_unnamed_addr {
  %3 = tail call i8* @malloc(i64 16)
  %4 = bitcast i8* %3 to i8**
  store i8* getelementptr inbounds ([5 x i8], [5 x i8]* @4, i64 0, i64 0), i8** %4, align 8
  %5 = getelementptr i8, i8* %3, i64 8
  %6 = bitcast i8* %5 to i8**
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i64 0, i64 0), i8** %6, align 8
  %7 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i64 0, i64 0)) #2
  %8 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @0, i64 0, i64 0)) #2
  %9 = icmp ult i64 %7, %8
  %10 = select i1 %9, i64 %7, i64 %8
  %11 = shl i64 %10, 32
  %12 = ashr exact i64 %11, 32
  %13 = tail call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i64 0, i64 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @0, i64 0, i64 0), i64 %12) #2
  %14 = icmp eq i32 %13, 0
  br i1 %14, label %32, label %15

15:                                               ; preds = %2
  %16 = shl i64 %7, 32
  %17 = ashr exact i64 %16, 32
  %18 = tail call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i64 0, i64 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i64 0, i64 0), i64 %17) #2
  %19 = icmp eq i32 %18, 0
  br i1 %19, label %30, label %20

20:                                               ; preds = %15
  %21 = tail call i64 @strlen(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @2, i64 0, i64 0)) #2
  %22 = icmp ult i64 %7, %21
  %23 = select i1 %22, i64 %7, i64 %21
  %24 = shl i64 %23, 32
  %25 = ashr exact i64 %24, 32
  %26 = tail call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i64 0, i64 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @2, i64 0, i64 0), i64 %25) #2
  %27 = icmp eq i32 %26, 0
  br i1 %27, label %28, label %34

28:                                               ; preds = %20
  ; CHECK: "__occam_spec.add_three(0x5,0x2)"
  %29 = tail call i32 @"__occam_spec.add_three(0x5,0x2)"()
  br label %34

30:                                               ; preds = %15
  ; CHECK: "__occam_spec.add_two(0x5,0x2)"
  %31 = tail call i32 @"__occam_spec.add_two(0x5,0x2)"()
  br label %34

32:                                               ; preds = %2
  ; CHECK: "__occam_spec.add_one(0x5,0x2)"
  %33 = tail call i32 @"__occam_spec.add_one(0x5,0x2)"()
  br label %34

34:                                               ; preds = %28, %30, %32, %20
  %35 = phi i32 [ 0, %20 ], [ %29, %28 ], [ %31, %30 ], [ %33, %32 ]
  %36 = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @3, i64 0, i64 0), i32 %35) #3
  ret i32 %35
}

declare noalias i8* @malloc(i64) local_unnamed_addr

declare i32 @"__occam_spec.add_one(0x5,0x2)"() local_unnamed_addr

declare i32 @"__occam_spec.add_three(0x5,0x2)"() local_unnamed_addr

declare i32 @"__occam_spec.add_two(0x5,0x2)"() local_unnamed_addr

attributes #0 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readonly }
attributes #3 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1}

!0 = !{!"clang version 5.0.2 (tags/RELEASE_502/final)"}
!1 = !{i32 1, !"wchar_size", i32 4}
