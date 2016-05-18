; ModuleID = 'libpoly_obj/upolynomial/.output.c.o.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.umonomial_struct = type { i64, %struct.__mpz_struct }
%struct.__mpz_struct = type { i32, i32, i64* }
%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.lp_int_ring_t = type { i64, i32, %struct.__mpz_struct, %struct.__mpz_struct, %struct.__mpz_struct }
%struct.upolynomial_dense_t = type { i64, i64, %struct.__mpz_struct* }
%struct.lp_upolynomial_struct = type { %struct.lp_int_ring_t*, i64, [0 x %struct.umonomial_struct] }
%struct.lp_upolynomial_factors_struct = type { %struct.__mpz_struct, i64, i64, %struct.lp_upolynomial_struct**, i64* }

@.str = private unnamed_addr constant [2 x i8] c"(\00", align 1
@.str1 = private unnamed_addr constant [4 x i8] c"*%s\00", align 1
@.str2 = private unnamed_addr constant [8 x i8] c"*x%s%zu\00", align 1
@.str3 = private unnamed_addr constant [2 x i8] c")\00", align 1
@.str4 = private unnamed_addr constant [2 x i8] c"+\00", align 1
@.str5 = private unnamed_addr constant [8 x i8] c"*x%s%d \00", align 1
@.str6 = private unnamed_addr constant [2 x i8] c"p\00", align 1
@.str7 = private unnamed_addr constant [56 x i8] c"/home/iam/Repositories/libpoly/src/upolynomial/output.c\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_print = private unnamed_addr constant [59 x i8] c"int lp_upolynomial_print(const lp_upolynomial_t *, FILE *)\00", align 1
@.str8 = private unnamed_addr constant [4 x i8] c" + \00", align 1
@.str9 = private unnamed_addr constant [3 x i8] c" [\00", align 1
@.str10 = private unnamed_addr constant [2 x i8] c"]\00", align 1
@.str11 = private unnamed_addr constant [4 x i8] c" * \00", align 1
@.str12 = private unnamed_addr constant [2 x i8] c"[\00", align 1
@.str13 = private unnamed_addr constant [6 x i8] c"]^%zu\00", align 1
@.str14 = private unnamed_addr constant [22 x i8] c"integer_in_ring(K, c)\00", align 1
@.str15 = private unnamed_addr constant [52 x i8] c"/home/iam/Repositories/libpoly/src/number/integer.h\00", align 1
@__PRETTY_FUNCTION__.integer_ring_normalize = private unnamed_addr constant [61 x i8] c"void integer_ring_normalize(lp_int_ring_t *, lp_integer_t *)\00", align 1

; Function Attrs: nounwind uwtable
define i32 @umonomial_print(%struct.umonomial_struct* %m, %struct._IO_FILE* %out) #0 {
entry:
  %m.addr = alloca %struct.umonomial_struct*, align 8
  %out.addr = alloca %struct._IO_FILE*, align 8
  %len = alloca i32, align 4
  %sgn = alloca i32, align 4
  store %struct.umonomial_struct* %m, %struct.umonomial_struct** %m.addr, align 8
  store %struct._IO_FILE* %out, %struct._IO_FILE** %out.addr, align 8
  store i32 0, i32* %len, align 4
  %0 = load %struct.umonomial_struct** %m.addr, align 8
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %0, i32 0, i32 1
  %call = call i32 @integer_sgn(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %coefficient)
  store i32 %call, i32* %sgn, align 4
  %1 = load i32* %sgn, align 4
  %cmp = icmp slt i32 %1, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %2 = load %struct._IO_FILE** %out.addr, align 8
  %call1 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %2, i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0))
  %3 = load i32* %len, align 4
  %add = add nsw i32 %3, %call1
  store i32 %add, i32* %len, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %4 = load %struct.umonomial_struct** %m.addr, align 8
  %coefficient2 = getelementptr inbounds %struct.umonomial_struct* %4, i32 0, i32 1
  %5 = load %struct._IO_FILE** %out.addr, align 8
  %call3 = call i32 @integer_print(%struct.__mpz_struct* %coefficient2, %struct._IO_FILE* %5)
  %6 = load i32* %len, align 4
  %add4 = add nsw i32 %6, %call3
  store i32 %add4, i32* %len, align 4
  %7 = load %struct.umonomial_struct** %m.addr, align 8
  %degree = getelementptr inbounds %struct.umonomial_struct* %7, i32 0, i32 0
  %8 = load i64* %degree, align 8
  %tobool = icmp ne i64 %8, 0
  br i1 %tobool, label %if.then5, label %if.end17

