MODULE MPL_WAIT_MOD

!**** MPL_WAIT Waits for completion

!     Purpose.
!     --------
!     Returns control when the operation(s) identified by the request
!     is completed.
!     Normally used in conjunction with non-blocking buffering type

!**   Interface.
!     ----------
!        CALL MPL_WAIT

!        Input required arguments :
!        -------------------------
!           PBUF     -  array with same size and shape as buffer
!                       used for MPL_SEND or MPL_RECV
!           KREQUEST -  array or scalar containing
!                       Communication request(s)
!                       as provided by MPL_RECV or MPL_SEND

!        Input optional arguments :
!        -------------------------
!           CDSTRING -  Character string for ABORT messages
!                       used when KERROR is not provided

!        Output required arguments :
!        -------------------------
!           none

!        Output optional arguments :
!        -------------------------
!           KOUNT    -  must be the same size and shape as KREQUEST
!                       contains number of items sent/received
!           KERROR   -  return error code.     If not supplied, 
!                       MPL_WAIT aborts when an error is detected.
!     Author.
!     -------
!        D.Dent, M.Hamrud     ECMWF

!     Modifications.
!     --------------
!        Original: 2000-09-01
!        J. Hague: 2005-04-25  WAITALL replaced by WAIT loop

!     ------------------------------------------------------------------

USE PARKIND1  ,ONLY : JPIM     ,JPRB     ,JPRM

USE MPL_MPIF
USE MPL_DATA_MODULE
USE MPL_MESSAGE_MOD

IMPLICIT NONE

PRIVATE

INTERFACE MPL_WAIT
MODULE PROCEDURE MPL_WAITS_REAL4,MPL_WAITS_REAL8,MPL_WAITS_INT, &
               & MPL_WAIT1_REAL4,MPL_WAIT1_REAL8,MPL_WAIT1_INT, &
               & MPL_WAITS_INT2,MPL_WAIT1_INT2
END INTERFACE

PUBLIC MPL_WAIT

CONTAINS 


SUBROUTINE MPL_WAITS_REAL4(PBUF,KREQUEST,KOUNT,KERROR,CDSTRING)


#ifdef USE_8_BYTE_WORDS
  Use mpi4to8, Only : &
    MPI_WAITALL => MPI_WAITALL8, MPI_GET_COUNT => MPI_GET_COUNT8, &
    MPI_WAIT => MPI_WAIT8
#endif

REAL(KIND=JPRM)                        :: PBUF(:)
INTEGER(KIND=JPIM),INTENT(IN)          :: KREQUEST(:)
CHARACTER*(*),INTENT(IN),OPTIONAL :: CDSTRING
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KOUNT(SIZE(KREQUEST))
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KERROR
INTEGER(KIND=JPIM) :: IWAITERR,ICOUNTERR,JL,IREQLEN,ICOUNT,IW
INTEGER(KIND=JPIM) :: IWAIT_STATUS(MPI_STATUS_SIZE,SIZE(KREQUEST))
LOGICAL :: LLABORT
LLABORT=.TRUE.
IWAITERR=0
ICOUNTERR=0

IF(MPL_NUMPROC < 1) CALL MPL_MESSAGE( &
  & CDMESSAGE='MPL_WAIT: MPL NOT INITIALISED ',LDABORT=LLABORT) 

IREQLEN=SIZE(KREQUEST)
!CALL MPI_WAITALL(IREQLEN,KREQUEST,IWAIT_STATUS,IWAITERR)
DO JL=1,IREQLEN
  CALL MPI_WAIT(KREQUEST(JL),IWAIT_STATUS(1,JL),IW)
  IWAITERR=MAX(IWAITERR,IW)
ENDDO

IF(PRESENT(KOUNT))THEN
  IF(SIZE(KOUNT) /= IREQLEN) THEN
    CALL MPL_MESSAGE( &
    & CDMESSAGE='MPL_WAIT: KOUNT AND KREQUEST INCONSISTENT ', &
    & CDSTRING=CDSTRING,LDABORT=LLABORT)
  ENDIF
  DO JL=1,IREQLEN
    CALL MPI_GET_COUNT(IWAIT_STATUS(1,JL),INT(MPI_REAL4),KOUNT(JL),ICOUNTERR)
  ENDDO
ENDIF

IF(PRESENT(KERROR))THEN
  KERROR=IWAITERR+ICOUNTERR
