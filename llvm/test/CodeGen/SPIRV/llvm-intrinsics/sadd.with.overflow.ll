; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv32-unknown-unknown %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -verify-machineinstrs -O0 -mtriple=spirv32-unknown-unknown %s -o - -filetype=obj | spirv-val %}

; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv64-unknown-unknown %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -verify-machineinstrs -O0 -mtriple=spirv64-unknown-unknown %s -o - -filetype=obj | spirv-val %}

;===---------------------------------------------------------------------===//
; Type definitions.
; CHECK-DAG: %[[I16:.*]] = OpTypeInt 16 0
; CHECK-DAG: %[[Bool:.*]] = OpTypeBool
; CHECK-DAG: %[[I32:.*]] = OpTypeInt 32 0
; CHECK-DAG: %[[I64:.*]] = OpTypeInt 64 0
; CHECK-DAG: %[[PtrI16:.*]] = OpTypePointer Function %[[I16]]
; CHECK-DAG: %[[PtrI32:.*]] = OpTypePointer Function %[[I32]]
; CHECK-DAG: %[[PtrI64:.*]] = OpTypePointer Function %[[I64]]
; CHECK-DAG: %[[V4I32:.*]] = OpTypeVector %[[I32]] 4
; CHECK-DAG: %[[V4Bool:.*]] = OpTypeVector %[[Bool]] 4
; CHECK-DAG: %[[PtrV4I32:.*]] = OpTypePointer Function %[[V4I32]]
; CHECK-DAG: %[[ZeroI16:.*]] = OpConstantNull %[[I16]]
; CHECK-DAG: %[[ZeroI32:.*]] = OpConstantNull %[[I32]]
; CHECK-DAG: %[[ZeroI64:.*]] = OpConstantNull %[[I64]]
; CHECK-DAG: %[[ZeroV4I32:.*]] = OpConstantNull %[[V4I32]]
;===---------------------------------------------------------------------===//
; Function for smulo_i16.
; CHECK: OpFunction
; CHECK: %[[A16:.*]] = OpFunctionParameter %[[I16]]
; CHECK: %[[B16:.*]] = OpFunctionParameter %[[I16]]
; CHECK: %[[Ptr16:.*]] = OpFunctionParameter %[[PtrI16]]
; CHECK: %[[Sum16:.*]] = OpIAdd %[[I16]] %[[A16]] %[[B16]]
; CHECK: %[[Cmp16:.*]] = OpSLessThan %[[Bool]] %[[Sum16]] %[[A16]]
; CHECK: %[[CmpZero16:.*]] = OpSLessThan %[[Bool]] %[[B16]] %[[ZeroI16]]
; CHECK: %[[Overflow16:.*]] = OpLogicalNotEqual %[[Bool]] %[[CmpZero16]] %[[Cmp16]]
; CHECK: %[[Result16:.*]] = OpSelect %[[I16]] %[[Overflow16]] %[[ZeroI16]] %[[Sum16]]
; CHECK: OpStore %[[Ptr16]] %[[Result16]] Aligned 1
; CHECK: OpReturn

define spir_func void @smulo_i16(i16 %a, i16 %b, ptr nocapture %c) {
entry:
  %umul = tail call { i16, i1 } @llvm.sadd.with.overflow.i16(i16 %a, i16 %b)
  %cmp = extractvalue { i16, i1 } %umul, 1
  %umul.value = extractvalue { i16, i1 } %umul, 0
  %storemerge = select i1 %cmp, i16 0, i16 %umul.value
  store i16 %storemerge, ptr %c, align 1
  ret void
}

;===---------------------------------------------------------------------===//
; Function for smulo_i32.
; CHECK: OpFunction
; CHECK: %[[A32:.*]] = OpFunctionParameter %[[I32]]
; CHECK: %[[B32:.*]] = OpFunctionParameter %[[I32]]
; CHECK: %[[Ptr32:.*]] = OpFunctionParameter %[[PtrI32]]
; CHECK: %[[Sum32:.*]] = OpIAdd %[[I32]] %[[A32]] %[[B32]]
; CHECK: %[[Cmp32:.*]] = OpSLessThan %[[Bool]] %[[Sum32]] %[[A32]]
; CHECK: %[[CmpZero32:.*]] = OpSLessThan %[[Bool]] %[[B32]] %[[ZeroI32]]
; CHECK: %[[Overflow32:.*]] = OpLogicalNotEqual %[[Bool]] %[[CmpZero32]] %[[Cmp32]]
; CHECK: %[[Result32:.*]] = OpSelect %[[I32]] %[[Overflow32]] %[[ZeroI32]] %[[Sum32]]
; CHECK: OpStore %[[Ptr32]] %[[Result32]] Aligned 4
; CHECK: OpReturn