if.then5:                                         ; preds = %if.end
  %9 = load %struct.umonomial_struct** %m.addr, align 8
  %degree6 = getelementptr inbounds %struct.umonomial_struct* %9, i32 0, i32 0
  %10 = load i64* %degree6, align 8
  %cmp7 = icmp eq i64 %10, 1
  br i1 %cmp7, label %if.then8, label %if.else

if.then8:                                         ; preds = %if.then5
  %11 = load %struct._IO_FILE** %out.addr, align 8
  %call9 = call i8* (...)* @get_upolynomial_var_symbol()
  %call10 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %11, i8* getelementptr inbounds ([4 x i8]* @.str1, i32 0, i32 0), i8* %call9)
  %12 = load i32* %len, align 4
  %add11 = add nsw i32 %12, %call10
  store i32 %add11, i32* %len, align 4
  br label %if.end16

if.else:                                          ; preds = %if.then5
  %13 = load %struct._IO_FILE** %out.addr, align 8
  %call12 = call i8* @get_power_symbol()
  %14 = load %struct.umonomial_struct** %m.addr, align 8
  %degree13 = getelementptr inbounds %struct.umonomial_struct* %14, i32 0, i32 0
  %15 = load i64* %degree13, align 8
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %13, i8* getelementptr inbounds ([8 x i8]* @.str2, i32 0, i32 0), i8* %call12, i64 %15)
  %16 = load i32* %len, align 4
  %add15 = add nsw i32 %16, %call14
  store i32 %add15, i32* %len, align 4
  br label %if.end16

if.end16:                                         ; preds = %if.else, %if.then8
  br label %if.end17

if.end17:                                         ; preds = %if.end16, %if.end
  %17 = load i32* %sgn, align 4
  %cmp18 = icmp slt i32 %17, 0
  br i1 %cmp18, label %if.then19, label %if.end22

if.then19:                                        ; preds = %if.end17
  %18 = load %struct._IO_FILE** %out.addr, align 8
  %call20 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %18, i8* getelementptr inbounds ([2 x i8]* @.str3, i32 0, i32 0))
  %19 = load i32* %len, align 4
  %add21 = add nsw i32 %19, %call20
  store i32 %add21, i32* %len, align 4
  br label %if.end22

if.end22:                                         ; preds = %if.then19, %if.end17
  %20 = load i32* %len, align 4
  ret i32 %20
}

; Function Attrs: inlinehint nounwind uwtable
define internal i32 @integer_sgn(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c) #1 {
entry:
  %retval = alloca i32, align 4
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %c.addr = alloca %struct.__mpz_struct*, align 8
  %c_normalized = alloca %struct.__mpz_struct, align 8
  %sgn = alloca i32, align 4
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %tobool = icmp ne %struct.lp_int_ring_t* %0, null
  br i1 %tobool, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %1 = load %struct.lp_int_ring_t** %K.addr, align 8
  %2 = load %struct.__mpz_struct** %c.addr, align 8
  call void @integer_construct_copy(%struct.lp_int_ring_t* %1, %struct.__mpz_struct* %c_normalized, %struct.__mpz_struct* %2)
  %_mp_size = getelementptr inbounds %struct.__mpz_struct* %c_normalized, i32 0, i32 1
  %3 = load i32* %_mp_size, align 4
  %cmp = icmp slt i32 %3, 0
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %_mp_size1 = getelementptr inbounds %struct.__mpz_struct* %c_normalized, i32 0, i32 1
  %4 = load i32* %_mp_size1, align 4
  %cmp2 = icmp sgt i32 %4, 0
  %conv = zext i1 %cmp2 to i32
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ -1, %cond.true ], [ %conv, %cond.false ]
  store i32 %cond, i32* %sgn, align 4
  call void @integer_destruct(%struct.__mpz_struct* %c_normalized)
  %5 = load i32* %sgn, align 4
  store i32 %5, i32* %retval
  br label %return

if.else:                                          ; preds = %entry
  %6 = load %struct.__mpz_struct** %c.addr, align 8
  %_mp_size3 = getelementptr inbounds %struct.__mpz_struct* %6, i32 0, i32 1
  %7 = load i32* %_mp_size3, align 4
  %cmp4 = icmp slt i32 %7, 0
  br i1 %cmp4, label %cond.true6, label %cond.false7

