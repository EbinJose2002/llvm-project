; RUN: llc -O0 -mtriple=spirv64-unknown-unknown %s -o - | FileCheck %s

; CHECK: %[[#FalseVal:]] = OpConstantFalse %[[#]] 
; CHECK: OpReturnValue %[[#FalseVal]]

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64-unknown-unknown"

define spir_func i1 @f(float %0) {
 %2 = fcmp false float %0, %0
 ret i1 %2
}
