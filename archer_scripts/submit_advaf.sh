#!/bin/bash
################################################
# Start a self-resubmitting simulation.
################################################

# ID number for run

# clean run directory and link all required files

# record start times
TIMEQSTART="$(date +%s)"
#echo Start-time `date` >> ../run_forward/times

if [ $# == 0 ]; then
	echo "pass a file"
	exit
fi

if [ -f "$1" ]; then
	cat $1
else
	echo "pass a file that exists"
	exit
fi

output=$(bash prepare_run_advaf.sh $1) 

nm=$(echo $output|cut -d ' ' -f1)
echo $output
echo $nm

echo $JOBNO
echo $TIMEQSTART
echo $HECACC
# submit the job chain
cp $1 ../$nm
source ./parse_params.sh $1
RES=$(sbatch --job-name=ice_$1 -A n02-GRISLAKES run_advaf.slurm $nm)
echo $RES run_advaf.slurm $1 $nm >> job_id_list
