; RUN: opt %s -S -passes=sroa -o - | FileCheck %s

;; $ cat test.cpp
;; class c {
;;   float b[4];
;; };
;; c fn1();
;; void d() {
;;   c a[3];
;;   a[2] = fn1();
;; }
;;
;; Generated by grabbing IR before sroa in:
;; $ clang++ -O2 -g -c test.cpp -Xclang -fexperimental-assignment-tracking
;;
;; Check that when the memcpy to fragment(256, 128) is split into two 2xfloat
;; stores, the dbg.assign is split into two with fragment(256, 64) &
;; fragment(320, 64). Ensure that only the value-expression gets fragment info;
;; that the address-expression remains untouched.

; CHECK: %call = call
; CHECK-NEXT: %0 = extractvalue { <2 x float>, <2 x float> } %call, 0
; CHECK-NEXT: %1 = extractvalue { <2 x float>, <2 x float> } %call, 1
; CHECK-NEXT: #dbg_value(<2 x float> %0, ![[var:[0-9]+]], !DIExpression(DW_OP_LLVM_fragment, 256, 64),
; CHECK-NEXT: #dbg_value(<2 x float> %1, ![[var]], !DIExpression(DW_OP_LLVM_fragment, 320, 64),

%class.c = type { [4 x float] }

; Function Attrs: uwtable
define dso_local void @_Z1dv() #0 !dbg !7 {
entry:
  %a = alloca [3 x %class.c], align 16, !DIAssignID !22
  call void @llvm.dbg.assign(metadata i1 undef, metadata !11, metadata !DIExpression(), metadata !22, metadata ptr %a, metadata !DIExpression()), !dbg !23
  %ref.tmp = alloca %class.c, align 4
  %0 = bitcast ptr %a to ptr, !dbg !24
  call void @llvm.lifetime.start.p0(i64 48, ptr %0) #4, !dbg !24
  %1 = bitcast ptr %ref.tmp to ptr, !dbg !25
  call void @llvm.lifetime.start.p0(i64 16, ptr %1) #4, !dbg !25
  %call = call { <2 x float>, <2 x float> } @_Z3fn1v(), !dbg !25
  %coerce.dive = getelementptr inbounds %class.c, ptr %ref.tmp, i32 0, i32 0, !dbg !25
  %2 = bitcast ptr %coerce.dive to ptr, !dbg !25
  %3 = getelementptr inbounds { <2 x float>, <2 x float> }, ptr %2, i32 0, i32 0, !dbg !25
  %4 = extractvalue { <2 x float>, <2 x float> } %call, 0, !dbg !25
  store <2 x float> %4, ptr %3, align 4, !dbg !25
  %5 = getelementptr inbounds { <2 x float>, <2 x float> }, ptr %2, i32 0, i32 1, !dbg !25
  %6 = extractvalue { <2 x float>, <2 x float> } %call, 1, !dbg !25
  store <2 x float> %6, ptr %5, align 4, !dbg !25
  %arrayidx = getelementptr inbounds [3 x %class.c], ptr %a, i64 0, i64 2, !dbg !26
  %7 = bitcast ptr %arrayidx to ptr, !dbg !27
  %8 = bitcast ptr %ref.tmp to ptr, !dbg !27
  call void @llvm.memcpy.p0.p0.i64(ptr align 16 %7, ptr align 4 %8, i64 16, i1 false), !dbg !27, !DIAssignID !32
  call void @llvm.dbg.assign(metadata i1 undef, metadata !11, metadata !DIExpression(DW_OP_LLVM_fragment, 256, 128), metadata !32, metadata ptr %7, metadata !DIExpression()), !dbg !23
  %9 = bitcast ptr %ref.tmp to ptr, !dbg !26
  call void @llvm.lifetime.end.p0(i64 16, ptr %9) #4, !dbg !26
  %10 = bitcast ptr %a to ptr, !dbg !33
  call void @llvm.lifetime.end.p0(i64 48, ptr %10) #4, !dbg !33
  ret void, !dbg !33
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #2

declare !dbg !34 dso_local { <2 x float>, <2 x float> } @_Z3fn1v() #3

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.assign(metadata, metadata, metadata, metadata, metadata, metadata) #2

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5, !1000}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !1, producer: "clang version 12.0.0", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "reduce.cpp", directory: "/")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 12.0.0"}
!7 = distinct !DISubprogram(name: "d", linkageName: "_Z1dv", scope: !1, file: !1, line: 5, type: !8, scopeLine: 5, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !10)
!8 = !DISubroutineType(types: !9)
!9 = !{null}
!10 = !{!11}
!11 = !DILocalVariable(name: "a", scope: !7, file: !1, line: 6, type: !12)
!12 = !DICompositeType(tag: DW_TAG_array_type, baseType: !13, size: 384, elements: !20)
!13 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "c", file: !1, line: 1, size: 128, flags: DIFlagTypePassByValue, elements: !14, identifier: "_ZTS1c")
!14 = !{!15}
!15 = !DIDerivedType(tag: DW_TAG_member, name: "b", scope: !13, file: !1, line: 2, baseType: !16, size: 128)
!16 = !DICompositeType(tag: DW_TAG_array_type, baseType: !17, size: 128, elements: !18)
!17 = !DIBasicType(name: "float", size: 32, encoding: DW_ATE_float)
!18 = !{!19}
!19 = !DISubrange(count: 4)
!20 = !{!21}
!21 = !DISubrange(count: 3)
!22 = distinct !DIAssignID()
!23 = !DILocation(line: 0, scope: !7)
!24 = !DILocation(line: 6, column: 3, scope: !7)
!25 = !DILocation(line: 7, column: 10, scope: !7)
!26 = !DILocation(line: 7, column: 3, scope: !7)
!27 = !DILocation(line: 7, column: 8, scope: !7)
!32 = distinct !DIAssignID()
!33 = !DILocation(line: 8, column: 1, scope: !7)
!34 = !DISubprogram(name: "fn1", linkageName: "_Z3fn1v", scope: !1, file: !1, line: 4, type: !35, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !2)
!35 = !DISubroutineType(types: !36)
!36 = !{!13}
!1000 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
