; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv64-unknown-unknown %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv64-unknown-unknown %s -o - -filetype=obj | spirv-val %}

%struct.Result32 = type { i32, i1 }
%struct.ResultV4i32 = type { <4 x i32>, <4 x i1> }

; CHECK: %[[#Int:]] = OpTypeInt 32 0
; CHECK: %[[#Bool:]] = OpTypeBool
; CHECK: %[[#Zero:]] = OpConstantNull %[[#Int]]
; CHECK: %[[#IntVector:]] = OpTypeVector %[[#Int]] 4
; CHECK: %[[#BoolVector:]] = OpTypeVector %[[#Bool]] 4
; CHECK: %[[#Composite:]] = OpConstantComposite %[[#IntVector]] %[[#Zero]] %[[#Zero]] %[[#Zero]] %[[#Zero]]

; CHECK: %[[#Add:]] = OpIAdd %[[#Int]] %[[#]] %[[#]]
; CHECK: %[[#Cmp1:]] = OpSLessThan %[[#Bool]] %[[#Add]] %[[#]]
; CHECK: %[[#Cmp2:]] = OpSLessThan %[[#Bool]] %[[#]] %[[#Zero]]
; CHECK: %[[#]] = OpLogicalNotEqual %[[#Bool]] %[[#Cmp2]] %[[#Cmp1]]
define spir_func %struct.Result32 @test_sadd_overflow_i32(i32 %a, i32 %b) {
entry:
  %res_tuple = call {i32, i1} @llvm.sadd.with.overflow.i32(i32 %a, i32 %b)
  %sum = extractvalue {i32, i1} %res_tuple, 0
  %overflow = extractvalue {i32, i1} %res_tuple, 1
  %s1 = insertvalue %struct.Result32 undef, i32 %sum, 0
  %s2 = insertvalue %struct.Result32 %s1, i1 %overflow, 1
  ret %struct.Result32 %s2
}
declare {i32, i1} @llvm.sadd.with.overflow.i32(i32, i32)

; CHECK: %[[#Add:]] = OpIAdd %[[#IntVector]] %[[#]] %[[#]]
; CHECK: %[[#Cmp1:]] = OpSLessThan %[[#BoolVector]] %[[#Add]] %[[#]]
; CHECK: %[[#Cmp2:]] = OpSLessThan %[[#BoolVector]] %[[#]] %[[#Composite]]
; CHECK: %[[#]] = OpLogicalNotEqual %[[#BoolVector]] %[[#Cmp2]] %[[#Cmp1]]
define spir_func %struct.ResultV4i32 @test_sadd_overflow_v4i32(<4 x i32> %a, <4 x i32> %b) {
entry:
  %res_tuple = call {<4 x i32>, <4 x i1>} @llvm.sadd.with.overflow.v4i32(<4 x i32> %a, <4 x i32> %b)
  %sum = extractvalue {<4 x i32>, <4 x i1>} %res_tuple, 0
  %overflow = extractvalue {<4 x i32>, <4 x i1>} %res_tuple, 1
  %s1 = insertvalue %struct.ResultV4i32 undef, <4 x i32> %sum, 0
  %s2 = insertvalue %struct.ResultV4i32 %s1, <4 x i1> %overflow, 1
  ret %struct.ResultV4i32 %s2
}
declare {<4 x i32>, <4 x i1>} @llvm.sadd.with.overflow.v4i32(<4 x i32>, <4 x i32>)

; CHECK: %[[#Add:]] = OpISub %[[#Int]] %[[#]] %[[#]]
; CHECK: %[[#Cmp1:]] = OpSLessThan %[[#Bool]] %[[#Add]] %[[#]]
; CHECK: %[[#Cmp2:]] = OpSGreaterThan %[[#Bool]] %[[#]] %[[#Zero]]
; CHECK: %[[#]] = OpLogicalNotEqual %[[#Bool]] %[[#Cmp2]] %[[#Cmp1]]
define spir_func %struct.Result32 @test_ssub_overflow_i32(i32 %a, i32 %b) {
entry:
  %res_tuple = call {i32, i1} @llvm.ssub.with.overflow.i32(i32 %a, i32 %b)
  %sum = extractvalue {i32, i1} %res_tuple, 0
  %overflow = extractvalue {i32, i1} %res_tuple, 1
  %s1 = insertvalue %struct.Result32 undef, i32 %sum, 0
  %s2 = insertvalue %struct.Result32 %s1, i1 %overflow, 1
  ret %struct.Result32 %s2
}
declare {i32, i1} @llvm.ssub.with.overflow.i32(i32, i32)

; CHECK: %[[#Add:]] = OpISub %[[#IntVector]] %[[#]] %[[#]]
; CHECK: %[[#Cmp1:]] = OpSLessThan %[[#BoolVector]] %[[#Add]] %[[#]]
; CHECK: %[[#Cmp2:]] = OpSGreaterThan %[[#BoolVector]] %[[#]] %[[#Composite]]
; CHECK: %[[#]] = OpLogicalNotEqual %[[#BoolVector]] %[[#Cmp2]] %[[#Cmp1]]
define spir_func %struct.ResultV4i32 @test_ssub_overflow_v4i32(<4 x i32> %a, <4 x i32> %b) {
entry:
  %res_tuple = call {<4 x i32>, <4 x i1>} @llvm.ssub.with.overflow.v4i32(<4 x i32> %a, <4 x i32> %b)
  %sum = extractvalue {<4 x i32>, <4 x i1>} %res_tuple, 0
  %overflow = extractvalue {<4 x i32>, <4 x i1>} %res_tuple, 1
  %s1 = insertvalue %struct.ResultV4i32 undef, <4 x i32> %sum, 0
  %s2 = insertvalue %struct.ResultV4i32 %s1, <4 x i1> %overflow, 1
  ret %struct.ResultV4i32 %s2
}
declare {<4 x i32>, <4 x i1>} @llvm.ssub.with.overflow.v4i32(<4 x i32>, <4 x i32>)
