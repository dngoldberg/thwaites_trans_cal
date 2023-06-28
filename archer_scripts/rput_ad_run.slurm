#!/bin/bash

#SBATCH --partition=serial
#SBATCH --qos=serial
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --time=1:00:00
#SBATCH --mem=32gb

# start timer

#
# make combined netcdf files
#

timestart="$(date +%s)"
echo >> times
echo Sync start `date` >> times
echo Sync start seconds `date +%s` >> times

run_folder=$1

cd $SLURM_SUBMIT_DIR/..
tar -czvf ${run_folder}.tgz ${run_folder}/outputoptiter* ${run_folder}/runoptiter* ${run_folder}/gradcontrol ${run_folder}/err ${run_folder}/out

if [ $HOMEHOST != 'null' ] ; then

  HOMEDIR=$HOMEROOT/THWAITES

  echo home folder $HOMEDIR

  ssh -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos -t $HOMEHOST "mkdir -p $HOMEDIR"
#  scp -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos $i.tgz $HOMEHOST:$HOMEDIR
  rsync -e "ssh -l dgoldber -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos" -avzL --remove-source-files ${run_folder}.tgz $HOMEHOST:$HOMEDIR
  ssh -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos -t $HOMEHOST "cd $HOMEDIR; tar -xzvf \"${run_folder}\".tgz"
  ssh -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos -t $HOMEHOST "cd $HOMEDIR; rm \"${run_folder}\".tgz"

#  rsync -e "ssh -l dgoldber -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos" -avzL *crash* $HOMEHOST:$HOMEDIR

#  rsync -e "ssh -l dgoldber -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos" -avzL --remove-source-files $Lsurfdiag $HOMEHOST:$HOMEDIR/$run_folder
#  rsync -e "ssh -l dgoldber -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos" -avzL --remove-source-files $Ldyndiag $HOMEHOST:$HOMEDIR/$run_folder
#  rsync -e "ssh -l dgoldber -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos" -avzL --remove-source-files $Ocestate $HOMEHOST:$HOMEDIR/$run_folder

#  rsync -e "ssh -l dgoldber -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos" -avzL --remove-source-files $Lstdoutoce $HOMEHOST:$HOMEDIR/$run_folder

#  process_id=$!
#  wait $process_id
#  rm $Lsurfdiag


#  process_id=$!
#  wait $process_id
#  rm $Lstdout

#  process_id=$!
#  wait $process_id
#  rm $Ocestate

#  rsync -avzL stateSalt.nc $HOMEHOST:$HOMEDIR
#  rsync -avzL stateRho.nc $HOMEHOST:$HOMEDIR
#  rsync -avzL stateUvel.nc $HOMEHOST:$HOMEDIR
#  rsync -avzL stateVvel.nc $HOMEHOST:$HOMEDIR
#  rsync -avzL stateWvel.nc $HOMEHOST:$HOMEDIR

fi

# end timer
timeend="$(date +%s)"
elapsedtotal="$(expr $timeend - $timestart)"
echo >> times
echo Sync end `date` >> times
echo Sync end seconds `date +%s` >> times
echo Sync-time seconds: $elapsedtotal >> times

