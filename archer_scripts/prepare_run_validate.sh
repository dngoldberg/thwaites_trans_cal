#!/bin/bash
################################################
# Clean out old results and link input files.
################################################

input_dir=../input_tc/


#Sliding: coul
#Timedep: tc
#MeltType: g
#GlenType: 0
#BetaType: 0
#Smith: NS
#BigConstr: surf
#gentim: gentim
#meltconst: n

#1 sliding lar
#2 melt mode
#3 bglen mode
#4 beta mode
#6 gentim
#7 smith constraint
#5 project_mode


#8 

#8
source ./parse_params.sh $1

strInvIter=`./add0upto3c $numInvIter`

output_param_file="params_file.txt_$(date +"%F%T.%6N")"
source ./write_params.sh
source ./get_run_folders.sh

build_dir=build_validate
echo $run_folder
#echo $run_ad_folder

# Empty the run directory - but first make sure it exists!
if [ -d "../$run_folder" ]; then
  cd ../$run_folder
  rm -rf *
else
  mkdir ../$run_folder
  cd ../$run_folder
fi

rm $output_param_file
output_param_file="params_file.txt"
slid=sys.argv[1]
ln -s ../archer_scripts/write_params.sh .
source ./write_params.sh


ln -s $input_dir/* .

if [ $tdep == "tc" ]; then
 cd ../archer_scripts;
 python prepare_validation_controls_const.py $numInvIter $run_ad_folder $run_folder $proj $melttype $glentype $betatype $meltconst
 cd $OLDPWD
fi

# Deep copy of the master namelist (so it doesn't get overwritten in input/)
rm -f data
cp -f $input_dir/data .

rm -f data.streamice
cp -f $input_dir/data.streamice ./

rm -f data.diagnostics
cp -f $input_dir/data.diagnostics ./

#if [ $tdep == "snap" ]; then
# if [ meltconst != "n" ]; then
#  meltnum=$(( 50 + $meltconst ))
#  strmelt=" streamice_bdot_maxmelt = $meltnum"
#  sed "s/.*streamice_bdot_maxmelt .*/$strmelt/" data.streamice > data.streamice.temp
#  mv data.streamice.temp data.streamice
# fi
#fi


if [ $meltconst != "n" ]; then
 str=$(grep streamice_bdot_maxmelt data.streamice); 
 val="${str##*=}"; 
 meltnum=$(( $val + $meltconst ))
 strmelt=" streamice_bdot_maxmelt = $meltnum"
 sed "s/.*streamice_bdot_maxmelt.*/$strmelt/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice
fi

if [ $sliding == 'weert' ]; then
 strcoul=" streamice_allow_reg_coulomb=.false."
 strsmooth=" streamice_smooth_gl_width = 10."
else
 strcoul=" streamice_allow_reg_coulomb=.true."
 strsmooth=" streamice_smooth_gl_width = 0."
fi

strdepth=" streamice_bdot_depth_nomelt = $bdotdepth"
sed "s/.*streamice_bdot_depth_nomelt.*/$strdepth/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*reg_coulomb.*/$strcoul/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*smooth_gl_width.*/$strsmooth/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice

type='short'
if [ $gentim == 'gentimlong' ]; then
  type='long'
fi

timestep=2592000
if [ $tdep != "snap" ] && [ $tdep != "snapBM" ]; then
 if [ $type == 'long' ]; then
  if [ $longproj == -1 ]; then
   ntimesteps=156
   strniter=" niter0=0"
  else
   ntimesteps=600
   strniter=" niter0=156"
  fi
 else
  strniter=" niter0=96"
  if [ $longproj == 0 ]; then
   ntimesteps=60
  elif [ $longproj == 50 ]; then
   ntimesteps=660
  elif [ $longproj == -1 ]; then
   ntimesteps=96
   strniter=" niter0=0"
  else
   ntimesteps=$(( 12 * $longproj + 5 * 12 ))
  fi
 fi
 if [ $longproj == -1 ]; then
  strpickup="# pickupsuff='ckptA'"
 else
  strpickup=" pickupsuff='ckptA'"
 fi
 cp ../$run_ad_folder/runoptiter${strInvIter}/pickup*ckptA* ./
else
 if [ $tdep == "snapBM" ]; then
  if [ $longproj == 0 ]; then
   ntimesteps=60
  else
   ntimesteps=$(( 12 * $longproj + 5 * 12 ))
  fi
  strniter=" niter0=0"
  strpickup=" pickupsuff=''"
 else
  if [ $longproj == 0 ]; then
   ntimesteps=156
  else
   ntimesteps=$(( 12 * $longproj + 13 * 12 ));
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
                python get_beta_bglen.py Coul $numInvIter $run_ad_folder $run_folder
                strBeta=" STREAMICEbasaltracFile = 'BetaCoul.bin',"
                strBglen=" STREAMICEglenconstfile = 'BglenCoul.bin',"
 else
                python get_beta_bglen.py Weert $numInvIter $run_ad_folder $run_folder
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

	if [ $smithconstr == 'S' ] || [ $smithconstr == 'SC' ]; then
	 strShelfConstr=" STREAMICEsurfOptimTCBasename = 'surface_constraints/CPOMSmith_surf',"
	 sed "s|.*surfOptimTCBasename.*|${strShelfConstr}|" data.streamice > data.streamice.temp
	 mv data.streamice.temp data.streamice
	 strShelfConstr=" STREAMICE_shelf_dhdt_ctrl = .true.,"
	 sed "s|.*STREAMICE_shelf_dhdt_ctrl.*|${strShelfConstr}|" data.streamice > data.streamice.temp
         mv data.streamice.temp data.streamice
	fi

	if [ $smithconstr == 'SC' ] || [ $smithconstr == 'NSC' ]; then
	 strDeepMelt=" streamice_bdot_maxmelt = 200"
	 sed "s/.*streamice_bdot_maxmelt.*/$strDeepMelt/" data.streamice > data.streamice.temp
	 mv data.streamice.temp data.streamice
        fi	 
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

if [ $longproj == 0 ]; then
 strDiagnostics="  frequency(1) = 2592000.,"
 strTimephase="  timephase(1) = 0."
else
 strDiagnostics="  frequency(1) = 7776000.,"
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
#strVelLev=" streamice_vel_cost_timesteps = 12 24 36 48 60 72 84 96 108 120 132 144 156"
#strThinLev=" streamice_surf_cost_timesteps = 36 96"
if [ $longproj == 50 ] || [ $longproj == 0 ]; then
 sed "s/.*streamice_vel_cost_timesteps.*/$strVelLev/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice
 sed "s/.*streamice_surf_cost_timesteps.*/$strThinLev/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice
fi


strconstrvel=" streamice_wgt_vel = 0.024"
strconstrsurf=" streamice_wgt_surf = 1.0"
if [ $longproj == -1 ] && [ $tdep == 'tc' ]; then
 if [[ $bigconstr == 'vel' ]]; then
  strconstrvel=" streamice_wgt_vel = 0.024"
  strconstrsurf=" streamice_wgt_surf = .01"
 elif [[ $bigconstr == 'surf' ]]; then
  strconstrvel=" streamice_wgt_vel = 0.00024"
  strconstrsurf=" streamice_wgt_surf = 1.0"
 elif [[ $bigconstr == 'mix' ]]; then
  strconstrvel=" streamice_wgt_vel = 0.024"
  strconstrsurf=" streamice_wgt_surf = 1.0"
 fi
fi

sed "s/.*streamice_wgt_vel =.*/$strconstrvel/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*streamice_wgt_surf.*/$strconstrsurf/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice


ln -s ../$build_dir/mitgcmuv .

