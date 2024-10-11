#!/bin/sh
##SBATCH --time=00:20:00
#SBATCH --time=23:45:00
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --tasks-per-node=100
#SBATCH --cpus-per-task=1
#SBATCH --partition=standard
#SBATCH --qos=standard
##SBATCH --qos=short
##SBATCH --reservation=shortqos


module load PrgEnv-gnu
#module swap cray-mpich  cray-mpich/8.1.4
module load cray-hdf5-parallel
module load cray-netcdf-hdf5parallel

export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK
source /work/n02/n02/dngoldbe/mitgcm/scripts/mit_archer.sh

run_folder=$1

cd $SLURM_SUBMIT_DIR/../$run_folder

start_time=$(date +%s)
MSGEMAIL=$(echo "Job starting opt: $1")
echo $MSGEMAIL
echo $SLURM_JOB_ID
echo $HECACC
RES=$(sbatch --job-name=EML -A $HECACC /work/n02/n02/dngoldbe/mitgcm/scripts/email_serial.slurm "${MSGEMAIL}" $SLURM_JOB_ID)
echo $RES EMAIL >> job_id_list


bash opt_script.csh

cd ../archer_scripts
module load cray-python
source /work/n02/n02/dngoldbe/myenv/bin/activate
export PYTHONPATH="${PYTHONPATH}:/work/n02/n02/dngoldbe/MITgcm/utils/python/MITgcmutils/MITgcmutils/"
source /work/n02/n02/dngoldbe/mitgcm/scripts/mit_archer.sh
RES=$(sbatch --job-name=DOWNLOAD -A $HECACC rput_ad_run.slurm $run_folder)
echo $RES rput_run_ad.slurm $run_folder >> job_id_list

if [ $2 == 1 ]; then
bash submit_val.sh ../$run_folder/exp*txt
fi

end_time=$(date +%s)
totaltime=$(((end_time-start_time)/60))
MSGEMAIL=$(echo "Job ending opt: $1, total time: $totaltime minutes")
RES=$(sbatch --job-name=EML -A $HECACC /work/n02/n02/dngoldbe/mitgcm/scripts/email_serial.slurm "${MSGEMAIL}" $SLURM_JOB_ID)
echo $RES EMAIL >> job_id_list

exit
