#Sliding: coul
#Timedep: tc
#MeltType: g
#GlenType: 0
#BetaType: 0
#Smith: NS
#BigConstr: surf
#gentim: gentim
#proj: last
#longproj: 50
#tikhbeta: .2e5
#tikhbglen: .2e5

tikh=".001e5 .003e5 .005e5 .01e5 .02e5 .05e5 .1e5 .15e5 .2e5 .3e5 .6e5 .8e5"

tokens=($tikh)  # Convert string to array

num_tokens=${#tokens[@]}

# Loop over the tokens in triplets
for ((i = 0; i < num_tokens - 2; i += 3)); do

    gam1=${tokens[i]}
    gam2=${tokens[i+1]}
    gam3=${tokens[i+2]}
    echo $gam1
    echo $gam2
    echo $gam3

    sed "s/.*tikhbeta.*/tikhbeta: ${gam1}/" exp_mix_lcurve.txt > exp_mix_beta_${gam1}.txt
    sed "s/.*tikhbeta.*/tikhbeta: ${gam2}/" exp_mix_lcurve.txt > exp_mix_beta_${gam2}.txt
    sed "s/.*tikhbeta.*/tikhbeta: ${gam3}/" exp_mix_lcurve.txt > exp_mix_beta_${gam3}.txt

    sed "s/.*tikhbeta.*/tikhbeta: ${gam1}/" exp_vel_lcurve.txt > exp_vel_beta_${gam1}.txt
    sed "s/.*tikhbeta.*/tikhbeta: ${gam2}/" exp_vel_lcurve.txt > exp_vel_beta_${gam2}.txt
    sed "s/.*tikhbeta.*/tikhbeta: ${gam3}/" exp_vel_lcurve.txt > exp_vel_beta_${gam3}.txt

    out1=$(bash submit_ad.sh exp_mix_beta_${gam1}.txt -1 1)
    tok=($out1)
    jobid=${tok[-1]}
    echo $jobid

    out1=$(bash submit_ad.sh exp_mix_beta_${gam2}.txt $jobid 1)
    tok=($out1)
    jobid2=${tok[-1]}
    echo $jobid2

    out1=$(bash submit_ad.sh exp_mix_beta_${gam3}.txt $jobid2 1)
    tok=($out1)
    jobid3=${tok[-1]}
    echo $jobid3

    out1=$(bash submit_ad.sh exp_vel_beta_${gam1}.txt $jobid3 1)
    tok=($out1)
    jobid4=${tok[-1]}
    echo $jobid4

    out1=$(bash submit_ad.sh exp_vel_beta_${gam2}.txt $jobid4 1)
    tok=($out1)
    jobid5=${tok[-1]}
    echo $jobid5

    out1=$(bash submit_ad.sh exp_vel_beta_${gam3}.txt $jobid5 1)
    tok=($out1)
    jobid6=${tok[-1]}
    echo $jobid6


done

