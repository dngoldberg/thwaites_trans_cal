# $Header: /u/gcmpack/MITgcm_contrib/mlosch/optim_m1qn3/Makefile,v 1.4 2016/05/09 09:36:00 mlosch Exp $
# $Name:  $
#***********************************************************************
# Makefile for the off-line large scale optimization with m1qn3
# in reverse communication mode.
#
# started: Martin Losch Martin.Losch@awi.de 24-Apr-2012
#
# changed: 
#
#***********************************************************************

MAKEFILE=Makefile
# The optimization routines.
SRC		=	optim_main.F			\
			optim_sub.F			\
			optim_readparms.F		\
			optim_readdata.F		\
			optim_writedata.F		\
			optim_store_m1qn3.F		\
                        m1qn3_offline.F			\
                        ddot.F                          

EXEDIR     = .

# default suffix for pre-processed fortran files is f
SUFF=f
# for case-insensitive file systems you may need this
# SUFF=for
# Location of cpp preprocessor
# default is (Linux)
CPP             = cat $< | cpp -P -traditional
# Mac OS X
# CPP             = cat $< | /usr/bin/cpp -P -traditional
# on SUNOS
# CPP		= cat $< | /usr/ccs/lib/cpp

#$MAKEDEPEND=~/makedepend-1.0.5/makedepend
# this works when you done have a makedepend
MAKEDEPEND=~/MITgcm/tools/xmakedepend

INCLUDEDIRS     = -I.				\
                  -I../../build_snap

LIBDIRS         = 
LIBS            = 

EXECUTABLE      = $(EXEDIR)/optim.x

# The cpp flags.
CPPFLAGS = -DREAL_BYTE=4		\
	-DMAX_INDEPEND=2000000		\
	-D_RL='double precision'	\
	-D_RS='double precision'	\
	-D_d='d' -D_BYTESWAPIO 
#CPPFLAGS = -DALLOW_USE_MPI -DALWAYS_USE_MPI -DWORDLENGTH=1 -D_BYTESWAPIO -DDEFAULT_R8 -DALLOW_USE_MPI -DHAVE_SYSTEM -DHAVE_FDATE -DHAVE_ETIME_FCT -DHAVE_CLOC -DHAVE_SETRLSTK -DHAVE_SIGREG -DHAVE_STAT -DHAVE_LAPACK -DHAVE_FLUSH -D_RL='double precision' -D_RS='double precision' -DREAL_BYTE=8 -D_d='d' -DMAX_INDEPEND=1000000

#                -DMAX_INDEPEND=293570968        \
# FORTRAN compiler and its flags.
# It is important that byte conversion flags are consistent between this
# compilation and the mitgcmuv compilation
# default is gfortran
#FC              = ifort
#FFLAGS          = -h pic -dynamic -O3 -hfp3 -Oipa5

# ifort compilers
FC              = ifort
#FFLAGS          = -dynamic
FFLAGS = -assume byterecl -convert big_endian -O2 

# SGI o3k IRIX64
#FC              = f77
#FFLAGS          = -extend_source -bytereclen -mips4 -r8 -static

# AER cluster
#FC		= /opt/mpich/bin/mpif77
#FFLAGS		= -byteswapio -r8 -Mnodclchk -Mextend

# Cray compiler
#FC     = ftn
#FFLAGS =  -h byteswapio -hnoomp -O0 -hfp0

SMALLF      = $(SRC:.F=.$(SUFF))
OBJECTS     = $(SRC:.F=.o)

.SUFFIXES:
.SUFFIXES: .o .$(SUFF) .F

all: small_f $(EXECUTABLE)
$(EXECUTABLE): $(OBJECTS)
	$(FC) -o $@ $(FFLAGS) $(OBJECTS) $(LIBDIRS) $(LIBS)

small_f: $(SMALLF)

depend:
	$(MAKEDEPEND) -o .$(SUFF) $(INCLUDEDIRS) $(SRC)

# The normal chain of rules is (  .F - .f - .o  )
.F.for:
	$(CPP) $(CPPFLAGS) $(INCLUDEDIRS) > $@
.for.o:
	$(FC) $(FFLAGS) -c $<
.F.f:
	$(CPP) $(CPPFLAGS) $(INCLUDEDIRS) > $@
.f.o:
	$(FC) $(FFLAGS) -c $<

# Cleaning options.
clean:
	-rm -f *.o *.f *.for

Clean:
	@make -f $(MAKEFILE) clean
	-rm -f OPWARM.*

CLEAN:
	@make -f $(MAKEFILE) Clean
	-rm -f $(EXECUTABLE)

# DO NOT DELETE


