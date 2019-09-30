; RUN: cd %funcs10 &&  %funcs10/build.sh
; RUN: %llvm_as < %funcs10/slash/main.o-final.ll | %llvm_dis | FileCheck %s

; ModuleID = 'slash/main.o-final.bc'
source_filename = "llvm-link"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@.str = private unnamed_addr constant [29 x i8] c"you should see this message\0A\00", align 1
@.str.1 = private unnamed_addr constant [33 x i8] c"you should NOT see this message\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() local_unnamed_addr #0 {
  ; CHECK: "__occam_spec.execute_call(incr,0x5)"
  %1 = tail call i32 @"__occam_spec.execute_call(incr,0x5)"() #3
  %2 = icmp eq i32 %1, 6
  br i1 %2, label %3, label %5

; <label>:3:                                      ; preds = %0
  %4 = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str, i64 0, i64 0)) #3
  br label %7

; <label>:5:                                      ; preds = %0
  %6 = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.1, i64 0, i64 0)) #3
  br label %7

; <label>:7:                                      ; preds = %5, %3
  ret i32 0
}

declare i32 @printf(i8*, ...) local_unnamed_addr #1

declare i32 @"__occam_spec.execute_call(incr,0x5)"() local_unnamed_addr

; Function Attrs: noinline norecurse nounwind readnone ssp uwtable
; CHECK: "__occam_spec.incr(0x5)"
define i32 @"__occam_spec.incr(0x5)"() local_unnamed_addr #2 {
  ; CHECK: 6
  ret i32 6
}

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline norecurse nounwind readnone ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1, !2}

!0 = !{!"clang version 5.0.0 (tags/RELEASE_500/final)"}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
