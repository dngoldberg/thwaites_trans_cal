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
source /work/n02/n02/dngoldbe/mitgcm/scripts/mit_archer.sh


run_folder=$1
expFolder=$2
start_time=$(date +%s)
MSGEMAIL=$(echo "Job starting val: $1")
RES=$(sbatch --job-name=EML -A $HECACC /work/n02/n02/dngoldbe/mitgcm/scripts/email_serial.slurm "${MSGEMAIL}" $SLURM_JOB_ID)
#echo $RES EMAIL >> job_id_list

cd $SLURM_SUBMIT_DIR/../$run_folder

srun --distribution=block:block --hint=nomultithread ./mitgcmuv

cd ../archer_scripts
source /work/n02/n02/dngoldbe/mitgcm/scripts/mit_archer.sh
RES=$(sbatch --job-name=DOWNLOAD -A $HECACC rput_val_run.slurm $run_folder $expFolder)
echo rput_val_run.slurm $run_folder $RES >> job_id_list

end_time=$(date +%s)
totaltime=$(((end_time-start_time)/60))
MSGEMAIL=$(echo "Job ending val: $1, total time: $totaltime minutes")
RES=$(sbatch --job-name=EML -A $HECACC /work/n02/n02/dngoldbe/mitgcm/scripts/email_serial.slurm "${MSGEMAIL}" $SLURM_JOB_ID)
#echo $RES EMAIL >> job_id_list


exit
