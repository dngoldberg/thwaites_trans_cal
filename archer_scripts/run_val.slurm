#!/bin/sh
#SBATCH --time=12:00:00
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --tasks-per-node=100
#SBATCH --cpus-per-task=1
#SBATCH --partition=standard
#SBATCH --qos=standard
##SBATCH --reservation=shortqos


module load PrgEnv-gnu
#module swap cray-mpich  cray-mpich/8.1.4
module load cray-hdf5-parallel
module load cray-netcdf-hdf5parallel

export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK


run_folder=$1
start_time=$(date +%s)

cd $SLURM_SUBMIT_DIR/../$run_folder

srun --distribution=block:block --hint=nomultithread ./mitgcmuv

cd ../archer_scripts
RES=$(sbatch --job-name=DOWNLOAD rput_val_run.slurm $run_folder)
echo rput_val_run.slurm $run_folder >> job_id_list



exit
