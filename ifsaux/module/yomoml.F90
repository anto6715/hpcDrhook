MODULE YOMOML

!-- the following system specific omp_lib-module is not always available (e.g. pgf90)
!! use omp_lib

USE PARKIND1  ,ONLY : JPIM, JPIB

!**SS/18-Feb-2005
!--Dr.Hook references removed, because these locks may also be
!  called from within drhook.c itself !! 
!--Also, there could be considerable & unjustified overhead
!  when using Dr.Hook in such a low level

!**SS/15-Dec-2005
!--The size of lock-variables are now OMP_LOCK_KIND as of in OMP_LIB,
!  and OMP_LOCK_KIND is aliased to OML_LOCK_KIND
!  OMP_LOCK_KIND is usually 4 in 32-bit addressing mode
!                           8 in 64-bit addressing mode
!--M_OML_LOCK changed to M_EVENT and kept as 32-bit int
!--OML_FUNCT changed to OML_TEST_EVENT
!--M_LOCK initialized to -1
!--M_EVENT initialized to 0
!--Added intent(s)
!--Support for omp_lib (but not always available)
!--Locks can now also be set/unset OUTSIDE the parallel regions
!--Added routine OML_TEST_LOCK (attempts to set lock, but if *un*successful, does NOT  block)
!--Buffer-zone for M_LOCK; now a vector of 2 elements in case problems/inconsistencies with OMP_LOCK_KIND 4/8

!**SS/22-Feb-2006
!--Locking routines are doing nothing unless OMP_GET_MAX_THREADS() > 1
!  This is to avoid unacceptable deadlocks/timeouts with signal handlers when
!  the only thread receives signal while inside locked region
!--Affected routines: OML_TEST_LOCK()  --> always receives .TRUE.
!                     OML_SET_LOCK()   --> sets nothing
!                     OML_UNSET_LOCK() --> unsets nothing
!                     OML_INIT_LOCK()  --> inits nothing

!**SS/11-Sep-2006
!--Added OML_DEBUG feature

!**REK/18-Jul-2007
!--Protected OML_DESTROY_LOCK

!**REK/07-Sep-2007
!--Add OMP FLUSH feature

!**SS/05-Dec-2007
!--Added routine OML_NUM_THREADS([optional_new_number_of_threads])
! 1) To adjust [reduce] the number of threads working in concert
!    Accepts only # of threads between 1 and the max # of threads (i.e. from export OMP_NUM_THREADS=<value>)
! 2) Returns the previous active number of threads
! 3) Can be called from outside the OpenMP-parallel region only

!**SS/14-Dec-2007
!--The routine OML_NUM_THREADS() now also accepts character string (= environment variable)
!  as the sole argumentoz
!--You could now set effective number of threads (<= $OMP_NUM_THREADS) to the value of
!  particular environment variable; f.ex.:
!  export OML_MSGPASS_OBSDATA_READ=8 and call to OML_NUM_THREADS('OML_MSGPASS_OBSDATA_READ')
!  would set the effective no. of threads to (max) 8 when reading obs. wiz msgpass_obsdata

!**SS/09-May-2008
!-- OML_NUM_THREADS() did not work as expected since I misinterpreted the meaning of 
!   the OpenMP-function OMP_NUM_THREADS()
!-- With two PRIVATE [to this module] variables the bug will get sorted out
!   + a new routine OML_INIT() was added (to be called from MPL_INIT or so)

IMPLICIT NONE

SAVE

PRIVATE

LOGICAL :: OML_DEBUG = .FALSE.

INTERFACE OML_NUM_THREADS
MODULE PROCEDURE &
     & OML_NUM_THREADS_INT, &
     & OML_NUM_THREADS_STR
END INTERFACE

PUBLIC OML_WAIT_EVENT, OML_SET_EVENT, OML_INCR_EVENT, &
   &   OML_MY_THREAD,  OML_MAX_THREADS , OML_OMP, &
   &   OML_IN_PARALLEL, OML_TEST_EVENT, &
   &   OML_UNSET_LOCK, OML_INIT_LOCK, OML_SET_LOCK, OML_DESTROY_LOCK, &
   &   OML_LOCK_KIND, OML_TEST_LOCK, OML_DEBUG, OML_NUM_THREADS, &
   &   OML_INIT

!-- The following should normally be 4 in 32-bit addressing mode
!                                    8 in 64-bit addressing mode
! Since system specific omp_lib-module is not always available (e.g. pgf90)
! we hardcode OML_LOCK_KIND to JPIB (usually 8) for now
!!INTEGER(KIND=JPIM), PARAMETER :: OML_LOCK_KIND = OMP_LOCK_KIND
INTEGER(KIND=JPIM), PARAMETER :: OML_LOCK_KIND = JPIB

!-- Note: Still JPIM !!
INTEGER(KIND=JPIM) :: M_EVENT = 0

