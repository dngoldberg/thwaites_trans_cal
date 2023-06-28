#!/bin/bash
################################################
# Clean out old results and link input files.
################################################

code_dir=code
input_dir=../input_tc/


while read -r line; do
   # Look for the correct line (if you have other parameters)
   if [[ $line == Sliding:* ]]; then
      sliding=$(echo "$line" | cut -c 10-);
   fi;
   if [[ $line == Timedep:* ]]; then
      tdep=$(echo "$line" | cut -c 10-);
   fi;
   if [[ $line == MeltType:* ]]; then
      melttype=$(echo "$line" | cut -c 11-);
   fi;
   if [[ $line == GlenType:* ]]; then
      glentype=$(echo "$line" | cut -c 11-);
   fi;
   if [[ $line == BetaType:* ]]; then
      betatype=$(echo "$line" | cut -c 11-);
   fi;
   if [[ $line == Smith:* ]]; then
      smithconstr=$(echo "$line" | cut -c 8-);
   fi;
   if [[ $line == BigConstr:* ]]; then
      bigconstr=$(echo "$line" | cut -c 12-);
   fi;
   if [[ $line == gentim:* ]]; then
      gentim=$(echo "$line" | cut -c 9-);
   fi;
done < $1

if [ x$sliding == x ]; then
	sliding='coul'
fi
if [ x$tdep == x ]; then
	tdep='tc'
fi
if [ x$melttype == x ]; then
	melttype=g
fi
if [ x$glentype == x ]; then
	glentype=0
fi
if [ x$betatype == x ]; then
	betatype=0
fi
if [ x$smithconstr == x ]; then
	smithconstr=''
fi
if [ x$bigconstr == x ]; then
	bigconstr='surf'
fi
if [ x$gentim == x ]; then
	gentim='gentim'
fi



if [ $tdep == 'snap' ] || [ $tdep == 'snapBM' ]; then
	build_dir=build_snap
        run_folder="run_ad_${sliding}_$tdep"
	cd $input_dir; 
	cd $OLDPWD
else
        run_folder="run_ad_${sliding}_${tdep}_${gentim}_${melttype}${glentype}${betatype}${smithconstr}_${bigconstr}"
	ad_folder="../run_ad_${sliding}_snap"
	if [ $gentim == 'genarr' ]; then
		build_dir=build_genarr
	        cd $input_dir; 
	        cd $OLDPWD
	else 
		build_dir=build_gentim
	        cd $input_dir; 
	        cd $OLDPWD
	fi
fi

echo $run_folder

exit

