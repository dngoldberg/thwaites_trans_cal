import numpy as np
import sys
from scipy.io import loadmat
from IPython import embed
import os
import matplotlib.pyplot as plt
import shutil

webfolder='/home/dgoldber/www/public_html/ThwaitesTC/'
if len(sys.argv)>1:
    expfolder=sys.argv[1]
    webfolder=webfolder + expfolder + '/'

print(webfolder)

currdir=os.path.split(os.getcwd())[1]
if not os.path.exists(webfolder):
    os.mkdir(webfolder)
if not os.path.exists(webfolder + 'dvaf'):
    os.mkdir(webfolder + 'dvaf')
if not os.path.exists(webfolder + 'dvdt'):
    os.mkdir(webfolder + 'dvdt')
if not os.path.exists(webfolder + 'inlandthin'):
    os.mkdir(webfolder + 'inlandthin')
if not os.path.exists(webfolder + 'conv'):
    os.mkdir(webfolder + 'conv')

with open('params_file.txt', 'r') as file:
    lines = file.readlines()

cfg_dict = {line.split(':')[0].strip(): line.split(':')[1].strip() for line in lines}

text = ''.join(lines)

tempdir=os.getcwd().rsplit('/',maxsplit=1)
adfolder=tempdir[0] + '/' + 'run_ad_' + tempdir[-1].split('_',maxsplit=2)[-1];

if cfg_dict['Timedep'] != 'snap':

    strret = os.popen('grep "fric smooth contr" ' + adfolder + '/outputoptiter' + str(cfg_dict['numInvIter']).zfill(3)).read()
    betacost = float(strret.rsplit(' ',maxsplit=1)[-1][:-1].replace('D','E'))
    strret = os.popen('grep "bglen smooth contr" ' + adfolder + '/outputoptiter' + str(cfg_dict['numInvIter']).zfill(3)).read()
    bglencost = float(strret.rsplit(' ',maxsplit=1)[-1][:-1].replace('D','E'))
    strret = os.popen('grep "prior smooth contr" ' + adfolder + '/outputoptiter' + str(cfg_dict['numInvIter']).zfill(3)).read()
    priorcost = float(strret.rsplit(' ',maxsplit=1)[-1][:-1].replace('D','E'))
    strret = os.popen('grep "thinning contr" ' + adfolder + '/outputoptiter' + str(cfg_dict['numInvIter']).zfill(3)).read()
    surfcost = float(strret.rsplit(' ',maxsplit=1)[-1][:-1].replace('D','E'))
    strret = os.popen('grep "vel misfit =" ' + adfolder + '/outputoptiter' + str(cfg_dict['numInvIter']).zfill(3)).read()
    velcost = float(strret.rsplit(' ',maxsplit=1)[-1][:-1].replace('D','E'))

    TotCost = np.zeros(int(cfg_dict['numInvIter'])+1)

    for niter in range(int(cfg_dict['numInvIter'])+1):
        strret = os.popen('grep "global fc" ' + adfolder + '/outputoptiter' + str(niter).zfill(3)).read()
        TotCost[niter] = float(strret.rsplit(' ',maxsplit=1)[-1][:-1].replace('D','E'))
    

else:

    betacost = ''
    bglencost = ''
    priorcost = ''
    surfcost = ''
    velcost = ''


Q = loadmat('series.mat')

Tobs0=Q['Tobs0'].flatten()
Tobs1=Q['Tobs1'].flatten()
Tobs2=Q['Tobs2'].flatten()
T=Q['T_st'].flatten()
V=Q['Vaf_st'].flatten()
vobs=Q['vafobs'].flatten()

T_is=Q['T_is'].flatten()
V_is=Q['Vaf_is'].flatten()


times=.5*(T[:-1]+T[1:])
dvdt = np.diff(V)/1e9*4*.917

times_is=.5*(T_is[:-1]+T_is[1:])
dvdt_is = np.diff(V_is)/1e9*4*.917



fig, (ax1, ax2) = plt.subplots(1,2,figsize=(10, 8))
plt.subplots_adjust(bottom=.5)

with open('params_file.txt', 'r') as file:
    lines = file.readlines()

# Combine lines into a single string
text = ''.join(lines)

# Add the text using fig.text()
fig.text(0.1, 0.45, text, ha='left', va='top', wrap=True, fontsize=10)

textmis = 'surface cost: ' +  str(surfcost) + '\nvelocity cost: ' + str(velcost) + '\nbeta reg cost: ' + str(betacost) + '\nbglen reg cost: ' + str(bglencost) + '\nprior cost: ' + str(priorcost) + '\n'

fig.text(0.5, 0.45, textmis, ha='left', va='top', wrap=True, fontsize=10)

ax1.plot(2004+times, dvdt,linewidth=2)
ax1.plot(2004+times_is, dvdt_is,'k--',linewidth=2)
ax1.grid(which='both')
ax1.minorticks_on()
ax1.tick_params(which='minor')

