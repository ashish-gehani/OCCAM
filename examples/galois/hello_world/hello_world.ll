declare i1 @reopt.EvenParity(i8) readnone nounwind
declare i2 @reopt.Read_X87_RC() readonly
declare void @reopt.Write_X87_RC(i2)
declare i2 @reopt.Read_X87_PC() readonly
declare void @reopt.Write_X87_PC(i2)
declare i16 @reopt.Read_FS() readonly
declare void @reopt.Write_FS(i16)
declare i16 @reopt.Read_GS() readonly
declare void @reopt.Write_GS(i16)
declare i64 @reopt.MemCmp(i64, i64, i64, i64, i1)
declare { i64, i1 } @reopt.SystemCall.Linux(i64, i64, i64, i64, i64, i64, i64)
declare { i64, i1 } @reopt.SystemCall.FreeBSD(i64, i64, i64, i64, i64, i64, i64)
declare void @reopt.MemCopy.i8(i64, i64, i64, i1)
declare void @reopt.MemCopy.i16(i64, i64, i64, i1)
declare void @reopt.MemCopy.i32(i64, i64, i64, i1)
declare void @reopt.MemCopy.i64(i64, i64, i64, i1)
declare void @reopt.MemSet.i8(i8*, i8, i64, i1)
declare void @reopt.MemSet.i16(i16*, i16, i64, i1)
declare void @reopt.MemSet.i32(i32*, i32, i64, i1)
declare void @reopt.MemSet.i64(i64*, i64, i64, i1)
declare { i4, i1 } @llvm.uadd.with.overflow.i4(i4, i4)
declare { i8, i1 } @llvm.uadd.with.overflow.i8(i8, i8)
declare { i16, i1 } @llvm.uadd.with.overflow.i16(i16, i16)
declare { i32, i1 } @llvm.uadd.with.overflow.i32(i32, i32)
declare { i64, i1 } @llvm.uadd.with.overflow.i64(i64, i64)
declare { i4, i1 } @llvm.sadd.with.overflow.i4(i4, i4)
declare { i8, i1 } @llvm.sadd.with.overflow.i8(i8, i8)
declare { i16, i1 } @llvm.sadd.with.overflow.i16(i16, i16)
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32)
declare { i64, i1 } @llvm.sadd.with.overflow.i64(i64, i64)
declare { i4, i1 } @llvm.usub.with.overflow.i4(i4, i4)
declare { i8, i1 } @llvm.usub.with.overflow.i8(i8, i8)
declare { i16, i1 } @llvm.usub.with.overflow.i16(i16, i16)
declare { i32, i1 } @llvm.usub.with.overflow.i32(i32, i32)
declare { i64, i1 } @llvm.usub.with.overflow.i64(i64, i64)
declare { i4, i1 } @llvm.ssub.with.overflow.i4(i4, i4)
declare { i8, i1 } @llvm.ssub.with.overflow.i8(i8, i8)
declare { i16, i1 } @llvm.ssub.with.overflow.i16(i16, i16)
declare { i32, i1 } @llvm.ssub.with.overflow.i32(i32, i32)
declare { i64, i1 } @llvm.ssub.with.overflow.i64(i64, i64)
declare i8 @llvm.cttz.i8(i8, i1)
declare i16 @llvm.cttz.i16(i16, i1)
declare i32 @llvm.cttz.i32(i32, i1)
declare i64 @llvm.cttz.i64(i64, i1)
declare i8 @llvm.ctlz.i8(i8, i1)
declare i16 @llvm.ctlz.i16(i16, i1)
declare i32 @llvm.ctlz.i32(i32, i1)
declare i64 @llvm.ctlz.i64(i64, i1)
define { i64, i64, <2 x double> } @reopt_gen_h() {
init:
  br label %block_0x4000e8
block_0x4000e8:
  ; r0 := (alloca 0x10 :: [64])
  %r0 = alloca i8, i64 16
  %r1 = ptrtoint i8* %r0 to i64
  ; r1 := (bv_add r0 0x10 :: [64])
  %r2 = add i64 %r1, 16
  ; # 0x4000e8: push   rbp
  ; r2 := (bv_add r1 0xfffffffffffffff8 :: [64])
  %r3 = add i64 %r2, 18446744073709551608
  ; # 0x4000e9: mov    rbp,rsp
  ; # 0x4000ec: mov    edi,0x400539
  ; # 0x4000f1: call   400453
  ; r3 := (bv_add r1 0xfffffffffffffff0 :: [64])
  %r4 = add i64 %r2, 18446744073709551600
  %r5 = inttoptr i64 4195411 to { i64, i64, <2 x double> }(i64, i64, i64, i64, i64, i64, <2 x double>, <2 x double>, <2 x double>, <2 x double>, <2 x double>, <2 x double>, <2 x double>, <2 x double>)*
  %r6 = bitcast i128 undef to <2 x double>
  %r7 = bitcast i128 undef to <2 x double>
  %r8 = bitcast i128 undef to <2 x double>
  %r9 = bitcast i128 undef to <2 x double>
  %r10 = bitcast i128 undef to <2 x double>
  %r11 = bitcast i128 undef to <2 x double>
  %r12 = bitcast i128 undef to <2 x double>
  %r13 = bitcast i128 undef to <2 x double>
  %r14 = call { i64, i64, <2 x double> }(i64, i64, i64, i64, i64, i64, <2 x double>, <2 x double>, <2 x double>, <2 x double>, <2 x double>, <2 x double>, <2 x double>, <2 x double>)* %r5(i64 4195641, i64 undef, i64 undef, i64 undef, i64 undef, i64 undef, <2 x double> %r6, <2 x double> %r7, <2 x double> %r8, <2 x double> %r9, <2 x double> %r10, <2 x double> %r11, <2 x double> %r12, <2 x double> %r13)
  %r15 = extractvalue { i64, i64, <2 x double> } %r14, 0
  %r16 = extractvalue { i64, i64, <2 x double> } %r14, 1
  %r17 = extractvalue { i64, i64, <2 x double> } %r14, 2
  %r18 = bitcast <2 x double> %r17 to i128
  br label %block_0x4000f6
block_0x4000f6:
  ; # 0x4000f6: pop    rbp
  ; r7 := *unsupported (Initial register rsp)
  %r19 = inttoptr i64 undef to i64*
  %r20 = load i64* %r19
  ; r8 := (bv_add unsupported (Initial register rsp) 0x8 :: [64])
  %r21 = add i64 undef, 8
  ; # 0x4000f7: ret
  ; r9 := (bv_add unsupported (Initial register rsp) 0x10 :: [64])
  %r22 = add i64 undef, 16
  %r23 = insertvalue { i64, i64, <2 x double> } undef, i64 undef, 0
  %r24 = insertvalue { i64, i64, <2 x double> } %r23, i64 undef, 1
  %r25 = insertvalue { i64, i64, <2 x double> } %r24, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r25
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen_g() {
init:
  br label %block_0x4000f8
block_0x4000f8:
  ; r0 := (alloca 0x10 :: [64])
  %r0 = alloca i8, i64 16
  %r1 = ptrtoint i8* %r0 to i64
  ; r1 := (bv_add r0 0x10 :: [64])
  %r2 = add i64 %r1, 16
  ; # 0x4000f8: push   rbp
  ; r2 := (bv_add r1 0xfffffffffffffff8 :: [64])
  %r3 = add i64 %r2, 18446744073709551608
  ; # 0x4000f9: mov    rbp,rsp
  ; # 0x4000fc: mov    eax,0x0
  ; # 0x400101: call   4000e8
  ; r3 := (bv_add r1 0xfffffffffffffff0 :: [64])
  %r4 = add i64 %r2, 18446744073709551600
  %r5 = call { i64, i64, <2 x double> } @reopt_gen_h()
  br label %block_0x400106
block_0x400106:
  ; # 0x400106: pop    rbp
  ; r4 := *unsupported (Initial register rsp)
  %r6 = inttoptr i64 undef to i64*
  %r7 = load i64* %r6
  ; r5 := (bv_add unsupported (Initial register rsp) 0x8 :: [64])
  %r8 = add i64 undef, 8
  ; # 0x400107: ret
  ; r6 := (bv_add unsupported (Initial register rsp) 0x10 :: [64])
  %r9 = add i64 undef, 16
  %r10 = insertvalue { i64, i64, <2 x double> } undef, i64 undef, 0
  %r11 = insertvalue { i64, i64, <2 x double> } %r10, i64 undef, 1
  %r12 = insertvalue { i64, i64, <2 x double> } %r11, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r12
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen_f() {
init:
  br label %block_0x400108
block_0x400108:
  ; r0 := (alloca 0x10 :: [64])
  %r0 = alloca i8, i64 16
  %r1 = ptrtoint i8* %r0 to i64
  ; r1 := (bv_add r0 0x10 :: [64])
  %r2 = add i64 %r1, 16
  ; # 0x400108: push   rbp
  ; r2 := (bv_add r1 0xfffffffffffffff8 :: [64])
  %r3 = add i64 %r2, 18446744073709551608
  ; # 0x400109: mov    rbp,rsp
  ; # 0x40010c: mov    eax,0x0
  ; # 0x400111: call   4000f8
  ; r3 := (bv_add r1 0xfffffffffffffff0 :: [64])
  %r4 = add i64 %r2, 18446744073709551600
  %r5 = call { i64, i64, <2 x double> } @reopt_gen_g()
  br label %block_0x400116
block_0x400116:
  ; # 0x400116: pop    rbp
  ; r4 := *unsupported (Initial register rsp)
  %r6 = inttoptr i64 undef to i64*
  %r7 = load i64* %r6
  ; r5 := (bv_add unsupported (Initial register rsp) 0x8 :: [64])
  %r8 = add i64 undef, 8
  ; # 0x400117: ret
  ; r6 := (bv_add unsupported (Initial register rsp) 0x10 :: [64])
  %r9 = add i64 undef, 16
  %r10 = insertvalue { i64, i64, <2 x double> } undef, i64 undef, 0
  %r11 = insertvalue { i64, i64, <2 x double> } %r10, i64 undef, 1
  %r12 = insertvalue { i64, i64, <2 x double> } %r11, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r12
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen_main(i64 %iarg0, i64 %iarg1) {
init:
  br label %block_0x400118
block_0x400118:
  ; r0 := (alloca 0x20 :: [64])
  %r0 = alloca i8, i64 32
  %r1 = ptrtoint i8* %r0 to i64
  ; r1 := (bv_add r0 0x20 :: [64])
  %r2 = add i64 %r1, 32
  ; # 0x400118: push   rbp
  ; r2 := (bv_add r1 0xfffffffffffffff8 :: [64])
  %r3 = add i64 %r2, 18446744073709551608
  ; # 0x400119: mov    rbp,rsp
  ; # 0x40011c: sub    rsp,0x10
  ; r3 := (ssbb_overflows r2 0x10 :: [64] 0x0 :: [1])
  %r4 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %r3, i64 16)
  %r5 = extractvalue { i64, i1 } %r4, 1
  ; r4 := (bv_ult r2 0x10 :: [64])
  %r6 = icmp ult i64 %r3, 16
  ; r5 := (bv_add r1 0xffffffffffffffe8 :: [64])
  %r7 = add i64 %r2, 18446744073709551592
  ; r6 := (bv_slt r5 0x0 :: [64])
  %r8 = icmp slt i64 %r7, 0
  ; r7 := (bv_eq r1 0x18 :: [64])
  %r9 = icmp eq i64 %r2, 24
  ; r8 := (trunc r5 8)
  %r10 = trunc i64 %r7 to i8
  ; r9 := (even_parity r8)
  %r11 = call i1 @reopt.EvenParity(i8 %r10)
  ; # 0x400120: mov    DWORD PTR [rbp-0x4],edi
  ; r10 := (trunc arg0 32)
  %r12 = trunc i64 %iarg0 to i32
  ; r11 := (bv_add r1 0xfffffffffffffff4 :: [64])
  %r13 = add i64 %r2, 18446744073709551604
  ; *(r11) = r10
  %r14 = inttoptr i64 %r13 to i32*
  store i32 %r12, i32* %r14
  ; # 0x400123: mov    QWORD PTR [rbp-0x10],rsi
  ; *(r5) = arg1
  %r15 = inttoptr i64 %r7 to i64*
  store i64 %iarg1, i64* %r15
  ; # 0x400127: mov    eax,0x0
  ; # 0x40012c: call   400108
  ; r12 := (bv_add r1 0xffffffffffffffe0 :: [64])
  %r16 = add i64 %r2, 18446744073709551584
  %r17 = call { i64, i64, <2 x double> } @reopt_gen_f()
  br label %block_0x400131
block_0x400131:
  ; # 0x400131: mov    eax,0x0
  ; # 0x400136: leave
  ; r13 := *unsupported (Initial register rbp)
  %r18 = inttoptr i64 undef to i64*
  %r19 = load i64* %r18
  ; r14 := (bv_add unsupported (Initial register rbp) 0x8 :: [64])
  %r20 = add i64 undef, 8
  ; # 0x400137: ret
  ; r15 := (bv_add unsupported (Initial register rbp) 0x10 :: [64])
  %r21 = add i64 undef, 16
  %r22 = insertvalue { i64, i64, <2 x double> } undef, i64 undef, 0
  %r23 = insertvalue { i64, i64, <2 x double> } %r22, i64 undef, 1
  %r24 = insertvalue { i64, i64, <2 x double> } %r23, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r24
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen___nop(i64 %iarg0, i64 %iarg1, i64 %iarg2, i64 %iarg3, i64 %iarg4, i64 %iarg5, <2 x double> %farg0, <2 x double> %farg1, <2 x double> %farg2, <2 x double> %farg3, <2 x double> %farg4, <2 x double> %farg5, <2 x double> %farg6, <2 x double> %farg7) {
init:
  %fargbv0 = bitcast <2 x double> %farg0 to i128
  %fargbv1 = bitcast <2 x double> %farg1 to i128
  %fargbv2 = bitcast <2 x double> %farg2 to i128
  %fargbv3 = bitcast <2 x double> %farg3 to i128
  %fargbv4 = bitcast <2 x double> %farg4 to i128
  %fargbv5 = bitcast <2 x double> %farg5 to i128
  %fargbv6 = bitcast <2 x double> %farg6 to i128
  %fargbv7 = bitcast <2 x double> %farg7 to i128
  br label %block_0x40017b
block_0x40017b:
  ; # 0x40017b: ret
  ; r0 := (bv_add unsupported (Initial register rsp) 0x8 :: [64])
  %r0 = add i64 undef, 8
  %r1 = bitcast i128 %fargbv0 to <2 x double>
  %r2 = insertvalue { i64, i64, <2 x double> } undef, i64 undef, 0
  %r3 = insertvalue { i64, i64, <2 x double> } %r2, i64 %iarg2, 1
  %r4 = insertvalue { i64, i64, <2 x double> } %r3, <2 x double> %r1, 2
  ret { i64, i64, <2 x double> } %r4
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen___errno_location(i64 %iarg0, i64 %iarg1, i64 %iarg2) {
init:
  br label %block_0x40017c
block_0x40017c:
  ; # 0x40017c: mov    eax,0x600748
  ; # 0x400181: ret
  ; r0 := (bv_add unsupported (Initial register rsp) 0x8 :: [64])
  %r0 = add i64 undef, 8
  %r1 = insertvalue { i64, i64, <2 x double> } undef, i64 6293320, 0
  %r2 = insertvalue { i64, i64, <2 x double> } %r1, i64 %iarg2, 1
  %r3 = insertvalue { i64, i64, <2 x double> } %r2, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r3
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen_strstr(i64 %iarg0, i64 %iarg1, i64 %iarg2, i64 %iarg3) {
init:
  br label %block_0x4003b4
block_0x4003b4:
  ; r0 := (alloca 0x30 :: [64])
  %r0 = alloca i8, i64 48
  %r1 = ptrtoint i8* %r0 to i64
  ; r1 := (bv_add r0 0x30 :: [64])
  %r2 = add i64 %r1, 48
  ; # 0x4003b4: push   r13
  ; r2 := (bv_add r1 0xfffffffffffffff8 :: [64])
  %r3 = add i64 %r2, 18446744073709551608
  ; # 0x4003b6: xor    eax,eax
  ; r3 := undef :: [1]
  ; # 0x4003b8: push   r12
  ; r4 := (bv_add r1 0xfffffffffffffff0 :: [64])
  %r4 = add i64 %r2, 18446744073709551600
  ; # 0x4003ba: push   rbp
  ; r5 := (bv_add r1 0xffffffffffffffe8 :: [64])
  %r5 = add i64 %r2, 18446744073709551592
  ; # 0x4003bb: mov    rbp,rsi
  ; # 0x4003be: or     rsi,-0x1
  ; r6 := undef :: [1]
  ; # 0x4003c2: push   rbx
  ; r7 := (bv_add r1 0xffffffffffffffe0 :: [64])
  %r6 = add i64 %r2, 18446744073709551584
  ; # 0x4003c3: mov    rbx,rdi
  ; # 0x4003c6: mov    rdi,rbp
  ; # 0x4003c9: push   rcx
  ; r8 := (bv_add r1 0xffffffffffffffd8 :: [64])
  %r7 = add i64 %r2, 18446744073709551576
  ; *(r8) = arg3
  %r8 = inttoptr i64 %r7 to i64*
  store i64 %iarg3, i64* %r8
  ; # 0x4003ca: mov    rcx,rsi
  ; # 0x4003cd: repnz scas al,BYTE PTR [rdi]
  ; r9 := undef :: [64]
  ; r10 := (bv_eq r9 0xffffffffffffffff :: [64])
  %r9 = icmp eq i64 undef, 18446744073709551615
  ; r11 := (bv_add r9 0x1 :: [64])
  %r10 = add i64 undef, 1
  ; r12 := (bv_sub 0xffffffffffffffff :: [64] r11)
  %r11 = sub i64 18446744073709551615, %r10
  ; r13 := (mux r10 0xffffffffffffffff :: [64] r12)
  %r12 = select i1 %r9, i64 18446744073709551615, i64 %r11
  ; r14 := (bv_add r13 0xffffffffffffffff :: [64])
  %r13 = add i64 %r12, 18446744073709551615
  ; r15 := (bv_sub arg1 r14)
  %r14 = sub i64 %iarg1, %r13
  ; r16 := (bv_add arg1 r14)
  %r15 = add i64 %iarg1, %r13
  ; r17 := (mux 0x0 :: [1] r15 r16)
  %r16 = select i1 0, i64 %r14, i64 %r15
  ; r18 := *r17
  %r17 = inttoptr i64 %r16 to i8*
  %r18 = load i8* %r17
  ; r19 := (bv_slt r18 0x0 :: [8])
  %r19 = icmp slt i8 %r18, 0
  ; r20 := (bv_eq r18 0x0 :: [8])
  %r20 = icmp eq i8 %r18, 0
  ; r21 := (even_parity r18)
  %r21 = call i1 @reopt.EvenParity(i8 %r18)
  ; r22 := (bv_sub arg1 r13)
  %r22 = sub i64 %iarg1, %r12
  ; r23 := (bv_add arg1 r13)
  %r23 = add i64 %iarg1, %r12
  ; r24 := (mux 0x0 :: [1] r22 r23)
  %r24 = select i1 0, i64 %r22, i64 %r23
  ; r25 := (bv_sub 0xffffffffffffffff :: [64] r13)
  %r25 = sub i64 18446744073709551615, %r12
  ; # 0x4003cf: mov    rdi,rbx
  ; # 0x4003d2: mov    rdx,rcx
  ; # 0x4003d5: mov    rcx,rsi
  ; # 0x4003d8: repnz scas al,BYTE PTR [rdi]
  ; r26 := undef :: [64]
  ; r27 := (bv_eq r26 0xffffffffffffffff :: [64])
  %r26 = icmp eq i64 undef, 18446744073709551615
  ; r28 := (bv_add r26 0x1 :: [64])
  %r27 = add i64 undef, 1
  ; r29 := (bv_sub 0xffffffffffffffff :: [64] r28)
  %r28 = sub i64 18446744073709551615, %r27
  ; r30 := (mux r27 0xffffffffffffffff :: [64] r29)
  %r29 = select i1 %r26, i64 18446744073709551615, i64 %r28
  ; r31 := (bv_add r30 0xffffffffffffffff :: [64])
  %r30 = add i64 %r29, 18446744073709551615
  ; r32 := (bv_sub arg0 r31)
  %r31 = sub i64 %iarg0, %r30
  ; r33 := (bv_add arg0 r31)
  %r32 = add i64 %iarg0, %r30
  ; r34 := (mux 0x0 :: [1] r32 r33)
  %r33 = select i1 0, i64 %r31, i64 %r32
  ; r35 := *r34
  %r34 = inttoptr i64 %r33 to i8*
  %r35 = load i8* %r34
  ; r36 := (bv_slt r35 0x0 :: [8])
  %r36 = icmp slt i8 %r35, 0
  ; r37 := (bv_eq r35 0x0 :: [8])
  %r37 = icmp eq i8 %r35, 0
  ; r38 := (even_parity r35)
  %r38 = call i1 @reopt.EvenParity(i8 %r35)
  ; r39 := (bv_sub arg0 r30)
  %r39 = sub i64 %iarg0, %r29
  ; r40 := (bv_add arg0 r30)
  %r40 = add i64 %iarg0, %r29
  ; r41 := (mux 0x0 :: [1] r39 r40)
  %r41 = select i1 0, i64 %r39, i64 %r40
  ; r42 := (bv_sub 0xffffffffffffffff :: [64] r30)
  %r42 = sub i64 18446744073709551615, %r29
  ; # 0x4003da: not    rdx
  ; r43 := (bv_complement r25)
  %r43 = xor i64 %r25, -1
  ; # 0x4003dd: mov    rax,rbx
  ; # 0x4003e0: not    rcx
  ; r44 := (bv_complement r42)
  %r44 = xor i64 %r42, -1
  ; # 0x4003e3: add    rsi,rcx
  ; r45 := (sadc_overflows 0xffffffffffffffff :: [64] r44 0x0 :: [1])
  %r45 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 18446744073709551615, i64 %r44)
  %r46 = extractvalue { i64, i1 } %r45, 1
  ; r46 := (trunc r44 4)
  %r47 = trunc i64 %r44 to i4
  ; r47 := (uadc_overflows 0xf :: [4] r46 0x0 :: [1])
  %r48 = call { i4, i1 } @llvm.uadd.with.overflow.i4(i4 15, i4 %r47)
  %r49 = extractvalue { i4, i1 } %r48, 1
  ; r48 := (uadc_overflows 0xffffffffffffffff :: [64] r44 0x0 :: [1])
  %r50 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 18446744073709551615, i64 %r44)
  %r51 = extractvalue { i64, i1 } %r50, 1
  ; r49 := (bv_add r44 0xffffffffffffffff :: [64])
  %r52 = add i64 %r44, 18446744073709551615
  ; r50 := (bv_slt r49 0x0 :: [64])
  %r53 = icmp slt i64 %r52, 0
  ; r51 := (bv_eq r44 0x1 :: [64])
  %r54 = icmp eq i64 %r44, 1
  ; r52 := (trunc r49 8)
  %r55 = trunc i64 %r52 to i8
  ; r53 := (even_parity r52)
  %r56 = call i1 @reopt.EvenParity(i8 %r55)
  ; # 0x4003e6: dec    rdx
  ; r54 := (ssbb_overflows r43 0x1 :: [64] 0x0 :: [1])
  %r57 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %r43, i64 1)
  %r58 = extractvalue { i64, i1 } %r57, 1
  ; r55 := (trunc r43 4)
  %r59 = trunc i64 %r43 to i4
  ; r56 := (bv_ult r55 0x1 :: [4])
  %r60 = icmp ult i4 %r59, 1
  ; r57 := (bv_add r43 0xffffffffffffffff :: [64])
  %r61 = add i64 %r43, 18446744073709551615
  ; r58 := (bv_slt r57 0x0 :: [64])
  %r62 = icmp slt i64 %r61, 0
  ; r59 := (bv_eq r43 0x1 :: [64])
  %r63 = icmp eq i64 %r43, 1
  ; r60 := (trunc r57 8)
  %r64 = trunc i64 %r61 to i8
  ; r61 := (even_parity r60)
  %r65 = call i1 @reopt.EvenParity(i8 %r64)
  ; # 0x4003e9: je     400424
  br i1 %r63, label %subblock_0x4003b4_1, label %subblock_0x4003b4_2
subblock_0x4003b4_1:
  br label %block_0x400424
subblock_0x4003b4_2:
  br label %block_0x4003eb
block_0x4003eb:
  %r66 = phi i64 [ %iarg0, %subblock_0x4003b4_2 ]
  %r67 = phi i64 [ %r44, %subblock_0x4003b4_2 ]
  %r68 = phi i64 [ %r61, %subblock_0x4003b4_2 ]
  %r69 = phi i64 [ %iarg0, %subblock_0x4003b4_2 ]
  %r70 = phi i64 [ %r7, %subblock_0x4003b4_2 ]
  %r71 = phi i64 [ %iarg1, %subblock_0x4003b4_2 ]
  %r72 = phi i64 [ %r52, %subblock_0x4003b4_2 ]
  ; # 0x4003eb: cmp    rdx,rsi
  ; r69 := (ssbb_overflows r64 r68 0x0 :: [1])
  %r73 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %r68, i64 %r72)
  %r74 = extractvalue { i64, i1 } %r73, 1
  ; r70 := (trunc r64 4)
  %r75 = trunc i64 %r68 to i4
  ; r71 := (trunc r68 4)
  %r76 = trunc i64 %r72 to i4
  ; r72 := (bv_ult r70 r71)
  %r77 = icmp ult i4 %r75, %r76
  ; r73 := (bv_ult r64 r68)
  %r78 = icmp ult i64 %r68, %r72
  ; r74 := (bv_sub r64 r68)
  %r79 = sub i64 %r68, %r72
  ; r75 := (bv_slt r74 0x0 :: [64])
  %r80 = icmp slt i64 %r79, 0
  ; r76 := (bv_eq r64 r68)
  %r81 = icmp eq i64 %r68, %r72
  ; r77 := (trunc r74 8)
  %r82 = trunc i64 %r79 to i8
  ; r78 := (even_parity r77)
  %r83 = call i1 @reopt.EvenParity(i8 %r82)
  ; # 0x4003ee: mov    r12,rdx
  ; # 0x4003f1: ja     40041d
  ; r79 := (bv_ult r68 r64)
  %r84 = icmp ult i64 %r72, %r68
  br i1 %r84, label %subblock_0x4003eb_1, label %subblock_0x4003eb_2
subblock_0x4003eb_1:
  br label %block_0x40041d
subblock_0x4003eb_2:
  br label %block_0x4003f3
block_0x4003f3:
  %r85 = phi i64 [ %r66, %subblock_0x4003eb_2 ]
  %r86 = phi i64 [ %r67, %subblock_0x4003eb_2 ]
  %r87 = phi i64 [ %r68, %subblock_0x4003eb_2 ]
  %r88 = phi i64 [ %r69, %subblock_0x4003eb_2 ]
  %r89 = phi i64 [ %r70, %subblock_0x4003eb_2 ]
  %r90 = phi i64 [ %r71, %subblock_0x4003eb_2 ]
  %r91 = phi i64 [ %r68, %subblock_0x4003eb_2 ]
  ; # 0x4003f3: sub    rcx,rdx
  ; r87 := (ssbb_overflows r81 r82 0x0 :: [1])
  %r92 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %r86, i64 %r87)
  %r93 = extractvalue { i64, i1 } %r92, 1
  ; r88 := (trunc r81 4)
  %r94 = trunc i64 %r86 to i4
  ; r89 := (trunc r82 4)
  %r95 = trunc i64 %r87 to i4
  ; r90 := (bv_ult r88 r89)
  %r96 = icmp ult i4 %r94, %r95
  ; r91 := (bv_ult r81 r82)
  %r97 = icmp ult i64 %r86, %r87
  ; r92 := (bv_sub r81 r82)
  %r98 = sub i64 %r86, %r87
  ; r93 := (bv_slt r92 0x0 :: [64])
  %r99 = icmp slt i64 %r98, 0
  ; r94 := (bv_eq r81 r82)
  %r100 = icmp eq i64 %r86, %r87
  ; r95 := (trunc r92 8)
  %r101 = trunc i64 %r98 to i8
  ; r96 := (even_parity r95)
  %r102 = call i1 @reopt.EvenParity(i8 %r101)
  ; # 0x4003f6: lea    r13,[rbx+rcx*1]
  ; r97 := (bv_add r83 r92)
  %r103 = add i64 %r88, %r98
  ; # 0x4003fa: cmp    rbx,r13
  ; r98 := (ssbb_overflows r83 r97 0x0 :: [1])
  %r104 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %r88, i64 %r103)
  %r105 = extractvalue { i64, i1 } %r104, 1
  ; r99 := (trunc r83 4)
  %r106 = trunc i64 %r88 to i4
  ; r100 := (trunc r97 4)
  %r107 = trunc i64 %r103 to i4
  ; r101 := (bv_ult r99 r100)
  %r108 = icmp ult i4 %r106, %r107
  ; r102 := (bv_ult r83 r97)
  %r109 = icmp ult i64 %r88, %r103
  ; r103 := (bv_sub r83 r97)
  %r110 = sub i64 %r88, %r103
  ; r104 := (bv_slt r103 0x0 :: [64])
  %r111 = icmp slt i64 %r110, 0
  ; r105 := (bv_eq r83 r97)
  %r112 = icmp eq i64 %r88, %r103
  ; r106 := (trunc r103 8)
  %r113 = trunc i64 %r110 to i8
  ; r107 := (even_parity r106)
  %r114 = call i1 @reopt.EvenParity(i8 %r113)
  ; # 0x4003fd: je     40041d
  br i1 %r112, label %subblock_0x4003f3_1, label %subblock_0x4003f3_2
