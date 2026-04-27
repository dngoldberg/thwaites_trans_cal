valFolder=$1

if [ $# -eq 2 ]; then
 expFolder=$2
fi


echo $valFolder
echo $expFolder


ssh -i ~/.ssh/geos_rsa shin "cd '$valFolder'; ln -s /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/batch_scripts/process_dir.m .; /usr/bin/matlab22a -nodesktop -nosplash -nojvm < process_dir.m;"
ssh -i ~/.ssh/geos_rsa shin "cd '$valFolder'; ln -s /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/batch_scripts/create_images.py .; source ~/.bashrc; python create_images.py $expFolder"




#ssh -i ~/.ssh/geos_rsa shin "cd /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/batch_scripts; cp -f plot_val.m '$valFolder'; cp -f save_arrays.m '$valFolder'; cp -f process_dir.m '$valFolder'/process_dir.m;"

#cd '$valFolder'; /usr/bin/matlab22a -nodesktop -nosplash -nojvm < process_dir.m;"