ELSE IF(IWAITERR /= 0) THEN
  CALL MPL_MESSAGE(IWAITERR,'MPL_WAIT_WAITING',CDSTRING,LDABORT=LLABORT)
ELSE IF(ICOUNTERR /= 0) THEN
  CALL MPL_MESSAGE(ICOUNTERR,'MPL_WAIT_COUNT',CDSTRING,LDABORT=LLABORT)
ENDIF

RETURN
END SUBROUTINE MPL_WAITS_REAL4


SUBROUTINE MPL_WAIT1_REAL4(PBUF,KREQUEST,KOUNT,KERROR,CDSTRING)


#ifdef USE_8_BYTE_WORDS
  Use mpi4to8, Only : &
    MPI_WAITALL => MPI_WAITALL8, MPI_GET_COUNT => MPI_GET_COUNT8
#endif

REAL(KIND=JPRM)                      :: PBUF(:)
INTEGER(KIND=JPIM),INTENT(IN)          :: KREQUEST
CHARACTER*(*),INTENT(IN),OPTIONAL :: CDSTRING
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KOUNT
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KERROR
INTEGER(KIND=JPIM) :: IWAITERR,ICOUNTERR,JL,IREQLEN,ICOUNT
INTEGER(KIND=JPIM) :: IWAIT_STATUS(MPI_STATUS_SIZE,1)
LOGICAL :: LLABORT
LLABORT=.TRUE.
IWAITERR=0
ICOUNTERR=0

IF(MPL_NUMPROC < 1) CALL MPL_MESSAGE( &
  & CDMESSAGE='MPL_WAIT: MPL NOT INITIALISED ',LDABORT=LLABORT) 

IREQLEN=1
CALL MPI_WAITALL(IREQLEN,KREQUEST,IWAIT_STATUS,IWAITERR)

IF(PRESENT(KOUNT))THEN
  CALL MPI_GET_COUNT(IWAIT_STATUS(1,1),INT(MPI_REAL4),KOUNT,ICOUNTERR)
ENDIF

IF(PRESENT(KERROR))THEN
  KERROR=IWAITERR+ICOUNTERR
ELSE IF(IWAITERR /= 0) THEN
  CALL MPL_MESSAGE(IWAITERR,'MPL_WAIT_WAITING',CDSTRING,LDABORT=LLABORT)
ELSE IF(ICOUNTERR /= 0) THEN
  CALL MPL_MESSAGE(ICOUNTERR,'MPL_WAIT_COUNT',CDSTRING,LDABORT=LLABORT)
ENDIF

RETURN
END SUBROUTINE MPL_WAIT1_REAL4


SUBROUTINE MPL_WAITS_REAL8(PBUF,KREQUEST,KOUNT,KERROR,CDSTRING)


#ifdef USE_8_BYTE_WORDS
  Use mpi4to8, Only : &
    MPI_WAITALL => MPI_WAITALL8, MPI_GET_COUNT => MPI_GET_COUNT8, &
    MPI_WAIT => MPI_WAIT8
#endif

REAL(KIND=JPRB)                      :: PBUF(:)
INTEGER(KIND=JPIM),INTENT(IN)          :: KREQUEST(:)
CHARACTER*(*),INTENT(IN),OPTIONAL :: CDSTRING
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KOUNT(SIZE(KREQUEST))
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KERROR
INTEGER(KIND=JPIM) :: IWAITERR,ICOUNTERR,JL,IREQLEN,ICOUNT,IW
INTEGER(KIND=JPIM) :: IWAIT_STATUS(MPI_STATUS_SIZE,SIZE(KREQUEST))
LOGICAL :: LLABORT
LLABORT=.TRUE.
IWAITERR=0
ICOUNTERR=0

IF(MPL_NUMPROC < 1) CALL MPL_MESSAGE( &
  & CDMESSAGE='MPL_WAIT: MPL NOT INITIALISED ',LDABORT=LLABORT) 

IREQLEN=SIZE(KREQUEST)
!CALL MPI_WAITALL(IREQLEN,KREQUEST,IWAIT_STATUS,IWAITERR)
DO JL=1,IREQLEN
  CALL MPI_WAIT(KREQUEST(JL),IWAIT_STATUS(1,JL),IW)
  IWAITERR=MAX(IWAITERR,IW)
ENDDO