cond.true6:                                       ; preds = %if.else
  br label %cond.end11

cond.false7:                                      ; preds = %if.else
  %8 = load %struct.__mpz_struct** %c.addr, align 8
  %_mp_size8 = getelementptr inbounds %struct.__mpz_struct* %8, i32 0, i32 1
  %9 = load i32* %_mp_size8, align 4
  %cmp9 = icmp sgt i32 %9, 0
  %conv10 = zext i1 %cmp9 to i32
  br label %cond.end11

cond.end11:                                       ; preds = %cond.false7, %cond.true6
  %cond12 = phi i32 [ -1, %cond.true6 ], [ %conv10, %cond.false7 ]
  store i32 %cond12, i32* %retval
  br label %return

return:                                           ; preds = %cond.end11, %cond.end
  %10 = load i32* %retval
  ret i32 %10
}

declare i32 @fprintf(%struct._IO_FILE*, i8*, ...) #2

; Function Attrs: inlinehint nounwind uwtable
define internal i32 @integer_print(%struct.__mpz_struct* %c, %struct._IO_FILE* %out) #1 {
entry:
  %c.addr = alloca %struct.__mpz_struct*, align 8
  %out.addr = alloca %struct._IO_FILE*, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  store %struct._IO_FILE* %out, %struct._IO_FILE** %out.addr, align 8
  %0 = load %struct._IO_FILE** %out.addr, align 8
  %1 = load %struct.__mpz_struct** %c.addr, align 8
  %call = call i64 @__gmpz_out_str(%struct._IO_FILE* %0, i32 10, %struct.__mpz_struct* %1)
  %conv = trunc i64 %call to i32
  ret i32 %conv
}

declare i8* @get_upolynomial_var_symbol(...) #2

declare i8* @get_power_symbol() #2

; Function Attrs: nounwind uwtable
define i32 @upolynomial_dense_print(%struct.upolynomial_dense_t* %p_d, %struct._IO_FILE* %file) #0 {
entry:
  %p_d.addr = alloca %struct.upolynomial_dense_t*, align 8
  %file.addr = alloca %struct._IO_FILE*, align 8
  %len = alloca i32, align 4
  %k = alloca i32, align 4
  %sgn = alloca i32, align 4
  store %struct.upolynomial_dense_t* %p_d, %struct.upolynomial_dense_t** %p_d.addr, align 8
  store %struct._IO_FILE* %file, %struct._IO_FILE** %file.addr, align 8
  store i32 0, i32* %len, align 4
  %0 = load %struct.upolynomial_dense_t** %p_d.addr, align 8
  %size = getelementptr inbounds %struct.upolynomial_dense_t* %0, i32 0, i32 1
  %1 = load i64* %size, align 8
  %sub = sub i64 %1, 1
  %conv = trunc i64 %sub to i32
  store i32 %conv, i32* %k, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %2 = load i32* %k, align 4
  %cmp = icmp sge i32 %2, 0
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %3 = load %struct.upolynomial_dense_t** %p_d.addr, align 8
  %coefficients = getelementptr inbounds %struct.upolynomial_dense_t* %3, i32 0, i32 2
  %4 = load %struct.__mpz_struct** %coefficients, align 8
  %5 = load i32* %k, align 4
  %idx.ext = sext i32 %5 to i64
  %add.ptr = getelementptr inbounds %struct.__mpz_struct* %4, i64 %idx.ext
  %call = call i32 @integer_sgn(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %add.ptr)
  store i32 %call, i32* %sgn, align 4
  %6 = load i32* %sgn, align 4
  %tobool = icmp ne i32 %6, 0
  br i1 %tobool, label %if.then, label %if.end13

if.then:                                          ; preds = %for.body
  %7 = load i32* %sgn, align 4
  %cmp2 = icmp sgt i32 %7, 0
  br i1 %cmp2, label %if.then4, label %if.end

