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
declare dso_local i64 @strlen(i8*) local_unnamed_addr #0

; Function Attrs: nounwind readonly
declare dso_local i32 @strncmp(i8*, i8*, i64) local_unnamed_addr #0

declare dso_local i32 @printf(i8*, ...) local_unnamed_addr #1

define i32 @main(i32 %0, i8** nocapture readonly %1) local_unnamed_addr {
  %3 = icmp eq i32 %0, 1
  br i1 %3, label %4, label %19

4:                                                ; preds = %2
  %5 = tail call i8* @malloc(i64 24)
  %6 = bitcast i8* %5 to i8**
  store i8* getelementptr inbounds ([5 x i8], [5 x i8]* @4, i64 0, i64 0), i8** %6, align 8
  %7 = getelementptr i8, i8* %5, i64 8
  %8 = bitcast i8* %7 to i8**
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i64 0, i64 0), i8** %8, align 8
  %9 = getelementptr inbounds i8, i8* %5, i64 16
  %10 = bitcast i8* %9 to i8**
  store i8* null, i8** %10, align 8
  %11 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i64 0, i64 0)) #2
  %12 = tail call i64 @strlen(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @0, i64 0, i64 0)) #2
  %13 = icmp ult i64 %11, %12
  %14 = select i1 %13, i64 %11, i64 %12
  %15 = shl i64 %14, 32
  %16 = ashr exact i64 %15, 32
  %17 = tail call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i64 0, i64 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @0, i64 0, i64 0), i64 %16) #2
  %18 = icmp eq i32 %17, 0
  br i1 %18, label %33, label %20

19:                                               ; preds = %2
  ret i32 1

20:                                               ; preds = %4
  %21 = shl i64 %11, 32
  %22 = ashr exact i64 %21, 32
  %23 = tail call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i64 0, i64 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i64 0, i64 0), i64 %22) #2
  %24 = icmp eq i32 %23, 0
  br i1 %24, label %35, label %25

25:                                               ; preds = %20
  %26 = tail call i64 @strlen(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @2, i64 0, i64 0)) #2
  %27 = icmp ult i64 %11, %26
  %28 = select i1 %27, i64 %11, i64 %26
  %29 = shl i64 %28, 32
  %30 = ashr exact i64 %29, 32
  %31 = tail call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i64 0, i64 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @2, i64 0, i64 0), i64 %30) #2
  %32 = icmp eq i32 %31, 0
  br i1 %32, label %37, label %39

33:                                               ; preds = %4
  ; CHECK: "__occam_spec.add_one(0x5,0x2)"
  %34 = tail call i32 @"__occam_spec.add_one(0x5,0x2)"()
  br label %39

35:                                               ; preds = %20
  ; CHECK: "__occam_spec.add_two(0x5,0x2)"
  %36 = tail call i32 @"__occam_spec.add_two(0x5,0x2)"()
  br label %39

37:                                               ; preds = %25
  ; CHECK: "__occam_spec.add_three(0x5,0x2)"
  %38 = tail call i32 @"__occam_spec.add_three(0x5,0x2)"()
  br label %39

39:                                               ; preds = %33, %37, %35, %25
  %40 = phi i32 [ 0, %25 ], [ %34, %33 ], [ %38, %37 ], [ %36, %35 ]
  %41 = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @3, i64 0, i64 0), i32 %40) #3
  ret i32 %40
}

declare noalias i8* @malloc(i64) local_unnamed_addr

declare i32 @"__occam_spec.add_one(0x5,0x2)"() local_unnamed_addr

declare i32 @"__occam_spec.add_three(0x5,0x2)"() local_unnamed_addr

declare i32 @"__occam_spec.add_two(0x5,0x2)"() local_unnamed_addr

attributes #0 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readonly }
attributes #3 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1}

!0 = !{!"clang version 10.0.0 "}
!1 = !{i32 1, !"wchar_size", i32 4}
