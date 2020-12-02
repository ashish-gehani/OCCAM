; RUN: cd %bounded_intra && %bounded_intra/build.sh
; RUN: %llvm_as < slash/main-final.ll | %llvm_dis | FileCheck %s


; ModuleID = 'slash/main-final.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [16 x i8] c"%d %d %d %d %d\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define internal fastcc i32 @nd_int() unnamed_addr #0 {
entry:
  %call = tail call i64 @time(i64* null) #3
  %conv = trunc i64 %call to i32
  tail call void @srand(i32 %conv) #3
  %call1 = tail call i32 @rand() #3
  ret i32 %call1
}

; Function Attrs: nounwind
declare i64 @time(i64*) local_unnamed_addr #1

; Function Attrs: nounwind
declare void @srand(i32) local_unnamed_addr #1

; Function Attrs: nounwind
declare i32 @rand() local_unnamed_addr #1

; Function Attrs: noinline nounwind uwtable
define internal fastcc i32 @libcall(i32 %uno) unnamed_addr #0 {
entry:
  switch i32 %uno, label %if.end5 [
    i32 0, label %if.then
    i32 1, label %return
  ]

if.then:                                          ; preds = %entry
  br label %return

if.end5:                                          ; preds = %entry
  %cmp6 = icmp eq i32 %uno, 2
  %call8 = tail call fastcc i32 @nd_int()
  %add9 = add nsw i32 %call8, 3
  %add9.call8 = select i1 %cmp6, i32 %add9, i32 %call8
  ret i32 %add9.call8

return:                                           ; preds = %entry, %if.then
  %.sink = phi i32 [ 1, %if.then ], [ 2, %entry ]
  %call3 = tail call fastcc i32 @nd_int()
  %add4 = add nsw i32 %call3, %.sink
  ret i32 %add4
}

declare i32 @printf(i8*, ...) local_unnamed_addr #2

; Function Attrs: nounwind
define i32 @main(i32, i8** nocapture readnone) local_unnamed_addr #3 {
  %call.i = tail call fastcc i32 @nd_int() #3
  %call1.i = tail call fastcc i32 @nd_int() #3
  %call2.i = tail call fastcc i32 @libcall(i32 %call.i) #3
  ; CHECK-NOT: "__occam_spec.libcall(0x1)"
  %call3.i = tail call fastcc i32 @libcall(i32 1) #3
  ; CHECK-NOT: "__occam_spec.libcall(0x3)"  
  %call4.i = tail call fastcc i32 @libcall(i32 3) #3
  ; CHECK: "__occam_spec.libcall(0x5)"    
  %call5.i2 = tail call fastcc i32 @"__occam_spec.libcall(0x5)"()
  ; CHECK: "__occam_spec.libcall(0x7)"    
  %call6.i1 = tail call fastcc i32 @"__occam_spec.libcall(0x7)"()
  
  %call7.i = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str, i64 0, i64 0), i32 %call2.i, i32 %call3.i, i32 %call4.i, i32 %call5.i2, i32 %call6.i1) #3
  ret i32 0
}

; Function Attrs: noinline nounwind uwtable
define internal fastcc i32 @"__occam_spec.libcall(0x7)"() unnamed_addr #0 {
entry:
  %call8 = tail call fastcc i32 @nd_int()
  ret i32 %call8
}

; Function Attrs: noinline nounwind uwtable
define internal fastcc i32 @"__occam_spec.libcall(0x5)"() unnamed_addr #0 {
entry:
  %call8 = tail call fastcc i32 @nd_int()
  ret i32 %call8
}

attributes #0 = { noinline nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1}

!0 = !{!"clang version 5.0.2 (tags/RELEASE_502/final)"}
!1 = !{i32 1, !"wchar_size", i32 4}
