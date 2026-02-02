#!/bin/bash
################################################

# Start a calibration run.
# To be run on the ARCHER2 Supercomputer.

# This script takes 3 arguments:
#   1. a path to a parameter file
#   2. a JobID (will wait until that job is finished to start new batch
#      (-1 otherwise)
#   3. a flag (1 or 0) to indicate submission of validation job once the 
#      calibration is finished
#
#
#   The parameter file specifies (up to) 21 operational parameters
#    (see exp_main.txt in folder) 
#
#   Sliding:       [coul / weert] the sliding law to be used in the simulation
#   Timedep:       [tc / snap] specify transient or snapshot calibration
#   MeltType:      [G / g / 1 / 0] set melt rate control to be distributed 
#                               (either 1 or 0) or global (G or g); and 
#                               to be time-varying (G or 1) or time-constant
#                               (g or 0)
#   GlenType:      [0 / 1] set Bglen control to be time-varying (1) or constant (0)
#   BetaType:      [0 / 1] set Beta control to be time-varying (1) or constant (0)
#   Smith:         [S / NS] include/exclude ice-shelf constraints from Smith 2020
#   BigConstr:     [vel / surf / mix] determines whether the run is a vel-only, 
#                                   surf-only or mixed calibration (for post-
#                                   processing purposes only)
#   gentim:        [gentim / snap] should be set to "gentim" if "Timedep" is "tc"
#   proj:          [min/max/last/mean] the method of selecting validation controls if 
#                                calibration is time-varying
#   longproj:      length of validation run (y) after calibration period (2004-2012)
#                  and validation (2012-2017). should be set to 50.
#   meltconst:     perturbation to deep melt rate (m/a). "n" if zero.
#   tikhbeta:      tikhonov smoothing coefficient for beta
#   tikhbglen:     tikhonov smoothing coefficient for bglen
#   bdotdepth:     depth at which melt rate = 0
#   wgtvel:        cost coefficient of velocity misfit in transient cal
#   wgtsurf:       cost coefficient of surface misfit in transient cal
#   Restart:       set to false
#   precondMelt:   gradient scaling of melt ctrl
#   precondBeta:   gradient scaling of beta
#   precondBglen:  gradient scaling of bglen
#   numInvIter:    # of iterations
#   numInvSaveRun: frequency (of iterations with which to save the experiment diagnostics
#   expFolder:     for postprocessing purposes
#
#
#   the file will be passed to md5sum to give a unique ID for the experiment

########################################################################

# ID number for run

# clean run directory and link all required files

# record start times
TIMEQSTART="$(date +%s)"
#echo Start-time `date` >> ../run_forward/times

if [ $# -lt 4 ]; then
	echo "pass a file, then a dependency ID (-1 if none), then a dependency params file (-1 if none), validation flag optional"
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

if [ $# -eq 4 ]; then
 val=$4
else
 val=1
fi
depID=$2
depFile=$3
echo $depFile
if [ "$depFile" == "-1" ]; then
	output=$(bash prepare_run_ad.sh $1)
else
 if [ "$depID" == "-1" ]; then
	output=$(bash prepare_run_ad.sh $1 $depFile)
 else
	output=$(bash prepare_run_ad.sh $1)
 fi
fi
echo $output

nm=$(echo $output|cut -d ' ' -f1)
echo $nm
#echo $output
echo "GOT HERE DONE PREPARE"

#echo $JOBNO
#echo $TIMEQSTART
#echo $HECACC
# submit the job chain
#
cp $1 ../$nm
source ./parse_params.sh $1
if [ $depID -ne -1 ]; then
 RES=$(sbatch --job-name=ice_${nm} --dependency=$depID -A n02-GRISLAKES run_ad.slurm $nm $1 $val $expFolder $depFile)
else
# echo "DO NOT RUN"
 RES=$(sbatch --job-name=ice_${nm} -A n02-GRISLAKES run_ad.slurm $nm $1 $val $expFolder -1)
fi
echo $RES run_ad.slurm $1 $nm $expFolder >> job_id_list
jobid=$(echo $RES | awk '{print $4}')
echo $jobid
