#!/bin/sh
#SBATCH --time=12:00:00
#SBATCH --exclusive
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=1
#SBATCH -o outlog
#SBATCH -e errlog
#SBATCH --account=ice
#SBATCH --mem=2G
##SBATCH --mail-type=END,FAIL
##SBATCH --job-name=20220927_Kangerlussuaq_Obs_Budd_sidewall_mw0_iT070
##SBATCH -o 20220927_Kangerlussuaq_Obs_Budd_sidewall_mw0_iT070.outlog
##SBATCH -e 20220927_Kangerlussuaq_Obs_Budd_sidewall_mw0_iT070.errlog
##SBATCH --nodes=1
##SBATCH --ntasks-per-node=16
##SBATCH --time=02:00:00



if [ $2 == 'snap' ]; then
        run_folder="${ICESHARE}/run_ad_${1}_${2}"
else
        run_folder="${ICESHARE}/run_ad_${1}_${2}_${3}"
fi


cd $run_folder

bash opt_script.csh

exit