if.then4:                                         ; preds = %if.then
  %8 = load %struct._IO_FILE** %file.addr, align 8
  %call5 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %8, i8* getelementptr inbounds ([2 x i8]* @.str4, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %if.then4, %if.then
  %9 = load %struct.upolynomial_dense_t** %p_d.addr, align 8
  %coefficients6 = getelementptr inbounds %struct.upolynomial_dense_t* %9, i32 0, i32 2
  %10 = load %struct.__mpz_struct** %coefficients6, align 8
  %11 = load i32* %k, align 4
  %idx.ext7 = sext i32 %11 to i64
  %add.ptr8 = getelementptr inbounds %struct.__mpz_struct* %10, i64 %idx.ext7
  %12 = load %struct._IO_FILE** %file.addr, align 8
  %call9 = call i32 @integer_print(%struct.__mpz_struct* %add.ptr8, %struct._IO_FILE* %12)
  %13 = load i32* %len, align 4
  %add = add nsw i32 %13, %call9
  store i32 %add, i32* %len, align 4
  %14 = load %struct._IO_FILE** %file.addr, align 8
  %call10 = call i8* @get_power_symbol()
  %15 = load i32* %k, align 4
  %call11 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %14, i8* getelementptr inbounds ([8 x i8]* @.str5, i32 0, i32 0), i8* %call10, i32 %15)
  %16 = load i32* %len, align 4
  %add12 = add nsw i32 %16, %call11
  store i32 %add12, i32* %len, align 4
  br label %if.end13

if.end13:                                         ; preds = %if.end, %for.body
  br label %for.inc

for.inc:                                          ; preds = %if.end13
  %17 = load i32* %k, align 4
  %dec = add nsw i32 %17, -1
  store i32 %dec, i32* %k, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %18 = load i32* %len, align 4
  ret i32 %18
}

; Function Attrs: nounwind uwtable
define i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %p, %struct._IO_FILE* %out) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %out.addr = alloca %struct._IO_FILE*, align 8
  %len = alloca i32, align 4
  %i = alloca i32, align 4
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct._IO_FILE* %out, %struct._IO_FILE** %out.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str6, i32 0, i32 0), i8* getelementptr inbounds ([56 x i8]* @.str7, i32 0, i32 0), i32 61, i8* getelementptr inbounds ([59 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_print, i32 0, i32 0)) #6
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  store i32 0, i32* %len, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %cond.end
  %2 = load i32* %i, align 4
  %conv = zext i32 %2 to i64
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %3, i32 0, i32 1
  %4 = load i64* %size, align 8
  %cmp = icmp ult i64 %conv, %4
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %5 = load i32* %i, align 4
  %tobool2 = icmp ne i32 %5, 0
  br i1 %tobool2, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %6 = load %struct._IO_FILE** %out.addr, align 8
  %call = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %6, i8* getelementptr inbounds ([4 x i8]* @.str8, i32 0, i32 0))
  %7 = load i32* %len, align 4
  %add = add nsw i32 %7, %call
  store i32 %add, i32* %len, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  %8 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size3 = getelementptr inbounds %struct.lp_upolynomial_struct* %8, i32 0, i32 1
  %9 = load i64* %size3, align 8
  %10 = load i32* %i, align 4
  %conv4 = zext i32 %10 to i64
  %sub = sub i64 %9, %conv4
  %sub5 = sub i64 %sub, 1
  %11 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %11, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %sub5
  %12 = load %struct._IO_FILE** %out.addr, align 8
  %call6 = call i32 @umonomial_print(%struct.umonomial_struct* %arrayidx, %struct._IO_FILE* %12)
  %13 = load i32* %len, align 4
  %add7 = add nsw i32 %13, %call6
  store i32 %add7, i32* %len, align 4
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %14 = load i32* %i, align 4
  %inc = add i32 %14, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %15 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %15, i32 0, i32 0
  %16 = load %struct.lp_int_ring_t** %K, align 8
  %tobool8 = icmp ne %struct.lp_int_ring_t* %16, null
  br i1 %tobool8, label %if.then9, label %if.end17

if.then9:                                         ; preds = %for.end
  %17 = load %struct._IO_FILE** %out.addr, align 8
  %call10 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %17, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  %18 = load i32* %len, align 4
  %add11 = add nsw i32 %18, %call10
  store i32 %add11, i32* %len, align 4
  %19 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K12 = getelementptr inbounds %struct.lp_upolynomial_struct* %19, i32 0, i32 0
  %20 = load %struct.lp_int_ring_t** %K12, align 8
  %21 = load %struct._IO_FILE** %out.addr, align 8
  %call13 = call i32 @lp_int_ring_print(%struct.lp_int_ring_t* %20, %struct._IO_FILE* %21)
  %22 = load i32* %len, align 4
  %add14 = add nsw i32 %22, %call13
  store i32 %add14, i32* %len, align 4
  %23 = load %struct._IO_FILE** %out.addr, align 8
  %call15 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %23, i8* getelementptr inbounds ([2 x i8]* @.str10, i32 0, i32 0))
  %24 = load i32* %len, align 4
  %add16 = add nsw i32 %24, %call15
  store i32 %add16, i32* %len, align 4
  br label %if.end17

