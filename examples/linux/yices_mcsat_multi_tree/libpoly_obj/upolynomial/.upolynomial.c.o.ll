; ModuleID = '.upolynomial.c.o.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.lp_upolynomial_struct = type { %struct.lp_int_ring_t*, i64, [0 x %struct.umonomial_struct] }
%struct.lp_int_ring_t = type { i64, i32, %struct.__mpz_struct, %struct.__mpz_struct, %struct.__mpz_struct }
%struct.__mpz_struct = type { i32, i32, i64* }
%struct.umonomial_struct = type { i64, %struct.__mpz_struct }
%struct.upolynomial_dense_t = type { i64, i64, %struct.__mpz_struct* }
%struct.__mpq_struct = type { %struct.__mpz_struct, %struct.__mpz_struct }
%struct.lp_dyadic_rational_t = type { %struct.__mpz_struct, i64 }
%struct.lp_upolynomial_factors_struct = type opaque
%struct.lp_rational_interval_struct = type opaque
%struct.lp_algebraic_number_struct = type { %struct.lp_upolynomial_struct*, %struct.lp_dyadic_interval_struct, i32, i32 }
%struct.lp_dyadic_interval_struct = type { i8, %struct.lp_dyadic_rational_t, %struct.lp_dyadic_rational_t }

@.str = private unnamed_addr constant [2 x i8] c"p\00", align 1
@.str1 = private unnamed_addr constant [61 x i8] c"/home/iam/Repositories/libpoly/src/upolynomial/upolynomial.c\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_degree = private unnamed_addr constant [55 x i8] c"size_t lp_upolynomial_degree(const lp_upolynomial_t *)\00", align 1
@.str2 = private unnamed_addr constant [12 x i8] c"p->size > 0\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_delete = private unnamed_addr constant [47 x i8] c"void lp_upolynomial_delete(lp_upolynomial_t *)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_construct_copy = private unnamed_addr constant [74 x i8] c"lp_upolynomial_t *lp_upolynomial_construct_copy(const lp_upolynomial_t *)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_construct_copy_K = private unnamed_addr constant [93 x i8] c"lp_upolynomial_t *lp_upolynomial_construct_copy_K(lp_int_ring_t *, const lp_upolynomial_t *)\00", align 1
@.str3 = private unnamed_addr constant [10 x i8] c"K != p->K\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_unpack = private unnamed_addr constant [69 x i8] c"void lp_upolynomial_unpack(const lp_upolynomial_t *, lp_integer_t *)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_ring = private unnamed_addr constant [61 x i8] c"lp_int_ring_t *lp_upolynomial_ring(const lp_upolynomial_t *)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_set_ring = private unnamed_addr constant [66 x i8] c"void lp_upolynomial_set_ring(lp_upolynomial_t *, lp_int_ring_t *)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_lead_coeff = private unnamed_addr constant [72 x i8] c"const lp_integer_t *lp_upolynomial_lead_coeff(const lp_upolynomial_t *)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_const_term = private unnamed_addr constant [72 x i8] c"const lp_integer_t *lp_upolynomial_const_term(const lp_upolynomial_t *)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_cmp = private unnamed_addr constant [75 x i8] c"int lp_upolynomial_cmp(const lp_upolynomial_t *, const lp_upolynomial_t *)\00", align 1
@.str4 = private unnamed_addr constant [2 x i8] c"q\00", align 1
@.str5 = private unnamed_addr constant [13 x i8] c"p->K == q->K\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_add = private unnamed_addr constant [89 x i8] c"lp_upolynomial_t *lp_upolynomial_add(const lp_upolynomial_t *, const lp_upolynomial_t *)\00", align 1
@.str6 = private unnamed_addr constant [11 x i8] c"arithmetic\00", align 1
@trace_out_real = external global %struct._IO_FILE*
@stderr = external global %struct._IO_FILE*
@.str7 = private unnamed_addr constant [17 x i8] c"upolynomial_add(\00", align 1
@.str8 = private unnamed_addr constant [3 x i8] c", \00", align 1
@.str9 = private unnamed_addr constant [3 x i8] c")\0A\00", align 1
@.str10 = private unnamed_addr constant [5 x i8] c") = \00", align 1
@.str11 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_sub = private unnamed_addr constant [89 x i8] c"lp_upolynomial_t *lp_upolynomial_sub(const lp_upolynomial_t *, const lp_upolynomial_t *)\00", align 1
@.str12 = private unnamed_addr constant [17 x i8] c"upolynomial_sub(\00", align 1
@.str13 = private unnamed_addr constant [2 x i8] c"m\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_multiply_simple = private unnamed_addr constant [99 x i8] c"lp_upolynomial_t *lp_upolynomial_multiply_simple(const ulp_monomial_t *, const lp_upolynomial_t *)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_mul = private unnamed_addr constant [89 x i8] c"lp_upolynomial_t *lp_upolynomial_mul(const lp_upolynomial_t *, const lp_upolynomial_t *)\00", align 1
@.str14 = private unnamed_addr constant [22 x i8] c"upolynomial_multiply(\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_mul_c = private unnamed_addr constant [87 x i8] c"lp_upolynomial_t *lp_upolynomial_mul_c(const lp_upolynomial_t *, const lp_integer_t *)\00", align 1
@.str15 = private unnamed_addr constant [24 x i8] c"upolynomial_multiply_c(\00", align 1
@.str16 = private unnamed_addr constant [17 x i8] c"upolynomial_pow(\00", align 1
@.str17 = private unnamed_addr constant [8 x i8] c", %ld)\0A\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_pow = private unnamed_addr constant [69 x i8] c"lp_upolynomial_t *lp_upolynomial_pow(const lp_upolynomial_t *, long)\00", align 1
@.str18 = private unnamed_addr constant [9 x i8] c"pow >= 0\00", align 1
@.str19 = private unnamed_addr constant [10 x i8] c", %ld) = \00", align 1
@.str20 = private unnamed_addr constant [24 x i8] c"upolynomial_derivative(\00", align 1
@.str21 = private unnamed_addr constant [9 x i8] c"division\00", align 1
@.str22 = private unnamed_addr constant [25 x i8] c"upolynomial_div_general(\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_div_general = private unnamed_addr constant [135 x i8] c"void lp_upolynomial_div_general(const lp_upolynomial_t *, const lp_upolynomial_t *, upolynomial_dense_t *, upolynomial_dense_t *, int)\00", align 1
@.str23 = private unnamed_addr constant [53 x i8] c"lp_upolynomial_degree(q) <= lp_upolynomial_degree(p)\00", align 1
@.str24 = private unnamed_addr constant [15 x i8] c"dividing with \00", align 1
@.str25 = private unnamed_addr constant [15 x i8] c" at degree %d\0A\00", align 1
@.str26 = private unnamed_addr constant [7 x i8] c"rem = \00", align 1
@.str27 = private unnamed_addr constant [7 x i8] c"div = \00", align 1
@.str28 = private unnamed_addr constant [82 x i8] c"!exact || integer_divides(K, lp_upolynomial_lead_coeff(q), rem->coefficients + k)\00", align 1
@.str29 = private unnamed_addr constant [25 x i8] c"upolynomial_div_degrees(\00", align 1
@.str30 = private unnamed_addr constant [8 x i8] c", %zd)\0A\00", align 1
@.str31 = private unnamed_addr constant [6 x i8] c"a > 1\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_div_degrees = private unnamed_addr constant [79 x i8] c"lp_upolynomial_t *lp_upolynomial_div_degrees(const lp_upolynomial_t *, size_t)\00", align 1
@.str32 = private unnamed_addr constant [37 x i8] c"result->monomials[i].degree % a == 0\00", align 1
@.str33 = private unnamed_addr constant [10 x i8] c", %zd) = \00", align 1
@.str34 = private unnamed_addr constant [23 x i8] c"upolynomial_div_exact(\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_div_exact = private unnamed_addr constant [95 x i8] c"lp_upolynomial_t *lp_upolynomial_div_exact(const lp_upolynomial_t *, const lp_upolynomial_t *)\00", align 1
@.str35 = private unnamed_addr constant [27 x i8] c"!lp_upolynomial_is_zero(q)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_div_exact_c = private unnamed_addr constant [93 x i8] c"lp_upolynomial_t *lp_upolynomial_div_exact_c(const lp_upolynomial_t *, const lp_integer_t *)\00", align 1
@.str36 = private unnamed_addr constant [25 x i8] c"integer_cmp_int(K, c, 0)\00", align 1
@.str37 = private unnamed_addr constant [52 x i8] c"integer_divides(K, c, &p->monomials[i].coefficient)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_rem_exact = private unnamed_addr constant [95 x i8] c"lp_upolynomial_t *lp_upolynomial_rem_exact(const lp_upolynomial_t *, const lp_upolynomial_t *)\00", align 1
@.str38 = private unnamed_addr constant [23 x i8] c"upolynomial_rem_exact(\00", align 1
@.str39 = private unnamed_addr constant [27 x i8] c"upolynomial_div_rem_exact(\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_div_rem_exact = private unnamed_addr constant [128 x i8] c"void lp_upolynomial_div_rem_exact(const lp_upolynomial_t *, const lp_upolynomial_t *, lp_upolynomial_t **, lp_upolynomial_t **)\00", align 1
@.str40 = private unnamed_addr constant [23 x i8] c"*div == 0 && *rem == 0\00", align 1
@.str41 = private unnamed_addr constant [6 x i8] c") = (\00", align 1
@.str42 = private unnamed_addr constant [24 x i8] c"upolynomial_div_pseudo(\00", align 1
@.str43 = private unnamed_addr constant [6 x i8] c"!*div\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_div_pseudo = private unnamed_addr constant [125 x i8] c"void lp_upolynomial_div_pseudo(lp_upolynomial_t **, lp_upolynomial_t **, const lp_upolynomial_t *, const lp_upolynomial_t *)\00", align 1
@.str44 = private unnamed_addr constant [6 x i8] c"!*rem\00", align 1
@.str45 = private unnamed_addr constant [53 x i8] c"lp_upolynomial_degree(p) >= lp_upolynomial_degree(q)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_divides = private unnamed_addr constant [79 x i8] c"int lp_upolynomial_divides(const lp_upolynomial_t *, const lp_upolynomial_t *)\00", align 1
@.str46 = private unnamed_addr constant [8 x i8] c") = %d\0A\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_content_Z = private unnamed_addr constant [72 x i8] c"void lp_upolynomial_content_Z(const lp_upolynomial_t *, lp_integer_t *)\00", align 1
@.str47 = private unnamed_addr constant [10 x i8] c"p->K == 0\00", align 1
@.str48 = private unnamed_addr constant [28 x i8] c"integer_sgn(0, content) > 0\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_is_primitive = private unnamed_addr constant [58 x i8] c"int lp_upolynomial_is_primitive(const lp_upolynomial_t *)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_make_primitive_Z = private unnamed_addr constant [57 x i8] c"void lp_upolynomial_make_primitive_Z(lp_upolynomial_t *)\00", align 1
@.str49 = private unnamed_addr constant [55 x i8] c"integer_divides(0, &gcd, &p->monomials[i].coefficient)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_primitive_part_Z = private unnamed_addr constant [76 x i8] c"lp_upolynomial_t *lp_upolynomial_primitive_part_Z(const lp_upolynomial_t *)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_evaluate_at_rational = private unnamed_addr constant [107 x i8] c"void lp_upolynomial_evaluate_at_rational(const lp_upolynomial_t *, const lp_rational_t *, lp_rational_t *)\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_evaluate_at_dyadic_rational = private unnamed_addr constant [128 x i8] c"void lp_upolynomial_evaluate_at_dyadic_rational(const lp_upolynomial_t *, const lp_dyadic_rational_t *, lp_dyadic_rational_t *)\00", align 1
@.str50 = private unnamed_addr constant [4 x i8] c"gcd\00", align 1
@.str51 = private unnamed_addr constant [17 x i8] c"upolynomial_gcd(\00", align 1
@.str52 = private unnamed_addr constant [28 x i8] c"p->K == 0 || p->K->is_prime\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_gcd = private unnamed_addr constant [89 x i8] c"lp_upolynomial_t *lp_upolynomial_gcd(const lp_upolynomial_t *, const lp_upolynomial_t *)\00", align 1
@.str53 = private unnamed_addr constant [23 x i8] c"p->K && p->K->is_prime\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_extended_gcd = private unnamed_addr constant [140 x i8] c"lp_upolynomial_t *lp_upolynomial_extended_gcd(const lp_upolynomial_t *, const lp_upolynomial_t *, lp_upolynomial_t **, lp_upolynomial_t **)\00", align 1
@.str54 = private unnamed_addr constant [8 x i8] c"*u == 0\00", align 1
@.str55 = private unnamed_addr constant [8 x i8] c"*v == 0\00", align 1
@.str56 = private unnamed_addr constant [19 x i8] c"*u == 0 && *v == 0\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_solve_bezout = private unnamed_addr constant [153 x i8] c"void lp_upolynomial_solve_bezout(const lp_upolynomial_t *, const lp_upolynomial_t *, const lp_upolynomial_t *, lp_upolynomial_t **, lp_upolynomial_t **)\00", align 1
@.str57 = private unnamed_addr constant [14 x i8] c"factorization\00", align 1
@.str58 = private unnamed_addr constant [20 x i8] c"upolynomial_factor(\00", align 1
@.str59 = private unnamed_addr constant [15 x i8] c"p->K->is_prime\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_factor = private unnamed_addr constant [74 x i8] c"lp_upolynomial_factors_t *lp_upolynomial_factor(const lp_upolynomial_t *)\00", align 1
@.str60 = private unnamed_addr constant [6 x i8] c"roots\00", align 1
@.str61 = private unnamed_addr constant [30 x i8] c"upolynomial_real_roots_count(\00", align 1
@.str62 = private unnamed_addr constant [9 x i8] c") => %d\0A\00", align 1
@.str63 = private unnamed_addr constant [27 x i8] c"upolynomial_roots_isolate(\00", align 1
@.str64 = private unnamed_addr constant [10 x i8] c") => %zu\0A\00", align 1
@.str65 = private unnamed_addr constant [34 x i8] c"upolynomial_roots_sturm_sequence(\00", align 1
@.str66 = private unnamed_addr constant [10 x i8] c"f->K == 0\00", align 1
@__PRETTY_FUNCTION__.lp_upolynomial_sturm_sequence = private unnamed_addr constant [93 x i8] c"void lp_upolynomial_sturm_sequence(const lp_upolynomial_t *, lp_upolynomial_t ***, size_t *)\00", align 1
@.str67 = private unnamed_addr constant [33 x i8] c"dyadic_rational_is_normalized(q)\00", align 1
@.str68 = private unnamed_addr constant [60 x i8] c"/home/iam/Repositories/libpoly/src/number/dyadic_rational.h\00", align 1
@__PRETTY_FUNCTION__.dyadic_rational_sgn = private unnamed_addr constant [54 x i8] c"int dyadic_rational_sgn(const lp_dyadic_rational_t *)\00", align 1
@.str69 = private unnamed_addr constant [82 x i8] c"integer_in_ring(K, sum_product) && integer_in_ring(K, a) && integer_in_ring(K, b)\00", align 1
@.str70 = private unnamed_addr constant [52 x i8] c"/home/iam/Repositories/libpoly/src/number/integer.h\00", align 1
@__PRETTY_FUNCTION__.integer_add_mul = private unnamed_addr constant [98 x i8] c"void integer_add_mul(lp_int_ring_t *, lp_integer_t *, const lp_integer_t *, const lp_integer_t *)\00", align 1
@.str71 = private unnamed_addr constant [22 x i8] c"integer_in_ring(K, c)\00", align 1
@__PRETTY_FUNCTION__.integer_ring_normalize = private unnamed_addr constant [61 x i8] c"void integer_ring_normalize(lp_int_ring_t *, lp_integer_t *)\00", align 1
@.str72 = private unnamed_addr constant [22 x i8] c"integer_in_ring(K, a)\00", align 1
@__PRETTY_FUNCTION__.integer_neg = private unnamed_addr constant [72 x i8] c"void integer_neg(lp_int_ring_t *, lp_integer_t *, const lp_integer_t *)\00", align 1
@.str73 = private unnamed_addr constant [47 x i8] c"integer_in_ring(K, a) && integer_in_ring(K, b)\00", align 1
@__PRETTY_FUNCTION__.integer_div_exact = private unnamed_addr constant [100 x i8] c"void integer_div_exact(lp_int_ring_t *, lp_integer_t *, const lp_integer_t *, const lp_integer_t *)\00", align 1
@.str74 = private unnamed_addr constant [28 x i8] c"__gmpz_divisible_p(a, &gcd)\00", align 1
@__PRETTY_FUNCTION__.integer_divides = private unnamed_addr constant [81 x i8] c"int integer_divides(lp_int_ring_t *, const lp_integer_t *, const lp_integer_t *)\00", align 1
@__PRETTY_FUNCTION__.integer_mul_int = private unnamed_addr constant [82 x i8] c"void integer_mul_int(lp_int_ring_t *, lp_integer_t *, const lp_integer_t *, long)\00", align 1
@__PRETTY_FUNCTION__.integer_pow = private unnamed_addr constant [86 x i8] c"void integer_pow(lp_int_ring_t *, lp_integer_t *, const lp_integer_t *, unsigned int)\00", align 1
@__PRETTY_FUNCTION__.integer_mul = private unnamed_addr constant [94 x i8] c"void integer_mul(lp_int_ring_t *, lp_integer_t *, const lp_integer_t *, const lp_integer_t *)\00", align 1

; Function Attrs: nounwind uwtable
define i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 40, i8* getelementptr inbounds ([55 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_degree, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %2, i32 0, i32 1
  %3 = load i64* %size, align 8
  %cmp = icmp ugt i64 %3, 0
  br i1 %cmp, label %cond.true1, label %cond.false2

cond.true1:                                       ; preds = %cond.end
  br label %cond.end3

cond.false2:                                      ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([12 x i8]* @.str2, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 41, i8* getelementptr inbounds ([55 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_degree, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end3

cond.end3:                                        ; preds = %4, %cond.true1
  %5 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size4 = getelementptr inbounds %struct.lp_upolynomial_struct* %5, i32 0, i32 1
  %6 = load i64* %size4, align 8
  %sub = sub i64 %6, 1
  %7 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %7, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %sub
  %degree = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 0
  %8 = load i64* %degree, align 8
  ret i64 %8
}

; Function Attrs: noreturn nounwind
declare void @__assert_fail(i8*, i8*, i32, i8*) #1

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_construct_empty(%struct.lp_int_ring_t* %K, i64 %size) #0 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %size.addr = alloca i64, align 8
  %malloc_size = alloca i64, align 8
  %new_p = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store i64 %size, i64* %size.addr, align 8
  %0 = load i64* %size.addr, align 8
  %mul = mul i64 %0, 24
  %add = add i64 16, %mul
  store i64 %add, i64* %malloc_size, align 8
  %1 = load i64* %malloc_size, align 8
  %call = call noalias i8* @malloc(i64 %1) #5
  %2 = bitcast i8* %call to %struct.lp_upolynomial_struct*
  store %struct.lp_upolynomial_struct* %2, %struct.lp_upolynomial_struct** %new_p, align 8
  %3 = load %struct.lp_int_ring_t** %K.addr, align 8
  %4 = load %struct.lp_upolynomial_struct** %new_p, align 8
  %K1 = getelementptr inbounds %struct.lp_upolynomial_struct* %4, i32 0, i32 0
  store %struct.lp_int_ring_t* %3, %struct.lp_int_ring_t** %K1, align 8
  %5 = load i64* %size.addr, align 8
  %6 = load %struct.lp_upolynomial_struct** %new_p, align 8
  %size2 = getelementptr inbounds %struct.lp_upolynomial_struct* %6, i32 0, i32 1
  store i64 %5, i64* %size2, align 8
  %7 = load %struct.lp_int_ring_t** %K.addr, align 8
  call void @lp_int_ring_attach(%struct.lp_int_ring_t* %7)
  %8 = load %struct.lp_upolynomial_struct** %new_p, align 8
  ret %struct.lp_upolynomial_struct* %8
}

; Function Attrs: nounwind
declare noalias i8* @malloc(i64) #2

declare void @lp_int_ring_attach(%struct.lp_int_ring_t*) #3

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_construct(%struct.lp_int_ring_t* %K, i64 %degree, %struct.__mpz_struct* %coefficients) #0 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %degree.addr = alloca i64, align 8
  %coefficients.addr = alloca %struct.__mpz_struct*, align 8
  %i = alloca i32, align 4
  %size = alloca i32, align 4
  %new_p = alloca %struct.lp_upolynomial_struct*, align 8
  %tmp = alloca %struct.__mpz_struct, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store i64 %degree, i64* %degree.addr, align 8
  store %struct.__mpz_struct* %coefficients, %struct.__mpz_struct** %coefficients.addr, align 8
  store i32 0, i32* %size, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32* %i, align 4
  %conv = zext i32 %0 to i64
  %1 = load i64* %degree.addr, align 8
  %cmp = icmp ule i64 %conv, %1
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %2 = load %struct.lp_int_ring_t** %K.addr, align 8
  %3 = load %struct.__mpz_struct** %coefficients.addr, align 8
  %4 = load i32* %i, align 4
  %idx.ext = zext i32 %4 to i64
  %add.ptr = getelementptr inbounds %struct.__mpz_struct* %3, i64 %idx.ext
  %call = call i32 @integer_sgn(%struct.lp_int_ring_t* %2, %struct.__mpz_struct* %add.ptr)
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %5 = load i32* %size, align 4
  %inc = add i32 %5, 1
  store i32 %inc, i32* %size, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %6 = load i32* %i, align 4
  %inc2 = add i32 %6, 1
  store i32 %inc2, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %7 = load i32* %size, align 4
  %cmp3 = icmp eq i32 %7, 0
  br i1 %cmp3, label %if.then5, label %if.end6

if.then5:                                         ; preds = %for.end
  store i32 1, i32* %size, align 4
  br label %if.end6

if.end6:                                          ; preds = %if.then5, %for.end
  %8 = load %struct.lp_int_ring_t** %K.addr, align 8
  %9 = load i32* %size, align 4
  %cmp7 = icmp ugt i32 %9, 0
  br i1 %cmp7, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.end6
  %10 = load i32* %size, align 4
  br label %cond.end

cond.false:                                       ; preds = %if.end6
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %10, %cond.true ], [ 1, %cond.false ]
  %conv9 = zext i32 %cond to i64
  %call10 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_empty(%struct.lp_int_ring_t* %8, i64 %conv9)
  store %struct.lp_upolynomial_struct* %call10, %struct.lp_upolynomial_struct** %new_p, align 8
  store i32 0, i32* %size, align 4
  call void @integer_construct_from_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %tmp, i64 0)
  store i32 0, i32* %i, align 4
  br label %for.cond11

for.cond11:                                       ; preds = %for.inc24, %cond.end
  %11 = load i32* %i, align 4
  %conv12 = zext i32 %11 to i64
  %12 = load i64* %degree.addr, align 8
  %cmp13 = icmp ule i64 %conv12, %12
  br i1 %cmp13, label %for.body15, label %for.end26

for.body15:                                       ; preds = %for.cond11
  %13 = load %struct.lp_int_ring_t** %K.addr, align 8
  %14 = load %struct.__mpz_struct** %coefficients.addr, align 8
  %15 = load i32* %i, align 4
  %idx.ext16 = zext i32 %15 to i64
  %add.ptr17 = getelementptr inbounds %struct.__mpz_struct* %14, i64 %idx.ext16
  call void @integer_assign(%struct.lp_int_ring_t* %13, %struct.__mpz_struct* %tmp, %struct.__mpz_struct* %add.ptr17)
  %call18 = call i32 @integer_sgn(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %tmp)
  %tobool19 = icmp ne i32 %call18, 0
  br i1 %tobool19, label %if.then20, label %if.end23

if.then20:                                        ; preds = %for.body15
  %16 = load %struct.lp_int_ring_t** %K.addr, align 8
  %17 = load i32* %size, align 4
  %idxprom = zext i32 %17 to i64
  %18 = load %struct.lp_upolynomial_struct** %new_p, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %18, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %idxprom
  %19 = load i32* %i, align 4
  %conv21 = zext i32 %19 to i64
  call void @umonomial_construct(%struct.lp_int_ring_t* %16, %struct.umonomial_struct* %arrayidx, i64 %conv21, %struct.__mpz_struct* %tmp)
  %20 = load i32* %size, align 4
  %inc22 = add i32 %20, 1
  store i32 %inc22, i32* %size, align 4
  br label %if.end23

if.end23:                                         ; preds = %if.then20, %for.body15
  br label %for.inc24

for.inc24:                                        ; preds = %if.end23
  %21 = load i32* %i, align 4
  %inc25 = add i32 %21, 1
  store i32 %inc25, i32* %i, align 4
  br label %for.cond11

for.end26:                                        ; preds = %for.cond11
  call void @integer_destruct(%struct.__mpz_struct* %tmp)
  %22 = load i32* %size, align 4
  %cmp27 = icmp eq i32 %22, 0
  br i1 %cmp27, label %if.then29, label %if.end32

if.then29:                                        ; preds = %for.end26
  %23 = load %struct.lp_int_ring_t** %K.addr, align 8
  %24 = load %struct.lp_upolynomial_struct** %new_p, align 8
  %monomials30 = getelementptr inbounds %struct.lp_upolynomial_struct* %24, i32 0, i32 2
  %arrayidx31 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials30, i32 0, i64 0
  call void @umonomial_construct_from_int(%struct.lp_int_ring_t* %23, %struct.umonomial_struct* %arrayidx31, i64 0, i64 0)
  store i32 1, i32* %size, align 4
  br label %if.end32

if.end32:                                         ; preds = %if.then29, %for.end26
  %25 = load %struct.lp_upolynomial_struct** %new_p, align 8
  ret %struct.lp_upolynomial_struct* %25
}

; Function Attrs: inlinehint nounwind uwtable
define internal i32 @integer_sgn(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c) #4 {
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

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_construct_from_int(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c, i64 %x) #4 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %c.addr = alloca %struct.__mpz_struct*, align 8
  %x.addr = alloca i64, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  store i64 %x, i64* %x.addr, align 8
  %0 = load %struct.__mpz_struct** %c.addr, align 8
  %1 = load i64* %x.addr, align 8
  call void @__gmpz_init_set_si(%struct.__mpz_struct* %0, i64 %1)
  %2 = load %struct.lp_int_ring_t** %K.addr, align 8
  %3 = load %struct.__mpz_struct** %c.addr, align 8
  call void @integer_ring_normalize(%struct.lp_int_ring_t* %2, %struct.__mpz_struct* %3)
  ret void
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_assign(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c, %struct.__mpz_struct* %from) #4 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %c.addr = alloca %struct.__mpz_struct*, align 8
  %from.addr = alloca %struct.__mpz_struct*, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  store %struct.__mpz_struct* %from, %struct.__mpz_struct** %from.addr, align 8
  %0 = load %struct.__mpz_struct** %c.addr, align 8
  %1 = load %struct.__mpz_struct** %from.addr, align 8
  call void @__gmpz_set(%struct.__mpz_struct* %0, %struct.__mpz_struct* %1)
  %2 = load %struct.lp_int_ring_t** %K.addr, align 8
  %3 = load %struct.__mpz_struct** %c.addr, align 8
  call void @integer_ring_normalize(%struct.lp_int_ring_t* %2, %struct.__mpz_struct* %3)
  ret void
}

declare void @umonomial_construct(%struct.lp_int_ring_t*, %struct.umonomial_struct*, i64, %struct.__mpz_struct*) #3

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_destruct(%struct.__mpz_struct* %c) #4 {
entry:
  %c.addr = alloca %struct.__mpz_struct*, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  %0 = load %struct.__mpz_struct** %c.addr, align 8
  call void @__gmpz_clear(%struct.__mpz_struct* %0)
  ret void
}

declare void @umonomial_construct_from_int(%struct.lp_int_ring_t*, %struct.umonomial_struct*, i64, i64) #3

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %i = alloca i64, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 98, i8* getelementptr inbounds ([47 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_delete, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  store i64 0, i64* %i, align 8
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %cond.end
  %2 = load i64* %i, align 8
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %3, i32 0, i32 1
  %4 = load i64* %size, align 8
  %cmp = icmp ult i64 %2, %4
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %5 = load i64* %i, align 8
  %6 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %6, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %5
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 1
  call void @integer_destruct(%struct.__mpz_struct* %coefficient)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %7 = load i64* %i, align 8
  %inc = add i64 %7, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %8 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %8, i32 0, i32 0
  %9 = load %struct.lp_int_ring_t** %K, align 8
  call void @lp_int_ring_detach(%struct.lp_int_ring_t* %9)
  %10 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %11 = bitcast %struct.lp_upolynomial_struct* %10 to i8*
  call void @free(i8* %11) #5
  ret void
}

declare void @lp_int_ring_detach(%struct.lp_int_ring_t*) #3

; Function Attrs: nounwind
declare void @free(i8*) #2

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_construct_power(%struct.lp_int_ring_t* %K, i64 %degree, i64 %c) #0 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %degree.addr = alloca i64, align 8
  %c.addr = alloca i64, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store i64 %degree, i64* %degree.addr, align 8
  store i64 %c, i64* %c.addr, align 8
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %call = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_empty(%struct.lp_int_ring_t* %0, i64 1)
  store %struct.lp_upolynomial_struct* %call, %struct.lp_upolynomial_struct** %result, align 8
  %1 = load %struct.lp_int_ring_t** %K.addr, align 8
  %2 = load %struct.lp_upolynomial_struct** %result, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %2, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 0
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 1
  %3 = load i64* %c.addr, align 8
  call void @integer_construct_from_int(%struct.lp_int_ring_t* %1, %struct.__mpz_struct* %coefficient, i64 %3)
  %4 = load i64* %degree.addr, align 8
  %5 = load %struct.lp_upolynomial_struct** %result, align 8
  %monomials1 = getelementptr inbounds %struct.lp_upolynomial_struct* %5, i32 0, i32 2
  %arrayidx2 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials1, i32 0, i64 0
  %degree3 = getelementptr inbounds %struct.umonomial_struct* %arrayidx2, i32 0, i32 0
  store i64 %4, i64* %degree3, align 8
  %6 = load %struct.lp_upolynomial_struct** %result, align 8
  ret %struct.lp_upolynomial_struct* %6
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_construct_from_int(%struct.lp_int_ring_t* %K, i64 %degree, i32* %coefficients) #0 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %degree.addr = alloca i64, align 8
  %coefficients.addr = alloca i32*, align 8
  %i = alloca i32, align 4
  %saved_stack = alloca i8*
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  %cleanup.dest.slot = alloca i32
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store i64 %degree, i64* %degree.addr, align 8
  store i32* %coefficients, i32** %coefficients.addr, align 8
  %0 = load i64* %degree.addr, align 8
  %add = add i64 %0, 1
  %1 = call i8* @llvm.stacksave()
  store i8* %1, i8** %saved_stack
  %vla = alloca %struct.__mpz_struct, i64 %add, align 16
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %2 = load i32* %i, align 4
  %conv = zext i32 %2 to i64
  %3 = load i64* %degree.addr, align 8
  %cmp = icmp ule i64 %conv, %3
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %4 = load %struct.lp_int_ring_t** %K.addr, align 8
  %5 = load i32* %i, align 4
  %idxprom = zext i32 %5 to i64
  %arrayidx = getelementptr inbounds %struct.__mpz_struct* %vla, i64 %idxprom
  %6 = load i32* %i, align 4
  %idxprom2 = zext i32 %6 to i64
  %7 = load i32** %coefficients.addr, align 8
  %arrayidx3 = getelementptr inbounds i32* %7, i64 %idxprom2
  %8 = load i32* %arrayidx3, align 4
  %conv4 = sext i32 %8 to i64
  call void @integer_construct_from_int(%struct.lp_int_ring_t* %4, %struct.__mpz_struct* %arrayidx, i64 %conv4)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %9 = load i32* %i, align 4
  %inc = add i32 %9, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %10 = load %struct.lp_int_ring_t** %K.addr, align 8
  %11 = load i64* %degree.addr, align 8
  %call = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct(%struct.lp_int_ring_t* %10, i64 %11, %struct.__mpz_struct* %vla)
  store %struct.lp_upolynomial_struct* %call, %struct.lp_upolynomial_struct** %result, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond5

for.cond5:                                        ; preds = %for.inc12, %for.end
  %12 = load i32* %i, align 4
  %conv6 = zext i32 %12 to i64
  %13 = load i64* %degree.addr, align 8
  %cmp7 = icmp ule i64 %conv6, %13
  br i1 %cmp7, label %for.body9, label %for.end14

for.body9:                                        ; preds = %for.cond5
  %14 = load i32* %i, align 4
  %idxprom10 = zext i32 %14 to i64
  %arrayidx11 = getelementptr inbounds %struct.__mpz_struct* %vla, i64 %idxprom10
  call void @integer_destruct(%struct.__mpz_struct* %arrayidx11)
  br label %for.inc12

for.inc12:                                        ; preds = %for.body9
  %15 = load i32* %i, align 4
  %inc13 = add i32 %15, 1
  store i32 %inc13, i32* %i, align 4
  br label %for.cond5

for.end14:                                        ; preds = %for.cond5
  %16 = load %struct.lp_upolynomial_struct** %result, align 8
  store i32 1, i32* %cleanup.dest.slot
  %17 = load i8** %saved_stack
  call void @llvm.stackrestore(i8* %17)
  ret %struct.lp_upolynomial_struct* %16
}

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #5

; Function Attrs: nounwind
declare void @llvm.stackrestore(i8*) #5

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_construct_from_long(%struct.lp_int_ring_t* %K, i64 %degree, i64* %coefficients) #0 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %degree.addr = alloca i64, align 8
  %coefficients.addr = alloca i64*, align 8
  %i = alloca i32, align 4
  %saved_stack = alloca i8*
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  %cleanup.dest.slot = alloca i32
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store i64 %degree, i64* %degree.addr, align 8
  store i64* %coefficients, i64** %coefficients.addr, align 8
  %0 = load i64* %degree.addr, align 8
  %add = add i64 %0, 1
  %1 = call i8* @llvm.stacksave()
  store i8* %1, i8** %saved_stack
  %vla = alloca %struct.__mpz_struct, i64 %add, align 16
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %2 = load i32* %i, align 4
  %conv = zext i32 %2 to i64
  %3 = load i64* %degree.addr, align 8
  %cmp = icmp ule i64 %conv, %3
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %4 = load %struct.lp_int_ring_t** %K.addr, align 8
  %5 = load i32* %i, align 4
  %idxprom = zext i32 %5 to i64
  %arrayidx = getelementptr inbounds %struct.__mpz_struct* %vla, i64 %idxprom
  %6 = load i32* %i, align 4
  %idxprom2 = zext i32 %6 to i64
  %7 = load i64** %coefficients.addr, align 8
  %arrayidx3 = getelementptr inbounds i64* %7, i64 %idxprom2
  %8 = load i64* %arrayidx3, align 8
  call void @integer_construct_from_int(%struct.lp_int_ring_t* %4, %struct.__mpz_struct* %arrayidx, i64 %8)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %9 = load i32* %i, align 4
  %inc = add i32 %9, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %10 = load %struct.lp_int_ring_t** %K.addr, align 8
  %11 = load i64* %degree.addr, align 8
  %call = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct(%struct.lp_int_ring_t* %10, i64 %11, %struct.__mpz_struct* %vla)
  store %struct.lp_upolynomial_struct* %call, %struct.lp_upolynomial_struct** %result, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond4

for.cond4:                                        ; preds = %for.inc11, %for.end
  %12 = load i32* %i, align 4
  %conv5 = zext i32 %12 to i64
  %13 = load i64* %degree.addr, align 8
  %cmp6 = icmp ule i64 %conv5, %13
  br i1 %cmp6, label %for.body8, label %for.end13

for.body8:                                        ; preds = %for.cond4
  %14 = load i32* %i, align 4
  %idxprom9 = zext i32 %14 to i64
  %arrayidx10 = getelementptr inbounds %struct.__mpz_struct* %vla, i64 %idxprom9
  call void @integer_destruct(%struct.__mpz_struct* %arrayidx10)
  br label %for.inc11

for.inc11:                                        ; preds = %for.body8
  %15 = load i32* %i, align 4
  %inc12 = add i32 %15, 1
  store i32 %inc12, i32* %i, align 4
  br label %for.cond4

for.end13:                                        ; preds = %for.cond4
  %16 = load %struct.lp_upolynomial_struct** %result, align 8
  store i32 1, i32* %cleanup.dest.slot
  %17 = load i8** %saved_stack
  call void @llvm.stackrestore(i8* %17)
  ret %struct.lp_upolynomial_struct* %16
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %new_p = alloca %struct.lp_upolynomial_struct*, align 8
  %i = alloca i32, align 4
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 151, i8* getelementptr inbounds ([74 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_construct_copy, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %2, i32 0, i32 0
  %3 = load %struct.lp_int_ring_t** %K, align 8
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %4, i32 0, i32 1
  %5 = load i64* %size, align 8
  %call = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_empty(%struct.lp_int_ring_t* %3, i64 %5)
  store %struct.lp_upolynomial_struct* %call, %struct.lp_upolynomial_struct** %new_p, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %cond.end
  %6 = load i32* %i, align 4
  %conv = zext i32 %6 to i64
  %7 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size1 = getelementptr inbounds %struct.lp_upolynomial_struct* %7, i32 0, i32 1
  %8 = load i64* %size1, align 8
  %cmp = icmp ult i64 %conv, %8
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %9 = load i32* %i, align 4
  %idxprom = zext i32 %9 to i64
  %10 = load %struct.lp_upolynomial_struct** %new_p, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %10, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %idxprom
  %11 = load i32* %i, align 4
  %idxprom3 = zext i32 %11 to i64
  %12 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials4 = getelementptr inbounds %struct.lp_upolynomial_struct* %12, i32 0, i32 2
  %arrayidx5 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials4, i32 0, i64 %idxprom3
  call void @umonomial_construct_copy(%struct.lp_int_ring_t* null, %struct.umonomial_struct* %arrayidx, %struct.umonomial_struct* %arrayidx5)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %13 = load i32* %i, align 4
  %inc = add i32 %13, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %14 = load %struct.lp_upolynomial_struct** %new_p, align 8
  ret %struct.lp_upolynomial_struct* %14
}

declare void @umonomial_construct_copy(%struct.lp_int_ring_t*, %struct.umonomial_struct*, %struct.umonomial_struct*) #3

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy_K(%struct.lp_int_ring_t* %K, %struct.lp_upolynomial_struct* %p) #0 {
entry:
  %retval = alloca %struct.lp_upolynomial_struct*, align 8
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %copy = alloca %struct.lp_upolynomial_struct*, align 8
  %i = alloca i32, align 4
  %size = alloca i64, align 8
  %degree = alloca i64, align 8
  %new_p = alloca %struct.lp_upolynomial_struct*, align 8
  %tmp = alloca %struct.__mpz_struct, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 165, i8* getelementptr inbounds ([93 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_construct_copy_K, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_int_ring_t** %K.addr, align 8
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K1 = getelementptr inbounds %struct.lp_upolynomial_struct* %3, i32 0, i32 0
  %4 = load %struct.lp_int_ring_t** %K1, align 8
  %cmp = icmp ne %struct.lp_int_ring_t* %2, %4
  br i1 %cmp, label %cond.true2, label %cond.false3

cond.true2:                                       ; preds = %cond.end
  br label %cond.end4

cond.false3:                                      ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([10 x i8]* @.str3, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 166, i8* getelementptr inbounds ([93 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_construct_copy_K, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end4

cond.end4:                                        ; preds = %5, %cond.true2
  %6 = load %struct.lp_int_ring_t** %K.addr, align 8
  %cmp5 = icmp eq %struct.lp_int_ring_t* %6, null
  br i1 %cmp5, label %if.then, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %cond.end4
  %7 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K6 = getelementptr inbounds %struct.lp_upolynomial_struct* %7, i32 0, i32 0
  %8 = load %struct.lp_int_ring_t** %K6, align 8
  %cmp7 = icmp ne %struct.lp_int_ring_t* %8, null
  br i1 %cmp7, label %land.lhs.true, label %if.end

land.lhs.true:                                    ; preds = %lor.lhs.false
  %9 = load %struct.lp_int_ring_t** %K.addr, align 8
  %M = getelementptr inbounds %struct.lp_int_ring_t* %9, i32 0, i32 2
  %10 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K8 = getelementptr inbounds %struct.lp_upolynomial_struct* %10, i32 0, i32 0
  %11 = load %struct.lp_int_ring_t** %K8, align 8
  %M9 = getelementptr inbounds %struct.lp_int_ring_t* %11, i32 0, i32 2
  %call = call i32 @integer_cmp(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %M, %struct.__mpz_struct* %M9)
  %cmp10 = icmp sge i32 %call, 0
  br i1 %cmp10, label %if.then, label %if.end

if.then:                                          ; preds = %land.lhs.true, %cond.end4
  %12 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call11 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy(%struct.lp_upolynomial_struct* %12)
  store %struct.lp_upolynomial_struct* %call11, %struct.lp_upolynomial_struct** %copy, align 8
  %13 = load %struct.lp_upolynomial_struct** %copy, align 8
  %K12 = getelementptr inbounds %struct.lp_upolynomial_struct* %13, i32 0, i32 0
  %14 = load %struct.lp_int_ring_t** %K12, align 8
  call void @lp_int_ring_detach(%struct.lp_int_ring_t* %14)
  %15 = load %struct.lp_int_ring_t** %K.addr, align 8
  %16 = load %struct.lp_upolynomial_struct** %copy, align 8
  %K13 = getelementptr inbounds %struct.lp_upolynomial_struct* %16, i32 0, i32 0
  store %struct.lp_int_ring_t* %15, %struct.lp_int_ring_t** %K13, align 8
  %17 = load %struct.lp_upolynomial_struct** %copy, align 8
  %K14 = getelementptr inbounds %struct.lp_upolynomial_struct* %17, i32 0, i32 0
  %18 = load %struct.lp_int_ring_t** %K14, align 8
  call void @lp_int_ring_attach(%struct.lp_int_ring_t* %18)
  %19 = load %struct.lp_upolynomial_struct** %copy, align 8
  store %struct.lp_upolynomial_struct* %19, %struct.lp_upolynomial_struct** %retval
  br label %return

if.end:                                           ; preds = %land.lhs.true, %lor.lhs.false
  store i64 0, i64* %size, align 8
  store i64 0, i64* %degree, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.end
  %20 = load i32* %i, align 4
  %conv = zext i32 %20 to i64
  %21 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size15 = getelementptr inbounds %struct.lp_upolynomial_struct* %21, i32 0, i32 1
  %22 = load i64* %size15, align 8
  %cmp16 = icmp ult i64 %conv, %22
  br i1 %cmp16, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %23 = load %struct.lp_int_ring_t** %K.addr, align 8
  %24 = load i32* %i, align 4
  %idxprom = zext i32 %24 to i64
  %25 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %25, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %idxprom
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 1
  %call18 = call i32 @integer_sgn(%struct.lp_int_ring_t* %23, %struct.__mpz_struct* %coefficient)
  %tobool19 = icmp ne i32 %call18, 0
  br i1 %tobool19, label %if.then20, label %if.end25

if.then20:                                        ; preds = %for.body
  %26 = load i64* %size, align 8
  %inc = add i64 %26, 1
  store i64 %inc, i64* %size, align 8
  %27 = load i32* %i, align 4
  %idxprom21 = zext i32 %27 to i64
  %28 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials22 = getelementptr inbounds %struct.lp_upolynomial_struct* %28, i32 0, i32 2
  %arrayidx23 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials22, i32 0, i64 %idxprom21
  %degree24 = getelementptr inbounds %struct.umonomial_struct* %arrayidx23, i32 0, i32 0
  %29 = load i64* %degree24, align 8
  store i64 %29, i64* %degree, align 8
  br label %if.end25

if.end25:                                         ; preds = %if.then20, %for.body
  br label %for.inc

for.inc:                                          ; preds = %if.end25
  %30 = load i32* %i, align 4
  %inc26 = add i32 %30, 1
  store i32 %inc26, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %31 = load i64* %degree, align 8
  %cmp27 = icmp eq i64 %31, 0
  br i1 %cmp27, label %if.then29, label %if.end30

if.then29:                                        ; preds = %for.end
  store i64 1, i64* %size, align 8
  br label %if.end30

if.end30:                                         ; preds = %if.then29, %for.end
  %32 = load %struct.lp_int_ring_t** %K.addr, align 8
  %33 = load i64* %size, align 8
  %call31 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_empty(%struct.lp_int_ring_t* %32, i64 %33)
  store %struct.lp_upolynomial_struct* %call31, %struct.lp_upolynomial_struct** %new_p, align 8
  %34 = load i64* %degree, align 8
  %cmp32 = icmp eq i64 %34, 0
  br i1 %cmp32, label %if.then34, label %if.else48

if.then34:                                        ; preds = %if.end30
  %35 = load %struct.lp_int_ring_t** %K.addr, align 8
  %36 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials35 = getelementptr inbounds %struct.lp_upolynomial_struct* %36, i32 0, i32 2
  %arrayidx36 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials35, i32 0, i64 0
  %coefficient37 = getelementptr inbounds %struct.umonomial_struct* %arrayidx36, i32 0, i32 1
  %call38 = call i32 @integer_sgn(%struct.lp_int_ring_t* %35, %struct.__mpz_struct* %coefficient37)
  %tobool39 = icmp ne i32 %call38, 0
  br i1 %tobool39, label %if.then40, label %if.else

if.then40:                                        ; preds = %if.then34
  %37 = load %struct.lp_int_ring_t** %K.addr, align 8
  %38 = load %struct.lp_upolynomial_struct** %new_p, align 8
  %monomials41 = getelementptr inbounds %struct.lp_upolynomial_struct* %38, i32 0, i32 2
  %arrayidx42 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials41, i32 0, i64 0
  %39 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials43 = getelementptr inbounds %struct.lp_upolynomial_struct* %39, i32 0, i32 2
  %arrayidx44 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials43, i32 0, i64 0
  call void @umonomial_construct_copy(%struct.lp_int_ring_t* %37, %struct.umonomial_struct* %arrayidx42, %struct.umonomial_struct* %arrayidx44)
  br label %if.end47

if.else:                                          ; preds = %if.then34
  %40 = load %struct.lp_int_ring_t** %K.addr, align 8
  %41 = load %struct.lp_upolynomial_struct** %new_p, align 8
  %monomials45 = getelementptr inbounds %struct.lp_upolynomial_struct* %41, i32 0, i32 2
  %arrayidx46 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials45, i32 0, i64 0
  call void @umonomial_construct_from_int(%struct.lp_int_ring_t* %40, %struct.umonomial_struct* %arrayidx46, i64 0, i64 0)
  br label %if.end47

if.end47:                                         ; preds = %if.else, %if.then40
  br label %if.end73

if.else48:                                        ; preds = %if.end30
  store i64 0, i64* %size, align 8
  call void @integer_construct_from_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %tmp, i64 0)
  store i32 0, i32* %i, align 4
  br label %for.cond49

for.cond49:                                       ; preds = %for.inc70, %if.else48
  %42 = load i32* %i, align 4
  %conv50 = zext i32 %42 to i64
  %43 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size51 = getelementptr inbounds %struct.lp_upolynomial_struct* %43, i32 0, i32 1
  %44 = load i64* %size51, align 8
  %cmp52 = icmp ult i64 %conv50, %44
  br i1 %cmp52, label %for.body54, label %for.end72

for.body54:                                       ; preds = %for.cond49
  %45 = load %struct.lp_int_ring_t** %K.addr, align 8
  %46 = load i32* %i, align 4
  %idxprom55 = zext i32 %46 to i64
  %47 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials56 = getelementptr inbounds %struct.lp_upolynomial_struct* %47, i32 0, i32 2
  %arrayidx57 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials56, i32 0, i64 %idxprom55
  %coefficient58 = getelementptr inbounds %struct.umonomial_struct* %arrayidx57, i32 0, i32 1
  call void @integer_assign(%struct.lp_int_ring_t* %45, %struct.__mpz_struct* %tmp, %struct.__mpz_struct* %coefficient58)
  %call59 = call i32 @integer_sgn(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %tmp)
  %tobool60 = icmp ne i32 %call59, 0
  br i1 %tobool60, label %if.then61, label %if.end69

if.then61:                                        ; preds = %for.body54
  %48 = load i64* %size, align 8
  %49 = load %struct.lp_upolynomial_struct** %new_p, align 8
  %monomials62 = getelementptr inbounds %struct.lp_upolynomial_struct* %49, i32 0, i32 2
  %arrayidx63 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials62, i32 0, i64 %48
  %50 = load i32* %i, align 4
  %idxprom64 = zext i32 %50 to i64
  %51 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials65 = getelementptr inbounds %struct.lp_upolynomial_struct* %51, i32 0, i32 2
  %arrayidx66 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials65, i32 0, i64 %idxprom64
  %degree67 = getelementptr inbounds %struct.umonomial_struct* %arrayidx66, i32 0, i32 0
  %52 = load i64* %degree67, align 8
  call void @umonomial_construct(%struct.lp_int_ring_t* null, %struct.umonomial_struct* %arrayidx63, i64 %52, %struct.__mpz_struct* %tmp)
  %53 = load i64* %size, align 8
  %inc68 = add i64 %53, 1
  store i64 %inc68, i64* %size, align 8
  br label %if.end69

if.end69:                                         ; preds = %if.then61, %for.body54
  br label %for.inc70

for.inc70:                                        ; preds = %if.end69
  %54 = load i32* %i, align 4
  %inc71 = add i32 %54, 1
  store i32 %inc71, i32* %i, align 4
  br label %for.cond49

for.end72:                                        ; preds = %for.cond49
  call void @integer_destruct(%struct.__mpz_struct* %tmp)
  br label %if.end73

if.end73:                                         ; preds = %for.end72, %if.end47
  %55 = load %struct.lp_upolynomial_struct** %new_p, align 8
  store %struct.lp_upolynomial_struct* %55, %struct.lp_upolynomial_struct** %retval
  br label %return

return:                                           ; preds = %if.end73, %if.then
  %56 = load %struct.lp_upolynomial_struct** %retval
  ret %struct.lp_upolynomial_struct* %56
}

; Function Attrs: inlinehint nounwind uwtable
define internal i32 @integer_cmp(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c, %struct.__mpz_struct* %to) #4 {
entry:
  %retval = alloca i32, align 4
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %c.addr = alloca %struct.__mpz_struct*, align 8
  %to.addr = alloca %struct.__mpz_struct*, align 8
  %c_normalized = alloca %struct.__mpz_struct, align 8
  %to_normalized = alloca %struct.__mpz_struct, align 8
  %cmp = alloca i32, align 4
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  store %struct.__mpz_struct* %to, %struct.__mpz_struct** %to.addr, align 8
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %tobool = icmp ne %struct.lp_int_ring_t* %0, null
  br i1 %tobool, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %1 = load %struct.lp_int_ring_t** %K.addr, align 8
  %2 = load %struct.__mpz_struct** %c.addr, align 8
  call void @integer_construct_copy(%struct.lp_int_ring_t* %1, %struct.__mpz_struct* %c_normalized, %struct.__mpz_struct* %2)
  %3 = load %struct.lp_int_ring_t** %K.addr, align 8
  %4 = load %struct.__mpz_struct** %to.addr, align 8
  call void @integer_construct_copy(%struct.lp_int_ring_t* %3, %struct.__mpz_struct* %to_normalized, %struct.__mpz_struct* %4)
  %call = call i32 @__gmpz_cmp(%struct.__mpz_struct* %c_normalized, %struct.__mpz_struct* %to_normalized) #8
  store i32 %call, i32* %cmp, align 4
  call void @integer_destruct(%struct.__mpz_struct* %c_normalized)
  call void @integer_destruct(%struct.__mpz_struct* %to_normalized)
  %5 = load i32* %cmp, align 4
  store i32 %5, i32* %retval
  br label %return

if.else:                                          ; preds = %entry
  %6 = load %struct.__mpz_struct** %c.addr, align 8
  %7 = load %struct.__mpz_struct** %to.addr, align 8
  %call1 = call i32 @__gmpz_cmp(%struct.__mpz_struct* %6, %struct.__mpz_struct* %7) #8
  store i32 %call1, i32* %retval
  br label %return

return:                                           ; preds = %if.else, %if.then
  %8 = load i32* %retval
  ret i32 %8
}

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_unpack(%struct.lp_upolynomial_struct* %p, %struct.__mpz_struct* %out) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %out.addr = alloca %struct.__mpz_struct*, align 8
  %i = alloca i32, align 4
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.__mpz_struct* %out, %struct.__mpz_struct** %out.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 223, i8* getelementptr inbounds ([69 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_unpack, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
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
  %idxprom = zext i32 %5 to i64
  %6 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %6, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %idxprom
  %degree = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 0
  %7 = load i64* %degree, align 8
  %8 = load %struct.__mpz_struct** %out.addr, align 8
  %arrayidx2 = getelementptr inbounds %struct.__mpz_struct* %8, i64 %7
  %9 = load i32* %i, align 4
  %idxprom3 = zext i32 %9 to i64
  %10 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials4 = getelementptr inbounds %struct.lp_upolynomial_struct* %10, i32 0, i32 2
  %arrayidx5 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials4, i32 0, i64 %idxprom3
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx5, i32 0, i32 1
  call void @integer_assign(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %arrayidx2, %struct.__mpz_struct* %coefficient)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %11 = load i32* %i, align 4
  %inc = add i32 %11, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define %struct.lp_int_ring_t* @lp_upolynomial_ring(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 231, i8* getelementptr inbounds ([61 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_ring, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %2, i32 0, i32 0
  %3 = load %struct.lp_int_ring_t** %K, align 8
  ret %struct.lp_int_ring_t* %3
}

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_set_ring(%struct.lp_upolynomial_struct* %p, %struct.lp_int_ring_t* %K) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 236, i8* getelementptr inbounds ([66 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_set_ring, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K1 = getelementptr inbounds %struct.lp_upolynomial_struct* %2, i32 0, i32 0
  %3 = load %struct.lp_int_ring_t** %K1, align 8
  call void @lp_int_ring_detach(%struct.lp_int_ring_t* %3)
  %4 = load %struct.lp_int_ring_t** %K.addr, align 8
  %5 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K2 = getelementptr inbounds %struct.lp_upolynomial_struct* %5, i32 0, i32 0
  store %struct.lp_int_ring_t* %4, %struct.lp_int_ring_t** %K2, align 8
  %6 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K3 = getelementptr inbounds %struct.lp_upolynomial_struct* %6, i32 0, i32 0
  %7 = load %struct.lp_int_ring_t** %K3, align 8
  call void @lp_int_ring_attach(%struct.lp_int_ring_t* %7)
  ret void
}

; Function Attrs: nounwind uwtable
define %struct.__mpz_struct* @lp_upolynomial_lead_coeff(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 243, i8* getelementptr inbounds ([72 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_lead_coeff, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %2, i32 0, i32 1
  %3 = load i64* %size, align 8
  %cmp = icmp ugt i64 %3, 0
  br i1 %cmp, label %cond.true1, label %cond.false2

cond.true1:                                       ; preds = %cond.end
  br label %cond.end3

cond.false2:                                      ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([12 x i8]* @.str2, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 244, i8* getelementptr inbounds ([72 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_lead_coeff, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end3

cond.end3:                                        ; preds = %4, %cond.true1
  %5 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size4 = getelementptr inbounds %struct.lp_upolynomial_struct* %5, i32 0, i32 1
  %6 = load i64* %size4, align 8
  %sub = sub i64 %6, 1
  %7 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %7, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %sub
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 1
  ret %struct.__mpz_struct* %coefficient
}

; Function Attrs: nounwind uwtable
define %struct.__mpz_struct* @lp_upolynomial_const_term(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %retval = alloca %struct.__mpz_struct*, align 8
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 249, i8* getelementptr inbounds ([72 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_const_term, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %2, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 0
  %degree = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 0
  %3 = load i64* %degree, align 8
  %cmp = icmp eq i64 %3, 0
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %cond.end
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials1 = getelementptr inbounds %struct.lp_upolynomial_struct* %4, i32 0, i32 2
  %arrayidx2 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials1, i32 0, i64 0
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx2, i32 0, i32 1
  store %struct.__mpz_struct* %coefficient, %struct.__mpz_struct** %retval
  br label %return

if.else:                                          ; preds = %cond.end
  store %struct.__mpz_struct* null, %struct.__mpz_struct** %retval
  br label %return

return:                                           ; preds = %if.else, %if.then
  %5 = load %struct.__mpz_struct** %retval
  ret %struct.__mpz_struct* %5
}

; Function Attrs: nounwind uwtable
define i32 @lp_upolynomial_cmp(%struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q) #0 {
entry:
  %retval = alloca i32, align 4
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %p_deg = alloca i32, align 4
  %q_deg = alloca i32, align 4
  %p_i = alloca i32, align 4
  %q_i = alloca i32, align 4
  %cmp9 = alloca i32, align 4
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 258, i8* getelementptr inbounds ([75 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_cmp, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %tobool1 = icmp ne %struct.lp_upolynomial_struct* %2, null
  br i1 %tobool1, label %cond.true2, label %cond.false3

cond.true2:                                       ; preds = %cond.end
  br label %cond.end4

cond.false3:                                      ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str4, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 259, i8* getelementptr inbounds ([75 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_cmp, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end4

cond.end4:                                        ; preds = %3, %cond.true2
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %4, i32 0, i32 0
  %5 = load %struct.lp_int_ring_t** %K, align 8
  %6 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %K5 = getelementptr inbounds %struct.lp_upolynomial_struct* %6, i32 0, i32 0
  %7 = load %struct.lp_int_ring_t** %K5, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %5, %7
  br i1 %cmp, label %cond.true6, label %cond.false7

cond.true6:                                       ; preds = %cond.end4
  br label %cond.end8

cond.false7:                                      ; preds = %cond.end4
  call void @__assert_fail(i8* getelementptr inbounds ([13 x i8]* @.str5, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 260, i8* getelementptr inbounds ([75 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_cmp, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end8

cond.end8:                                        ; preds = %8, %cond.true6
  %9 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %9, i32 0, i32 1
  %10 = load i64* %size, align 8
  %conv = trunc i64 %10 to i32
  store i32 %conv, i32* %p_i, align 4
  %11 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %size10 = getelementptr inbounds %struct.lp_upolynomial_struct* %11, i32 0, i32 1
  %12 = load i64* %size10, align 8
  %conv11 = trunc i64 %12 to i32
  store i32 %conv11, i32* %q_i, align 4
  br label %do.body

do.body:                                          ; preds = %lor.end, %cond.end8
  %13 = load i32* %p_i, align 4
  %dec = add nsw i32 %13, -1
  store i32 %dec, i32* %p_i, align 4
  %14 = load i32* %q_i, align 4
  %dec12 = add nsw i32 %14, -1
  store i32 %dec12, i32* %q_i, align 4
  %15 = load i32* %p_i, align 4
  %idxprom = sext i32 %15 to i64
  %16 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %16, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %idxprom
  %degree = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 0
  %17 = load i64* %degree, align 8
  %conv13 = trunc i64 %17 to i32
  store i32 %conv13, i32* %p_deg, align 4
  %18 = load i32* %q_i, align 4
  %idxprom14 = sext i32 %18 to i64
  %19 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %monomials15 = getelementptr inbounds %struct.lp_upolynomial_struct* %19, i32 0, i32 2
  %arrayidx16 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials15, i32 0, i64 %idxprom14
  %degree17 = getelementptr inbounds %struct.umonomial_struct* %arrayidx16, i32 0, i32 0
  %20 = load i64* %degree17, align 8
  %conv18 = trunc i64 %20 to i32
  store i32 %conv18, i32* %q_deg, align 4
  %21 = load i32* %p_deg, align 4
  %22 = load i32* %q_deg, align 4
  %cmp19 = icmp sgt i32 %21, %22
  br i1 %cmp19, label %if.then, label %if.end

if.then:                                          ; preds = %do.body
  store i32 1, i32* %retval
  br label %return

if.end:                                           ; preds = %do.body
  %23 = load i32* %q_deg, align 4
  %24 = load i32* %p_deg, align 4
  %cmp21 = icmp sgt i32 %23, %24
  br i1 %cmp21, label %if.then23, label %if.end24

if.then23:                                        ; preds = %if.end
  store i32 -1, i32* %retval
  br label %return

if.end24:                                         ; preds = %if.end
  %25 = load i32* %p_i, align 4
  %idxprom25 = sext i32 %25 to i64
  %26 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials26 = getelementptr inbounds %struct.lp_upolynomial_struct* %26, i32 0, i32 2
  %arrayidx27 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials26, i32 0, i64 %idxprom25
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx27, i32 0, i32 1
  %27 = load i32* %q_i, align 4
  %idxprom28 = sext i32 %27 to i64
  %28 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %monomials29 = getelementptr inbounds %struct.lp_upolynomial_struct* %28, i32 0, i32 2
  %arrayidx30 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials29, i32 0, i64 %idxprom28
  %coefficient31 = getelementptr inbounds %struct.umonomial_struct* %arrayidx30, i32 0, i32 1
  %call = call i32 @integer_cmp(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %coefficient, %struct.__mpz_struct* %coefficient31)
  store i32 %call, i32* %cmp9, align 4
  %29 = load i32* %cmp9, align 4
  %tobool32 = icmp ne i32 %29, 0
  br i1 %tobool32, label %if.then33, label %if.end34

if.then33:                                        ; preds = %if.end24
  %30 = load i32* %cmp9, align 4
  store i32 %30, i32* %retval
  br label %return

if.end34:                                         ; preds = %if.end24
  br label %do.cond

do.cond:                                          ; preds = %if.end34
  %31 = load i32* %p_i, align 4
  %cmp35 = icmp sgt i32 %31, 0
  br i1 %cmp35, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %do.cond
  %32 = load i32* %q_i, align 4
  %cmp37 = icmp sgt i32 %32, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %do.cond
  %33 = phi i1 [ true, %do.cond ], [ %cmp37, %lor.rhs ]
  br i1 %33, label %do.body, label %do.end

do.end:                                           ; preds = %lor.end
  %34 = load i32* %p_i, align 4
  %35 = load i32* %q_i, align 4
  %cmp39 = icmp eq i32 %34, %35
  br i1 %cmp39, label %if.then41, label %if.else

if.then41:                                        ; preds = %do.end
  store i32 0, i32* %retval
  br label %return

if.else:                                          ; preds = %do.end
  %36 = load i32* %p_i, align 4
  %37 = load i32* %q_i, align 4
  %cmp42 = icmp sgt i32 %36, %37
  br i1 %cmp42, label %if.then44, label %if.else45

if.then44:                                        ; preds = %if.else
  store i32 1, i32* %retval
  br label %return

if.else45:                                        ; preds = %if.else
  store i32 -1, i32* %retval
  br label %return

return:                                           ; preds = %if.else45, %if.then44, %if.then41, %if.then33, %if.then23, %if.then
  %38 = load i32* %retval
  ret i32 %38
}

; Function Attrs: nounwind uwtable
define i32 @lp_upolynomial_is_zero(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %retval = alloca i32, align 4
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %0, i32 0, i32 1
  %1 = load i64* %size, align 8
  %cmp = icmp ugt i64 %1, 1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 0, i32* %retval
  br label %return

if.end:                                           ; preds = %entry
  %2 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %2, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 0
  %degree = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 0
  %3 = load i64* %degree, align 8
  %cmp1 = icmp ugt i64 %3, 0
  br i1 %cmp1, label %if.then2, label %if.end3

if.then2:                                         ; preds = %if.end
  store i32 0, i32* %retval
  br label %return

if.end3:                                          ; preds = %if.end
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials4 = getelementptr inbounds %struct.lp_upolynomial_struct* %4, i32 0, i32 2
  %arrayidx5 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials4, i32 0, i64 0
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx5, i32 0, i32 1
  %call = call i32 @integer_sgn(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %coefficient)
  %cmp6 = icmp eq i32 %call, 0
  %conv = zext i1 %cmp6 to i32
  store i32 %conv, i32* %retval
  br label %return

return:                                           ; preds = %if.end3, %if.then2, %if.then
  %5 = load i32* %retval
  ret i32 %5
}

; Function Attrs: nounwind uwtable
define i32 @lp_upolynomial_is_one(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %retval = alloca i32, align 4
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %0, i32 0, i32 1
  %1 = load i64* %size, align 8
  %cmp = icmp ugt i64 %1, 1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 0, i32* %retval
  br label %return

if.end:                                           ; preds = %entry
  %2 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %2, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 0
  %degree = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 0
  %3 = load i64* %degree, align 8
  %cmp1 = icmp ugt i64 %3, 0
  br i1 %cmp1, label %if.then2, label %if.end3

if.then2:                                         ; preds = %if.end
  store i32 0, i32* %retval
  br label %return

if.end3:                                          ; preds = %if.end
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials4 = getelementptr inbounds %struct.lp_upolynomial_struct* %4, i32 0, i32 2
  %arrayidx5 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials4, i32 0, i64 0
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx5, i32 0, i32 1
  %call = call i32 @integer_cmp_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %coefficient, i64 1)
  %cmp6 = icmp eq i32 %call, 0
  %conv = zext i1 %cmp6 to i32
  store i32 %conv, i32* %retval
  br label %return

return:                                           ; preds = %if.end3, %if.then2, %if.then
  %5 = load i32* %retval
  ret i32 %5
}

; Function Attrs: inlinehint nounwind uwtable
define internal i32 @integer_cmp_int(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c, i64 %to) #4 {
entry:
  %retval = alloca i32, align 4
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %c.addr = alloca %struct.__mpz_struct*, align 8
  %to.addr = alloca i64, align 8
  %c_normalized = alloca %struct.__mpz_struct, align 8
  %to_normalized = alloca %struct.__mpz_struct, align 8
  %cmp = alloca i32, align 4
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  store i64 %to, i64* %to.addr, align 8
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %tobool = icmp ne %struct.lp_int_ring_t* %0, null
  br i1 %tobool, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %1 = load %struct.lp_int_ring_t** %K.addr, align 8
  %2 = load %struct.__mpz_struct** %c.addr, align 8
  call void @integer_construct_copy(%struct.lp_int_ring_t* %1, %struct.__mpz_struct* %c_normalized, %struct.__mpz_struct* %2)
  %3 = load %struct.lp_int_ring_t** %K.addr, align 8
  %4 = load i64* %to.addr, align 8
  call void @integer_construct_from_int(%struct.lp_int_ring_t* %3, %struct.__mpz_struct* %to_normalized, i64 %4)
  %call = call i32 @__gmpz_cmp(%struct.__mpz_struct* %c_normalized, %struct.__mpz_struct* %to_normalized) #8
  store i32 %call, i32* %cmp, align 4
  call void @integer_destruct(%struct.__mpz_struct* %c_normalized)
  call void @integer_destruct(%struct.__mpz_struct* %to_normalized)
  %5 = load i32* %cmp, align 4
  store i32 %5, i32* %retval
  br label %return

if.else:                                          ; preds = %entry
  %6 = load %struct.__mpz_struct** %c.addr, align 8
  %7 = load i64* %to.addr, align 8
  %call1 = call i32 @__gmpz_cmp_si(%struct.__mpz_struct* %6, i64 %7) #8
  store i32 %call1, i32* %retval
  br label %return

return:                                           ; preds = %if.else, %if.then
  %8 = load i32* %retval
  ret i32 %8
}

; Function Attrs: nounwind uwtable
define i32 @lp_upolynomial_is_monic(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call = call %struct.__mpz_struct* @lp_upolynomial_lead_coeff(%struct.lp_upolynomial_struct* %0)
  %call1 = call i32 @integer_cmp_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %call, i64 1)
  %cmp = icmp eq i32 %call1, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_add(%struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %K39 = alloca %struct.lp_int_ring_t*, align 8
  %degree = alloca i64, align 8
  %tmp = alloca %struct.upolynomial_dense_t, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 312, i8* getelementptr inbounds ([89 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_add, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %tobool1 = icmp ne %struct.lp_upolynomial_struct* %2, null
  br i1 %tobool1, label %cond.true2, label %cond.false3

cond.true2:                                       ; preds = %cond.end
  br label %cond.end4

cond.false3:                                      ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str4, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 313, i8* getelementptr inbounds ([89 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_add, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end4

cond.end4:                                        ; preds = %3, %cond.true2
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %4, i32 0, i32 0
  %5 = load %struct.lp_int_ring_t** %K, align 8
  %6 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %K5 = getelementptr inbounds %struct.lp_upolynomial_struct* %6, i32 0, i32 0
  %7 = load %struct.lp_int_ring_t** %K5, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %5, %7
  br i1 %cmp, label %cond.true6, label %cond.false7

cond.true6:                                       ; preds = %cond.end4
  br label %cond.end8

cond.false7:                                      ; preds = %cond.end4
  call void @__assert_fail(i8* getelementptr inbounds ([13 x i8]* @.str5, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 314, i8* getelementptr inbounds ([89 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_add, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end8

cond.end8:                                        ; preds = %8, %cond.true6
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool9 = icmp ne i32 %call, 0
  br i1 %tobool9, label %if.then, label %if.end

if.then:                                          ; preds = %cond.end8
  %9 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool10 = icmp ne %struct._IO_FILE* %9, null
  br i1 %tobool10, label %cond.true11, label %cond.false12

cond.true11:                                      ; preds = %if.then
  %10 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end13

cond.false12:                                     ; preds = %if.then
  %11 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end13

cond.end13:                                       ; preds = %cond.false12, %cond.true11
  %cond = phi %struct._IO_FILE* [ %10, %cond.true11 ], [ %11, %cond.false12 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([17 x i8]* @.str7, i32 0, i32 0))
  %12 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %13 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool15 = icmp ne %struct._IO_FILE* %13, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %cond.end13
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end18

cond.false17:                                     ; preds = %cond.end13
  %15 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false17, %cond.true16
  %cond19 = phi %struct._IO_FILE* [ %14, %cond.true16 ], [ %15, %cond.false17 ]
  %call20 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %12, %struct._IO_FILE* %cond19)
  %16 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool21 = icmp ne %struct._IO_FILE* %16, null
  br i1 %tobool21, label %cond.true22, label %cond.false23

cond.true22:                                      ; preds = %cond.end18
  %17 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end24

cond.false23:                                     ; preds = %cond.end18
  %18 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end24

cond.end24:                                       ; preds = %cond.false23, %cond.true22
  %cond25 = phi %struct._IO_FILE* [ %17, %cond.true22 ], [ %18, %cond.false23 ]
  %call26 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond25, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %19 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %20 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool27 = icmp ne %struct._IO_FILE* %20, null
  br i1 %tobool27, label %cond.true28, label %cond.false29

cond.true28:                                      ; preds = %cond.end24
  %21 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end30

cond.false29:                                     ; preds = %cond.end24
  %22 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end30

cond.end30:                                       ; preds = %cond.false29, %cond.true28
  %cond31 = phi %struct._IO_FILE* [ %21, %cond.true28 ], [ %22, %cond.false29 ]
  %call32 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %19, %struct._IO_FILE* %cond31)
  %23 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool33 = icmp ne %struct._IO_FILE* %23, null
  br i1 %tobool33, label %cond.true34, label %cond.false35

cond.true34:                                      ; preds = %cond.end30
  %24 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end36

cond.false35:                                     ; preds = %cond.end30
  %25 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end36

cond.end36:                                       ; preds = %cond.false35, %cond.true34
  %cond37 = phi %struct._IO_FILE* [ %24, %cond.true34 ], [ %25, %cond.false35 ]
  %call38 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond37, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end36, %cond.end8
  %26 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K40 = getelementptr inbounds %struct.lp_upolynomial_struct* %26, i32 0, i32 0
  %27 = load %struct.lp_int_ring_t** %K40, align 8
  store %struct.lp_int_ring_t* %27, %struct.lp_int_ring_t** %K39, align 8
  %28 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call41 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %28)
  store i64 %call41, i64* %degree, align 8
  %29 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call42 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %29)
  %30 = load i64* %degree, align 8
  %cmp43 = icmp ugt i64 %call42, %30
  br i1 %cmp43, label %if.then44, label %if.end46

if.then44:                                        ; preds = %if.end
  %31 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call45 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %31)
  store i64 %call45, i64* %degree, align 8
  br label %if.end46

if.end46:                                         ; preds = %if.then44, %if.end
  %32 = load i64* %degree, align 8
  %add = add i64 %32, 1
  call void @upolynomial_dense_construct(%struct.upolynomial_dense_t* %tmp, i64 %add)
  %33 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  call void @upolynomial_dense_add_mult_p_int(%struct.upolynomial_dense_t* %tmp, %struct.lp_upolynomial_struct* %33, i32 1)
  %34 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  call void @upolynomial_dense_add_mult_p_int(%struct.upolynomial_dense_t* %tmp, %struct.lp_upolynomial_struct* %34, i32 1)
  %35 = load %struct.lp_int_ring_t** %K39, align 8
  %call48 = call %struct.lp_upolynomial_struct* @upolynomial_dense_to_upolynomial(%struct.upolynomial_dense_t* %tmp, %struct.lp_int_ring_t* %35)
  store %struct.lp_upolynomial_struct* %call48, %struct.lp_upolynomial_struct** %result, align 8
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %tmp)
  %call49 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool50 = icmp ne i32 %call49, 0
  br i1 %tobool50, label %if.then51, label %if.end94

if.then51:                                        ; preds = %if.end46
  %36 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool52 = icmp ne %struct._IO_FILE* %36, null
  br i1 %tobool52, label %cond.true53, label %cond.false54

cond.true53:                                      ; preds = %if.then51
  %37 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end55

cond.false54:                                     ; preds = %if.then51
  %38 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end55

cond.end55:                                       ; preds = %cond.false54, %cond.true53
  %cond56 = phi %struct._IO_FILE* [ %37, %cond.true53 ], [ %38, %cond.false54 ]
  %call57 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond56, i8* getelementptr inbounds ([17 x i8]* @.str7, i32 0, i32 0))
  %39 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %40 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool58 = icmp ne %struct._IO_FILE* %40, null
  br i1 %tobool58, label %cond.true59, label %cond.false60

cond.true59:                                      ; preds = %cond.end55
  %41 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end61

cond.false60:                                     ; preds = %cond.end55
  %42 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end61

cond.end61:                                       ; preds = %cond.false60, %cond.true59
  %cond62 = phi %struct._IO_FILE* [ %41, %cond.true59 ], [ %42, %cond.false60 ]
  %call63 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %39, %struct._IO_FILE* %cond62)
  %43 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool64 = icmp ne %struct._IO_FILE* %43, null
  br i1 %tobool64, label %cond.true65, label %cond.false66

cond.true65:                                      ; preds = %cond.end61
  %44 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end67

cond.false66:                                     ; preds = %cond.end61
  %45 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end67

cond.end67:                                       ; preds = %cond.false66, %cond.true65
  %cond68 = phi %struct._IO_FILE* [ %44, %cond.true65 ], [ %45, %cond.false66 ]
  %call69 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond68, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %46 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %47 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool70 = icmp ne %struct._IO_FILE* %47, null
  br i1 %tobool70, label %cond.true71, label %cond.false72

cond.true71:                                      ; preds = %cond.end67
  %48 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end73

cond.false72:                                     ; preds = %cond.end67
  %49 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end73

cond.end73:                                       ; preds = %cond.false72, %cond.true71
  %cond74 = phi %struct._IO_FILE* [ %48, %cond.true71 ], [ %49, %cond.false72 ]
  %call75 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %46, %struct._IO_FILE* %cond74)
  %50 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool76 = icmp ne %struct._IO_FILE* %50, null
  br i1 %tobool76, label %cond.true77, label %cond.false78

cond.true77:                                      ; preds = %cond.end73
  %51 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end79

cond.false78:                                     ; preds = %cond.end73
  %52 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end79

cond.end79:                                       ; preds = %cond.false78, %cond.true77
  %cond80 = phi %struct._IO_FILE* [ %51, %cond.true77 ], [ %52, %cond.false78 ]
  %call81 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond80, i8* getelementptr inbounds ([5 x i8]* @.str10, i32 0, i32 0))
  %53 = load %struct.lp_upolynomial_struct** %result, align 8
  %54 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool82 = icmp ne %struct._IO_FILE* %54, null
  br i1 %tobool82, label %cond.true83, label %cond.false84

cond.true83:                                      ; preds = %cond.end79
  %55 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end85

cond.false84:                                     ; preds = %cond.end79
  %56 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end85

cond.end85:                                       ; preds = %cond.false84, %cond.true83
  %cond86 = phi %struct._IO_FILE* [ %55, %cond.true83 ], [ %56, %cond.false84 ]
  %call87 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %53, %struct._IO_FILE* %cond86)
  %57 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool88 = icmp ne %struct._IO_FILE* %57, null
  br i1 %tobool88, label %cond.true89, label %cond.false90

cond.true89:                                      ; preds = %cond.end85
  %58 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end91

cond.false90:                                     ; preds = %cond.end85
  %59 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end91

cond.end91:                                       ; preds = %cond.false90, %cond.true89
  %cond92 = phi %struct._IO_FILE* [ %58, %cond.true89 ], [ %59, %cond.false90 ]
  %call93 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond92, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end94

if.end94:                                         ; preds = %cond.end91, %if.end46
  %60 = load %struct.lp_upolynomial_struct** %result, align 8
  ret %struct.lp_upolynomial_struct* %60
}

declare i32 @trace_is_enabled(i8*) #3

declare i32 @fprintf(%struct._IO_FILE*, i8*, ...) #3

declare i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct*, %struct._IO_FILE*) #3

declare void @upolynomial_dense_construct(%struct.upolynomial_dense_t*, i64) #3

declare void @upolynomial_dense_add_mult_p_int(%struct.upolynomial_dense_t*, %struct.lp_upolynomial_struct*, i32) #3

declare %struct.lp_upolynomial_struct* @upolynomial_dense_to_upolynomial(%struct.upolynomial_dense_t*, %struct.lp_int_ring_t*) #3

declare void @upolynomial_dense_destruct(%struct.upolynomial_dense_t*) #3

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_sub(%struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %K39 = alloca %struct.lp_int_ring_t*, align 8
  %degree = alloca i64, align 8
  %tmp = alloca %struct.upolynomial_dense_t, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 349, i8* getelementptr inbounds ([89 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_sub, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %tobool1 = icmp ne %struct.lp_upolynomial_struct* %2, null
  br i1 %tobool1, label %cond.true2, label %cond.false3

cond.true2:                                       ; preds = %cond.end
  br label %cond.end4

cond.false3:                                      ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str4, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 350, i8* getelementptr inbounds ([89 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_sub, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end4

cond.end4:                                        ; preds = %3, %cond.true2
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %4, i32 0, i32 0
  %5 = load %struct.lp_int_ring_t** %K, align 8
  %6 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %K5 = getelementptr inbounds %struct.lp_upolynomial_struct* %6, i32 0, i32 0
  %7 = load %struct.lp_int_ring_t** %K5, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %5, %7
  br i1 %cmp, label %cond.true6, label %cond.false7

cond.true6:                                       ; preds = %cond.end4
  br label %cond.end8

cond.false7:                                      ; preds = %cond.end4
  call void @__assert_fail(i8* getelementptr inbounds ([13 x i8]* @.str5, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 351, i8* getelementptr inbounds ([89 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_sub, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end8

cond.end8:                                        ; preds = %8, %cond.true6
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool9 = icmp ne i32 %call, 0
  br i1 %tobool9, label %if.then, label %if.end

if.then:                                          ; preds = %cond.end8
  %9 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool10 = icmp ne %struct._IO_FILE* %9, null
  br i1 %tobool10, label %cond.true11, label %cond.false12

cond.true11:                                      ; preds = %if.then
  %10 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end13

cond.false12:                                     ; preds = %if.then
  %11 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end13

cond.end13:                                       ; preds = %cond.false12, %cond.true11
  %cond = phi %struct._IO_FILE* [ %10, %cond.true11 ], [ %11, %cond.false12 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([17 x i8]* @.str12, i32 0, i32 0))
  %12 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %13 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool15 = icmp ne %struct._IO_FILE* %13, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %cond.end13
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end18

cond.false17:                                     ; preds = %cond.end13
  %15 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false17, %cond.true16
  %cond19 = phi %struct._IO_FILE* [ %14, %cond.true16 ], [ %15, %cond.false17 ]
  %call20 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %12, %struct._IO_FILE* %cond19)
  %16 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool21 = icmp ne %struct._IO_FILE* %16, null
  br i1 %tobool21, label %cond.true22, label %cond.false23

cond.true22:                                      ; preds = %cond.end18
  %17 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end24

cond.false23:                                     ; preds = %cond.end18
  %18 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end24

cond.end24:                                       ; preds = %cond.false23, %cond.true22
  %cond25 = phi %struct._IO_FILE* [ %17, %cond.true22 ], [ %18, %cond.false23 ]
  %call26 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond25, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %19 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %20 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool27 = icmp ne %struct._IO_FILE* %20, null
  br i1 %tobool27, label %cond.true28, label %cond.false29

cond.true28:                                      ; preds = %cond.end24
  %21 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end30

cond.false29:                                     ; preds = %cond.end24
  %22 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end30

cond.end30:                                       ; preds = %cond.false29, %cond.true28
  %cond31 = phi %struct._IO_FILE* [ %21, %cond.true28 ], [ %22, %cond.false29 ]
  %call32 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %19, %struct._IO_FILE* %cond31)
  %23 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool33 = icmp ne %struct._IO_FILE* %23, null
  br i1 %tobool33, label %cond.true34, label %cond.false35

cond.true34:                                      ; preds = %cond.end30
  %24 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end36

cond.false35:                                     ; preds = %cond.end30
  %25 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end36

cond.end36:                                       ; preds = %cond.false35, %cond.true34
  %cond37 = phi %struct._IO_FILE* [ %24, %cond.true34 ], [ %25, %cond.false35 ]
  %call38 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond37, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end36, %cond.end8
  %26 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K40 = getelementptr inbounds %struct.lp_upolynomial_struct* %26, i32 0, i32 0
  %27 = load %struct.lp_int_ring_t** %K40, align 8
  store %struct.lp_int_ring_t* %27, %struct.lp_int_ring_t** %K39, align 8
  %28 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call41 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %28)
  store i64 %call41, i64* %degree, align 8
  %29 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call42 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %29)
  %30 = load i64* %degree, align 8
  %cmp43 = icmp ugt i64 %call42, %30
  br i1 %cmp43, label %if.then44, label %if.end46

if.then44:                                        ; preds = %if.end
  %31 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call45 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %31)
  store i64 %call45, i64* %degree, align 8
  br label %if.end46

if.end46:                                         ; preds = %if.then44, %if.end
  %32 = load i64* %degree, align 8
  %add = add i64 %32, 1
  call void @upolynomial_dense_construct(%struct.upolynomial_dense_t* %tmp, i64 %add)
  %33 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  call void @upolynomial_dense_add_mult_p_int(%struct.upolynomial_dense_t* %tmp, %struct.lp_upolynomial_struct* %33, i32 1)
  %34 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  call void @upolynomial_dense_add_mult_p_int(%struct.upolynomial_dense_t* %tmp, %struct.lp_upolynomial_struct* %34, i32 -1)
  %35 = load %struct.lp_int_ring_t** %K39, align 8
  %call48 = call %struct.lp_upolynomial_struct* @upolynomial_dense_to_upolynomial(%struct.upolynomial_dense_t* %tmp, %struct.lp_int_ring_t* %35)
  store %struct.lp_upolynomial_struct* %call48, %struct.lp_upolynomial_struct** %result, align 8
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %tmp)
  %call49 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool50 = icmp ne i32 %call49, 0
  br i1 %tobool50, label %if.then51, label %if.end94

if.then51:                                        ; preds = %if.end46
  %36 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool52 = icmp ne %struct._IO_FILE* %36, null
  br i1 %tobool52, label %cond.true53, label %cond.false54

cond.true53:                                      ; preds = %if.then51
  %37 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end55

cond.false54:                                     ; preds = %if.then51
  %38 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end55

cond.end55:                                       ; preds = %cond.false54, %cond.true53
  %cond56 = phi %struct._IO_FILE* [ %37, %cond.true53 ], [ %38, %cond.false54 ]
  %call57 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond56, i8* getelementptr inbounds ([17 x i8]* @.str12, i32 0, i32 0))
  %39 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %40 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool58 = icmp ne %struct._IO_FILE* %40, null
  br i1 %tobool58, label %cond.true59, label %cond.false60

cond.true59:                                      ; preds = %cond.end55
  %41 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end61

cond.false60:                                     ; preds = %cond.end55
  %42 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end61

cond.end61:                                       ; preds = %cond.false60, %cond.true59
  %cond62 = phi %struct._IO_FILE* [ %41, %cond.true59 ], [ %42, %cond.false60 ]
  %call63 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %39, %struct._IO_FILE* %cond62)
  %43 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool64 = icmp ne %struct._IO_FILE* %43, null
  br i1 %tobool64, label %cond.true65, label %cond.false66

cond.true65:                                      ; preds = %cond.end61
  %44 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end67

cond.false66:                                     ; preds = %cond.end61
  %45 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end67

cond.end67:                                       ; preds = %cond.false66, %cond.true65
  %cond68 = phi %struct._IO_FILE* [ %44, %cond.true65 ], [ %45, %cond.false66 ]
  %call69 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond68, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %46 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %47 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool70 = icmp ne %struct._IO_FILE* %47, null
  br i1 %tobool70, label %cond.true71, label %cond.false72

cond.true71:                                      ; preds = %cond.end67
  %48 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end73

cond.false72:                                     ; preds = %cond.end67
  %49 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end73

cond.end73:                                       ; preds = %cond.false72, %cond.true71
  %cond74 = phi %struct._IO_FILE* [ %48, %cond.true71 ], [ %49, %cond.false72 ]
  %call75 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %46, %struct._IO_FILE* %cond74)
  %50 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool76 = icmp ne %struct._IO_FILE* %50, null
  br i1 %tobool76, label %cond.true77, label %cond.false78

cond.true77:                                      ; preds = %cond.end73
  %51 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end79

cond.false78:                                     ; preds = %cond.end73
  %52 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end79

cond.end79:                                       ; preds = %cond.false78, %cond.true77
  %cond80 = phi %struct._IO_FILE* [ %51, %cond.true77 ], [ %52, %cond.false78 ]
  %call81 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond80, i8* getelementptr inbounds ([5 x i8]* @.str10, i32 0, i32 0))
  %53 = load %struct.lp_upolynomial_struct** %result, align 8
  %54 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool82 = icmp ne %struct._IO_FILE* %54, null
  br i1 %tobool82, label %cond.true83, label %cond.false84

cond.true83:                                      ; preds = %cond.end79
  %55 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end85

cond.false84:                                     ; preds = %cond.end79
  %56 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end85

cond.end85:                                       ; preds = %cond.false84, %cond.true83
  %cond86 = phi %struct._IO_FILE* [ %55, %cond.true83 ], [ %56, %cond.false84 ]
  %call87 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %53, %struct._IO_FILE* %cond86)
  %57 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool88 = icmp ne %struct._IO_FILE* %57, null
  br i1 %tobool88, label %cond.true89, label %cond.false90

cond.true89:                                      ; preds = %cond.end85
  %58 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end91

cond.false90:                                     ; preds = %cond.end85
  %59 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end91

cond.end91:                                       ; preds = %cond.false90, %cond.true89
  %cond92 = phi %struct._IO_FILE* [ %58, %cond.true89 ], [ %59, %cond.false90 ]
  %call93 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond92, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end94

if.end94:                                         ; preds = %cond.end91, %if.end46
  %60 = load %struct.lp_upolynomial_struct** %result, align 8
  ret %struct.lp_upolynomial_struct* %60
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_multiply_simple(%struct.umonomial_struct* %m, %struct.lp_upolynomial_struct* %q) #0 {
entry:
  %m.addr = alloca %struct.umonomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  %i = alloca i64, align 8
  store %struct.umonomial_struct* %m, %struct.umonomial_struct** %m.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  %0 = load %struct.umonomial_struct** %m.addr, align 8
  %tobool = icmp ne %struct.umonomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str13, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 386, i8* getelementptr inbounds ([99 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_multiply_simple, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %tobool1 = icmp ne %struct.lp_upolynomial_struct* %2, null
  br i1 %tobool1, label %cond.true2, label %cond.false3

cond.true2:                                       ; preds = %cond.end
  br label %cond.end4

cond.false3:                                      ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str4, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 387, i8* getelementptr inbounds ([99 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_multiply_simple, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end4

cond.end4:                                        ; preds = %3, %cond.true2
  %4 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy(%struct.lp_upolynomial_struct* %4)
  store %struct.lp_upolynomial_struct* %call, %struct.lp_upolynomial_struct** %result, align 8
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %cond.end4
  %5 = load i64* %i, align 8
  %6 = load %struct.lp_upolynomial_struct** %result, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %6, i32 0, i32 1
  %7 = load i64* %size, align 8
  %cmp = icmp ult i64 %5, %7
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %8 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %8, i32 0, i32 0
  %9 = load %struct.lp_int_ring_t** %K, align 8
  %10 = load i64* %i, align 8
  %11 = load %struct.lp_upolynomial_struct** %result, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %11, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %10
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 1
  %12 = load %struct.umonomial_struct** %m.addr, align 8
  %coefficient5 = getelementptr inbounds %struct.umonomial_struct* %12, i32 0, i32 1
  %13 = load i64* %i, align 8
  %14 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %monomials6 = getelementptr inbounds %struct.lp_upolynomial_struct* %14, i32 0, i32 2
  %arrayidx7 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials6, i32 0, i64 %13
  %coefficient8 = getelementptr inbounds %struct.umonomial_struct* %arrayidx7, i32 0, i32 1
  call void @integer_mul(%struct.lp_int_ring_t* %9, %struct.__mpz_struct* %coefficient, %struct.__mpz_struct* %coefficient5, %struct.__mpz_struct* %coefficient8)
  %15 = load %struct.umonomial_struct** %m.addr, align 8
  %degree = getelementptr inbounds %struct.umonomial_struct* %15, i32 0, i32 0
  %16 = load i64* %degree, align 8
  %17 = load i64* %i, align 8
  %18 = load %struct.lp_upolynomial_struct** %result, align 8
  %monomials9 = getelementptr inbounds %struct.lp_upolynomial_struct* %18, i32 0, i32 2
  %arrayidx10 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials9, i32 0, i64 %17
  %degree11 = getelementptr inbounds %struct.umonomial_struct* %arrayidx10, i32 0, i32 0
  %19 = load i64* %degree11, align 8
  %add = add i64 %19, %16
  store i64 %add, i64* %degree11, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %20 = load i64* %i, align 8
  %inc = add i64 %20, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %21 = load %struct.lp_upolynomial_struct** %result, align 8
  ret %struct.lp_upolynomial_struct* %21
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_mul(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %product, %struct.__mpz_struct* %a, %struct.__mpz_struct* %b) #4 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %product.addr = alloca %struct.__mpz_struct*, align 8
  %a.addr = alloca %struct.__mpz_struct*, align 8
  %b.addr = alloca %struct.__mpz_struct*, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %product, %struct.__mpz_struct** %product.addr, align 8
  store %struct.__mpz_struct* %a, %struct.__mpz_struct** %a.addr, align 8
  store %struct.__mpz_struct* %b, %struct.__mpz_struct** %b.addr, align 8
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %1 = load %struct.__mpz_struct** %a.addr, align 8
  %call = call i32 @integer_in_ring(%struct.lp_int_ring_t* %0, %struct.__mpz_struct* %1)
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %land.lhs.true, label %cond.false

land.lhs.true:                                    ; preds = %entry
  %2 = load %struct.lp_int_ring_t** %K.addr, align 8
  %3 = load %struct.__mpz_struct** %b.addr, align 8
  %call1 = call i32 @integer_in_ring(%struct.lp_int_ring_t* %2, %struct.__mpz_struct* %3)
  %tobool2 = icmp ne i32 %call1, 0
  br i1 %tobool2, label %cond.true, label %cond.false

cond.true:                                        ; preds = %land.lhs.true
  br label %cond.end

cond.false:                                       ; preds = %land.lhs.true, %entry
  call void @__assert_fail(i8* getelementptr inbounds ([47 x i8]* @.str73, i32 0, i32 0), i8* getelementptr inbounds ([52 x i8]* @.str70, i32 0, i32 0), i32 319, i8* getelementptr inbounds ([94 x i8]* @__PRETTY_FUNCTION__.integer_mul, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %4, %cond.true
  %5 = load %struct.__mpz_struct** %product.addr, align 8
  %6 = load %struct.__mpz_struct** %a.addr, align 8
  %7 = load %struct.__mpz_struct** %b.addr, align 8
  call void @__gmpz_mul(%struct.__mpz_struct* %5, %struct.__mpz_struct* %6, %struct.__mpz_struct* %7)
  %8 = load %struct.lp_int_ring_t** %K.addr, align 8
  %9 = load %struct.__mpz_struct** %product.addr, align 8
  call void @integer_ring_normalize(%struct.lp_int_ring_t* %8, %struct.__mpz_struct* %9)
  ret void
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_mul(%struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q) #0 {
entry:
  %retval = alloca %struct.lp_upolynomial_struct*, align 8
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  %degree = alloca i64, align 8
  %tmp = alloca %struct.upolynomial_dense_t, align 8
  %i = alloca i32, align 4
  %result114 = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 402, i8* getelementptr inbounds ([89 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_mul, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %tobool1 = icmp ne %struct.lp_upolynomial_struct* %2, null
  br i1 %tobool1, label %cond.true2, label %cond.false3

cond.true2:                                       ; preds = %cond.end
  br label %cond.end4

cond.false3:                                      ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str4, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 403, i8* getelementptr inbounds ([89 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_mul, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end4

cond.end4:                                        ; preds = %3, %cond.true2
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %4, i32 0, i32 0
  %5 = load %struct.lp_int_ring_t** %K, align 8
  %6 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %K5 = getelementptr inbounds %struct.lp_upolynomial_struct* %6, i32 0, i32 0
  %7 = load %struct.lp_int_ring_t** %K5, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %5, %7
  br i1 %cmp, label %cond.true6, label %cond.false7

cond.true6:                                       ; preds = %cond.end4
  br label %cond.end8

cond.false7:                                      ; preds = %cond.end4
  call void @__assert_fail(i8* getelementptr inbounds ([13 x i8]* @.str5, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 404, i8* getelementptr inbounds ([89 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_mul, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end8

cond.end8:                                        ; preds = %8, %cond.true6
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool9 = icmp ne i32 %call, 0
  br i1 %tobool9, label %if.then, label %if.end

if.then:                                          ; preds = %cond.end8
  %9 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool10 = icmp ne %struct._IO_FILE* %9, null
  br i1 %tobool10, label %cond.true11, label %cond.false12

cond.true11:                                      ; preds = %if.then
  %10 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end13

cond.false12:                                     ; preds = %if.then
  %11 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end13

cond.end13:                                       ; preds = %cond.false12, %cond.true11
  %cond = phi %struct._IO_FILE* [ %10, %cond.true11 ], [ %11, %cond.false12 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([22 x i8]* @.str14, i32 0, i32 0))
  %12 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %13 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool15 = icmp ne %struct._IO_FILE* %13, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %cond.end13
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end18

cond.false17:                                     ; preds = %cond.end13
  %15 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false17, %cond.true16
  %cond19 = phi %struct._IO_FILE* [ %14, %cond.true16 ], [ %15, %cond.false17 ]
  %call20 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %12, %struct._IO_FILE* %cond19)
  %16 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool21 = icmp ne %struct._IO_FILE* %16, null
  br i1 %tobool21, label %cond.true22, label %cond.false23

cond.true22:                                      ; preds = %cond.end18
  %17 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end24

cond.false23:                                     ; preds = %cond.end18
  %18 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end24

cond.end24:                                       ; preds = %cond.false23, %cond.true22
  %cond25 = phi %struct._IO_FILE* [ %17, %cond.true22 ], [ %18, %cond.false23 ]
  %call26 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond25, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %19 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %20 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool27 = icmp ne %struct._IO_FILE* %20, null
  br i1 %tobool27, label %cond.true28, label %cond.false29

cond.true28:                                      ; preds = %cond.end24
  %21 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end30

cond.false29:                                     ; preds = %cond.end24
  %22 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end30

cond.end30:                                       ; preds = %cond.false29, %cond.true28
  %cond31 = phi %struct._IO_FILE* [ %21, %cond.true28 ], [ %22, %cond.false29 ]
  %call32 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %19, %struct._IO_FILE* %cond31)
  %23 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool33 = icmp ne %struct._IO_FILE* %23, null
  br i1 %tobool33, label %cond.true34, label %cond.false35

cond.true34:                                      ; preds = %cond.end30
  %24 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end36

cond.false35:                                     ; preds = %cond.end30
  %25 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end36

cond.end36:                                       ; preds = %cond.false35, %cond.true34
  %cond37 = phi %struct._IO_FILE* [ %24, %cond.true34 ], [ %25, %cond.false35 ]
  %call38 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond37, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end36, %cond.end8
  %26 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %26, i32 0, i32 1
  %27 = load i64* %size, align 8
  %28 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %size39 = getelementptr inbounds %struct.lp_upolynomial_struct* %28, i32 0, i32 1
  %29 = load i64* %size39, align 8
  %cmp40 = icmp ugt i64 %27, %29
  br i1 %cmp40, label %if.then41, label %if.end43

if.then41:                                        ; preds = %if.end
  %30 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %31 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call42 = call %struct.lp_upolynomial_struct* @lp_upolynomial_mul(%struct.lp_upolynomial_struct* %30, %struct.lp_upolynomial_struct* %31)
  store %struct.lp_upolynomial_struct* %call42, %struct.lp_upolynomial_struct** %retval
  br label %return

if.end43:                                         ; preds = %if.end
  %32 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call44 = call i32 @lp_upolynomial_is_zero(%struct.lp_upolynomial_struct* %32)
  %tobool45 = icmp ne i32 %call44, 0
  br i1 %tobool45, label %if.then48, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %if.end43
  %33 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call46 = call i32 @lp_upolynomial_is_zero(%struct.lp_upolynomial_struct* %33)
  %tobool47 = icmp ne i32 %call46, 0
  br i1 %tobool47, label %if.then48, label %if.end51

if.then48:                                        ; preds = %lor.lhs.false, %if.end43
  %34 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K49 = getelementptr inbounds %struct.lp_upolynomial_struct* %34, i32 0, i32 0
  %35 = load %struct.lp_int_ring_t** %K49, align 8
  %call50 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_power(%struct.lp_int_ring_t* %35, i64 0, i64 0)
  store %struct.lp_upolynomial_struct* %call50, %struct.lp_upolynomial_struct** %retval
  br label %return

if.end51:                                         ; preds = %lor.lhs.false
  %36 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K52 = getelementptr inbounds %struct.lp_upolynomial_struct* %36, i32 0, i32 0
  %37 = load %struct.lp_int_ring_t** %K52, align 8
  %cmp53 = icmp eq %struct.lp_int_ring_t* %37, null
  br i1 %cmp53, label %land.lhs.true, label %if.end104

land.lhs.true:                                    ; preds = %if.end51
  %38 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size54 = getelementptr inbounds %struct.lp_upolynomial_struct* %38, i32 0, i32 1
  %39 = load i64* %size54, align 8
  %cmp55 = icmp eq i64 %39, 1
  br i1 %cmp55, label %if.then56, label %if.end104

if.then56:                                        ; preds = %land.lhs.true
  %40 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %40, i32 0, i32 2
  %arraydecay = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i32 0
  %41 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call57 = call %struct.lp_upolynomial_struct* @lp_upolynomial_multiply_simple(%struct.umonomial_struct* %arraydecay, %struct.lp_upolynomial_struct* %41)
  store %struct.lp_upolynomial_struct* %call57, %struct.lp_upolynomial_struct** %result, align 8
  %call58 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool59 = icmp ne i32 %call58, 0
  br i1 %tobool59, label %if.then60, label %if.end103

if.then60:                                        ; preds = %if.then56
  %42 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool61 = icmp ne %struct._IO_FILE* %42, null
  br i1 %tobool61, label %cond.true62, label %cond.false63

cond.true62:                                      ; preds = %if.then60
  %43 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end64

cond.false63:                                     ; preds = %if.then60
  %44 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end64

cond.end64:                                       ; preds = %cond.false63, %cond.true62
  %cond65 = phi %struct._IO_FILE* [ %43, %cond.true62 ], [ %44, %cond.false63 ]
  %call66 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond65, i8* getelementptr inbounds ([22 x i8]* @.str14, i32 0, i32 0))
  %45 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %46 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool67 = icmp ne %struct._IO_FILE* %46, null
  br i1 %tobool67, label %cond.true68, label %cond.false69

cond.true68:                                      ; preds = %cond.end64
  %47 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end70

cond.false69:                                     ; preds = %cond.end64
  %48 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end70

cond.end70:                                       ; preds = %cond.false69, %cond.true68
  %cond71 = phi %struct._IO_FILE* [ %47, %cond.true68 ], [ %48, %cond.false69 ]
  %call72 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %45, %struct._IO_FILE* %cond71)
  %49 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool73 = icmp ne %struct._IO_FILE* %49, null
  br i1 %tobool73, label %cond.true74, label %cond.false75

cond.true74:                                      ; preds = %cond.end70
  %50 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end76

cond.false75:                                     ; preds = %cond.end70
  %51 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end76

cond.end76:                                       ; preds = %cond.false75, %cond.true74
  %cond77 = phi %struct._IO_FILE* [ %50, %cond.true74 ], [ %51, %cond.false75 ]
  %call78 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond77, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %52 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %53 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool79 = icmp ne %struct._IO_FILE* %53, null
  br i1 %tobool79, label %cond.true80, label %cond.false81

cond.true80:                                      ; preds = %cond.end76
  %54 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end82

cond.false81:                                     ; preds = %cond.end76
  %55 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end82

cond.end82:                                       ; preds = %cond.false81, %cond.true80
  %cond83 = phi %struct._IO_FILE* [ %54, %cond.true80 ], [ %55, %cond.false81 ]
  %call84 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %52, %struct._IO_FILE* %cond83)
  %56 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool85 = icmp ne %struct._IO_FILE* %56, null
  br i1 %tobool85, label %cond.true86, label %cond.false87

cond.true86:                                      ; preds = %cond.end82
  %57 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end88

cond.false87:                                     ; preds = %cond.end82
  %58 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end88

cond.end88:                                       ; preds = %cond.false87, %cond.true86
  %cond89 = phi %struct._IO_FILE* [ %57, %cond.true86 ], [ %58, %cond.false87 ]
  %call90 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond89, i8* getelementptr inbounds ([5 x i8]* @.str10, i32 0, i32 0))
  %59 = load %struct.lp_upolynomial_struct** %result, align 8
  %60 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool91 = icmp ne %struct._IO_FILE* %60, null
  br i1 %tobool91, label %cond.true92, label %cond.false93

cond.true92:                                      ; preds = %cond.end88
  %61 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end94

cond.false93:                                     ; preds = %cond.end88
  %62 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end94

cond.end94:                                       ; preds = %cond.false93, %cond.true92
  %cond95 = phi %struct._IO_FILE* [ %61, %cond.true92 ], [ %62, %cond.false93 ]
  %call96 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %59, %struct._IO_FILE* %cond95)
  %63 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool97 = icmp ne %struct._IO_FILE* %63, null
  br i1 %tobool97, label %cond.true98, label %cond.false99

cond.true98:                                      ; preds = %cond.end94
  %64 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end100

cond.false99:                                     ; preds = %cond.end94
  %65 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end100

cond.end100:                                      ; preds = %cond.false99, %cond.true98
  %cond101 = phi %struct._IO_FILE* [ %64, %cond.true98 ], [ %65, %cond.false99 ]
  %call102 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond101, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end103

if.end103:                                        ; preds = %cond.end100, %if.then56
  %66 = load %struct.lp_upolynomial_struct** %result, align 8
  store %struct.lp_upolynomial_struct* %66, %struct.lp_upolynomial_struct** %retval
  br label %return

if.end104:                                        ; preds = %land.lhs.true, %if.end51
  %67 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call105 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %67)
  %68 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call106 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %68)
  %add = add i64 %call105, %call106
  store i64 %add, i64* %degree, align 8
  %69 = load i64* %degree, align 8
  %add107 = add i64 %69, 1
  call void @upolynomial_dense_construct(%struct.upolynomial_dense_t* %tmp, i64 %add107)
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.end104
  %70 = load i32* %i, align 4
  %conv = zext i32 %70 to i64
  %71 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size109 = getelementptr inbounds %struct.lp_upolynomial_struct* %71, i32 0, i32 1
  %72 = load i64* %size109, align 8
  %cmp110 = icmp ult i64 %conv, %72
  br i1 %cmp110, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %73 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %74 = load i32* %i, align 4
  %idxprom = zext i32 %74 to i64
  %75 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials112 = getelementptr inbounds %struct.lp_upolynomial_struct* %75, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials112, i32 0, i64 %idxprom
  call void @upolynomial_dense_add_mult_p_mon(%struct.upolynomial_dense_t* %tmp, %struct.lp_upolynomial_struct* %73, %struct.umonomial_struct* %arrayidx)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %76 = load i32* %i, align 4
  %inc = add i32 %76, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %77 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K115 = getelementptr inbounds %struct.lp_upolynomial_struct* %77, i32 0, i32 0
  %78 = load %struct.lp_int_ring_t** %K115, align 8
  %call116 = call %struct.lp_upolynomial_struct* @upolynomial_dense_to_upolynomial(%struct.upolynomial_dense_t* %tmp, %struct.lp_int_ring_t* %78)
  store %struct.lp_upolynomial_struct* %call116, %struct.lp_upolynomial_struct** %result114, align 8
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %tmp)
  %call117 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool118 = icmp ne i32 %call117, 0
  br i1 %tobool118, label %if.then119, label %if.end162

if.then119:                                       ; preds = %for.end
  %79 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool120 = icmp ne %struct._IO_FILE* %79, null
  br i1 %tobool120, label %cond.true121, label %cond.false122

cond.true121:                                     ; preds = %if.then119
  %80 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end123

cond.false122:                                    ; preds = %if.then119
  %81 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end123

cond.end123:                                      ; preds = %cond.false122, %cond.true121
  %cond124 = phi %struct._IO_FILE* [ %80, %cond.true121 ], [ %81, %cond.false122 ]
  %call125 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond124, i8* getelementptr inbounds ([22 x i8]* @.str14, i32 0, i32 0))
  %82 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %83 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool126 = icmp ne %struct._IO_FILE* %83, null
  br i1 %tobool126, label %cond.true127, label %cond.false128

cond.true127:                                     ; preds = %cond.end123
  %84 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end129

cond.false128:                                    ; preds = %cond.end123
  %85 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end129

cond.end129:                                      ; preds = %cond.false128, %cond.true127
  %cond130 = phi %struct._IO_FILE* [ %84, %cond.true127 ], [ %85, %cond.false128 ]
  %call131 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %82, %struct._IO_FILE* %cond130)
  %86 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool132 = icmp ne %struct._IO_FILE* %86, null
  br i1 %tobool132, label %cond.true133, label %cond.false134

cond.true133:                                     ; preds = %cond.end129
  %87 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end135

cond.false134:                                    ; preds = %cond.end129
  %88 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end135

cond.end135:                                      ; preds = %cond.false134, %cond.true133
  %cond136 = phi %struct._IO_FILE* [ %87, %cond.true133 ], [ %88, %cond.false134 ]
  %call137 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond136, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %89 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %90 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool138 = icmp ne %struct._IO_FILE* %90, null
  br i1 %tobool138, label %cond.true139, label %cond.false140

cond.true139:                                     ; preds = %cond.end135
  %91 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end141

cond.false140:                                    ; preds = %cond.end135
  %92 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end141

cond.end141:                                      ; preds = %cond.false140, %cond.true139
  %cond142 = phi %struct._IO_FILE* [ %91, %cond.true139 ], [ %92, %cond.false140 ]
  %call143 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %89, %struct._IO_FILE* %cond142)
  %93 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool144 = icmp ne %struct._IO_FILE* %93, null
  br i1 %tobool144, label %cond.true145, label %cond.false146

cond.true145:                                     ; preds = %cond.end141
  %94 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end147

cond.false146:                                    ; preds = %cond.end141
  %95 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end147

cond.end147:                                      ; preds = %cond.false146, %cond.true145
  %cond148 = phi %struct._IO_FILE* [ %94, %cond.true145 ], [ %95, %cond.false146 ]
  %call149 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond148, i8* getelementptr inbounds ([5 x i8]* @.str10, i32 0, i32 0))
  %96 = load %struct.lp_upolynomial_struct** %result114, align 8
  %97 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool150 = icmp ne %struct._IO_FILE* %97, null
  br i1 %tobool150, label %cond.true151, label %cond.false152

cond.true151:                                     ; preds = %cond.end147
  %98 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end153

cond.false152:                                    ; preds = %cond.end147
  %99 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end153

cond.end153:                                      ; preds = %cond.false152, %cond.true151
  %cond154 = phi %struct._IO_FILE* [ %98, %cond.true151 ], [ %99, %cond.false152 ]
  %call155 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %96, %struct._IO_FILE* %cond154)
  %100 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool156 = icmp ne %struct._IO_FILE* %100, null
  br i1 %tobool156, label %cond.true157, label %cond.false158

cond.true157:                                     ; preds = %cond.end153
  %101 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end159

cond.false158:                                    ; preds = %cond.end153
  %102 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end159

cond.end159:                                      ; preds = %cond.false158, %cond.true157
  %cond160 = phi %struct._IO_FILE* [ %101, %cond.true157 ], [ %102, %cond.false158 ]
  %call161 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond160, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end162

if.end162:                                        ; preds = %cond.end159, %for.end
  %103 = load %struct.lp_upolynomial_struct** %result114, align 8
  store %struct.lp_upolynomial_struct* %103, %struct.lp_upolynomial_struct** %retval
  br label %return

return:                                           ; preds = %if.end162, %if.end103, %if.then48, %if.then41
  %104 = load %struct.lp_upolynomial_struct** %retval
  ret %struct.lp_upolynomial_struct* %104
}

declare void @upolynomial_dense_add_mult_p_mon(%struct.upolynomial_dense_t*, %struct.lp_upolynomial_struct*, %struct.umonomial_struct*) #3

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_mul_c(%struct.lp_upolynomial_struct* %p, %struct.__mpz_struct* %c) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %c.addr = alloca %struct.__mpz_struct*, align 8
  %m = alloca %struct.umonomial_struct, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 453, i8* getelementptr inbounds ([87 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_mul_c, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool1 = icmp ne i32 %call, 0
  br i1 %tobool1, label %if.then, label %if.end

if.then:                                          ; preds = %cond.end
  %2 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool2 = icmp ne %struct._IO_FILE* %2, null
  br i1 %tobool2, label %cond.true3, label %cond.false4

cond.true3:                                       ; preds = %if.then
  %3 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end5

cond.false4:                                      ; preds = %if.then
  %4 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end5

cond.end5:                                        ; preds = %cond.false4, %cond.true3
  %cond = phi %struct._IO_FILE* [ %3, %cond.true3 ], [ %4, %cond.false4 ]
  %call6 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([24 x i8]* @.str15, i32 0, i32 0))
  %5 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %6 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool7 = icmp ne %struct._IO_FILE* %6, null
  br i1 %tobool7, label %cond.true8, label %cond.false9

cond.true8:                                       ; preds = %cond.end5
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end10

cond.false9:                                      ; preds = %cond.end5
  %8 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end10

cond.end10:                                       ; preds = %cond.false9, %cond.true8
  %cond11 = phi %struct._IO_FILE* [ %7, %cond.true8 ], [ %8, %cond.false9 ]
  %call12 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %5, %struct._IO_FILE* %cond11)
  %9 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool13 = icmp ne %struct._IO_FILE* %9, null
  br i1 %tobool13, label %cond.true14, label %cond.false15

cond.true14:                                      ; preds = %cond.end10
  %10 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end16

cond.false15:                                     ; preds = %cond.end10
  %11 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end16

cond.end16:                                       ; preds = %cond.false15, %cond.true14
  %cond17 = phi %struct._IO_FILE* [ %10, %cond.true14 ], [ %11, %cond.false15 ]
  %call18 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond17, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %12 = load %struct.__mpz_struct** %c.addr, align 8
  %13 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool19 = icmp ne %struct._IO_FILE* %13, null
  br i1 %tobool19, label %cond.true20, label %cond.false21

cond.true20:                                      ; preds = %cond.end16
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end22

cond.false21:                                     ; preds = %cond.end16
  %15 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end22

cond.end22:                                       ; preds = %cond.false21, %cond.true20
  %cond23 = phi %struct._IO_FILE* [ %14, %cond.true20 ], [ %15, %cond.false21 ]
  %call24 = call i32 @integer_print(%struct.__mpz_struct* %12, %struct._IO_FILE* %cond23)
  %16 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool25 = icmp ne %struct._IO_FILE* %16, null
  br i1 %tobool25, label %cond.true26, label %cond.false27

cond.true26:                                      ; preds = %cond.end22
  %17 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end28

cond.false27:                                     ; preds = %cond.end22
  %18 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end28

cond.end28:                                       ; preds = %cond.false27, %cond.true26
  %cond29 = phi %struct._IO_FILE* [ %17, %cond.true26 ], [ %18, %cond.false27 ]
  %call30 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond29, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end28, %cond.end
  %19 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %19, i32 0, i32 0
  %20 = load %struct.lp_int_ring_t** %K, align 8
  %21 = load %struct.__mpz_struct** %c.addr, align 8
  call void @umonomial_construct(%struct.lp_int_ring_t* %20, %struct.umonomial_struct* %m, i64 0, %struct.__mpz_struct* %21)
  %22 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call31 = call %struct.lp_upolynomial_struct* @lp_upolynomial_multiply_simple(%struct.umonomial_struct* %m, %struct.lp_upolynomial_struct* %22)
  store %struct.lp_upolynomial_struct* %call31, %struct.lp_upolynomial_struct** %result, align 8
  call void @umonomial_destruct(%struct.umonomial_struct* %m)
  %call32 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool33 = icmp ne i32 %call32, 0
  br i1 %tobool33, label %if.then34, label %if.end77

if.then34:                                        ; preds = %if.end
  %23 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool35 = icmp ne %struct._IO_FILE* %23, null
  br i1 %tobool35, label %cond.true36, label %cond.false37

cond.true36:                                      ; preds = %if.then34
  %24 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end38

cond.false37:                                     ; preds = %if.then34
  %25 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end38

cond.end38:                                       ; preds = %cond.false37, %cond.true36
  %cond39 = phi %struct._IO_FILE* [ %24, %cond.true36 ], [ %25, %cond.false37 ]
  %call40 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond39, i8* getelementptr inbounds ([24 x i8]* @.str15, i32 0, i32 0))
  %26 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %27 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool41 = icmp ne %struct._IO_FILE* %27, null
  br i1 %tobool41, label %cond.true42, label %cond.false43

cond.true42:                                      ; preds = %cond.end38
  %28 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end44

cond.false43:                                     ; preds = %cond.end38
  %29 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end44

cond.end44:                                       ; preds = %cond.false43, %cond.true42
  %cond45 = phi %struct._IO_FILE* [ %28, %cond.true42 ], [ %29, %cond.false43 ]
  %call46 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %26, %struct._IO_FILE* %cond45)
  %30 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool47 = icmp ne %struct._IO_FILE* %30, null
  br i1 %tobool47, label %cond.true48, label %cond.false49

cond.true48:                                      ; preds = %cond.end44
  %31 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end50

cond.false49:                                     ; preds = %cond.end44
  %32 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end50

cond.end50:                                       ; preds = %cond.false49, %cond.true48
  %cond51 = phi %struct._IO_FILE* [ %31, %cond.true48 ], [ %32, %cond.false49 ]
  %call52 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond51, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %33 = load %struct.__mpz_struct** %c.addr, align 8
  %34 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool53 = icmp ne %struct._IO_FILE* %34, null
  br i1 %tobool53, label %cond.true54, label %cond.false55

cond.true54:                                      ; preds = %cond.end50
  %35 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end56

cond.false55:                                     ; preds = %cond.end50
  %36 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end56

cond.end56:                                       ; preds = %cond.false55, %cond.true54
  %cond57 = phi %struct._IO_FILE* [ %35, %cond.true54 ], [ %36, %cond.false55 ]
  %call58 = call i32 @integer_print(%struct.__mpz_struct* %33, %struct._IO_FILE* %cond57)
  %37 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool59 = icmp ne %struct._IO_FILE* %37, null
  br i1 %tobool59, label %cond.true60, label %cond.false61

cond.true60:                                      ; preds = %cond.end56
  %38 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end62

cond.false61:                                     ; preds = %cond.end56
  %39 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end62

cond.end62:                                       ; preds = %cond.false61, %cond.true60
  %cond63 = phi %struct._IO_FILE* [ %38, %cond.true60 ], [ %39, %cond.false61 ]
  %call64 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond63, i8* getelementptr inbounds ([5 x i8]* @.str10, i32 0, i32 0))
  %40 = load %struct.lp_upolynomial_struct** %result, align 8
  %41 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool65 = icmp ne %struct._IO_FILE* %41, null
  br i1 %tobool65, label %cond.true66, label %cond.false67

cond.true66:                                      ; preds = %cond.end62
  %42 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end68

cond.false67:                                     ; preds = %cond.end62
  %43 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end68

cond.end68:                                       ; preds = %cond.false67, %cond.true66
  %cond69 = phi %struct._IO_FILE* [ %42, %cond.true66 ], [ %43, %cond.false67 ]
  %call70 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %40, %struct._IO_FILE* %cond69)
  %44 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool71 = icmp ne %struct._IO_FILE* %44, null
  br i1 %tobool71, label %cond.true72, label %cond.false73

cond.true72:                                      ; preds = %cond.end68
  %45 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end74

cond.false73:                                     ; preds = %cond.end68
  %46 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end74

cond.end74:                                       ; preds = %cond.false73, %cond.true72
  %cond75 = phi %struct._IO_FILE* [ %45, %cond.true72 ], [ %46, %cond.false73 ]
  %call76 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond75, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end77

if.end77:                                         ; preds = %cond.end74, %if.end
  %47 = load %struct.lp_upolynomial_struct** %result, align 8
  ret %struct.lp_upolynomial_struct* %47
}

; Function Attrs: inlinehint nounwind uwtable
define internal i32 @integer_print(%struct.__mpz_struct* %c, %struct._IO_FILE* %out) #4 {
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

declare void @umonomial_destruct(%struct.umonomial_struct*) #3

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_pow(%struct.lp_upolynomial_struct* %p, i64 %pow) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %pow.addr = alloca i64, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  %tmp = alloca %struct.lp_upolynomial_struct*, align 8
  %prev = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store i64 %pow, i64* %pow.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([17 x i8]* @.str16, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %10 = load i64* %pow.addr, align 8
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([8 x i8]* @.str17, i32 0, i32 0), i64 %10)
  br label %if.end

if.end:                                           ; preds = %cond.end12, %entry
  %11 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool15 = icmp ne %struct.lp_upolynomial_struct* %11, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %if.end
  br label %cond.end18

cond.false17:                                     ; preds = %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 482, i8* getelementptr inbounds ([69 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_pow, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end18

cond.end18:                                       ; preds = %12, %cond.true16
  %13 = load i64* %pow.addr, align 8
  %cmp = icmp sge i64 %13, 0
  br i1 %cmp, label %cond.true19, label %cond.false20

cond.true19:                                      ; preds = %cond.end18
  br label %cond.end21

cond.false20:                                     ; preds = %cond.end18
  call void @__assert_fail(i8* getelementptr inbounds ([9 x i8]* @.str18, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 483, i8* getelementptr inbounds ([69 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_pow, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end21

cond.end21:                                       ; preds = %14, %cond.true19
  store %struct.lp_upolynomial_struct* null, %struct.lp_upolynomial_struct** %result, align 8
  %15 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %15, i32 0, i32 1
  %16 = load i64* %size, align 8
  %cmp22 = icmp eq i64 %16, 1
  br i1 %cmp22, label %if.then23, label %if.else

if.then23:                                        ; preds = %cond.end21
  %17 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %17, i32 0, i32 0
  %18 = load %struct.lp_int_ring_t** %K, align 8
  %call24 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_empty(%struct.lp_int_ring_t* %18, i64 1)
  store %struct.lp_upolynomial_struct* %call24, %struct.lp_upolynomial_struct** %result, align 8
  %19 = load %struct.lp_upolynomial_struct** %result, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %19, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 0
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 1
  call void @integer_construct_from_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %coefficient, i64 0)
  %20 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K25 = getelementptr inbounds %struct.lp_upolynomial_struct* %20, i32 0, i32 0
  %21 = load %struct.lp_int_ring_t** %K25, align 8
  %22 = load %struct.lp_upolynomial_struct** %result, align 8
  %monomials26 = getelementptr inbounds %struct.lp_upolynomial_struct* %22, i32 0, i32 2
  %arrayidx27 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials26, i32 0, i64 0
  %coefficient28 = getelementptr inbounds %struct.umonomial_struct* %arrayidx27, i32 0, i32 1
  %23 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials29 = getelementptr inbounds %struct.lp_upolynomial_struct* %23, i32 0, i32 2
  %arrayidx30 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials29, i32 0, i64 0
  %coefficient31 = getelementptr inbounds %struct.umonomial_struct* %arrayidx30, i32 0, i32 1
  %24 = load i64* %pow.addr, align 8
  %conv = trunc i64 %24 to i32
  call void @integer_pow(%struct.lp_int_ring_t* %21, %struct.__mpz_struct* %coefficient28, %struct.__mpz_struct* %coefficient31, i32 %conv)
  %25 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials32 = getelementptr inbounds %struct.lp_upolynomial_struct* %25, i32 0, i32 2
  %arrayidx33 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials32, i32 0, i64 0
  %degree = getelementptr inbounds %struct.umonomial_struct* %arrayidx33, i32 0, i32 0
  %26 = load i64* %degree, align 8
  %27 = load i64* %pow.addr, align 8
  %mul = mul i64 %26, %27
  %28 = load %struct.lp_upolynomial_struct** %result, align 8
  %monomials34 = getelementptr inbounds %struct.lp_upolynomial_struct* %28, i32 0, i32 2
  %arrayidx35 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials34, i32 0, i64 0
  %degree36 = getelementptr inbounds %struct.umonomial_struct* %arrayidx35, i32 0, i32 0
  store i64 %mul, i64* %degree36, align 8
  br label %if.end47

if.else:                                          ; preds = %cond.end21
  %29 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K37 = getelementptr inbounds %struct.lp_upolynomial_struct* %29, i32 0, i32 0
  %30 = load %struct.lp_int_ring_t** %K37, align 8
  %call38 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_power(%struct.lp_int_ring_t* %30, i64 0, i64 1)
  store %struct.lp_upolynomial_struct* %call38, %struct.lp_upolynomial_struct** %result, align 8
  %31 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call39 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy(%struct.lp_upolynomial_struct* %31)
  store %struct.lp_upolynomial_struct* %call39, %struct.lp_upolynomial_struct** %tmp, align 8
  br label %while.cond

while.cond:                                       ; preds = %if.end45, %if.else
  %32 = load i64* %pow.addr, align 8
  %tobool41 = icmp ne i64 %32, 0
  br i1 %tobool41, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %33 = load i64* %pow.addr, align 8
  %and = and i64 %33, 1
  %tobool42 = icmp ne i64 %and, 0
  br i1 %tobool42, label %if.then43, label %if.end45

if.then43:                                        ; preds = %while.body
  %34 = load %struct.lp_upolynomial_struct** %result, align 8
  store %struct.lp_upolynomial_struct* %34, %struct.lp_upolynomial_struct** %prev, align 8
  %35 = load %struct.lp_upolynomial_struct** %result, align 8
  %36 = load %struct.lp_upolynomial_struct** %tmp, align 8
  %call44 = call %struct.lp_upolynomial_struct* @lp_upolynomial_mul(%struct.lp_upolynomial_struct* %35, %struct.lp_upolynomial_struct* %36)
  store %struct.lp_upolynomial_struct* %call44, %struct.lp_upolynomial_struct** %result, align 8
  %37 = load %struct.lp_upolynomial_struct** %prev, align 8
  call void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %37)
  br label %if.end45

if.end45:                                         ; preds = %if.then43, %while.body
  %38 = load %struct.lp_upolynomial_struct** %tmp, align 8
  store %struct.lp_upolynomial_struct* %38, %struct.lp_upolynomial_struct** %prev, align 8
  %39 = load %struct.lp_upolynomial_struct** %tmp, align 8
  %40 = load %struct.lp_upolynomial_struct** %tmp, align 8
  %call46 = call %struct.lp_upolynomial_struct* @lp_upolynomial_mul(%struct.lp_upolynomial_struct* %39, %struct.lp_upolynomial_struct* %40)
  store %struct.lp_upolynomial_struct* %call46, %struct.lp_upolynomial_struct** %tmp, align 8
  %41 = load i64* %pow.addr, align 8
  %shr = ashr i64 %41, 1
  store i64 %shr, i64* %pow.addr, align 8
  %42 = load %struct.lp_upolynomial_struct** %prev, align 8
  call void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %42)
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %43 = load %struct.lp_upolynomial_struct** %tmp, align 8
  call void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %43)
  br label %if.end47

if.end47:                                         ; preds = %while.end, %if.then23
  %call48 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool49 = icmp ne i32 %call48, 0
  br i1 %tobool49, label %if.then50, label %if.end81

if.then50:                                        ; preds = %if.end47
  %44 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool51 = icmp ne %struct._IO_FILE* %44, null
  br i1 %tobool51, label %cond.true52, label %cond.false53

cond.true52:                                      ; preds = %if.then50
  %45 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end54

cond.false53:                                     ; preds = %if.then50
  %46 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end54

cond.end54:                                       ; preds = %cond.false53, %cond.true52
  %cond55 = phi %struct._IO_FILE* [ %45, %cond.true52 ], [ %46, %cond.false53 ]
  %call56 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond55, i8* getelementptr inbounds ([17 x i8]* @.str16, i32 0, i32 0))
  %47 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %48 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool57 = icmp ne %struct._IO_FILE* %48, null
  br i1 %tobool57, label %cond.true58, label %cond.false59

cond.true58:                                      ; preds = %cond.end54
  %49 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end60

cond.false59:                                     ; preds = %cond.end54
  %50 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end60

cond.end60:                                       ; preds = %cond.false59, %cond.true58
  %cond61 = phi %struct._IO_FILE* [ %49, %cond.true58 ], [ %50, %cond.false59 ]
  %call62 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %47, %struct._IO_FILE* %cond61)
  %51 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool63 = icmp ne %struct._IO_FILE* %51, null
  br i1 %tobool63, label %cond.true64, label %cond.false65

cond.true64:                                      ; preds = %cond.end60
  %52 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end66

cond.false65:                                     ; preds = %cond.end60
  %53 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end66

cond.end66:                                       ; preds = %cond.false65, %cond.true64
  %cond67 = phi %struct._IO_FILE* [ %52, %cond.true64 ], [ %53, %cond.false65 ]
  %54 = load i64* %pow.addr, align 8
  %call68 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond67, i8* getelementptr inbounds ([10 x i8]* @.str19, i32 0, i32 0), i64 %54)
  %55 = load %struct.lp_upolynomial_struct** %result, align 8
  %56 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool69 = icmp ne %struct._IO_FILE* %56, null
  br i1 %tobool69, label %cond.true70, label %cond.false71

cond.true70:                                      ; preds = %cond.end66
  %57 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end72

cond.false71:                                     ; preds = %cond.end66
  %58 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end72

cond.end72:                                       ; preds = %cond.false71, %cond.true70
  %cond73 = phi %struct._IO_FILE* [ %57, %cond.true70 ], [ %58, %cond.false71 ]
  %call74 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %55, %struct._IO_FILE* %cond73)
  %59 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool75 = icmp ne %struct._IO_FILE* %59, null
  br i1 %tobool75, label %cond.true76, label %cond.false77

cond.true76:                                      ; preds = %cond.end72
  %60 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end78

cond.false77:                                     ; preds = %cond.end72
  %61 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end78

cond.end78:                                       ; preds = %cond.false77, %cond.true76
  %cond79 = phi %struct._IO_FILE* [ %60, %cond.true76 ], [ %61, %cond.false77 ]
  %call80 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond79, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end81

if.end81:                                         ; preds = %cond.end78, %if.end47
  %62 = load %struct.lp_upolynomial_struct** %result, align 8
  ret %struct.lp_upolynomial_struct* %62
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_pow(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %power, %struct.__mpz_struct* %a, i32 %n) #4 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %power.addr = alloca %struct.__mpz_struct*, align 8
  %a.addr = alloca %struct.__mpz_struct*, align 8
  %n.addr = alloca i32, align 4
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %power, %struct.__mpz_struct** %power.addr, align 8
  store %struct.__mpz_struct* %a, %struct.__mpz_struct** %a.addr, align 8
  store i32 %n, i32* %n.addr, align 4
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %1 = load %struct.__mpz_struct** %a.addr, align 8
  %call = call i32 @integer_in_ring(%struct.lp_int_ring_t* %0, %struct.__mpz_struct* %1)
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([22 x i8]* @.str72, i32 0, i32 0), i8* getelementptr inbounds ([52 x i8]* @.str70, i32 0, i32 0), i32 340, i8* getelementptr inbounds ([86 x i8]* @__PRETTY_FUNCTION__.integer_pow, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %2, %cond.true
  %3 = load %struct.lp_int_ring_t** %K.addr, align 8
  %tobool1 = icmp ne %struct.lp_int_ring_t* %3, null
  br i1 %tobool1, label %if.then, label %if.else

if.then:                                          ; preds = %cond.end
  %4 = load %struct.__mpz_struct** %power.addr, align 8
  %5 = load %struct.__mpz_struct** %a.addr, align 8
  %6 = load i32* %n.addr, align 4
  %conv = zext i32 %6 to i64
  %7 = load %struct.lp_int_ring_t** %K.addr, align 8
  %M = getelementptr inbounds %struct.lp_int_ring_t* %7, i32 0, i32 2
  call void @__gmpz_powm_ui(%struct.__mpz_struct* %4, %struct.__mpz_struct* %5, i64 %conv, %struct.__mpz_struct* %M)
  %8 = load %struct.lp_int_ring_t** %K.addr, align 8
  %9 = load %struct.__mpz_struct** %power.addr, align 8
  call void @integer_ring_normalize(%struct.lp_int_ring_t* %8, %struct.__mpz_struct* %9)
  br label %if.end

if.else:                                          ; preds = %cond.end
  %10 = load %struct.__mpz_struct** %power.addr, align 8
  %11 = load %struct.__mpz_struct** %a.addr, align 8
  %12 = load i32* %n.addr, align 4
  %conv2 = zext i32 %12 to i64
  call void @__gmpz_pow_ui(%struct.__mpz_struct* %10, %struct.__mpz_struct* %11, i64 %conv2)
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  ret void
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_derivative(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %degree = alloca i64, align 8
  %tmp = alloca %struct.upolynomial_dense_t, align 8
  %i = alloca i32, align 4
  %degree_i = alloca i64, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([24 x i8]* @.str20, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end12, %entry
  %10 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call15 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %10)
  store i64 %call15, i64* %degree, align 8
  %11 = load i64* %degree, align 8
  %cmp = icmp ugt i64 %11, 0
  br i1 %cmp, label %if.then16, label %if.end17

if.then16:                                        ; preds = %if.end
  %12 = load i64* %degree, align 8
  %dec = add i64 %12, -1
  store i64 %dec, i64* %degree, align 8
  br label %if.end17

if.end17:                                         ; preds = %if.then16, %if.end
  %13 = load i64* %degree, align 8
  %add = add i64 %13, 1
  call void @upolynomial_dense_construct(%struct.upolynomial_dense_t* %tmp, i64 %add)
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.end17
  %14 = load i32* %i, align 4
  %conv = zext i32 %14 to i64
  %15 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %15, i32 0, i32 1
  %16 = load i64* %size, align 8
  %cmp19 = icmp ult i64 %conv, %16
  br i1 %cmp19, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %17 = load i32* %i, align 4
  %idxprom = zext i32 %17 to i64
  %18 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %18, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %idxprom
  %degree22 = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 0
  %19 = load i64* %degree22, align 8
  store i64 %19, i64* %degree_i, align 8
  %20 = load i64* %degree_i, align 8
  %cmp23 = icmp ugt i64 %20, 0
  br i1 %cmp23, label %if.then25, label %if.end30

if.then25:                                        ; preds = %for.body
  %21 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %21, i32 0, i32 0
  %22 = load %struct.lp_int_ring_t** %K, align 8
  %23 = load i64* %degree_i, align 8
  %sub = sub i64 %23, 1
  %coefficients = getelementptr inbounds %struct.upolynomial_dense_t* %tmp, i32 0, i32 2
  %24 = load %struct.__mpz_struct** %coefficients, align 8
  %arrayidx26 = getelementptr inbounds %struct.__mpz_struct* %24, i64 %sub
  %25 = load i32* %i, align 4
  %idxprom27 = zext i32 %25 to i64
  %26 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials28 = getelementptr inbounds %struct.lp_upolynomial_struct* %26, i32 0, i32 2
  %arrayidx29 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials28, i32 0, i64 %idxprom27
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx29, i32 0, i32 1
  %27 = load i64* %degree_i, align 8
  call void @integer_mul_int(%struct.lp_int_ring_t* %22, %struct.__mpz_struct* %arrayidx26, %struct.__mpz_struct* %coefficient, i64 %27)
  br label %if.end30

if.end30:                                         ; preds = %if.then25, %for.body
  br label %for.inc

for.inc:                                          ; preds = %if.end30
  %28 = load i32* %i, align 4
  %inc = add i32 %28, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %29 = load i64* %degree, align 8
  %add31 = add i64 %29, 1
  %size32 = getelementptr inbounds %struct.upolynomial_dense_t* %tmp, i32 0, i32 1
  store i64 %add31, i64* %size32, align 8
  %30 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K34 = getelementptr inbounds %struct.lp_upolynomial_struct* %30, i32 0, i32 0
  %31 = load %struct.lp_int_ring_t** %K34, align 8
  %call35 = call %struct.lp_upolynomial_struct* @upolynomial_dense_to_upolynomial(%struct.upolynomial_dense_t* %tmp, %struct.lp_int_ring_t* %31)
  store %struct.lp_upolynomial_struct* %call35, %struct.lp_upolynomial_struct** %result, align 8
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %tmp)
  %call36 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool37 = icmp ne i32 %call36, 0
  br i1 %tobool37, label %if.then38, label %if.end69

if.then38:                                        ; preds = %for.end
  %32 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool39 = icmp ne %struct._IO_FILE* %32, null
  br i1 %tobool39, label %cond.true40, label %cond.false41

cond.true40:                                      ; preds = %if.then38
  %33 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end42

cond.false41:                                     ; preds = %if.then38
  %34 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end42

cond.end42:                                       ; preds = %cond.false41, %cond.true40
  %cond43 = phi %struct._IO_FILE* [ %33, %cond.true40 ], [ %34, %cond.false41 ]
  %call44 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond43, i8* getelementptr inbounds ([24 x i8]* @.str20, i32 0, i32 0))
  %35 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %36 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool45 = icmp ne %struct._IO_FILE* %36, null
  br i1 %tobool45, label %cond.true46, label %cond.false47

cond.true46:                                      ; preds = %cond.end42
  %37 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end48

cond.false47:                                     ; preds = %cond.end42
  %38 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end48

cond.end48:                                       ; preds = %cond.false47, %cond.true46
  %cond49 = phi %struct._IO_FILE* [ %37, %cond.true46 ], [ %38, %cond.false47 ]
  %call50 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %35, %struct._IO_FILE* %cond49)
  %39 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool51 = icmp ne %struct._IO_FILE* %39, null
  br i1 %tobool51, label %cond.true52, label %cond.false53

cond.true52:                                      ; preds = %cond.end48
  %40 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end54

cond.false53:                                     ; preds = %cond.end48
  %41 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end54

cond.end54:                                       ; preds = %cond.false53, %cond.true52
  %cond55 = phi %struct._IO_FILE* [ %40, %cond.true52 ], [ %41, %cond.false53 ]
  %call56 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond55, i8* getelementptr inbounds ([5 x i8]* @.str10, i32 0, i32 0))
  %42 = load %struct.lp_upolynomial_struct** %result, align 8
  %43 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool57 = icmp ne %struct._IO_FILE* %43, null
  br i1 %tobool57, label %cond.true58, label %cond.false59

cond.true58:                                      ; preds = %cond.end54
  %44 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end60

cond.false59:                                     ; preds = %cond.end54
  %45 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end60

cond.end60:                                       ; preds = %cond.false59, %cond.true58
  %cond61 = phi %struct._IO_FILE* [ %44, %cond.true58 ], [ %45, %cond.false59 ]
  %call62 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %42, %struct._IO_FILE* %cond61)
  %46 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool63 = icmp ne %struct._IO_FILE* %46, null
  br i1 %tobool63, label %cond.true64, label %cond.false65

cond.true64:                                      ; preds = %cond.end60
  %47 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end66

cond.false65:                                     ; preds = %cond.end60
  %48 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end66

cond.end66:                                       ; preds = %cond.false65, %cond.true64
  %cond67 = phi %struct._IO_FILE* [ %47, %cond.true64 ], [ %48, %cond.false65 ]
  %call68 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond67, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end69

if.end69:                                         ; preds = %cond.end66, %for.end
  %49 = load %struct.lp_upolynomial_struct** %result, align 8
  ret %struct.lp_upolynomial_struct* %49
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_mul_int(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %product, %struct.__mpz_struct* %a, i64 %b) #4 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %product.addr = alloca %struct.__mpz_struct*, align 8
  %a.addr = alloca %struct.__mpz_struct*, align 8
  %b.addr = alloca i64, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %product, %struct.__mpz_struct** %product.addr, align 8
  store %struct.__mpz_struct* %a, %struct.__mpz_struct** %a.addr, align 8
  store i64 %b, i64* %b.addr, align 8
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %1 = load %struct.__mpz_struct** %a.addr, align 8
  %call = call i32 @integer_in_ring(%struct.lp_int_ring_t* %0, %struct.__mpz_struct* %1)
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([22 x i8]* @.str72, i32 0, i32 0), i8* getelementptr inbounds ([52 x i8]* @.str70, i32 0, i32 0), i32 326, i8* getelementptr inbounds ([82 x i8]* @__PRETTY_FUNCTION__.integer_mul_int, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %2, %cond.true
  %3 = load %struct.__mpz_struct** %product.addr, align 8
  %4 = load %struct.__mpz_struct** %a.addr, align 8
  %5 = load i64* %b.addr, align 8
  call void @__gmpz_mul_si(%struct.__mpz_struct* %3, %struct.__mpz_struct* %4, i64 %5)
  %6 = load %struct.lp_int_ring_t** %K.addr, align 8
  %7 = load %struct.__mpz_struct** %product.addr, align 8
  call void @integer_ring_normalize(%struct.lp_int_ring_t* %6, %struct.__mpz_struct* %7)
  ret void
}

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_div_general(%struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q, %struct.upolynomial_dense_t* %div, %struct.upolynomial_dense_t* %rem, i32 %exact) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %div.addr = alloca %struct.upolynomial_dense_t*, align 8
  %rem.addr = alloca %struct.upolynomial_dense_t*, align 8
  %exact.addr = alloca i32, align 4
  %K45 = alloca %struct.lp_int_ring_t*, align 8
  %p_deg = alloca i32, align 4
  %q_deg = alloca i32, align 4
  %m = alloca %struct.umonomial_struct, align 8
  %adjust = alloca %struct.__mpz_struct, align 8
  %k = alloca i32, align 4
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  store %struct.upolynomial_dense_t* %div, %struct.upolynomial_dense_t** %div.addr, align 8
  store %struct.upolynomial_dense_t* %rem, %struct.upolynomial_dense_t** %rem.addr, align 8
  store i32 %exact, i32* %exact.addr, align 4
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([9 x i8]* @.str21, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([25 x i8]* @.str22, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %10 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %11 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool15 = icmp ne %struct._IO_FILE* %11, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %cond.end12
  %12 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end18

cond.false17:                                     ; preds = %cond.end12
  %13 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false17, %cond.true16
  %cond19 = phi %struct._IO_FILE* [ %12, %cond.true16 ], [ %13, %cond.false17 ]
  %call20 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %10, %struct._IO_FILE* %cond19)
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool21 = icmp ne %struct._IO_FILE* %14, null
  br i1 %tobool21, label %cond.true22, label %cond.false23

cond.true22:                                      ; preds = %cond.end18
  %15 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end24

cond.false23:                                     ; preds = %cond.end18
  %16 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end24

cond.end24:                                       ; preds = %cond.false23, %cond.true22
  %cond25 = phi %struct._IO_FILE* [ %15, %cond.true22 ], [ %16, %cond.false23 ]
  %call26 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond25, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end24, %entry
  %17 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool27 = icmp ne %struct.lp_upolynomial_struct* %17, null
  br i1 %tobool27, label %cond.true28, label %cond.false29

cond.true28:                                      ; preds = %if.end
  br label %cond.end30

cond.false29:                                     ; preds = %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 563, i8* getelementptr inbounds ([135 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_general, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end30

cond.end30:                                       ; preds = %18, %cond.true28
  %19 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %tobool31 = icmp ne %struct.lp_upolynomial_struct* %19, null
  br i1 %tobool31, label %cond.true32, label %cond.false33

cond.true32:                                      ; preds = %cond.end30
  br label %cond.end34

cond.false33:                                     ; preds = %cond.end30
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str4, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 564, i8* getelementptr inbounds ([135 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_general, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end34

cond.end34:                                       ; preds = %20, %cond.true32
  %21 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %21, i32 0, i32 0
  %22 = load %struct.lp_int_ring_t** %K, align 8
  %23 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %K35 = getelementptr inbounds %struct.lp_upolynomial_struct* %23, i32 0, i32 0
  %24 = load %struct.lp_int_ring_t** %K35, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %22, %24
  br i1 %cmp, label %cond.true36, label %cond.false37

cond.true36:                                      ; preds = %cond.end34
  br label %cond.end38

cond.false37:                                     ; preds = %cond.end34
  call void @__assert_fail(i8* getelementptr inbounds ([13 x i8]* @.str5, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 565, i8* getelementptr inbounds ([135 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_general, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end38

cond.end38:                                       ; preds = %25, %cond.true36
  %26 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call39 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %26)
  %27 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call40 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %27)
  %cmp41 = icmp ule i64 %call39, %call40
  br i1 %cmp41, label %cond.true42, label %cond.false43

cond.true42:                                      ; preds = %cond.end38
  br label %cond.end44

cond.false43:                                     ; preds = %cond.end38
  call void @__assert_fail(i8* getelementptr inbounds ([53 x i8]* @.str23, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 566, i8* getelementptr inbounds ([135 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_general, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end44

cond.end44:                                       ; preds = %28, %cond.true42
  %29 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K46 = getelementptr inbounds %struct.lp_upolynomial_struct* %29, i32 0, i32 0
  %30 = load %struct.lp_int_ring_t** %K46, align 8
  store %struct.lp_int_ring_t* %30, %struct.lp_int_ring_t** %K45, align 8
  %31 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call47 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %31)
  %conv = trunc i64 %call47 to i32
  store i32 %conv, i32* %p_deg, align 4
  %32 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call48 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %32)
  %conv49 = trunc i64 %call48 to i32
  store i32 %conv49, i32* %q_deg, align 4
  %33 = load %struct.upolynomial_dense_t** %rem.addr, align 8
  %34 = load i32* %p_deg, align 4
  %add = add nsw i32 %34, 1
  %conv50 = sext i32 %add to i64
  %35 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  call void @upolynomial_dense_construct_p(%struct.upolynomial_dense_t* %33, i64 %conv50, %struct.lp_upolynomial_struct* %35)
  %36 = load %struct.upolynomial_dense_t** %div.addr, align 8
  %37 = load i32* %p_deg, align 4
  %38 = load i32* %q_deg, align 4
  %sub = sub nsw i32 %37, %38
  %add51 = add nsw i32 %sub, 1
  %conv52 = sext i32 %add51 to i64
  call void @upolynomial_dense_construct(%struct.upolynomial_dense_t* %36, i64 %conv52)
  call void @umonomial_construct_from_int(%struct.lp_int_ring_t* null, %struct.umonomial_struct* %m, i64 0, i64 0)
  call void @integer_construct_from_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %adjust, i64 0)
  %39 = load i32* %p_deg, align 4
  store i32 %39, i32* %k, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %cond.end44
  %40 = load i32* %k, align 4
  %41 = load i32* %q_deg, align 4
  %cmp53 = icmp sge i32 %40, %41
  br i1 %cmp53, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  br label %while.cond

while.cond:                                       ; preds = %while.body, %for.body
  %42 = load i32* %exact.addr, align 4
  %tobool55 = icmp ne i32 %42, 0
  br i1 %tobool55, label %land.lhs.true, label %land.end

land.lhs.true:                                    ; preds = %while.cond
  %43 = load i32* %k, align 4
  %44 = load i32* %q_deg, align 4
  %cmp56 = icmp sge i32 %43, %44
  br i1 %cmp56, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %land.lhs.true
  %45 = load %struct.upolynomial_dense_t** %rem.addr, align 8
  %coefficients = getelementptr inbounds %struct.upolynomial_dense_t* %45, i32 0, i32 2
  %46 = load %struct.__mpz_struct** %coefficients, align 8
  %47 = load i32* %k, align 4
  %idx.ext = sext i32 %47 to i64
  %add.ptr = getelementptr inbounds %struct.__mpz_struct* %46, i64 %idx.ext
  %call58 = call i32 @integer_sgn(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %add.ptr)
  %cmp59 = icmp eq i32 %call58, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %land.lhs.true, %while.cond
  %48 = phi i1 [ false, %land.lhs.true ], [ false, %while.cond ], [ %cmp59, %land.rhs ]
  br i1 %48, label %while.body, label %while.end

while.body:                                       ; preds = %land.end
  %49 = load i32* %k, align 4
  %dec = add nsw i32 %49, -1
  store i32 %dec, i32* %k, align 4
  br label %while.cond

while.end:                                        ; preds = %land.end
  %50 = load i32* %k, align 4
  %51 = load i32* %q_deg, align 4
  %cmp61 = icmp sge i32 %50, %51
  br i1 %cmp61, label %if.then63, label %if.end170

if.then63:                                        ; preds = %while.end
  %call64 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([9 x i8]* @.str21, i32 0, i32 0))
  %tobool65 = icmp ne i32 %call64, 0
  br i1 %tobool65, label %if.then66, label %if.end121

if.then66:                                        ; preds = %if.then63
  %52 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool67 = icmp ne %struct._IO_FILE* %52, null
  br i1 %tobool67, label %cond.true68, label %cond.false69

cond.true68:                                      ; preds = %if.then66
  %53 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end70

cond.false69:                                     ; preds = %if.then66
  %54 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end70

cond.end70:                                       ; preds = %cond.false69, %cond.true68
  %cond71 = phi %struct._IO_FILE* [ %53, %cond.true68 ], [ %54, %cond.false69 ]
  %call72 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond71, i8* getelementptr inbounds ([15 x i8]* @.str24, i32 0, i32 0))
  %55 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %56 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool73 = icmp ne %struct._IO_FILE* %56, null
  br i1 %tobool73, label %cond.true74, label %cond.false75

cond.true74:                                      ; preds = %cond.end70
  %57 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end76

cond.false75:                                     ; preds = %cond.end70
  %58 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end76

cond.end76:                                       ; preds = %cond.false75, %cond.true74
  %cond77 = phi %struct._IO_FILE* [ %57, %cond.true74 ], [ %58, %cond.false75 ]
  %call78 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %55, %struct._IO_FILE* %cond77)
  %59 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool79 = icmp ne %struct._IO_FILE* %59, null
  br i1 %tobool79, label %cond.true80, label %cond.false81

cond.true80:                                      ; preds = %cond.end76
  %60 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end82

cond.false81:                                     ; preds = %cond.end76
  %61 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end82

cond.end82:                                       ; preds = %cond.false81, %cond.true80
  %cond83 = phi %struct._IO_FILE* [ %60, %cond.true80 ], [ %61, %cond.false81 ]
  %62 = load i32* %k, align 4
  %call84 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond83, i8* getelementptr inbounds ([15 x i8]* @.str25, i32 0, i32 0), i32 %62)
  %63 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool85 = icmp ne %struct._IO_FILE* %63, null
  br i1 %tobool85, label %cond.true86, label %cond.false87

cond.true86:                                      ; preds = %cond.end82
  %64 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end88

cond.false87:                                     ; preds = %cond.end82
  %65 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end88

cond.end88:                                       ; preds = %cond.false87, %cond.true86
  %cond89 = phi %struct._IO_FILE* [ %64, %cond.true86 ], [ %65, %cond.false87 ]
  %call90 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond89, i8* getelementptr inbounds ([7 x i8]* @.str26, i32 0, i32 0))
  %66 = load %struct.upolynomial_dense_t** %rem.addr, align 8
  %67 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool91 = icmp ne %struct._IO_FILE* %67, null
  br i1 %tobool91, label %cond.true92, label %cond.false93

cond.true92:                                      ; preds = %cond.end88
  %68 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end94

cond.false93:                                     ; preds = %cond.end88
  %69 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end94

cond.end94:                                       ; preds = %cond.false93, %cond.true92
  %cond95 = phi %struct._IO_FILE* [ %68, %cond.true92 ], [ %69, %cond.false93 ]
  %call96 = call i32 @upolynomial_dense_print(%struct.upolynomial_dense_t* %66, %struct._IO_FILE* %cond95)
  %70 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool97 = icmp ne %struct._IO_FILE* %70, null
  br i1 %tobool97, label %cond.true98, label %cond.false99

cond.true98:                                      ; preds = %cond.end94
  %71 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end100

cond.false99:                                     ; preds = %cond.end94
  %72 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end100

cond.end100:                                      ; preds = %cond.false99, %cond.true98
  %cond101 = phi %struct._IO_FILE* [ %71, %cond.true98 ], [ %72, %cond.false99 ]
  %call102 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond101, i8* getelementptr inbounds ([7 x i8]* @.str27, i32 0, i32 0))
  %73 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool103 = icmp ne %struct._IO_FILE* %73, null
  br i1 %tobool103, label %cond.true104, label %cond.false105

cond.true104:                                     ; preds = %cond.end100
  %74 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end106

cond.false105:                                    ; preds = %cond.end100
  %75 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end106

cond.end106:                                      ; preds = %cond.false105, %cond.true104
  %cond107 = phi %struct._IO_FILE* [ %74, %cond.true104 ], [ %75, %cond.false105 ]
  %call108 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond107, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  %76 = load %struct.upolynomial_dense_t** %div.addr, align 8
  %77 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool109 = icmp ne %struct._IO_FILE* %77, null
  br i1 %tobool109, label %cond.true110, label %cond.false111

cond.true110:                                     ; preds = %cond.end106
  %78 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end112

cond.false111:                                    ; preds = %cond.end106
  %79 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end112

cond.end112:                                      ; preds = %cond.false111, %cond.true110
  %cond113 = phi %struct._IO_FILE* [ %78, %cond.true110 ], [ %79, %cond.false111 ]
  %call114 = call i32 @upolynomial_dense_print(%struct.upolynomial_dense_t* %76, %struct._IO_FILE* %cond113)
  %80 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool115 = icmp ne %struct._IO_FILE* %80, null
  br i1 %tobool115, label %cond.true116, label %cond.false117

cond.true116:                                     ; preds = %cond.end112
  %81 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end118

cond.false117:                                    ; preds = %cond.end112
  %82 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end118

cond.end118:                                      ; preds = %cond.false117, %cond.true116
  %cond119 = phi %struct._IO_FILE* [ %81, %cond.true116 ], [ %82, %cond.false117 ]
  %call120 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond119, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end121

if.end121:                                        ; preds = %cond.end118, %if.then63
  %83 = load i32* %exact.addr, align 4
  %tobool122 = icmp ne i32 %83, 0
  br i1 %tobool122, label %lor.lhs.false, label %cond.true129

lor.lhs.false:                                    ; preds = %if.end121
  %84 = load %struct.lp_int_ring_t** %K45, align 8
  %85 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call123 = call %struct.__mpz_struct* @lp_upolynomial_lead_coeff(%struct.lp_upolynomial_struct* %85)
  %86 = load %struct.upolynomial_dense_t** %rem.addr, align 8
  %coefficients124 = getelementptr inbounds %struct.upolynomial_dense_t* %86, i32 0, i32 2
  %87 = load %struct.__mpz_struct** %coefficients124, align 8
  %88 = load i32* %k, align 4
  %idx.ext125 = sext i32 %88 to i64
  %add.ptr126 = getelementptr inbounds %struct.__mpz_struct* %87, i64 %idx.ext125
  %call127 = call i32 @integer_divides(%struct.lp_int_ring_t* %84, %struct.__mpz_struct* %call123, %struct.__mpz_struct* %add.ptr126)
  %tobool128 = icmp ne i32 %call127, 0
  br i1 %tobool128, label %cond.true129, label %cond.false130

cond.true129:                                     ; preds = %lor.lhs.false, %if.end121
  br label %cond.end131

cond.false130:                                    ; preds = %lor.lhs.false
  call void @__assert_fail(i8* getelementptr inbounds ([82 x i8]* @.str28, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 600, i8* getelementptr inbounds ([135 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_general, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end131

cond.end131:                                      ; preds = %89, %cond.true129
  %90 = load i32* %k, align 4
  %91 = load i32* %q_deg, align 4
  %sub132 = sub nsw i32 %90, %91
  %conv133 = sext i32 %sub132 to i64
  %degree = getelementptr inbounds %struct.umonomial_struct* %m, i32 0, i32 0
  store i64 %conv133, i64* %degree, align 8
  %92 = load i32* %exact.addr, align 4
  %tobool134 = icmp ne i32 %92, 0
  br i1 %tobool134, label %if.then135, label %if.else

if.then135:                                       ; preds = %cond.end131
  %93 = load %struct.lp_int_ring_t** %K45, align 8
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %m, i32 0, i32 1
  %94 = load %struct.upolynomial_dense_t** %rem.addr, align 8
  %coefficients136 = getelementptr inbounds %struct.upolynomial_dense_t* %94, i32 0, i32 2
  %95 = load %struct.__mpz_struct** %coefficients136, align 8
  %96 = load i32* %k, align 4
  %idx.ext137 = sext i32 %96 to i64
  %add.ptr138 = getelementptr inbounds %struct.__mpz_struct* %95, i64 %idx.ext137
  %97 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call139 = call %struct.__mpz_struct* @lp_upolynomial_lead_coeff(%struct.lp_upolynomial_struct* %97)
  call void @integer_div_exact(%struct.lp_int_ring_t* %93, %struct.__mpz_struct* %coefficient, %struct.__mpz_struct* %add.ptr138, %struct.__mpz_struct* %call139)
  br label %if.end145

if.else:                                          ; preds = %cond.end131
  %coefficient140 = getelementptr inbounds %struct.umonomial_struct* %m, i32 0, i32 1
  %98 = load %struct.upolynomial_dense_t** %rem.addr, align 8
  %coefficients141 = getelementptr inbounds %struct.upolynomial_dense_t* %98, i32 0, i32 2
  %99 = load %struct.__mpz_struct** %coefficients141, align 8
  %100 = load i32* %k, align 4
  %idx.ext142 = sext i32 %100 to i64
  %add.ptr143 = getelementptr inbounds %struct.__mpz_struct* %99, i64 %idx.ext142
  call void @integer_assign(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %coefficient140, %struct.__mpz_struct* %add.ptr143)
  %101 = load %struct.upolynomial_dense_t** %rem.addr, align 8
  %102 = load %struct.lp_int_ring_t** %K45, align 8
  %103 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call144 = call %struct.__mpz_struct* @lp_upolynomial_lead_coeff(%struct.lp_upolynomial_struct* %103)
  call void @upolynomial_dense_mult_c(%struct.upolynomial_dense_t* %101, %struct.lp_int_ring_t* %102, %struct.__mpz_struct* %call144)
  br label %if.end145

if.end145:                                        ; preds = %if.else, %if.then135
  %104 = load %struct.lp_int_ring_t** %K45, align 8
  %coefficient146 = getelementptr inbounds %struct.umonomial_struct* %m, i32 0, i32 1
  %call147 = call i32 @integer_sgn(%struct.lp_int_ring_t* %104, %struct.__mpz_struct* %coefficient146)
  %tobool148 = icmp ne i32 %call147, 0
  br i1 %tobool148, label %if.then149, label %if.end150

if.then149:                                       ; preds = %if.end145
  %105 = load %struct.upolynomial_dense_t** %rem.addr, align 8
  %106 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  call void @upolynomial_dense_sub_mult_p_mon(%struct.upolynomial_dense_t* %105, %struct.lp_upolynomial_struct* %106, %struct.umonomial_struct* %m)
  br label %if.end150

if.end150:                                        ; preds = %if.then149, %if.end145
  %107 = load i32* %exact.addr, align 4
  %tobool151 = icmp ne i32 %107, 0
  br i1 %tobool151, label %if.then156, label %lor.lhs.false152

lor.lhs.false152:                                 ; preds = %if.end150
  %coefficient153 = getelementptr inbounds %struct.umonomial_struct* %m, i32 0, i32 1
  %call154 = call i32 @integer_sgn(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %coefficient153)
  %tobool155 = icmp ne i32 %call154, 0
  br i1 %tobool155, label %if.else160, label %if.then156

if.then156:                                       ; preds = %lor.lhs.false152, %if.end150
  %degree157 = getelementptr inbounds %struct.umonomial_struct* %m, i32 0, i32 0
  %108 = load i64* %degree157, align 8
  %109 = load %struct.upolynomial_dense_t** %div.addr, align 8
  %coefficients158 = getelementptr inbounds %struct.upolynomial_dense_t* %109, i32 0, i32 2
  %110 = load %struct.__mpz_struct** %coefficients158, align 8
  %arrayidx = getelementptr inbounds %struct.__mpz_struct* %110, i64 %108
  %coefficient159 = getelementptr inbounds %struct.umonomial_struct* %m, i32 0, i32 1
  call void @integer_swap(%struct.__mpz_struct* %arrayidx, %struct.__mpz_struct* %coefficient159)
  br label %if.end168

if.else160:                                       ; preds = %lor.lhs.false152
  %111 = load %struct.lp_int_ring_t** %K45, align 8
  %112 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call161 = call %struct.__mpz_struct* @lp_upolynomial_lead_coeff(%struct.lp_upolynomial_struct* %112)
  %degree162 = getelementptr inbounds %struct.umonomial_struct* %m, i32 0, i32 0
  %113 = load i64* %degree162, align 8
  %conv163 = trunc i64 %113 to i32
  call void @integer_pow(%struct.lp_int_ring_t* %111, %struct.__mpz_struct* %adjust, %struct.__mpz_struct* %call161, i32 %conv163)
  %114 = load %struct.lp_int_ring_t** %K45, align 8
  %degree164 = getelementptr inbounds %struct.umonomial_struct* %m, i32 0, i32 0
  %115 = load i64* %degree164, align 8
  %116 = load %struct.upolynomial_dense_t** %div.addr, align 8
  %coefficients165 = getelementptr inbounds %struct.upolynomial_dense_t* %116, i32 0, i32 2
  %117 = load %struct.__mpz_struct** %coefficients165, align 8
  %arrayidx166 = getelementptr inbounds %struct.__mpz_struct* %117, i64 %115
  %coefficient167 = getelementptr inbounds %struct.umonomial_struct* %m, i32 0, i32 1
  call void @integer_mul(%struct.lp_int_ring_t* %114, %struct.__mpz_struct* %arrayidx166, %struct.__mpz_struct* %coefficient167, %struct.__mpz_struct* %adjust)
  br label %if.end168

if.end168:                                        ; preds = %if.else160, %if.then156
  %118 = load %struct.upolynomial_dense_t** %div.addr, align 8
  %degree169 = getelementptr inbounds %struct.umonomial_struct* %m, i32 0, i32 0
  %119 = load i64* %degree169, align 8
  call void @upolynomial_dense_touch(%struct.upolynomial_dense_t* %118, i64 %119)
  br label %if.end170

if.end170:                                        ; preds = %if.end168, %while.end
  br label %for.inc

for.inc:                                          ; preds = %if.end170
  %120 = load i32* %k, align 4
  %dec171 = add nsw i32 %120, -1
  store i32 %dec171, i32* %k, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  call void @integer_destruct(%struct.__mpz_struct* %adjust)
  call void @umonomial_destruct(%struct.umonomial_struct* %m)
  ret void
}

declare void @upolynomial_dense_construct_p(%struct.upolynomial_dense_t*, i64, %struct.lp_upolynomial_struct*) #3

declare i32 @upolynomial_dense_print(%struct.upolynomial_dense_t*, %struct._IO_FILE*) #3

; Function Attrs: inlinehint nounwind uwtable
define internal i32 @integer_divides(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %a, %struct.__mpz_struct* %b) #4 {
entry:
  %retval = alloca i32, align 4
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %a.addr = alloca %struct.__mpz_struct*, align 8
  %b.addr = alloca %struct.__mpz_struct*, align 8
  %gcd = alloca %struct.__mpz_struct, align 8
  %divides = alloca i32, align 4
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %a, %struct.__mpz_struct** %a.addr, align 8
  store %struct.__mpz_struct* %b, %struct.__mpz_struct** %b.addr, align 8
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %1 = load %struct.__mpz_struct** %a.addr, align 8
  %call = call i32 @integer_in_ring(%struct.lp_int_ring_t* %0, %struct.__mpz_struct* %1)
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %land.lhs.true, label %cond.false

land.lhs.true:                                    ; preds = %entry
  %2 = load %struct.lp_int_ring_t** %K.addr, align 8
  %3 = load %struct.__mpz_struct** %b.addr, align 8
  %call1 = call i32 @integer_in_ring(%struct.lp_int_ring_t* %2, %struct.__mpz_struct* %3)
  %tobool2 = icmp ne i32 %call1, 0
  br i1 %tobool2, label %cond.true, label %cond.false

cond.true:                                        ; preds = %land.lhs.true
  br label %cond.end

cond.false:                                       ; preds = %land.lhs.true, %entry
  call void @__assert_fail(i8* getelementptr inbounds ([47 x i8]* @.str73, i32 0, i32 0), i8* getelementptr inbounds ([52 x i8]* @.str70, i32 0, i32 0), i32 236, i8* getelementptr inbounds ([81 x i8]* @__PRETTY_FUNCTION__.integer_divides, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %4, %cond.true
  %5 = load %struct.lp_int_ring_t** %K.addr, align 8
  %tobool3 = icmp ne %struct.lp_int_ring_t* %5, null
  br i1 %tobool3, label %if.then, label %if.else

if.then:                                          ; preds = %cond.end
  %6 = load %struct.lp_int_ring_t** %K.addr, align 8
  %is_prime = getelementptr inbounds %struct.lp_int_ring_t* %6, i32 0, i32 1
  %7 = load i32* %is_prime, align 4
  %tobool4 = icmp ne i32 %7, 0
  br i1 %tobool4, label %if.then5, label %if.end

if.then5:                                         ; preds = %if.then
  %8 = load %struct.__mpz_struct** %a.addr, align 8
  %call6 = call i32 @integer_sgn(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %8)
  store i32 %call6, i32* %retval
  br label %return

if.end:                                           ; preds = %if.then
  call void @__gmpz_init(%struct.__mpz_struct* %gcd)
  %9 = load %struct.__mpz_struct** %a.addr, align 8
  %10 = load %struct.lp_int_ring_t** %K.addr, align 8
  %M = getelementptr inbounds %struct.lp_int_ring_t* %10, i32 0, i32 2
  call void @__gmpz_gcd(%struct.__mpz_struct* %gcd, %struct.__mpz_struct* %9, %struct.__mpz_struct* %M)
  %11 = load %struct.__mpz_struct** %b.addr, align 8
  %call7 = call i32 @__gmpz_divisible_p(%struct.__mpz_struct* %11, %struct.__mpz_struct* %gcd) #8
  store i32 %call7, i32* %divides, align 4
  call void @__gmpz_clear(%struct.__mpz_struct* %gcd)
  %12 = load i32* %divides, align 4
  store i32 %12, i32* %retval
  br label %return

if.else:                                          ; preds = %cond.end
  %13 = load %struct.__mpz_struct** %b.addr, align 8
  %14 = load %struct.__mpz_struct** %a.addr, align 8
  %call8 = call i32 @__gmpz_divisible_p(%struct.__mpz_struct* %13, %struct.__mpz_struct* %14) #8
  store i32 %call8, i32* %retval
  br label %return

return:                                           ; preds = %if.else, %if.end, %if.then5
  %15 = load i32* %retval
  ret i32 %15
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_div_exact(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %div, %struct.__mpz_struct* %a, %struct.__mpz_struct* %b) #4 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %div.addr = alloca %struct.__mpz_struct*, align 8
  %a.addr = alloca %struct.__mpz_struct*, align 8
  %b.addr = alloca %struct.__mpz_struct*, align 8
  %c1 = alloca %struct.__mpz_struct, align 8
  %c2 = alloca %struct.__mpz_struct, align 8
  %gcd = alloca %struct.__mpz_struct, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %div, %struct.__mpz_struct** %div.addr, align 8
  store %struct.__mpz_struct* %a, %struct.__mpz_struct** %a.addr, align 8
  store %struct.__mpz_struct* %b, %struct.__mpz_struct** %b.addr, align 8
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %1 = load %struct.__mpz_struct** %a.addr, align 8
  %call = call i32 @integer_in_ring(%struct.lp_int_ring_t* %0, %struct.__mpz_struct* %1)
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %land.lhs.true, label %cond.false

land.lhs.true:                                    ; preds = %entry
  %2 = load %struct.lp_int_ring_t** %K.addr, align 8
  %3 = load %struct.__mpz_struct** %b.addr, align 8
  %call1 = call i32 @integer_in_ring(%struct.lp_int_ring_t* %2, %struct.__mpz_struct* %3)
  %tobool2 = icmp ne i32 %call1, 0
  br i1 %tobool2, label %cond.true, label %cond.false

cond.true:                                        ; preds = %land.lhs.true
  br label %cond.end

cond.false:                                       ; preds = %land.lhs.true, %entry
  call void @__assert_fail(i8* getelementptr inbounds ([47 x i8]* @.str73, i32 0, i32 0), i8* getelementptr inbounds ([52 x i8]* @.str70, i32 0, i32 0), i32 382, i8* getelementptr inbounds ([100 x i8]* @__PRETTY_FUNCTION__.integer_div_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %4, %cond.true
  %5 = load %struct.lp_int_ring_t** %K.addr, align 8
  %tobool3 = icmp ne %struct.lp_int_ring_t* %5, null
  br i1 %tobool3, label %if.then, label %if.else

if.then:                                          ; preds = %cond.end
  call void @__gmpz_init(%struct.__mpz_struct* %c1)
  call void @__gmpz_init(%struct.__mpz_struct* %c2)
  call void @__gmpz_init(%struct.__mpz_struct* %gcd)
  %6 = load %struct.__mpz_struct** %b.addr, align 8
  %7 = load %struct.lp_int_ring_t** %K.addr, align 8
  %M = getelementptr inbounds %struct.lp_int_ring_t* %7, i32 0, i32 2
  call void @__gmpz_gcdext(%struct.__mpz_struct* %gcd, %struct.__mpz_struct* %c1, %struct.__mpz_struct* %c2, %struct.__mpz_struct* %6, %struct.__mpz_struct* %M)
  %8 = load %struct.__mpz_struct** %a.addr, align 8
  %call4 = call i32 @__gmpz_divisible_p(%struct.__mpz_struct* %8, %struct.__mpz_struct* %gcd) #8
  %tobool5 = icmp ne i32 %call4, 0
  br i1 %tobool5, label %cond.true6, label %cond.false7

cond.true6:                                       ; preds = %if.then
  br label %cond.end8

cond.false7:                                      ; preds = %if.then
  call void @__assert_fail(i8* getelementptr inbounds ([28 x i8]* @.str74, i32 0, i32 0), i8* getelementptr inbounds ([52 x i8]* @.str70, i32 0, i32 0), i32 390, i8* getelementptr inbounds ([100 x i8]* @__PRETTY_FUNCTION__.integer_div_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end8

cond.end8:                                        ; preds = %9, %cond.true6
  %10 = load %struct.__mpz_struct** %a.addr, align 8
  call void @__gmpz_divexact(%struct.__mpz_struct* %c2, %struct.__mpz_struct* %10, %struct.__mpz_struct* %gcd)
  %11 = load %struct.__mpz_struct** %div.addr, align 8
  call void @__gmpz_mul(%struct.__mpz_struct* %11, %struct.__mpz_struct* %c1, %struct.__mpz_struct* %c2)
  call void @__gmpz_clear(%struct.__mpz_struct* %c1)
  call void @__gmpz_clear(%struct.__mpz_struct* %c2)
  call void @__gmpz_clear(%struct.__mpz_struct* %gcd)
  %12 = load %struct.lp_int_ring_t** %K.addr, align 8
  %13 = load %struct.__mpz_struct** %div.addr, align 8
  call void @integer_ring_normalize(%struct.lp_int_ring_t* %12, %struct.__mpz_struct* %13)
  br label %if.end

if.else:                                          ; preds = %cond.end
  %14 = load %struct.__mpz_struct** %div.addr, align 8
  %15 = load %struct.__mpz_struct** %a.addr, align 8
  %16 = load %struct.__mpz_struct** %b.addr, align 8
  call void @__gmpz_divexact(%struct.__mpz_struct* %14, %struct.__mpz_struct* %15, %struct.__mpz_struct* %16)
  br label %if.end

if.end:                                           ; preds = %if.else, %cond.end8
  ret void
}

declare void @upolynomial_dense_mult_c(%struct.upolynomial_dense_t*, %struct.lp_int_ring_t*, %struct.__mpz_struct*) #3

declare void @upolynomial_dense_sub_mult_p_mon(%struct.upolynomial_dense_t*, %struct.lp_upolynomial_struct*, %struct.umonomial_struct*) #3

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_swap(%struct.__mpz_struct* %a, %struct.__mpz_struct* %b) #4 {
entry:
  %a.addr = alloca %struct.__mpz_struct*, align 8
  %b.addr = alloca %struct.__mpz_struct*, align 8
  store %struct.__mpz_struct* %a, %struct.__mpz_struct** %a.addr, align 8
  store %struct.__mpz_struct* %b, %struct.__mpz_struct** %b.addr, align 8
  %0 = load %struct.__mpz_struct** %a.addr, align 8
  %1 = load %struct.__mpz_struct** %b.addr, align 8
  call void @__gmpz_swap(%struct.__mpz_struct* %0, %struct.__mpz_struct* %1)
  ret void
}

declare void @upolynomial_dense_touch(%struct.upolynomial_dense_t*, i64) #3

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_div_degrees(%struct.lp_upolynomial_struct* %p, i64 %a) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %a.addr = alloca i64, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  %i = alloca i64, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store i64 %a, i64* %a.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([25 x i8]* @.str29, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %10 = load i64* %a.addr, align 8
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([8 x i8]* @.str30, i32 0, i32 0), i64 %10)
  br label %if.end

if.end:                                           ; preds = %cond.end12, %entry
  %11 = load i64* %a.addr, align 8
  %cmp = icmp ugt i64 %11, 1
  br i1 %cmp, label %cond.true15, label %cond.false16

cond.true15:                                      ; preds = %if.end
  br label %cond.end17

cond.false16:                                     ; preds = %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([6 x i8]* @.str31, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 643, i8* getelementptr inbounds ([79 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_degrees, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end17

cond.end17:                                       ; preds = %12, %cond.true15
  %13 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call18 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy(%struct.lp_upolynomial_struct* %13)
  store %struct.lp_upolynomial_struct* %call18, %struct.lp_upolynomial_struct** %result, align 8
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %cond.end17
  %14 = load i64* %i, align 8
  %15 = load %struct.lp_upolynomial_struct** %result, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %15, i32 0, i32 1
  %16 = load i64* %size, align 8
  %cmp19 = icmp ult i64 %14, %16
  br i1 %cmp19, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %17 = load i64* %i, align 8
  %18 = load %struct.lp_upolynomial_struct** %result, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %18, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %17
  %degree = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 0
  %19 = load i64* %degree, align 8
  %20 = load i64* %a.addr, align 8
  %rem = urem i64 %19, %20
  %cmp20 = icmp eq i64 %rem, 0
  br i1 %cmp20, label %cond.true21, label %cond.false22

cond.true21:                                      ; preds = %for.body
  br label %cond.end23

cond.false22:                                     ; preds = %for.body
  call void @__assert_fail(i8* getelementptr inbounds ([37 x i8]* @.str32, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 648, i8* getelementptr inbounds ([79 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_degrees, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end23

cond.end23:                                       ; preds = %21, %cond.true21
  %22 = load i64* %a.addr, align 8
  %23 = load i64* %i, align 8
  %24 = load %struct.lp_upolynomial_struct** %result, align 8
  %monomials24 = getelementptr inbounds %struct.lp_upolynomial_struct* %24, i32 0, i32 2
  %arrayidx25 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials24, i32 0, i64 %23
  %degree26 = getelementptr inbounds %struct.umonomial_struct* %arrayidx25, i32 0, i32 0
  %25 = load i64* %degree26, align 8
  %div = udiv i64 %25, %22
  store i64 %div, i64* %degree26, align 8
  br label %for.inc

for.inc:                                          ; preds = %cond.end23
  %26 = load i64* %i, align 8
  %inc = add i64 %26, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %call27 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool28 = icmp ne i32 %call27, 0
  br i1 %tobool28, label %if.then29, label %if.end60

if.then29:                                        ; preds = %for.end
  %27 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool30 = icmp ne %struct._IO_FILE* %27, null
  br i1 %tobool30, label %cond.true31, label %cond.false32

cond.true31:                                      ; preds = %if.then29
  %28 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end33

cond.false32:                                     ; preds = %if.then29
  %29 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end33

cond.end33:                                       ; preds = %cond.false32, %cond.true31
  %cond34 = phi %struct._IO_FILE* [ %28, %cond.true31 ], [ %29, %cond.false32 ]
  %call35 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond34, i8* getelementptr inbounds ([25 x i8]* @.str29, i32 0, i32 0))
  %30 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %31 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool36 = icmp ne %struct._IO_FILE* %31, null
  br i1 %tobool36, label %cond.true37, label %cond.false38

cond.true37:                                      ; preds = %cond.end33
  %32 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end39

cond.false38:                                     ; preds = %cond.end33
  %33 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end39

cond.end39:                                       ; preds = %cond.false38, %cond.true37
  %cond40 = phi %struct._IO_FILE* [ %32, %cond.true37 ], [ %33, %cond.false38 ]
  %call41 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %30, %struct._IO_FILE* %cond40)
  %34 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool42 = icmp ne %struct._IO_FILE* %34, null
  br i1 %tobool42, label %cond.true43, label %cond.false44

cond.true43:                                      ; preds = %cond.end39
  %35 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end45

cond.false44:                                     ; preds = %cond.end39
  %36 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end45

cond.end45:                                       ; preds = %cond.false44, %cond.true43
  %cond46 = phi %struct._IO_FILE* [ %35, %cond.true43 ], [ %36, %cond.false44 ]
  %37 = load i64* %a.addr, align 8
  %call47 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond46, i8* getelementptr inbounds ([10 x i8]* @.str33, i32 0, i32 0), i64 %37)
  %38 = load %struct.lp_upolynomial_struct** %result, align 8
  %39 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool48 = icmp ne %struct._IO_FILE* %39, null
  br i1 %tobool48, label %cond.true49, label %cond.false50

cond.true49:                                      ; preds = %cond.end45
  %40 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end51

cond.false50:                                     ; preds = %cond.end45
  %41 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end51

cond.end51:                                       ; preds = %cond.false50, %cond.true49
  %cond52 = phi %struct._IO_FILE* [ %40, %cond.true49 ], [ %41, %cond.false50 ]
  %call53 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %38, %struct._IO_FILE* %cond52)
  %42 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool54 = icmp ne %struct._IO_FILE* %42, null
  br i1 %tobool54, label %cond.true55, label %cond.false56

cond.true55:                                      ; preds = %cond.end51
  %43 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end57

cond.false56:                                     ; preds = %cond.end51
  %44 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end57

cond.end57:                                       ; preds = %cond.false56, %cond.true55
  %cond58 = phi %struct._IO_FILE* [ %43, %cond.true55 ], [ %44, %cond.false56 ]
  %call59 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond58, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end60

if.end60:                                         ; preds = %cond.end57, %for.end
  %45 = load %struct.lp_upolynomial_struct** %result, align 8
  ret %struct.lp_upolynomial_struct* %45
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_div_exact(%struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  %K48 = alloca %struct.lp_int_ring_t*, align 8
  %rem_buffer = alloca %struct.upolynomial_dense_t, align 8
  %div_buffer = alloca %struct.upolynomial_dense_t, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([23 x i8]* @.str34, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %10 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %11 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool15 = icmp ne %struct._IO_FILE* %11, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %cond.end12
  %12 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end18

cond.false17:                                     ; preds = %cond.end12
  %13 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false17, %cond.true16
  %cond19 = phi %struct._IO_FILE* [ %12, %cond.true16 ], [ %13, %cond.false17 ]
  %call20 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %10, %struct._IO_FILE* %cond19)
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool21 = icmp ne %struct._IO_FILE* %14, null
  br i1 %tobool21, label %cond.true22, label %cond.false23

cond.true22:                                      ; preds = %cond.end18
  %15 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end24

cond.false23:                                     ; preds = %cond.end18
  %16 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end24

cond.end24:                                       ; preds = %cond.false23, %cond.true22
  %cond25 = phi %struct._IO_FILE* [ %15, %cond.true22 ], [ %16, %cond.false23 ]
  %call26 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond25, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end24, %entry
  %17 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool27 = icmp ne %struct.lp_upolynomial_struct* %17, null
  br i1 %tobool27, label %cond.true28, label %cond.false29

cond.true28:                                      ; preds = %if.end
  br label %cond.end30

cond.false29:                                     ; preds = %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 665, i8* getelementptr inbounds ([95 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end30

cond.end30:                                       ; preds = %18, %cond.true28
  %19 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %tobool31 = icmp ne %struct.lp_upolynomial_struct* %19, null
  br i1 %tobool31, label %cond.true32, label %cond.false33

cond.true32:                                      ; preds = %cond.end30
  br label %cond.end34

cond.false33:                                     ; preds = %cond.end30
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str4, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 666, i8* getelementptr inbounds ([95 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end34

cond.end34:                                       ; preds = %20, %cond.true32
  %21 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %21, i32 0, i32 0
  %22 = load %struct.lp_int_ring_t** %K, align 8
  %23 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %K35 = getelementptr inbounds %struct.lp_upolynomial_struct* %23, i32 0, i32 0
  %24 = load %struct.lp_int_ring_t** %K35, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %22, %24
  br i1 %cmp, label %cond.true36, label %cond.false37

cond.true36:                                      ; preds = %cond.end34
  br label %cond.end38

cond.false37:                                     ; preds = %cond.end34
  call void @__assert_fail(i8* getelementptr inbounds ([13 x i8]* @.str5, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 667, i8* getelementptr inbounds ([95 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end38

cond.end38:                                       ; preds = %25, %cond.true36
  %26 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call39 = call i32 @lp_upolynomial_is_zero(%struct.lp_upolynomial_struct* %26)
  %tobool40 = icmp ne i32 %call39, 0
  br i1 %tobool40, label %cond.false42, label %cond.true41

cond.true41:                                      ; preds = %cond.end38
  br label %cond.end43

cond.false42:                                     ; preds = %cond.end38
  call void @__assert_fail(i8* getelementptr inbounds ([27 x i8]* @.str35, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 668, i8* getelementptr inbounds ([95 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end43

cond.end43:                                       ; preds = %27, %cond.true41
  store %struct.lp_upolynomial_struct* null, %struct.lp_upolynomial_struct** %result, align 8
  %28 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call44 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %28)
  %29 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call45 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %29)
  %cmp46 = icmp uge i64 %call44, %call45
  br i1 %cmp46, label %if.then47, label %if.else

if.then47:                                        ; preds = %cond.end43
  %30 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K49 = getelementptr inbounds %struct.lp_upolynomial_struct* %30, i32 0, i32 0
  %31 = load %struct.lp_int_ring_t** %K49, align 8
  store %struct.lp_int_ring_t* %31, %struct.lp_int_ring_t** %K48, align 8
  %32 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %33 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  call void @lp_upolynomial_div_general(%struct.lp_upolynomial_struct* %32, %struct.lp_upolynomial_struct* %33, %struct.upolynomial_dense_t* %div_buffer, %struct.upolynomial_dense_t* %rem_buffer, i32 1)
  %34 = load %struct.lp_int_ring_t** %K48, align 8
  %call50 = call %struct.lp_upolynomial_struct* @upolynomial_dense_to_upolynomial(%struct.upolynomial_dense_t* %div_buffer, %struct.lp_int_ring_t* %34)
  store %struct.lp_upolynomial_struct* %call50, %struct.lp_upolynomial_struct** %result, align 8
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %div_buffer)
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %rem_buffer)
  br label %if.end53

if.else:                                          ; preds = %cond.end43
  %35 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K51 = getelementptr inbounds %struct.lp_upolynomial_struct* %35, i32 0, i32 0
  %36 = load %struct.lp_int_ring_t** %K51, align 8
  %call52 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_power(%struct.lp_int_ring_t* %36, i64 0, i64 0)
  store %struct.lp_upolynomial_struct* %call52, %struct.lp_upolynomial_struct** %result, align 8
  br label %if.end53

if.end53:                                         ; preds = %if.else, %if.then47
  %call54 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool55 = icmp ne i32 %call54, 0
  br i1 %tobool55, label %if.then56, label %if.end99

if.then56:                                        ; preds = %if.end53
  %37 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool57 = icmp ne %struct._IO_FILE* %37, null
  br i1 %tobool57, label %cond.true58, label %cond.false59

cond.true58:                                      ; preds = %if.then56
  %38 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end60

cond.false59:                                     ; preds = %if.then56
  %39 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end60

cond.end60:                                       ; preds = %cond.false59, %cond.true58
  %cond61 = phi %struct._IO_FILE* [ %38, %cond.true58 ], [ %39, %cond.false59 ]
  %call62 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond61, i8* getelementptr inbounds ([23 x i8]* @.str34, i32 0, i32 0))
  %40 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %41 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool63 = icmp ne %struct._IO_FILE* %41, null
  br i1 %tobool63, label %cond.true64, label %cond.false65

cond.true64:                                      ; preds = %cond.end60
  %42 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end66

cond.false65:                                     ; preds = %cond.end60
  %43 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end66

cond.end66:                                       ; preds = %cond.false65, %cond.true64
  %cond67 = phi %struct._IO_FILE* [ %42, %cond.true64 ], [ %43, %cond.false65 ]
  %call68 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %40, %struct._IO_FILE* %cond67)
  %44 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool69 = icmp ne %struct._IO_FILE* %44, null
  br i1 %tobool69, label %cond.true70, label %cond.false71

cond.true70:                                      ; preds = %cond.end66
  %45 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end72

cond.false71:                                     ; preds = %cond.end66
  %46 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end72

cond.end72:                                       ; preds = %cond.false71, %cond.true70
  %cond73 = phi %struct._IO_FILE* [ %45, %cond.true70 ], [ %46, %cond.false71 ]
  %call74 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond73, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %47 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %48 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool75 = icmp ne %struct._IO_FILE* %48, null
  br i1 %tobool75, label %cond.true76, label %cond.false77

cond.true76:                                      ; preds = %cond.end72
  %49 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end78

cond.false77:                                     ; preds = %cond.end72
  %50 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end78

cond.end78:                                       ; preds = %cond.false77, %cond.true76
  %cond79 = phi %struct._IO_FILE* [ %49, %cond.true76 ], [ %50, %cond.false77 ]
  %call80 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %47, %struct._IO_FILE* %cond79)
  %51 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool81 = icmp ne %struct._IO_FILE* %51, null
  br i1 %tobool81, label %cond.true82, label %cond.false83

cond.true82:                                      ; preds = %cond.end78
  %52 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end84

cond.false83:                                     ; preds = %cond.end78
  %53 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end84

cond.end84:                                       ; preds = %cond.false83, %cond.true82
  %cond85 = phi %struct._IO_FILE* [ %52, %cond.true82 ], [ %53, %cond.false83 ]
  %call86 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond85, i8* getelementptr inbounds ([5 x i8]* @.str10, i32 0, i32 0))
  %54 = load %struct.lp_upolynomial_struct** %result, align 8
  %55 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool87 = icmp ne %struct._IO_FILE* %55, null
  br i1 %tobool87, label %cond.true88, label %cond.false89

cond.true88:                                      ; preds = %cond.end84
  %56 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end90

cond.false89:                                     ; preds = %cond.end84
  %57 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end90

cond.end90:                                       ; preds = %cond.false89, %cond.true88
  %cond91 = phi %struct._IO_FILE* [ %56, %cond.true88 ], [ %57, %cond.false89 ]
  %call92 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %54, %struct._IO_FILE* %cond91)
  %58 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool93 = icmp ne %struct._IO_FILE* %58, null
  br i1 %tobool93, label %cond.true94, label %cond.false95

cond.true94:                                      ; preds = %cond.end90
  %59 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end96

cond.false95:                                     ; preds = %cond.end90
  %60 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end96

cond.end96:                                       ; preds = %cond.false95, %cond.true94
  %cond97 = phi %struct._IO_FILE* [ %59, %cond.true94 ], [ %60, %cond.false95 ]
  %call98 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond97, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end99

if.end99:                                         ; preds = %cond.end96, %if.end53
  %61 = load %struct.lp_upolynomial_struct** %result, align 8
  ret %struct.lp_upolynomial_struct* %61
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_div_exact_c(%struct.lp_upolynomial_struct* %p, %struct.__mpz_struct* %c) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %c.addr = alloca %struct.__mpz_struct*, align 8
  %K = alloca %struct.lp_int_ring_t*, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  %i = alloca i64, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([23 x i8]* @.str34, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %10 = load %struct.__mpz_struct** %c.addr, align 8
  %11 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool15 = icmp ne %struct._IO_FILE* %11, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %cond.end12
  %12 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end18

cond.false17:                                     ; preds = %cond.end12
  %13 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false17, %cond.true16
  %cond19 = phi %struct._IO_FILE* [ %12, %cond.true16 ], [ %13, %cond.false17 ]
  %call20 = call i32 @integer_print(%struct.__mpz_struct* %10, %struct._IO_FILE* %cond19)
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool21 = icmp ne %struct._IO_FILE* %14, null
  br i1 %tobool21, label %cond.true22, label %cond.false23

cond.true22:                                      ; preds = %cond.end18
  %15 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end24

cond.false23:                                     ; preds = %cond.end18
  %16 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end24

cond.end24:                                       ; preds = %cond.false23, %cond.true22
  %cond25 = phi %struct._IO_FILE* [ %15, %cond.true22 ], [ %16, %cond.false23 ]
  %call26 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond25, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end24, %entry
  %17 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K27 = getelementptr inbounds %struct.lp_upolynomial_struct* %17, i32 0, i32 0
  %18 = load %struct.lp_int_ring_t** %K27, align 8
  store %struct.lp_int_ring_t* %18, %struct.lp_int_ring_t** %K, align 8
  %19 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool28 = icmp ne %struct.lp_upolynomial_struct* %19, null
  br i1 %tobool28, label %cond.true29, label %cond.false30

cond.true29:                                      ; preds = %if.end
  br label %cond.end31

cond.false30:                                     ; preds = %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 702, i8* getelementptr inbounds ([93 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_exact_c, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end31

cond.end31:                                       ; preds = %20, %cond.true29
  %21 = load %struct.lp_int_ring_t** %K, align 8
  %22 = load %struct.__mpz_struct** %c.addr, align 8
  %call32 = call i32 @integer_cmp_int(%struct.lp_int_ring_t* %21, %struct.__mpz_struct* %22, i64 0)
  %tobool33 = icmp ne i32 %call32, 0
  br i1 %tobool33, label %cond.true34, label %cond.false35

cond.true34:                                      ; preds = %cond.end31
  br label %cond.end36

cond.false35:                                     ; preds = %cond.end31
  call void @__assert_fail(i8* getelementptr inbounds ([25 x i8]* @.str36, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 703, i8* getelementptr inbounds ([93 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_exact_c, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end36

cond.end36:                                       ; preds = %23, %cond.true34
  %24 = load %struct.lp_int_ring_t** %K, align 8
  %25 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %25, i32 0, i32 1
  %26 = load i64* %size, align 8
  %call37 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_empty(%struct.lp_int_ring_t* %24, i64 %26)
  store %struct.lp_upolynomial_struct* %call37, %struct.lp_upolynomial_struct** %result, align 8
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %cond.end36
  %27 = load i64* %i, align 8
  %28 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size38 = getelementptr inbounds %struct.lp_upolynomial_struct* %28, i32 0, i32 1
  %29 = load i64* %size38, align 8
  %cmp = icmp ult i64 %27, %29
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %30 = load i64* %i, align 8
  %31 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %31, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %30
  %degree = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 0
  %32 = load i64* %degree, align 8
  %33 = load i64* %i, align 8
  %34 = load %struct.lp_upolynomial_struct** %result, align 8
  %monomials39 = getelementptr inbounds %struct.lp_upolynomial_struct* %34, i32 0, i32 2
  %arrayidx40 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials39, i32 0, i64 %33
  %degree41 = getelementptr inbounds %struct.umonomial_struct* %arrayidx40, i32 0, i32 0
  store i64 %32, i64* %degree41, align 8
  %35 = load %struct.lp_int_ring_t** %K, align 8
  %36 = load i64* %i, align 8
  %37 = load %struct.lp_upolynomial_struct** %result, align 8
  %monomials42 = getelementptr inbounds %struct.lp_upolynomial_struct* %37, i32 0, i32 2
  %arrayidx43 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials42, i32 0, i64 %36
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx43, i32 0, i32 1
  call void @integer_construct_from_int(%struct.lp_int_ring_t* %35, %struct.__mpz_struct* %coefficient, i64 0)
  %38 = load %struct.lp_int_ring_t** %K, align 8
  %39 = load %struct.__mpz_struct** %c.addr, align 8
  %40 = load i64* %i, align 8
  %41 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials44 = getelementptr inbounds %struct.lp_upolynomial_struct* %41, i32 0, i32 2
  %arrayidx45 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials44, i32 0, i64 %40
  %coefficient46 = getelementptr inbounds %struct.umonomial_struct* %arrayidx45, i32 0, i32 1
  %call47 = call i32 @integer_divides(%struct.lp_int_ring_t* %38, %struct.__mpz_struct* %39, %struct.__mpz_struct* %coefficient46)
  %tobool48 = icmp ne i32 %call47, 0
  br i1 %tobool48, label %cond.true49, label %cond.false50

cond.true49:                                      ; preds = %for.body
  br label %cond.end51

cond.false50:                                     ; preds = %for.body
  call void @__assert_fail(i8* getelementptr inbounds ([52 x i8]* @.str37, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 711, i8* getelementptr inbounds ([93 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_exact_c, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end51

cond.end51:                                       ; preds = %42, %cond.true49
  %43 = load %struct.lp_int_ring_t** %K, align 8
  %44 = load i64* %i, align 8
  %45 = load %struct.lp_upolynomial_struct** %result, align 8
  %monomials52 = getelementptr inbounds %struct.lp_upolynomial_struct* %45, i32 0, i32 2
  %arrayidx53 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials52, i32 0, i64 %44
  %coefficient54 = getelementptr inbounds %struct.umonomial_struct* %arrayidx53, i32 0, i32 1
  %46 = load i64* %i, align 8
  %47 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials55 = getelementptr inbounds %struct.lp_upolynomial_struct* %47, i32 0, i32 2
  %arrayidx56 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials55, i32 0, i64 %46
  %coefficient57 = getelementptr inbounds %struct.umonomial_struct* %arrayidx56, i32 0, i32 1
  %48 = load %struct.__mpz_struct** %c.addr, align 8
  call void @integer_div_exact(%struct.lp_int_ring_t* %43, %struct.__mpz_struct* %coefficient54, %struct.__mpz_struct* %coefficient57, %struct.__mpz_struct* %48)
  br label %for.inc

for.inc:                                          ; preds = %cond.end51
  %49 = load i64* %i, align 8
  %inc = add i64 %49, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %call58 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool59 = icmp ne i32 %call58, 0
  br i1 %tobool59, label %if.then60, label %if.end103

if.then60:                                        ; preds = %for.end
  %50 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool61 = icmp ne %struct._IO_FILE* %50, null
  br i1 %tobool61, label %cond.true62, label %cond.false63

cond.true62:                                      ; preds = %if.then60
  %51 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end64

cond.false63:                                     ; preds = %if.then60
  %52 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end64

cond.end64:                                       ; preds = %cond.false63, %cond.true62
  %cond65 = phi %struct._IO_FILE* [ %51, %cond.true62 ], [ %52, %cond.false63 ]
  %call66 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond65, i8* getelementptr inbounds ([23 x i8]* @.str34, i32 0, i32 0))
  %53 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %54 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool67 = icmp ne %struct._IO_FILE* %54, null
  br i1 %tobool67, label %cond.true68, label %cond.false69

cond.true68:                                      ; preds = %cond.end64
  %55 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end70

cond.false69:                                     ; preds = %cond.end64
  %56 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end70

cond.end70:                                       ; preds = %cond.false69, %cond.true68
  %cond71 = phi %struct._IO_FILE* [ %55, %cond.true68 ], [ %56, %cond.false69 ]
  %call72 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %53, %struct._IO_FILE* %cond71)
  %57 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool73 = icmp ne %struct._IO_FILE* %57, null
  br i1 %tobool73, label %cond.true74, label %cond.false75

cond.true74:                                      ; preds = %cond.end70
  %58 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end76

cond.false75:                                     ; preds = %cond.end70
  %59 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end76

cond.end76:                                       ; preds = %cond.false75, %cond.true74
  %cond77 = phi %struct._IO_FILE* [ %58, %cond.true74 ], [ %59, %cond.false75 ]
  %call78 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond77, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %60 = load %struct.__mpz_struct** %c.addr, align 8
  %61 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool79 = icmp ne %struct._IO_FILE* %61, null
  br i1 %tobool79, label %cond.true80, label %cond.false81

cond.true80:                                      ; preds = %cond.end76
  %62 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end82

cond.false81:                                     ; preds = %cond.end76
  %63 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end82

cond.end82:                                       ; preds = %cond.false81, %cond.true80
  %cond83 = phi %struct._IO_FILE* [ %62, %cond.true80 ], [ %63, %cond.false81 ]
  %call84 = call i32 @integer_print(%struct.__mpz_struct* %60, %struct._IO_FILE* %cond83)
  %64 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool85 = icmp ne %struct._IO_FILE* %64, null
  br i1 %tobool85, label %cond.true86, label %cond.false87

cond.true86:                                      ; preds = %cond.end82
  %65 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end88

cond.false87:                                     ; preds = %cond.end82
  %66 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end88

cond.end88:                                       ; preds = %cond.false87, %cond.true86
  %cond89 = phi %struct._IO_FILE* [ %65, %cond.true86 ], [ %66, %cond.false87 ]
  %call90 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond89, i8* getelementptr inbounds ([5 x i8]* @.str10, i32 0, i32 0))
  %67 = load %struct.lp_upolynomial_struct** %result, align 8
  %68 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool91 = icmp ne %struct._IO_FILE* %68, null
  br i1 %tobool91, label %cond.true92, label %cond.false93

cond.true92:                                      ; preds = %cond.end88
  %69 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end94

cond.false93:                                     ; preds = %cond.end88
  %70 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end94

cond.end94:                                       ; preds = %cond.false93, %cond.true92
  %cond95 = phi %struct._IO_FILE* [ %69, %cond.true92 ], [ %70, %cond.false93 ]
  %call96 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %67, %struct._IO_FILE* %cond95)
  %71 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool97 = icmp ne %struct._IO_FILE* %71, null
  br i1 %tobool97, label %cond.true98, label %cond.false99

cond.true98:                                      ; preds = %cond.end94
  %72 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end100

cond.false99:                                     ; preds = %cond.end94
  %73 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end100

cond.end100:                                      ; preds = %cond.false99, %cond.true98
  %cond101 = phi %struct._IO_FILE* [ %72, %cond.true98 ], [ %73, %cond.false99 ]
  %call102 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond101, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end103

if.end103:                                        ; preds = %cond.end100, %for.end
  %74 = load %struct.lp_upolynomial_struct** %result, align 8
  ret %struct.lp_upolynomial_struct* %74
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_rem_exact(%struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  %K48 = alloca %struct.lp_int_ring_t*, align 8
  %rem_buffer = alloca %struct.upolynomial_dense_t, align 8
  %div_buffer = alloca %struct.upolynomial_dense_t, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 727, i8* getelementptr inbounds ([95 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_rem_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %tobool1 = icmp ne %struct.lp_upolynomial_struct* %2, null
  br i1 %tobool1, label %cond.true2, label %cond.false3

cond.true2:                                       ; preds = %cond.end
  br label %cond.end4

cond.false3:                                      ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str4, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 728, i8* getelementptr inbounds ([95 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_rem_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end4

cond.end4:                                        ; preds = %3, %cond.true2
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %4, i32 0, i32 0
  %5 = load %struct.lp_int_ring_t** %K, align 8
  %6 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %K5 = getelementptr inbounds %struct.lp_upolynomial_struct* %6, i32 0, i32 0
  %7 = load %struct.lp_int_ring_t** %K5, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %5, %7
  br i1 %cmp, label %cond.true6, label %cond.false7

cond.true6:                                       ; preds = %cond.end4
  br label %cond.end8

cond.false7:                                      ; preds = %cond.end4
  call void @__assert_fail(i8* getelementptr inbounds ([13 x i8]* @.str5, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 729, i8* getelementptr inbounds ([95 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_rem_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end8

cond.end8:                                        ; preds = %8, %cond.true6
  %9 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call = call i32 @lp_upolynomial_is_zero(%struct.lp_upolynomial_struct* %9)
  %tobool9 = icmp ne i32 %call, 0
  br i1 %tobool9, label %cond.false11, label %cond.true10

cond.true10:                                      ; preds = %cond.end8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end8
  call void @__assert_fail(i8* getelementptr inbounds ([27 x i8]* @.str35, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 730, i8* getelementptr inbounds ([95 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_rem_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end12

cond.end12:                                       ; preds = %10, %cond.true10
  %call13 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool14 = icmp ne i32 %call13, 0
  br i1 %tobool14, label %if.then, label %if.end

if.then:                                          ; preds = %cond.end12
  %11 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool15 = icmp ne %struct._IO_FILE* %11, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %if.then
  %12 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end18

cond.false17:                                     ; preds = %if.then
  %13 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false17, %cond.true16
  %cond = phi %struct._IO_FILE* [ %12, %cond.true16 ], [ %13, %cond.false17 ]
  %call19 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([23 x i8]* @.str38, i32 0, i32 0))
  %14 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %15 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool20 = icmp ne %struct._IO_FILE* %15, null
  br i1 %tobool20, label %cond.true21, label %cond.false22

cond.true21:                                      ; preds = %cond.end18
  %16 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end23

cond.false22:                                     ; preds = %cond.end18
  %17 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end23

cond.end23:                                       ; preds = %cond.false22, %cond.true21
  %cond24 = phi %struct._IO_FILE* [ %16, %cond.true21 ], [ %17, %cond.false22 ]
  %call25 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %14, %struct._IO_FILE* %cond24)
  %18 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool26 = icmp ne %struct._IO_FILE* %18, null
  br i1 %tobool26, label %cond.true27, label %cond.false28

cond.true27:                                      ; preds = %cond.end23
  %19 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end29

cond.false28:                                     ; preds = %cond.end23
  %20 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end29

cond.end29:                                       ; preds = %cond.false28, %cond.true27
  %cond30 = phi %struct._IO_FILE* [ %19, %cond.true27 ], [ %20, %cond.false28 ]
  %call31 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond30, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %21 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %22 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool32 = icmp ne %struct._IO_FILE* %22, null
  br i1 %tobool32, label %cond.true33, label %cond.false34

cond.true33:                                      ; preds = %cond.end29
  %23 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end35

cond.false34:                                     ; preds = %cond.end29
  %24 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end35

cond.end35:                                       ; preds = %cond.false34, %cond.true33
  %cond36 = phi %struct._IO_FILE* [ %23, %cond.true33 ], [ %24, %cond.false34 ]
  %call37 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %21, %struct._IO_FILE* %cond36)
  %25 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool38 = icmp ne %struct._IO_FILE* %25, null
  br i1 %tobool38, label %cond.true39, label %cond.false40

cond.true39:                                      ; preds = %cond.end35
  %26 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end41

cond.false40:                                     ; preds = %cond.end35
  %27 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end41

cond.end41:                                       ; preds = %cond.false40, %cond.true39
  %cond42 = phi %struct._IO_FILE* [ %26, %cond.true39 ], [ %27, %cond.false40 ]
  %call43 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond42, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end41, %cond.end12
  store %struct.lp_upolynomial_struct* null, %struct.lp_upolynomial_struct** %result, align 8
  %28 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call44 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %28)
  %29 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call45 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %29)
  %cmp46 = icmp uge i64 %call44, %call45
  br i1 %cmp46, label %if.then47, label %if.else

if.then47:                                        ; preds = %if.end
  %30 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K49 = getelementptr inbounds %struct.lp_upolynomial_struct* %30, i32 0, i32 0
  %31 = load %struct.lp_int_ring_t** %K49, align 8
  store %struct.lp_int_ring_t* %31, %struct.lp_int_ring_t** %K48, align 8
  %32 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %33 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  call void @lp_upolynomial_div_general(%struct.lp_upolynomial_struct* %32, %struct.lp_upolynomial_struct* %33, %struct.upolynomial_dense_t* %div_buffer, %struct.upolynomial_dense_t* %rem_buffer, i32 1)
  %34 = load %struct.lp_int_ring_t** %K48, align 8
  %call50 = call %struct.lp_upolynomial_struct* @upolynomial_dense_to_upolynomial(%struct.upolynomial_dense_t* %rem_buffer, %struct.lp_int_ring_t* %34)
  store %struct.lp_upolynomial_struct* %call50, %struct.lp_upolynomial_struct** %result, align 8
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %rem_buffer)
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %div_buffer)
  br label %if.end52

if.else:                                          ; preds = %if.end
  %35 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call51 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy(%struct.lp_upolynomial_struct* %35)
  store %struct.lp_upolynomial_struct* %call51, %struct.lp_upolynomial_struct** %result, align 8
  br label %if.end52

if.end52:                                         ; preds = %if.else, %if.then47
  %call53 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool54 = icmp ne i32 %call53, 0
  br i1 %tobool54, label %if.then55, label %if.end98

if.then55:                                        ; preds = %if.end52
  %36 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool56 = icmp ne %struct._IO_FILE* %36, null
  br i1 %tobool56, label %cond.true57, label %cond.false58

cond.true57:                                      ; preds = %if.then55
  %37 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end59

cond.false58:                                     ; preds = %if.then55
  %38 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end59

cond.end59:                                       ; preds = %cond.false58, %cond.true57
  %cond60 = phi %struct._IO_FILE* [ %37, %cond.true57 ], [ %38, %cond.false58 ]
  %call61 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond60, i8* getelementptr inbounds ([23 x i8]* @.str38, i32 0, i32 0))
  %39 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %40 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool62 = icmp ne %struct._IO_FILE* %40, null
  br i1 %tobool62, label %cond.true63, label %cond.false64

cond.true63:                                      ; preds = %cond.end59
  %41 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end65

cond.false64:                                     ; preds = %cond.end59
  %42 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end65

cond.end65:                                       ; preds = %cond.false64, %cond.true63
  %cond66 = phi %struct._IO_FILE* [ %41, %cond.true63 ], [ %42, %cond.false64 ]
  %call67 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %39, %struct._IO_FILE* %cond66)
  %43 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool68 = icmp ne %struct._IO_FILE* %43, null
  br i1 %tobool68, label %cond.true69, label %cond.false70

cond.true69:                                      ; preds = %cond.end65
  %44 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end71

cond.false70:                                     ; preds = %cond.end65
  %45 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end71

cond.end71:                                       ; preds = %cond.false70, %cond.true69
  %cond72 = phi %struct._IO_FILE* [ %44, %cond.true69 ], [ %45, %cond.false70 ]
  %call73 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond72, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %46 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %47 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool74 = icmp ne %struct._IO_FILE* %47, null
  br i1 %tobool74, label %cond.true75, label %cond.false76

cond.true75:                                      ; preds = %cond.end71
  %48 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end77

cond.false76:                                     ; preds = %cond.end71
  %49 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end77

cond.end77:                                       ; preds = %cond.false76, %cond.true75
  %cond78 = phi %struct._IO_FILE* [ %48, %cond.true75 ], [ %49, %cond.false76 ]
  %call79 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %46, %struct._IO_FILE* %cond78)
  %50 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool80 = icmp ne %struct._IO_FILE* %50, null
  br i1 %tobool80, label %cond.true81, label %cond.false82

cond.true81:                                      ; preds = %cond.end77
  %51 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end83

cond.false82:                                     ; preds = %cond.end77
  %52 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end83

cond.end83:                                       ; preds = %cond.false82, %cond.true81
  %cond84 = phi %struct._IO_FILE* [ %51, %cond.true81 ], [ %52, %cond.false82 ]
  %call85 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond84, i8* getelementptr inbounds ([5 x i8]* @.str10, i32 0, i32 0))
  %53 = load %struct.lp_upolynomial_struct** %result, align 8
  %54 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool86 = icmp ne %struct._IO_FILE* %54, null
  br i1 %tobool86, label %cond.true87, label %cond.false88

cond.true87:                                      ; preds = %cond.end83
  %55 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end89

cond.false88:                                     ; preds = %cond.end83
  %56 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end89

cond.end89:                                       ; preds = %cond.false88, %cond.true87
  %cond90 = phi %struct._IO_FILE* [ %55, %cond.true87 ], [ %56, %cond.false88 ]
  %call91 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %53, %struct._IO_FILE* %cond90)
  %57 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool92 = icmp ne %struct._IO_FILE* %57, null
  br i1 %tobool92, label %cond.true93, label %cond.false94

cond.true93:                                      ; preds = %cond.end89
  %58 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end95

cond.false94:                                     ; preds = %cond.end89
  %59 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end95

cond.end95:                                       ; preds = %cond.false94, %cond.true93
  %cond96 = phi %struct._IO_FILE* [ %58, %cond.true93 ], [ %59, %cond.false94 ]
  %call97 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond96, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end98

if.end98:                                         ; preds = %cond.end95, %if.end52
  %60 = load %struct.lp_upolynomial_struct** %result, align 8
  ret %struct.lp_upolynomial_struct* %60
}

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_div_rem_exact(%struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %div, %struct.lp_upolynomial_struct** %rem) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %div.addr = alloca %struct.lp_upolynomial_struct**, align 8
  %rem.addr = alloca %struct.lp_upolynomial_struct**, align 8
  %K53 = alloca %struct.lp_int_ring_t*, align 8
  %rem_buffer = alloca %struct.upolynomial_dense_t, align 8
  %div_buffer = alloca %struct.upolynomial_dense_t, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  store %struct.lp_upolynomial_struct** %div, %struct.lp_upolynomial_struct*** %div.addr, align 8
  store %struct.lp_upolynomial_struct** %rem, %struct.lp_upolynomial_struct*** %rem.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([27 x i8]* @.str39, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %10 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %11 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool15 = icmp ne %struct._IO_FILE* %11, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %cond.end12
  %12 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end18

cond.false17:                                     ; preds = %cond.end12
  %13 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false17, %cond.true16
  %cond19 = phi %struct._IO_FILE* [ %12, %cond.true16 ], [ %13, %cond.false17 ]
  %call20 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %10, %struct._IO_FILE* %cond19)
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool21 = icmp ne %struct._IO_FILE* %14, null
  br i1 %tobool21, label %cond.true22, label %cond.false23

cond.true22:                                      ; preds = %cond.end18
  %15 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end24

cond.false23:                                     ; preds = %cond.end18
  %16 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end24

cond.end24:                                       ; preds = %cond.false23, %cond.true22
  %cond25 = phi %struct._IO_FILE* [ %15, %cond.true22 ], [ %16, %cond.false23 ]
  %call26 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond25, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end24, %entry
  %17 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool27 = icmp ne %struct.lp_upolynomial_struct* %17, null
  br i1 %tobool27, label %cond.true28, label %cond.false29

cond.true28:                                      ; preds = %if.end
  br label %cond.end30

cond.false29:                                     ; preds = %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 765, i8* getelementptr inbounds ([128 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_rem_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end30

cond.end30:                                       ; preds = %18, %cond.true28
  %19 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %tobool31 = icmp ne %struct.lp_upolynomial_struct* %19, null
  br i1 %tobool31, label %cond.true32, label %cond.false33

cond.true32:                                      ; preds = %cond.end30
  br label %cond.end34

cond.false33:                                     ; preds = %cond.end30
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str4, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 766, i8* getelementptr inbounds ([128 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_rem_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end34

cond.end34:                                       ; preds = %20, %cond.true32
  %21 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %21, i32 0, i32 0
  %22 = load %struct.lp_int_ring_t** %K, align 8
  %23 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %K35 = getelementptr inbounds %struct.lp_upolynomial_struct* %23, i32 0, i32 0
  %24 = load %struct.lp_int_ring_t** %K35, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %22, %24
  br i1 %cmp, label %cond.true36, label %cond.false37

cond.true36:                                      ; preds = %cond.end34
  br label %cond.end38

cond.false37:                                     ; preds = %cond.end34
  call void @__assert_fail(i8* getelementptr inbounds ([13 x i8]* @.str5, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 767, i8* getelementptr inbounds ([128 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_rem_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end38

cond.end38:                                       ; preds = %25, %cond.true36
  %26 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call39 = call i32 @lp_upolynomial_is_zero(%struct.lp_upolynomial_struct* %26)
  %tobool40 = icmp ne i32 %call39, 0
  br i1 %tobool40, label %cond.false42, label %cond.true41

cond.true41:                                      ; preds = %cond.end38
  br label %cond.end43

cond.false42:                                     ; preds = %cond.end38
  call void @__assert_fail(i8* getelementptr inbounds ([27 x i8]* @.str35, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 768, i8* getelementptr inbounds ([128 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_rem_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end43

cond.end43:                                       ; preds = %27, %cond.true41
  %28 = load %struct.lp_upolynomial_struct*** %div.addr, align 8
  %29 = load %struct.lp_upolynomial_struct** %28, align 8
  %cmp44 = icmp eq %struct.lp_upolynomial_struct* %29, null
  br i1 %cmp44, label %land.lhs.true, label %cond.false47

land.lhs.true:                                    ; preds = %cond.end43
  %30 = load %struct.lp_upolynomial_struct*** %rem.addr, align 8
  %31 = load %struct.lp_upolynomial_struct** %30, align 8
  %cmp45 = icmp eq %struct.lp_upolynomial_struct* %31, null
  br i1 %cmp45, label %cond.true46, label %cond.false47

cond.true46:                                      ; preds = %land.lhs.true
  br label %cond.end48

cond.false47:                                     ; preds = %land.lhs.true, %cond.end43
  call void @__assert_fail(i8* getelementptr inbounds ([23 x i8]* @.str40, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 769, i8* getelementptr inbounds ([128 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_rem_exact, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end48

cond.end48:                                       ; preds = %32, %cond.true46
  %33 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call49 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %33)
  %34 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call50 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %34)
  %cmp51 = icmp uge i64 %call49, %call50
  br i1 %cmp51, label %if.then52, label %if.else

if.then52:                                        ; preds = %cond.end48
  %35 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K54 = getelementptr inbounds %struct.lp_upolynomial_struct* %35, i32 0, i32 0
  %36 = load %struct.lp_int_ring_t** %K54, align 8
  store %struct.lp_int_ring_t* %36, %struct.lp_int_ring_t** %K53, align 8
  %37 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %38 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  call void @lp_upolynomial_div_general(%struct.lp_upolynomial_struct* %37, %struct.lp_upolynomial_struct* %38, %struct.upolynomial_dense_t* %div_buffer, %struct.upolynomial_dense_t* %rem_buffer, i32 1)
  %39 = load %struct.lp_int_ring_t** %K53, align 8
  %call55 = call %struct.lp_upolynomial_struct* @upolynomial_dense_to_upolynomial(%struct.upolynomial_dense_t* %div_buffer, %struct.lp_int_ring_t* %39)
  %40 = load %struct.lp_upolynomial_struct*** %div.addr, align 8
  store %struct.lp_upolynomial_struct* %call55, %struct.lp_upolynomial_struct** %40, align 8
  %41 = load %struct.lp_int_ring_t** %K53, align 8
  %call56 = call %struct.lp_upolynomial_struct* @upolynomial_dense_to_upolynomial(%struct.upolynomial_dense_t* %rem_buffer, %struct.lp_int_ring_t* %41)
  %42 = load %struct.lp_upolynomial_struct*** %rem.addr, align 8
  store %struct.lp_upolynomial_struct* %call56, %struct.lp_upolynomial_struct** %42, align 8
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %div_buffer)
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %rem_buffer)
  br label %if.end60

if.else:                                          ; preds = %cond.end48
  %43 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K57 = getelementptr inbounds %struct.lp_upolynomial_struct* %43, i32 0, i32 0
  %44 = load %struct.lp_int_ring_t** %K57, align 8
  %call58 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_power(%struct.lp_int_ring_t* %44, i64 0, i64 0)
  %45 = load %struct.lp_upolynomial_struct*** %div.addr, align 8
  store %struct.lp_upolynomial_struct* %call58, %struct.lp_upolynomial_struct** %45, align 8
  %46 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call59 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy(%struct.lp_upolynomial_struct* %46)
  %47 = load %struct.lp_upolynomial_struct*** %rem.addr, align 8
  store %struct.lp_upolynomial_struct* %call59, %struct.lp_upolynomial_struct** %47, align 8
  br label %if.end60

if.end60:                                         ; preds = %if.else, %if.then52
  %call61 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool62 = icmp ne i32 %call61, 0
  br i1 %tobool62, label %if.then63, label %if.end118

if.then63:                                        ; preds = %if.end60
  %48 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool64 = icmp ne %struct._IO_FILE* %48, null
  br i1 %tobool64, label %cond.true65, label %cond.false66

cond.true65:                                      ; preds = %if.then63
  %49 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end67

cond.false66:                                     ; preds = %if.then63
  %50 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end67

cond.end67:                                       ; preds = %cond.false66, %cond.true65
  %cond68 = phi %struct._IO_FILE* [ %49, %cond.true65 ], [ %50, %cond.false66 ]
  %call69 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond68, i8* getelementptr inbounds ([23 x i8]* @.str34, i32 0, i32 0))
  %51 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %52 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool70 = icmp ne %struct._IO_FILE* %52, null
  br i1 %tobool70, label %cond.true71, label %cond.false72

cond.true71:                                      ; preds = %cond.end67
  %53 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end73

cond.false72:                                     ; preds = %cond.end67
  %54 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end73

cond.end73:                                       ; preds = %cond.false72, %cond.true71
  %cond74 = phi %struct._IO_FILE* [ %53, %cond.true71 ], [ %54, %cond.false72 ]
  %call75 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %51, %struct._IO_FILE* %cond74)
  %55 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool76 = icmp ne %struct._IO_FILE* %55, null
  br i1 %tobool76, label %cond.true77, label %cond.false78

cond.true77:                                      ; preds = %cond.end73
  %56 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end79

cond.false78:                                     ; preds = %cond.end73
  %57 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end79

cond.end79:                                       ; preds = %cond.false78, %cond.true77
  %cond80 = phi %struct._IO_FILE* [ %56, %cond.true77 ], [ %57, %cond.false78 ]
  %call81 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond80, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %58 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %59 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool82 = icmp ne %struct._IO_FILE* %59, null
  br i1 %tobool82, label %cond.true83, label %cond.false84

cond.true83:                                      ; preds = %cond.end79
  %60 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end85

cond.false84:                                     ; preds = %cond.end79
  %61 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end85

cond.end85:                                       ; preds = %cond.false84, %cond.true83
  %cond86 = phi %struct._IO_FILE* [ %60, %cond.true83 ], [ %61, %cond.false84 ]
  %call87 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %58, %struct._IO_FILE* %cond86)
  %62 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool88 = icmp ne %struct._IO_FILE* %62, null
  br i1 %tobool88, label %cond.true89, label %cond.false90

cond.true89:                                      ; preds = %cond.end85
  %63 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end91

cond.false90:                                     ; preds = %cond.end85
  %64 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end91

cond.end91:                                       ; preds = %cond.false90, %cond.true89
  %cond92 = phi %struct._IO_FILE* [ %63, %cond.true89 ], [ %64, %cond.false90 ]
  %call93 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond92, i8* getelementptr inbounds ([6 x i8]* @.str41, i32 0, i32 0))
  %65 = load %struct.lp_upolynomial_struct*** %div.addr, align 8
  %66 = load %struct.lp_upolynomial_struct** %65, align 8
  %67 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool94 = icmp ne %struct._IO_FILE* %67, null
  br i1 %tobool94, label %cond.true95, label %cond.false96

cond.true95:                                      ; preds = %cond.end91
  %68 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end97

cond.false96:                                     ; preds = %cond.end91
  %69 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end97

cond.end97:                                       ; preds = %cond.false96, %cond.true95
  %cond98 = phi %struct._IO_FILE* [ %68, %cond.true95 ], [ %69, %cond.false96 ]
  %call99 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %66, %struct._IO_FILE* %cond98)
  %70 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool100 = icmp ne %struct._IO_FILE* %70, null
  br i1 %tobool100, label %cond.true101, label %cond.false102

cond.true101:                                     ; preds = %cond.end97
  %71 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end103

cond.false102:                                    ; preds = %cond.end97
  %72 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end103

cond.end103:                                      ; preds = %cond.false102, %cond.true101
  %cond104 = phi %struct._IO_FILE* [ %71, %cond.true101 ], [ %72, %cond.false102 ]
  %call105 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond104, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %73 = load %struct.lp_upolynomial_struct*** %rem.addr, align 8
  %74 = load %struct.lp_upolynomial_struct** %73, align 8
  %75 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool106 = icmp ne %struct._IO_FILE* %75, null
  br i1 %tobool106, label %cond.true107, label %cond.false108

cond.true107:                                     ; preds = %cond.end103
  %76 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end109

cond.false108:                                    ; preds = %cond.end103
  %77 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end109

cond.end109:                                      ; preds = %cond.false108, %cond.true107
  %cond110 = phi %struct._IO_FILE* [ %76, %cond.true107 ], [ %77, %cond.false108 ]
  %call111 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %74, %struct._IO_FILE* %cond110)
  %78 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool112 = icmp ne %struct._IO_FILE* %78, null
  br i1 %tobool112, label %cond.true113, label %cond.false114

cond.true113:                                     ; preds = %cond.end109
  %79 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end115

cond.false114:                                    ; preds = %cond.end109
  %80 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end115

cond.end115:                                      ; preds = %cond.false114, %cond.true113
  %cond116 = phi %struct._IO_FILE* [ %79, %cond.true113 ], [ %80, %cond.false114 ]
  %call117 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond116, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end118

if.end118:                                        ; preds = %cond.end115, %if.end60
  ret void
}

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_div_pseudo(%struct.lp_upolynomial_struct** %div, %struct.lp_upolynomial_struct** %rem, %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q) #0 {
entry:
  %div.addr = alloca %struct.lp_upolynomial_struct**, align 8
  %rem.addr = alloca %struct.lp_upolynomial_struct**, align 8
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %K50 = alloca %struct.lp_int_ring_t*, align 8
  %rem_buffer = alloca %struct.upolynomial_dense_t, align 8
  %div_buffer = alloca %struct.upolynomial_dense_t, align 8
  store %struct.lp_upolynomial_struct** %div, %struct.lp_upolynomial_struct*** %div.addr, align 8
  store %struct.lp_upolynomial_struct** %rem, %struct.lp_upolynomial_struct*** %rem.addr, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([24 x i8]* @.str42, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %10 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %11 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool15 = icmp ne %struct._IO_FILE* %11, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %cond.end12
  %12 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end18

cond.false17:                                     ; preds = %cond.end12
  %13 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false17, %cond.true16
  %cond19 = phi %struct._IO_FILE* [ %12, %cond.true16 ], [ %13, %cond.false17 ]
  %call20 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %10, %struct._IO_FILE* %cond19)
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool21 = icmp ne %struct._IO_FILE* %14, null
  br i1 %tobool21, label %cond.true22, label %cond.false23

cond.true22:                                      ; preds = %cond.end18
  %15 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end24

cond.false23:                                     ; preds = %cond.end18
  %16 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end24

cond.end24:                                       ; preds = %cond.false23, %cond.true22
  %cond25 = phi %struct._IO_FILE* [ %15, %cond.true22 ], [ %16, %cond.false23 ]
  %call26 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond25, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end24, %entry
  %17 = load %struct.lp_upolynomial_struct*** %div.addr, align 8
  %18 = load %struct.lp_upolynomial_struct** %17, align 8
  %tobool27 = icmp ne %struct.lp_upolynomial_struct* %18, null
  br i1 %tobool27, label %cond.false29, label %cond.true28

cond.true28:                                      ; preds = %if.end
  br label %cond.end30

cond.false29:                                     ; preds = %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([6 x i8]* @.str43, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 799, i8* getelementptr inbounds ([125 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_pseudo, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end30

cond.end30:                                       ; preds = %19, %cond.true28
  %20 = load %struct.lp_upolynomial_struct*** %rem.addr, align 8
  %21 = load %struct.lp_upolynomial_struct** %20, align 8
  %tobool31 = icmp ne %struct.lp_upolynomial_struct* %21, null
  br i1 %tobool31, label %cond.false33, label %cond.true32

cond.true32:                                      ; preds = %cond.end30
  br label %cond.end34

cond.false33:                                     ; preds = %cond.end30
  call void @__assert_fail(i8* getelementptr inbounds ([6 x i8]* @.str44, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 800, i8* getelementptr inbounds ([125 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_pseudo, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end34

cond.end34:                                       ; preds = %22, %cond.true32
  %23 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %23, i32 0, i32 0
  %24 = load %struct.lp_int_ring_t** %K, align 8
  %25 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %K35 = getelementptr inbounds %struct.lp_upolynomial_struct* %25, i32 0, i32 0
  %26 = load %struct.lp_int_ring_t** %K35, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %24, %26
  br i1 %cmp, label %cond.true36, label %cond.false37

cond.true36:                                      ; preds = %cond.end34
  br label %cond.end38

cond.false37:                                     ; preds = %cond.end34
  call void @__assert_fail(i8* getelementptr inbounds ([13 x i8]* @.str5, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 801, i8* getelementptr inbounds ([125 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_pseudo, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end38

cond.end38:                                       ; preds = %27, %cond.true36
  %28 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call39 = call i32 @lp_upolynomial_is_zero(%struct.lp_upolynomial_struct* %28)
  %tobool40 = icmp ne i32 %call39, 0
  br i1 %tobool40, label %cond.false42, label %cond.true41

cond.true41:                                      ; preds = %cond.end38
  br label %cond.end43

cond.false42:                                     ; preds = %cond.end38
  call void @__assert_fail(i8* getelementptr inbounds ([27 x i8]* @.str35, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 802, i8* getelementptr inbounds ([125 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_pseudo, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end43

cond.end43:                                       ; preds = %29, %cond.true41
  %30 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call44 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %30)
  %31 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call45 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %31)
  %cmp46 = icmp uge i64 %call44, %call45
  br i1 %cmp46, label %cond.true47, label %cond.false48

cond.true47:                                      ; preds = %cond.end43
  br label %cond.end49

cond.false48:                                     ; preds = %cond.end43
  call void @__assert_fail(i8* getelementptr inbounds ([53 x i8]* @.str45, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 804, i8* getelementptr inbounds ([125 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_div_pseudo, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end49

cond.end49:                                       ; preds = %32, %cond.true47
  %33 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K51 = getelementptr inbounds %struct.lp_upolynomial_struct* %33, i32 0, i32 0
  %34 = load %struct.lp_int_ring_t** %K51, align 8
  store %struct.lp_int_ring_t* %34, %struct.lp_int_ring_t** %K50, align 8
  %35 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %36 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  call void @lp_upolynomial_div_general(%struct.lp_upolynomial_struct* %35, %struct.lp_upolynomial_struct* %36, %struct.upolynomial_dense_t* %div_buffer, %struct.upolynomial_dense_t* %rem_buffer, i32 0)
  %37 = load %struct.lp_int_ring_t** %K50, align 8
  %call52 = call %struct.lp_upolynomial_struct* @upolynomial_dense_to_upolynomial(%struct.upolynomial_dense_t* %div_buffer, %struct.lp_int_ring_t* %37)
  %38 = load %struct.lp_upolynomial_struct*** %div.addr, align 8
  store %struct.lp_upolynomial_struct* %call52, %struct.lp_upolynomial_struct** %38, align 8
  %39 = load %struct.lp_int_ring_t** %K50, align 8
  %call53 = call %struct.lp_upolynomial_struct* @upolynomial_dense_to_upolynomial(%struct.upolynomial_dense_t* %rem_buffer, %struct.lp_int_ring_t* %39)
  %40 = load %struct.lp_upolynomial_struct*** %rem.addr, align 8
  store %struct.lp_upolynomial_struct* %call53, %struct.lp_upolynomial_struct** %40, align 8
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %div_buffer)
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %rem_buffer)
  %call54 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool55 = icmp ne i32 %call54, 0
  br i1 %tobool55, label %if.then56, label %if.end111

if.then56:                                        ; preds = %cond.end49
  %41 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool57 = icmp ne %struct._IO_FILE* %41, null
  br i1 %tobool57, label %cond.true58, label %cond.false59

cond.true58:                                      ; preds = %if.then56
  %42 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end60

cond.false59:                                     ; preds = %if.then56
  %43 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end60

cond.end60:                                       ; preds = %cond.false59, %cond.true58
  %cond61 = phi %struct._IO_FILE* [ %42, %cond.true58 ], [ %43, %cond.false59 ]
  %call62 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond61, i8* getelementptr inbounds ([24 x i8]* @.str42, i32 0, i32 0))
  %44 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %45 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool63 = icmp ne %struct._IO_FILE* %45, null
  br i1 %tobool63, label %cond.true64, label %cond.false65

cond.true64:                                      ; preds = %cond.end60
  %46 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end66

cond.false65:                                     ; preds = %cond.end60
  %47 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end66

cond.end66:                                       ; preds = %cond.false65, %cond.true64
  %cond67 = phi %struct._IO_FILE* [ %46, %cond.true64 ], [ %47, %cond.false65 ]
  %call68 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %44, %struct._IO_FILE* %cond67)
  %48 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool69 = icmp ne %struct._IO_FILE* %48, null
  br i1 %tobool69, label %cond.true70, label %cond.false71

cond.true70:                                      ; preds = %cond.end66
  %49 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end72

cond.false71:                                     ; preds = %cond.end66
  %50 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end72

cond.end72:                                       ; preds = %cond.false71, %cond.true70
  %cond73 = phi %struct._IO_FILE* [ %49, %cond.true70 ], [ %50, %cond.false71 ]
  %call74 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond73, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %51 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %52 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool75 = icmp ne %struct._IO_FILE* %52, null
  br i1 %tobool75, label %cond.true76, label %cond.false77

cond.true76:                                      ; preds = %cond.end72
  %53 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end78

cond.false77:                                     ; preds = %cond.end72
  %54 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end78

cond.end78:                                       ; preds = %cond.false77, %cond.true76
  %cond79 = phi %struct._IO_FILE* [ %53, %cond.true76 ], [ %54, %cond.false77 ]
  %call80 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %51, %struct._IO_FILE* %cond79)
  %55 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool81 = icmp ne %struct._IO_FILE* %55, null
  br i1 %tobool81, label %cond.true82, label %cond.false83

cond.true82:                                      ; preds = %cond.end78
  %56 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end84

cond.false83:                                     ; preds = %cond.end78
  %57 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end84

cond.end84:                                       ; preds = %cond.false83, %cond.true82
  %cond85 = phi %struct._IO_FILE* [ %56, %cond.true82 ], [ %57, %cond.false83 ]
  %call86 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond85, i8* getelementptr inbounds ([6 x i8]* @.str41, i32 0, i32 0))
  %58 = load %struct.lp_upolynomial_struct*** %div.addr, align 8
  %59 = load %struct.lp_upolynomial_struct** %58, align 8
  %60 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool87 = icmp ne %struct._IO_FILE* %60, null
  br i1 %tobool87, label %cond.true88, label %cond.false89

cond.true88:                                      ; preds = %cond.end84
  %61 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end90

cond.false89:                                     ; preds = %cond.end84
  %62 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end90

cond.end90:                                       ; preds = %cond.false89, %cond.true88
  %cond91 = phi %struct._IO_FILE* [ %61, %cond.true88 ], [ %62, %cond.false89 ]
  %call92 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %59, %struct._IO_FILE* %cond91)
  %63 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool93 = icmp ne %struct._IO_FILE* %63, null
  br i1 %tobool93, label %cond.true94, label %cond.false95

cond.true94:                                      ; preds = %cond.end90
  %64 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end96

cond.false95:                                     ; preds = %cond.end90
  %65 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end96

cond.end96:                                       ; preds = %cond.false95, %cond.true94
  %cond97 = phi %struct._IO_FILE* [ %64, %cond.true94 ], [ %65, %cond.false95 ]
  %call98 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond97, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %66 = load %struct.lp_upolynomial_struct*** %rem.addr, align 8
  %67 = load %struct.lp_upolynomial_struct** %66, align 8
  %68 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool99 = icmp ne %struct._IO_FILE* %68, null
  br i1 %tobool99, label %cond.true100, label %cond.false101

cond.true100:                                     ; preds = %cond.end96
  %69 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end102

cond.false101:                                    ; preds = %cond.end96
  %70 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end102

cond.end102:                                      ; preds = %cond.false101, %cond.true100
  %cond103 = phi %struct._IO_FILE* [ %69, %cond.true100 ], [ %70, %cond.false101 ]
  %call104 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %67, %struct._IO_FILE* %cond103)
  %71 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool105 = icmp ne %struct._IO_FILE* %71, null
  br i1 %tobool105, label %cond.true106, label %cond.false107

cond.true106:                                     ; preds = %cond.end102
  %72 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end108

cond.false107:                                    ; preds = %cond.end102
  %73 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end108

cond.end108:                                      ; preds = %cond.false107, %cond.true106
  %cond109 = phi %struct._IO_FILE* [ %72, %cond.true106 ], [ %73, %cond.false107 ]
  %call110 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond109, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end111

if.end111:                                        ; preds = %cond.end108, %cond.end49
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @lp_upolynomial_divides(%struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q) #0 {
entry:
  %retval = alloca i32, align 4
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %K36 = alloca %struct.lp_int_ring_t*, align 8
  %result = alloca i32, align 4
  %rem = alloca %struct.lp_upolynomial_struct*, align 8
  %div = alloca %struct.lp_upolynomial_struct*, align 8
  %rem58 = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([23 x i8]* @.str34, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %10 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %11 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool15 = icmp ne %struct._IO_FILE* %11, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %cond.end12
  %12 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end18

cond.false17:                                     ; preds = %cond.end12
  %13 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false17, %cond.true16
  %cond19 = phi %struct._IO_FILE* [ %12, %cond.true16 ], [ %13, %cond.false17 ]
  %call20 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %10, %struct._IO_FILE* %cond19)
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool21 = icmp ne %struct._IO_FILE* %14, null
  br i1 %tobool21, label %cond.true22, label %cond.false23

cond.true22:                                      ; preds = %cond.end18
  %15 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end24

cond.false23:                                     ; preds = %cond.end18
  %16 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end24

cond.end24:                                       ; preds = %cond.false23, %cond.true22
  %cond25 = phi %struct._IO_FILE* [ %15, %cond.true22 ], [ %16, %cond.false23 ]
  %call26 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond25, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end24, %entry
  %17 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %17, i32 0, i32 0
  %18 = load %struct.lp_int_ring_t** %K, align 8
  %19 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %K27 = getelementptr inbounds %struct.lp_upolynomial_struct* %19, i32 0, i32 0
  %20 = load %struct.lp_int_ring_t** %K27, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %18, %20
  br i1 %cmp, label %cond.true28, label %cond.false29

cond.true28:                                      ; preds = %if.end
  br label %cond.end30

cond.false29:                                     ; preds = %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([13 x i8]* @.str5, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 830, i8* getelementptr inbounds ([79 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_divides, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end30

cond.end30:                                       ; preds = %21, %cond.true28
  %22 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call31 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %22)
  %23 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call32 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %23)
  %cmp33 = icmp ugt i64 %call31, %call32
  br i1 %cmp33, label %if.then34, label %if.end35

if.then34:                                        ; preds = %cond.end30
  store i32 0, i32* %retval
  br label %return

if.end35:                                         ; preds = %cond.end30
  %24 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K37 = getelementptr inbounds %struct.lp_upolynomial_struct* %24, i32 0, i32 0
  %25 = load %struct.lp_int_ring_t** %K37, align 8
  store %struct.lp_int_ring_t* %25, %struct.lp_int_ring_t** %K36, align 8
  store i32 0, i32* %result, align 4
  %26 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %26, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 0
  %degree = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 0
  %27 = load i64* %degree, align 8
  %28 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %monomials38 = getelementptr inbounds %struct.lp_upolynomial_struct* %28, i32 0, i32 2
  %arrayidx39 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials38, i32 0, i64 0
  %degree40 = getelementptr inbounds %struct.umonomial_struct* %arrayidx39, i32 0, i32 0
  %29 = load i64* %degree40, align 8
  %cmp41 = icmp ugt i64 %27, %29
  br i1 %cmp41, label %if.then42, label %if.else

if.then42:                                        ; preds = %if.end35
  store i32 0, i32* %result, align 4
  br label %if.end62

if.else:                                          ; preds = %if.end35
  %30 = load %struct.lp_int_ring_t** %K36, align 8
  %31 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials43 = getelementptr inbounds %struct.lp_upolynomial_struct* %31, i32 0, i32 2
  %arrayidx44 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials43, i32 0, i64 0
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx44, i32 0, i32 1
  %32 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %monomials45 = getelementptr inbounds %struct.lp_upolynomial_struct* %32, i32 0, i32 2
  %arrayidx46 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials45, i32 0, i64 0
  %coefficient47 = getelementptr inbounds %struct.umonomial_struct* %arrayidx46, i32 0, i32 1
  %call48 = call i32 @integer_divides(%struct.lp_int_ring_t* %30, %struct.__mpz_struct* %coefficient, %struct.__mpz_struct* %coefficient47)
  %tobool49 = icmp ne i32 %call48, 0
  br i1 %tobool49, label %if.else51, label %if.then50

if.then50:                                        ; preds = %if.else
  store i32 0, i32* %result, align 4
  br label %if.end61

if.else51:                                        ; preds = %if.else
  %33 = load %struct.lp_int_ring_t** %K36, align 8
  %tobool52 = icmp ne %struct.lp_int_ring_t* %33, null
  br i1 %tobool52, label %land.lhs.true, label %if.else57

land.lhs.true:                                    ; preds = %if.else51
  %34 = load %struct.lp_int_ring_t** %K36, align 8
  %is_prime = getelementptr inbounds %struct.lp_int_ring_t* %34, i32 0, i32 1
  %35 = load i32* %is_prime, align 4
  %tobool53 = icmp ne i32 %35, 0
  br i1 %tobool53, label %if.then54, label %if.else57

if.then54:                                        ; preds = %land.lhs.true
  %36 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %37 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call55 = call %struct.lp_upolynomial_struct* @lp_upolynomial_rem_exact(%struct.lp_upolynomial_struct* %36, %struct.lp_upolynomial_struct* %37)
  store %struct.lp_upolynomial_struct* %call55, %struct.lp_upolynomial_struct** %rem, align 8
  %38 = load %struct.lp_upolynomial_struct** %rem, align 8
  %call56 = call i32 @lp_upolynomial_is_zero(%struct.lp_upolynomial_struct* %38)
  store i32 %call56, i32* %result, align 4
  %39 = load %struct.lp_upolynomial_struct** %rem, align 8
  call void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %39)
  br label %if.end60

if.else57:                                        ; preds = %land.lhs.true, %if.else51
  store %struct.lp_upolynomial_struct* null, %struct.lp_upolynomial_struct** %div, align 8
  store %struct.lp_upolynomial_struct* null, %struct.lp_upolynomial_struct** %rem58, align 8
  %40 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %41 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  call void @lp_upolynomial_div_pseudo(%struct.lp_upolynomial_struct** %div, %struct.lp_upolynomial_struct** %rem58, %struct.lp_upolynomial_struct* %40, %struct.lp_upolynomial_struct* %41)
  %42 = load %struct.lp_upolynomial_struct** %rem58, align 8
  %call59 = call i32 @lp_upolynomial_is_zero(%struct.lp_upolynomial_struct* %42)
  store i32 %call59, i32* %result, align 4
  %43 = load %struct.lp_upolynomial_struct** %div, align 8
  call void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %43)
  %44 = load %struct.lp_upolynomial_struct** %rem58, align 8
  call void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %44)
  br label %if.end60

if.end60:                                         ; preds = %if.else57, %if.then54
  br label %if.end61

if.end61:                                         ; preds = %if.end60, %if.then50
  br label %if.end62

if.end62:                                         ; preds = %if.end61, %if.then42
  %call63 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([11 x i8]* @.str6, i32 0, i32 0))
  %tobool64 = icmp ne i32 %call63, 0
  br i1 %tobool64, label %if.then65, label %if.end96

if.then65:                                        ; preds = %if.end62
  %45 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool66 = icmp ne %struct._IO_FILE* %45, null
  br i1 %tobool66, label %cond.true67, label %cond.false68

cond.true67:                                      ; preds = %if.then65
  %46 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end69

cond.false68:                                     ; preds = %if.then65
  %47 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end69

cond.end69:                                       ; preds = %cond.false68, %cond.true67
  %cond70 = phi %struct._IO_FILE* [ %46, %cond.true67 ], [ %47, %cond.false68 ]
  %call71 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond70, i8* getelementptr inbounds ([23 x i8]* @.str34, i32 0, i32 0))
  %48 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %49 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool72 = icmp ne %struct._IO_FILE* %49, null
  br i1 %tobool72, label %cond.true73, label %cond.false74

cond.true73:                                      ; preds = %cond.end69
  %50 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end75

cond.false74:                                     ; preds = %cond.end69
  %51 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end75

cond.end75:                                       ; preds = %cond.false74, %cond.true73
  %cond76 = phi %struct._IO_FILE* [ %50, %cond.true73 ], [ %51, %cond.false74 ]
  %call77 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %48, %struct._IO_FILE* %cond76)
  %52 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool78 = icmp ne %struct._IO_FILE* %52, null
  br i1 %tobool78, label %cond.true79, label %cond.false80

cond.true79:                                      ; preds = %cond.end75
  %53 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end81

cond.false80:                                     ; preds = %cond.end75
  %54 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end81

cond.end81:                                       ; preds = %cond.false80, %cond.true79
  %cond82 = phi %struct._IO_FILE* [ %53, %cond.true79 ], [ %54, %cond.false80 ]
  %call83 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond82, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %55 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %56 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool84 = icmp ne %struct._IO_FILE* %56, null
  br i1 %tobool84, label %cond.true85, label %cond.false86

cond.true85:                                      ; preds = %cond.end81
  %57 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end87

cond.false86:                                     ; preds = %cond.end81
  %58 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end87

cond.end87:                                       ; preds = %cond.false86, %cond.true85
  %cond88 = phi %struct._IO_FILE* [ %57, %cond.true85 ], [ %58, %cond.false86 ]
  %call89 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %55, %struct._IO_FILE* %cond88)
  %59 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool90 = icmp ne %struct._IO_FILE* %59, null
  br i1 %tobool90, label %cond.true91, label %cond.false92

cond.true91:                                      ; preds = %cond.end87
  %60 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end93

cond.false92:                                     ; preds = %cond.end87
  %61 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end93

cond.end93:                                       ; preds = %cond.false92, %cond.true91
  %cond94 = phi %struct._IO_FILE* [ %60, %cond.true91 ], [ %61, %cond.false92 ]
  %62 = load i32* %result, align 4
  %call95 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond94, i8* getelementptr inbounds ([8 x i8]* @.str46, i32 0, i32 0), i32 %62)
  br label %if.end96

if.end96:                                         ; preds = %cond.end93, %if.end62
  %63 = load i32* %result, align 4
  store i32 %63, i32* %retval
  br label %return

return:                                           ; preds = %if.end96, %if.then34
  %64 = load i32* %retval
  ret i32 %64
}

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_content_Z(%struct.lp_upolynomial_struct* %p, %struct.__mpz_struct* %content) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %content.addr = alloca %struct.__mpz_struct*, align 8
  %i = alloca i32, align 4
  %tmp = alloca %struct.__mpz_struct, align 8
  %lc = alloca %struct.__mpz_struct*, align 8
  %sgn = alloca i32, align 4
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.__mpz_struct* %content, %struct.__mpz_struct** %content.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 876, i8* getelementptr inbounds ([72 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_content_Z, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %2, i32 0, i32 0
  %3 = load %struct.lp_int_ring_t** %K, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %3, null
  br i1 %cmp, label %cond.true1, label %cond.false2

cond.true1:                                       ; preds = %cond.end
  br label %cond.end3

cond.false2:                                      ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([10 x i8]* @.str47, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 877, i8* getelementptr inbounds ([72 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_content_Z, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end3

cond.end3:                                        ; preds = %4, %cond.true1
  call void @integer_construct_from_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %tmp, i64 0)
  %5 = load %struct.__mpz_struct** %content.addr, align 8
  %6 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %6, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 0
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 1
  call void @integer_assign(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %5, %struct.__mpz_struct* %coefficient)
  %7 = load %struct.__mpz_struct** %content.addr, align 8
  %call = call i32 @integer_sgn(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %7)
  %cmp4 = icmp slt i32 %call, 0
  br i1 %cmp4, label %if.then, label %if.end

if.then:                                          ; preds = %cond.end3
  %8 = load %struct.__mpz_struct** %content.addr, align 8
  call void @integer_neg(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %tmp, %struct.__mpz_struct* %8)
  %9 = load %struct.__mpz_struct** %content.addr, align 8
  call void @integer_swap(%struct.__mpz_struct* %tmp, %struct.__mpz_struct* %9)
  br label %if.end

if.end:                                           ; preds = %if.then, %cond.end3
  store i32 1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.end
  %10 = load i32* %i, align 4
  %conv = zext i32 %10 to i64
  %11 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %11, i32 0, i32 1
  %12 = load i64* %size, align 8
  %cmp5 = icmp ult i64 %conv, %12
  br i1 %cmp5, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %13 = load %struct.__mpz_struct** %content.addr, align 8
  %14 = load i32* %i, align 4
  %idxprom = zext i32 %14 to i64
  %15 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials7 = getelementptr inbounds %struct.lp_upolynomial_struct* %15, i32 0, i32 2
  %arrayidx8 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials7, i32 0, i64 %idxprom
  %coefficient9 = getelementptr inbounds %struct.umonomial_struct* %arrayidx8, i32 0, i32 1
  call void @integer_gcd_Z(%struct.__mpz_struct* %tmp, %struct.__mpz_struct* %13, %struct.__mpz_struct* %coefficient9)
  %16 = load %struct.__mpz_struct** %content.addr, align 8
  call void @integer_swap(%struct.__mpz_struct* %tmp, %struct.__mpz_struct* %16)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %17 = load i32* %i, align 4
  %inc = add i32 %17, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %18 = load %struct.__mpz_struct** %content.addr, align 8
  %call10 = call i32 @integer_sgn(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %18)
  %cmp11 = icmp sgt i32 %call10, 0
  br i1 %cmp11, label %cond.true13, label %cond.false14

cond.true13:                                      ; preds = %for.end
  br label %cond.end15

cond.false14:                                     ; preds = %for.end
  call void @__assert_fail(i8* getelementptr inbounds ([28 x i8]* @.str48, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 895, i8* getelementptr inbounds ([72 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_content_Z, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end15

cond.end15:                                       ; preds = %19, %cond.true13
  %20 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call17 = call %struct.__mpz_struct* @lp_upolynomial_lead_coeff(%struct.lp_upolynomial_struct* %20)
  store %struct.__mpz_struct* %call17, %struct.__mpz_struct** %lc, align 8
  %21 = load %struct.__mpz_struct** %lc, align 8
  %call19 = call i32 @integer_sgn(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %21)
  store i32 %call19, i32* %sgn, align 4
  %22 = load i32* %sgn, align 4
  %cmp20 = icmp slt i32 %22, 0
  br i1 %cmp20, label %if.then22, label %if.end23

if.then22:                                        ; preds = %cond.end15
  %23 = load %struct.__mpz_struct** %content.addr, align 8
  call void @integer_neg(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %tmp, %struct.__mpz_struct* %23)
  %24 = load %struct.__mpz_struct** %content.addr, align 8
  call void @integer_swap(%struct.__mpz_struct* %tmp, %struct.__mpz_struct* %24)
  br label %if.end23

if.end23:                                         ; preds = %if.then22, %cond.end15
  call void @integer_destruct(%struct.__mpz_struct* %tmp)
  ret void
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_neg(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %neg, %struct.__mpz_struct* %a) #4 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %neg.addr = alloca %struct.__mpz_struct*, align 8
  %a.addr = alloca %struct.__mpz_struct*, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %neg, %struct.__mpz_struct** %neg.addr, align 8
  store %struct.__mpz_struct* %a, %struct.__mpz_struct** %a.addr, align 8
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %1 = load %struct.__mpz_struct** %a.addr, align 8
  %call = call i32 @integer_in_ring(%struct.lp_int_ring_t* %0, %struct.__mpz_struct* %1)
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([22 x i8]* @.str72, i32 0, i32 0), i8* getelementptr inbounds ([52 x i8]* @.str70, i32 0, i32 0), i32 295, i8* getelementptr inbounds ([72 x i8]* @__PRETTY_FUNCTION__.integer_neg, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %2, %cond.true
  %3 = load %struct.__mpz_struct** %neg.addr, align 8
  %4 = load %struct.__mpz_struct** %a.addr, align 8
  call void @__gmpz_neg(%struct.__mpz_struct* %3, %struct.__mpz_struct* %4)
  %5 = load %struct.lp_int_ring_t** %K.addr, align 8
  %6 = load %struct.__mpz_struct** %neg.addr, align 8
  call void @integer_ring_normalize(%struct.lp_int_ring_t* %5, %struct.__mpz_struct* %6)
  ret void
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_gcd_Z(%struct.__mpz_struct* %gcd, %struct.__mpz_struct* %a, %struct.__mpz_struct* %b) #4 {
entry:
  %gcd.addr = alloca %struct.__mpz_struct*, align 8
  %a.addr = alloca %struct.__mpz_struct*, align 8
  %b.addr = alloca %struct.__mpz_struct*, align 8
  store %struct.__mpz_struct* %gcd, %struct.__mpz_struct** %gcd.addr, align 8
  store %struct.__mpz_struct* %a, %struct.__mpz_struct** %a.addr, align 8
  store %struct.__mpz_struct* %b, %struct.__mpz_struct** %b.addr, align 8
  %0 = load %struct.__mpz_struct** %gcd.addr, align 8
  %1 = load %struct.__mpz_struct** %a.addr, align 8
  %2 = load %struct.__mpz_struct** %b.addr, align 8
  call void @__gmpz_gcd(%struct.__mpz_struct* %0, %struct.__mpz_struct* %1, %struct.__mpz_struct* %2)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @lp_upolynomial_is_primitive(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %content = alloca %struct.__mpz_struct, align 8
  %is_primitive = alloca i32, align 4
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %0, i32 0, i32 0
  %1 = load %struct.lp_int_ring_t** %K, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %1, null
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([10 x i8]* @.str47, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 909, i8* getelementptr inbounds ([58 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_is_primitive, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %2, %cond.true
  call void @integer_construct_from_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %content, i64 0)
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  call void @lp_upolynomial_content_Z(%struct.lp_upolynomial_struct* %3, %struct.__mpz_struct* %content)
  %call = call i32 @integer_cmp_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %content, i64 1)
  %cmp1 = icmp eq i32 %call, 0
  br i1 %cmp1, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %cond.end
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call2 = call %struct.__mpz_struct* @lp_upolynomial_lead_coeff(%struct.lp_upolynomial_struct* %4)
  %call3 = call i32 @integer_sgn(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %call2)
  %cmp4 = icmp sgt i32 %call3, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %cond.end
  %5 = phi i1 [ false, %cond.end ], [ %cmp4, %land.rhs ]
  %land.ext = zext i1 %5 to i32
  store i32 %land.ext, i32* %is_primitive, align 4
  call void @integer_destruct(%struct.__mpz_struct* %content)
  %6 = load i32* %is_primitive, align 4
  ret i32 %6
}

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_make_primitive_Z(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %gcd = alloca %struct.__mpz_struct, align 8
  %tmp = alloca %struct.__mpz_struct, align 8
  %i = alloca i32, align 4
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %0, i32 0, i32 0
  %1 = load %struct.lp_int_ring_t** %K, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %1, null
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([10 x i8]* @.str47, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 919, i8* getelementptr inbounds ([57 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_make_primitive_Z, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %2, %cond.true
  call void @integer_construct_from_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %gcd, i64 0)
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  call void @lp_upolynomial_content_Z(%struct.lp_upolynomial_struct* %3, %struct.__mpz_struct* %gcd)
  call void @integer_construct_from_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %tmp, i64 0)
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %cond.end
  %4 = load i32* %i, align 4
  %conv = zext i32 %4 to i64
  %5 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %5, i32 0, i32 1
  %6 = load i64* %size, align 8
  %cmp2 = icmp ult i64 %conv, %6
  br i1 %cmp2, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %7 = load i32* %i, align 4
  %idxprom = zext i32 %7 to i64
  %8 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %8, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %idxprom
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 1
  %call = call i32 @integer_divides(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %gcd, %struct.__mpz_struct* %coefficient)
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %for.body
  br label %cond.end6

cond.false5:                                      ; preds = %for.body
  call void @__assert_fail(i8* getelementptr inbounds ([55 x i8]* @.str49, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 929, i8* getelementptr inbounds ([57 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_make_primitive_Z, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end6

cond.end6:                                        ; preds = %9, %cond.true4
  %10 = load i32* %i, align 4
  %idxprom7 = zext i32 %10 to i64
  %11 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials8 = getelementptr inbounds %struct.lp_upolynomial_struct* %11, i32 0, i32 2
  %arrayidx9 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials8, i32 0, i64 %idxprom7
  %coefficient10 = getelementptr inbounds %struct.umonomial_struct* %arrayidx9, i32 0, i32 1
  call void @integer_div_exact(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %tmp, %struct.__mpz_struct* %coefficient10, %struct.__mpz_struct* %gcd)
  %12 = load i32* %i, align 4
  %idxprom11 = zext i32 %12 to i64
  %13 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials12 = getelementptr inbounds %struct.lp_upolynomial_struct* %13, i32 0, i32 2
  %arrayidx13 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials12, i32 0, i64 %idxprom11
  %coefficient14 = getelementptr inbounds %struct.umonomial_struct* %arrayidx13, i32 0, i32 1
  call void @integer_swap(%struct.__mpz_struct* %tmp, %struct.__mpz_struct* %coefficient14)
  br label %for.inc

for.inc:                                          ; preds = %cond.end6
  %14 = load i32* %i, align 4
  %inc = add i32 %14, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  call void @integer_destruct(%struct.__mpz_struct* %gcd)
  call void @integer_destruct(%struct.__mpz_struct* %tmp)
  ret void
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_primitive_part_Z(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %result = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %tobool = icmp ne %struct.lp_upolynomial_struct* %0, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([2 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 939, i8* getelementptr inbounds ([76 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_primitive_part_Z, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %2, i32 0, i32 0
  %3 = load %struct.lp_int_ring_t** %K, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %3, null
  br i1 %cmp, label %cond.true1, label %cond.false2

cond.true1:                                       ; preds = %cond.end
  br label %cond.end3

cond.false2:                                      ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([10 x i8]* @.str47, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 940, i8* getelementptr inbounds ([76 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_primitive_part_Z, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end3

cond.end3:                                        ; preds = %4, %cond.true1
  %5 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy(%struct.lp_upolynomial_struct* %5)
  store %struct.lp_upolynomial_struct* %call, %struct.lp_upolynomial_struct** %result, align 8
  %6 = load %struct.lp_upolynomial_struct** %result, align 8
  call void @lp_upolynomial_make_primitive_Z(%struct.lp_upolynomial_struct* %6)
  %7 = load %struct.lp_upolynomial_struct** %result, align 8
  ret %struct.lp_upolynomial_struct* %7
}

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_evaluate_at_integer(%struct.lp_upolynomial_struct* %p, %struct.__mpz_struct* %x, %struct.__mpz_struct* %value) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %x.addr = alloca %struct.__mpz_struct*, align 8
  %value.addr = alloca %struct.__mpz_struct*, align 8
  %K = alloca %struct.lp_int_ring_t*, align 8
  %power = alloca %struct.__mpz_struct, align 8
  %i = alloca i64, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.__mpz_struct* %x, %struct.__mpz_struct** %x.addr, align 8
  store %struct.__mpz_struct* %value, %struct.__mpz_struct** %value.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K1 = getelementptr inbounds %struct.lp_upolynomial_struct* %0, i32 0, i32 0
  %1 = load %struct.lp_int_ring_t** %K1, align 8
  store %struct.lp_int_ring_t* %1, %struct.lp_int_ring_t** %K, align 8
  call void @integer_construct_from_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %power, i64 0)
  %2 = load %struct.__mpz_struct** %value.addr, align 8
  call void @integer_assign_int(%struct.lp_int_ring_t* null, %struct.__mpz_struct* %2, i64 0)
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %3 = load i64* %i, align 8
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %4, i32 0, i32 1
  %5 = load i64* %size, align 8
  %cmp = icmp ult i64 %3, %5
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %6 = load %struct.lp_int_ring_t** %K, align 8
  %7 = load %struct.__mpz_struct** %x.addr, align 8
  %8 = load i64* %i, align 8
  %9 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %9, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %8
  %degree = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 0
  %10 = load i64* %degree, align 8
  %conv = trunc i64 %10 to i32
  call void @integer_pow(%struct.lp_int_ring_t* %6, %struct.__mpz_struct* %power, %struct.__mpz_struct* %7, i32 %conv)
  %11 = load %struct.lp_int_ring_t** %K, align 8
  %12 = load %struct.__mpz_struct** %value.addr, align 8
  %13 = load i64* %i, align 8
  %14 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials2 = getelementptr inbounds %struct.lp_upolynomial_struct* %14, i32 0, i32 2
  %arrayidx3 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials2, i32 0, i64 %13
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx3, i32 0, i32 1
  call void @integer_add_mul(%struct.lp_int_ring_t* %11, %struct.__mpz_struct* %12, %struct.__mpz_struct* %coefficient, %struct.__mpz_struct* %power)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %15 = load i64* %i, align 8
  %inc = add i64 %15, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

for.end:                                          ; preds = %for.cond
  call void @integer_destruct(%struct.__mpz_struct* %power)
  ret void
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_assign_int(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c, i64 %from) #4 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %c.addr = alloca %struct.__mpz_struct*, align 8
  %from.addr = alloca i64, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %c, %struct.__mpz_struct** %c.addr, align 8
  store i64 %from, i64* %from.addr, align 8
  %0 = load %struct.__mpz_struct** %c.addr, align 8
  %1 = load i64* %from.addr, align 8
  call void @__gmpz_set_si(%struct.__mpz_struct* %0, i64 %1)
  %2 = load %struct.lp_int_ring_t** %K.addr, align 8
  %3 = load %struct.__mpz_struct** %c.addr, align 8
  call void @integer_ring_normalize(%struct.lp_int_ring_t* %2, %struct.__mpz_struct* %3)
  ret void
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_add_mul(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %sum_product, %struct.__mpz_struct* %a, %struct.__mpz_struct* %b) #4 {
entry:
  %K.addr = alloca %struct.lp_int_ring_t*, align 8
  %sum_product.addr = alloca %struct.__mpz_struct*, align 8
  %a.addr = alloca %struct.__mpz_struct*, align 8
  %b.addr = alloca %struct.__mpz_struct*, align 8
  store %struct.lp_int_ring_t* %K, %struct.lp_int_ring_t** %K.addr, align 8
  store %struct.__mpz_struct* %sum_product, %struct.__mpz_struct** %sum_product.addr, align 8
  store %struct.__mpz_struct* %a, %struct.__mpz_struct** %a.addr, align 8
  store %struct.__mpz_struct* %b, %struct.__mpz_struct** %b.addr, align 8
  %0 = load %struct.lp_int_ring_t** %K.addr, align 8
  %1 = load %struct.__mpz_struct** %sum_product.addr, align 8
  %call = call i32 @integer_in_ring(%struct.lp_int_ring_t* %0, %struct.__mpz_struct* %1)
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %land.lhs.true, label %cond.false

land.lhs.true:                                    ; preds = %entry
  %2 = load %struct.lp_int_ring_t** %K.addr, align 8
  %3 = load %struct.__mpz_struct** %a.addr, align 8
  %call1 = call i32 @integer_in_ring(%struct.lp_int_ring_t* %2, %struct.__mpz_struct* %3)
  %tobool2 = icmp ne i32 %call1, 0
  br i1 %tobool2, label %land.lhs.true3, label %cond.false

land.lhs.true3:                                   ; preds = %land.lhs.true
  %4 = load %struct.lp_int_ring_t** %K.addr, align 8
  %5 = load %struct.__mpz_struct** %b.addr, align 8
  %call4 = call i32 @integer_in_ring(%struct.lp_int_ring_t* %4, %struct.__mpz_struct* %5)
  %tobool5 = icmp ne i32 %call4, 0
  br i1 %tobool5, label %cond.true, label %cond.false

cond.true:                                        ; preds = %land.lhs.true3
  br label %cond.end

cond.false:                                       ; preds = %land.lhs.true3, %land.lhs.true, %entry
  call void @__assert_fail(i8* getelementptr inbounds ([82 x i8]* @.str69, i32 0, i32 0), i8* getelementptr inbounds ([52 x i8]* @.str70, i32 0, i32 0), i32 356, i8* getelementptr inbounds ([98 x i8]* @__PRETTY_FUNCTION__.integer_add_mul, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %6, %cond.true
  %7 = load %struct.__mpz_struct** %sum_product.addr, align 8
  %8 = load %struct.__mpz_struct** %a.addr, align 8
  %9 = load %struct.__mpz_struct** %b.addr, align 8
  call void @__gmpz_addmul(%struct.__mpz_struct* %7, %struct.__mpz_struct* %8, %struct.__mpz_struct* %9)
  %10 = load %struct.lp_int_ring_t** %K.addr, align 8
  %11 = load %struct.__mpz_struct** %sum_product.addr, align 8
  call void @integer_ring_normalize(%struct.lp_int_ring_t* %10, %struct.__mpz_struct* %11)
  ret void
}

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_evaluate_at_rational(%struct.lp_upolynomial_struct* %p, %struct.__mpq_struct* %x, %struct.__mpq_struct* %value) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %x.addr = alloca %struct.__mpq_struct*, align 8
  %value.addr = alloca %struct.__mpq_struct*, align 8
  %p_d = alloca %struct.upolynomial_dense_t, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.__mpq_struct* %x, %struct.__mpq_struct** %x.addr, align 8
  store %struct.__mpq_struct* %value, %struct.__mpq_struct** %value.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %0, i32 0, i32 0
  %1 = load %struct.lp_int_ring_t** %K, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %1, null
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([10 x i8]* @.str47, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 965, i8* getelementptr inbounds ([107 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_evaluate_at_rational, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %2, %cond.true
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %3)
  %add = add i64 %call, 1
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  call void @upolynomial_dense_construct_p(%struct.upolynomial_dense_t* %p_d, i64 %add, %struct.lp_upolynomial_struct* %4)
  %5 = load %struct.__mpq_struct** %x.addr, align 8
  %6 = load %struct.__mpq_struct** %value.addr, align 8
  call void @upolynomial_dense_evaluate_at_rational(%struct.upolynomial_dense_t* %p_d, %struct.__mpq_struct* %5, %struct.__mpq_struct* %6)
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %p_d)
  ret void
}

declare void @upolynomial_dense_evaluate_at_rational(%struct.upolynomial_dense_t*, %struct.__mpq_struct*, %struct.__mpq_struct*) #3

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_evaluate_at_dyadic_rational(%struct.lp_upolynomial_struct* %p, %struct.lp_dyadic_rational_t* %x, %struct.lp_dyadic_rational_t* %value) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %x.addr = alloca %struct.lp_dyadic_rational_t*, align 8
  %value.addr = alloca %struct.lp_dyadic_rational_t*, align 8
  %p_d = alloca %struct.upolynomial_dense_t, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_dyadic_rational_t* %x, %struct.lp_dyadic_rational_t** %x.addr, align 8
  store %struct.lp_dyadic_rational_t* %value, %struct.lp_dyadic_rational_t** %value.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %0, i32 0, i32 0
  %1 = load %struct.lp_int_ring_t** %K, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %1, null
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([10 x i8]* @.str47, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 973, i8* getelementptr inbounds ([128 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_evaluate_at_dyadic_rational, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %2, %cond.true
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %3)
  %add = add i64 %call, 1
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  call void @upolynomial_dense_construct_p(%struct.upolynomial_dense_t* %p_d, i64 %add, %struct.lp_upolynomial_struct* %4)
  %5 = load %struct.lp_dyadic_rational_t** %x.addr, align 8
  %6 = load %struct.lp_dyadic_rational_t** %value.addr, align 8
  call void @upolynomial_dense_evaluate_at_dyadic_rational(%struct.upolynomial_dense_t* %p_d, %struct.lp_dyadic_rational_t* %5, %struct.lp_dyadic_rational_t* %6)
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %p_d)
  ret void
}

declare void @upolynomial_dense_evaluate_at_dyadic_rational(%struct.upolynomial_dense_t*, %struct.lp_dyadic_rational_t*, %struct.lp_dyadic_rational_t*) #3

; Function Attrs: nounwind uwtable
define i32 @lp_upolynomial_sgn_at_integer(%struct.lp_upolynomial_struct* %p, %struct.__mpz_struct* %x) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %x.addr = alloca %struct.__mpz_struct*, align 8
  %value = alloca %struct.__mpz_struct, align 8
  %sgn = alloca i32, align 4
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.__mpz_struct* %x, %struct.__mpz_struct** %x.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %0, i32 0, i32 0
  %1 = load %struct.lp_int_ring_t** %K, align 8
  call void @integer_construct_from_int(%struct.lp_int_ring_t* %1, %struct.__mpz_struct* %value, i64 0)
  %2 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %3 = load %struct.__mpz_struct** %x.addr, align 8
  call void @lp_upolynomial_evaluate_at_integer(%struct.lp_upolynomial_struct* %2, %struct.__mpz_struct* %3, %struct.__mpz_struct* %value)
  %4 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K1 = getelementptr inbounds %struct.lp_upolynomial_struct* %4, i32 0, i32 0
  %5 = load %struct.lp_int_ring_t** %K1, align 8
  %call = call i32 @integer_sgn(%struct.lp_int_ring_t* %5, %struct.__mpz_struct* %value)
  store i32 %call, i32* %sgn, align 4
  call void @integer_destruct(%struct.__mpz_struct* %value)
  %6 = load i32* %sgn, align 4
  ret i32 %6
}

; Function Attrs: nounwind uwtable
define i32 @lp_upolynomial_sgn_at_rational(%struct.lp_upolynomial_struct* %p, %struct.__mpq_struct* %x) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %x.addr = alloca %struct.__mpq_struct*, align 8
  %value = alloca %struct.__mpq_struct, align 8
  %sgn = alloca i32, align 4
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.__mpq_struct* %x, %struct.__mpq_struct** %x.addr, align 8
  call void @rational_construct(%struct.__mpq_struct* %value)
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %1 = load %struct.__mpq_struct** %x.addr, align 8
  call void @lp_upolynomial_evaluate_at_rational(%struct.lp_upolynomial_struct* %0, %struct.__mpq_struct* %1, %struct.__mpq_struct* %value)
  %call = call i32 @rational_sgn(%struct.__mpq_struct* %value)
  store i32 %call, i32* %sgn, align 4
  call void @rational_destruct(%struct.__mpq_struct* %value)
  %2 = load i32* %sgn, align 4
  ret i32 %2
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @rational_construct(%struct.__mpq_struct* %q) #4 {
entry:
  %q.addr = alloca %struct.__mpq_struct*, align 8
  store %struct.__mpq_struct* %q, %struct.__mpq_struct** %q.addr, align 8
  %0 = load %struct.__mpq_struct** %q.addr, align 8
  call void @__gmpq_init(%struct.__mpq_struct* %0)
  ret void
}

; Function Attrs: inlinehint nounwind uwtable
define internal i32 @rational_sgn(%struct.__mpq_struct* %q) #4 {
entry:
  %q.addr = alloca %struct.__mpq_struct*, align 8
  store %struct.__mpq_struct* %q, %struct.__mpq_struct** %q.addr, align 8
  %0 = load %struct.__mpq_struct** %q.addr, align 8
  %_mp_num = getelementptr inbounds %struct.__mpq_struct* %0, i32 0, i32 0
  %_mp_size = getelementptr inbounds %struct.__mpz_struct* %_mp_num, i32 0, i32 1
  %1 = load i32* %_mp_size, align 4
  %cmp = icmp slt i32 %1, 0
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load %struct.__mpq_struct** %q.addr, align 8
  %_mp_num1 = getelementptr inbounds %struct.__mpq_struct* %2, i32 0, i32 0
  %_mp_size2 = getelementptr inbounds %struct.__mpz_struct* %_mp_num1, i32 0, i32 1
  %3 = load i32* %_mp_size2, align 4
  %cmp3 = icmp sgt i32 %3, 0
  %conv = zext i1 %cmp3 to i32
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ -1, %cond.true ], [ %conv, %cond.false ]
  ret i32 %cond
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @rational_destruct(%struct.__mpq_struct* %q) #4 {
entry:
  %q.addr = alloca %struct.__mpq_struct*, align 8
  store %struct.__mpq_struct* %q, %struct.__mpq_struct** %q.addr, align 8
  %0 = load %struct.__mpq_struct** %q.addr, align 8
  call void @__gmpq_clear(%struct.__mpq_struct* %0)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @lp_upolynomial_sgn_at_dyadic_rational(%struct.lp_upolynomial_struct* %p, %struct.lp_dyadic_rational_t* %x) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %x.addr = alloca %struct.lp_dyadic_rational_t*, align 8
  %value = alloca %struct.lp_dyadic_rational_t, align 8
  %sgn = alloca i32, align 4
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_dyadic_rational_t* %x, %struct.lp_dyadic_rational_t** %x.addr, align 8
  call void @dyadic_rational_construct(%struct.lp_dyadic_rational_t* %value)
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %1 = load %struct.lp_dyadic_rational_t** %x.addr, align 8
  call void @lp_upolynomial_evaluate_at_dyadic_rational(%struct.lp_upolynomial_struct* %0, %struct.lp_dyadic_rational_t* %1, %struct.lp_dyadic_rational_t* %value)
  %call = call i32 @dyadic_rational_sgn(%struct.lp_dyadic_rational_t* %value)
  store i32 %call, i32* %sgn, align 4
  call void @dyadic_rational_destruct(%struct.lp_dyadic_rational_t* %value)
  %2 = load i32* %sgn, align 4
  ret i32 %2
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @dyadic_rational_construct(%struct.lp_dyadic_rational_t* %q) #4 {
entry:
  %q.addr = alloca %struct.lp_dyadic_rational_t*, align 8
  store %struct.lp_dyadic_rational_t* %q, %struct.lp_dyadic_rational_t** %q.addr, align 8
  %0 = load %struct.lp_dyadic_rational_t** %q.addr, align 8
  %a = getelementptr inbounds %struct.lp_dyadic_rational_t* %0, i32 0, i32 0
  call void @__gmpz_init(%struct.__mpz_struct* %a)
  %1 = load %struct.lp_dyadic_rational_t** %q.addr, align 8
  %n = getelementptr inbounds %struct.lp_dyadic_rational_t* %1, i32 0, i32 1
  store i64 0, i64* %n, align 8
  ret void
}

; Function Attrs: inlinehint nounwind uwtable
define internal i32 @dyadic_rational_sgn(%struct.lp_dyadic_rational_t* %q) #4 {
entry:
  %q.addr = alloca %struct.lp_dyadic_rational_t*, align 8
  store %struct.lp_dyadic_rational_t* %q, %struct.lp_dyadic_rational_t** %q.addr, align 8
  %0 = load %struct.lp_dyadic_rational_t** %q.addr, align 8
  %call = call i32 @dyadic_rational_is_normalized(%struct.lp_dyadic_rational_t* %0)
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @__assert_fail(i8* getelementptr inbounds ([33 x i8]* @.str67, i32 0, i32 0), i8* getelementptr inbounds ([60 x i8]* @.str68, i32 0, i32 0), i32 137, i8* getelementptr inbounds ([54 x i8]* @__PRETTY_FUNCTION__.dyadic_rational_sgn, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %1, %cond.true
  %2 = load %struct.lp_dyadic_rational_t** %q.addr, align 8
  %a = getelementptr inbounds %struct.lp_dyadic_rational_t* %2, i32 0, i32 0
  %_mp_size = getelementptr inbounds %struct.__mpz_struct* %a, i32 0, i32 1
  %3 = load i32* %_mp_size, align 4
  %cmp = icmp slt i32 %3, 0
  br i1 %cmp, label %cond.true1, label %cond.false2

cond.true1:                                       ; preds = %cond.end
  br label %cond.end6

cond.false2:                                      ; preds = %cond.end
  %4 = load %struct.lp_dyadic_rational_t** %q.addr, align 8
  %a3 = getelementptr inbounds %struct.lp_dyadic_rational_t* %4, i32 0, i32 0
  %_mp_size4 = getelementptr inbounds %struct.__mpz_struct* %a3, i32 0, i32 1
  %5 = load i32* %_mp_size4, align 4
  %cmp5 = icmp sgt i32 %5, 0
  %conv = zext i1 %cmp5 to i32
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false2, %cond.true1
  %cond = phi i32 [ -1, %cond.true1 ], [ %conv, %cond.false2 ]
  ret i32 %cond
}

; Function Attrs: inlinehint nounwind uwtable
define internal void @dyadic_rational_destruct(%struct.lp_dyadic_rational_t* %q) #4 {
entry:
  %q.addr = alloca %struct.lp_dyadic_rational_t*, align 8
  store %struct.lp_dyadic_rational_t* %q, %struct.lp_dyadic_rational_t** %q.addr, align 8
  %0 = load %struct.lp_dyadic_rational_t** %q.addr, align 8
  %a = getelementptr inbounds %struct.lp_dyadic_rational_t* %0, i32 0, i32 0
  call void @__gmpz_clear(%struct.__mpz_struct* %a)
  ret void
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_gcd(%struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %gcd = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([4 x i8]* @.str50, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([17 x i8]* @.str51, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %10 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %11 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool15 = icmp ne %struct._IO_FILE* %11, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %cond.end12
  %12 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end18

cond.false17:                                     ; preds = %cond.end12
  %13 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false17, %cond.true16
  %cond19 = phi %struct._IO_FILE* [ %12, %cond.true16 ], [ %13, %cond.false17 ]
  %call20 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %10, %struct._IO_FILE* %cond19)
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool21 = icmp ne %struct._IO_FILE* %14, null
  br i1 %tobool21, label %cond.true22, label %cond.false23

cond.true22:                                      ; preds = %cond.end18
  %15 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end24

cond.false23:                                     ; preds = %cond.end18
  %16 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end24

cond.end24:                                       ; preds = %cond.false23, %cond.true22
  %cond25 = phi %struct._IO_FILE* [ %15, %cond.true22 ], [ %16, %cond.false23 ]
  %call26 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond25, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end24, %entry
  %17 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %17, i32 0, i32 0
  %18 = load %struct.lp_int_ring_t** %K, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %18, null
  br i1 %cmp, label %cond.true29, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %if.end
  %19 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K27 = getelementptr inbounds %struct.lp_upolynomial_struct* %19, i32 0, i32 0
  %20 = load %struct.lp_int_ring_t** %K27, align 8
  %is_prime = getelementptr inbounds %struct.lp_int_ring_t* %20, i32 0, i32 1
  %21 = load i32* %is_prime, align 4
  %tobool28 = icmp ne i32 %21, 0
  br i1 %tobool28, label %cond.true29, label %cond.false30

cond.true29:                                      ; preds = %lor.lhs.false, %if.end
  br label %cond.end31

cond.false30:                                     ; preds = %lor.lhs.false
  call void @__assert_fail(i8* getelementptr inbounds ([28 x i8]* @.str52, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 1013, i8* getelementptr inbounds ([89 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_gcd, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end31

cond.end31:                                       ; preds = %22, %cond.true29
  store %struct.lp_upolynomial_struct* null, %struct.lp_upolynomial_struct** %gcd, align 8
  %23 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call32 = call i32 @lp_upolynomial_is_zero(%struct.lp_upolynomial_struct* %23)
  %tobool33 = icmp ne i32 %call32, 0
  br i1 %tobool33, label %if.then34, label %if.else

if.then34:                                        ; preds = %cond.end31
  %24 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call35 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy(%struct.lp_upolynomial_struct* %24)
  store %struct.lp_upolynomial_struct* %call35, %struct.lp_upolynomial_struct** %gcd, align 8
  br label %if.end60

if.else:                                          ; preds = %cond.end31
  %25 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call36 = call i32 @lp_upolynomial_is_zero(%struct.lp_upolynomial_struct* %25)
  %tobool37 = icmp ne i32 %call36, 0
  br i1 %tobool37, label %if.then38, label %if.else40

if.then38:                                        ; preds = %if.else
  %26 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call39 = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy(%struct.lp_upolynomial_struct* %26)
  store %struct.lp_upolynomial_struct* %call39, %struct.lp_upolynomial_struct** %gcd, align 8
  br label %if.end59

if.else40:                                        ; preds = %if.else
  %27 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call41 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %27)
  %28 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call42 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %28)
  %cmp43 = icmp ult i64 %call41, %call42
  br i1 %cmp43, label %if.then44, label %if.else46

if.then44:                                        ; preds = %if.else40
  %29 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %30 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call45 = call %struct.lp_upolynomial_struct* @lp_upolynomial_gcd(%struct.lp_upolynomial_struct* %29, %struct.lp_upolynomial_struct* %30)
  store %struct.lp_upolynomial_struct* %call45, %struct.lp_upolynomial_struct** %gcd, align 8
  br label %if.end58

if.else46:                                        ; preds = %if.else40
  %31 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K47 = getelementptr inbounds %struct.lp_upolynomial_struct* %31, i32 0, i32 0
  %32 = load %struct.lp_int_ring_t** %K47, align 8
  %cmp48 = icmp eq %struct.lp_int_ring_t* %32, null
  br i1 %cmp48, label %if.then49, label %if.else55

if.then49:                                        ; preds = %if.else46
  %33 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %34 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call50 = call %struct.lp_upolynomial_struct* @upolynomial_gcd_heuristic(%struct.lp_upolynomial_struct* %33, %struct.lp_upolynomial_struct* %34, i32 2)
  store %struct.lp_upolynomial_struct* %call50, %struct.lp_upolynomial_struct** %gcd, align 8
  %35 = load %struct.lp_upolynomial_struct** %gcd, align 8
  %tobool51 = icmp ne %struct.lp_upolynomial_struct* %35, null
  br i1 %tobool51, label %if.end54, label %if.then52

if.then52:                                        ; preds = %if.then49
  %36 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %37 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call53 = call %struct.lp_upolynomial_struct* @upolynomial_gcd_subresultant(%struct.lp_upolynomial_struct* %36, %struct.lp_upolynomial_struct* %37)
  store %struct.lp_upolynomial_struct* %call53, %struct.lp_upolynomial_struct** %gcd, align 8
  br label %if.end54

if.end54:                                         ; preds = %if.then52, %if.then49
  br label %if.end57

if.else55:                                        ; preds = %if.else46
  %38 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %39 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call56 = call %struct.lp_upolynomial_struct* @upolynomial_gcd_euclid(%struct.lp_upolynomial_struct* %38, %struct.lp_upolynomial_struct* %39, %struct.lp_upolynomial_struct** null, %struct.lp_upolynomial_struct** null)
  store %struct.lp_upolynomial_struct* %call56, %struct.lp_upolynomial_struct** %gcd, align 8
  br label %if.end57

if.end57:                                         ; preds = %if.else55, %if.end54
  br label %if.end58

if.end58:                                         ; preds = %if.end57, %if.then44
  br label %if.end59

if.end59:                                         ; preds = %if.end58, %if.then38
  br label %if.end60

if.end60:                                         ; preds = %if.end59, %if.then34
  %call61 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([4 x i8]* @.str50, i32 0, i32 0))
  %tobool62 = icmp ne i32 %call61, 0
  br i1 %tobool62, label %if.then63, label %if.end106

if.then63:                                        ; preds = %if.end60
  %40 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool64 = icmp ne %struct._IO_FILE* %40, null
  br i1 %tobool64, label %cond.true65, label %cond.false66

cond.true65:                                      ; preds = %if.then63
  %41 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end67

cond.false66:                                     ; preds = %if.then63
  %42 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end67

cond.end67:                                       ; preds = %cond.false66, %cond.true65
  %cond68 = phi %struct._IO_FILE* [ %41, %cond.true65 ], [ %42, %cond.false66 ]
  %call69 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond68, i8* getelementptr inbounds ([17 x i8]* @.str51, i32 0, i32 0))
  %43 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %44 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool70 = icmp ne %struct._IO_FILE* %44, null
  br i1 %tobool70, label %cond.true71, label %cond.false72

cond.true71:                                      ; preds = %cond.end67
  %45 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end73

cond.false72:                                     ; preds = %cond.end67
  %46 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end73

cond.end73:                                       ; preds = %cond.false72, %cond.true71
  %cond74 = phi %struct._IO_FILE* [ %45, %cond.true71 ], [ %46, %cond.false72 ]
  %call75 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %43, %struct._IO_FILE* %cond74)
  %47 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool76 = icmp ne %struct._IO_FILE* %47, null
  br i1 %tobool76, label %cond.true77, label %cond.false78

cond.true77:                                      ; preds = %cond.end73
  %48 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end79

cond.false78:                                     ; preds = %cond.end73
  %49 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end79

cond.end79:                                       ; preds = %cond.false78, %cond.true77
  %cond80 = phi %struct._IO_FILE* [ %48, %cond.true77 ], [ %49, %cond.false78 ]
  %call81 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond80, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %50 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %51 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool82 = icmp ne %struct._IO_FILE* %51, null
  br i1 %tobool82, label %cond.true83, label %cond.false84

cond.true83:                                      ; preds = %cond.end79
  %52 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end85

cond.false84:                                     ; preds = %cond.end79
  %53 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end85

cond.end85:                                       ; preds = %cond.false84, %cond.true83
  %cond86 = phi %struct._IO_FILE* [ %52, %cond.true83 ], [ %53, %cond.false84 ]
  %call87 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %50, %struct._IO_FILE* %cond86)
  %54 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool88 = icmp ne %struct._IO_FILE* %54, null
  br i1 %tobool88, label %cond.true89, label %cond.false90

cond.true89:                                      ; preds = %cond.end85
  %55 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end91

cond.false90:                                     ; preds = %cond.end85
  %56 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end91

cond.end91:                                       ; preds = %cond.false90, %cond.true89
  %cond92 = phi %struct._IO_FILE* [ %55, %cond.true89 ], [ %56, %cond.false90 ]
  %call93 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond92, i8* getelementptr inbounds ([5 x i8]* @.str10, i32 0, i32 0))
  %57 = load %struct.lp_upolynomial_struct** %gcd, align 8
  %58 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool94 = icmp ne %struct._IO_FILE* %58, null
  br i1 %tobool94, label %cond.true95, label %cond.false96

cond.true95:                                      ; preds = %cond.end91
  %59 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end97

cond.false96:                                     ; preds = %cond.end91
  %60 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end97

cond.end97:                                       ; preds = %cond.false96, %cond.true95
  %cond98 = phi %struct._IO_FILE* [ %59, %cond.true95 ], [ %60, %cond.false96 ]
  %call99 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %57, %struct._IO_FILE* %cond98)
  %61 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool100 = icmp ne %struct._IO_FILE* %61, null
  br i1 %tobool100, label %cond.true101, label %cond.false102

cond.true101:                                     ; preds = %cond.end97
  %62 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end103

cond.false102:                                    ; preds = %cond.end97
  %63 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end103

cond.end103:                                      ; preds = %cond.false102, %cond.true101
  %cond104 = phi %struct._IO_FILE* [ %62, %cond.true101 ], [ %63, %cond.false102 ]
  %call105 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond104, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end106

if.end106:                                        ; preds = %cond.end103, %if.end60
  %64 = load %struct.lp_upolynomial_struct** %gcd, align 8
  ret %struct.lp_upolynomial_struct* %64
}

declare %struct.lp_upolynomial_struct* @upolynomial_gcd_heuristic(%struct.lp_upolynomial_struct*, %struct.lp_upolynomial_struct*, i32) #3

declare %struct.lp_upolynomial_struct* @upolynomial_gcd_subresultant(%struct.lp_upolynomial_struct*, %struct.lp_upolynomial_struct*) #3

declare %struct.lp_upolynomial_struct* @upolynomial_gcd_euclid(%struct.lp_upolynomial_struct*, %struct.lp_upolynomial_struct*, %struct.lp_upolynomial_struct**, %struct.lp_upolynomial_struct**) #3

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_extended_gcd(%struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %u, %struct.lp_upolynomial_struct** %v) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %u.addr = alloca %struct.lp_upolynomial_struct**, align 8
  %v.addr = alloca %struct.lp_upolynomial_struct**, align 8
  %gcd = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  store %struct.lp_upolynomial_struct** %u, %struct.lp_upolynomial_struct*** %u.addr, align 8
  store %struct.lp_upolynomial_struct** %v, %struct.lp_upolynomial_struct*** %v.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([4 x i8]* @.str50, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([17 x i8]* @.str51, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %10 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %11 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool15 = icmp ne %struct._IO_FILE* %11, null
  br i1 %tobool15, label %cond.true16, label %cond.false17

cond.true16:                                      ; preds = %cond.end12
  %12 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end18

cond.false17:                                     ; preds = %cond.end12
  %13 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end18

cond.end18:                                       ; preds = %cond.false17, %cond.true16
  %cond19 = phi %struct._IO_FILE* [ %12, %cond.true16 ], [ %13, %cond.false17 ]
  %call20 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %10, %struct._IO_FILE* %cond19)
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool21 = icmp ne %struct._IO_FILE* %14, null
  br i1 %tobool21, label %cond.true22, label %cond.false23

cond.true22:                                      ; preds = %cond.end18
  %15 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end24

cond.false23:                                     ; preds = %cond.end18
  %16 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end24

cond.end24:                                       ; preds = %cond.false23, %cond.true22
  %cond25 = phi %struct._IO_FILE* [ %15, %cond.true22 ], [ %16, %cond.false23 ]
  %call26 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond25, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end24, %entry
  %17 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %17, i32 0, i32 0
  %18 = load %struct.lp_int_ring_t** %K, align 8
  %tobool27 = icmp ne %struct.lp_int_ring_t* %18, null
  br i1 %tobool27, label %land.lhs.true, label %cond.false31

land.lhs.true:                                    ; preds = %if.end
  %19 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K28 = getelementptr inbounds %struct.lp_upolynomial_struct* %19, i32 0, i32 0
  %20 = load %struct.lp_int_ring_t** %K28, align 8
  %is_prime = getelementptr inbounds %struct.lp_int_ring_t* %20, i32 0, i32 1
  %21 = load i32* %is_prime, align 4
  %tobool29 = icmp ne i32 %21, 0
  br i1 %tobool29, label %cond.true30, label %cond.false31

cond.true30:                                      ; preds = %land.lhs.true
  br label %cond.end32

cond.false31:                                     ; preds = %land.lhs.true, %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([23 x i8]* @.str53, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 1047, i8* getelementptr inbounds ([140 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_extended_gcd, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end32

cond.end32:                                       ; preds = %22, %cond.true30
  %23 = load %struct.lp_upolynomial_struct*** %u.addr, align 8
  %24 = load %struct.lp_upolynomial_struct** %23, align 8
  %cmp = icmp eq %struct.lp_upolynomial_struct* %24, null
  br i1 %cmp, label %cond.true33, label %cond.false34

cond.true33:                                      ; preds = %cond.end32
  br label %cond.end35

cond.false34:                                     ; preds = %cond.end32
  call void @__assert_fail(i8* getelementptr inbounds ([8 x i8]* @.str54, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 1048, i8* getelementptr inbounds ([140 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_extended_gcd, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end35

cond.end35:                                       ; preds = %25, %cond.true33
  %26 = load %struct.lp_upolynomial_struct*** %v.addr, align 8
  %27 = load %struct.lp_upolynomial_struct** %26, align 8
  %cmp36 = icmp eq %struct.lp_upolynomial_struct* %27, null
  br i1 %cmp36, label %cond.true37, label %cond.false38

cond.true37:                                      ; preds = %cond.end35
  br label %cond.end39

cond.false38:                                     ; preds = %cond.end35
  call void @__assert_fail(i8* getelementptr inbounds ([8 x i8]* @.str55, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 1049, i8* getelementptr inbounds ([140 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_extended_gcd, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end39

cond.end39:                                       ; preds = %28, %cond.true37
  store %struct.lp_upolynomial_struct* null, %struct.lp_upolynomial_struct** %gcd, align 8
  %29 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call40 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %29)
  %30 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call41 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %30)
  %cmp42 = icmp ult i64 %call40, %call41
  br i1 %cmp42, label %if.then43, label %if.else

if.then43:                                        ; preds = %cond.end39
  %31 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %32 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %33 = load %struct.lp_upolynomial_struct*** %v.addr, align 8
  %34 = load %struct.lp_upolynomial_struct*** %u.addr, align 8
  %call44 = call %struct.lp_upolynomial_struct* @lp_upolynomial_extended_gcd(%struct.lp_upolynomial_struct* %31, %struct.lp_upolynomial_struct* %32, %struct.lp_upolynomial_struct** %33, %struct.lp_upolynomial_struct** %34)
  store %struct.lp_upolynomial_struct* %call44, %struct.lp_upolynomial_struct** %gcd, align 8
  br label %if.end46

if.else:                                          ; preds = %cond.end39
  %35 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %36 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %37 = load %struct.lp_upolynomial_struct*** %u.addr, align 8
  %38 = load %struct.lp_upolynomial_struct*** %v.addr, align 8
  %call45 = call %struct.lp_upolynomial_struct* @upolynomial_gcd_euclid(%struct.lp_upolynomial_struct* %35, %struct.lp_upolynomial_struct* %36, %struct.lp_upolynomial_struct** %37, %struct.lp_upolynomial_struct** %38)
  store %struct.lp_upolynomial_struct* %call45, %struct.lp_upolynomial_struct** %gcd, align 8
  br label %if.end46

if.end46:                                         ; preds = %if.else, %if.then43
  %call47 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([4 x i8]* @.str50, i32 0, i32 0))
  %tobool48 = icmp ne i32 %call47, 0
  br i1 %tobool48, label %if.then49, label %if.end92

if.then49:                                        ; preds = %if.end46
  %39 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool50 = icmp ne %struct._IO_FILE* %39, null
  br i1 %tobool50, label %cond.true51, label %cond.false52

cond.true51:                                      ; preds = %if.then49
  %40 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end53

cond.false52:                                     ; preds = %if.then49
  %41 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end53

cond.end53:                                       ; preds = %cond.false52, %cond.true51
  %cond54 = phi %struct._IO_FILE* [ %40, %cond.true51 ], [ %41, %cond.false52 ]
  %call55 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond54, i8* getelementptr inbounds ([17 x i8]* @.str51, i32 0, i32 0))
  %42 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %43 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool56 = icmp ne %struct._IO_FILE* %43, null
  br i1 %tobool56, label %cond.true57, label %cond.false58

cond.true57:                                      ; preds = %cond.end53
  %44 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end59

cond.false58:                                     ; preds = %cond.end53
  %45 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end59

cond.end59:                                       ; preds = %cond.false58, %cond.true57
  %cond60 = phi %struct._IO_FILE* [ %44, %cond.true57 ], [ %45, %cond.false58 ]
  %call61 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %42, %struct._IO_FILE* %cond60)
  %46 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool62 = icmp ne %struct._IO_FILE* %46, null
  br i1 %tobool62, label %cond.true63, label %cond.false64

cond.true63:                                      ; preds = %cond.end59
  %47 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end65

cond.false64:                                     ; preds = %cond.end59
  %48 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end65

cond.end65:                                       ; preds = %cond.false64, %cond.true63
  %cond66 = phi %struct._IO_FILE* [ %47, %cond.true63 ], [ %48, %cond.false64 ]
  %call67 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond66, i8* getelementptr inbounds ([3 x i8]* @.str8, i32 0, i32 0))
  %49 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %50 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool68 = icmp ne %struct._IO_FILE* %50, null
  br i1 %tobool68, label %cond.true69, label %cond.false70

cond.true69:                                      ; preds = %cond.end65
  %51 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end71

cond.false70:                                     ; preds = %cond.end65
  %52 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end71

cond.end71:                                       ; preds = %cond.false70, %cond.true69
  %cond72 = phi %struct._IO_FILE* [ %51, %cond.true69 ], [ %52, %cond.false70 ]
  %call73 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %49, %struct._IO_FILE* %cond72)
  %53 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool74 = icmp ne %struct._IO_FILE* %53, null
  br i1 %tobool74, label %cond.true75, label %cond.false76

cond.true75:                                      ; preds = %cond.end71
  %54 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end77

cond.false76:                                     ; preds = %cond.end71
  %55 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end77

cond.end77:                                       ; preds = %cond.false76, %cond.true75
  %cond78 = phi %struct._IO_FILE* [ %54, %cond.true75 ], [ %55, %cond.false76 ]
  %call79 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond78, i8* getelementptr inbounds ([5 x i8]* @.str10, i32 0, i32 0))
  %56 = load %struct.lp_upolynomial_struct** %gcd, align 8
  %57 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool80 = icmp ne %struct._IO_FILE* %57, null
  br i1 %tobool80, label %cond.true81, label %cond.false82

cond.true81:                                      ; preds = %cond.end77
  %58 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end83

cond.false82:                                     ; preds = %cond.end77
  %59 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end83

cond.end83:                                       ; preds = %cond.false82, %cond.true81
  %cond84 = phi %struct._IO_FILE* [ %58, %cond.true81 ], [ %59, %cond.false82 ]
  %call85 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %56, %struct._IO_FILE* %cond84)
  %60 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool86 = icmp ne %struct._IO_FILE* %60, null
  br i1 %tobool86, label %cond.true87, label %cond.false88

cond.true87:                                      ; preds = %cond.end83
  %61 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end89

cond.false88:                                     ; preds = %cond.end83
  %62 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end89

cond.end89:                                       ; preds = %cond.false88, %cond.true87
  %cond90 = phi %struct._IO_FILE* [ %61, %cond.true87 ], [ %62, %cond.false88 ]
  %call91 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond90, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end92

if.end92:                                         ; preds = %cond.end89, %if.end46
  %63 = load %struct.lp_upolynomial_struct** %gcd, align 8
  ret %struct.lp_upolynomial_struct* %63
}

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_solve_bezout(%struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct* %r, %struct.lp_upolynomial_struct** %u, %struct.lp_upolynomial_struct** %v) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %q.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %r.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %u.addr = alloca %struct.lp_upolynomial_struct**, align 8
  %v.addr = alloca %struct.lp_upolynomial_struct**, align 8
  %u1 = alloca %struct.lp_upolynomial_struct*, align 8
  %v1 = alloca %struct.lp_upolynomial_struct*, align 8
  %gcd = alloca %struct.lp_upolynomial_struct*, align 8
  %m = alloca %struct.lp_upolynomial_struct*, align 8
  %u2 = alloca %struct.lp_upolynomial_struct*, align 8
  %v2 = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_upolynomial_struct* %q, %struct.lp_upolynomial_struct** %q.addr, align 8
  store %struct.lp_upolynomial_struct* %r, %struct.lp_upolynomial_struct** %r.addr, align 8
  store %struct.lp_upolynomial_struct** %u, %struct.lp_upolynomial_struct*** %u.addr, align 8
  store %struct.lp_upolynomial_struct** %v, %struct.lp_upolynomial_struct*** %v.addr, align 8
  %0 = load %struct.lp_upolynomial_struct*** %u.addr, align 8
  %1 = load %struct.lp_upolynomial_struct** %0, align 8
  %cmp = icmp eq %struct.lp_upolynomial_struct* %1, null
  br i1 %cmp, label %land.lhs.true, label %cond.false

land.lhs.true:                                    ; preds = %entry
  %2 = load %struct.lp_upolynomial_struct*** %v.addr, align 8
  %3 = load %struct.lp_upolynomial_struct** %2, align 8
  %cmp1 = icmp eq %struct.lp_upolynomial_struct* %3, null
  br i1 %cmp1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %land.lhs.true
  br label %cond.end

cond.false:                                       ; preds = %land.lhs.true, %entry
  call void @__assert_fail(i8* getelementptr inbounds ([19 x i8]* @.str56, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 1067, i8* getelementptr inbounds ([153 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_solve_bezout, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %4, %cond.true
  store %struct.lp_upolynomial_struct* null, %struct.lp_upolynomial_struct** %u1, align 8
  store %struct.lp_upolynomial_struct* null, %struct.lp_upolynomial_struct** %v1, align 8
  %5 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %6 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call = call %struct.lp_upolynomial_struct* @lp_upolynomial_extended_gcd(%struct.lp_upolynomial_struct* %5, %struct.lp_upolynomial_struct* %6, %struct.lp_upolynomial_struct** %u1, %struct.lp_upolynomial_struct** %v1)
  store %struct.lp_upolynomial_struct* %call, %struct.lp_upolynomial_struct** %gcd, align 8
  %7 = load %struct.lp_upolynomial_struct** %r.addr, align 8
  %8 = load %struct.lp_upolynomial_struct** %gcd, align 8
  %call2 = call %struct.lp_upolynomial_struct* @lp_upolynomial_div_exact(%struct.lp_upolynomial_struct* %7, %struct.lp_upolynomial_struct* %8)
  store %struct.lp_upolynomial_struct* %call2, %struct.lp_upolynomial_struct** %m, align 8
  %9 = load %struct.lp_upolynomial_struct** %u1, align 8
  %10 = load %struct.lp_upolynomial_struct** %m, align 8
  %call3 = call %struct.lp_upolynomial_struct* @lp_upolynomial_mul(%struct.lp_upolynomial_struct* %9, %struct.lp_upolynomial_struct* %10)
  store %struct.lp_upolynomial_struct* %call3, %struct.lp_upolynomial_struct** %u2, align 8
  %11 = load %struct.lp_upolynomial_struct** %v1, align 8
  %12 = load %struct.lp_upolynomial_struct** %m, align 8
  %call4 = call %struct.lp_upolynomial_struct* @lp_upolynomial_mul(%struct.lp_upolynomial_struct* %11, %struct.lp_upolynomial_struct* %12)
  store %struct.lp_upolynomial_struct* %call4, %struct.lp_upolynomial_struct** %v2, align 8
  %13 = load %struct.lp_upolynomial_struct** %u2, align 8
  %14 = load %struct.lp_upolynomial_struct** %q.addr, align 8
  %call5 = call %struct.lp_upolynomial_struct* @lp_upolynomial_rem_exact(%struct.lp_upolynomial_struct* %13, %struct.lp_upolynomial_struct* %14)
  %15 = load %struct.lp_upolynomial_struct*** %u.addr, align 8
  store %struct.lp_upolynomial_struct* %call5, %struct.lp_upolynomial_struct** %15, align 8
  %16 = load %struct.lp_upolynomial_struct** %v2, align 8
  %17 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call6 = call %struct.lp_upolynomial_struct* @lp_upolynomial_rem_exact(%struct.lp_upolynomial_struct* %16, %struct.lp_upolynomial_struct* %17)
  %18 = load %struct.lp_upolynomial_struct*** %v.addr, align 8
  store %struct.lp_upolynomial_struct* %call6, %struct.lp_upolynomial_struct** %18, align 8
  %19 = load %struct.lp_upolynomial_struct** %u1, align 8
  call void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %19)
  %20 = load %struct.lp_upolynomial_struct** %v1, align 8
  call void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %20)
  %21 = load %struct.lp_upolynomial_struct** %u2, align 8
  call void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %21)
  %22 = load %struct.lp_upolynomial_struct** %v2, align 8
  call void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %22)
  %23 = load %struct.lp_upolynomial_struct** %gcd, align 8
  call void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %23)
  %24 = load %struct.lp_upolynomial_struct** %m, align 8
  call void @lp_upolynomial_delete(%struct.lp_upolynomial_struct* %24)
  ret void
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_factors_struct* @lp_upolynomial_factor(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %factors = alloca %struct.lp_upolynomial_factors_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([14 x i8]* @.str57, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([20 x i8]* @.str58, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end12, %entry
  store %struct.lp_upolynomial_factors_struct* null, %struct.lp_upolynomial_factors_struct** %factors, align 8
  %10 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %10, i32 0, i32 0
  %11 = load %struct.lp_int_ring_t** %K, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %11, null
  br i1 %cmp, label %if.then15, label %if.else

if.then15:                                        ; preds = %if.end
  %12 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call16 = call %struct.lp_upolynomial_factors_struct* @upolynomial_factor_Z(%struct.lp_upolynomial_struct* %12)
  store %struct.lp_upolynomial_factors_struct* %call16, %struct.lp_upolynomial_factors_struct** %factors, align 8
  br label %if.end23

if.else:                                          ; preds = %if.end
  %13 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K17 = getelementptr inbounds %struct.lp_upolynomial_struct* %13, i32 0, i32 0
  %14 = load %struct.lp_int_ring_t** %K17, align 8
  %is_prime = getelementptr inbounds %struct.lp_int_ring_t* %14, i32 0, i32 1
  %15 = load i32* %is_prime, align 4
  %tobool18 = icmp ne i32 %15, 0
  br i1 %tobool18, label %cond.true19, label %cond.false20

cond.true19:                                      ; preds = %if.else
  br label %cond.end21

cond.false20:                                     ; preds = %if.else
  call void @__assert_fail(i8* getelementptr inbounds ([15 x i8]* @.str59, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 1103, i8* getelementptr inbounds ([74 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_factor, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end21

cond.end21:                                       ; preds = %16, %cond.true19
  %17 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call22 = call %struct.lp_upolynomial_factors_struct* @upolynomial_factor_Zp(%struct.lp_upolynomial_struct* %17)
  store %struct.lp_upolynomial_factors_struct* %call22, %struct.lp_upolynomial_factors_struct** %factors, align 8
  br label %if.end23

if.end23:                                         ; preds = %cond.end21, %if.then15
  %call24 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([14 x i8]* @.str57, i32 0, i32 0))
  %tobool25 = icmp ne i32 %call24, 0
  br i1 %tobool25, label %if.then26, label %if.end57

if.then26:                                        ; preds = %if.end23
  %18 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool27 = icmp ne %struct._IO_FILE* %18, null
  br i1 %tobool27, label %cond.true28, label %cond.false29

cond.true28:                                      ; preds = %if.then26
  %19 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end30

cond.false29:                                     ; preds = %if.then26
  %20 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end30

cond.end30:                                       ; preds = %cond.false29, %cond.true28
  %cond31 = phi %struct._IO_FILE* [ %19, %cond.true28 ], [ %20, %cond.false29 ]
  %call32 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond31, i8* getelementptr inbounds ([20 x i8]* @.str58, i32 0, i32 0))
  %21 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %22 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool33 = icmp ne %struct._IO_FILE* %22, null
  br i1 %tobool33, label %cond.true34, label %cond.false35

cond.true34:                                      ; preds = %cond.end30
  %23 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end36

cond.false35:                                     ; preds = %cond.end30
  %24 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end36

cond.end36:                                       ; preds = %cond.false35, %cond.true34
  %cond37 = phi %struct._IO_FILE* [ %23, %cond.true34 ], [ %24, %cond.false35 ]
  %call38 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %21, %struct._IO_FILE* %cond37)
  %25 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool39 = icmp ne %struct._IO_FILE* %25, null
  br i1 %tobool39, label %cond.true40, label %cond.false41

cond.true40:                                      ; preds = %cond.end36
  %26 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end42

cond.false41:                                     ; preds = %cond.end36
  %27 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end42

cond.end42:                                       ; preds = %cond.false41, %cond.true40
  %cond43 = phi %struct._IO_FILE* [ %26, %cond.true40 ], [ %27, %cond.false41 ]
  %call44 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond43, i8* getelementptr inbounds ([5 x i8]* @.str10, i32 0, i32 0))
  %28 = load %struct.lp_upolynomial_factors_struct** %factors, align 8
  %29 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool45 = icmp ne %struct._IO_FILE* %29, null
  br i1 %tobool45, label %cond.true46, label %cond.false47

cond.true46:                                      ; preds = %cond.end42
  %30 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end48

cond.false47:                                     ; preds = %cond.end42
  %31 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end48

cond.end48:                                       ; preds = %cond.false47, %cond.true46
  %cond49 = phi %struct._IO_FILE* [ %30, %cond.true46 ], [ %31, %cond.false47 ]
  %call50 = call i32 @lp_upolynomial_factors_print(%struct.lp_upolynomial_factors_struct* %28, %struct._IO_FILE* %cond49)
  %32 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool51 = icmp ne %struct._IO_FILE* %32, null
  br i1 %tobool51, label %cond.true52, label %cond.false53

cond.true52:                                      ; preds = %cond.end48
  %33 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end54

cond.false53:                                     ; preds = %cond.end48
  %34 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end54

cond.end54:                                       ; preds = %cond.false53, %cond.true52
  %cond55 = phi %struct._IO_FILE* [ %33, %cond.true52 ], [ %34, %cond.false53 ]
  %call56 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond55, i8* getelementptr inbounds ([2 x i8]* @.str11, i32 0, i32 0))
  br label %if.end57

if.end57:                                         ; preds = %cond.end54, %if.end23
  %35 = load %struct.lp_upolynomial_factors_struct** %factors, align 8
  ret %struct.lp_upolynomial_factors_struct* %35
}

declare %struct.lp_upolynomial_factors_struct* @upolynomial_factor_Z(%struct.lp_upolynomial_struct*) #3

declare %struct.lp_upolynomial_factors_struct* @upolynomial_factor_Zp(%struct.lp_upolynomial_struct*) #3

declare i32 @lp_upolynomial_factors_print(%struct.lp_upolynomial_factors_struct*, %struct._IO_FILE*) #3

; Function Attrs: nounwind uwtable
define i32 @lp_upolynomial_roots_count(%struct.lp_upolynomial_struct* %p, %struct.lp_rational_interval_struct* %ab) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %ab.addr = alloca %struct.lp_rational_interval_struct*, align 8
  %roots = alloca i32, align 4
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_rational_interval_struct* %ab, %struct.lp_rational_interval_struct** %ab.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([6 x i8]* @.str60, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([30 x i8]* @.str61, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end12, %entry
  %10 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %11 = load %struct.lp_rational_interval_struct** %ab.addr, align 8
  %call15 = call i32 @upolynomial_roots_count_sturm(%struct.lp_upolynomial_struct* %10, %struct.lp_rational_interval_struct* %11)
  store i32 %call15, i32* %roots, align 4
  %call16 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([6 x i8]* @.str60, i32 0, i32 0))
  %tobool17 = icmp ne i32 %call16, 0
  br i1 %tobool17, label %if.then18, label %if.end37

if.then18:                                        ; preds = %if.end
  %12 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool19 = icmp ne %struct._IO_FILE* %12, null
  br i1 %tobool19, label %cond.true20, label %cond.false21

cond.true20:                                      ; preds = %if.then18
  %13 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end22

cond.false21:                                     ; preds = %if.then18
  %14 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end22

cond.end22:                                       ; preds = %cond.false21, %cond.true20
  %cond23 = phi %struct._IO_FILE* [ %13, %cond.true20 ], [ %14, %cond.false21 ]
  %call24 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond23, i8* getelementptr inbounds ([30 x i8]* @.str61, i32 0, i32 0))
  %15 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %16 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool25 = icmp ne %struct._IO_FILE* %16, null
  br i1 %tobool25, label %cond.true26, label %cond.false27

cond.true26:                                      ; preds = %cond.end22
  %17 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end28

cond.false27:                                     ; preds = %cond.end22
  %18 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end28

cond.end28:                                       ; preds = %cond.false27, %cond.true26
  %cond29 = phi %struct._IO_FILE* [ %17, %cond.true26 ], [ %18, %cond.false27 ]
  %call30 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %15, %struct._IO_FILE* %cond29)
  %19 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool31 = icmp ne %struct._IO_FILE* %19, null
  br i1 %tobool31, label %cond.true32, label %cond.false33

cond.true32:                                      ; preds = %cond.end28
  %20 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end34

cond.false33:                                     ; preds = %cond.end28
  %21 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end34

cond.end34:                                       ; preds = %cond.false33, %cond.true32
  %cond35 = phi %struct._IO_FILE* [ %20, %cond.true32 ], [ %21, %cond.false33 ]
  %22 = load i32* %roots, align 4
  %call36 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond35, i8* getelementptr inbounds ([9 x i8]* @.str62, i32 0, i32 0), i32 %22)
  br label %if.end37

if.end37:                                         ; preds = %cond.end34, %if.end
  %23 = load i32* %roots, align 4
  ret i32 %23
}

declare i32 @upolynomial_roots_count_sturm(%struct.lp_upolynomial_struct*, %struct.lp_rational_interval_struct*) #3

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_roots_isolate(%struct.lp_upolynomial_struct* %p, %struct.lp_algebraic_number_struct* %roots, i64* %roots_size) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %roots.addr = alloca %struct.lp_algebraic_number_struct*, align 8
  %roots_size.addr = alloca i64*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store %struct.lp_algebraic_number_struct* %roots, %struct.lp_algebraic_number_struct** %roots.addr, align 8
  store i64* %roots_size, i64** %roots_size.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([6 x i8]* @.str60, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([27 x i8]* @.str63, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end12, %entry
  %10 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %11 = load %struct.lp_algebraic_number_struct** %roots.addr, align 8
  %12 = load i64** %roots_size.addr, align 8
  call void @upolynomial_roots_isolate_sturm(%struct.lp_upolynomial_struct* %10, %struct.lp_algebraic_number_struct* %11, i64* %12)
  %call15 = call i32 @trace_is_enabled(i8* getelementptr inbounds ([6 x i8]* @.str60, i32 0, i32 0))
  %tobool16 = icmp ne i32 %call15, 0
  br i1 %tobool16, label %if.then17, label %if.end36

if.then17:                                        ; preds = %if.end
  %13 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool18 = icmp ne %struct._IO_FILE* %13, null
  br i1 %tobool18, label %cond.true19, label %cond.false20

cond.true19:                                      ; preds = %if.then17
  %14 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end21

cond.false20:                                     ; preds = %if.then17
  %15 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end21

cond.end21:                                       ; preds = %cond.false20, %cond.true19
  %cond22 = phi %struct._IO_FILE* [ %14, %cond.true19 ], [ %15, %cond.false20 ]
  %call23 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond22, i8* getelementptr inbounds ([27 x i8]* @.str63, i32 0, i32 0))
  %16 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %17 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool24 = icmp ne %struct._IO_FILE* %17, null
  br i1 %tobool24, label %cond.true25, label %cond.false26

cond.true25:                                      ; preds = %cond.end21
  %18 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end27

cond.false26:                                     ; preds = %cond.end21
  %19 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end27

cond.end27:                                       ; preds = %cond.false26, %cond.true25
  %cond28 = phi %struct._IO_FILE* [ %18, %cond.true25 ], [ %19, %cond.false26 ]
  %call29 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %16, %struct._IO_FILE* %cond28)
  %20 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool30 = icmp ne %struct._IO_FILE* %20, null
  br i1 %tobool30, label %cond.true31, label %cond.false32

cond.true31:                                      ; preds = %cond.end27
  %21 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end33

cond.false32:                                     ; preds = %cond.end27
  %22 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end33

cond.end33:                                       ; preds = %cond.false32, %cond.true31
  %cond34 = phi %struct._IO_FILE* [ %21, %cond.true31 ], [ %22, %cond.false32 ]
  %23 = load i64** %roots_size.addr, align 8
  %24 = load i64* %23, align 8
  %call35 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond34, i8* getelementptr inbounds ([10 x i8]* @.str64, i32 0, i32 0), i64 %24)
  br label %if.end36

if.end36:                                         ; preds = %cond.end33, %if.end
  ret void
}

declare void @upolynomial_roots_isolate_sturm(%struct.lp_upolynomial_struct*, %struct.lp_algebraic_number_struct*, i64*) #3

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_sturm_sequence(%struct.lp_upolynomial_struct* %f, %struct.lp_upolynomial_struct*** %S, i64* %size) #0 {
entry:
  %f.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %S.addr = alloca %struct.lp_upolynomial_struct***, align 8
  %size.addr = alloca i64*, align 8
  %f_deg = alloca i64, align 8
  %S_dense = alloca %struct.upolynomial_dense_t*, align 8
  %i = alloca i64, align 8
  store %struct.lp_upolynomial_struct* %f, %struct.lp_upolynomial_struct** %f.addr, align 8
  store %struct.lp_upolynomial_struct*** %S, %struct.lp_upolynomial_struct**** %S.addr, align 8
  store i64* %size, i64** %size.addr, align 8
  %call = call i32 @trace_is_enabled(i8* getelementptr inbounds ([6 x i8]* @.str60, i32 0, i32 0))
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %0 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool1 = icmp ne %struct._IO_FILE* %0, null
  br i1 %tobool1, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.then
  %1 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end

cond.false:                                       ; preds = %if.then
  %2 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi %struct._IO_FILE* [ %1, %cond.true ], [ %2, %cond.false ]
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond, i8* getelementptr inbounds ([34 x i8]* @.str65, i32 0, i32 0))
  %3 = load %struct.lp_upolynomial_struct** %f.addr, align 8
  %4 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool3 = icmp ne %struct._IO_FILE* %4, null
  br i1 %tobool3, label %cond.true4, label %cond.false5

cond.true4:                                       ; preds = %cond.end
  %5 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end6

cond.false5:                                      ; preds = %cond.end
  %6 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end6

cond.end6:                                        ; preds = %cond.false5, %cond.true4
  %cond7 = phi %struct._IO_FILE* [ %5, %cond.true4 ], [ %6, %cond.false5 ]
  %call8 = call i32 @lp_upolynomial_print(%struct.lp_upolynomial_struct* %3, %struct._IO_FILE* %cond7)
  %7 = load %struct._IO_FILE** @trace_out_real, align 8
  %tobool9 = icmp ne %struct._IO_FILE* %7, null
  br i1 %tobool9, label %cond.true10, label %cond.false11

cond.true10:                                      ; preds = %cond.end6
  %8 = load %struct._IO_FILE** @trace_out_real, align 8
  br label %cond.end12

cond.false11:                                     ; preds = %cond.end6
  %9 = load %struct._IO_FILE** @stderr, align 8
  br label %cond.end12

cond.end12:                                       ; preds = %cond.false11, %cond.true10
  %cond13 = phi %struct._IO_FILE* [ %8, %cond.true10 ], [ %9, %cond.false11 ]
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %cond13, i8* getelementptr inbounds ([3 x i8]* @.str9, i32 0, i32 0))
  br label %if.end

if.end:                                           ; preds = %cond.end12, %entry
  %10 = load %struct.lp_upolynomial_struct** %f.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %10, i32 0, i32 0
  %11 = load %struct.lp_int_ring_t** %K, align 8
  %cmp = icmp eq %struct.lp_int_ring_t* %11, null
  br i1 %cmp, label %cond.true15, label %cond.false16

cond.true15:                                      ; preds = %if.end
  br label %cond.end17

cond.false16:                                     ; preds = %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([10 x i8]* @.str66, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8]* @.str1, i32 0, i32 0), i32 1140, i8* getelementptr inbounds ([93 x i8]* @__PRETTY_FUNCTION__.lp_upolynomial_sturm_sequence, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end17

cond.end17:                                       ; preds = %12, %cond.true15
  %13 = load %struct.lp_upolynomial_struct** %f.addr, align 8
  %call18 = call i64 @lp_upolynomial_degree(%struct.lp_upolynomial_struct* %13)
  store i64 %call18, i64* %f_deg, align 8
  %14 = load i64* %f_deg, align 8
  %add = add i64 %14, 1
  %mul = mul i64 %add, 24
  %call19 = call noalias i8* @malloc(i64 %mul) #5
  %15 = bitcast i8* %call19 to %struct.upolynomial_dense_t*
  store %struct.upolynomial_dense_t* %15, %struct.upolynomial_dense_t** %S_dense, align 8
  %16 = load %struct.lp_upolynomial_struct** %f.addr, align 8
  %17 = load %struct.upolynomial_dense_t** %S_dense, align 8
  %18 = load i64** %size.addr, align 8
  call void @upolynomial_compute_sturm_sequence(%struct.lp_upolynomial_struct* %16, %struct.upolynomial_dense_t* %17, i64* %18)
  %19 = load i64** %size.addr, align 8
  %20 = load i64* %19, align 8
  %mul20 = mul i64 %20, 8
  %call21 = call noalias i8* @malloc(i64 %mul20) #5
  %21 = bitcast i8* %call21 to %struct.lp_upolynomial_struct**
  %22 = load %struct.lp_upolynomial_struct**** %S.addr, align 8
  store %struct.lp_upolynomial_struct** %21, %struct.lp_upolynomial_struct*** %22, align 8
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %cond.end17
  %23 = load i64* %i, align 8
  %24 = load i64** %size.addr, align 8
  %25 = load i64* %24, align 8
  %cmp22 = icmp ult i64 %23, %25
  br i1 %cmp22, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %26 = load %struct.upolynomial_dense_t** %S_dense, align 8
  %27 = load i64* %i, align 8
  %add.ptr = getelementptr inbounds %struct.upolynomial_dense_t* %26, i64 %27
  %call23 = call %struct.lp_upolynomial_struct* @upolynomial_dense_to_upolynomial(%struct.upolynomial_dense_t* %add.ptr, %struct.lp_int_ring_t* null)
  %28 = load i64* %i, align 8
  %29 = load %struct.lp_upolynomial_struct**** %S.addr, align 8
  %30 = load %struct.lp_upolynomial_struct*** %29, align 8
  %arrayidx = getelementptr inbounds %struct.lp_upolynomial_struct** %30, i64 %28
  store %struct.lp_upolynomial_struct* %call23, %struct.lp_upolynomial_struct** %arrayidx, align 8
  %31 = load %struct.upolynomial_dense_t** %S_dense, align 8
  %32 = load i64* %i, align 8
  %add.ptr24 = getelementptr inbounds %struct.upolynomial_dense_t* %31, i64 %32
  call void @upolynomial_dense_destruct(%struct.upolynomial_dense_t* %add.ptr24)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %33 = load i64* %i, align 8
  %inc = add i64 %33, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %34 = load %struct.upolynomial_dense_t** %S_dense, align 8
  %35 = bitcast %struct.upolynomial_dense_t* %34 to i8*
  call void @free(i8* %35) #5
  ret void
}

declare void @upolynomial_compute_sturm_sequence(%struct.lp_upolynomial_struct*, %struct.upolynomial_dense_t*, i64*) #3

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_neg(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %neg = alloca %struct.lp_upolynomial_struct*, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %call = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy(%struct.lp_upolynomial_struct* %0)
  store %struct.lp_upolynomial_struct* %call, %struct.lp_upolynomial_struct** %neg, align 8
  %1 = load %struct.lp_upolynomial_struct** %neg, align 8
  call void @lp_upolynomial_neg_in_place(%struct.lp_upolynomial_struct* %1)
  %2 = load %struct.lp_upolynomial_struct** %neg, align 8
  ret %struct.lp_upolynomial_struct* %2
}

; Function Attrs: nounwind uwtable
define void @lp_upolynomial_neg_in_place(%struct.lp_upolynomial_struct* %p) #0 {
entry:
  %p.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %i = alloca i64, align 8
  store %struct.lp_upolynomial_struct* %p, %struct.lp_upolynomial_struct** %p.addr, align 8
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i64* %i, align 8
  %1 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %1, i32 0, i32 1
  %2 = load i64* %size, align 8
  %cmp = icmp ult i64 %0, %2
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %3 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %3, i32 0, i32 0
  %4 = load %struct.lp_int_ring_t** %K, align 8
  %5 = load i64* %i, align 8
  %6 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %6, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %5
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 1
  %7 = load i64* %i, align 8
  %8 = load %struct.lp_upolynomial_struct** %p.addr, align 8
  %monomials1 = getelementptr inbounds %struct.lp_upolynomial_struct* %8, i32 0, i32 2
  %arrayidx2 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials1, i32 0, i64 %7
  %coefficient3 = getelementptr inbounds %struct.umonomial_struct* %arrayidx2, i32 0, i32 1
  call void @integer_neg(%struct.lp_int_ring_t* %4, %struct.__mpz_struct* %coefficient, %struct.__mpz_struct* %coefficient3)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %9 = load i64* %i, align 8
  %inc = add i64 %9, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define %struct.lp_upolynomial_struct* @lp_upolynomial_subst_x_neg(%struct.lp_upolynomial_struct* %f) #0 {
entry:
  %f.addr = alloca %struct.lp_upolynomial_struct*, align 8
  %neg = alloca %struct.lp_upolynomial_struct*, align 8
  %i = alloca i64, align 8
  store %struct.lp_upolynomial_struct* %f, %struct.lp_upolynomial_struct** %f.addr, align 8
  %0 = load %struct.lp_upolynomial_struct** %f.addr, align 8
  %call = call %struct.lp_upolynomial_struct* @lp_upolynomial_construct_copy(%struct.lp_upolynomial_struct* %0)
  store %struct.lp_upolynomial_struct* %call, %struct.lp_upolynomial_struct** %neg, align 8
  store i64 0, i64* %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %1 = load i64* %i, align 8
  %2 = load %struct.lp_upolynomial_struct** %neg, align 8
  %size = getelementptr inbounds %struct.lp_upolynomial_struct* %2, i32 0, i32 1
  %3 = load i64* %size, align 8
  %cmp = icmp ult i64 %1, %3
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %4 = load i64* %i, align 8
  %5 = load %struct.lp_upolynomial_struct** %neg, align 8
  %monomials = getelementptr inbounds %struct.lp_upolynomial_struct* %5, i32 0, i32 2
  %arrayidx = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials, i32 0, i64 %4
  %degree = getelementptr inbounds %struct.umonomial_struct* %arrayidx, i32 0, i32 0
  %6 = load i64* %degree, align 8
  %rem = urem i64 %6, 2
  %tobool = icmp ne i64 %rem, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %7 = load %struct.lp_upolynomial_struct** %neg, align 8
  %K = getelementptr inbounds %struct.lp_upolynomial_struct* %7, i32 0, i32 0
  %8 = load %struct.lp_int_ring_t** %K, align 8
  %9 = load i64* %i, align 8
  %10 = load %struct.lp_upolynomial_struct** %neg, align 8
  %monomials1 = getelementptr inbounds %struct.lp_upolynomial_struct* %10, i32 0, i32 2
  %arrayidx2 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials1, i32 0, i64 %9
  %coefficient = getelementptr inbounds %struct.umonomial_struct* %arrayidx2, i32 0, i32 1
  %11 = load i64* %i, align 8
  %12 = load %struct.lp_upolynomial_struct** %neg, align 8
  %monomials3 = getelementptr inbounds %struct.lp_upolynomial_struct* %12, i32 0, i32 2
  %arrayidx4 = getelementptr inbounds [0 x %struct.umonomial_struct]* %monomials3, i32 0, i64 %11
  %coefficient5 = getelementptr inbounds %struct.umonomial_struct* %arrayidx4, i32 0, i32 1
  call void @integer_neg(%struct.lp_int_ring_t* %8, %struct.__mpz_struct* %coefficient, %struct.__mpz_struct* %coefficient5)
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %13 = load i64* %i, align 8
  %inc = add i64 %13, 1
  store i64 %inc, i64* %i, align 8
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %14 = load %struct.lp_upolynomial_struct** %neg, align 8
  ret %struct.lp_upolynomial_struct* %14
}

declare void @__gmpz_clear(%struct.__mpz_struct*) #3

; Function Attrs: inlinehint nounwind uwtable
define internal i32 @dyadic_rational_is_normalized(%struct.lp_dyadic_rational_t* %q) #4 {
entry:
  %q.addr = alloca %struct.lp_dyadic_rational_t*, align 8
  store %struct.lp_dyadic_rational_t* %q, %struct.lp_dyadic_rational_t** %q.addr, align 8
  %0 = load %struct.lp_dyadic_rational_t** %q.addr, align 8
  %a = getelementptr inbounds %struct.lp_dyadic_rational_t* %0, i32 0, i32 0
  %_mp_size = getelementptr inbounds %struct.__mpz_struct* %a, i32 0, i32 1
  %1 = load i32* %_mp_size, align 4
  %cmp = icmp slt i32 %1, 0
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load %struct.lp_dyadic_rational_t** %q.addr, align 8
  %a1 = getelementptr inbounds %struct.lp_dyadic_rational_t* %2, i32 0, i32 0
  %_mp_size2 = getelementptr inbounds %struct.__mpz_struct* %a1, i32 0, i32 1
  %3 = load i32* %_mp_size2, align 4
  %cmp3 = icmp sgt i32 %3, 0
  %conv = zext i1 %cmp3 to i32
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ -1, %cond.true ], [ %conv, %cond.false ]
  %cmp4 = icmp eq i32 %cond, 0
  br i1 %cmp4, label %land.lhs.true, label %lor.rhs

land.lhs.true:                                    ; preds = %cond.end
  %4 = load %struct.lp_dyadic_rational_t** %q.addr, align 8
  %n = getelementptr inbounds %struct.lp_dyadic_rational_t* %4, i32 0, i32 1
  %5 = load i64* %n, align 8
  %cmp6 = icmp eq i64 %5, 0
  br i1 %cmp6, label %lor.end15, label %lor.rhs

lor.rhs:                                          ; preds = %land.lhs.true, %cond.end
  %6 = load %struct.lp_dyadic_rational_t** %q.addr, align 8
  %a8 = getelementptr inbounds %struct.lp_dyadic_rational_t* %6, i32 0, i32 0
  %call = call i64 @__gmpz_scan1(%struct.__mpz_struct* %a8, i64 0) #8
  %cmp9 = icmp eq i64 %call, 0
  br i1 %cmp9, label %lor.end, label %lor.rhs11

lor.rhs11:                                        ; preds = %lor.rhs
  %7 = load %struct.lp_dyadic_rational_t** %q.addr, align 8
  %n12 = getelementptr inbounds %struct.lp_dyadic_rational_t* %7, i32 0, i32 1
  %8 = load i64* %n12, align 8
  %cmp13 = icmp eq i64 %8, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs11, %lor.rhs
  %9 = phi i1 [ true, %lor.rhs ], [ %cmp13, %lor.rhs11 ]
  br label %lor.end15

lor.end15:                                        ; preds = %lor.end, %land.lhs.true
  %10 = phi i1 [ true, %land.lhs.true ], [ %9, %lor.end ]
  %lor.ext = zext i1 %10 to i32
  ret i32 %lor.ext
}

; Function Attrs: nounwind readonly
declare i64 @__gmpz_scan1(%struct.__mpz_struct*, i64) #6

declare void @__gmpz_init(%struct.__mpz_struct*) #3

declare void @__gmpq_clear(%struct.__mpq_struct*) #3

declare void @__gmpq_init(%struct.__mpq_struct*) #3

; Function Attrs: inlinehint nounwind uwtable
define internal i32 @integer_in_ring(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c) #4 {
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

declare void @__gmpz_addmul(%struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*) #3

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_ring_normalize(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c) #4 {
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
  call void @__assert_fail(i8* getelementptr inbounds ([22 x i8]* @.str71, i32 0, i32 0), i8* getelementptr inbounds ([52 x i8]* @.str70, i32 0, i32 0), i32 71, i8* getelementptr inbounds ([61 x i8]* @__PRETTY_FUNCTION__.integer_ring_normalize, i32 0, i32 0)) #7
  unreachable
                                                  ; No predecessors!
  br label %cond.end26

cond.end26:                                       ; preds = %24, %cond.true24
  br label %if.end27

if.end27:                                         ; preds = %cond.end26, %land.lhs.true, %entry
  ret void
}

declare void @__gmpz_tdiv_r(%struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*) #3

declare void @__gmpz_swap(%struct.__mpz_struct*, %struct.__mpz_struct*) #3

; Function Attrs: nounwind readonly
declare i32 @__gmpz_cmp(%struct.__mpz_struct*, %struct.__mpz_struct*) #6

declare void @__gmpz_sub(%struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*) #3

declare void @__gmpz_add(%struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*) #3

declare void @__gmpz_set_si(%struct.__mpz_struct*, i64) #3

declare void @__gmpz_gcd(%struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*) #3

declare void @__gmpz_neg(%struct.__mpz_struct*, %struct.__mpz_struct*) #3

declare void @__gmpz_gcdext(%struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*) #3

; Function Attrs: nounwind readonly
declare i32 @__gmpz_divisible_p(%struct.__mpz_struct*, %struct.__mpz_struct*) #6

declare void @__gmpz_divexact(%struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*) #3

declare void @__gmpz_mul(%struct.__mpz_struct*, %struct.__mpz_struct*, %struct.__mpz_struct*) #3

declare void @__gmpz_mul_si(%struct.__mpz_struct*, %struct.__mpz_struct*, i64) #3

declare void @__gmpz_powm_ui(%struct.__mpz_struct*, %struct.__mpz_struct*, i64, %struct.__mpz_struct*) #3

declare void @__gmpz_pow_ui(%struct.__mpz_struct*, %struct.__mpz_struct*, i64) #3

declare i64 @__gmpz_out_str(%struct._IO_FILE*, i32, %struct.__mpz_struct*) #3

; Function Attrs: inlinehint nounwind uwtable
define internal void @integer_construct_copy(%struct.lp_int_ring_t* %K, %struct.__mpz_struct* %c, %struct.__mpz_struct* %from) #4 {
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

; Function Attrs: nounwind readonly
declare i32 @__gmpz_cmp_si(%struct.__mpz_struct*, i64) #6

declare void @__gmpz_init_set(%struct.__mpz_struct*, %struct.__mpz_struct*) #3

declare void @__gmpz_set(%struct.__mpz_struct*, %struct.__mpz_struct*) #3

declare void @__gmpz_init_set_si(%struct.__mpz_struct*, i64) #3

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noreturn nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { inlinehint nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind }
attributes #6 = { nounwind readonly "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { noreturn nounwind }
attributes #8 = { nounwind readonly }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.5.2 (branches/release_35 229013) (llvm/branches/release_35 229009)"}
