import numpy as np
import sys
from scipy.io import loadmat
from IPython import embed
import os
from glob import glob
import matplotlib.pyplot as plt
import shutil
from pathlib import Path
import matplotlib.cm as cm
import matplotlib.colors as colors


Lcurvefolder='/exports/geos.ed.ac.uk/iceocean/dgoldber/archer_output/THWAITES_NEW/VELCURVE/run_val*'
Mainfolder='/exports/geos.ed.ac.uk/iceocean/dgoldber/archer_output/THWAITES_NEW/MAINRUNS/run_val_coul_tc_vel*'
Mainfolder2='/exports/geos.ed.ac.uk/iceocean/dgoldber/archer_output/THWAITES_NEW/MAINRUNS/run_val_coul_tc_mix*'
Mainfolder3='/exports/geos.ed.ac.uk/iceocean/dgoldber/archer_output/THWAITES_NEW/MAINRUNS/run_val_coul_tc_surf*'
foldlist = glob(Lcurvefolder) + glob(Mainfolder3) + glob(Mainfolder)
#foldlist = glob(Lcurvefolder) + glob(Mainfolder2) + glob(Mainfolder3) + glob(Mainfolder)

#    save metrics.mat metric_vel1_st metric_acc1_st metric_surf1_st metric_dhdt1_st dvafdt_err1_st ...
#                     metric_vel2_st metric_acc2_st metric_surf2_st metric_dhdt2_st dvafdt_err2_st ...
#                     tikhbeta wgtvel betacost bglencost priorcost thincost velcost
scalarnames=['betacost','bglencost','priorcost','wgtvel','tikhbeta','velcost','thincost', \
             'metric_vel1_st', 'metric_acc1_st', 'metric_accrel1_st', 'metric_surf1_st', 'metric_dhdt1_st', 'dvafdt_err1_st', \
             'metric_vel2_st', 'metric_acc2_st', 'metric_accrel2_st', 'metric_surf2_st', 'metric_dhdt2_st', 'dvafdt_err2_st' ]

vectornames=['T_st','Vaf_st','Tobs1','Tobs2','Tobs0','vafobs']

nameslist = [scalarnames, vectornames]
matfiles = ['/metrics.mat','/series.mat']

for i in [0,1]:

 names = nameslist[i]
 matfile = matfiles[i]

 for name in names:
    exec(f"{name}=[]")
 if i==0:
     wgtsurf=[];

 for fold in foldlist:

    path = Path(fold)

    if (path.is_dir()):

        mat = loadmat(str(path) + matfile)
        
        for name in names:
            exec(f"{name}.append(mat['{name}'].flatten())")
        if i==0:
            if 'wgtsurf' in mat.keys():
                wgtsurf.append(mat['wgtsurf'].flatten())
            else:
                if mat['thincost']==0:
                    wgtsurf.append(np.array([0.0]))
                else:
                    wgtsurf.append(np.array([1.0]))   


 for name in names:
    exec(f"{name}=np.array({name})")

for name in scalarnames:
    exec(f"{name}={name}.flatten()")

wgtsurf = np.array(wgtsurf).flatten()

I = np.argsort(wgtvel)

for name in scalarnames:
    exec(f"{name}={name}[I]")
for name in vectornames:
    exec(f"{name}={name}[I]")
wgtsurf = wgtsurf[I]

#plt.scatter(wgtvel,velcost/wgtvel/np.min(velcost/wgtvel),label='velcost'); 
#plt.scatter(wgtvel,thincost/60,label='thincost'); 
#plt.plot(wgtvel,thincost/np.max(thincost),'r',label='thincost'); 


T = T_st[0,:]

times=.5*(T[:-1]+T[1:])

fig, ax1 = plt.subplots(figsize=(6, 8))

ax1.grid(which='both')
ax1.minorticks_on()
ax1.tick_params(which='minor')

vobs = vafobs[0,:]

dvdtobs1 = (vobs[1]-vobs[0])/5/1e9*.917
dvdtobs2 = (vobs[2]-vobs[1])/5/1e9*.917
Tobs1 = Tobs1[0,:]
Tobs2 = Tobs2[0,:]


ax1.set(ylabel='DvDt (Gt/a)')

vmin=-.1
norm = colors.Normalize(vmin=0, vmax=1)

cmap = cm.berlin
sm = cm.ScalarMappable(norm=norm, cmap=cmap)

for i in range(len(foldlist)):
    if wgtsurf[i]>0:
        V = Vaf_st[i,:]
        dvdt = np.diff(V)/1e9*4*.917
        ax1.plot(2004+times, dvdt,linewidth=2,color=cmap(wgtvel[i]/.00675))

ax1.plot(2004+Tobs1,dvdtobs1*np.ones(np.shape(Tobs1)),'k',linewidth=4)
ax1.plot(2004+Tobs2,dvdtobs2*np.ones(np.shape(Tobs2)),'k',linewidth=4)

cbar = plt.colorbar(sm, ax=ax1)
cbar.set_label("fraction")
plt.savefig('velcurve.png')


plt.figure()
I = wgtvel!=0
J = wgtsurf!=0

plt.scatter(wgtvel[I],velcost[I]/wgtvel[I]/np.min(velcost[I]/wgtvel[I]),label='velcost');
#plt.scatter(wgtvel,thincost/np.min(thincost),label='thincost');
plt.scatter(wgtvel[J],thincost[J]/np.min(thincost[J]),color='r',label='thincost');
plt.legend()

plt.show()

#plt.ylim([0,np.max(velcost/wgtvel/np.min(velcost/wgtvel))*1.1])
exit()

########################################

plt.figure()

Lcurvefolder='/exports/geos.ed.ac.uk/iceocean/dgoldber/archer_output/THWAITES/VELCURVE_LOWERSURF/'
foldlist = glob(Lcurvefolder + 'run_val*')

scalarnames=['betacost','bglencost','priorcost','wgtsurf','tikhbeta','velcost','thincost', \
             'metric_vel1_st', 'metric_acc1_st', 'metric_accrel1_st', 'metric_surf1_st', 'metric_dhdt1_st', 'dvafdt_err1_st', \
             'metric_vel2_st', 'metric_acc2_st', 'metric_accrel2_st', 'metric_surf2_st', 'metric_dhdt2_st', 'dvafdt_err2_st' ]

for name in scalarnames:
    exec(f"{name}=[]")

for fold in foldlist:

    path = Path(fold)

    if (path.is_dir()):

        mat = loadmat(str(path) + '/metrics.mat')

        for name in scalarnames:
            exec(f"{name}.append(mat['{name}'][0][0])")

for name in scalarnames:
    exec(f"{name}=np.array({name})")

I = np.argsort(wgtsurf)

for name in scalarnames:
    exec(f"{name}={name}[I]")

print(tikhbeta)
plt.plot(wgtsurf,thincost/wgtsurf/np.max(thincost/wgtsurf),'r',label='thincost');
plt.plot(wgtsurf,velcost/np.max(velcost),'b',label='velcost');
plt.legend()    

plt.show()
    