IF(PRESENT(KOUNT))THEN
  IF(SIZE(KOUNT) /= IREQLEN) THEN
    CALL MPL_MESSAGE( &
    & CDMESSAGE='MPL_WAIT: KOUNT AND KREQUEST INCONSISTENT ', &
    & CDSTRING=CDSTRING,LDABORT=LLABORT)
  ENDIF
  DO JL=1,IREQLEN
    CALL MPI_GET_COUNT(IWAIT_STATUS(1,JL),INT(MPI_REAL8),KOUNT(JL),ICOUNTERR)
  ENDDO
ENDIF

IF(PRESENT(KERROR))THEN
  KERROR=IWAITERR+ICOUNTERR
ELSE IF(IWAITERR /= 0) THEN
  CALL MPL_MESSAGE(IWAITERR,'MPL_WAIT_WAITING',CDSTRING,LDABORT=LLABORT)
ELSE IF(ICOUNTERR /= 0) THEN
  CALL MPL_MESSAGE(ICOUNTERR,'MPL_WAIT_COUNT',CDSTRING,LDABORT=LLABORT)
ENDIF

RETURN
END SUBROUTINE MPL_WAITS_REAL8


SUBROUTINE MPL_WAIT1_REAL8(PBUF,KREQUEST,KOUNT,KERROR,CDSTRING)


#ifdef USE_8_BYTE_WORDS
  Use mpi4to8, Only : &
    MPI_WAITALL => MPI_WAITALL8, MPI_GET_COUNT => MPI_GET_COUNT8
#endif

REAL(KIND=JPRB)                      :: PBUF(:)
INTEGER(KIND=JPIM),INTENT(IN)          :: KREQUEST
CHARACTER*(*),INTENT(IN),OPTIONAL :: CDSTRING
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KOUNT
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KERROR
INTEGER(KIND=JPIM) :: IWAITERR,ICOUNTERR,JL,IREQLEN,ICOUNT
INTEGER(KIND=JPIM) :: IWAIT_STATUS(MPI_STATUS_SIZE,1)
LOGICAL :: LLABORT
LLABORT=.TRUE.
IWAITERR=0
ICOUNTERR=0

IF(MPL_NUMPROC < 1) CALL MPL_MESSAGE( &
  & CDMESSAGE='MPL_WAIT: MPL NOT INITIALISED ',LDABORT=LLABORT) 

IREQLEN=1
CALL MPI_WAITALL(IREQLEN,KREQUEST,IWAIT_STATUS,IWAITERR)

IF(PRESENT(KOUNT))THEN
  CALL MPI_GET_COUNT(IWAIT_STATUS(1,1),INT(MPI_REAL8),KOUNT,ICOUNTERR)
ENDIF

IF(PRESENT(KERROR))THEN
  KERROR=IWAITERR+ICOUNTERR
ELSE IF(IWAITERR /= 0) THEN
  CALL MPL_MESSAGE(IWAITERR,'MPL_WAIT_WAITING',CDSTRING,LDABORT=LLABORT)
ELSE IF(ICOUNTERR /= 0) THEN
  CALL MPL_MESSAGE(ICOUNTERR,'MPL_WAIT_COUNT',CDSTRING,LDABORT=LLABORT)
ENDIF

RETURN
END SUBROUTINE MPL_WAIT1_REAL8


SUBROUTINE MPL_WAITS_INT(KBUF,KREQUEST,KOUNT,KERROR,CDSTRING)


#ifdef USE_8_BYTE_WORDS
  Use mpi4to8, Only : &
    MPI_WAITALL => MPI_WAITALL8, MPI_GET_COUNT => MPI_GET_COUNT8, &
    MPI_WAIT => MPI_WAIT8
#endif

INTEGER(KIND=JPIM)                     :: KBUF(:)
INTEGER(KIND=JPIM),INTENT(IN)          :: KREQUEST(:)
CHARACTER*(*),INTENT(IN),OPTIONAL :: CDSTRING
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KOUNT(SIZE(KREQUEST))
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KERROR
INTEGER(KIND=JPIM) :: IWAITERR,ICOUNTERR,JL,IREQLEN,ICOUNT,IW
INTEGER(KIND=JPIM) :: IWAIT_STATUS(MPI_STATUS_SIZE,SIZE(KREQUEST))
LOGICAL :: LLABORT
LLABORT=.TRUE.
IWAITERR=0
ICOUNTERR=0

IF(MPL_NUMPROC < 1) CALL MPL_MESSAGE( &
  & CDMESSAGE='MPL_WAIT: MPL NOT INITIALISED ',LDABORT=LLABORT) 