subblock_0x4003f3_1:
  br label %block_0x40041d
subblock_0x4003f3_2:
  br label %block_0x4003ff
block_0x4003fa:
  %r115 = phi i64 [ %r177, %block_0x400418 ]
  %r116 = phi i64 [ %r188, %block_0x400418 ]
  %r117 = phi i64 [ %r179, %block_0x400418 ]
  %r118 = phi i64 [ %r180, %block_0x400418 ]
  %r119 = phi i64 [ %r181, %block_0x400418 ]
  %r120 = phi i64 [ %r182, %block_0x400418 ]
  ; # 0x4003fa: cmp    rbx,r13
  ; r114 := (ssbb_overflows r109 r113 0x0 :: [1])
  %r121 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %r116, i64 %r120)
  %r122 = extractvalue { i64, i1 } %r121, 1
  ; r115 := (trunc r109 4)
  %r123 = trunc i64 %r116 to i4
  ; r116 := (trunc r113 4)
  %r124 = trunc i64 %r120 to i4
  ; r117 := (bv_ult r115 r116)
  %r125 = icmp ult i4 %r123, %r124
  ; r118 := (bv_ult r109 r113)
  %r126 = icmp ult i64 %r116, %r120
  ; r119 := (bv_sub r109 r113)
  %r127 = sub i64 %r116, %r120
  ; r120 := (bv_slt r119 0x0 :: [64])
  %r128 = icmp slt i64 %r127, 0
  ; r121 := (bv_eq r109 r113)
  %r129 = icmp eq i64 %r116, %r120
  ; r122 := (trunc r119 8)
  %r130 = trunc i64 %r127 to i8
  ; r123 := (even_parity r122)
  %r131 = call i1 @reopt.EvenParity(i8 %r130)
  ; # 0x4003fd: je     40041d
  br i1 %r129, label %subblock_0x4003fa_1, label %subblock_0x4003fa_2
