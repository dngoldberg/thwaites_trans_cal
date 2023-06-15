#!/bin/sh
#SBATCH --time=1:00:00
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --tasks-per-node=100
#SBATCH --cpus-per-task=1
#SBATCH --partition=standard
#SBATCH --qos=standard
##SBATCH --reservation=shortqos


# hardwire budget if you wish to over-ride default
#export HECACC=n02-NEI025867
#export HECACC=n02-NEM001660


#module load leave_time
#module load intel-mpi-18
#module load mpt/2.22
#module load intel-compilers-18
#module load intel-compilers-19

#module restore /etc/cray-pe.d/PrgEnv-gnu
#module swap cray-mpich  cray-mpich/8.1.3
# brings in wriogn gcc, no netcdf -  module load cray-hdf5
#module load cray-hdf5-parallel/1.12.0.2
#module load cray-netcdf-hdf5parallel/4.7.4.2

module load PrgEnv-gnu
module swap cray-mpich  cray-mpich/8.1.4
module load cray-hdf5-parallel/1.12.0.3
module load cray-netcdf-hdf5parallel/4.7.4.3

if [ $2 == "snap" ]; then
        run_folder="run_val_$1_snap"
else
 run_folder="run_val_$1_$2$3$4_$5$6"
fi

cd $SLURM_SUBMIT_DIR/../${run_folder}
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

srun --distribution=block:block --hint=nomultithread ./mitgcmuv > out 2> err

exit
