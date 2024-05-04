program drhook_ex3
implicit none
integer(4) :: n
real(8), allocatable  :: a(:)
integer(4) :: j

n = 100
allocate(a(n))
do j=1,n
  a(j) = j-1
enddo
write(0,*)'drhook_ex3: sum#1 = ',sum(a)
deallocate(a)

n = 5 * n
allocate(a(n))
do j=1,n
  a(j) = j + n
enddo
do j=1,n
 call sub1(a,j)
enddo
write(0,*)'drhook_ex3: sum#2 = ',sum(a)
deallocate(a)

n = n/10
allocate(a(-n:n))
do j=-n,n
  a(j) = j + 2*n
enddo
do j=1,n
 call sub1(a,j)
enddo
write(0,*)'drhook_ex3: sum#3 = ',sum(a)
deallocate(a)
end program drhook_ex3

subroutine sub1(a,n)
implicit none
integer(4), intent(in) :: n
real(8), intent(inout) :: a(n)
integer(4) j
do j=1,n
  if (mod(j,2) == 0) call sub2(a(j))
  a(j) = 2*a(j) + 1
enddo
end subroutine sub1

subroutine sub2(s)
implicit none
real(8), intent(inout) :: s
s = 1/(s+1)
end subroutine sub2