if.end17:                                         ; preds = %if.then9, %for.end
  %25 = load i32* %len, align 4
  ret i32 %25
}

; Function Attrs: noreturn nounwind
declare void @__assert_fail(i8*, i8*, i32, i8*) #3

declare i32 @lp_int_ring_print(%struct.lp_int_ring_t*, %struct._IO_FILE*) #2

; Function Attrs: nounwind uwtable
define i8* @lp_upolynomial_to_string(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %str = alloca i8*, align 8
  %size = alloca i64, align 8
  %f = alloca %struct._IO_FILE*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store i8* null, i8** %str, align 8
  store i64 0, i64* %size, align 8
  %call = call %struct._IO_FILE* @open_memstream(i8** %str, i64* %size) #7
  store %struct._IO_FILE* %call, %struct._IO_FILE** %f, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %1 = load %struct._IO_FILE** %f, align 8
  %call1 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %0, %struct._IO_FILE* %1)
  %2 = load %struct._IO_FILE** %f, align 8
  %call2 = call i32 @fclose(%struct._IO_FILE* %2)
  %3 = load i8** %str, align 8
  ret i8* %3
}

; Function Attrs: nounwind
declare %struct._IO_FILE* @open_memstream(i8**, i64*) #4

declare i32 @fclose(%struct._IO_FILE*) #2

; Function Attrs: nounwind uwtable
define i32 @lp_upolynomial_factors_print(%struct.lp_upolynomial_factors_struct* %f, %struct._IO_FILE* %out) #0 {
entry:
  %f.addr = alloca %struct.lp_upolynomial_factors_struct*, align 8
  %out.addr = alloca %struct._IO_FILE*, align 8
  %len = alloca i32, align 4
  %i = alloca i64, align 8
  store %struct.lp_upolynomial_factors_struct* %f, %struct.lp_upolynomial_factors_struct** %f.addr, align 8
  store %struct._IO_FILE* %out, %struct._IO_FILE** %out.addr, align 8
  store i32 0, i32* %len, align 4
  %0 = load %struct.lp_upolynomial_factors_struct** %f.addr, align 8
  %constant = getelementptr inbounds %struct.lp_upolynomial_factors_struct* %0, i32 0, i32 0
  %1 = load %struct._IO_FILE** %out.addr, align 8
  %call = call i32 @integer_print(%struct.__mpz_struct* %constant, %struct._IO_FILE* %1)
  %2 = load i32* %len, align 4
  %add = add nsw i32 %2, %call
  store i32 %add, i32* %len, align 4
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %3 = load i64* %i, align 8
  %4 = load %struct.lp_upolynomial_factors_struct** %f.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_factors_struct* %4, i32 0, i32 1
  %5 = load i64* %size, align 8
  %cmp = icmp ult i64 %3, %5
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %6 = load %struct._IO_FILE** %out.addr, align 8
  %call1 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %6, i8* getelementptr inbounds ([4 x i8]* @.str11, i32 0, i32 0))
  %7 = load i32* %len, align 4
  %add2 = add nsw i32 %7, %call1
  store i32 %add2, i32* %len, align 4
  %8 = load %struct._IO_FILE** %out.addr, align 8
  %call3 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %8, i8* getelementptr inbounds ([2 x i8]* @.str12, i32 0, i32 0))
  %9 = load i32* %len, align 4
  %add4 = add nsw i32 %9, %call3
  store i32 %add4, i32* %len, align 4
  %10 = load i64* %i, align 8
  %11 = load %struct.lp_upolynomial_factors_struct** %f.addr, align 8
  %factors = getelementptr inbounds %struct.lp_upolynomial_factors_struct* %11, i32 0, i32 3
  %12 = load %struct.lp_upolynomial_struct*** %factors, align 8
  %arrayidx = getelementptr inbounds %struct.lp_upolynomial_struct** %12, i64 %10
  %13 = load %struct.lp_upolynomial_struct** %arrayidx, align 8
  %14 = load %struct._IO_FILE** %out.addr, align 8
  %call5 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %13, %struct._IO_FILE* %14)
  %15 = load i32* %len, align 4
  %add6 = add nsw i32 %15, %call5
  store i32 %add6, i32* %len, align 4
  %16 = load %struct._IO_FILE** %out.addr, align 8
  %17 = load i64* %i, align 8
  %18 = load %struct.lp_upolynomial_factors_struct** %f.addr, align 8
  %multiplicities = getelementptr inbounds %struct.lp_upolynomial_factors_struct* %18, i32 0, i32 4
  %19 = load i64** %multiplicities, align 8
  %arrayidx7 = getelementptr inbounds i64* %19, i64 %17
  %20 = load i64* %arrayidx7, align 8
  %call8 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %16, i8* getelementptr inbounds ([6 x i8]* @.str13, i32 0, i32 0), i64 %20)
  %21 = load i32* %len, align 4
  %add9 = add nsw i32 %21, %call8
  store i32 %add9, i32* %len, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %22 = load i64* %i, align 8
  %inc = add i64 %22, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %23 = load i32* %len, align 4
  ret i32 %23
}

