#Sliding: coul
#Timedep: tc
#MeltType: g
#GlenType: 0
#BetaType: 0
#Smith: S
#BigConstr: surf
#gentim: gentim
#proj: last
#longproj: 50
#meltconst: n
#tikhbeta: .2e5
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
#expFolder: MAINRUNS


sed "s/.*BigConstr.*/BigConstr: surf/" exp_main.txt > temp
mv temp exp_surf.txt
bash submit_ad.sh exp_surf.txt -1 1
rm exp_surf.txt

sed "s/.*Timedep.*/Timedep: snap/" exp_main.txt > temp
mv temp exp_snap.txt
sed "s/.*numInvIter.*/numInvIter: 200/" exp_snap.txt > temp
mv temp exp_snap.txt
sed "s/.*numInvSaveRun.*/numInvSaveRun: 40/" exp_snap.txt > temp
mv temp exp_snap.txt
bash submit_ad.sh exp_snap.txt -1 1
rm exp_snap.txt

jobid1=-1
jobid2=-1

for wgtvel in 0.0025 0.0035; do

	sed "s/.*BigConstr.*/BigConstr: vel/" exp_main.txt > temp
	sed "s/.*wgtvel.*/wgtvel: $wgtvel/" temp > temp2
	sed "s/.*wgtsurf.*/wgtsurf: 0.0/" temp2 > temp3
	mv temp3 exp_vel.txt
	out1=$(bash submit_ad.sh exp_vel.txt $jobid1 1)
	echo $out1
	rm temp temp2 exp_vel.txt
	tok1=($out1)
	jobid1=${tok1[-1]}

	sed "s/.*BigConstr.*/BigConstr: mix/" exp_main.txt > temp
	sed "s/.*wgtvel.*/wgtvel: $wgtvel/" temp > temp2
	sed "s/.*wgtsurf.*/wgtsurf: 1.0/" temp2 > temp3
	mv temp3 exp_mix.txt
	out2=$(bash submit_ad.sh exp_mix.txt $jobid2 1)
	echo $out2
	tok2=($out2)
	jobid2=${tok2[-1]}
	rm temp temp2 exp_mix.txt

done


