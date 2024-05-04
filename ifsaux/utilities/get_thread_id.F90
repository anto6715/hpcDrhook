FUNCTION get_thread_id() RESULT(tid)
USE PARKIND1  ,ONLY : JPIM
USE yomoml, only : OML_MY_THREAD
implicit none
INTEGER(KIND=JPIM) :: tid
tid = 1
!$ tid = OML_MY_THREAD()
END FUNCTION get_thread_id
