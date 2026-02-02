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
paramfile=$3
source ./parse_params.sh $SLURM_SUBMIT_DIR/../${run_folder}/$paramfile
echo "numInvIter: $numInvIter"

cd $SLURM_SUBMIT_DIR/..
tar -czvf ${run_folder}.tgz ${run_folder}/outputoptiter* ${run_folder}/runoptiter* ${run_folder}/gradcontrol ${run_folder}/err ${run_folder}/out ${run_folder}/*.bin ${run_folder}/*constraints ${run_folder}/params_file.txt

if [ $HOMEHOST != 'null' ] ; then

  HOMEDIR=$HOMEROOT/THWAITES/${exp_folder}

  echo home folder $HOMEDIR

  ssh -p6022 -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos -t $HOMEHOST "mkdir -p $HOMEDIR"
  rsync -e "ssh -l dgoldber -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos -p6022" -avzL --remove-source-files ${run_folder}.tgz $HOMEHOST:$HOMEDIR
  ssh -p6022 -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos -t $HOMEHOST "cd $HOMEDIR; tar -xzvf \"${run_folder}\".tgz"
  ssh -p6022 -i /home/n02/n02/dngoldbe/.ssh/id_rsa_cirrus_geos -t $HOMEHOST "cd $HOMEDIR; rm \"${run_folder}\".tgz"
  cd $run_folder

  ii=`./add0upto3c $numInvIter`
  cp -rv runoptiter${ii} temprunoptiter${ii}
  rm -rv runoptiter*
  cp -rv temprunoptiter${ii} runoptiter${ii}
  rm -v runoptiter*/STD*
  rm -v OPTIM/OPWARM*


fi

# end timer
timeend="$(date +%s)"
elapsedtotal="$(expr $timeend - $timestart)"
echo >> times
echo Sync end `date` >> times
echo Sync end seconds `date +%s` >> times
echo Sync-time seconds: $elapsedtotal >> times

