; ModuleID = 'debug-vector.cl'
source_filename = "debug-vector.cl"
target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir-unknown-unknown"

; Function Attrs: convergent noinline norecurse nounwind optnone
define dso_local spir_kernel void @test_vector(ptr addrspace(1) noundef align 16 %out) #0 !kernel_arg_addr_space !3 !kernel_arg_access_qual !4 !kernel_arg_type !5 !kernel_arg_base_type !6 !kernel_arg_type_qual !7 {
entry:
  %out.addr = alloca ptr addrspace(1), align 4
  %v = alloca <4 x float>, align 16
  %.compoundliteral = alloca <4 x float>, align 16
  store ptr addrspace(1) %out, ptr %out.addr, align 4
  store <4 x float> <float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00>, ptr %.compoundliteral, align 16
  %0 = load <4 x float>, ptr %.compoundliteral, align 16
  store <4 x float> %0, ptr %v, align 16
  %1 = load <4 x float>, ptr %v, align 16
  %2 = load ptr addrspace(1), ptr %out.addr, align 4
  %arrayidx = getelementptr inbounds <4 x float>, ptr addrspace(1) %2, i32 0
  store <4 x float> %1, ptr addrspace(1) %arrayidx, align 16
  ret void
}

attributes #0 = { convergent noinline norecurse nounwind optnone "no-trapping-math"="true" "stack-protector-buffer-size"="8" "uniform-work-group-size"="false" }

!llvm.module.flags = !{!0}
!opencl.ocl.version = !{!1}
!opencl.spir.version = !{!1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 2, i32 0}
!2 = !{!"Ubuntu clang version 18.1.3 (1ubuntu1)"}
!3 = !{i32 1}
!4 = !{!"none"}
!5 = !{!"float4*"}
!6 = !{!"float __attribute__((ext_vector_type(4)))*"}
!7 = !{!""}