subblock_0x4003fa_1:
  br label %block_0x40041d
subblock_0x4003fa_2:
  br label %block_0x4003ff
block_0x4003ff:
  %r132 = phi i64 [ %r115, %subblock_0x4003fa_2 ], [ %r85, %subblock_0x4003f3_2 ]
  %r133 = phi i64 [ %r116, %subblock_0x4003fa_2 ], [ %r88, %subblock_0x4003f3_2 ]
  %r134 = phi i64 [ %r117, %subblock_0x4003fa_2 ], [ %r89, %subblock_0x4003f3_2 ]
  %r135 = phi i64 [ %r118, %subblock_0x4003fa_2 ], [ %r90, %subblock_0x4003f3_2 ]
  %r136 = phi i64 [ %r119, %subblock_0x4003fa_2 ], [ %r91, %subblock_0x4003f3_2 ]
  %r137 = phi i64 [ %r120, %subblock_0x4003fa_2 ], [ %r103, %subblock_0x4003f3_2 ]
  ; # 0x4003ff: mov    al,BYTE PTR [rbp]
  ; r130 := *r127
  %r138 = inttoptr i64 %r135 to i8*
  %r139 = load i8* %r138
  ; r131 := (bv_and r124 0xffffffffffffff00 :: [64])
  %r140 = and i64 %r132, 18446744073709551360
  ; r132 := (uext r130 64)
  %r141 = zext i8 %r139 to i64
  ; r133 := (bv_or r131 r132)
  %r142 = or i64 %r140, %r141
  ; # 0x400402: cmp    BYTE PTR [rbx],al
  ; r134 := *r125
  %r143 = inttoptr i64 %r133 to i8*
  %r144 = load i8* %r143
  ; r135 := (trunc r133 8)
  %r145 = trunc i64 %r142 to i8
  ; r136 := (ssbb_overflows r134 r135 0x0 :: [1])
  %r146 = call { i8, i1 } @llvm.ssub.with.overflow.i8(i8 %r144, i8 %r145)
  %r147 = extractvalue { i8, i1 } %r146, 1
  ; r137 := (trunc r134 4)
  %r148 = trunc i8 %r144 to i4
  ; r138 := (trunc r133 4)
  %r149 = trunc i64 %r142 to i4
  ; r139 := (bv_ult r137 r138)
  %r150 = icmp ult i4 %r148, %r149
  ; r140 := (bv_ult r134 r135)
  %r151 = icmp ult i8 %r144, %r145
  ; r141 := (bv_sub r134 r135)
  %r152 = sub i8 %r144, %r145
  ; r142 := (bv_slt r141 0x0 :: [8])
  %r153 = icmp slt i8 %r152, 0
  ; r143 := (bv_eq r134 r135)
  %r154 = icmp eq i8 %r144, %r145
  ; r144 := (even_parity r141)
  %r155 = call i1 @reopt.EvenParity(i8 %r152)
  ; # 0x400404: jne    400418
  ; r145 := (bv_complement r143)
  %r156 = xor i1 %r154, -1
  br i1 %r156, label %subblock_0x4003ff_1, label %subblock_0x4003ff_2
subblock_0x4003ff_1:
  br label %block_0x400418
subblock_0x4003ff_2:
  br label %block_0x400406
block_0x400406:
  %r157 = phi i64 [ %r133, %subblock_0x4003ff_2 ]
  %r158 = phi i64 [ %r134, %subblock_0x4003ff_2 ]
  %r159 = phi i64 [ %r135, %subblock_0x4003ff_2 ]
  %r160 = phi i64 [ %r136, %subblock_0x4003ff_2 ]
  %r161 = phi i64 [ %r137, %subblock_0x4003ff_2 ]
  ; # 0x400406: mov    rdx,r12
  ; # 0x400409: mov    rsi,rbp
  ; # 0x40040c: mov    rdi,rbx
  ; # 0x40040f: call   40051c
  ; r151 := (bv_add r147 0xfffffffffffffff8 :: [64])
  %r162 = add i64 %r158, 18446744073709551608
  ; r153 := (bv_add r151 0x8 :: [64])
  %r163 = add i64 %r162, 8
  %r164 = call { i64, i64, <2 x double> } @reopt_gen_memcmp(i64 %r157, i64 %r159, i64 %r160)
  %r165 = extractvalue { i64, i64, <2 x double> } %r164, 0
  br label %block_0x400414
block_0x400414:
  %r166 = phi i64 [ %r165, %block_0x400406 ]
  %r167 = phi i64 [ %r157, %block_0x400406 ]
  %r168 = phi i64 [ %r163, %block_0x400406 ]
  %r169 = phi i64 [ %r159, %block_0x400406 ]
  %r170 = phi i64 [ %r160, %block_0x400406 ]
  %r171 = phi i64 [ %r161, %block_0x400406 ]
  ; # 0x400414: test   eax,eax
  ; r160 := undef :: [1]
  ; r161 := (trunc r154 32)
  %r172 = trunc i64 %r166 to i32
  ; r162 := (bv_slt r161 0x0 :: [32])
  %r173 = icmp slt i32 %r172, 0
  ; r163 := (bv_eq r161 0x0 :: [32])
  %r174 = icmp eq i32 %r172, 0
  ; r164 := (trunc r154 8)
  %r175 = trunc i64 %r166 to i8
  ; r165 := (even_parity r164)
  %r176 = call i1 @reopt.EvenParity(i8 %r175)
  ; # 0x400416: je     400421
  br i1 %r174, label %subblock_0x400414_1, label %subblock_0x400414_2
subblock_0x400414_1:
  br label %block_0x400421
subblock_0x400414_2:
  br label %block_0x400418
block_0x400418:
  %r177 = phi i64 [ %r166, %subblock_0x400414_2 ], [ %r142, %subblock_0x4003ff_1 ]
  %r178 = phi i64 [ %r167, %subblock_0x400414_2 ], [ %r133, %subblock_0x4003ff_1 ]
  %r179 = phi i64 [ %r168, %subblock_0x400414_2 ], [ %r134, %subblock_0x4003ff_1 ]
  %r180 = phi i64 [ %r169, %subblock_0x400414_2 ], [ %r135, %subblock_0x4003ff_1 ]
  %r181 = phi i64 [ %r170, %subblock_0x400414_2 ], [ %r136, %subblock_0x4003ff_1 ]
  %r182 = phi i64 [ %r171, %subblock_0x400414_2 ], [ %r137, %subblock_0x4003ff_1 ]
  ; # 0x400418: inc    rbx
  ; r172 := (sadc_overflows r167 0x1 :: [64] 0x0 :: [1])
  %r183 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %r178, i64 1)
  %r184 = extractvalue { i64, i1 } %r183, 1
  ; r173 := (trunc r167 4)
  %r185 = trunc i64 %r178 to i4
  ; r174 := (uadc_overflows r173 0x1 :: [4] 0x0 :: [1])
  %r186 = call { i4, i1 } @llvm.uadd.with.overflow.i4(i4 %r185, i4 1)
  %r187 = extractvalue { i4, i1 } %r186, 1
  ; r175 := (bv_add r167 0x1 :: [64])
  %r188 = add i64 %r178, 1
  ; r176 := (bv_slt r175 0x0 :: [64])
  %r189 = icmp slt i64 %r188, 0
  ; r177 := (bv_eq r167 0xffffffffffffffff :: [64])
  %r190 = icmp eq i64 %r178, 18446744073709551615
  ; r178 := (trunc r175 8)
  %r191 = trunc i64 %r188 to i8
  ; r179 := (even_parity r178)
  %r192 = call i1 @reopt.EvenParity(i8 %r191)
  ; # 0x40041b: jmp    4003fa
  br label %block_0x4003fa
block_0x40041d:
  %r193 = phi i64 [ %r117, %subblock_0x4003fa_1 ], [ %r89, %subblock_0x4003f3_1 ], [ %r70, %subblock_0x4003eb_1 ]
  ; # 0x40041d: xor    eax,eax
  ; r181 := undef :: [1]
  ; # 0x40041f: jmp    400424
  br label %block_0x400424
block_0x400421:
  %r194 = phi i64 [ %r167, %subblock_0x400414_1 ]
  %r195 = phi i64 [ %r168, %subblock_0x400414_1 ]
  ; # 0x400421: mov    rax,rbx
  ; # 0x400424: pop    rdx
  ; r184 := *r183
  %r196 = inttoptr i64 %r195 to i64*
  %r197 = load i64* %r196
  ; r185 := (bv_add r183 0x8 :: [64])
  %r198 = add i64 %r195, 8
  ; # 0x400425: pop    rbx
  ; r186 := *r185
  %r199 = inttoptr i64 %r198 to i64*
  %r200 = load i64* %r199
  ; r187 := (bv_add r183 0x10 :: [64])
  %r201 = add i64 %r195, 16
  ; # 0x400426: pop    rbp
  ; r188 := *r187
  %r202 = inttoptr i64 %r201 to i64*
  %r203 = load i64* %r202
  ; r189 := (bv_add r183 0x18 :: [64])
  %r204 = add i64 %r195, 24
  ; # 0x400427: pop    r12
  ; r190 := *r189
  %r205 = inttoptr i64 %r204 to i64*
  %r206 = load i64* %r205
  ; r191 := (bv_add r183 0x20 :: [64])
  %r207 = add i64 %r195, 32
  ; # 0x400429: pop    r13
  ; r192 := *r191
  %r208 = inttoptr i64 %r207 to i64*
  %r209 = load i64* %r208
  ; r193 := (bv_add r183 0x28 :: [64])
  %r210 = add i64 %r195, 40
  ; # 0x40042b: ret
  ; r194 := (bv_add r183 0x30 :: [64])
  %r211 = add i64 %r195, 48
  %r212 = insertvalue { i64, i64, <2 x double> } undef, i64 %r194, 0
  %r213 = insertvalue { i64, i64, <2 x double> } %r212, i64 %r197, 1
  %r214 = insertvalue { i64, i64, <2 x double> } %r213, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r214