define spir_func void @smulo_i32(i32 %a, i32 %b, ptr nocapture %c) {
entry:
  %umul = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %a, i32 %b)
  %cmp = extractvalue { i32, i1 } %umul, 1
  %umul.value = extractvalue { i32, i1 } %umul, 0
  %storemerge = select i1 %cmp, i32 0, i32 %umul.value
  store i32 %storemerge, ptr %c, align 4
  ret void
}

;===---------------------------------------------------------------------===//
; Function for smulo_i64.
; CHECK: OpFunction
; CHECK: %[[A64:.*]] = OpFunctionParameter %[[I64]]
; CHECK: %[[B64:.*]] = OpFunctionParameter %[[I64]]
; CHECK: %[[Ptr64:.*]] = OpFunctionParameter %[[PtrI64]]
; CHECK: %[[Sum64:.*]] = OpIAdd %[[I64]] %[[A64]] %[[B64]]
; CHECK: %[[Cmp64:.*]] = OpSLessThan %[[Bool]] %[[Sum64]] %[[A64]]
; CHECK: %[[CmpZero64:.*]] = OpSLessThan %[[Bool]] %[[B64]] %[[ZeroI64]]
; CHECK: %[[Overflow64:.*]] = OpLogicalNotEqual %[[Bool]] %[[CmpZero64]] %[[Cmp64]]
; CHECK: %[[Result64:.*]] = OpSelect %[[I64]] %[[Overflow64]] %[[ZeroI64]] %[[Sum64]]
; CHECK: OpStore %[[Ptr64]] %[[Result64]] Aligned 8
; CHECK: OpReturn

define spir_func void @smulo_i64(i64 %a, i64 %b, ptr nocapture %c) {
entry:
  %umul = tail call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %a, i64 %b)
  %cmp = extractvalue { i64, i1 } %umul, 1
  %umul.value = extractvalue { i64, i1 } %umul, 0
  %storemerge = select i1 %cmp, i64 0, i64 %umul.value
  store i64 %storemerge, ptr %c, align 8
  ret void
}

;===---------------------------------------------------------------------===//
; Function for smulo_v4i32.
; CHECK: OpFunction
; CHECK: %[[A_V4:.*]] = OpFunctionParameter %[[V4I32]]
; CHECK: %[[B_V4:.*]] = OpFunctionParameter %[[V4I32]]
; CHECK: %[[Ptr_V4:.*]] = OpFunctionParameter %[[PtrV4I32]]
; CHECK: %[[Sum_V4:.*]] = OpIAdd %[[V4I32]] %[[A_V4]] %[[B_V4]]
; CHECK: %[[Cmp_V4:.*]] = OpSLessThan %[[V4Bool]] %[[Sum_V4]] %[[A_V4]]
; CHECK: %[[CmpZero_V4:.*]] = OpSLessThan %[[V4Bool]] %[[B_V4]] %[[#]]
; CHECK: %[[Overflow_V4:.*]] = OpLogicalNotEqual %[[V4Bool]] %[[CmpZero_V4]] %[[Cmp_V4]]
; CHECK: %[[Result_V4:.*]] = OpSelect %[[V4I32]] %[[Overflow_V4]] %[[ZeroV4I32]] %[[Sum_V4]]
; CHECK: OpStore %[[Ptr_V4]] %[[Result_V4]] Aligned 16
; CHECK: OpReturn

define spir_func void @smulo_v4i32(<4 x i32> %a, <4 x i32> %b, ptr nocapture %c) {
entry:
  %umul = tail call { <4 x i32>, <4 x i1> } @llvm.sadd.with.overflow.v4i32(<4 x i32> %a, <4 x i32> %b)
  %cmp = extractvalue { <4 x i32>, <4 x i1> } %umul, 1
  %umul.value = extractvalue { <4 x i32>, <4 x i1> } %umul, 0
  %storemerge = select <4 x i1> %cmp, <4 x i32> zeroinitializer, <4 x i32> %umul.value
  store <4 x i32> %storemerge, ptr %c, align 16
  ret void
}

;===---------------------------------------------------------------------===//
; Declarations of the intrinsics.
declare { i16, i1 } @llvm.sadd.with.overflow.i16(i16, i16)
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32)
declare { i64, i1 } @llvm.sadd.with.overflow.i64(i64, i64)
declare { <4 x i32>, <4 x i1> } @llvm.sadd.with.overflow.v4i32(<4 x i32>, <4 x i32>)