declare i64 @__gmpz_out_str(%struct._IO_FILE*, i32, %struct.__mpz_struct*) #2

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_construct_copy(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c, %struct.__mpz_struct* %from) #1 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %c.addr = alloca %struct.__mpz_struct*, align 8
  %from.addr = alloca %struct.__mpz_struct*, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  store %struct.__mpz_struct* %from, %struct.__mpz_struct** %from.addr, align 8
  %0 = load %struct.__mpz_struct** %c.addr, align 8
  %1 = load %struct.__mpz_struct** %from.addr, align 8
  call void @__gmpz_init_set(%struct.__mpz_struct* %0, %struct.__mpz_struct* %1)
  %2 = load %struct.lp_int_ring_t** %K.addr, align 8
  %3 = load %struct.__mpz_struct** %c.addr, align 8
  call void @integer_ring_normalize(%struct.lp_int_ring_t* %2, %struct.__mpz_struct* %3)
  ret void
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_destruct(%struct.__mpz_struct* %c) #1 {
entry:
  %c.addr = alloca %struct.__mpz_struct*, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  %0 = load %struct.__mpz_struct** %c.addr, align 8
  call void @__gmpz_clear(%struct.__mpz_struct* %0)
  ret void
}

declare void @__gmpz_clear(%struct.__mpz_struct*) #2

declare void @__gmpz_init_set(%struct.__mpz_struct*, %struct.__mpz_struct*) #2

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_ring_normalize(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c) #1 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %c.addr = alloca %struct.__mpz_struct*, align 8
  %tmp = alloca %struct.__mpz_struct, align 8
  %sgn = alloca i32, align 4
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %tobool = icmp ne %struct.lp_int_ring_t* %0, null
  br i1 %tobool, label %land.lhs.true, label %if.end27

land.lhs.true:                                    ; preds = %entry
  %1 = load %struct.lp_int_ring_t** %K.addr, align 8
  %2 = load %struct.__mpz_struct** %c.addr, align 8
  %call = call i32 @integer_in_ring(%struct.lp_int_ring_t* %1, %struct.__mpz_struct* %2)
  %tobool1 = icmp ne i32 %call, 0
  br i1 %tobool1, label %if.end27, label %if.then

if.then:                                          ; preds = %land.lhs.true
  call void @__gmpz_init(%struct.__mpz_struct* %tmp)
  %3 = load %struct.__mpz_struct** %c.addr, align 8
  %4 = load %struct.lp_int_ring_t** %K.addr, align 8
  %M = getelementptr inbounds %struct.lp_int_ring_t* %4, i32 0, i32 2
  call void @__gmpz_tdiv_r(%struct.__mpz_struct* %tmp, %struct.__mpz_struct* %3, %struct.__mpz_struct* %M)
  %5 = load %struct.__mpz_struct** %c.addr, align 8
  call void @__gmpz_swap(%struct.__mpz_struct* %5, %struct.__mpz_struct* %tmp)
  %6 = load %struct.__mpz_struct** %c.addr, align 8
  %_mp_size = getelementptr inbounds %struct.__mpz_struct* %6, i32 0, i32 1
  %7 = load i32* %_mp_size, align 4
  %cmp = icmp slt i32 %7, 0
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %8 = load %struct.__mpz_struct** %c.addr, align 8
  %_mp_size3 = getelementptr inbounds %struct.__mpz_struct* %8, i32 0, i32 1
  %9 = load i32* %_mp_size3, align 4
  %cmp4 = icmp sgt i32 %9, 0
  %conv = zext i1 %cmp4 to i32
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ -1, %cond.true ], [ %conv, %cond.false ]
  store i32 %cond, i32* %sgn, align 4
  %10 = load i32* %sgn, align 4
  %cmp5 = icmp sgt i32 %10, 0
  br i1 %cmp5, label %land.lhs.true7, label %if.end