block_0x400424:
  %r215 = phi i64 [ 0, %block_0x40041d ], [ %iarg0, %subblock_0x4003b4_1 ]
  %r216 = phi i64 [ %r193, %block_0x40041d ], [ %r7, %subblock_0x4003b4_1 ]
  ; # 0x400424: pop    rdx
  ; r197 := *r196
  %r217 = inttoptr i64 %r216 to i64*
  %r218 = load i64* %r217
  ; r198 := (bv_add r196 0x8 :: [64])
  %r219 = add i64 %r216, 8
  ; # 0x400425: pop    rbx
  ; r199 := *r198
  %r220 = inttoptr i64 %r219 to i64*
  %r221 = load i64* %r220
  ; r200 := (bv_add r196 0x10 :: [64])
  %r222 = add i64 %r216, 16
  ; # 0x400426: pop    rbp
  ; r201 := *r200
  %r223 = inttoptr i64 %r222 to i64*
  %r224 = load i64* %r223
  ; r202 := (bv_add r196 0x18 :: [64])
  %r225 = add i64 %r216, 24
  ; # 0x400427: pop    r12
  ; r203 := *r202
  %r226 = inttoptr i64 %r225 to i64*
  %r227 = load i64* %r226
  ; r204 := (bv_add r196 0x20 :: [64])
  %r228 = add i64 %r216, 32
  ; # 0x400429: pop    r13
  ; r205 := *r204
  %r229 = inttoptr i64 %r228 to i64*
  %r230 = load i64* %r229
  ; r206 := (bv_add r196 0x28 :: [64])
  %r231 = add i64 %r216, 40
  ; # 0x40042b: ret
  ; r207 := (bv_add r196 0x30 :: [64])
  %r232 = add i64 %r216, 48
  %r233 = insertvalue { i64, i64, <2 x double> } undef, i64 %r215, 0
  %r234 = insertvalue { i64, i64, <2 x double> } %r233, i64 %r218, 1
  %r235 = insertvalue { i64, i64, <2 x double> } %r234, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r235
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen_arch_prctl(i64 %iarg0, i64 %iarg1, i64 %iarg2, i64 %iarg3, i64 %iarg4, i64 %iarg5) {
init:
  br label %block_0x40042c
block_0x40015a:
  %r0 = phi i64 [ %iarg3, %block_0x40042c ]
  %r1 = phi i64 [ %iarg2, %block_0x40042c ]
  %r2 = phi i64 [ %r71, %block_0x40042c ]
  %r3 = phi i64 [ %iarg1, %block_0x40042c ]
  %r4 = phi i64 [ %iarg0, %block_0x40042c ]
  %r5 = phi i64 [ %iarg4, %block_0x40042c ]
  %r6 = phi i64 [ %iarg5, %block_0x40042c ]
  ; # 0x40015a: mov    ah,0x0
  ; r11 := (bv_and unsupported (Initial register rax) 0xffffffffffff00ff :: [64])
  %r7 = and i64 undef, 18446744073709486335
  ; # 0x40015c: movzx  eax,ax
  ; r12 := (trunc unsupported (Initial register rax) 16)
  %r8 = trunc i64 undef to i16
  ; r13 := (bv_and r12 0xff :: [16])
  %r9 = and i16 %r8, 255
  ; r14 := (uext r13 32)
  %r10 = zext i16 %r9 to i32
  ; r15 := (uext r13 64)
  %r11 = zext i16 %r9 to i64
  ; # 0x40015f: mov    r10,rcx
  ; # 0x400162: syscall
  %r12 = call { i64, i1 } @reopt.SystemCall.Linux(i64 %r4, i64 %r3, i64 %r1, i64 %r0, i64 %r5, i64 %r6, i64 %r11)
  %r13 = extractvalue { i64, i1 } %r12, 0
  br label %block_0x400164
block_0x400164:
  %r14 = phi i64 [ %r13, %block_0x40015a ]
  %r15 = phi i64 [ undef, %block_0x40015a ]
  %r16 = phi i64 [ %r2, %block_0x40015a ]
  %r17 = phi i64 [ undef, %block_0x40015a ]
  %r18 = phi i64 [ undef, %block_0x40015a ]
  ; # 0x400164: cmp    rax,-0x84
  ; r22 := (ssbb_overflows r17 0xffffffffffffff7c :: [64] 0x0 :: [1])
  %r19 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %r14, i64 18446744073709551484)
  %r20 = extractvalue { i64, i1 } %r19, 1
  ; r23 := (trunc r17 4)
  %r21 = trunc i64 %r14 to i4
  ; r24 := (bv_ult r23 0xc :: [4])
  %r22 = icmp ult i4 %r21, 12
  ; r25 := (bv_ult r17 0xffffffffffffff7c :: [64])
  %r23 = icmp ult i64 %r14, 18446744073709551484
  ; r26 := (bv_add r17 0x84 :: [64])
  %r24 = add i64 %r14, 132
  ; r27 := (bv_slt r26 0x0 :: [64])
  %r25 = icmp slt i64 %r24, 0
  ; r28 := (bv_eq r17 0xffffffffffffff7c :: [64])
  %r26 = icmp eq i64 %r14, 18446744073709551484
  ; r29 := (trunc r26 8)
  %r27 = trunc i64 %r24 to i8
  ; r30 := (even_parity r29)
  %r28 = call i1 @reopt.EvenParity(i8 %r27)
  ; # 0x40016a: jbe    40017b
  ; r31 := (bv_ule r17 0xffffffffffffff7c :: [64])
  %r29 = icmp ule i64 %r14, 18446744073709551484
  br i1 %r29, label %subblock_0x400164_1, label %subblock_0x400164_2
subblock_0x400164_1:
  br label %block_0x40017b
subblock_0x400164_2:
  br label %block_0x40016c
block_0x40016c:
  %r30 = phi i64 [ %r14, %subblock_0x400164_2 ]
  %r31 = phi i64 [ %r15, %subblock_0x400164_2 ]
  %r32 = phi i64 [ %r16, %subblock_0x400164_2 ]
  %r33 = phi i64 [ %r17, %subblock_0x400164_2 ]
  %r34 = phi i64 [ %r18, %subblock_0x400164_2 ]
  ; # 0x40016c: neg    eax
  ; r37 := (trunc r32 32)
  %r35 = trunc i64 %r30 to i32
  ; r38 := (bv_eq r37 0x0 :: [32])
  %r36 = icmp eq i32 %r35, 0
  ; r39 := (mux r38 0x0 :: [1] 0x1 :: [1])
  %r37 = select i1 %r36, i1 0, i1 1
  ; r40 := (ssbb_overflows 0x0 :: [32] r37 0x0 :: [1])
  %r38 = call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 0, i32 %r35)
  %r39 = extractvalue { i32, i1 } %r38, 1
  ; r41 := (trunc r32 4)
  %r40 = trunc i64 %r30 to i4
  ; r42 := (bv_ult 0x0 :: [4] r41)
  %r41 = icmp ult i4 0, %r40
  ; r43 := (bv_sub 0x0 :: [32] r37)
  %r42 = sub i32 0, %r35
  ; r44 := (bv_slt r43 0x0 :: [32])
  %r43 = icmp slt i32 %r42, 0
  ; r45 := (trunc r43 8)
  %r44 = trunc i32 %r42 to i8
  ; r46 := (even_parity r45)
  %r45 = call i1 @reopt.EvenParity(i8 %r44)
  ; r47 := (uext r43 64)
  %r46 = zext i32 %r42 to i64
  ; # 0x40016e: push   rax
  ; r48 := (bv_add r34 0xfffffffffffffff8 :: [64])
  %r47 = add i64 %r32, 18446744073709551608
  ; *(r48) = r47
  %r48 = inttoptr i64 %r47 to i64*
  store i64 %r46, i64* %r48
  ; # 0x40016f: call   40017c
  ; r49 := (bv_add r34 0xfffffffffffffff0 :: [64])
  %r49 = add i64 %r32, 18446744073709551600
  ; r52 := (bv_add r49 0x8 :: [64])
  %r50 = add i64 %r49, 8
  %r51 = call { i64, i64, <2 x double> } @reopt_gen___errno_location(i64 %r34, i64 %r33, i64 %r31)
  %r52 = extractvalue { i64, i64, <2 x double> } %r51, 0
  %r53 = extractvalue { i64, i64, <2 x double> } %r51, 1
  br label %block_0x400174
block_0x400174:
  %r54 = phi i64 [ %r52, %block_0x40016c ]
  %r55 = phi i64 [ %r50, %block_0x40016c ]
  ; # 0x400174: pop    rcx
  ; r55 := *r54
  %r56 = inttoptr i64 %r55 to i64*
  %r57 = load i64* %r56
  ; r56 := (bv_add r54 0x8 :: [64])
  %r58 = add i64 %r55, 8
  ; # 0x400175: mov    DWORD PTR [rax],ecx
  ; r57 := (trunc r55 32)
  %r59 = trunc i64 %r57 to i32
  ; *(r53) = r57
  %r60 = inttoptr i64 %r54 to i32*
  store i32 %r59, i32* %r60
  ; # 0x400177: or     rax,-0x1
  ; r58 := undef :: [1]
  ; # 0x40017b: ret
  ; r59 := (bv_add r54 0x10 :: [64])
  %r61 = add i64 %r55, 16
  %r62 = insertvalue { i64, i64, <2 x double> } undef, i64 undef, 0
  %r63 = insertvalue { i64, i64, <2 x double> } %r62, i64 undef, 1
  %r64 = insertvalue { i64, i64, <2 x double> } %r63, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r64
block_0x40017b:
  ; # 0x40017b: ret
  ; r60 := (bv_add unsupported (Initial register rsp) 0x8 :: [64])
  %r65 = add i64 undef, 8
  %r66 = insertvalue { i64, i64, <2 x double> } undef, i64 undef, 0
  %r67 = insertvalue { i64, i64, <2 x double> } %r66, i64 undef, 1
  %r68 = insertvalue { i64, i64, <2 x double> } %r67, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r68
block_0x40042c:
  ; r0 := (alloca 0x10 :: [64])
  %r69 = alloca i8, i64 16
  %r70 = ptrtoint i8* %r69 to i64
  ; r1 := (bv_add r0 0x10 :: [64])
  %r71 = add i64 %r70, 16
  ; # 0x40042c: mov    al,-0x62
  ; r2 := (bv_and unsupported (Initial register rax) 0xffffffffffffff00 :: [64])
  %r72 = and i64 undef, 18446744073709551360
  ; r3 := (bv_or r2 0x9e :: [64])
  %r73 = or i64 %r72, 158
  ; # 0x40042e: jmp    40015a
  br label %block_0x40015a
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen_close(i64 %iarg0, i64 %iarg1, i64 %iarg2, i64 %iarg3, i64 %iarg4, i64 %iarg5) {
init:
  br label %block_0x400494
block_0x40015a:
  %r0 = phi i64 [ %iarg3, %block_0x400494 ]
  %r1 = phi i64 [ %iarg2, %block_0x400494 ]
  %r2 = phi i64 [ %r71, %block_0x400494 ]
  %r3 = phi i64 [ %iarg1, %block_0x400494 ]
  %r4 = phi i64 [ %iarg0, %block_0x400494 ]
  %r5 = phi i64 [ %iarg4, %block_0x400494 ]
  %r6 = phi i64 [ %iarg5, %block_0x400494 ]
  ; # 0x40015a: mov    ah,0x0
  ; r11 := (bv_and unsupported (Initial register rax) 0xffffffffffff00ff :: [64])
  %r7 = and i64 undef, 18446744073709486335
  ; # 0x40015c: movzx  eax,ax
  ; r12 := (trunc unsupported (Initial register rax) 16)
  %r8 = trunc i64 undef to i16
  ; r13 := (bv_and r12 0xff :: [16])
  %r9 = and i16 %r8, 255
  ; r14 := (uext r13 32)
  %r10 = zext i16 %r9 to i32
  ; r15 := (uext r13 64)
  %r11 = zext i16 %r9 to i64
  ; # 0x40015f: mov    r10,rcx
  ; # 0x400162: syscall
  %r12 = call { i64, i1 } @reopt.SystemCall.Linux(i64 %r4, i64 %r3, i64 %r1, i64 %r0, i64 %r5, i64 %r6, i64 %r11)
  %r13 = extractvalue { i64, i1 } %r12, 0
  br label %block_0x400164
block_0x400164:
  %r14 = phi i64 [ %r13, %block_0x40015a ]
  %r15 = phi i64 [ undef, %block_0x40015a ]
  %r16 = phi i64 [ %r2, %block_0x40015a ]
  %r17 = phi i64 [ undef, %block_0x40015a ]
  %r18 = phi i64 [ undef, %block_0x40015a ]
  ; # 0x400164: cmp    rax,-0x84
  ; r22 := (ssbb_overflows r17 0xffffffffffffff7c :: [64] 0x0 :: [1])
  %r19 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %r14, i64 18446744073709551484)
  %r20 = extractvalue { i64, i1 } %r19, 1
  ; r23 := (trunc r17 4)
  %r21 = trunc i64 %r14 to i4
  ; r24 := (bv_ult r23 0xc :: [4])
  %r22 = icmp ult i4 %r21, 12
  ; r25 := (bv_ult r17 0xffffffffffffff7c :: [64])
  %r23 = icmp ult i64 %r14, 18446744073709551484
  ; r26 := (bv_add r17 0x84 :: [64])
  %r24 = add i64 %r14, 132
  ; r27 := (bv_slt r26 0x0 :: [64])
  %r25 = icmp slt i64 %r24, 0
  ; r28 := (bv_eq r17 0xffffffffffffff7c :: [64])
  %r26 = icmp eq i64 %r14, 18446744073709551484
  ; r29 := (trunc r26 8)
  %r27 = trunc i64 %r24 to i8
  ; r30 := (even_parity r29)
  %r28 = call i1 @reopt.EvenParity(i8 %r27)
  ; # 0x40016a: jbe    40017b
  ; r31 := (bv_ule r17 0xffffffffffffff7c :: [64])
  %r29 = icmp ule i64 %r14, 18446744073709551484
  br i1 %r29, label %subblock_0x400164_1, label %subblock_0x400164_2
subblock_0x400164_1:
  br label %block_0x40017b
subblock_0x400164_2:
  br label %block_0x40016c
block_0x40016c:
  %r30 = phi i64 [ %r14, %subblock_0x400164_2 ]
  %r31 = phi i64 [ %r15, %subblock_0x400164_2 ]
  %r32 = phi i64 [ %r16, %subblock_0x400164_2 ]
  %r33 = phi i64 [ %r17, %subblock_0x400164_2 ]
  %r34 = phi i64 [ %r18, %subblock_0x400164_2 ]
  ; # 0x40016c: neg    eax
  ; r37 := (trunc r32 32)
  %r35 = trunc i64 %r30 to i32
  ; r38 := (bv_eq r37 0x0 :: [32])
  %r36 = icmp eq i32 %r35, 0
  ; r39 := (mux r38 0x0 :: [1] 0x1 :: [1])
  %r37 = select i1 %r36, i1 0, i1 1
  ; r40 := (ssbb_overflows 0x0 :: [32] r37 0x0 :: [1])
  %r38 = call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 0, i32 %r35)
  %r39 = extractvalue { i32, i1 } %r38, 1
  ; r41 := (trunc r32 4)
  %r40 = trunc i64 %r30 to i4
  ; r42 := (bv_ult 0x0 :: [4] r41)
  %r41 = icmp ult i4 0, %r40
  ; r43 := (bv_sub 0x0 :: [32] r37)
  %r42 = sub i32 0, %r35
  ; r44 := (bv_slt r43 0x0 :: [32])
  %r43 = icmp slt i32 %r42, 0
  ; r45 := (trunc r43 8)
  %r44 = trunc i32 %r42 to i8
  ; r46 := (even_parity r45)
  %r45 = call i1 @reopt.EvenParity(i8 %r44)
  ; r47 := (uext r43 64)
  %r46 = zext i32 %r42 to i64
  ; # 0x40016e: push   rax
  ; r48 := (bv_add r34 0xfffffffffffffff8 :: [64])
  %r47 = add i64 %r32, 18446744073709551608
  ; *(r48) = r47
  %r48 = inttoptr i64 %r47 to i64*
  store i64 %r46, i64* %r48
  ; # 0x40016f: call   40017c
  ; r49 := (bv_add r34 0xfffffffffffffff0 :: [64])
  %r49 = add i64 %r32, 18446744073709551600
  ; r52 := (bv_add r49 0x8 :: [64])
  %r50 = add i64 %r49, 8
  %r51 = call { i64, i64, <2 x double> } @reopt_gen___errno_location(i64 %r34, i64 %r33, i64 %r31)
  %r52 = extractvalue { i64, i64, <2 x double> } %r51, 0
  %r53 = extractvalue { i64, i64, <2 x double> } %r51, 1
  br label %block_0x400174
