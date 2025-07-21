; RUN: llc -O0 -mtriple=spirv64-unknown-unknown %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv64-unknown-unknown %s -o - -filetype=obj | spirv-val %}

; This test checks that basic blocks are reordered in SPIR-V so that dominators
; are emitted ahead of their dominated blocks as required by the SPIR-V
; specification.

; CHECK-DAG: OpName %[[#ENTRY:]] "entry"
; CHECK-DAG: OpName %[[#FOR_BODY137_LR_PH:]] "for.body137.lr.ph"
; CHECK-DAG: OpName %[[#FOR_BODY:]] "for.body"

; CHECK: %[[#ENTRY]] = OpLabel
; CHECK: %[[#FOR_BODY]] = OpLabel
; CHECK: %[[#FOR_BODY137_LR_PH]] = OpLabel

define spir_kernel void @test(ptr addrspace(1) %arg) local_unnamed_addr #0 !kernel_arg_addr_space !1 !kernel_arg_access_qual !2 !kernel_arg_type !3 !kernel_arg_base_type !3 !kernel_arg_type_qual !4 {
entry:
  br label %for.body

for.body137.lr.ph:                                ; preds = %for.body
  ret void

for.body:                                         ; preds = %for.body, %entry
  br i1 undef, label %for.body, label %for.body137.lr.ph
}

attributes #0 = { "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable }

!llvm.ident = !{!0}

!0 = !{!"clang version 9.0.0 "}
!1 = !{i32 1}
!2 = !{!"none"}
!3 = !{!"uchar*"}
!4 = !{!""}