!-- Note: OML_LOCK_KIND, not JPIM !!
INTEGER(KIND=OML_LOCK_KIND) :: M_LOCK(2) = (/-1, -1/)

!-- The two PRIVATE [to this module] variables
INTEGER(KIND=JPIM) :: N_OML_MAX_THREADS = -1

CONTAINS

SUBROUTINE OML_INIT()
!$ INTEGER(KIND=JPIM) OMP_GET_MAX_THREADS
IF (N_OML_MAX_THREADS == -1) THEN
   N_OML_MAX_THREADS = 1
!$ N_OML_MAX_THREADS = OMP_GET_MAX_THREADS()
ENDIF
END SUBROUTINE OML_INIT

FUNCTION OML_OMP()
LOGICAL :: OML_OMP
OML_OMP=.FALSE.
!$ OML_OMP=.TRUE.
END FUNCTION OML_OMP

FUNCTION OML_IN_PARALLEL()
LOGICAL :: OML_IN_PARALLEL
!$ LOGICAL :: OMP_IN_PARALLEL
!$ INTEGER(KIND=JPIM) OMP_GET_MAX_THREADS
OML_IN_PARALLEL=.FALSE.
!$ OML_IN_PARALLEL=((OMP_GET_MAX_THREADS() > 1).AND.OMP_IN_PARALLEL())
END FUNCTION OML_IN_PARALLEL

FUNCTION OML_TEST_LOCK(MYLOCK)
INTEGER(KIND=OML_LOCK_KIND),intent(inout),optional :: MYLOCK
LOGICAL :: OML_TEST_LOCK
!$ LOGICAL :: OMP_TEST_LOCK
!$ INTEGER(KIND=JPIM) OMP_GET_MAX_THREADS
OML_TEST_LOCK = .TRUE.
!$ IF(OMP_GET_MAX_THREADS() > 1) THEN
!$   IF(PRESENT(MYLOCK))THEN
!$     OML_TEST_LOCK = OMP_TEST_LOCK(MYLOCK)
!$   ELSE
!$     OML_TEST_LOCK = OMP_TEST_LOCK(M_LOCK(1))
!$   ENDIF
!$ ENDIF
END FUNCTION OML_TEST_LOCK

SUBROUTINE OML_UNSET_LOCK(MYLOCK)
INTEGER(KIND=OML_LOCK_KIND),intent(inout),optional :: MYLOCK
!$ INTEGER(KIND=JPIM) OMP_GET_MAX_THREADS
!$ IF(OMP_GET_MAX_THREADS() > 1) THEN
!$   IF(PRESENT(MYLOCK))THEN
!$     CALL OMP_UNSET_LOCK(MYLOCK)
!$   ELSE
!$     CALL OMP_UNSET_LOCK(M_LOCK(1))
!$   ENDIF
!$ ENDIF
END SUBROUTINE OML_UNSET_LOCK

SUBROUTINE OML_SET_LOCK(MYLOCK)
INTEGER(KIND=OML_LOCK_KIND),intent(inout),optional :: MYLOCK
!$ INTEGER(KIND=JPIM) OMP_GET_MAX_THREADS
!$ IF(OMP_GET_MAX_THREADS() > 1) THEN
!$   IF(PRESENT(MYLOCK))THEN
!$     CALL OMP_SET_LOCK(MYLOCK)
!$   ELSE
!$     CALL OMP_SET_LOCK(M_LOCK(1))
!$   ENDIF
!$ ENDIF
END SUBROUTINE OML_SET_LOCK

SUBROUTINE OML_INIT_LOCK(MYLOCK)
INTEGER(KIND=OML_LOCK_KIND),intent(inout),optional :: MYLOCK
!$ INTEGER(KIND=JPIM) OMP_GET_MAX_THREADS
!$ IF(OMP_GET_MAX_THREADS() > 1) THEN
!$   IF(PRESENT(MYLOCK))THEN
!$     CALL OMP_INIT_LOCK(MYLOCK)
!$   ELSE
!$     CALL OMP_INIT_LOCK(M_LOCK(1))
!$   ENDIF
!$ ENDIF
END SUBROUTINE OML_INIT_LOCK

SUBROUTINE OML_DESTROY_LOCK(MYLOCK)
INTEGER(KIND=OML_LOCK_KIND),intent(inout),optional :: MYLOCK
!$ INTEGER(KIND=JPIM) OMP_GET_MAX_THREADS
!$ IF(OMP_GET_MAX_THREADS() > 1) THEN
!$   IF(PRESENT(MYLOCK))THEN
!$     CALL OMP_DESTROY_LOCK(MYLOCK)
!$   ELSE
!$     CALL OMP_DESTROY_LOCK(M_LOCK(1))
!$   ENDIF
!$ ENDIF
END SUBROUTINE OML_DESTROY_LOCK

