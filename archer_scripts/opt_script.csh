#!/bin/sh

#
#
#

#nprocs=128
itermax=0
procsonnode=128


#



name=optiter
echo "Beginning of script"
echo "HERE0"
ite=`egrep 'optimcycle' data.optim | sed 's/ optimcycle=//'| sed 's/,$//'`
echo "HERE1"
echo $ite
i=`expr $ite + 1`
echo "HERE2"
echo $itermax

source /work/n02/n02/dngoldbe/mitgcm/scripts/mit_archer.sh

mkdir gradcontrol

while [ $i -le $itermax ]
do
 echo "GOT HERE 1"
 ii=`./add0upto3c $i`
 echo "GOT HERE 2"
 echo "Beginning of iteration $ii"
 cp OPTIM/ecco_ctrl_MIT_CE_000.opt0$ii .
 ite=`expr $i - 1`
 sed "s/ optimcycle=$ite/ optimcycle=$i/" data.optim > TTT.tmp
 mv -f TTT.tmp data.optim
 fich=output$name$ii
 echo "Running mitcgm_ad: iteration $ii"
 srun --distribution=block:block --hint=nomultithread ./mitgcmuv_ad > out 2> err
 rm tapelev*
 rm oad_cp*
 mv STDOUT.0000 $fich
 egrep optimcycle data.optim >> fcost$name
 grep "objf_temp_tut(" $fich >> fcost$name
 grep "objf_hflux_tut(" $fich >> fcost$name
 egrep 'global fc =' $fich >> fcost$name
 grep 'global fc =' $fich
 echo Cleaning
 \rm tapelev*
 mv adxx* gradcontrol
 mv xx* gradcontrol
 if [ $((i % 1)) -eq 0 ]; then 
  direc=run$name$ii
  mkdir $direc
  rm maskCtrl* hFac* wunit* RA*ta DX*ta DY*ta DR*ta PH*ta
  mv -f *.meta *.data STDOUT* STDERR* out err $direc 
  mv -f $direc/wunit*.*data ./
 fi
 cp -f ecco_ctrl_MIT_CE_000.opt0$ii OPTIM/
 cp -f ecco_cost_MIT_CE_000.opt0$ii OPTIM/
 echo "Line-search: iteration $ii"
 cd OPTIM/
 egrep optimcycle data.optim
 cp -f ../data.optim .
 ./optim.x > std$ii
 cd ..

 if [ $((i % 10)) -eq 0 ]; then 
     now=$(date +"%T")
     costthin=$(grep "thinning contr" $fich)
     costdhdt=$(grep "dhdt contr" $fich)
     costglen=$(grep "bglen smooth" $fich)
     costprio=$(grep "prior smooth" $fich) 
     costvel=$(grep "td vel misfit" $fich)
     MSGEMAIL=$(echo "ice model cost, current time: $now, current iter: $i, thin cost: $costthin, dhdt cost: $costdhdt, smooth cost: $costglen, prior cost: $costprio, vel cost: $costvel")
     sbatch --job-name=EML -A $HECACC /work/n02/n02/dngoldbe/mitgcm/scripts/email_serial.slurm "${MSGEMAIL}" $SLURM_JOB_ID
 fi

 echo $i
 i=`expr $i + 1`
 echo "GOT HERE END"
 echo $i
done

rm tapelev*
rm oad_cp*
rm ecco_c*

exit

for i in $(ls -d runoptiter*00); do 
 mv $i SAVE$i;
done
#rm OPTIM/OPWARM*



#----------------------------------------------------

# --- end of script ---