IREQLEN=SIZE(KREQUEST)
!CALL MPI_WAITALL(IREQLEN,KREQUEST,IWAIT_STATUS,IWAITERR)
DO JL=1,IREQLEN
  CALL MPI_WAIT(KREQUEST(JL),IWAIT_STATUS(1,JL),IW)
  IWAITERR=MAX(IWAITERR,IW)
ENDDO

IF(PRESENT(KOUNT))THEN
  IF(SIZE(KOUNT) /= IREQLEN) THEN
    CALL MPL_MESSAGE( &
    & CDMESSAGE='MPL_WAIT: KOUNT AND KREQUEST INCONSISTENT ', &
    & CDSTRING=CDSTRING,LDABORT=LLABORT)
  ENDIF
  DO JL=1,IREQLEN
    CALL MPI_GET_COUNT(IWAIT_STATUS(1,JL),INT(MPI_INTEGER),KOUNT(JL),ICOUNTERR)
  ENDDO
ENDIF

IF(PRESENT(KERROR))THEN
  KERROR=IWAITERR+ICOUNTERR
ELSE IF(IWAITERR /= 0) THEN
  CALL MPL_MESSAGE(IWAITERR,'MPL_WAIT_WAITING',CDSTRING,LDABORT=LLABORT)
ELSE IF(ICOUNTERR /= 0) THEN
  CALL MPL_MESSAGE(ICOUNTERR,'MPL_WAIT_COUNT',CDSTRING,LDABORT=LLABORT)
ENDIF

RETURN
END SUBROUTINE MPL_WAITS_INT


SUBROUTINE MPL_WAIT1_INT(KBUF,KREQUEST,KOUNT,KERROR,CDSTRING)


#ifdef USE_8_BYTE_WORDS
  Use mpi4to8, Only : &
    MPI_WAITALL => MPI_WAITALL8, MPI_GET_COUNT => MPI_GET_COUNT8
#endif

INTEGER(KIND=JPIM)                     :: KBUF(:)
INTEGER(KIND=JPIM),INTENT(IN)          :: KREQUEST
CHARACTER*(*),INTENT(IN),OPTIONAL :: CDSTRING
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KOUNT
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KERROR
INTEGER(KIND=JPIM) :: IWAITERR,ICOUNTERR,JL,IREQLEN,ICOUNT
INTEGER(KIND=JPIM) :: IWAIT_STATUS(MPI_STATUS_SIZE,1)
LOGICAL :: LLABORT
LLABORT=.TRUE.
IWAITERR=0
ICOUNTERR=0

IF(MPL_NUMPROC < 1) CALL MPL_MESSAGE( &
  & CDMESSAGE='MPL_WAIT: MPL NOT INITIALISED ',LDABORT=LLABORT) 

IREQLEN=1
CALL MPI_WAITALL(IREQLEN,KREQUEST,IWAIT_STATUS,IWAITERR)

IF(PRESENT(KOUNT))THEN
  CALL MPI_GET_COUNT(IWAIT_STATUS(1,1),INT(MPI_INTEGER),KOUNT,ICOUNTERR)
ENDIF

IF(PRESENT(KERROR))THEN
  KERROR=IWAITERR+ICOUNTERR
ELSE IF(IWAITERR /= 0) THEN
  CALL MPL_MESSAGE(IWAITERR,'MPL_WAIT_WAITING',CDSTRING,LDABORT=LLABORT)
ELSE IF(ICOUNTERR /= 0) THEN
  CALL MPL_MESSAGE(ICOUNTERR,'MPL_WAIT_COUNT',CDSTRING,LDABORT=LLABORT)
ENDIF

RETURN
END SUBROUTINE MPL_WAIT1_INT


SUBROUTINE MPL_WAITS_INT2(KBUF,KREQUEST,KOUNT,KERROR,CDSTRING)


#ifdef USE_8_BYTE_WORDS
  Use mpi4to8, Only : &
    MPI_WAITALL => MPI_WAITALL8, MPI_GET_COUNT => MPI_GET_COUNT8, &
    MPI_WAIT => MPI_WAIT8
#endif

