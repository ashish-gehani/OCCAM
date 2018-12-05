; RUN: cd %funcs1 &&  %funcs1/build.sh 
; RUN: %llvm_as < %funcs1/slash/main.o-final.ll | %llvm_dis | FileCheck %s


; ModuleID = 'slash/main.o-final.bc'
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.11.0"

@.str1 = private unnamed_addr constant [7 x i8] c"Nope!\0A\00", align 1

declare i32 @printf(i8*, ...) #0

; Function Attrs: nounwind ssp
define i32 @main(i32, i8** nocapture readnone) #1 {
  ; CHECK: "call(test,0x2,S:7EB6C85)"
  %3 = tail call i32 @"call(test,0x2,S:7EB6C85)"() #3
  ret i32 %3
}

declare i32 @"call(test,0x2,S:7EB6C85)"()

; Function Attrs: nounwind ssp uwtable
define i32 @"test(0x2,S:7EB6C85)"() #2 {
  %1 = tail call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([7 x i8]* @.str1, i64 0, i64 0)) #3
  ret i32 -1
}

attributes #0 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind ssp }
attributes #2 = { nounwind ssp uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
