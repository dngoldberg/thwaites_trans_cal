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

./prepare_run_ad.sh $1 $2 $3

echo $JOBNO
echo $TIMEQSTART
echo $HECACC
# submit the job chain
sbatch --job-name=ice_$1 -A $HECACC run_ad.slurm $1 $2 $3
#qsub -A $HECACC run.sh
