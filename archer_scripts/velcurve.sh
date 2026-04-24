#Sliding: coul
#Timedep: tc
#MeltType: g
#GlenType: 0
#BetaType: 0
#Smith: S
#BigConstr: mix
#gentim: gentim
#proj: last
#longproj: 50
#meltconst: n
#tikhbeta: .02e5
#tikhbglen: .2e5
#bdotdepth: 0
#wgtvel: 0.0
#wgtsurf: 1.000
#Restart: false
#precondMelt: 0.1
#precondBeta: 1.0
#precondBglen: 0.1
#numInvIter: 40
#numInvSaveRun: 10
#expFolder: VELCURVE

wgtvel=".0001 .0003 .0005 .001 .002 .003 .004 .005 .006 .007"

tokens=($wgtvel)  # Convert string to array

num_tokens=${#tokens[@]}

# Loop over the tokens in pairs
for ((i = 0; i < num_tokens; i += 2)); do

    wgtvel1=${tokens[i]}
    echo $wgtvel1
    wgtvel2=${tokens[i+1]}
    echo $wgtvel2

    sed "s/.*wgtvel.*/wgtvel: ${wgtvel1}/" exp_mix_velcurve.txt > exp_mix_velcurve_${wgtvel1}.txt
    sed "s/.*wgtvel.*/wgtvel: ${wgtvel2}/" exp_mix_velcurve.txt > exp_mix_velcurve_${wgtvel2}.txt

    out1=$(bash submit_ad.sh exp_mix_velcurve_${wgtvel1}.txt -1 1)
    echo $out1
    tok=($out1)
    jobid=${tok[-1]}
    echo $jobid

    out2=$(bash submit_ad.sh exp_mix_velcurve_${wgtvel2}.txt $jobid 1)
    echo $out2
    tok=($out2)
    jobid2=${tok[-1]}
    echo $jobid2

#    sed "s/.*Smith.*/Smith: SNV/" exp_mix_velcurve_${wgtvel1}.txt > exp_mix_velcurve_${wgtvel1}_NV.txt
#    sed "s/.*expFolder.*/expFolder: VELCURVE_SNV/" exp_mix_velcurve_${wgtvel1}_NV.txt > temp
#    mv temp exp_mix_velcurve_${wgtvel1}_NV.txt

    #bash submit_ad.sh exp_mix_velcurve_${wgtvel1}.txt -1 1

done

