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


./prepare_run_ad.sh $1 $2 $3 $4 $5 $6 $7

echo $JOBNO
echo $TIMEQSTART
echo $HECACC
# submit the job chain
RES=$(sbatch --job-name=ice_$1 -A $HECACC run_ad.slurm $1 $2 $3 $4 $5 $6 $7)
echo $RES run_ad.slurm $1 $2 $3 $4 $5 $6 $7 >> job_id_list
#qsub -A $HECACC run.sh
