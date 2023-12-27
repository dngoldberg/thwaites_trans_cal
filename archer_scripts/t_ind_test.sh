#Sliding: coul
#Timedep: tc
#MeltType: g
#GlenType: 0
#BetaType: 0
#Smith: NS
#BigConstr: surf
#gentim: gentim
#proj: last
#longproj: -1

#sed "s/.*Timedep.*/Timedep: snap/" ../params/exp2.txt > exp_snap.txt;
#bash submit_ad.sh exp_snap.txt
#sed "s/.*Timedep.*/Timedep: snapBM/" ../params/exp2.txt > exp_snapBM.txt;
#bash submit_ad.sh exp_snapBM.txt

sed "s/.*BigConstr.*/BigConstr: surf/" ../params/exp1.txt > exp_surf_constr.txt
bash submit_ad.sh exp_surf_constr.txt

sed "s/.*BigConstr.*/BigConstr: vel/" ../params/exp1.txt > exp_vel_constr.txt;
bash submit_ad.sh exp_vel_constr.txt

sed "s/.*BigConstr.*/BigConstr: mix/" ../params/exp1.txt > exp_mix_constr.txt;
bash submit_ad.sh exp_mix_constr.txt

sed "s/.*Smith.*/Smith: NSC/" exp_mix_constr.txt > exp_mix_constr_bigmelt.txt
bash submit_ad.sh exp_mix_constr_bigmelt.txt


#sed "s/.*MeltType.*/MeltType: G/" exp_mix_constr.txt > exp_mix_constr_meltvar.txt
#bash submit_ad.sh exp_mix_constr_meltvar.txt

#sed "s/.*BetaType.*/BetaType: 1/" exp_mix_constr.txt > exp_mix_constr_betavar.txt
#bash submit_ad.sh exp_mix_constr_betavar.txt

#sed "s/.*GlenType.*/GlenType: 1/" exp_mix_constr.txt > exp_mix_constr_glenvar.txt
#bash submit_ad.sh exp_mix_constr_glenvar.txt


#sed "s/.*gentim.*/gentim: gentimlong/" exp_mix_constr.txt > exp_mix_constr_long.txt
#bash submit_ad.sh exp_mix_constr_long.txt
