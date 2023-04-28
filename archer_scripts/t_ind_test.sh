#Sliding: coul
#Timedep: tc
#MeltType: g
#GlenType: 0
#BetaType: 0
#Smith: NS
#BigConstr: surf
#gentim: gentim

sed "s/.*BigConstr.*/BigConstr: surf/" ../params/exp1.txt > exp_surf_constr.txt;
bash submit_ad.sh exp_surf_constr.txt

sed "s/.*BigConstr.*/BigConstr: vel/" ../params/exp1.txt > exp_vel_constr.txt;
bash submit_ad.sh exp_vel_constr.txt

sed "s/.*BigConstr.*/BigConstr: mix/" ../params/exp1.txt > exp_mix_constr.txt;
bash submit_ad.sh exp_mix_constr.txt