block_0x400174:
  %r54 = phi i64 [ %r52, %block_0x40016c ]
  %r55 = phi i64 [ %r50, %block_0x40016c ]
  ; # 0x400174: pop    rcx
  ; r55 := *r54
  %r56 = inttoptr i64 %r55 to i64*
  %r57 = load i64* %r56
  ; r56 := (bv_add r54 0x8 :: [64])
  %r58 = add i64 %r55, 8
  ; # 0x400175: mov    DWORD PTR [rax],ecx
  ; r57 := (trunc r55 32)
  %r59 = trunc i64 %r57 to i32
  ; *(r53) = r57
  %r60 = inttoptr i64 %r54 to i32*
  store i32 %r59, i32* %r60
  ; # 0x400177: or     rax,-0x1
  ; r58 := undef :: [1]
  ; # 0x40017b: ret
  ; r59 := (bv_add r54 0x10 :: [64])
  %r61 = add i64 %r55, 16
  %r62 = insertvalue { i64, i64, <2 x double> } undef, i64 undef, 0
  %r63 = insertvalue { i64, i64, <2 x double> } %r62, i64 undef, 1
  %r64 = insertvalue { i64, i64, <2 x double> } %r63, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r64
block_0x40017b:
  ; # 0x40017b: ret
  ; r60 := (bv_add unsupported (Initial register rsp) 0x8 :: [64])
  %r65 = add i64 undef, 8
  %r66 = insertvalue { i64, i64, <2 x double> } undef, i64 undef, 0
  %r67 = insertvalue { i64, i64, <2 x double> } %r66, i64 undef, 1
  %r68 = insertvalue { i64, i64, <2 x double> } %r67, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r68
block_0x400494:
  ; r0 := (alloca 0x10 :: [64])
  %r69 = alloca i8, i64 16
  %r70 = ptrtoint i8* %r69 to i64
  ; r1 := (bv_add r0 0x10 :: [64])
  %r71 = add i64 %r70, 16
  ; # 0x400494: mov    al,0x3
  ; r2 := (bv_and unsupported (Initial register rax) 0xffffffffffffff00 :: [64])
  %r72 = and i64 undef, 18446744073709551360
  ; r3 := (bv_or r2 0x3 :: [64])
  %r73 = or i64 %r72, 3
  ; # 0x400496: jmp    40015a
  br label %block_0x40015a
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen_open(i64 %iarg0, i64 %iarg1, i64 %iarg2, i64 %iarg3, i64 %iarg4, i64 %iarg5) {
init:
  br label %block_0x40049c
block_0x40015a:
  %r0 = phi i64 [ %iarg3, %block_0x40049c ]
  %r1 = phi i64 [ %iarg2, %block_0x40049c ]
  %r2 = phi i64 [ %r72, %block_0x40049c ]
  %r3 = phi i64 [ %iarg1, %block_0x40049c ]
  %r4 = phi i64 [ %iarg0, %block_0x40049c ]
  %r5 = phi i64 [ %iarg4, %block_0x40049c ]
  %r6 = phi i64 [ %iarg5, %block_0x40049c ]
  ; # 0x40015a: mov    ah,0x0
  ; r11 := (bv_and unsupported (Initial register rax) 0xffffffffffff00ff :: [64])
  %r7 = and i64 undef, 18446744073709486335
  ; # 0x40015c: movzx  eax,ax
  ; r12 := (trunc unsupported (Initial register rax) 16)
  %r8 = trunc i64 undef to i16
  ; r13 := (bv_and r12 0xff :: [16])
  %r9 = and i16 %r8, 255
  ; r14 := (uext r13 32)
  %r10 = zext i16 %r9 to i32
  ; r15 := (uext r13 64)
  %r11 = zext i16 %r9 to i64
  ; # 0x40015f: mov    r10,rcx
  ; # 0x400162: syscall
  %r12 = call { i64, i1 } @reopt.SystemCall.Linux(i64 %r4, i64 %r3, i64 %r1, i64 %r0, i64 %r5, i64 %r6, i64 %r11)
  %r13 = extractvalue { i64, i1 } %r12, 0
  br label %block_0x400164
block_0x400164:
  %r14 = phi i64 [ %r13, %block_0x40015a ]
  %r15 = phi i64 [ undef, %block_0x40015a ]
  %r16 = phi i64 [ %r2, %block_0x40015a ]
  %r17 = phi i64 [ undef, %block_0x40015a ]
  %r18 = phi i64 [ undef, %block_0x40015a ]
  ; # 0x400164: cmp    rax,-0x84
  ; r22 := (ssbb_overflows r17 0xffffffffffffff7c :: [64] 0x0 :: [1])
  %r19 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %r14, i64 18446744073709551484)
  %r20 = extractvalue { i64, i1 } %r19, 1
  ; r23 := (trunc r17 4)
  %r21 = trunc i64 %r14 to i4
  ; r24 := (bv_ult r23 0xc :: [4])
  %r22 = icmp ult i4 %r21, 12
  ; r25 := (bv_ult r17 0xffffffffffffff7c :: [64])
  %r23 = icmp ult i64 %r14, 18446744073709551484
  ; r26 := (bv_add r17 0x84 :: [64])
  %r24 = add i64 %r14, 132
  ; r27 := (bv_slt r26 0x0 :: [64])
  %r25 = icmp slt i64 %r24, 0
  ; r28 := (bv_eq r17 0xffffffffffffff7c :: [64])
  %r26 = icmp eq i64 %r14, 18446744073709551484
  ; r29 := (trunc r26 8)
  %r27 = trunc i64 %r24 to i8
  ; r30 := (even_parity r29)
  %r28 = call i1 @reopt.EvenParity(i8 %r27)
  ; # 0x40016a: jbe    40017b
  ; r31 := (bv_ule r17 0xffffffffffffff7c :: [64])
  %r29 = icmp ule i64 %r14, 18446744073709551484
  br i1 %r29, label %subblock_0x400164_1, label %subblock_0x400164_2
subblock_0x400164_1:
  br label %block_0x40017b
subblock_0x400164_2:
  br label %block_0x40016c
block_0x40016c:
  %r30 = phi i64 [ %r14, %subblock_0x400164_2 ]
  %r31 = phi i64 [ %r15, %subblock_0x400164_2 ]
  %r32 = phi i64 [ %r16, %subblock_0x400164_2 ]
  %r33 = phi i64 [ %r17, %subblock_0x400164_2 ]
  %r34 = phi i64 [ %r18, %subblock_0x400164_2 ]
  ; # 0x40016c: neg    eax
  ; r37 := (trunc r32 32)
  %r35 = trunc i64 %r30 to i32
  ; r38 := (bv_eq r37 0x0 :: [32])
  %r36 = icmp eq i32 %r35, 0
  ; r39 := (mux r38 0x0 :: [1] 0x1 :: [1])
  %r37 = select i1 %r36, i1 0, i1 1
  ; r40 := (ssbb_overflows 0x0 :: [32] r37 0x0 :: [1])
  %r38 = call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 0, i32 %r35)
  %r39 = extractvalue { i32, i1 } %r38, 1
  ; r41 := (trunc r32 4)
  %r40 = trunc i64 %r30 to i4
  ; r42 := (bv_ult 0x0 :: [4] r41)
  %r41 = icmp ult i4 0, %r40
  ; r43 := (bv_sub 0x0 :: [32] r37)
  %r42 = sub i32 0, %r35
  ; r44 := (bv_slt r43 0x0 :: [32])
  %r43 = icmp slt i32 %r42, 0
  ; r45 := (trunc r43 8)
  %r44 = trunc i32 %r42 to i8
  ; r46 := (even_parity r45)
  %r45 = call i1 @reopt.EvenParity(i8 %r44)
  ; r47 := (uext r43 64)
  %r46 = zext i32 %r42 to i64
  ; # 0x40016e: push   rax
  ; r48 := (bv_add r34 0xfffffffffffffff8 :: [64])
  %r47 = add i64 %r32, 18446744073709551608
  ; *(r48) = r47
  %r48 = inttoptr i64 %r47 to i64*
  store i64 %r46, i64* %r48
  ; # 0x40016f: call   40017c
  ; r49 := (bv_add r34 0xfffffffffffffff0 :: [64])
  %r49 = add i64 %r32, 18446744073709551600
  ; r52 := (bv_add r49 0x8 :: [64])
  %r50 = add i64 %r49, 8
  %r51 = call { i64, i64, <2 x double> } @reopt_gen___errno_location(i64 %r34, i64 %r33, i64 %r31)
  %r52 = extractvalue { i64, i64, <2 x double> } %r51, 0
  %r53 = extractvalue { i64, i64, <2 x double> } %r51, 1
  br label %block_0x400174
block_0x400174:
  %r54 = phi i64 [ %r52, %block_0x40016c ]
  %r55 = phi i64 [ %r50, %block_0x40016c ]
  ; # 0x400174: pop    rcx
  ; r55 := *r54
  %r56 = inttoptr i64 %r55 to i64*
  %r57 = load i64* %r56
  ; r56 := (bv_add r54 0x8 :: [64])
  %r58 = add i64 %r55, 8
  ; # 0x400175: mov    DWORD PTR [rax],ecx
  ; r57 := (trunc r55 32)
  %r59 = trunc i64 %r57 to i32
  ; *(r53) = r57
  %r60 = inttoptr i64 %r54 to i32*
  store i32 %r59, i32* %r60
  ; # 0x400177: or     rax,-0x1
  ; r58 := undef :: [1]
  ; # 0x40017b: ret
  ; r59 := (bv_add r54 0x10 :: [64])
  %r61 = add i64 %r55, 16
  %r62 = insertvalue { i64, i64, <2 x double> } undef, i64 18446744073709551615, 0
  %r63 = insertvalue { i64, i64, <2 x double> } %r62, i64 undef, 1
  %r64 = insertvalue { i64, i64, <2 x double> } %r63, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r64
block_0x40017b:
  %r65 = phi i64 [ %r14, %subblock_0x400164_1 ]
  ; # 0x40017b: ret
  ; r61 := (bv_add unsupported (Initial register rsp) 0x8 :: [64])
  %r66 = add i64 undef, 8
  %r67 = insertvalue { i64, i64, <2 x double> } undef, i64 %r65, 0
  %r68 = insertvalue { i64, i64, <2 x double> } %r67, i64 undef, 1
  %r69 = insertvalue { i64, i64, <2 x double> } %r68, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r69
block_0x40049c:
  ; r0 := (alloca 0x10 :: [64])
  %r70 = alloca i8, i64 16
  %r71 = ptrtoint i8* %r70 to i64
  ; r1 := (bv_add r0 0x10 :: [64])
  %r72 = add i64 %r71, 16
  ; # 0x40049c: mov    al,0x2
  ; r2 := (bv_and unsupported (Initial register rax) 0xffffffffffffff00 :: [64])
  %r73 = and i64 undef, 18446744073709551360
  ; r3 := (bv_or r2 0x2 :: [64])
  %r74 = or i64 %r73, 2
  ; # 0x40049e: jmp    40015a
  br label %block_0x40015a
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen_read(i64 %iarg0, i64 %iarg1, i64 %iarg2, i64 %iarg3, i64 %iarg4, i64 %iarg5) {
init:
  br label %block_0x4004a4
block_0x40015a:
  %r0 = phi i64 [ %iarg3, %block_0x4004a4 ]
  %r1 = phi i64 [ %iarg2, %block_0x4004a4 ]
  %r2 = phi i64 [ %r74, %block_0x4004a4 ]
  %r3 = phi i64 [ %iarg1, %block_0x4004a4 ]
  %r4 = phi i64 [ %iarg0, %block_0x4004a4 ]
  %r5 = phi i64 [ %iarg4, %block_0x4004a4 ]
  %r6 = phi i64 [ %iarg5, %block_0x4004a4 ]
  ; # 0x40015a: mov    ah,0x0
  ; r10 := (bv_and unsupported (Initial register rax) 0xffffffffffff00ff :: [64])
  %r7 = and i64 undef, 18446744073709486335
  ; # 0x40015c: movzx  eax,ax
  ; r11 := (trunc unsupported (Initial register rax) 16)
  %r8 = trunc i64 undef to i16
  ; r12 := (bv_and r11 0xff :: [16])
  %r9 = and i16 %r8, 255
  ; r13 := (uext r12 32)
  %r10 = zext i16 %r9 to i32
  ; r14 := (uext r12 64)
  %r11 = zext i16 %r9 to i64
  ; # 0x40015f: mov    r10,rcx
  ; # 0x400162: syscall
  %r12 = call { i64, i1 } @reopt.SystemCall.Linux(i64 %r4, i64 %r3, i64 %r1, i64 %r0, i64 %r5, i64 %r6, i64 %r11)
  %r13 = extractvalue { i64, i1 } %r12, 0
  br label %block_0x400164
block_0x400164:
  %r14 = phi i64 [ %r13, %block_0x40015a ]
  %r15 = phi i64 [ undef, %block_0x40015a ]
  %r16 = phi i64 [ %r2, %block_0x40015a ]
  %r17 = phi i64 [ undef, %block_0x40015a ]
  %r18 = phi i64 [ undef, %block_0x40015a ]
  ; # 0x400164: cmp    rax,-0x84
  ; r21 := (ssbb_overflows r16 0xffffffffffffff7c :: [64] 0x0 :: [1])
  %r19 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %r14, i64 18446744073709551484)
  %r20 = extractvalue { i64, i1 } %r19, 1
  ; r22 := (trunc r16 4)
  %r21 = trunc i64 %r14 to i4
  ; r23 := (bv_ult r22 0xc :: [4])
  %r22 = icmp ult i4 %r21, 12
  ; r24 := (bv_ult r16 0xffffffffffffff7c :: [64])
  %r23 = icmp ult i64 %r14, 18446744073709551484
  ; r25 := (bv_add r16 0x84 :: [64])
  %r24 = add i64 %r14, 132
  ; r26 := (bv_slt r25 0x0 :: [64])
  %r25 = icmp slt i64 %r24, 0
  ; r27 := (bv_eq r16 0xffffffffffffff7c :: [64])
  %r26 = icmp eq i64 %r14, 18446744073709551484
  ; r28 := (trunc r25 8)
  %r27 = trunc i64 %r24 to i8
  ; r29 := (even_parity r28)
  %r28 = call i1 @reopt.EvenParity(i8 %r27)
  ; # 0x40016a: jbe    40017b
  ; r30 := (bv_ule r16 0xffffffffffffff7c :: [64])
  %r29 = icmp ule i64 %r14, 18446744073709551484
  br i1 %r29, label %subblock_0x400164_1, label %subblock_0x400164_2
