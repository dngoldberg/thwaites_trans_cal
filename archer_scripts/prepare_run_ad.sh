#!/bin/bash
################################################
# Clean out old results and link input files.
################################################

code_dir=code
input_dir=../input/
if [ $2 == 'snap' ]; then
	build_dir=build_snap
        run_folder="run_ad_$1_$2"
	cd $input_dir; 
	cd $OLDPWD
else
        run_folder="run_ad_$1_$2_$3"
	if [ $3 == 'genarr' ]; then
		build_dir=build_genarr
	        cd $input_dir; 
	        cd $OLDPWD
	else 
		build_dir=build_gentim
	        cd $input_dir; 
	        cd $OLDPWD
	fi
fi


# Empty the run directory - but first make sure it exists!
if [ -d "../$run_folder" ]; then
  cd ../$run_folder
  rm -rf *
else
  mkdir ../$run_folder
  cd ../$run_folder
fi


ln -s $input_dir/* .
ln -s ../archer_scripts/opt_script.csh .
ln -s ../archer_scripts/add0upto3c .
ln -s ../archer_scripts/clear_optim.sh .

# Deep copy of the master namelist (so it doesn't get overwritten in input/)
rm -f data
cp -f $input_dir/data .

rm -f data.streamice
cp -f $input_dir/data.streamice ./

if [ $1 == 'weert' ]; then
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

if [ $2 == 'snap' ]; then
	strdt=' deltaT=1728000.0,'
	strtimestep=' nTimesteps=1,'
	strdiagnost=' STREAMICE_diagnostic_only=.true.,'
        strbetaconfig="STREAMICEbasalTracConfig='UNIFORM',"
	strtc=" STREAMICE_do_timedep_cost = .false."
        strsnap=" STREAMICE_do_snapshot_cost = .true."
	rm data.ctrl
	ln -s data.ctrl_snap data.ctrl
else
	strdt=' deltaT=1728000.0,'
	strtimestep=' nTimesteps=144,'
	strdiagnost=' STREAMICE_diagnostic_only=.false.,'
        strbetaconfig=" STREAMICEbasalTracConfig='FILE',"
	strtc=" STREAMICE_do_timedep_cost = .true."
        strsnap=" STREAMICE_do_snapshot_cost = .false."
        if [ $3 == 'genarr' ]; then
 	 rm data.ctrl
	 ln -s data.ctrl_genarr data.ctrl
	else
	 rm data.ctrl
         ln -s data.ctrl_gentim data.ctrl
	fi

        ln -s ../archer_scripts/get_beta_bglen.py .
	if [ $1 == 'coul' ]; then
	
		python get_beta_bglen.py Coul 100
		strBeta=" STREAMICEbasaltracFile = 'BetaCoul.bin',"
		strBglen=" STREAMICEglenconstfile = 'BglenCoul.bin',"
        else
                python get_beta_bglen.py Weert 100
                strBeta=" STREAMICEbasaltracFile = 'BetaWeert.bin',"
                strBglen=" STREAMICEglenconstfile = 'BglenWeert.bin',"
        fi
	sed "s/.*STREAMICEbasaltracFile.*/$strBeta/" data.streamice > data.streamice.temp
        mv data.streamice.temp data.streamice
	sed "s/.*STREAMICEglenconstfile.*/$strBglen/" data.streamice > data.streamice.temp
        mv data.streamice.temp data.streamice

fi

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

if [ $3 == "genarr" ]; then
	numgen=5
	numtim=0
elif [ $2 == "snap" ]; then 
        numgen=2
        numtim=0
elif [ $3 == "gentim" ]; then
        numgen=4
        numtim=2
fi

strgen="      parameter ( maxCtrlArr2D = $numgen )"
strtim="      parameter ( maxCtrlTim2D = $numtim )"

cd ../$code_dir 
sed "s/.*parameter ( maxCtrlArr2D.*/$strgen/" CTRL_SIZE.h > data.streamice.temp
mv data.streamice.temp CTRL_SIZE.h
sed "s/.*parameter ( maxCtrlTim2D.*/$strtim/" CTRL_SIZE.h > data.streamice.temp
mv data.streamice.temp CTRL_SIZE.h
cd $OLDPWD

echo "GOT HERE PREPARE"

cd OPTIM
rm optim.x
rm data.optim
rm data.ctrl
echo $PWD
echo $builddir
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


