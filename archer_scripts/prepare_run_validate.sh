#!/bin/bash
################################################
# Clean out old results and link input files.
################################################

code_dir=code
input_dir=../input/


#Sliding: coul
#Timedep: tc
#MeltType: g
#GlenType: 0
#BetaType: 0
#Smith: NS
#BigConstr: surf
#gentim: gentim

#1 sliding lar
#2 melt mode
#3 bglen mode
#4 beta mode
#6 gentim
#7 smith constraint
#5 project_mode


#8 

#8

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
   if [[ $line == project:* ]]; then
      proj=$(echo "$line" | cut -c 10-);
   fi;
   if [[ $line == longproj:* ]]; then
      longproj=$(echo "$line" | cut -c 11-);
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
if [ x$proj == x ]; then
        proj='last'
fi
if [ x$longproj == x ]; then
        longproj=0
fi

if [ $gentim == "gentimlong" ] && [ $longproj == 0 ]; then
	echo "badrun"
	exit
fi

if [ $tdep == "snap" ] || [ $tdep == "snapBM" ]; then
	run_folder="run_val_${sliding}_${tdep}_${longproj}"
        run_ad_folder="run_ad_${sliding}_$tdep"	
else
        run_folder="run_val_${sliding}_${melttype}${glentype}${betatype}${smithconstr}_${proj}_${gentim}_${longproj}"
        run_ad_folder="run_ad_${sliding}_${tdep}_${gentim}_${melttype}${glentype}${betatype}${smithconstr}_${bigconstr}"
fi

build_dir=build_validate

# Empty the run directory - but first make sure it exists!
if [ -d "../$run_folder" ]; then
  cd ../$run_folder
  rm -rf *
else
  mkdir ../$run_folder
  cd ../$run_folder
fi


ln -s $input_dir/* .

if [ $tdep == "tc" ]; then
 cd ../archer_scripts;
 python prepare_validation_controls_const.py 30 $run_ad_folder $run_folder $proj
 cd $OLDPWD
fi


# Deep copy of the master namelist (so it doesn't get overwritten in input/)
rm -f data
cp -f $input_dir/data .

rm -f data.streamice
cp -f $input_dir/data.streamice ./

rm -f data.diagnostics
cp -f $input_dir/data.diagnostics ./


if [ $sliding == 'weert' ]; then
 strcoul=" streamice_allow_reg_coulomb=.false."
 strsmooth=" streamice_smooth_gl_width = 10."
else
 strcoul=" streamice_allow_reg_coulomb=.true."
 strsmooth=" streamice_smooth_gl_width = 0."
fi

sed "s/.*reg_coulomb.*/$strcoul/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*smooth_gl_width.*/$strsmooth/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice

type='short'
if [ $gentim == 'gentimlong' ]; then
  type='long'
fi

timestep=2592000
if [ $2 != "snap" ] && [ $2 != "snapBM" ]; then
 if [ $type == 'long' ]; then
   ntimesteps=600
   strniter=" niter0=156"
 else
  if [ $longproj == 0 ]; then
   ntimesteps=60
  else
   ntimesteps=660
  fi
  strniter=" niter0=96"
 fi
 strpickup=" pickupsuff='ckptA'"
 cp ../$run_ad_folder/runoptiter030/pickup*ckptA* ./
else
 if [ $2 != "snapBM" ]; then
  if [ $longproj == 0 ]; then
   ntimesteps=60
  else
   ntimesteps=660
  fi
  strniter=" niter0=0"
  strpickup=" pickupsuff=''"
 else
  if [ $longproj == 0 ]; then
   ntimesteps=156
  else
   ntimesteps=756
  fi
  strniter=" niter0=0"
  strpickup=" pickupsuff=''"
 fi
fi

strdt=" deltaT=$timestep,"
strtimestep=" nTimesteps=$ntimesteps,"
strdiagnost=' STREAMICE_diagnostic_only=.false.,'
strbetaconfig=" STREAMICEbasalTracConfig='FILE',"
strtc=" STREAMICE_do_timedep_cost = .true."
strsnap=" STREAMICE_do_snapshot_cost = .false."

gentimperiod=$(($timestep*96/2))