subblock_0x400164_1:
  br label %block_0x40017b
subblock_0x400164_2:
  br label %block_0x40016c
block_0x40016c:
  %r30 = phi i64 [ %r14, %subblock_0x400164_2 ]
  %r31 = phi i64 [ %r15, %subblock_0x400164_2 ]
  %r32 = phi i64 [ %r16, %subblock_0x400164_2 ]
  %r33 = phi i64 [ %r17, %subblock_0x400164_2 ]
  %r34 = phi i64 [ %r18, %subblock_0x400164_2 ]
  ; # 0x40016c: neg    eax
  ; r36 := (trunc r31 32)
  %r35 = trunc i64 %r30 to i32
  ; r37 := (bv_eq r36 0x0 :: [32])
  %r36 = icmp eq i32 %r35, 0
  ; r38 := (mux r37 0x0 :: [1] 0x1 :: [1])
  %r37 = select i1 %r36, i1 0, i1 1
  ; r39 := (ssbb_overflows 0x0 :: [32] r36 0x0 :: [1])
  %r38 = call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 0, i32 %r35)
  %r39 = extractvalue { i32, i1 } %r38, 1
  ; r40 := (trunc r31 4)
  %r40 = trunc i64 %r30 to i4
  ; r41 := (bv_ult 0x0 :: [4] r40)
  %r41 = icmp ult i4 0, %r40
  ; r42 := (bv_sub 0x0 :: [32] r36)
  %r42 = sub i32 0, %r35
  ; r43 := (bv_slt r42 0x0 :: [32])
  %r43 = icmp slt i32 %r42, 0
  ; r44 := (trunc r42 8)
  %r44 = trunc i32 %r42 to i8
  ; r45 := (even_parity r44)
  %r45 = call i1 @reopt.EvenParity(i8 %r44)
  ; r46 := (uext r42 64)
  %r46 = zext i32 %r42 to i64
  ; # 0x40016e: push   rax
  ; r47 := (bv_add r33 0xfffffffffffffff8 :: [64])
  %r47 = add i64 %r32, 18446744073709551608
  ; *(r47) = r46
  %r48 = inttoptr i64 %r47 to i64*
  store i64 %r46, i64* %r48
  ; # 0x40016f: call   40017c
  ; r48 := (bv_add r33 0xfffffffffffffff0 :: [64])
  %r49 = add i64 %r32, 18446744073709551600
  ; r51 := (bv_add r48 0x8 :: [64])
  %r50 = add i64 %r49, 8
  %r51 = call { i64, i64, <2 x double> } @reopt_gen___errno_location(i64 %r34, i64 %r33, i64 %r31)
  %r52 = extractvalue { i64, i64, <2 x double> } %r51, 0
  %r53 = extractvalue { i64, i64, <2 x double> } %r51, 1
  br label %block_0x400174
block_0x400174:
  %r54 = phi i64 [ %r52, %block_0x40016c ]
  %r55 = phi i64 [ %r53, %block_0x40016c ]
  %r56 = phi i64 [ %r50, %block_0x40016c ]
  ; # 0x400174: pop    rcx
  ; r55 := *r54
  %r57 = inttoptr i64 %r56 to i64*
  %r58 = load i64* %r57
  ; r56 := (bv_add r54 0x8 :: [64])
  %r59 = add i64 %r56, 8
  ; # 0x400175: mov    DWORD PTR [rax],ecx
  ; r57 := (trunc r55 32)
  %r60 = trunc i64 %r58 to i32
  ; *(r52) = r57
  %r61 = inttoptr i64 %r54 to i32*
  store i32 %r60, i32* %r61
  ; # 0x400177: or     rax,-0x1
  ; r58 := undef :: [1]
  ; # 0x40017b: ret
  ; r59 := (bv_add r54 0x10 :: [64])
  %r62 = add i64 %r56, 16
  %r63 = insertvalue { i64, i64, <2 x double> } undef, i64 18446744073709551615, 0
  %r64 = insertvalue { i64, i64, <2 x double> } %r63, i64 %r55, 1
  %r65 = insertvalue { i64, i64, <2 x double> } %r64, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r65
block_0x40017b:
  %r66 = phi i64 [ %r14, %subblock_0x400164_1 ]
  %r67 = phi i64 [ %r15, %subblock_0x400164_1 ]
  ; # 0x40017b: ret
  ; r62 := (bv_add unsupported (Initial register rsp) 0x8 :: [64])
  %r68 = add i64 undef, 8
  %r69 = insertvalue { i64, i64, <2 x double> } undef, i64 %r66, 0
  %r70 = insertvalue { i64, i64, <2 x double> } %r69, i64 %r67, 1
  %r71 = insertvalue { i64, i64, <2 x double> } %r70, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r71
block_0x4004a4:
  ; r0 := (alloca 0x10 :: [64])
  %r72 = alloca i8, i64 16
  %r73 = ptrtoint i8* %r72 to i64
  ; r1 := (bv_add r0 0x10 :: [64])
  %r74 = add i64 %r73, 16
  ; # 0x4004a4: mov    al,0x0
  ; r2 := (bv_and unsupported (Initial register rax) 0xffffffffffffff00 :: [64])
  %r75 = and i64 undef, 18446744073709551360
  ; # 0x4004a6: jmp    40015a
  br label %block_0x40015a
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen___libc_write(i64 %iarg0, i64 %iarg1, i64 %iarg2, i64 %iarg3, i64 %iarg4, i64 %iarg5) {
init:
  br label %block_0x4004ac
block_0x40015a:
  %r0 = phi i64 [ %iarg3, %block_0x4004ac ]
  %r1 = phi i64 [ %iarg2, %block_0x4004ac ]
  %r2 = phi i64 [ %r71, %block_0x4004ac ]
  %r3 = phi i64 [ %iarg1, %block_0x4004ac ]
  %r4 = phi i64 [ %iarg0, %block_0x4004ac ]
  %r5 = phi i64 [ %iarg4, %block_0x4004ac ]
  %r6 = phi i64 [ %iarg5, %block_0x4004ac ]
  ; # 0x40015a: mov    ah,0x0
  ; r11 := (bv_and unsupported (Initial register rax) 0xffffffffffff00ff :: [64])
  %r7 = and i64 undef, 18446744073709486335
  ; # 0x40015c: movzx  eax,ax
  ; r12 := (trunc unsupported (Initial register rax) 16)
  %r8 = trunc i64 undef to i16
  ; r13 := (bv_and r12 0xff :: [16])
  %r9 = and i16 %r8, 255
  ; r14 := (uext r13 32)
  %r10 = zext i16 %r9 to i32
  ; r15 := (uext r13 64)
  %r11 = zext i16 %r9 to i64
  ; # 0x40015f: mov    r10,rcx
  ; # 0x400162: syscall
  %r12 = call { i64, i1 } @reopt.SystemCall.Linux(i64 %r4, i64 %r3, i64 %r1, i64 %r0, i64 %r5, i64 %r6, i64 %r11)
  %r13 = extractvalue { i64, i1 } %r12, 0
  br label %block_0x400164
block_0x400164:
  %r14 = phi i64 [ %r13, %block_0x40015a ]
  %r15 = phi i64 [ undef, %block_0x40015a ]
  %r16 = phi i64 [ %r2, %block_0x40015a ]
  %r17 = phi i64 [ undef, %block_0x40015a ]
  %r18 = phi i64 [ undef, %block_0x40015a ]
  ; # 0x400164: cmp    rax,-0x84
  ; r22 := (ssbb_overflows r17 0xffffffffffffff7c :: [64] 0x0 :: [1])
  %r19 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %r14, i64 18446744073709551484)
  %r20 = extractvalue { i64, i1 } %r19, 1
  ; r23 := (trunc r17 4)
  %r21 = trunc i64 %r14 to i4
  ; r24 := (bv_ult r23 0xc :: [4])
  %r22 = icmp ult i4 %r21, 12
  ; r25 := (bv_ult r17 0xffffffffffffff7c :: [64])
  %r23 = icmp ult i64 %r14, 18446744073709551484
  ; r26 := (bv_add r17 0x84 :: [64])
  %r24 = add i64 %r14, 132
  ; r27 := (bv_slt r26 0x0 :: [64])
  %r25 = icmp slt i64 %r24, 0
  ; r28 := (bv_eq r17 0xffffffffffffff7c :: [64])
  %r26 = icmp eq i64 %r14, 18446744073709551484
  ; r29 := (trunc r26 8)
  %r27 = trunc i64 %r24 to i8
  ; r30 := (even_parity r29)
  %r28 = call i1 @reopt.EvenParity(i8 %r27)
  ; # 0x40016a: jbe    40017b
  ; r31 := (bv_ule r17 0xffffffffffffff7c :: [64])
  %r29 = icmp ule i64 %r14, 18446744073709551484
  br i1 %r29, label %subblock_0x400164_1, label %subblock_0x400164_2
subblock_0x400164_1:
  br label %block_0x40017b
subblock_0x400164_2:
  br label %block_0x40016c
block_0x40016c:
  %r30 = phi i64 [ %r14, %subblock_0x400164_2 ]
  %r31 = phi i64 [ %r15, %subblock_0x400164_2 ]
  %r32 = phi i64 [ %r16, %subblock_0x400164_2 ]
  %r33 = phi i64 [ %r17, %subblock_0x400164_2 ]
  %r34 = phi i64 [ %r18, %subblock_0x400164_2 ]
  ; # 0x40016c: neg    eax
  ; r37 := (trunc r32 32)
  %r35 = trunc i64 %r30 to i32
  ; r38 := (bv_eq r37 0x0 :: [32])
  %r36 = icmp eq i32 %r35, 0
  ; r39 := (mux r38 0x0 :: [1] 0x1 :: [1])
  %r37 = select i1 %r36, i1 0, i1 1
  ; r40 := (ssbb_overflows 0x0 :: [32] r37 0x0 :: [1])
  %r38 = call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 0, i32 %r35)
  %r39 = extractvalue { i32, i1 } %r38, 1
  ; r41 := (trunc r32 4)
  %r40 = trunc i64 %r30 to i4
  ; r42 := (bv_ult 0x0 :: [4] r41)
  %r41 = icmp ult i4 0, %r40
  ; r43 := (bv_sub 0x0 :: [32] r37)
  %r42 = sub i32 0, %r35
  ; r44 := (bv_slt r43 0x0 :: [32])
  %r43 = icmp slt i32 %r42, 0
  ; r45 := (trunc r43 8)
  %r44 = trunc i32 %r42 to i8
  ; r46 := (even_parity r45)
  %r45 = call i1 @reopt.EvenParity(i8 %r44)
  ; r47 := (uext r43 64)
  %r46 = zext i32 %r42 to i64
  ; # 0x40016e: push   rax
  ; r48 := (bv_add r34 0xfffffffffffffff8 :: [64])
  %r47 = add i64 %r32, 18446744073709551608
  ; *(r48) = r47
  %r48 = inttoptr i64 %r47 to i64*
  store i64 %r46, i64* %r48
  ; # 0x40016f: call   40017c
  ; r49 := (bv_add r34 0xfffffffffffffff0 :: [64])
  %r49 = add i64 %r32, 18446744073709551600
  ; r52 := (bv_add r49 0x8 :: [64])
  %r50 = add i64 %r49, 8
  %r51 = call { i64, i64, <2 x double> } @reopt_gen___errno_location(i64 %r34, i64 %r33, i64 %r31)
  %r52 = extractvalue { i64, i64, <2 x double> } %r51, 0
  %r53 = extractvalue { i64, i64, <2 x double> } %r51, 1
  br label %block_0x400174
block_0x400174:
  %r54 = phi i64 [ %r52, %block_0x40016c ]
  %r55 = phi i64 [ %r50, %block_0x40016c ]
  ; # 0x400174: pop    rcx
  ; r55 := *r54
  %r56 = inttoptr i64 %r55 to i64*
  %r57 = load i64* %r56
  ; r56 := (bv_add r54 0x8 :: [64])
  %r58 = add i64 %r55, 8
  ; # 0x400175: mov    DWORD PTR [rax],ecx
  ; r57 := (trunc r55 32)
  %r59 = trunc i64 %r57 to i32
  ; *(r53) = r57
  %r60 = inttoptr i64 %r54 to i32*
  store i32 %r59, i32* %r60
  ; # 0x400177: or     rax,-0x1
  ; r58 := undef :: [1]
  ; # 0x40017b: ret
  ; r59 := (bv_add r54 0x10 :: [64])
  %r61 = add i64 %r55, 16
  %r62 = insertvalue { i64, i64, <2 x double> } undef, i64 undef, 0
  %r63 = insertvalue { i64, i64, <2 x double> } %r62, i64 undef, 1
  %r64 = insertvalue { i64, i64, <2 x double> } %r63, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r64
block_0x40017b:
  ; # 0x40017b: ret
  ; r60 := (bv_add unsupported (Initial register rsp) 0x8 :: [64])
  %r65 = add i64 undef, 8
  %r66 = insertvalue { i64, i64, <2 x double> } undef, i64 undef, 0
  %r67 = insertvalue { i64, i64, <2 x double> } %r66, i64 undef, 1
  %r68 = insertvalue { i64, i64, <2 x double> } %r67, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r68