land.lhs.true7:                                   ; preds = %cond.end
  %11 = load %struct.__mpz_struct** %c.addr, align 8
  %12 = load %struct.lp_int_ring_t** %K.addr, align 8
  %ub = getelementptr inbounds %struct.lp_int_ring_t* %12, i32 0, i32 4
  %call8 = call i32 @__gmpz_cmp(%struct.__mpz_struct* %11, %struct.__mpz_struct* %ub) #8
  %cmp9 = icmp sgt i32 %call8, 0
  br i1 %cmp9, label %if.then11, label %if.end

if.then11:                                        ; preds = %land.lhs.true7
  %13 = load %struct.__mpz_struct** %c.addr, align 8
  %14 = load %struct.lp_int_ring_t** %K.addr, align 8
  %M12 = getelementptr inbounds %struct.lp_int_ring_t* %14, i32 0, i32 2
  call void @__gmpz_sub(%struct.__mpz_struct* %tmp, %struct.__mpz_struct* %13, %struct.__mpz_struct* %M12)
  %15 = load %struct.__mpz_struct** %c.addr, align 8
  call void @__gmpz_swap(%struct.__mpz_struct* %15, %struct.__mpz_struct* %tmp)
  br label %if.end

if.end:                                           ; preds = %if.then11, %land.lhs.true7, %cond.end
  %16 = load i32* %sgn, align 4
  %cmp13 = icmp slt i32 %16, 0
  br i1 %cmp13, label %land.lhs.true15, label %if.end21

land.lhs.true15:                                  ; preds = %if.end
  %17 = load %struct.__mpz_struct** %c.addr, align 8
  %18 = load %struct.lp_int_ring_t** %K.addr, align 8
  %lb = getelementptr inbounds %struct.lp_int_ring_t* %18, i32 0, i32 3
  %call16 = call i32 @__gmpz_cmp(%struct.__mpz_struct* %17, %struct.__mpz_struct* %lb) #8
  %cmp17 = icmp slt i32 %call16, 0
  br i1 %cmp17, label %if.then19, label %if.end21

if.then19:                                        ; preds = %land.lhs.true15
  %19 = load %struct.__mpz_struct** %c.addr, align 8
  %20 = load %struct.lp_int_ring_t** %K.addr, align 8
  %M20 = getelementptr inbounds %struct.lp_int_ring_t* %20, i32 0, i32 2
  call void @__gmpz_add(%struct.__mpz_struct* %tmp, %struct.__mpz_struct* %19, %struct.__mpz_struct* %M20)
  %21 = load %struct.__mpz_struct** %c.addr, align 8
  call void @__gmpz_swap(%struct.__mpz_struct* %21, %struct.__mpz_struct* %tmp)
  br label %if.end21

if.end21:                                         ; preds = %if.then19, %land.lhs.true15, %if.end
  call void @__gmpz_clear(%struct.__mpz_struct* %tmp)
  %22 = load %struct.lp_int_ring_t** %K.addr, align 8
  %23 = load %struct.__mpz_struct** %c.addr, align 8
  %call22 = call i32 @integer_in_ring(%struct.lp_int_ring_t* %22, %struct.__mpz_struct* %23)
  %tobool23 = icmp ne i32 %call22, 0
  br i1 %tobool23, label %cond.true24, label %cond.false25

cond.true24:                                      ; preds = %if.end21
  br label %cond.end26

cond.false25:                                     ; preds = %if.end21
  call void @__assert_fail(i8* getelementptr inbounds ([22 x i8]* @.str14, i32 0, i32 0), i8* getelementptr inbounds ([52 x i8]* @.str15, i32 0, i32 0), i32 71, i8* getelementptr inbounds ([61 x i8]* @__PRETTY_FUNCTION__.integer_ring_normalize, i32 0, i32 0)) #6
  unreachable
                                                  ; No predecessors!
  br label %cond.end26

cond.end26:                                       ; preds = %24, %cond.true24
  br label %if.end27

