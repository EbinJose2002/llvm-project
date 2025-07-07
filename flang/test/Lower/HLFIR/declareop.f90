! RUN: bbc -emit-hlfir %s -o - | FileCheck %s

! Check that declareop doesnt redefine shape for box type operands.

! CHECK: %[[VAR:[0-9]+]]:2 = hlfir.declare %{{.*}} {fortran_attrs = #fir.var_attrs<pointer>, uniq_name = "_QMm3Ecy1"}
! CHECK-NOT: hlfir.declare %{{.*}}, %{{.*}}

module m3
  type x1
     integer::ix1
  end type x1
  type,extends(x1)::x2
  end type x2
  type,extends(x2)::x3
  end type x3
  class(x1),pointer,dimension(:)::cy1
contains
  subroutine dummy()
  entry chk(c1)
   class(x1),dimension(3)::c1
 end subroutine dummy
end module m3

subroutine s1
  use m3
  type(x1),target::ty1(3)
  ty1%ix1=[1,2,3]
  cy1=>ty1
  call chk(cy1)
end subroutine s1

program main
  call s1
  print *,'pass'
end program main
