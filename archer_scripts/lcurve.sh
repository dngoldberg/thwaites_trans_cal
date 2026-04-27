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

tikh=".005e5 .01e5 .02e5 .05e5 .1e5 .15e5 .2e5 .3e5 .6e5 .8e5 1.e5 2.e5"
tikh=".001e5 .003e5"

tokens=($tikh)  # Convert string to array

num_tokens=${#tokens[@]}

# Loop over the tokens in triplets
for ((i = 0; i < num_tokens - 1; i += 2)); do

    gam1=${tokens[i]}
    gam2=${tokens[i+1]}
#    gam3=${tokens[i+2]}
    echo $gam1
    echo $gam2
#    echo $gam3

    sed "s/.*tikhbeta.*/tikhbeta: ${gam1}/" exp_surf_lcurve.txt > exp_surf_beta_${gam1}.txt
    sed "s/.*tikhbeta.*/tikhbeta: ${gam2}/" exp_surf_lcurve.txt > exp_surf_beta_${gam2}.txt
#    sed "s/.*tikhbeta.*/tikhbeta: ${gam3}/" exp_surf_lcurve.txt > exp_surf_beta_${gam3}.txt

    out1=$(bash submit_ad.sh exp_surf_beta_${gam1}.txt -1 0)
#    out1=$(bash submit_val.sh exp_surf_beta_${gam1}.txt)
    tok=($out1)
    jobid=${tok[-1]}
    echo $jobid

#    out1=$(bash submit_ad.sh exp_surf_beta_${gam2}.txt $jobid 0)
    out1=$(bash submit_ad.sh exp_surf_beta_${gam2}.txt -1 0)
#    out1=$(bash submit_val.sh exp_surf_beta_${gam2}.txt)
    tok=($out1)
    jobid2=${tok[-1]}
    echo $jobid2

#    out1=$(bash submit_ad.sh exp_surf_beta_${gam3}.txt $jobid2 0)
#    tok=($out1)
#    jobid3=${tok[-1]}
#    echo $jobid3

done

