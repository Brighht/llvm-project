; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc < %s -mtriple=s390x-linux-gnu -mcpu=z13 | FileCheck %s

define i64 @test(i128 %in) {
; CHECK-LABEL: test:
; CHECK:       # %bb.0:
; CHECK-NEXT:    larl %r1, .LCPI0_0
; CHECK-NEXT:    vl %v0, 0(%r2), 3
; CHECK-NEXT:    vl %v1, 0(%r1), 3
; CHECK-NEXT:    vaccq %v0, %v0, %v1
; CHECK-NEXT:    vlgvg %r1, %v0, 1
; CHECK-NEXT:    la %r2, 1(%r1)
; CHECK-NEXT:    br %r14
  %1 = tail call { i128, i1 } @llvm.uadd.with.overflow.i128(i128 %in, i128 1)
  %2 = extractvalue { i128, i1 } %1, 1
  %3 = zext i1 %2 to i64
  %4 = add i64 %3, 1
  ret i64 %4
}

declare { i128, i1 } @llvm.uadd.with.overflow.i128(i128, i128) #0

attributes #0 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
