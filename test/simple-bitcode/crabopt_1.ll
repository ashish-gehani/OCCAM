; RUN: cd %crabopt/1 &&  ./build.sh 
; RUN: %llvm_as < %crabopt/1/slash/main-final.ll | %llvm_dis | FileCheck %s

; ModuleID = 'slash/main-final.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.state = type { i32, i32 }

; CHECK-NOT: You should not see this message.
@.str.1 = private unnamed_addr constant [68 x i8] c"2. You should not see this message but analysis not precise enough.\0A\00", align 1
@.str.3 = private unnamed_addr constant [32 x i8] c"4. You should see this message.\0A\00", align 1
@new_argv = private constant [5 x i8] c"main\00"


; Function Attrs: noinline nounwind optnone uwtable
define internal fastcc i32 @nd_int() unnamed_addr #0 {
_1:
  %_2 = call i64 @time(i64* null) #4
  %_call = trunc i64 %_2 to i32
  call void @srand(i32 %_call) #4
  %_ret = call i32 @rand() #4
  ret i32 %_ret
}

; Function Attrs: nounwind
declare dso_local i64 @time(i64*) local_unnamed_addr #1

; Function Attrs: nounwind
declare dso_local void @srand(i32) local_unnamed_addr #1

; Function Attrs: nounwind
declare dso_local i32 @rand() local_unnamed_addr #1

; Function Attrs: noinline nounwind optnone uwtable
define internal fastcc void @read(i8** %arg, %struct.state* %arg1) unnamed_addr #0 {
_3:
  %_4 = alloca i32, align 4
  %_5 = alloca i8**, align 8
  %_store = alloca %struct.state*, align 8
  store i32 1, i32* %_4, align 4
  store i8** %arg, i8*** %_5, align 8
  store %struct.state* %arg1, %struct.state** %_store, align 8
  %_7 = call fastcc i32 @nd_int()
  %_br = icmp ne i32 %_7, 0
  br i1 %_br, label %_9, label %_12

_9:                                               ; preds = %_3
  %_10 = load %struct.state*, %struct.state** %_store, align 8
  %_store2 = getelementptr inbounds %struct.state, %struct.state* %_10, i32 0, i32 0
  store i32 1, i32* %_store2, align 4
  br label %_ret

_12:                                              ; preds = %_3
  %_13 = call fastcc i32 @nd_int()
  %_br3 = icmp ne i32 %_13, 0
  br i1 %_br3, label %_15, label %_18

_15:                                              ; preds = %_12
  %_16 = load %struct.state*, %struct.state** %_store, align 8
  %_store4 = getelementptr inbounds %struct.state, %struct.state* %_16, i32 0, i32 0
  store i32 2, i32* %_store4, align 4
  br label %_br9

_18:                                              ; preds = %_12
  %_19 = call fastcc i32 @nd_int()
  %_br5 = icmp ne i32 %_19, 0
  br i1 %_br5, label %_21, label %_24

_21:                                              ; preds = %_18
  %_22 = load %struct.state*, %struct.state** %_store, align 8
  %_store6 = getelementptr inbounds %struct.state, %struct.state* %_22, i32 0, i32 0
  store i32 4, i32* %_store6, align 4
  br label %_br8

_24:                                              ; preds = %_18
  %_25 = load %struct.state*, %struct.state** %_store, align 8
  %_store7 = getelementptr inbounds %struct.state, %struct.state* %_25, i32 0, i32 0
  store i32 5, i32* %_store7, align 4
  br label %_br8

_br8:                                             ; preds = %_24, %_21
  br label %_br9

_br9:                                             ; preds = %_br8, %_15
  br label %_ret

_ret:                                             ; preds = %_br9, %_9
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal fastcc void @process(%struct.state* %arg) unnamed_addr #0 {
_2:
  %_store = alloca %struct.state*, align 8
  store %struct.state* %arg, %struct.state** %_store, align 8
  %_4 = load %struct.state*, %struct.state** %_store, align 8
  %_5 = getelementptr inbounds %struct.state, %struct.state* %_4, i32 0, i32 0
  %_6 = load i32, i32* %_5, align 4
  %_br = icmp eq i32 %_6, 7
  br label %_10

_10:                                              ; preds = %_2
  %_11 = load %struct.state*, %struct.state** %_store, align 8
  %_12 = getelementptr inbounds %struct.state, %struct.state* %_11, i32 0, i32 0
  %_13 = load i32, i32* %_12, align 4
  %_br2 = icmp eq i32 %_13, 3
  br i1 %_br2, label %_15, label %_17

_15:                                              ; preds = %_10
  %_br3 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([68 x i8], [68 x i8]* @.str.1, i64 0, i64 0))
  br label %_17

_17:                                              ; preds = %_15, %_10
  %_18 = load %struct.state*, %struct.state** %_store, align 8
  %_19 = getelementptr inbounds %struct.state, %struct.state* %_18, i32 0, i32 0
  %_20 = load i32, i32* %_19, align 4
  %_br4 = icmp eq i32 %_20, 0
  br label %_24

_24:                                              ; preds = %_17
  %_25 = load %struct.state*, %struct.state** %_store, align 8
  %_26 = getelementptr inbounds %struct.state, %struct.state* %_25, i32 0, i32 0
  %_27 = load i32, i32* %_26, align 4
  %_br6 = icmp eq i32 %_27, 2
  br i1 %_br6, label %_29, label %_ret

_29:                                              ; preds = %_24
  %_br7 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([32 x i8], [32 x i8]* @.str.3, i64 0, i64 0))
  br label %_ret

_ret:                                             ; preds = %_29, %_24
  ret void
}

declare dso_local i32 @printf(i8*, ...) local_unnamed_addr #2

define i32 @main(i32 %arg, i8** nocapture readonly %arg1) local_unnamed_addr {
entry:
  %_2 = alloca %struct.state, align 4
  %_3 = icmp eq i32 %arg, 1
  br i1 %_3, label %entry1, label %UnifiedReturnBlock

entry1:                                           ; preds = %entry
  %malloccall = tail call dereferenceable_or_null(16) i8* @malloc(i64 16)
  %_4 = bitcast i8* %malloccall to i8**
  store i8* getelementptr inbounds ([5 x i8], [5 x i8]* @new_argv, i64 0, i64 0), i8** %_4, align 8
  %_5 = getelementptr inbounds i8, i8* %malloccall, i64 8
  %_6 = bitcast i8* %_5 to i8**
  store i8* null, i8** %_6, align 8
  %_7 = bitcast %struct.state* %_2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %_7)
  call fastcc void @read(i8** nonnull %_4, %struct.state* nonnull %_2) #4
  call fastcc void @process(%struct.state* nonnull %_2) #4
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %_7)
  br label %UnifiedReturnBlock

UnifiedReturnBlock:                               ; preds = %entry1, %entry
  %UnifiedRetVal = phi i32 [ 0, %entry1 ], [ 1, %entry ]
  ret i32 %UnifiedRetVal
}

declare noalias i8* @malloc(i64) local_unnamed_addr

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1}

!0 = !{!"clang version 10.0.0 "}
!1 = !{i32 1, !"wchar_size", i32 4}