if [ $tdep == "snap" ] || [ $tdep == "snapBM" ]; then


 ln -s ../archer_scripts/get_beta_bglen.py .
 melttd=" bdotMaxmeltTimeDepFile=''"
 sed "s/.*bdotMaxmeltTimeDepFile.*/$melttd/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice
 strBdotMax=" STREAMICEBdotMaxMeltFile=''"
 sed "s/.*STREAMICEBdotMaxMeltFile.*/$strBdotMax/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice
 bglentd=" bglenTimeDepFile='',"
 sed "s/.*bglenTimeDepFile.*/$bglentd/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice 
 betatd=" cfricTimeDepFile='',"
 sed "s/.*cfricTimeDepFile.*/$betatd/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice
 if [ $1 == 'coul' ]; then
                python get_beta_bglen.py Coul 100 $run_ad_folder $run_folder
                strBeta=" STREAMICEbasaltracFile = 'BetaCoul.bin',"
                strBglen=" STREAMICEglenconstfile = 'BglenCoul.bin',"
 else
                python get_beta_bglen.py Weert 100  $run_ad_folder $run_folder
                strBeta=" STREAMICEbasaltracFile = 'BetaWeert.bin',"
                strBglen=" STREAMICEglenconstfile = 'BglenWeert.bin',"
 fi
 sed "s/.*STREAMICEbasaltracFile.*/$strBeta/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice
 sed "s/.*STREAMICEglenconstfile.*/$strBglen/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice

 if [ $tdep == 'snapBM' ]; then
        thickfile='BedMachineThickRema.bin'
        maskfile='hmask_bm.bin'
 else
        thickfile='BedMachineThick.bin'
        maskfile='hmask.bin'
 fi

 strThickFile=" streamicethickFile = '$thickfile',"
 strMaskFile=" streamicehmaskfile = '$maskfile',"
 sed "s/.*streamicethickFile.*/$strThickFile/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice
 sed "s/.*streamicehmaskfile.*/$strMaskFile/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice


else
 strBdotMax=" STREAMICEBdotMaxMeltFile='xx_bdot_max.bin'"
 sed "s/.*STREAMICEBdotMaxMeltFile.*/$strBdotMax/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice

 strBglen=" STREAMICEglenconstfile = 'xx_bglen.bin',"
 sed "s/.*STREAMICEglenconstfile.*/$strBglen/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice

 strBeta=" STREAMICEbasaltracFile = 'xx_beta.bin',"
 sed "s/.*STREAMICEbasaltracFile.*/$strBeta/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice
fi 



sed "s/.*niter0.*/$strniter/" data > data.streamice.temp
mv data.streamice.temp data
sed "s/.*pickupsuff.*/$strpickup/" data > data.streamice.temp
mv data.streamice.temp data

sed "s/.*deltaT.*/$strdt/" data > data.streamice.temp
mv data.streamice.temp data
sed "s/.*nTimesteps.*/$strtimestep/" data > data.streamice.temp
mv data.streamice.temp data
sed "s/.*diagnostic_only.*/$strdiagnost/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*STREAMICEbasalTracConfig.*/$strbetaconfig/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*timedep_cost.*/$strtc/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*snapshot_cost.*/$strsnap/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice

if [ $longproj == 50 ]; then
 strDiagnostics="  frequency(1) = 15552000.,"
 strTimephase="  timephase(1) = 0."
else
 strDiagnostics="  frequency(1) = 2592000.,"
 strTimephase="  timephase(1) = 0."
fi
sed "s/.*frequency(1).*/$strDiagnostics/" data.diagnostics > data.streamice.temp
mv data.streamice.temp data.diagnostics
sed "s/.*timephase(1).*/$strTimephase/" data.diagnostics > data.streamice.temp
mv data.streamice.temp data.diagnostics

StrPeriod="# streamice_forcing_period = $gentimperiod"
sed "s/.*streamice_forcing_period.*/$StrPeriod/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice

cd ../archer_scripts; python remove_constraint.py 0.3 $timestep; cd $OLDPWD

# Link executables

strVelLev=" streamice_vel_cost_timesteps = 108 120 132 144 156"
strThinLev=" streamice_surf_cost_timesteps = 156"
#strVelLev=" streamice_vel_cost_timesteps = 60 72 84 96 108 120 132 144 156"
#strThinLev=" streamice_surf_cost_timesteps = 36 96"
sed "s/.*streamice_vel_cost_timesteps.*/$strVelLev/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*streamice_surf_cost_timesteps.*/$strThinLev/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice

ln -s ../$build_dir/mitgcmuv .

