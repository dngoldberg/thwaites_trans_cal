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

run_folder=$1

cd $SLURM_SUBMIT_DIR/../$run_folder


bash opt_script.csh

cd ../archer_scripts
module load cray-python
source /work/n02/n02/dngoldbe/myenv/bin/activate
export PYTHONPATH="${PYTHONPATH}:/work/n02/n02/dngoldbe/MITgcm/utils/python/MITgcmutils/MITgcmutils/"
source /work/n02/n02/dngoldbe/mitgcm/scripts/mit_archer.sh
RES=$(sbatch --job-name=DOWNLOAD rput_ad_run.slurm $run_folder)
echo $RES rput_run_ad.slurm $run_folder >> job_id_list

if [ $2 == 1 ]; then
bash submit_val.sh ../$run_folder/exp*txt
fi


exit
