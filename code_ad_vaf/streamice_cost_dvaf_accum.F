#include "STREAMICE_OPTIONS.h"
c#ifdef ALLOW_AUTODIFF
c# include "AUTODIFF_OPTIONS.h"
c#endif
#ifdef ALLOW_COST
# include "COST_OPTIONS.h"
#endif

      subroutine streamice_cost_dvaf_accum ( myIter, myThid )
C     *==========================================================*
C     | subroutine streamice_cost_surf_accum                     |
C     | o this routine calculates the surface misfit contri-     |
C     |   bution to the per-timestep STREAMICE cost              |
C     *==========================================================*
C     |                                                          |
C     | Notes                                                    |
C     | =====                                                    |
C     *==========================================================*
      IMPLICIT NONE

C     == Global variables ===
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DYNVARS.h"
#ifdef ALLOW_STREAMICE
# include "STREAMICE.h"
#endif

#ifdef ALLOW_COST
# include "cost.h"
#endif
c#ifdef ALLOW_AUTODIFF_TAMC
c# include "tamc.h"
c#endif

C     == Routine arguments ==
C     myThid - Thread number for this instance of the routine.
      integer myIter, myThid

#ifdef ALLOW_STREAMICE_TC_COST
C     == Local variables
      _RL HAF
      integer i, j, k, bi, bj
      integer ig, jg
      integer itlo,ithi
      integer jtlo,jthi
      integer il
      CHARACTER*(10) myIterStr
      INTEGER  ILNBLNK
      EXTERNAL ILNBLNK
      CHARACTER*(MAX_LEN_FNAM) surffilename, errsurffilename
      _RL surfobs (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL errsurfobs (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL rhoi, rhow, r, i_r, i_numcells, surf_err, h, hf,
     &        r_low_tmp, mytime, mult
      WRITE(myIterStr,'(I10.10)') myIter

c#ifdef ALLOW_AUTODIFF_TAMC
cCADJ STORE surf_el_streamice  = comlev1, key = ikey_dynamics,
cCADJ &     kind = isbyte
cCADJ STORE H_streamice_prev  = comlev1, key = ikey_dynamics,
cCADJ &     kind = isbyte
cCADJ STORE H_streamice  = comlev1, key = ikey_dynamics,
cCADJ &     kind = isbyte
c#endif

      rhoi = streamice_density
      rhow = streamice_density_ocean_avg
      r=rhoi/rhow
      i_r = 1./r
      i_numcells = 1.0/(Nx*Ny)

      mytime=myIter * deltaT / 31536000.
      
      mult=0.
      if (ABS(mytime-58).lt..01) then
              mult=-0.2
      else
              mult=0.2
      endif

C--   Calculate cost function on tile of this instance
      DO bj=myByLo(myThid),myByHi(myThid)
        DO bi=myBxLo(myThid),myBxHi(myThid)
          do j=1,sNy
            do i=1,sNx

             if (streamice_hmask(i,j,bi,bj).eq.1.0) then

              r_low_tmp = R_low_si (i,j,bi,bj)

              if (r_low_tmp .ge. 0.0) then
               HAF = h_streamice (i,j,bi,bj)
              else
               HAF = h_streamice (i,j,bi,bj) +
     &          (streamice_density_ocean_avg / streamice_density
     &          * r_low_tmp)
              endif

              if (HAF .gt. 0.0) then
               cost_func1_streamice (bi,bj) =
     &         cost_func1_streamice (bi,bj) +
     &         mult * HAF * rA (i,j,bi,bj)
               cost_surf_streamice (bi,bj) =
     &         cost_surf_streamice (bi,bj) +
     &         mult * HAF * rA (i,j,bi,bj)
              endif

             endif

            end do
          end do
        end do
      end do

#endif

      RETURN
      END