INTEGER(KIND=JPIM)                     :: KBUF(:,:)
INTEGER(KIND=JPIM),INTENT(IN)          :: KREQUEST(:)
CHARACTER*(*),INTENT(IN),OPTIONAL :: CDSTRING
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KOUNT(SIZE(KREQUEST))
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KERROR
INTEGER(KIND=JPIM) :: IWAITERR,ICOUNTERR,JL,IREQLEN,ICOUNT,IW
INTEGER(KIND=JPIM) :: IWAIT_STATUS(MPI_STATUS_SIZE,SIZE(KREQUEST))
LOGICAL :: LLABORT
LLABORT=.TRUE.
IWAITERR=0
ICOUNTERR=0

IF(MPL_NUMPROC < 1) CALL MPL_MESSAGE( &
  & CDMESSAGE='MPL_WAIT: MPL NOT INITIALISED ',LDABORT=LLABORT) 

IREQLEN=SIZE(KREQUEST)
!CALL MPI_WAITALL(IREQLEN,KREQUEST,IWAIT_STATUS,IWAITERR)
DO JL=1,IREQLEN
  CALL MPI_WAIT(KREQUEST(JL),IWAIT_STATUS(1,JL),IW)
  IWAITERR=MAX(IWAITERR,IW)
ENDDO

IF(PRESENT(KOUNT))THEN
  IF(SIZE(KOUNT) /= IREQLEN) THEN
    CALL MPL_MESSAGE( &
    & CDMESSAGE='MPL_WAIT: KOUNT AND KREQUEST INCONSISTENT ', &
    & CDSTRING=CDSTRING,LDABORT=LLABORT)
  ENDIF
  DO JL=1,IREQLEN
    CALL MPI_GET_COUNT(IWAIT_STATUS(1,JL),INT(MPI_INTEGER),KOUNT(JL),ICOUNTERR)
  ENDDO
ENDIF

IF(PRESENT(KERROR))THEN
  KERROR=IWAITERR+ICOUNTERR
ELSE IF(IWAITERR /= 0) THEN
  CALL MPL_MESSAGE(IWAITERR,'MPL_WAIT_WAITING',CDSTRING,LDABORT=LLABORT)
ELSE IF(ICOUNTERR /= 0) THEN
  CALL MPL_MESSAGE(ICOUNTERR,'MPL_WAIT_COUNT',CDSTRING,LDABORT=LLABORT)
ENDIF

RETURN
END SUBROUTINE MPL_WAITS_INT2


SUBROUTINE MPL_WAIT1_INT2(KBUF,KREQUEST,KOUNT,KERROR,CDSTRING)


#ifdef USE_8_BYTE_WORDS
  Use mpi4to8, Only : &
    MPI_WAITALL => MPI_WAITALL8, MPI_GET_COUNT => MPI_GET_COUNT8
#endif

INTEGER(KIND=JPIM)                     :: KBUF(:,:)
INTEGER(KIND=JPIM),INTENT(IN)          :: KREQUEST
CHARACTER*(*),INTENT(IN),OPTIONAL :: CDSTRING
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KOUNT
INTEGER(KIND=JPIM),INTENT(OUT),OPTIONAL :: KERROR
INTEGER(KIND=JPIM) :: IWAITERR,ICOUNTERR,JL,IREQLEN,ICOUNT
INTEGER(KIND=JPIM) :: IWAIT_STATUS(MPI_STATUS_SIZE,1)
LOGICAL :: LLABORT
LLABORT=.TRUE.
IWAITERR=0
ICOUNTERR=0

IF(MPL_NUMPROC < 1) CALL MPL_MESSAGE( &
  & CDMESSAGE='MPL_WAIT: MPL NOT INITIALISED ',LDABORT=LLABORT) 

IREQLEN=1
CALL MPI_WAITALL(IREQLEN,KREQUEST,IWAIT_STATUS,IWAITERR)

IF(PRESENT(KOUNT))THEN
  CALL MPI_GET_COUNT(IWAIT_STATUS(1,1),INT(MPI_INTEGER),KOUNT,ICOUNTERR)
ENDIF

IF(PRESENT(KERROR))THEN
  KERROR=IWAITERR+ICOUNTERR
ELSE IF(IWAITERR /= 0) THEN
  CALL MPL_MESSAGE(IWAITERR,'MPL_WAIT_WAITING',CDSTRING,LDABORT=LLABORT)
ELSE IF(ICOUNTERR /= 0) THEN
  CALL MPL_MESSAGE(ICOUNTERR,'MPL_WAIT_COUNT',CDSTRING,LDABORT=LLABORT)
ENDIF

RETURN
END SUBROUTINE MPL_WAIT1_INT2

END MODULE MPL_WAIT_MOD