block_0x4004ac:
  ; r0 := (alloca 0x10 :: [64])
  %r69 = alloca i8, i64 16
  %r70 = ptrtoint i8* %r69 to i64
  ; r1 := (bv_add r0 0x10 :: [64])
  %r71 = add i64 %r70, 16
  ; # 0x4004ac: mov    al,0x1
  ; r2 := (bv_and unsupported (Initial register rax) 0xffffffffffffff00 :: [64])
  %r72 = and i64 undef, 18446744073709551360
  ; r3 := (bv_or r2 0x1 :: [64])
  %r73 = or i64 %r72, 1
  ; # 0x4004ae: jmp    40015a
  br label %block_0x40015a
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen_getenv(i64 %iarg0, i64 %iarg1, i64 %iarg2, i64 %iarg3) {
init:
  br label %block_0x4004b4
block_0x4004b4:
  ; r0 := (alloca 0x30 :: [64])
  %r0 = alloca i8, i64 48
  %r1 = ptrtoint i8* %r0 to i64
  ; r1 := (bv_add r0 0x30 :: [64])
  %r2 = add i64 %r1, 48
  ; # 0x4004b4: push   r13
  ; r2 := (bv_add r1 0xfffffffffffffff8 :: [64])
  %r3 = add i64 %r2, 18446744073709551608
  ; # 0x4004b6: push   r12
  ; r3 := (bv_add r1 0xfffffffffffffff0 :: [64])
  %r4 = add i64 %r2, 18446744073709551600
  ; # 0x4004b8: push   rbp
  ; r4 := (bv_add r1 0xffffffffffffffe8 :: [64])
  %r5 = add i64 %r2, 18446744073709551592
  ; # 0x4004b9: push   rbx
  ; r5 := (bv_add r1 0xffffffffffffffe0 :: [64])
  %r6 = add i64 %r2, 18446744073709551584
  ; # 0x4004ba: push   rcx
  ; r6 := (bv_add r1 0xffffffffffffffd8 :: [64])
  %r7 = add i64 %r2, 18446744073709551576
  ; *(r6) = arg3
  %r8 = inttoptr i64 %r7 to i64*
  store i64 %iarg3, i64* %r8
  ; # 0x4004bb: mov    r12,QWORD PTR [rip+0x20027e]
  ; r7 := *data@(0x600740)
  %r9 = inttoptr i64 6293312 to i64*
  %r10 = load i64* %r9
  ; # 0x4004c2: test   r12,r12
  ; r8 := undef :: [1]
  ; r9 := (bv_slt r7 0x0 :: [64])
  %r11 = icmp slt i64 %r10, 0
  ; r10 := (bv_eq r7 0x0 :: [64])
  %r12 = icmp eq i64 %r10, 0
  ; r11 := (trunc r7 8)
  %r13 = trunc i64 %r10 to i8
  ; r12 := (even_parity r11)
  %r14 = call i1 @reopt.EvenParity(i8 %r13)
  ; # 0x4004c5: je     40050d
  br i1 %r12, label %subblock_0x4004b4_1, label %subblock_0x4004b4_2
subblock_0x4004b4_1:
  br label %block_0x40050d
subblock_0x4004b4_2:
  br label %block_0x4004c7
block_0x4004c7:
  %r15 = phi i64 [ %r7, %subblock_0x4004b4_2 ]
  %r16 = phi i64 [ %iarg0, %subblock_0x4004b4_2 ]
  %r17 = phi i64 [ %r10, %subblock_0x4004b4_2 ]
  %r18 = phi i1 [ 0, %subblock_0x4004b4_2 ]
  ; # 0x4004c7: test   rdi,rdi
  ; r17 := undef :: [1]
  ; r18 := (bv_slt r14 0x0 :: [64])
  %r19 = icmp slt i64 %r16, 0
  ; r19 := (bv_eq r14 0x0 :: [64])
  %r20 = icmp eq i64 %r16, 0
  ; r20 := (trunc r14 8)
  %r21 = trunc i64 %r16 to i8
  ; r21 := (even_parity r20)
  %r22 = call i1 @reopt.EvenParity(i8 %r21)
  ; # 0x4004ca: mov    rbp,rdi
  ; # 0x4004cd: je     40050d
  br i1 %r20, label %subblock_0x4004c7_1, label %subblock_0x4004c7_2
subblock_0x4004c7_1:
  br label %block_0x40050d
subblock_0x4004c7_2:
  br label %block_0x4004cf
block_0x4004cf:
  %r23 = phi i64 [ %r15, %subblock_0x4004c7_2 ]
  %r24 = phi i64 [ %r16, %subblock_0x4004c7_2 ]
  %r25 = phi i64 [ %r16, %subblock_0x4004c7_2 ]
  %r26 = phi i64 [ %r17, %subblock_0x4004c7_2 ]
  %r27 = phi i1 [ %r18, %subblock_0x4004c7_2 ]
  ; # 0x4004cf: xor    eax,eax
  ; r27 := undef :: [1]
  ; # 0x4004d1: or     rcx,-0x1
  ; r28 := undef :: [1]
  ; # 0x4004d5: repnz scas al,BYTE PTR [rdi]
  ; r29 := undef :: [64]
  ; r30 := (bv_eq r29 0xffffffffffffffff :: [64])
  %r28 = icmp eq i64 undef, 18446744073709551615
  ; r31 := (bv_add r29 0x1 :: [64])
  %r29 = add i64 undef, 1
  ; r32 := (bv_sub 0xffffffffffffffff :: [64] r31)
  %r30 = sub i64 18446744073709551615, %r29
  ; r33 := (mux r30 0xffffffffffffffff :: [64] r32)
  %r31 = select i1 %r28, i64 18446744073709551615, i64 %r30
  ; r34 := (bv_add r33 0xffffffffffffffff :: [64])
  %r32 = add i64 %r31, 18446744073709551615
  ; r35 := (bv_sub r24 r34)
  %r33 = sub i64 %r25, %r32
  ; r36 := (bv_add r24 r34)
  %r34 = add i64 %r25, %r32
  ; r37 := (mux r26 r35 r36)
  %r35 = select i1 %r27, i64 %r33, i64 %r34
  ; r38 := *r37
  %r36 = inttoptr i64 %r35 to i8*
  %r37 = load i8* %r36
  ; r39 := (bv_slt r38 0x0 :: [8])
  %r38 = icmp slt i8 %r37, 0
  ; r40 := (bv_eq r38 0x0 :: [8])
  %r39 = icmp eq i8 %r37, 0
  ; r41 := (even_parity r38)
  %r40 = call i1 @reopt.EvenParity(i8 %r37)
  ; r42 := (bv_sub r24 r33)
  %r41 = sub i64 %r25, %r31
  ; r43 := (bv_add r24 r33)
  %r42 = add i64 %r25, %r31
  ; r44 := (mux r26 r42 r43)
  %r43 = select i1 %r27, i64 %r41, i64 %r42
  ; r45 := (bv_sub 0xffffffffffffffff :: [64] r33)
  %r44 = sub i64 18446744073709551615, %r31
  ; # 0x4004d7: not    rcx
  ; r46 := (bv_complement r45)
  %r45 = xor i64 %r44, -1
  ; # 0x4004da: lea    r13d,[rcx-0x1]
  ; r47 := (bv_add r46 0xffffffffffffffff :: [64])
  %r46 = add i64 %r45, 18446744073709551615
  ; r48 := (trunc r47 32)
  %r47 = trunc i64 %r46 to i32
  ; r49 := (uext r48 64)
  %r48 = zext i32 %r47 to i64
  ; # 0x4004de: mov    rbx,QWORD PTR [r12]
  ; r50 := *r25
  %r49 = inttoptr i64 %r26 to i64*
  %r50 = load i64* %r49
  ; # 0x4004e2: test   rbx,rbx
  ; r51 := undef :: [1]
  ; r52 := (bv_slt r50 0x0 :: [64])
  %r51 = icmp slt i64 %r50, 0
  ; r53 := (bv_eq r50 0x0 :: [64])
  %r52 = icmp eq i64 %r50, 0
  ; r54 := (trunc r50 8)
  %r53 = trunc i64 %r50 to i8
  ; r55 := (even_parity r54)
  %r54 = call i1 @reopt.EvenParity(i8 %r53)
  ; # 0x4004e5: je     40050f
  br i1 %r52, label %subblock_0x4004cf_1, label %subblock_0x4004cf_2
subblock_0x4004cf_1:
  br label %block_0x40050f
subblock_0x4004cf_2:
  br label %block_0x4004e7
block_0x4004de:
  %r55 = phi i64 [ %r109, %block_0x400507 ]
  %r56 = phi i64 [ %r110, %block_0x400507 ]
  %r57 = phi i64 [ %r120, %block_0x400507 ]
  %r58 = phi i64 [ %r112, %block_0x400507 ]
  ; # 0x4004de: mov    rbx,QWORD PTR [r12]
  ; r60 := *r58
  %r59 = inttoptr i64 %r57 to i64*
  %r60 = load i64* %r59
  ; # 0x4004e2: test   rbx,rbx
  ; r61 := undef :: [1]
  ; r62 := (bv_slt r60 0x0 :: [64])
  %r61 = icmp slt i64 %r60, 0
  ; r63 := (bv_eq r60 0x0 :: [64])
  %r62 = icmp eq i64 %r60, 0
  ; r64 := (trunc r60 8)
  %r63 = trunc i64 %r60 to i8
  ; r65 := (even_parity r64)
  %r64 = call i1 @reopt.EvenParity(i8 %r63)
  ; # 0x4004e5: je     40050f
  br i1 %r62, label %subblock_0x4004de_1, label %subblock_0x4004de_2
subblock_0x4004de_1:
  br label %block_0x40050f
subblock_0x4004de_2:
  br label %block_0x4004e7
block_0x4004e7:
  %r65 = phi i64 [ %r60, %subblock_0x4004de_2 ], [ %r50, %subblock_0x4004cf_2 ]
  %r66 = phi i64 [ %r55, %subblock_0x4004de_2 ], [ %r23, %subblock_0x4004cf_2 ]
  %r67 = phi i64 [ %r56, %subblock_0x4004de_2 ], [ %r24, %subblock_0x4004cf_2 ]
  %r68 = phi i64 [ %r57, %subblock_0x4004de_2 ], [ %r26, %subblock_0x4004cf_2 ]
  %r69 = phi i64 [ %r58, %subblock_0x4004de_2 ], [ %r48, %subblock_0x4004cf_2 ]
  ; # 0x4004e7: mov    rdx,r13
  ; # 0x4004ea: mov    rsi,rbp
  ; # 0x4004ed: mov    rdi,rbx
  ; # 0x4004f0: call   40051c
  ; r71 := (bv_add r67 0xfffffffffffffff8 :: [64])
  %r70 = add i64 %r66, 18446744073709551608
  ; r73 := (bv_add r71 0x8 :: [64])
  %r71 = add i64 %r70, 8
  %r72 = call { i64, i64, <2 x double> } @reopt_gen_memcmp(i64 %r65, i64 %r67, i64 %r69)
  %r73 = extractvalue { i64, i64, <2 x double> } %r72, 0
  br label %block_0x4004f5
block_0x4004f5:
  %r74 = phi i64 [ %r73, %block_0x4004e7 ]
  %r75 = phi i64 [ %r65, %block_0x4004e7 ]
  %r76 = phi i64 [ %r71, %block_0x4004e7 ]
  %r77 = phi i64 [ %r67, %block_0x4004e7 ]
  %r78 = phi i64 [ %r68, %block_0x4004e7 ]
  %r79 = phi i64 [ %r69, %block_0x4004e7 ]
  ; # 0x4004f5: test   eax,eax
  ; r80 := undef :: [1]
  ; r81 := (trunc r74 32)
  %r80 = trunc i64 %r74 to i32
  ; r82 := (bv_slt r81 0x0 :: [32])
  %r81 = icmp slt i32 %r80, 0
  ; r83 := (bv_eq r81 0x0 :: [32])
  %r82 = icmp eq i32 %r80, 0
  ; r84 := (trunc r74 8)
  %r83 = trunc i64 %r74 to i8
  ; r85 := (even_parity r84)
  %r84 = call i1 @reopt.EvenParity(i8 %r83)
  ; # 0x4004f7: jne    400507
  ; r86 := (bv_complement r83)
  %r85 = xor i1 %r82, -1
  br i1 %r85, label %subblock_0x4004f5_1, label %subblock_0x4004f5_2
subblock_0x4004f5_1:
  br label %block_0x400507
subblock_0x4004f5_2:
  br label %block_0x4004f9
block_0x4004f9:
  %r86 = phi i64 [ %r75, %subblock_0x4004f5_2 ]
  %r87 = phi i64 [ %r76, %subblock_0x4004f5_2 ]
  %r88 = phi i64 [ %r77, %subblock_0x4004f5_2 ]
  %r89 = phi i64 [ %r78, %subblock_0x4004f5_2 ]
  %r90 = phi i64 [ %r79, %subblock_0x4004f5_2 ]
  ; # 0x4004f9: cmp    BYTE PTR [rbx+r13*1],0x3d
  ; r92 := (bv_add r87 r91)
  %r91 = add i64 %r86, %r90
  ; r93 := *r92
  %r92 = inttoptr i64 %r91 to i8*
  %r93 = load i8* %r92
  ; r94 := (ssbb_overflows r93 0x3d :: [8] 0x0 :: [1])
  %r94 = call { i8, i1 } @llvm.ssub.with.overflow.i8(i8 %r93, i8 61)
  %r95 = extractvalue { i8, i1 } %r94, 1
  ; r95 := (trunc r93 4)
  %r96 = trunc i8 %r93 to i4
  ; r96 := (bv_ult r95 0xd :: [4])
  %r97 = icmp ult i4 %r96, 13
  ; r97 := (bv_ult r93 0x3d :: [8])
  %r98 = icmp ult i8 %r93, 61
  ; r98 := (bv_add r93 0xc3 :: [8])
  %r99 = add i8 %r93, 195
  ; r99 := (bv_slt r98 0x0 :: [8])
  %r100 = icmp slt i8 %r99, 0
  ; r100 := (bv_eq r93 0x3d :: [8])
  %r101 = icmp eq i8 %r93, 61
  ; r101 := (even_parity r98)
  %r102 = call i1 @reopt.EvenParity(i8 %r99)
  ; # 0x4004fe: jne    400507
  ; r102 := (bv_complement r100)
  %r103 = xor i1 %r101, -1
  br i1 %r103, label %subblock_0x4004f9_1, label %subblock_0x4004f9_2
subblock_0x4004f9_1:
  br label %block_0x400507
subblock_0x4004f9_2:
  br label %block_0x400500
block_0x400500:
  %r104 = phi i64 [ %r86, %subblock_0x4004f9_2 ]
  %r105 = phi i64 [ %r87, %subblock_0x4004f9_2 ]
  %r106 = phi i64 [ %r90, %subblock_0x4004f9_2 ]
  ; # 0x400500: lea    rbx,[rbx+r13*1+0x1]
  ; r106 := (bv_add r103 r105)
  %r107 = add i64 %r104, %r106
  ; r107 := (bv_add r106 0x1 :: [64])
  %r108 = add i64 %r107, 1
  ; # 0x400505: jmp    40050f
  br label %block_0x40050f
block_0x400507:
  %r109 = phi i64 [ %r87, %subblock_0x4004f9_1 ], [ %r76, %subblock_0x4004f5_1 ]
  %r110 = phi i64 [ %r88, %subblock_0x4004f9_1 ], [ %r77, %subblock_0x4004f5_1 ]
  %r111 = phi i64 [ %r89, %subblock_0x4004f9_1 ], [ %r78, %subblock_0x4004f5_1 ]
  %r112 = phi i64 [ %r90, %subblock_0x4004f9_1 ], [ %r79, %subblock_0x4004f5_1 ]
  ; # 0x400507: add    r12,0x8
  ; r112 := (sadc_overflows r110 0x8 :: [64] 0x0 :: [1])
  %r113 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %r111, i64 8)
  %r114 = extractvalue { i64, i1 } %r113, 1
  ; r113 := (trunc r110 4)
  %r115 = trunc i64 %r111 to i4
  ; r114 := (uadc_overflows r113 0x8 :: [4] 0x0 :: [1])
  %r116 = call { i4, i1 } @llvm.uadd.with.overflow.i4(i4 %r115, i4 8)
  %r117 = extractvalue { i4, i1 } %r116, 1
  ; r115 := (uadc_overflows r110 0x8 :: [64] 0x0 :: [1])
  %r118 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %r111, i64 8)
  %r119 = extractvalue { i64, i1 } %r118, 1
  ; r116 := (bv_add r110 0x8 :: [64])
  %r120 = add i64 %r111, 8
  ; r117 := (bv_slt r116 0x0 :: [64])
  %r121 = icmp slt i64 %r120, 0
  ; r118 := (bv_eq r110 0xfffffffffffffff8 :: [64])
  %r122 = icmp eq i64 %r111, 18446744073709551608
  ; r119 := (trunc r116 8)
  %r123 = trunc i64 %r120 to i8
  ; r120 := (even_parity r119)
  %r124 = call i1 @reopt.EvenParity(i8 %r123)
  ; # 0x40050b: jmp    4004de
  br label %block_0x4004de
