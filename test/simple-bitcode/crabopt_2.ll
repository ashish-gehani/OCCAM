; RUN: cd %crabopt/2 &&  ./build.sh 
; RUN: %llvm_as < %crabopt/2/slash/main-final.ll | %llvm_dis | FileCheck %s

; ModuleID = 'slash/main-final.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@fun_ptr = internal unnamed_addr global void (i32)* @fun3, align 8
@.str = private unnamed_addr constant [18 x i8] c"Value of a is %d\0A\00", align 1

; Function Attrs: nofree nounwind uwtable
define dso_local void @fun3(i32 %arg) #0 {
_2:
  unreachable
}

; Function Attrs: nofree nounwind
declare dso_local i32 @printf(i8* nocapture readonly, ...) local_unnamed_addr #1

; Function Attrs: nounwind
declare dso_local i64 @time(i64*) local_unnamed_addr #2

; Function Attrs: nounwind
declare dso_local void @srand(i32) local_unnamed_addr #2

; Function Attrs: nounwind
declare dso_local i32 @rand() local_unnamed_addr #2

; Function Attrs: nofree nounwind uwtable
define dso_local void @fun1(i32 %arg) #0 {
_2:
  %_ret = tail call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([18 x i8], [18 x i8]* @.str, i64 0, i64 0), i32 %arg)
  ret void
}

; Function Attrs: nofree nounwind uwtable
define dso_local void @fun2(i32 %arg) #0 {
_2:
  %_3 = add nsw i32 %arg, 1
  %_ret = tail call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([18 x i8], [18 x i8]* @.str, i64 0, i64 0), i32 %_3)
  ret void
}

; Function Attrs: nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #3 {
; CHECK: main
_1:
  %_2 = tail call i64 @time(i64* null) #4
  %_tail = trunc i64 %_2 to i32
  tail call void @srand(i32 %_tail) #4
  %_4 = tail call i32 @rand() #4
  %_br = icmp slt i32 %_4, 0
  br i1 %_br, label %_ret, label %_6

_6:                                               ; preds = %_1
  %_7 = icmp eq i32 %_4, 0
  %_store = select i1 %_7, void (i32)* @fun2, void (i32)* @fun1
  store void (i32)* %_store, void (i32)** @fun_ptr, align 8, !tbaa !2
  br i1 %_7, label %if.true.direct_targ1, label %if.true.direct_targ

if.true.direct_targ:                              ; preds = %_6
  tail call void @fun1(i32 %_4) #4
  br label %_ret

if.true.direct_targ1:                             ; preds = %_6
  tail call void @fun2(i32 %_4) #4
  br label %_ret

_ret:                                             ; preds = %if.true.direct_targ1, %if.true.direct_targ, %_1
  ret i32 0
  ; CHECK-NOT: fun3
}

attributes #0 = { nofree nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1}

!0 = !{!"clang version 10.0.0 "}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{!3, !3, i64 0}
!3 = !{!"any pointer", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
