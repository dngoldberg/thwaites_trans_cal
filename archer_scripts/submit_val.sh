#!/bin/bash
################################################
# Start a self-resubmitting simulation.
################################################

# ID number for run
JOBNO=00

# clean run directory and link all required files

# record start times
TIMEQSTART="$(date +%s)"
#echo Start-time `date` >> ../run_forward/times


./prepare_run_validate.sh $1 $2 $3 $4 $5 $6


#1 sliding lar
#2 melt mode
#3 bglen mode
#4 beta mode
#5 project_mode

#run_folder="run_val_$1_$2$3$4_$5"

echo $JOBNO
echo $TIMEQSTART
echo $HECACC
# submit the job chain
RES=$(sbatch --job-name=ice_$1 -A $HECACC run_val.slurm $1 $2 $3 $4 $5 $6)
echo $RES run_val.slurm $1 $2 $3 $4 $5 $6 >> job_id_list
#qsub -A $HECACC run.sh