block_0x40050d:
  %r125 = phi i64 [ %r15, %subblock_0x4004c7_1 ], [ %r7, %subblock_0x4004b4_1 ]
  ; # 0x40050d: xor    ebx,ebx
  ; r122 := undef :: [1]
  ; # 0x40050f: pop    rdx
  ; r123 := *r121
  %r126 = inttoptr i64 %r125 to i64*
  %r127 = load i64* %r126
  ; r124 := (bv_add r121 0x8 :: [64])
  %r128 = add i64 %r125, 8
  ; # 0x400510: mov    rax,rbx
  ; # 0x400513: pop    rbx
  ; r125 := *r124
  %r129 = inttoptr i64 %r128 to i64*
  %r130 = load i64* %r129
  ; r126 := (bv_add r121 0x10 :: [64])
  %r131 = add i64 %r125, 16
  ; # 0x400514: pop    rbp
  ; r127 := *r126
  %r132 = inttoptr i64 %r131 to i64*
  %r133 = load i64* %r132
  ; r128 := (bv_add r121 0x18 :: [64])
  %r134 = add i64 %r125, 24
  ; # 0x400515: pop    r12
  ; r129 := *r128
  %r135 = inttoptr i64 %r134 to i64*
  %r136 = load i64* %r135
  ; r130 := (bv_add r121 0x20 :: [64])
  %r137 = add i64 %r125, 32
  ; # 0x400517: pop    r13
  ; r131 := *r130
  %r138 = inttoptr i64 %r137 to i64*
  %r139 = load i64* %r138
  ; r132 := (bv_add r121 0x28 :: [64])
  %r140 = add i64 %r125, 40
  ; # 0x400519: ret
  ; r133 := (bv_add r121 0x30 :: [64])
  %r141 = add i64 %r125, 48
  %r142 = insertvalue { i64, i64, <2 x double> } undef, i64 0, 0
  %r143 = insertvalue { i64, i64, <2 x double> } %r142, i64 %r127, 1
  %r144 = insertvalue { i64, i64, <2 x double> } %r143, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r144
block_0x40050f:
  %r145 = phi i64 [ %r60, %subblock_0x4004de_1 ], [ %r108, %block_0x400500 ], [ %r50, %subblock_0x4004cf_1 ]
  %r146 = phi i64 [ %r55, %subblock_0x4004de_1 ], [ %r105, %block_0x400500 ], [ %r23, %subblock_0x4004cf_1 ]
  ; # 0x40050f: pop    rdx
  ; r136 := *r135
  %r147 = inttoptr i64 %r146 to i64*
  %r148 = load i64* %r147
  ; r137 := (bv_add r135 0x8 :: [64])
  %r149 = add i64 %r146, 8
  ; # 0x400510: mov    rax,rbx
  ; # 0x400513: pop    rbx
  ; r138 := *r137
  %r150 = inttoptr i64 %r149 to i64*
  %r151 = load i64* %r150
  ; r139 := (bv_add r135 0x10 :: [64])
  %r152 = add i64 %r146, 16
  ; # 0x400514: pop    rbp
  ; r140 := *r139
  %r153 = inttoptr i64 %r152 to i64*
  %r154 = load i64* %r153
  ; r141 := (bv_add r135 0x18 :: [64])
  %r155 = add i64 %r146, 24
  ; # 0x400515: pop    r12
  ; r142 := *r141
  %r156 = inttoptr i64 %r155 to i64*
  %r157 = load i64* %r156
  ; r143 := (bv_add r135 0x20 :: [64])
  %r158 = add i64 %r146, 32
  ; # 0x400517: pop    r13
  ; r144 := *r143
  %r159 = inttoptr i64 %r158 to i64*
  %r160 = load i64* %r159
  ; r145 := (bv_add r135 0x28 :: [64])
  %r161 = add i64 %r146, 40
  ; # 0x400519: ret
  ; r146 := (bv_add r135 0x30 :: [64])
  %r162 = add i64 %r146, 48
  %r163 = insertvalue { i64, i64, <2 x double> } undef, i64 %r145, 0
  %r164 = insertvalue { i64, i64, <2 x double> } %r163, i64 %r148, 1
  %r165 = insertvalue { i64, i64, <2 x double> } %r164, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r165
failure:
  unreachable
}
define { i64, i64, <2 x double> } @reopt_gen_memcmp(i64 %iarg0, i64 %iarg1, i64 %iarg2) {
init:
  br label %block_0x40051c
block_0x40051c:
  ; # 0x40051c: xor    ecx,ecx
  ; r0 := undef :: [1]
  ; # 0x40051e: cmp    rcx,rdx
  ; r1 := (ssbb_overflows 0x0 :: [64] arg2 0x0 :: [1])
  %r0 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 0, i64 %iarg2)
  %r1 = extractvalue { i64, i1 } %r0, 1
  ; r2 := (trunc arg2 4)
  %r2 = trunc i64 %iarg2 to i4
  ; r3 := (bv_ult 0x0 :: [4] r2)
  %r3 = icmp ult i4 0, %r2
  ; r4 := (bv_ult 0x0 :: [64] arg2)
  %r4 = icmp ult i64 0, %iarg2
  ; r5 := (bv_sub 0x0 :: [64] arg2)
  %r5 = sub i64 0, %iarg2
  ; r6 := (bv_slt r5 0x0 :: [64])
  %r6 = icmp slt i64 %r5, 0
  ; r7 := (bv_eq arg2 0x0 :: [64])
  %r7 = icmp eq i64 %iarg2, 0
  ; r8 := (trunc r5 8)
  %r8 = trunc i64 %r5 to i8
  ; r9 := (even_parity r8)
  %r9 = call i1 @reopt.EvenParity(i8 %r8)
  ; # 0x400521: je     400536
  br i1 %r7, label %subblock_0x40051c_1, label %subblock_0x40051c_2
subblock_0x40051c_1:
  br label %block_0x400536
subblock_0x40051c_2:
  br label %block_0x400523
block_0x40051e:
  %r10 = phi i64 [ %r44, %subblock_0x400523_1 ]
  %r11 = phi i64 [ %r26, %subblock_0x400523_1 ]
  %r12 = phi i64 [ %r27, %subblock_0x400523_1 ]
  %r13 = phi i64 [ %r28, %subblock_0x400523_1 ]
  ; # 0x40051e: cmp    rcx,rdx
  ; r14 := (ssbb_overflows r10 r11 0x0 :: [1])
  %r14 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %r10, i64 %r11)
  %r15 = extractvalue { i64, i1 } %r14, 1
  ; r15 := (trunc r10 4)
  %r16 = trunc i64 %r10 to i4
  ; r16 := (trunc r11 4)
  %r17 = trunc i64 %r11 to i4
  ; r17 := (bv_ult r15 r16)
  %r18 = icmp ult i4 %r16, %r17
  ; r18 := (bv_ult r10 r11)
  %r19 = icmp ult i64 %r10, %r11
  ; r19 := (bv_sub r10 r11)
  %r20 = sub i64 %r10, %r11
  ; r20 := (bv_slt r19 0x0 :: [64])
  %r21 = icmp slt i64 %r20, 0
  ; r21 := (bv_eq r10 r11)
  %r22 = icmp eq i64 %r10, %r11
  ; r22 := (trunc r19 8)
  %r23 = trunc i64 %r20 to i8
  ; r23 := (even_parity r22)
  %r24 = call i1 @reopt.EvenParity(i8 %r23)
  ; # 0x400521: je     400536
  br i1 %r22, label %subblock_0x40051e_1, label %subblock_0x40051e_2
subblock_0x40051e_1:
  br label %block_0x400536
subblock_0x40051e_2:
  br label %block_0x400523
block_0x400523:
  %r25 = phi i64 [ %r10, %subblock_0x40051e_2 ], [ 0, %subblock_0x40051c_2 ]
  %r26 = phi i64 [ %r11, %subblock_0x40051e_2 ], [ %iarg2, %subblock_0x40051c_2 ]
  %r27 = phi i64 [ %r12, %subblock_0x40051e_2 ], [ %iarg1, %subblock_0x40051c_2 ]
  %r28 = phi i64 [ %r13, %subblock_0x40051e_2 ], [ %iarg0, %subblock_0x40051c_2 ]
  ; # 0x400523: movzx  eax,BYTE PTR [rdi+rcx*1]
  ; r28 := (bv_add r27 r24)
  %r29 = add i64 %r28, %r25
  ; r29 := *r28
  %r30 = inttoptr i64 %r29 to i8*
  %r31 = load i8* %r30
  ; r30 := (uext r29 32)
  %r32 = zext i8 %r31 to i32
  ; r31 := (uext r29 64)
  %r33 = zext i8 %r31 to i64
  ; # 0x400527: movzx  r8d,BYTE PTR [rsi+rcx*1]
  ; r32 := (bv_add r26 r24)
  %r34 = add i64 %r27, %r25
  ; r33 := *r32
  %r35 = inttoptr i64 %r34 to i8*
  %r36 = load i8* %r35
  ; r34 := (uext r33 32)
  %r37 = zext i8 %r36 to i32
  ; r35 := (uext r33 64)
  %r38 = zext i8 %r36 to i64
  ; # 0x40052c: inc    rcx
  ; r36 := (sadc_overflows r24 0x1 :: [64] 0x0 :: [1])
  %r39 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %r25, i64 1)
  %r40 = extractvalue { i64, i1 } %r39, 1
  ; r37 := (trunc r24 4)
  %r41 = trunc i64 %r25 to i4
  ; r38 := (uadc_overflows r37 0x1 :: [4] 0x0 :: [1])
  %r42 = call { i4, i1 } @llvm.uadd.with.overflow.i4(i4 %r41, i4 1)
  %r43 = extractvalue { i4, i1 } %r42, 1
  ; r39 := (bv_add r24 0x1 :: [64])
  %r44 = add i64 %r25, 1
  ; r40 := (bv_slt r39 0x0 :: [64])
  %r45 = icmp slt i64 %r44, 0
  ; r41 := (bv_eq r24 0xffffffffffffffff :: [64])
  %r46 = icmp eq i64 %r25, 18446744073709551615
  ; r42 := (trunc r39 8)
  %r47 = trunc i64 %r44 to i8
  ; r43 := (even_parity r42)
  %r48 = call i1 @reopt.EvenParity(i8 %r47)
  ; # 0x40052f: sub    eax,r8d
  ; r44 := (ssbb_overflows r30 r34 0x0 :: [1])
  %r49 = call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 %r32, i32 %r37)
  %r50 = extractvalue { i32, i1 } %r49, 1
  ; r45 := (trunc r29 4)
  %r51 = trunc i8 %r31 to i4
  ; r46 := (trunc r33 4)
  %r52 = trunc i8 %r36 to i4
  ; r47 := (bv_ult r45 r46)
  %r53 = icmp ult i4 %r51, %r52
  ; r48 := (bv_ult r30 r34)
  %r54 = icmp ult i32 %r32, %r37
  ; r49 := (bv_sub r30 r34)
  %r55 = sub i32 %r32, %r37
  ; r50 := (bv_slt r49 0x0 :: [32])
  %r56 = icmp slt i32 %r55, 0
  ; r51 := (bv_eq r30 r34)
  %r57 = icmp eq i32 %r32, %r37
  ; r52 := (trunc r49 8)
  %r58 = trunc i32 %r55 to i8
  ; r53 := (even_parity r52)
  %r59 = call i1 @reopt.EvenParity(i8 %r58)
  ; r54 := (uext r49 64)
  %r60 = zext i32 %r55 to i64
  ; # 0x400532: je     40051e
  br i1 %r57, label %subblock_0x400523_1, label %subblock_0x400523_2
subblock_0x400523_1:
  br label %block_0x40051e
subblock_0x400523_2:
  br label %block_0x400534
block_0x400534:
  %r61 = phi i64 [ %r60, %subblock_0x400523_2 ]
  ; # 0x400534: jmp    400538
  br label %block_0x400538
block_0x400536:
  ; # 0x400536: xor    eax,eax
  ; r56 := undef :: [1]
  ; # 0x400538: ret
  ; r57 := (bv_add unsupported (Initial register rsp) 0x8 :: [64])
  %r62 = add i64 undef, 8
  %r63 = insertvalue { i64, i64, <2 x double> } undef, i64 0, 0
  %r64 = insertvalue { i64, i64, <2 x double> } %r63, i64 undef, 1
  %r65 = insertvalue { i64, i64, <2 x double> } %r64, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r65
block_0x400538:
  %r66 = phi i64 [ %r61, %block_0x400534 ]
  ; # 0x400538: ret
  ; r59 := (bv_add unsupported (Initial register rsp) 0x8 :: [64])
  %r67 = add i64 undef, 8
  %r68 = insertvalue { i64, i64, <2 x double> } undef, i64 %r66, 0
  %r69 = insertvalue { i64, i64, <2 x double> } %r68, i64 undef, 1
  %r70 = insertvalue { i64, i64, <2 x double> } %r69, <2 x double> undef, 2
  ret { i64, i64, <2 x double> } %r70
failure:
  unreachable
}