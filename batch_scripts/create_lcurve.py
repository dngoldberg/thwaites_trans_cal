import numpy as np
import sys
from scipy.io import loadmat
from IPython import embed
import os
from glob import glob
import matplotlib.pyplot as plt
import shutil
from pathlib import Path

if len(sys.argv)>1:
    constrType=sys.argv[1]
else:
    constrType = 'surf'

Lcurvefolder='/exports/geos.ed.ac.uk/iceocean/dgoldber/archer_output/THWAITES/LCURVE_' + constrType.upper() + '/'
foldlist = glob(Lcurvefolder + 'run_ad*')
print(foldlist)

BetaCost=[]
BglenCost=[]
PriorCost=[]
SurfCost=[]
VelCost=[]
TikhBeta=[]

for fold in foldlist:

    path = Path(fold)

    if (path.is_dir()):

        with open(str(path)+ '/params_file.txt', 'r') as file:
            lines = file.readlines()

        cfg_dict = {line.split(':')[0].strip(): line.split(':')[1].strip() for line in lines}
        print(cfg_dict)

        strret = os.popen('grep "fric smooth contr" ' + str(path) + '/outputoptiter' + str(cfg_dict['numInvIter']).zfill(3)).read()
        print (str(path) + '/outputoptiter' + str(cfg_dict['numInvIter']).zfill(3))
        betacost = float(strret.rsplit(' ',maxsplit=1)[-1][:-1].replace('D','E'))
        strret = os.popen('grep "bglen smooth contr" ' + str(path) + '/outputoptiter' + str(cfg_dict['numInvIter']).zfill(3)).read()
        bglencost = float(strret.rsplit(' ',maxsplit=1)[-1][:-1].replace('D','E'))
        strret = os.popen('grep "prior smooth contr" ' + str(path) + '/outputoptiter' + str(cfg_dict['numInvIter']).zfill(3)).read()
        priorcost = float(strret.rsplit(' ',maxsplit=1)[-1][:-1].replace('D','E'))
        strret = os.popen('grep "thinning contr" ' + str(path) + '/outputoptiter' + str(cfg_dict['numInvIter']).zfill(3)).read()
        surfcost = float(strret.rsplit(' ',maxsplit=1)[-1][:-1].replace('D','E'))
        strret = os.popen('grep "vel misfit =" ' + str(path) + '/outputoptiter' + str(cfg_dict['numInvIter']).zfill(3)).read()
        velcost = float(strret.rsplit(' ',maxsplit=1)[-1][:-1].replace('D','E'))

        BetaCost.append(betacost)
        BglenCost.append(bglencost)
        PriorCost.append(priorcost)
        SurfCost.append(surfcost)
        VelCost.append(velcost)
        TikhBeta.append(float(cfg_dict['tikhbeta']))


BetaCost=np.array(BetaCost)
BglenCost=np.array(BglenCost)
PriorCost=np.array(PriorCost)
SurfCost=np.array(SurfCost)
VelCost=np.array(VelCost)
TikhBeta=np.array(TikhBeta)

#I = np.where(TikhBeta>1.e2)
#BetaCost=BetaCost[I]
#BglenCost=BglenCost[I]
#PriorCost=PriorCost[I]
#SurfCost=SurfCost[I]
#VelCost=VelCost[I]
#TikhBeta=TikhBeta[I]

#I = np.where(TikhBeta!=5.e2)
#BetaCost=BetaCost[I]
#BglenCost=BglenCost[I]
#PriorCost=PriorCost[I]
#SurfCost=SurfCost[I]
#VelCost=VelCost[I]
#TikhBeta=TikhBeta[I]

TotCost = VelCost+SurfCost

fig = plt.figure(figsize=(6,8))
ax = plt.gca()
ax.scatter(TotCost, BetaCost/TikhBeta, alpha=0.5)
plt.xlabel('$J_{mis}^{surf}$',fontsize=14,fontweight='bold')
plt.ylabel(r'$J_{\beta}$',fontsize=14,fontweight='bold')
for i in range(len(TikhBeta)):
    ax.text(TotCost[i]+.1,BetaCost[i]/TikhBeta[i]*1.01,"{:.1E}".format(TikhBeta[i]),fontsize=8)

#ax.set_yscale('log')
#plt.colorbar()
#ax.set_xscale('log')
ax.grid(axis='both')

print(TotCost)
print(TikhBeta)

plt.savefig('lcurve_' + constrType.lower() + '.png')

