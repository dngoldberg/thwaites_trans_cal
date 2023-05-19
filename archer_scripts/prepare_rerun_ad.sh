#!/bin/bash
################################################
# Clean out old results and link input files.
################################################

code_dir=code
input_dir=../input/


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

# Empty the run directory - but first make sure it exists!
if [ -d "../$run_folder" ]; then
  cd ../$run_folder
  rm -rf *
else
  mkdir ../$run_folder
  cd ../$run_folder
fi



ln -s $input_dir/* .
cp ../archer_scripts/opt_script.csh ./
if [ $tdep == 'snap' ] || [ $tdep == 'snapBM' ]; then
stroptiter="itermax=200"
sed "s/.*itermax=40.*/$stroptiter/" opt_script.csh > temp
mv temp opt_script.csh
fi
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

         if [ $melttype == 1 ]; then
	  gentimperiod1=$(($melttype*$timestep*$ntimesteps/2))
         elif [ $melttype == 0 ]; then
	  gentimperiod1=0
	 elif [ $melttype == G ]; then
	  gentimperiod1=$(($timestep*$ntimesteps/2))
	  strglob=" STREAMICE_use_global_ctrl = .true."
	  sed "s/.*STREAMICE_use_global_ctrl.*/$strglob/" data.streamice > data.streamice.temp;
	  mv data.streamice.temp data.streamice
	 elif [ $melttype == g ]; then
	  gentimperiod1=0
	  strglob=" STREAMICE_use_global_ctrl = .true."
	  sed "s/.*STREAMICE_use_global_ctrl.*/$strglob/" data.streamice > data.streamice.temp;
	  mv data.streamice.temp data.streamice
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


	if [ $smithconstr == 'S' ]; then
	 strShelfConstr=" STREAMICEsurfOptimTCBasename = 'surface_constraints/CPOMSmith_surf',"
	 sed "s|.*surfOptimTCBasename.*|${strShelfConstr}|" data.streamice > data.streamice.temp
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

fi

if [[ $tdep == 'snap' ]] || [[ $tdep == 'snapBM' ]] ; then
  wgtsurf=0.
  wgtvel=0.
  tikhbeta="1.e6"
  tikhbglen="1.e6"
elif [[ $bigconstr == 'vel' ]]; then
  wgtsurf=0.01
  wgtvel=0.015
  tikhbeta="5.e5"
  tikhbglen="5.e5"
elif [[ $bigconstr == 'surf' ]]; then
  wgtsurf=1.0
  wgtvel=0.00015
  tikhbeta="5.e5"
  tikhbglen="5.e5"
else
  wgtsurf=1.0
  wgtvel=0.015
  tikhbeta="5.e5"
  tikhbglen="5.e5"
fi



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
strtikhbeta="  streamice_wgt_tikh_beta = ${tikhbeta}"
strtikhbglen=" streamice_wgt_tikh_bglen = ${tikhbglen}"
sed "s/.*streamice_wgt_vel =.*/$strconstrvel/" data.streamice > data.streamice.temp
mv data.streamice.temp data.streamice
sed "s/.*streamice_wgt_surf.*/$strconstrsurf/" data.streamice > data.streamice.temp
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
module swap cray-mpich  cray-mpich/8.1.4
module load cray-hdf5-parallel/1.12.0.3
module load cray-netcdf-hdf5parallel/4.7.4.3


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
rm optim.x
rm data.optim
rm data.ctrl
cd $builddir
cp ../../archer_scripts/Makefile ./
str="                  -I../../$build_dir"
sed "s@.*-I../../build_ad.*@$str@" Makefile > makefile_temp;
mv makefile_temp Makefile
make clean; make depend; make; 
cd $OLDPWD
cp $builddir/optim.x .
ln -s ../data.optim .
ln -s ../data.ctrl .
cd ..
./clear_optim.sh


