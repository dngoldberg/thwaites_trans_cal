#!/bin/sh

#
#
#

#nprocs=128
itermax=35
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

mkdir gradcontrol

while [ $i -le $itermax ]
do
 echo "GOT HERE"
 ii=`./add0upto3c $i`
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
 if [ `expr $i % 5` -eq 0 ]
 then
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
rm OPTIM/OPWARM*



#----------------------------------------------------

# --- end of script ---
