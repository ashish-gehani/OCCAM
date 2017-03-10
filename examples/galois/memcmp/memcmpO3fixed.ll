; ModuleID = 'memcmp0O3.bc'

; Function Attrs: nounwind readonly
define i64 @F4004ec(i64 %a0, i64 %a1, i64 %a2) #0 {
entry:
  br label %block_4004ee

block_4004ee:                                     ; preds = %block_4004f3, %entry
  %R2 = phi i64 [ 0, %entry ], [ %R17, %block_4004f3 ]
  %R6 = icmp eq i64 %R2, %a2
  br i1 %R6, label %block_400508, label %block_4004f3

block_4004f3:                                     ; preds = %block_4004ee
  %R11 = add i64 %R2, %a0
  %r13 = inttoptr i64 %R11 to i8*
  %R12 = load i8* %r13
  %R13 = zext i8 %R12 to i32
  %R14 = add i64 %R2, %a1
  %r17 = inttoptr i64 %R14 to i8*
  %R15 = load i8* %r17
  %R16 = zext i8 %R15 to i32
  %R17 = add i64 %R2, 1
  %R18 = sub i32 %R13, %R16
  %R19 = icmp eq i8 %R12, %R15
  %R20 = zext i32 %R18 to i64
  br i1 %R19, label %block_4004ee, label %block_400508

block_400508:                                     ; preds = %block_4004f3, %block_4004ee
  %R22 = phi i64 [ %R20, %block_4004f3 ], [ 0, %block_4004ee ]
  ret i64 %R22
}

attributes #0 = { nounwind readonly }