dvdtobs1 = (vobs[1]-vobs[0])/5/1e9*.917
dvdtobs2 = (vobs[2]-vobs[1])/5/1e9*.917

ax1.plot(2004+Tobs1,dvdtobs1*np.ones(np.shape(Tobs1)),'k',linewidth=4)
ax1.plot(2004+Tobs2,dvdtobs2*np.ones(np.shape(Tobs2)),'k',linewidth=4)

ax1.set(ylabel='DvDt (Gt/a)',title='DVafDt')

ax2.plot(2004+T, V/1e9*.917,linewidth=2)
ax2.grid(which='both')
ax2.minorticks_on()
ax2.tick_params(which='minor')
ax2.set(ylabel='VAF (Gt)',title='VAF')

tempfile='/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/temp_data.mat'
Q = loadmat(tempfile)
mask_cost=Q['mask_cost']
x=Q['x_mesh_mid']
y=Q['y_mesh_mid']
rlow=Q['bed']
rlow[mask_cost==0]=np.nan

plt.savefig(f'{webfolder}/dvaf/{currdir}.png')
os.system(f'chmod 755 {webfolder}/dvaf/{currdir}.png')



#############################


fig, ax1 = plt.subplots(1,1,figsize=(6, 8))
plt.subplots_adjust(bottom=.5)


# Add the text using fig.text()
fig.text(0.1, 0.45, text, ha='left', va='top', wrap=True, fontsize=10)

X=ax1.contourf(x.flatten(),y.flatten(),rlow,np.linspace(-1100,-500,31),extend='both')
cbar=plt.colorbar(X);
cbar.set_label('m')
ax1.grid(which='both')
Q=loadmat('expout.mat')
surf = Q['SURF']
thick = Q['THICK']
vx=Q['VX']
vy=Q['VY']
h0=thick[:,:,0]

haf0=h0.copy();
haf0[rlow<0]=haf0[rlow<0]+1027/917*rlow[rlow<0];

n=4
dsdt = (surf[:,:,-1]-surf[:,:,-1-n*4])/n
dsdt[mask_cost==0]=np.nan
ax1.contour(x.flatten(),y.flatten(),haf0>0,levels=[.5],colors="0.5",linewidths=2)
ax1.contour(x.flatten(),y.flatten(),dsdt<-5,levels=[.5],colors='k',linewidths=3)

plt.savefig(f'{webfolder}/inlandthin/{currdir}.png')
os.system(f'chmod 755 {webfolder}/inlandthin/{currdir}.png')

######################################

fig, ax1 = plt.subplots(1,1,figsize=(6, 8))
plt.subplots_adjust(bottom=.5)

with open('params_file.txt', 'r') as file:
    lines = file.readlines()

# Combine lines into a single string
text = ''.join(lines)

# Add the text using fig.text()
fig.text(0.1, 0.45, text, ha='left', va='top', wrap=True, fontsize=10)

v2004=np.sqrt(vx[:,:,0]**2+vy[:,:,0])
v2020=np.sqrt(vx[:,:,16*4]**2+vy[:,:,16*4])
ax1.contour(x.flatten(),y.flatten(),mask_cost,levels=[.5],colors='k',linewidths=1)
v2004[mask_cost==0]=np.nan
v2020[mask_cost==0]=np.nan
X=ax1.contourf(x.flatten(),y.flatten(),(v2020-v2004)/16.,np.linspace(-20,20,31),extend='both',cmap='bwr')
cbar=plt.colorbar(X);
ax1.contour(x.flatten(),y.flatten(),haf0>0,levels=[.5],colors="0.5",linewidths=2)
cbar.set_label('m/a$^2$')
ax1.grid(which='both')

plt.savefig(f'{webfolder}/dvdt/{currdir}.png')
os.system(f'chmod 755 {webfolder}/dvdt/{currdir}.png')

plt.close('all')

#shutil.copyfile('params_file.txt',f'/home/dgoldber/www/public_html/ThwaitesTC/{currdir}/params_file.txt')
#os.system(f'chmod 755 /home/dgoldber/www/public_html/ThwaitesTC/{currdir}/params_file.txt')


######################################

fig, ax1 = plt.subplots(1,1,figsize=(6, 8))
plt.subplots_adjust(bottom=.5)

with open('params_file.txt', 'r') as file:
    lines = file.readlines()

# Combine lines into a single string
text = ''.join(lines)

# Add the text using fig.text()
fig.text(0.1, 0.45, text, ha='left', va='top', wrap=True, fontsize=10)

plt.plot(np.arange(int(cfg_dict['numInvIter'])+1),TotCost)
plt.xlabel('iteration')

plt.savefig(f'{webfolder}/conv/{currdir}.png')
os.system(f'chmod 755 {webfolder}/conv/{currdir}.png')

plt.close('all')




