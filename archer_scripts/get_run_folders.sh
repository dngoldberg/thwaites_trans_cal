hash=$(md5sum < $output_param_file | cut -d' ' -f1 | cut -c1-12)

if [ $tdep == 'snap' ] || [ $tdep == 'snapBM' ]; then

	run_folder_pattern="run_val_${sliding}_${tdep}"
        run_ad_folder_pattern="run_ad_${sliding}_$tdep"
        run_advaf_folder_pattern="run_advaf_${sliding}_$tdep"
        build_dir=build_snap

else

	run_folder_pattern="run_val_${sliding}_${tdep}_${bigconstr}"
        run_ad_folder_pattern="run_ad_${sliding}_${tdep}_${bigconstr}"
	ad_folder="run_ad_${sliding}_snap"
        run_advaf_folder_pattern="run_advaf_${sliding}_${tdep}_${bigconstr}"

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

run_ad_folder="${run_ad_folder_pattern}_${hash}"
run_advaf_folder="${run_advaf_folder_pattern}_${hash}"
run_folder="${run_folder_pattern}_${hash}"
