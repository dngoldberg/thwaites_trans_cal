
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


module load PrgEnv-gnu
#module swap cray-mpich  cray-mpich/8.1.4
#module load cray-hdf5-parallel/1.12.0.3
#module load cray-netcdf-hdf5parallel/4.7.4.3
PETSCDIR=/work/n02/n02/dngoldbe/petsc/


# module load nco/4.9.6-gcc-10.1.0
# module load ncview/ncview-2.1.7-gcc-10.1.0

export LD_LIBRARY_PATH=/work/n02/n02/dngoldbe/petsc/lib:$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
build_dir=build_validate
code_dir=code_validate

if [ -d "../$build_dir" ]; then
  cd ../$build_dir
  rm -rf *
else
  echo 'Creating build directory'
  mkdir ../$build_dir
  cd ../$build_dir
fi


cd $ROOTDIR
git checkout branch_streamice_generic_ctrl_reg
cd $OLDPWD




make CLEAN
$ROOTDIR/tools/genmake2 -mods="../$code_dir" -of=$HOME/own_scripts/dev_linux_amd64_cray_archer2_oad -mpi
#$ROOTDIR/tools/genmake2 -ieee -mods='../code ../newcode' -of=$ROOTDIR/tools/build_options/linux_amd64_gfortran -mpi
#$ROOTDIR/tools/genmake2 -mods='../code' -mpi
echo $LD_LIBRARY_PATH
make depend
make -j

# Switch Programming Environment back
#module swap PrgEnv-intel PrgEnv-cray
#module swap netcdf cray-netcdf
