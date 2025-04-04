; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 4
; Test to make sure malloc's bitcast does not block detection of a store
; to aliased memory; GVN should not optimize away the load in this program.
; RUN: opt < %s -passes=newgvn -S | FileCheck %s

define i64 @test() {
; CHECK-LABEL: define i64 @test() {
; CHECK-NEXT:    [[MUL:%.*]] = mul i64 4, ptrtoint (ptr getelementptr (i64, ptr null, i64 1) to i64)
; CHECK-NEXT:    [[TMP1:%.*]] = tail call ptr @malloc(i64 [[MUL]])
; CHECK-NEXT:    store i8 42, ptr [[TMP1]], align 1
; CHECK-NEXT:    [[Y:%.*]] = load i64, ptr [[TMP1]], align 4
; CHECK-NEXT:    ret i64 [[Y]]
;
  %mul = mul i64 4, ptrtoint (ptr getelementptr (i64, ptr null, i64 1) to i64)
  %1 = tail call ptr @malloc(i64 %mul)
  store i8 42, ptr %1
  %Y = load i64, ptr %1                               ; <i64> [#uses=1]
  ret i64 %Y
}

declare noalias ptr @malloc(i64)
