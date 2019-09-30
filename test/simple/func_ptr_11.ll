; RUN: cd %funcs11 &&  %funcs11/build.sh
; RUN: %llvm_as < %funcs11/slash/main.o-final.ll | %llvm_dis | FileCheck %s
; XFAIL: *

; ModuleID = 'slash/main.o-final.bc'
source_filename = "llvm-link"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@_fun = internal unnamed_addr global i32 (i32)* null, align 8
@.str = private unnamed_addr constant [29 x i8] c"you should see this message\0A\00", align 1
@.str.1 = private unnamed_addr constant [33 x i8] c"you should NOT see this message\0A\00", align 1

; Function Attrs: noinline norecurse nounwind readnone ssp uwtable
define internal i32 @incr(i32) #0 {
  %2 = add nsw i32 %0, 1
  ret i32 %2
}

; Function Attrs: noinline norecurse nounwind ssp uwtable
define internal fastcc void @init() unnamed_addr #1 {
  store i32 (i32)* @incr, i32 (i32)** @_fun, align 8
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() local_unnamed_addr #2 {
  tail call fastcc void @init()
  %1 = load i32 (i32)*, i32 (i32)** @_fun, align 8
  ; CHECK: "__occam_spec.execute_call(incr,0x5)"
  %2 = tail call i32 @"__occam_spec.execute_call(?,0x5)"(i32 (i32)* %1) #4
  %3 = icmp eq i32 %2, 6
  br i1 %3, label %4, label %6

; <label>:4:                                      ; preds = %0
  %5 = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str, i64 0, i64 0)) #4
  br label %8

; <label>:6:                                      ; preds = %0
  %7 = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([33 x i8], [33 x i8]* @.str.1, i64 0, i64 0)) #4
  br label %8

; <label>:8:                                      ; preds = %6, %4
  ret i32 0
}

declare i32 @printf(i8*, ...) local_unnamed_addr #3

declare i32 @"__occam_spec.execute_call(?,0x5)"(i32 (i32)*) local_unnamed_addr

attributes #0 = { noinline norecurse nounwind readnone ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline norecurse nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1, !2}

!0 = !{!"clang version 5.0.0 (tags/RELEASE_500/final)"}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