FUNCTION OML_TEST_EVENT(K,MYEVENT)
LOGICAL :: OML_TEST_EVENT
INTEGER(KIND=JPIM),intent(in) :: K,MYEVENT
!$OMP FLUSH
IF(K.EQ.MYEVENT) THEN
 OML_TEST_EVENT =.TRUE.
ELSE
 OML_TEST_EVENT=.FALSE.
ENDIF
END FUNCTION OML_TEST_EVENT

SUBROUTINE OML_WAIT_EVENT(K,MYEVENT)
INTEGER(KIND=JPIM),intent(in) :: K
INTEGER(KIND=JPIM),intent(in),OPTIONAL :: MYEVENT
IF(PRESENT(MYEVENT))THEN
  DO
    IF(OML_TEST_EVENT(K,MYEVENT)) EXIT
  ENDDO
ELSE
  DO
    IF(OML_TEST_EVENT(K,M_EVENT)) EXIT
  ENDDO
ENDIF
END SUBROUTINE OML_WAIT_EVENT

SUBROUTINE OML_SET_EVENT(K,MYEVENT)
INTEGER(KIND=JPIM),intent(in) :: K
INTEGER(KIND=JPIM),intent(out),OPTIONAL :: MYEVENT
IF(PRESENT(MYEVENT))THEN
  MYEVENT=K
ELSE
  M_EVENT=K
ENDIF
END SUBROUTINE OML_SET_EVENT

SUBROUTINE OML_INCR_EVENT(K,MYEVENT)
INTEGER(KIND=JPIM) :: K
INTEGER(KIND=JPIM),intent(inout),OPTIONAL :: MYEVENT
IF(PRESENT(MYEVENT))THEN
  MYEVENT=MYEVENT+K
ELSE
  M_EVENT=M_EVENT+K
ENDIF
!$OMP FLUSH
END SUBROUTINE OML_INCR_EVENT

FUNCTION OML_MY_THREAD()
INTEGER(KIND=JPIM) :: OML_MY_THREAD
!$ INTEGER(KIND=JPIM) OMP_GET_THREAD_NUM
OML_MY_THREAD = 1
!$ OML_MY_THREAD = OMP_GET_THREAD_NUM() + 1
END FUNCTION OML_MY_THREAD

FUNCTION OML_MAX_THREADS()
INTEGER(KIND=JPIM) :: OML_MAX_THREADS
!$ INTEGER(KIND=JPIM) OMP_GET_MAX_THREADS
OML_MAX_THREADS = 1
!$ OML_MAX_THREADS = OMP_GET_MAX_THREADS()
END FUNCTION OML_MAX_THREADS

FUNCTION OML_NUM_THREADS_INT(KOMP_SET_THREADS)
INTEGER(KIND=JPIM) :: OML_NUM_THREADS_INT
INTEGER(KIND=JPIM),intent(in),OPTIONAL :: KOMP_SET_THREADS
!$ LOGICAL :: OMP_IN_PARALLEL
!$ INTEGER(KIND=JPIM) OMP_GET_MAX_THREADS
OML_NUM_THREADS_INT = 1
!$ OML_NUM_THREADS_INT = OMP_GET_MAX_THREADS()
!$ IF (PRESENT(KOMP_SET_THREADS)) THEN
!$   IF (KOMP_SET_THREADS >= 1 .AND. KOMP_SET_THREADS <= N_OML_MAX_THREADS) THEN
!- This is the absolute max no. of threads available --> ^^^^^^^^^^^^^^^^^ <--
!$     IF (.NOT.OMP_IN_PARALLEL()) THEN ! Change only if called from OUTSIDE the OpenMP-parallel region
!$       CALL OMP_SET_NUM_THREADS(KOMP_SET_THREADS)
!$     ENDIF
!$   ENDIF
!$ ENDIF
END FUNCTION OML_NUM_THREADS_INT

FUNCTION OML_NUM_THREADS_STR(CD_ENV)
INTEGER(KIND=JPIM) :: OML_NUM_THREADS_STR
character(len=*),intent(in) :: CD_ENV
!$ character(len=20) CLvalue
!$ INTEGER(KIND=JPIM) :: itmp
OML_NUM_THREADS_STR = 1
!$ OML_NUM_THREADS_STR = OML_NUM_THREADS_INT()
!$ IF (LEN(CD_ENV) > 0) THEN
!$   CALL EC_GETENV(CD_ENV,CLvalue)
!$   IF (CLvalue /= ' ') THEN
!$     READ(CLvalue,'(i20)',end=99,err=99) itmp
!$     OML_NUM_THREADS_STR = OML_NUM_THREADS_INT(itmp)
!$   ENDIF
!$ 99 continue
!$ ENDIF
END FUNCTION OML_NUM_THREADS_STR

END MODULE YOMOML
