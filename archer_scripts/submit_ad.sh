#!/bin/bash
################################################
# Start a self-resubmitting simulation.
################################################

# ID number for run

# clean run directory and link all required files

# record start times
TIMEQSTART="$(date +%s)"
#echo Start-time `date` >> ../run_forward/times

if [ $# -lt 3 ]; then
	echo "pass a file, then a dependency (-1 if none), validation flag optional"
	exit
fi

if [ -f "$1" ]; then
	cat $1
else
	echo "pass a file that exists"
	exit
fi

#if [ -f "$2" ]; then
#	job_dep=$2
#else
#	val=1
#fi

if [ $# -eq 3 ]; then
 val=$3
else
 val=1
fi
dep=$2


output=$(bash prepare_run_ad.sh $1) 
echo $output

nm=$(echo $output|cut -d ' ' -f1)

#echo $output
#echo "GOT HERE DONE PREPARE"

#echo $JOBNO
#echo $TIMEQSTART
#echo $HECACC
# submit the job chain
#
cp $1 ../$nm
source ./parse_params.sh $1
if [ $dep -ne -1 ]; then
 RES=$(sbatch --job-name=ice_$1 --dependency=$dep -A n02-GRISLAKES run_ad.slurm $nm $1 $val $expFolder)
else
# echo "DO NOT RUN"
 RES=$(sbatch --job-name=ice_$1 -A n02-GRISLAKES run_ad.slurm $nm $1 $val $expFolder)
fi
echo $RES run_ad.slurm $1 $nm $expFolder >> job_id_list
jobid=$(echo $RES | awk '{print $4}')
echo $jobid
