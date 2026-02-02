#!/bin/bash
################################################
# Clean out old results and link input files.
################################################


code_dir=code
input_dir=../input_tc/

if [ -n	"$2" ]; then
 source ./parse_params.sh $2
 output_param_file="params_file.txt_$(date +"%F%T.%6N")"
 source ./write_params.sh 
 source ./get_run_folders.sh
 run_folder_prev=${run_ad_folder}
fi


source ./parse_params.sh $1

output_param_file="params_file.txt_$(date +"%F%T.%6N")"
source ./write_params.sh
source ./get_run_folders.sh

# Print the next available folder name
run_folder=${run_ad_folder}

echo $run_folder
echo "prev run folder: ${run_folder_prev}" 
if [ $reStart == 'true' ]; then
	exit
fi

# Empty the run directory - but first make sure it exists!
if [ -d "../$run_folder" ]; then
  mv $output_param_file ../$run_folder
  cd ../$run_folder
  rm -rf *
else
  mkdir ../$run_folder
  mv $output_param_file ../$run_folder
  cd ../$run_folder
fi

output_param_file="params_file.txt"
ln -s ../archer_scripts/write_params.sh .
source ./write_params.sh


cp $input_dir/*bin ./
cp -r $input_dir/*constraints ./
ln -s $input_dir/* .
cp ../archer_scripts/opt_script.csh ./
if [ $tdep == 'snap' ] || [ $tdep == 'snapBM' ]; then
stroptiter="itermax=200"
else
stroptiter="itermax=$numInvIter"
fi

sed "s/.*itermax=.*/$stroptiter/" opt_script.csh > temp
mv temp opt_script.csh

stroptiter="if [ \$((i % $numInvSaveRun)) -eq 0 ]; then"
sed "s/.*if [ $((i % 1)) -eq 0 ].*/$stroptiter/" opt_script.csh > temp
mv temp opt_script.csh


ln -s ../archer_scripts/add0upto3c .
ln -s ../archer_scripts/clear_optim.sh .

# Deep copy of the master namelist (so it doesn't get overwritten in input/)
rm -f data
cp -f $input_dir/data .

rm -f data.streamice
cp -f $input_dir/data.streamice ./

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

if [ $meltconst != 'n' ]; then
 str=$(grep streamice_bdot_maxmelt data.streamice); 
 val="${str##*=}"; 
 meltnum=$(( $val + $meltconst ))
 strmelt=" streamice_bdot_maxmelt = $meltnum"
 sed "s/.*streamice_bdot_maxmelt.*/$strmelt/" data.streamice > data.streamice.temp
 mv data.streamice.temp data.streamice
fi

sed "s/.*reg_coulomb.*/$strcoul/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*smooth_gl_width.*/$strsmooth/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice

timestep=2592000
if [ $gentim == 'gentimlong' ]; then
 ntimesteps=156
else
 ntimesteps=96
fi


if [ $tdep == 'snap' ] || [ $tdep == 'snapBM' ]; then
	strdt=" deltaT=$timestep,"
	strtimestep=' nTimesteps=1,'
	strdiagnost=' STREAMICE_diagnostic_only=.true.,'
        strbetaconfig="STREAMICEbasalTracConfig='UNIFORM',"
	strtc=" STREAMICE_do_timedep_cost = .false."
        strsnap=" STREAMICE_do_snapshot_cost = .true."
        strconstrvel=" streamice_wgt_vel_norm = 200.0"
        sed "s/.*streamice_wgt_vel_norm.*/$strconstrvel/" data.streamice > data.streamice.temp
        mv data.streamice.temp data.streamice
	rm data.ctrl
	ln -s data.ctrl_snap data.ctrl
