; RUN: llc -O0 -mtriple=spirv64-unknown-unknown %s -o - | FileCheck %s --check-prefix=CHECK-SPIRV

;; Test for llvm.is.fpclass translation
;; it's a bit rewritten subset of is_fpclass.ll test from llvm.org

; CHECK-SPIRV: OpCapability Kernel
; CHECK-SPIRV: OpCapability Addresses
; CHECK-SPIRV: OpCapability Linkage
; CHECK-SPIRV: OpCapability Float64
; CHECK-SPIRV: OpCapability Int64
; CHECK-SPIRV: OpCapability Int16
; CHECK-SPIRV: OpCapability Float16
; CHECK-SPIRV: OpExtInstImport "OpenCL.std"
; CHECK-SPIRV: OpMemoryModel Physical64 OpenCL
; CHECK-SPIRV: OpSource OpenCL_CPP 100000

; CHECK-SPIRV-DAG: %[[#Float32Ty:]] = OpTypeFloat 32
; CHECK-SPIRV-DAG: %[[#BoolTy:]] = OpTypeBool
; CHECK-SPIRV-DAG: %[[#FuncTy1:]] = OpTypeFunction %[[#BoolTy]] %[[#Float32Ty]]
; CHECK-SPIRV-DAG: %[[#Int32Ty:]] = OpTypeInt 32 0
; CHECK-SPIRV-DAG: %[[#Float32VecTy:]] = OpTypeVector %[[#Float32Ty]] 2
; CHECK-SPIRV-DAG: %[[#BoolVecTy:]] = OpTypeVector %[[#BoolTy]] 2
; CHECK-SPIRV-DAG: %[[#FuncTy2:]] = OpTypeFunction %[[#BoolVecTy]] %[[#Float32VecTy]]
; CHECK-SPIRV-DAG: %[[#DoubleTy:]] = OpTypeFloat 64
; CHECK-SPIRV-DAG: %[[#Int64Ty:]] = OpTypeInt 64 0
; CHECK-SPIRV-DAG: %[[#Int16Ty:]] = OpTypeInt 16 0
; CHECK-SPIRV-DAG: %[[#Int16VecTy:]] = OpTypeVector %[[#Int16Ty]] 2

; CHECK-SPIRV-DAG: %[[#FalseConst:]] = OpConstantFalse %[[#BoolTy]]
; CHECK-SPIRV-DAG: %[[#TrueConst:]] = OpConstantTrue %[[#BoolTy]]
; CHECK-SPIRV-DAG: %[[#Int32Const1:]] = OpConstant %[[#Int32Ty]] 2139095040
; CHECK-SPIRV-DAG: %[[#Int32Const2:]] = OpConstant %[[#Int32Ty]] 2147483647
; CHECK-SPIRV-DAG: %[[#Int32VecTy:]] = OpTypeVector %[[#Int32Ty]] 2
; CHECK-SPIRV-DAG: %[[#Int32VecConst1:]] = OpConstantComposite %[[#Int32VecTy]] %[[#Int32Const2]] %[[#Int32Const2]]
; CHECK-SPIRV-DAG: %[[#Int32VecConst2:]] = OpConstantComposite %[[#Int32VecTy]] %[[#Int32Const1]] %[[#Int32Const1]]
; CHECK-SPIRV-DAG: %[[#BoolVecConst:]] = OpConstantComposite %[[#BoolVecTy]] %[[#FalseConst]] %[[#FalseConst]]
; CHECK-SPIRV-DAG: %[[#Int32Const3:]] = OpConstant %[[#Int32Ty]] 2143289344
; CHECK-SPIRV-DAG: %[[#Int32Const4:]] = OpConstant %[[#Int32Ty]] 4286578688
; CHECK-SPIRV-DAG: %[[#Int32VecConst3:]] = OpConstantComposite %[[#Int32VecTy]] %[[#Int32Const4]] %[[#Int32Const4]]
; CHECK-SPIRV-DAG: %[[#Int32Const5:]] = OpConstant %[[#Int32Ty]] 2130706432
; CHECK-SPIRV-DAG: %[[#Int32Const6:]] = OpConstant %[[#Int32Ty]] 8388608
; CHECK-SPIRV-DAG: %[[#Int32Const7:]] = OpConstant %[[#Int32Ty]] 8388607
; CHECK-SPIRV-DAG: %[[#Int32Const8:]] = OpConstant %[[#Int32Ty]] 1
; CHECK-SPIRV-DAG: %[[#Int32Const9:]] = OpConstantNull %[[#Int32Ty]]
; CHECK-SPIRV-DAG: %[[#Int32Const10:]] = OpConstant %[[#Int32Ty]] 2147483648
; CHECK-SPIRV-DAG: %[[#Int64Const1:]] = OpConstant %[[#Int64Ty]] 9214364837600034816
; CHECK-SPIRV-DAG: %[[#Int64Const2:]] = OpConstant %[[#Int64Ty]] 4503599627370496
; CHECK-SPIRV-DAG: %[[#Int64Const3:]] = OpConstant %[[#Int64Ty]] 9223372036854775807
; CHECK-SPIRV-DAG: %[[#Int64Const4:]] = OpConstant %[[#Int64Ty]] 9221120237041090560
; CHECK-SPIRV-DAG: %[[#Int64Const5:]] = OpConstant %[[#Int64Ty]] 18442240474082181120
; CHECK-SPIRV-DAG: %[[#Int64Const6:]] = OpConstant %[[#Int64Ty]] 4503599627370495
; CHECK-SPIRV-DAG: %[[#Int64Const7:]] = OpConstant %[[#Int64Ty]] 1
; CHECK-SPIRV-DAG: %[[#Int64Const8:]] = OpConstantNull %[[#Int64Ty]]
; CHECK-SPIRV-DAG: %[[#Int64Const9:]] = OpConstant %[[#Int64Ty]] 9218868437227405312
; CHECK-SPIRV-DAG: %[[#DoubleConst:]] = OpConstant %[[#DoubleTy]] 1
; CHECK-SPIRV-DAG: %[[#Int16Const1:]] = OpConstant %[[#Int16Ty]] 30720
; CHECK-SPIRV-DAG: %[[#Int16Const2:]] = OpConstant %[[#Int16Ty]] 1024
; CHECK-SPIRV-DAG: %[[#Int16Const3:]] = OpConstant %[[#Int16Ty]] 32256
; CHECK-SPIRV-DAG: %[[#Int16Const4:]] = OpConstant %[[#Int16Ty]] 64512
; CHECK-SPIRV-DAG: %[[#Int16Const5:]] = OpConstant %[[#Int16Ty]] 1023
; CHECK-SPIRV-DAG: %[[#Int16Const6:]] = OpConstant %[[#Int16Ty]] 1
; CHECK-SPIRV-DAG: %[[#Int16ConstNull:]] = OpConstantNull %[[#Int16Ty]]
; CHECK-SPIRV-DAG: %[[#Int16Const7:]] = OpConstant %[[#Int16Ty]] 31744
; CHECK-SPIRV-DAG: %[[#Int16Const8:]] = OpConstant %[[#Int16Ty]] 32767
; CHECK-SPIRV-DAG: %[[#Int16VecConst1:]] = OpConstantComposite %[[#Int16VecTy]] %[[#Int16Const8]] %[[#Int16Const8]]
; CHECK-SPIRV-DAG: %[[#Int16VecConst2:]] = OpConstantComposite %[[#Int16VecTy]] %[[#Int16Const7]] %[[#Int16Const7]]
; CHECK-SPIRV-DAG: %[[#BoolVecConst1:]] = OpConstantComposite %[[#BoolVecTy]] %[[#TrueConst]] %[[#TrueConst]]
; CHECK-SPIRV-DAG: %[[#Int16VecConst3:]] = OpConstantComposite %[[#Int16VecTy]] %[[#Int16ConstNull]] %[[#Int16ConstNull]]
; CHECK-SPIRV-DAG: %[[#Int16VecConst4:]] = OpConstantComposite %[[#Int16VecTy]] %[[#Int16Const6]] %[[#Int16Const6]]
; CHECK-SPIRV-DAG: %[[#Int16VecConst5:]] = OpConstantComposite %[[#Int16VecTy]] %[[#Int16Const5]] %[[#Int16Const5]]
; CHECK-SPIRV-DAG: %[[#Int16VecConst6:]] = OpConstantComposite %[[#Int16VecTy]] %[[#Int16Const4]] %[[#Int16Const4]]
; CHECK-SPIRV-DAG: %[[#Int16VecConst7:]] = OpConstantComposite %[[#Int16VecTy]] %[[#Int16Const3]] %[[#Int16Const3]]
; CHECK-SPIRV-DAG: %[[#Int16VecConst8:]] = OpConstantComposite %[[#Int16VecTy]] %[[#Int16Const2]] %[[#Int16Const2]]
; CHECK-SPIRV-DAG: %[[#Int16VecConst9:]] = OpConstantComposite %[[#Int16VecTy]] %[[#Int16Const1]] %[[#Int16Const1]]

; ModuleID = 'fpclass.bc'
source_filename = "fpclass.ll"
target triple = "spir64-unknown-unknown"

; check for no mask
define i1 @test_class_no_mask_f32(float %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]

; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: OpReturnValue %[[#FalseConst]]
  %val = call i1 @llvm.is.fpclass.f32(float %x, i32 0)
  ret i1 %val
}

; check for full mask
define i1 @test_class_full_mask_f32(float %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]

; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: OpReturnValue %[[#TrueConst]]
  %val = call i1 @llvm.is.fpclass.f32(float %x, i32 1023)
  ret i1 %val
}

; check for nan
define i1 @test_class_isnan_f32(float %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int32Ty]] %[[#BitCast]] %[[#Int32Const2]]
; CHECK-SPIRV: %[[#UGTRes:]] = OpUGreaterThan %[[#BoolTy]] %[[#AndRes]] %[[#Int32Const1]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#UGTRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f32(float %x, i32 3)
  ret i1 %val
}

define <2 x i1> @test_class_isnan_v2f32(<2 x float> %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32VecTy]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int32VecTy]] %[[#BitCast]] %[[#Int32VecConst1]]
; CHECK-SPIRV: %[[#UGTRes:]] = OpUGreaterThan %[[#BoolVecTy]] %[[#AndRes]] %[[#Int32VecConst2]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolVecTy]] %[[#BoolVecConst]] %[[#UGTRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call <2 x i1> @llvm.is.fpclass.v2f32(<2 x float> %x, i32 3)
  ret <2 x i1> %val
}

; check for snan
define i1 @test_class_issnan_f32(float %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int32Ty]] %[[#BitCast]] %[[#Int32Const2]]
; CHECK-SPIRV: %[[#UGTRes:]] = OpUGreaterThan %[[#BoolTy]] %[[#AndRes]] %[[#Int32Const1]]
; CHECK-SPIRV: %[[#ULTRes:]] = OpULessThan %[[#BoolTy]] %[[#AndRes]] %[[#Int32Const3]]
; CHECK-SPIRV: %[[#AndRes1:]] = OpLogicalAnd %[[#BoolTy]] %[[#UGTRes]] %[[#ULTRes]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#AndRes1]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f32(float %x, i32 1)
  ret i1 %val
}

; check for qnan
define i1 @test_class_isqnan_f32(float %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int32Ty]] %[[#BitCast]] %[[#Int32Const2]]
; CHECK-SPIRV: %[[#UGERes:]] = OpUGreaterThanEqual %[[#BoolTy]] %[[#AndRes]] %[[#Int32Const3]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#UGERes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f32(float %x, i32 2)
  ret i1 %val
}

; check for inf
define i1 @test_class_is_inf_f32(float %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int32Ty]] %[[#BitCast]] %[[#Int32Const2]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolTy]] %[[#AndRes]] %[[#Int32Const1]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#IEqRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f32(float %x, i32 516)
  ret i1 %val
}

define <2 x i1> @test_class_is_inf_v2f32(<2 x float> %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32VecTy]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int32VecTy]] %[[#BitCast]] %[[#Int32VecConst1]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolVecTy]] %[[#AndRes]] %[[#Int32VecConst2]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolVecTy]] %[[#BoolVecConst]] %[[#IEqRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call <2 x i1> @llvm.is.fpclass.v2f32(<2 x float> %x, i32 516)
  ret <2 x i1> %val
}

; check for pos inf
define i1 @test_class_is_pinf_f32(float %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolTy]] %[[#BitCast]] %[[#Int32Const1]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#IEqRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f32(float %x, i32 512)
  ret i1 %val
}

define <2 x i1> @test_class_is_pinf_v2f32(<2 x float> %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32VecTy]] %[[#Val]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolVecTy]] %[[#BitCast]] %[[#Int32VecConst2]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolVecTy]] %[[#BoolVecConst]] %[[#IEqRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call <2 x i1> @llvm.is.fpclass.v2f32(<2 x float> %x, i32 512)
  ret <2 x i1> %val
}

; check for neg inf
define i1 @test_class_is_ninf_f32(float %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolTy]] %[[#BitCast]] %[[#Int32Const4]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#IEqRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f32(float %x, i32 4)
  ret i1 %val
}

define <2 x i1> @test_class_is_ninf_v2f32(<2 x float> %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32VecTy]] %[[#Val]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolVecTy]] %[[#BitCast]] %[[#Int32VecConst3]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolVecTy]] %[[#BoolVecConst]] %[[#IEqRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call <2 x i1> @llvm.is.fpclass.v2f32(<2 x float> %x, i32 4)
  ret <2 x i1> %val
}

; check for normal
define i1 @test_class_is_normal(float %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int32Ty]] %[[#BitCast]] %[[#Int32Const2]]
; CHECK-SPIRV: %[[#SubRes:]] = OpISub %[[#Int32Ty]] %[[#AndRes]] %[[#Int32Const6]]
; CHECK-SPIRV: %[[#ULTRes:]] = OpULessThan %[[#BoolTy]] %[[#SubRes]] %[[#Int32Const5]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#ULTRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f32(float %x, i32 264)
  ret i1 %val
}

; check for pos normal
define i1 @test_constant_class_pnormal() {
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int64Ty]] %[[#DoubleConst]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int64Ty]] %[[#BitCast]] %[[#Int64Const3]]
; CHECK-SPIRV: %[[#INEqRes:]] = OpINotEqual %[[#BoolTy]] %[[#BitCast]] %[[#AndRes]]
; CHECK-SPIRV: %[[#SubRes:]] = OpISub %[[#Int64Ty]] %[[#AndRes]] %[[#Int64Const2]]
; CHECK-SPIRV: %[[#ULTRes:]] = OpULessThan %[[#BoolTy]] %[[#SubRes]] %[[#Int64Const1]]
; CHECK-SPIRV: %[[#LNEqRes:]] = OpLogicalNotEqual %[[#BoolTy]] %[[#INEqRes]] %[[#TrueConst]]
; CHECK-SPIRV: %[[#AndRes1:]] = OpLogicalAnd %[[#BoolTy]] %[[#ULTRes]] %[[#LNEqRes]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#AndRes1]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f64(double 1.000000e+00, i32 256)
  ret i1 %val
}

; check for neg normal
define i1 @test_constant_class_nnormal() {
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int64Ty]] %[[#DoubleConst]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int64Ty]] %[[#BitCast]] %[[#Int64Const3]]
; CHECK-SPIRV: %[[#INEqRes:]] = OpINotEqual %[[#BoolTy]] %[[#BitCast]] %[[#AndRes]]
; CHECK-SPIRV: %[[#SubRes:]] = OpISub %[[#Int64Ty]] %[[#AndRes]] %[[#Int64Const2]]
; CHECK-SPIRV: %[[#ULTRes:]] = OpULessThan %[[#BoolTy]] %[[#SubRes]] %[[#Int64Const1]]
; CHECK-SPIRV: %[[#AndRes1:]] = OpLogicalAnd %[[#BoolTy]] %[[#ULTRes]] %[[#INEqRes]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#AndRes1]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f64(double 1.000000e+00, i32 8)
  ret i1 %val
}

; check for subnormal
define i1 @test_class_subnormal(float %arg) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int32Ty]] %[[#BitCast]] %[[#Int32Const2]]
; CHECK-SPIRV: %[[#SubRes:]] = OpISub %[[#Int32Ty]] %[[#AndRes]] %[[#Int32Const8]]
; CHECK-SPIRV: %[[#ULTRes:]] = OpULessThan %[[#BoolTy]] %[[#SubRes]] %[[#Int32Const7]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#ULTRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f32(float %arg, i32 144)
  ret i1 %val
}

; check for pos subnormal
define i1 @test_class_possubnormal(float %arg) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#SubRes:]] = OpISub %[[#Int32Ty]] %[[#BitCast]] %[[#Int32Const8]]
; CHECK-SPIRV: %[[#ULTRes:]] = OpULessThan %[[#BoolTy]] %[[#SubRes]] %[[#Int32Const7]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#ULTRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f32(float %arg, i32 128)
  ret i1 %val
}


; check for zero
define i1 @test_class_zero(float %arg) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int32Ty]] %[[#BitCast]] %[[#Int32Const2]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolTy]] %[[#AndRes]] %[[#Int32Const9]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#IEqRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f32(float %arg, i32 96)
  ret i1 %val
}

; check for pos zero
define i1 @test_class_poszero(float %arg) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolTy]] %[[#BitCast]] %[[#Int32Const9]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#IEqRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f32(float %arg, i32 64)
  ret i1 %val
}

; check for neg zero
define i1 @test_class_negzero(float %arg) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolTy]] %[[#BitCast]] %[[#Int32Const10]]
; CHECK-SPIRV: %[[#OrRes:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#IEqRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes]]
  %val = call i1 @llvm.is.fpclass.f32(float %arg, i32 32)
  ret i1 %val
}

; check for neg inf or nan
define i1 @test_class_is_ninf_or_nan_f32(float %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int32Ty]] %[[#BitCast]] %[[#Int32Const2]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolTy]] %[[#BitCast]] %[[#Int32Const4]]
; CHECK-SPIRV: %[[#OrRes1:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#IEqRes]]
; CHECK-SPIRV: %[[#UGTRes:]] = OpUGreaterThan %[[#BoolTy]] %[[#AndRes]] %[[#Int32Const1]]
; CHECK-SPIRV: %[[#OrRes2:]] = OpLogicalOr %[[#BoolTy]] %[[#OrRes1]] %[[#UGTRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes2]]
  %val = call i1 @llvm.is.fpclass.f32(float %x, i32 7)
  ret i1 %val
}

; check for neg inf, pos normal, neg subnormal, pos zero and snan scalar
define i1 @test_class_neginf_posnormal_negsubnormal_poszero_snan_f64(double %arg) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int64Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int64Ty]] %[[#BitCast]] %[[#Int64Const3]]
; CHECK-SPIRV: %[[#INEqRes:]] = OpINotEqual %[[#BoolTy]] %[[#BitCast]] %[[#AndRes]]
; CHECK-SPIRV: %[[#BitCast2:]] = OpBitcast %[[#Int64Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolTy]] %[[#BitCast2]] %[[#Int64Const8]]
; CHECK-SPIRV: %[[#OrRes1:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#IEqRes]]
; CHECK-SPIRV: %[[#SubRes:]] = OpISub %[[#Int64Ty]] %[[#AndRes]] %[[#Int64Const7]]
; CHECK-SPIRV: %[[#ULTRes:]] = OpULessThan %[[#BoolTy]] %[[#SubRes]] %[[#Int64Const6]]
; CHECK-SPIRV: %[[#AndRes1:]] = OpLogicalAnd %[[#BoolTy]] %[[#ULTRes]] %[[#INEqRes]]
; CHECK-SPIRV: %[[#OrRes2:]] = OpLogicalOr %[[#BoolTy]] %[[#OrRes1]] %[[#AndRes1]]
; CHECK-SPIRV: %[[#IEqRes2:]] = OpIEqual %[[#BoolTy]] %[[#BitCast2]] %[[#Int64Const5]]
; CHECK-SPIRV: %[[#OrRes3:]] = OpLogicalOr %[[#BoolTy]] %[[#OrRes2]] %[[#IEqRes2]]
; CHECK-SPIRV: %[[#UGTRes:]] = OpUGreaterThan %[[#BoolTy]] %[[#AndRes]] %[[#Int64Const9]]
; CHECK-SPIRV: %[[#ULTRes2:]] = OpULessThan %[[#BoolTy]] %[[#AndRes]] %[[#Int64Const4]]
; CHECK-SPIRV: %[[#AndRes2:]] = OpLogicalAnd %[[#BoolTy]] %[[#UGTRes]] %[[#ULTRes2]]
; CHECK-SPIRV: %[[#OrRes4:]] = OpLogicalOr %[[#BoolTy]] %[[#OrRes3]] %[[#AndRes2]]
; CHECK-SPIRV: %[[#SubRes2:]] = OpISub %[[#Int64Ty]] %[[#AndRes]] %[[#Int64Const2]]
; CHECK-SPIRV: %[[#ULTRes3:]] = OpULessThan %[[#BoolTy]] %[[#SubRes2]] %[[#Int64Const1]]
; CHECK-SPIRV: %[[#LNEqRes:]] = OpLogicalNotEqual %[[#BoolTy]] %[[#INEqRes]] %[[#TrueConst]]
; CHECK-SPIRV: %[[#AndRes3:]] = OpLogicalAnd %[[#BoolTy]] %[[#ULTRes3]] %[[#LNEqRes]]
; CHECK-SPIRV: %[[#OrRes5:]] = OpLogicalOr %[[#BoolTy]] %[[#OrRes4]] %[[#AndRes3]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes5]]
  %val = call i1 @llvm.is.fpclass.f64(double %arg, i32 341)
  ret i1 %val
}

; check for neg inf, pos normal, neg subnormal, pos zero and snan vector
define <2 x i1> @test_class_neginf_posnormal_negsubnormal_poszero_snan_v2f16(<2 x half> %arg) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int16VecTy]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int16VecTy]] %[[#BitCast]] %[[#Int16VecConst1]]
; CHECK-SPIRV: %[[#INEqRes:]] = OpINotEqual %[[#BoolVecTy]] %[[#BitCast]] %[[#AndRes]]
; CHECK-SPIRV: %[[#BitCast2:]] = OpBitcast %[[#Int16VecTy]] %[[#Val]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolVecTy]] %[[#BitCast2]] %[[#Int16VecConst3]]
; CHECK-SPIRV: %[[#OrRes1:]] = OpLogicalOr %[[#BoolVecTy]] %[[#BoolVecConst]] %[[#IEqRes]]
; CHECK-SPIRV: %[[#SubRes:]] = OpISub %[[#Int16VecTy]] %[[#AndRes]] %[[#Int16VecConst4]]
; CHECK-SPIRV: %[[#ULTRes:]] = OpULessThan %[[#BoolVecTy]] %[[#SubRes]] %[[#Int16VecConst5]]
; CHECK-SPIRV: %[[#AndRes1:]] = OpLogicalAnd %[[#BoolVecTy]] %[[#ULTRes]] %[[#INEqRes]]
; CHECK-SPIRV: %[[#OrRes2:]] = OpLogicalOr %[[#BoolVecTy]] %[[#OrRes1]] %[[#AndRes1]]
; CHECK-SPIRV: %[[#IEqRes2:]] = OpIEqual %[[#BoolVecTy]] %[[#BitCast2]] %[[#Int16VecConst6]]
; CHECK-SPIRV: %[[#OrRes3:]] = OpLogicalOr %[[#BoolVecTy]] %[[#OrRes2]] %[[#IEqRes2]]
; CHECK-SPIRV: %[[#UGTRes:]] = OpUGreaterThan %[[#BoolVecTy]] %[[#AndRes]] %[[#Int16VecConst2]]
; CHECK-SPIRV: %[[#ULTRes2:]] = OpULessThan %[[#BoolVecTy]] %[[#AndRes]] %[[#Int16VecConst7]]
; CHECK-SPIRV: %[[#AndRes2:]] = OpLogicalAnd %[[#BoolVecTy]] %[[#UGTRes]] %[[#ULTRes2]]
; CHECK-SPIRV: %[[#OrRes4:]] = OpLogicalOr %[[#BoolVecTy]] %[[#OrRes3]] %[[#AndRes2]]
; CHECK-SPIRV: %[[#SubRes2:]] = OpISub %[[#Int16VecTy]] %[[#AndRes]] %[[#Int16VecConst8]]
; CHECK-SPIRV: %[[#ULTRes3:]] = OpULessThan %[[#BoolVecTy]] %[[#SubRes2]] %[[#Int16VecConst9]]
; CHECK-SPIRV: %[[#LNEqRes:]] = OpLogicalNotEqual %[[#BoolVecTy]] %[[#INEqRes]] %[[#BoolVecConst1]]
; CHECK-SPIRV: %[[#AndRes3:]] = OpLogicalAnd %[[#BoolVecTy]] %[[#ULTRes3]] %[[#LNEqRes]]
; CHECK-SPIRV: %[[#OrRes5:]] = OpLogicalOr %[[#BoolVecTy]] %[[#OrRes4]] %[[#AndRes3]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes5]]
  %val = call <2 x i1> @llvm.is.fpclass.v2f16(<2 x half> %arg, i32 341)
  ret <2 x i1> %val
}

; inverted check for not nan
define i1 @test_class_inverted_is_not_nan_f32(float %x) {
; CHECK-SPIRV: %[[#Val:]] = OpFunctionParameter %[[#]]
; CHECK-SPIRV: OpLabel
; CHECK-SPIRV: %[[#BitCast:]] = OpBitcast %[[#Int32Ty]] %[[#Val]]
; CHECK-SPIRV: %[[#AndRes:]] = OpBitwiseAnd %[[#Int32Ty]] %[[#BitCast]] %[[#Int32Const2]]
; CHECK-SPIRV: %[[#ULTRes:]] = OpULessThan %[[#BoolTy]] %[[#AndRes]] %[[#Int32Const1]]
; CHECK-SPIRV: %[[#OrRes1:]] = OpLogicalOr %[[#BoolTy]] %[[#FalseConst]] %[[#ULTRes]]
; CHECK-SPIRV: %[[#IEqRes:]] = OpIEqual %[[#BoolTy]] %[[#AndRes]] %[[#Int32Const1]]
; CHECK-SPIRV: %[[#OrRes2:]] = OpLogicalOr %[[#BoolTy]] %[[#OrRes1]] %[[#IEqRes]]
; CHECK-SPIRV: OpReturnValue %[[#OrRes2]]
  %val = call i1 @llvm.is.fpclass.f32(float %x, i32 1020)
  ret i1 %val
}

declare i1 @llvm.is.fpclass.f32(float, i32 immarg)

declare i1 @llvm.is.fpclass.f64(double, i32 immarg)

declare <2 x i1> @llvm.is.fpclass.v2f32(<2 x float>, i32 immarg)

declare <2 x i1> @llvm.is.fpclass.v2f16(<2 x half>, i32 immarg)
