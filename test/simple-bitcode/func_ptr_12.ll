; RUN: cd %funcs12 &&  %funcs12/build.sh
; RUN: %llvm_as < %funcs12/slash/main.o-final.ll | %llvm_dis | FileCheck %s

; ModuleID = 'slash/main.o-final.bc'
source_filename = "llvm-link"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

%struct.class_t = type { {}*, {}* }

; Function Attrs: noinline nounwind ssp uwtable
define internal i32 @foo(%struct.class_t*, i32) #0 {
  %3 = icmp sgt i32 %1, 10
  br i1 %3, label %4, label %11

; <label>:4:                                      ; preds = %2
  %5 = getelementptr inbounds %struct.class_t, %struct.class_t* %0, i64 0, i32 1
  %6 = bitcast {}** %5 to i32 (%struct.class_t*, i32)**
  %7 = load i32 (%struct.class_t*, i32)*, i32 (%struct.class_t*, i32)** %6, align 8
  %8 = add nsw i32 %1, 1
  %9 = bitcast i32 (%struct.class_t*, i32)* %7 to i8*
  %sc.i = icmp eq i8* bitcast (i32 (%struct.class_t*, i32)* @bar to i8*), %9
  br i1 %sc.i, label %__occam.bounce.1.exit, label %fail.i

fail.i:                                           ; preds = %4
  unreachable

__occam.bounce.1.exit:                            ; preds = %4
  ; CHECK:  call i32 @bar
  %10 = call i32 @bar(%struct.class_t* %0, i32 %8)
  br label %11

; <label>:11:                                     ; preds = %2, %__occam.bounce.1.exit
  %.0 = phi i32 [ %10, %__occam.bounce.1.exit ], [ %1, %2 ]
  ret i32 %.0
}

; Function Attrs: noinline nounwind ssp uwtable
define internal i32 @bar(%struct.class_t*, i32) #0 {
  %3 = icmp slt i32 %1, 100
  br i1 %3, label %4, label %9

; <label>:4:                                      ; preds = %2
  %5 = bitcast %struct.class_t* %0 to i32 (%struct.class_t*, i32)**
  %6 = load i32 (%struct.class_t*, i32)*, i32 (%struct.class_t*, i32)** %5, align 8
  %7 = bitcast i32 (%struct.class_t*, i32)* %6 to i8*
  %sc.i = icmp eq i8* bitcast (i32 (%struct.class_t*, i32)* @foo to i8*), %7
  br i1 %sc.i, label %__occam.bounce.exit, label %fail.i

fail.i:                                           ; preds = %4
  unreachable

__occam.bounce.exit:                              ; preds = %4
  ; CHECK:  call i32 @foo
  %8 = call i32 @foo(%struct.class_t* %0, i32 10)
  br label %9

; <label>:9:                                      ; preds = %2, %__occam.bounce.exit
  %.pn = phi i32 [ %8, %__occam.bounce.exit ], [ -5, %2 ]
  %.0 = add nsw i32 %.pn, %1
  ret i32 %.0
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() local_unnamed_addr #0 {
  %1 = alloca %struct.class_t, align 8
  %2 = bitcast %struct.class_t* %1 to i32 (%struct.class_t*, i32)**
  store i32 (%struct.class_t*, i32)* @foo, i32 (%struct.class_t*, i32)** %2, align 8
  %3 = getelementptr inbounds %struct.class_t, %struct.class_t* %1, i64 0, i32 1
  %4 = bitcast {}** %3 to i32 (%struct.class_t*, i32)**
  store i32 (%struct.class_t*, i32)* @bar, i32 (%struct.class_t*, i32)** %4, align 8
  %5 = call i32 @foo(%struct.class_t* nonnull %1, i32 42)
  ret i32 0
}

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1, !2}

!0 = !{!"clang version 5.0.0 (tags/RELEASE_500/final)"}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
