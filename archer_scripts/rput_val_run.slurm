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
exp_folder=$2

cd $SLURM_SUBMIT_DIR/..
rm U.* V.* T.* S.* W.* hFac*
tar -czvf ${run_folder}.tgz ${run_folder}/*.meta ${run_folder}/STDOUT.0000 ${run_folder}/*.data ${run_folder}/err ${run_folder}/out ${run_folder}/params_file.txt

if [ $HOMEHOST != 'null' ] ; then

  HOMEDIR=$HOMEROOT/THWAITES/${exp_folder}

  echo home folder $HOMEDIR

  ssh -p6022 -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos -t $HOMEHOST "mkdir -p $HOMEDIR"
  rsync -e "ssh -l dgoldber -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos -p6022" -avzL --remove-source-files ${run_folder}.tgz $HOMEHOST:$HOMEDIR
  ssh -p6022 -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos -t $HOMEHOST "cd $HOMEDIR; tar -xzvf \"${run_folder}\".tgz"
  ssh -p6022 -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos -t $HOMEHOST "cd $HOMEDIR; rm \"${run_folder}\".tgz"
  ssh -p6022 -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos -t $HOMEHOST "cd /home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/batch_scripts; bash process_dir.sh $HOMEDIR/\"${run_folder}\" \"${exp_folder}\""

fi

# end timer
timeend="$(date +%s)"
elapsedtotal="$(expr $timeend - $timestart)"
echo >> times
echo Sync end `date` >> times
echo Sync end seconds `date +%s` >> times
echo Sync-time seconds: $elapsedtotal >> times