if.end27:                                         ; preds = %cond.end26, %land.lhs.true, %entry
  ret void
}

; Function Attrs: inlinehint nounwind uwtable
define internal i32 @integer_in_ring(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c) #1 {
entry:
  %retval = alloca i32, align 4
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %c.addr = alloca %struct.__mpz_struct*, align 8
  %sgn = alloca i32, align 4
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %tobool = icmp ne %struct.lp_int_ring_t* %0, null
  br i1 %tobool, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %1 = load %struct.__mpz_struct** %c.addr, align 8
  %_mp_size = getelementptr inbounds %struct.__mpz_struct* %1, i32 0, i32 1
  %2 = load i32* %_mp_size, align 4
  %cmp = icmp slt i32 %2, 0
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %3 = load %struct.__mpz_struct** %c.addr, align 8
  %_mp_size1 = getelementptr inbounds %struct.__mpz_struct* %3, i32 0, i32 1
  %4 = load i32* %_mp_size1, align 4
  %cmp2 = icmp sgt i32 %4, 0
  %conv = zext i1 %cmp2 to i32
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ -1, %cond.true ], [ %conv, %cond.false ]
  store i32 %cond, i32* %sgn, align 4
  %5 = load i32* %sgn, align 4
  %cmp3 = icmp eq i32 %5, 0
  br i1 %cmp3, label %if.then5, label %if.end

if.then5:                                         ; preds = %cond.end
  store i32 1, i32* %retval
  br label %return

if.end:                                           ; preds = %cond.end
  %6 = load i32* %sgn, align 4
  %cmp6 = icmp sgt i32 %6, 0
  br i1 %cmp6, label %land.lhs.true, label %if.end11

land.lhs.true:                                    ; preds = %if.end
  %7 = load %struct.__mpz_struct** %c.addr, align 8
  %8 = load %struct.lp_int_ring_t** %K.addr, align 8
  %ub = getelementptr inbounds %struct.lp_int_ring_t* %8, i32 0, i32 4
  %call = call i32 @__gmpz_cmp(%struct.__mpz_struct* %7, %struct.__mpz_struct* %ub) #8
  %cmp8 = icmp sle i32 %call, 0
  br i1 %cmp8, label %if.then10, label %if.end11

if.then10:                                        ; preds = %land.lhs.true
  store i32 1, i32* %retval
  br label %return

if.end11:                                         ; preds = %land.lhs.true, %if.end
  %9 = load i32* %sgn, align 4
  %cmp12 = icmp slt i32 %9, 0
  br i1 %cmp12, label %land.lhs.true14, label %if.end19

land.lhs.true14:                                  ; preds = %if.end11
  %10 = load %struct.lp_int_ring_t** %K.addr, align 8
  %lb = getelementptr inbounds %struct.lp_int_ring_t* %10, i32 0, i32 3
  %11 = load %struct.__mpz_struct** %c.addr, align 8
  %call15 = call i32 @__gmpz_cmp(%struct.__mpz_struct* %lb, %struct.__mpz_struct* %11) #8
  %cmp16 = icmp sle i32 %call15, 0
  br i1 %cmp16, label %if.then18, label %if.end19

if.then18:                                        ; preds = %land.lhs.true14
  store i32 1, i32* %retval
  br label %return

if.end19:                                         ; preds = %land.lhs.true14, %if.end11
  store i32 0, i32* %retval
  br label %return

if.else:                                          ; preds = %entry
  store i32 1, i32* %retval
  br label %return

return:                                           ; preds = %if.else, %if.end19, %if.then18, %if.then10, %if.then5
  %12 = load i32* %retval
  ret i32 %12
}

declare void @__gmpz_init(%struct.__mpz_struct*) #2

declare void @__gmpz_tdiv_r(%struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*) #2

declare void @__gmpz_swap(%struct.__mpz_struct*, %struct.__mpz_struct*) #2

; Function Attrs: nounwind readonly
declare i32 @__gmpz_cmp(%struct.__mpz_struct*, %struct.__mpz_struct*) #5

declare void @__gmpz_sub(%struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*) #2

declare void @__gmpz_add(%struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*) #2

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { inlinehint nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noreturn nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind readonly "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { noreturn nounwind }
attributes #7 = { nounwind }
attributes #8 = { nounwind readonly }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.5.2 (branches/release_35 229013) (llvm/branches/release_35 229009)"}