else
	strdt=" deltaT=$timestep,"
	strtimestep=" nTimesteps=$ntimesteps,"
	strdiagnost=' STREAMICE_diagnostic_only=.false.,'
        strbetaconfig=" STREAMICEbasalTracConfig='FILE',"
	strtc=" STREAMICE_do_timedep_cost = .true."
        strsnap=" STREAMICE_do_snapshot_cost = .false."
        if [ $gentim == 'genarr' ]; then
 	 rm data.ctrl
	 ln -s data.ctrl_genarr data.ctrl
	else
	 rm data.ctrl
         cp -r $input_dir/data.ctrl_gentim data.ctrl
	 strprecond="  gentim2dPrecond = ${precondMelt} ${precondBglen} ${precondBeta}"
         sed "s/.*gentim2dPrecond.*/$strprecond/" data.ctrl > data.ctrl_temp;
	 mv data.ctrl_temp data.ctrl
         if [ $melttype == 1 ]; then
	  gentimperiod1=$(($melttype*$timestep*$ntimesteps/2))
         elif [ $melttype == 0 ]; then
	  gentimperiod1=0
	 elif [ $melttype == G ]; then
	  gentimperiod1=$(($timestep*$ntimesteps/2))
	  strglob=" STREAMICE_use_global_ctrl = .true."
	  sed "s/.*STREAMICE_use_global_ctrl.*/$strglob/" data.streamice > data.streamice.temp;
	  mv data.streamice.temp data.streamice
          strglob="  xx_gentim2d_glosum(1) = .true."
	  sed "s/.*xx_gentim2d_glosum.*/$strglob/" data.ctrl > data.ctrl.temp;
	  mv data.ctrl.temp data.ctrl
	 elif [ $melttype == g ]; then
	  gentimperiod1=0
	  strglob=" STREAMICE_use_global_ctrl = .true."
	  sed "s/.*STREAMICE_use_global_ctrl.*/$strglob/" data.streamice > data.streamice.temp;
	  mv data.streamice.temp data.streamice
	  strglob="  xx_gentim2d_glosum(1) = .true."
	  sed "s/.*xx_gentim2d_glosum.*/$strglob/" data.ctrl > data.ctrl.temp;
	  mv data.ctrl.temp data.ctrl
	 fi
         gentimperiod2=$(($glentype*$timestep*$ntimesteps/2))
         gentimperiod3=$(($betatype*$timestep*$ntimesteps/2))

         StrPeriod="  xx_gentim2d_period(1) = $gentimperiod1"
         sed "s/.*xx_gentim2d_period(1).*/$StrPeriod/" data.ctrl > data.ctrl.temp; 
	 mv data.ctrl.temp data.ctrl;
         StrPeriod="  xx_gentim2d_period(2) = $gentimperiod2"
         sed "s/.*xx_gentim2d_period(2).*/$StrPeriod/" data.ctrl > data.ctrl.temp; 
	 mv data.ctrl.temp data.ctrl;
         StrPeriod="  xx_gentim2d_period(3) = $gentimperiod3"
         sed "s/.*xx_gentim2d_period(3).*/$StrPeriod/" data.ctrl > data.ctrl.temp; 
	 mv data.ctrl.temp data.ctrl;

	fi


	if [ $smithconstr == 'S' ] || [ $smithconstr == 'SC' ] || [ $smithconstr == 'SNV' ]; then
	 strShelfConstr=" STREAMICEsurfOptimTCBasename = 'surface_constraints/CPOMSmith_surf',"
	 sed "s|.*surfOptimTCBasename.*|${strShelfConstr}|" data.streamice > data.streamice.temp
	 mv data.streamice.temp data.streamice
	 strShelfConstr=" STREAMICEdhdtOptimTCBasename = 'dhdt_constraints/CPOMSmith_dhdt',"
	 sed "s|.*dhdtOptimTCBasename.*|${strShelfConstr}|" data.streamice > data.streamice.temp
	 mv data.streamice.temp data.streamice
	 strShelfConstr=" STREAMICE_shelf_dhdt_ctrl = .true.,"
	 sed "s|.*STREAMICE_shelf_dhdt_ctrl.*|${strShelfConstr}|" data.streamice > data.streamice.temp
         mv data.streamice.temp data.streamice
	fi

	if [ $smithconstr == 'SNV' ]; then
	 strShelfConstr=" STREAMICE_shelf_vel_ctrl = .false.,"
	 sed "s|.*STREAMICE_shelf_vel_ctrl.*|${strShelfConstr}|" data.streamice > data.streamice.temp
         mv data.streamice.temp data.streamice
	fi

	if [ $smithconstr == 'SC' ] || [ $smithconstr == 'NSC' ]; then
	 strDeepMelt=" streamice_bdot_maxmelt = 200"
	 sed "s/.*streamice_bdot_maxmelt.*/$strDeepMelt/" data.streamice > data.streamice.temp
	 mv data.streamice.temp data.streamice
        fi	 



        ln -s ../archer_scripts/get_beta_bglen.py .
	if [ $sliding == 'coul' ]; then
	
		python get_beta_bglen.py Coul 200 $ad_folder $run_folder 
		strBeta=" STREAMICEbasaltracFile = 'BetaCoul.bin',"
		strBglen=" STREAMICEglenconstfile = 'BglenCoul.bin',"
        else
                python get_beta_bglen.py Weert 200 $ad_folder $run_folder
                strBeta=" STREAMICEbasaltracFile = 'BetaWeert.bin',"
                strBglen=" STREAMICEglenconstfile = 'BglenWeert.bin',"
        fi
	sed "s/.*STREAMICEbasaltracFile.*/$strBeta/" data.streamice > data.streamice.temp
        mv data.streamice.temp data.streamice
	sed "s/.*STREAMICEglenconstfile.*/$strBglen/" data.streamice > data.streamice.temp
        mv data.streamice.temp data.streamice

	if [ -n "${run_folder_prev}" ]; then
        	ln -s ../archer_scripts/prepare_adjoint_controls.py
        	python prepare_adjoint_controls.py $run_folder_prev $run_folder

		strBeta=" STREAMICEbasaltracFile = 'xx_beta.bin',"
                strBglen=" STREAMICEglenconstfile = 'xx_bglen.bin',"
		strBdotMax=" STREAMICEBdotMaxMeltFile='xx_bdot_max.bin'"

	       	sed "s/.*STREAMICEBdotMaxMeltFile.*/$strBdotMax/" data.streamice > data.streamice.temp
                mv data.streamice.temp data.streamice
		sed "s/.*STREAMICEbasaltracFile.*/$strBeta/" data.streamice > data.streamice.temp
        	mv data.streamice.temp data.streamice
		sed "s/.*STREAMICEglenconstfile.*/$strBglen/" data.streamice > data.streamice.temp
        	mv data.streamice.temp data.streamice
	else
		echo "GOT HERE NO 2"
	fi	
