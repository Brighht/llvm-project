// RUN: mlir-opt %s -convert-amdgpu-to-rocdl=chipset=gfx1100 --allow-unregistered-dialect | FileCheck %s
// CHECK-LABEL: @wmma_to_rocdl
func.func @wmma_to_rocdl(%arg0 : vector<16xf16>, %arg1 : vector<8xf32>, %arg2 : vector<4xf32>,
                         %arg3 : vector<16xbf16>, %arg4 : vector<8xf16>, %arg5 : vector<8xbf16>,
                         %arg6 : vector<16xi8>, %arg7 : vector<8xi32>, %arg8 : vector<4xi32>,
                         %arg9 : vector<16xui8>, %arg10 : vector<16xi4>, %arg11 : vector<8xi4>) {
  // CHECK: rocdl.wmma.f32.16x16x16.f16{{.*}}: (vector<16xf16>, vector<16xf16>, vector<8xf32>) -> vector<8xf32>
  amdgpu.wmma %arg0 * %arg0 + %arg1 : vector<16xf16>, vector<16xf16>, vector<8xf32>
  // CHECK: rocdl.wmma.f32.16x16x16.f16{{.*}}: (vector<16xf16>, vector<16xf16>, vector<4xf32>) -> vector<4xf32>
  amdgpu.wmma %arg0 * %arg0 + %arg2 : vector<16xf16>, vector<16xf16>, vector<4xf32>
  // CHECK: rocdl.wmma.f32.16x16x16.bf16{{.*}}: (vector<16xi16>, vector<16xi16>, vector<8xf32>) -> vector<8xf32>
  amdgpu.wmma %arg3 * %arg3 + %arg1 : vector<16xbf16>, vector<16xbf16>, vector<8xf32>
  // CHECK: rocdl.wmma.f32.16x16x16.bf16{{.*}}: (vector<16xi16>, vector<16xi16>, vector<4xf32>) -> vector<4xf32>
  amdgpu.wmma %arg3 * %arg3 + %arg2 : vector<16xbf16>, vector<16xbf16>, vector<4xf32>
  // CHECK: rocdl.wmma.f16.16x16x16.f16{{.*}}: (vector<16xf16>, vector<16xf16>, vector<16xf16>, i1) -> vector<16xf16>
  amdgpu.wmma %arg0 * %arg0 + %arg0 {subwordOffset = 1 : i32}: vector<16xf16>, vector<16xf16>, vector<16xf16>
  // CHECK: rocdl.wmma.f16.16x16x16.f16{{.*}}: (vector<16xf16>, vector<16xf16>, vector<8xf16>, i1) -> vector<8xf16>
  amdgpu.wmma %arg0 * %arg0 + %arg4 {subwordOffset = 0 : i32}: vector<16xf16>, vector<16xf16>, vector<8xf16>
  // CHECK: %[[raw_bf16x16:.+]] = rocdl.wmma.bf16.16x16x16.bf16{{.*}}: (vector<16xi16>, vector<16xi16>, vector<16xi16>, i1) -> vector<16xi16>
  // CHECK-NEXT: llvm.bitcast %[[raw_bf16x16]] : vector<16xi16> to vector<16xbf16>
  amdgpu.wmma %arg3 * %arg3 + %arg3 {subwordOffset = 1 : i32}: vector<16xbf16>, vector<16xbf16>, vector<16xbf16>
  // CHECK: %[[raw_bf16x8:.+]] = rocdl.wmma.bf16.16x16x16.bf16{{.*}}: (vector<16xi16>, vector<16xi16>, vector<8xi16>, i1) -> vector<8xi16>
  // CHECK-NEXT: llvm.bitcast %[[raw_bf16x8]] : vector<8xi16> to vector<8xbf16>
  amdgpu.wmma %arg3 * %arg3 + %arg5 {subwordOffset = 0 : i32}: vector<16xbf16>, vector<16xbf16>, vector<8xbf16>
  // CHECK: rocdl.wmma.i32.16x16x16.iu8{{.*}}: (i1, vector<4xi32>, i1, vector<4xi32>, vector<8xi32>, i1) -> vector<8xi32>
  amdgpu.wmma %arg6 * %arg6 + %arg7 {clamp}: vector<16xi8>, vector<16xi8>, vector<8xi32>
  // CHECK: rocdl.wmma.i32.16x16x16.iu8{{.*}}: (i1, vector<4xi32>, i1, vector<4xi32>, vector<4xi32>, i1) -> vector<4xi32>
  amdgpu.wmma %arg9 * %arg9 + %arg8 {unsignedA, unsignedB, clamp}: vector<16xui8>, vector<16xui8>, vector<4xi32>
  // CHECK: rocdl.wmma.i32.16x16x16.iu4{{.*}}: (i1, vector<2xi32>, i1, vector<2xi32>, vector<8xi32>, i1) -> vector<8xi32>
  amdgpu.wmma %arg10 * %arg10 + %arg7 {clamp}: vector<16xi4>, vector<16xi4>, vector<8xi32>
  // CHECK: rocdl.wmma.i32.16x16x16.iu4{{.*}}: (i1, i32, i1, i32, vector<4xi32>, i1) -> vector<4xi32>
  amdgpu.wmma %arg11 * %arg11 + %arg8 {clamp}: vector<8xi4>, vector<8xi4>, vector<4xi32>

  func.return
}
