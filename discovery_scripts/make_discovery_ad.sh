
# Switch compilers as  the Cray compiler gives an error.
#module swap PrgEnv-gnu PrgEnv-intel
#module swap PrgEnv-cray PrgEnv-intel
##module swap cray-netcdf netcdf
#module load netcdf-nc-max-vars
#module load cray-petsc

#ROOTDIR=/home/dgoldber/MITgcm

#module restore PrgEnv-cray
#module load cray-hdf5-parallel/1.12.0.2
#module load cray-netcdf-hdf5parallel/4.7.4.2

#module purge
#module load intel-compilers/19.3
#module load mpich/3.3.0-intel19.3
#module load mkl/19.3
#module load cmake/3.10.1
#export PETSCDIR=/dartfs-hpc/rc/home/d/f006sfd/trunk-jpl/externalpackages/petsc/install



# module load nco/4.9.6-gcc-10.1.0
# module load ncview/ncview-2.1.7-gcc-10.1.0

export LD_LIBRARY_PATH=$PETSC_DIR/lib:$LD_LIBRARY_PATH

if [ $1 == "genarr" ]; then
	numgen=5
	numtim=0
elif [ $1 == "snap" ]; then 
        numgen=2
        numtim=0
elif [ $1 == "gentim" ]; then
        numgen=4
        numtim=2
fi

code_dir=code
strgen="      parameter ( maxCtrlArr2D = $numgen )"
strtim="      parameter ( maxCtrlTim2D = $numtim )"

build_dir=build_$1
cd ../$code_dir
sed "s/.*parameter ( maxCtrlArr2D.*/$strgen/" CTRL_SIZE.h > data.streamice.temp
mv data.streamice.temp CTRL_SIZE.h
sed "s/.*parameter ( maxCtrlTim2D.*/$strtim/" CTRL_SIZE.h > data.streamice.temp
mv data.streamice.temp CTRL_SIZE.h
cd $OLDPWD

if [ -d "../$build_dir" ]; then
  cd ../$build_dir
  rm -rf *
else
  echo 'Creating build directory'
  mkdir ../$build_dir
  cd ../$build_dir
fi


cd $ROOTDIR
git checkout branch_controls_snap_tc
cd $OLDPWD

sing_str="$HOME/openad/openad_latest.sif"


#rm ../$code_dir/cost_test.F
#ln ../$code_dir/cost_test.F.snap_noBglen ../$code_dir/cost_test.F


make CLEAN
$ROOTDIR/tools/genmake2 -mods=../$code_dir -of=$HOME/own_scripts/dev_linux_amd64_discovery_oad -oad -mpi --oadsingularity "$sing_str"
#$ROOTDIR/tools/genmake2 -ieee -mods='../code ../newcode' -of=$ROOTDIR/tools/build_options/linux_amd64_gfortran -mpi
#$ROOTDIR/tools/genmake2 -mods='../code' -mpi
ln -s $PETSC_DIR/include/*.mod .
make adAll

# Switch Programming Environment back
#module swap PrgEnv-intel PrgEnv-cray
#module swap netcdf cray-netcdf
