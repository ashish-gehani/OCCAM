; RUN: cd %funcs14 &&  %funcs14/build.sh
; RUN: %llvm_as < %funcs14/slash/main.o-final.ll | %llvm_dis | FileCheck %s

; ModuleID = 'slash/main.o-final.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@_fun1 = common dso_local local_unnamed_addr global i32 (i32)* null, align 8
@_fun2 = common dso_local local_unnamed_addr global i32 (i32)* null, align 8
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define internal fastcc i32 @nd_int() unnamed_addr #0 {
  %1 = tail call i64 @time(i64* null) #5
  %2 = trunc i64 %1 to i32
  tail call void @srand(i32 %2) #5
  %3 = tail call i32 @rand() #5
  ret i32 %3
}

; Function Attrs: nounwind
declare dso_local i64 @time(i64*) local_unnamed_addr #1

; Function Attrs: nounwind
declare dso_local void @srand(i32) local_unnamed_addr #1

; Function Attrs: nounwind
declare dso_local i32 @rand() local_unnamed_addr #1

; Function Attrs: noinline norecurse nounwind readnone uwtable
define dso_local i32 @incr(i32 %0) #2 {
  %2 = add nsw i32 %0, 1
  ret i32 %2
}

; Function Attrs: noinline norecurse nounwind readnone uwtable
define dso_local i32 @decr(i32 %0) #2 {
  %2 = add nsw i32 %0, -1
  ret i32 %2
}

; Function Attrs: noinline norecurse nounwind readnone uwtable
define dso_local i32 @square(i32 %0) #2 {
  %2 = mul nsw i32 %0, %0
  ret i32 %2
}

; Function Attrs: noinline nounwind uwtable
define internal fastcc void @init() unnamed_addr #0 {
  br label %1

1:                                                ; preds = %1, %0
  %2 = tail call fastcc i32 @nd_int()
  %3 = icmp eq i32 %2, 0
  br i1 %3, label %4, label %1

4:                                                ; preds = %1
  %5 = tail call fastcc i32 @nd_int()
  %6 = icmp eq i32 %5, 0
  %decr.incr = select i1 %6, i32 (i32)* @decr, i32 (i32)* @incr
  store i32 (i32)* %decr.incr, i32 (i32)** @_fun1, align 8
  store i32 (i32)* @square, i32 (i32)** @_fun2, align 8
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #0 {
if.end.specialize_funcptr:
  tail call fastcc void @init()
  %0 = tail call i32 @square(i32 7) #5
  %1 = load i32 (i32)*, i32 (i32)** @_fun1, align 8
  %2 = icmp eq i32 (i32)* %1, @incr
  br i1 %2, label %if.false.specialize_funcptr, label %if.true.specialize_funcptr

if.true.specialize_funcptr:                       ; preds = %if.end.specialize_funcptr
  ; CHECK: "__occam_spec.execute_call(decr,0x5)"
  %3 = tail call i32 @"__occam_spec.execute_call(decr,0x5)"() #5
  br label %if.end.specialize_funcptr1

if.false.specialize_funcptr:                      ; preds = %if.end.specialize_funcptr
  ; CHECK: "__occam_spec.execute_call(incr,0x5)"
  %4 = tail call i32 @"__occam_spec.execute_call(incr,0x5)"() #5
  br label %if.end.specialize_funcptr1

if.end.specialize_funcptr1:                       ; preds = %if.false.specialize_funcptr, %if.true.specialize_funcptr
  %5 = phi i32 [ %4, %if.false.specialize_funcptr ], [ %3, %if.true.specialize_funcptr ]
  %6 = add nsw i32 %5, %0
  %7 = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %6) #5
  ret i32 0
}

declare dso_local i32 @printf(i8*, ...) local_unnamed_addr #3

declare i32 @"__occam_spec.execute_call(incr,0x5)"() local_unnamed_addr

; Function Attrs: alwaysinline norecurse nounwind readnone uwtable
define dso_local i32 @"__occam_spec.incr(0x5)"() local_unnamed_addr #4 {
  ret i32 6
}

declare i32 @"__occam_spec.execute_call(decr,0x5)"() local_unnamed_addr

; Function Attrs: alwaysinline norecurse nounwind readnone uwtable
define dso_local i32 @"__occam_spec.decr(0x5)"() local_unnamed_addr #4 {
  ret i32 4
}

attributes #0 = { noinline nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline norecurse nounwind readnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { alwaysinline norecurse nounwind readnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1}

!0 = !{!"clang version 10.0.0 "}
!1 = !{i32 1, !"wchar_size", i32 4}