fi

: <<'EOF'
if [[ $bigconstr == 'mix' ]]; then
  wgtsurf=1.
fi
if [[ $tdep == 'snap' ]] || [[ $tdep == 'snapBM' ]] ; then
  wgtsurf=0.
  wgtvel=1.
elif [[ $bigconstr == 'vel' ]]; then
  wgtsurf=0.00
  wgtvel=0.0035
elif [[ $bigconstr == 'surf' ]]; then
  wgtsurf=1.0
elif [[ $bigconstr == 'dhdt' ]]; then
  wgtsurf=0.0
elif [[ $imposewgtvel == 0 ]]; then
  wgtsurf=1.0
  wgtvel=0.0035
fi
EOF


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




strconstrvel=" streamice_wgt_vel = $wgtvel"
strconstrsurf=" streamice_wgt_surf = $wgtsurf"
strconstrdhdt=" streamice_wgt_dhdt = $wgtdhdt"
strtikhbeta="  streamice_wgt_tikh_beta = ${tikhbeta}"
strtikhbglen=" streamice_wgt_tikh_bglen = ${tikhbglen}"
sed "s/.*streamice_wgt_vel =.*/$strconstrvel/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*streamice_wgt_surf.*/$strconstrsurf/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*streamice_wgt_dhdt.*/$strconstrdhdt/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*streamice_wgt_tikh_bglen.*/$strtikhbglen/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*streamice_wgt_tikh_beta.*/$strtikhbeta/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice


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

cd ../archer_scripts; python remove_constraint.py 0.3 $timestep; cd $OLDPWD

# Link executables


ln -s ../$build_dir/mitgcmuv_ad .


module load PrgEnv-gnu


optimdir=OPTIM
builddir="../../optim_m1qn3/src"

if [ ! -d "$optimdir" ]; then
 mkdir -p $optimdir
fi

if [ $gentim == "genarr" ]; then
	numgen=3
	numtim=0
elif [ $tdep == "snap" ]; then 
        numgen=2
        numtim=0
elif [ $gentim == "gentim" ]; then
        numgen=0
        numtim=3
elif [ $gentim == "gentimlong" ]; then
        numgen=0
        numtim=3
fi

strgen="      parameter ( maxCtrlArr2D = $numgen )"
strtim="      parameter ( maxCtrlTim2D = $numtim )"


cd ../$code_dir 
sed "s/.*parameter ( maxCtrlArr2D.*/$strgen/" CTRL_SIZE.h > data.streamice.temp
mv data.streamice.temp CTRL_SIZE.h
sed "s/.*parameter ( maxCtrlTim2D.*/$strtim/" CTRL_SIZE.h > data.streamice.temp
mv data.streamice.temp CTRL_SIZE.h
cd $OLDPWD



cd OPTIM
rm data.optim
rm data.ctrl
cd $builddir
cp ../../archer_scripts/Makefile ./
str="                  -I../../$build_dir"
sed "s@.*-I../../build_ad.*@$str@" Makefile > makefile_temp;
mv makefile_temp Makefile
if [ -f "/home/n02/n02/dngoldbe/MITgcm/tools/xmakedepend" ]; then
 rm optim.x
 make clean; make depend; make; 
fi 
cd $OLDPWD
cp $builddir/optim.x .
ln -s ../data.optim .
ln -s ../data.ctrl .
cd ..
./clear_optim.sh



