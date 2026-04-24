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

type=mix
if [ -n "$1" ]; then
   type=$1
fi
echo $type

tikh=".001e5 .003e5 .005e5 .01e5 .02e5 .05e5 .1e5 .15e5 .2e5 .3e5 .6e5 .8e5"
tikh=$(echo "$tikh" | tr ' ' '\n' | tac | xargs)

tokens=($tikh)  # Convert string to array

num_tokens=${#tokens[@]}
# Loop over the tokens in triplets
for ((i = 0; i < $num_tokens; i += 1)); do

    gam=${tokens[i]}
    echo $gam

    if [ $i == 0 ]; then
	    niter=75
    else
	    niter=30
    fi

    sed "s/.*tikhbeta.*/tikhbeta: ${gam}/" exp_${type}_lcurve.txt > exp_${type}_${gam}.txt
    sed -i "s/.*numInvIter.*/numInvIter: ${niter}/" exp_${type}_${gam}.txt

    if [ $i == 0 ]; then
     out1=$(bash submit_ad.sh exp_${type}_${gam}.txt -1 -1 1)
     echo $out1
    else
     out1=$(bash submit_ad.sh exp_${type}_${gam}.txt ${jobid} exp_${type}_${oldgam}.txt 1) 
     echo $out1
    fi
    tok=($out1)
    jobid=${tok[-1]}
    echo $jobid

    oldgam=$gam

done

