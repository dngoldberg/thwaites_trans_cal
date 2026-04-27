from mds import rdmds
from scipy.io import loadmat
import numpy as np
import matplotlib.pyplot as plt
import sys
import skimage
from IPython import embed

plt.close('all')
nin = int(sys.argv[1])

fsize=16
x0=-1466
y0=-480

Q=loadmat('../input_tc/temp_data.mat'); x=Q['x_mesh_mid'].flatten(); y=Q['y_mesh_mid'].flatten()

bed=np.fromfile('../input_tc/topog.bin',dtype='float64').byteswap().reshape((300,260))
thick=np.fromfile('../input_tc/BedMachineThick.bin',dtype='float64').byteswap().reshape((300,260))
haf=thick;
haf[bed<0] = haf[bed<0] + 1027/917*bed[bed<0]
grmask=haf>0;



x=x/1e3
y=y/1e3
mask=Q['mask_cost']

yticks=np.array([-500, -400, -300])
xticks=np.array([-1600, -1500, -1400, -1300])

def draw_circle(x0,y0,rad):
 theta = np.linspace(0,2*np.pi,31)
 x = x0 + rad*np.cos(theta)
 y = y0 + rad*np.sin(theta)
 plt.plot(x,y,linewidth=3,color='k')

def draw_ellipse(xc, yc, a, b, theta):
 theta_rad = np.deg2rad(theta);

 # Parametric angle
 t = np.linspace(0, 2*np.pi, 200);

 # Parametric ellipse before rotation
 x = a * np.cos(t);
 y = b * np.sin(t);

 # Rotate the ellipse
 x_rot = x * np.cos(theta_rad) - y * np.sin(theta_rad);
 y_rot = x * np.sin(theta_rad) + y * np.cos(theta_rad);

 # Translate to center
 x_final = x_rot + xc;
 y_final = y_rot + yc;

 # Plotting

 plt.plot(x_final, y_final, linewidth=4, color='k', linestyle=':');
 

plt.figure();
rg=100
#q=rdmds('LCURVE_VEL/run_ad_coul_tc_vel_853a9d6495e8/gradcontrol/xx_beta',30);
q=rdmds('/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/LCURVE_VEL/run_ad_coul_tc_vel_855b2af022e4/gradcontrol/xx_beta',nin);
q[haf<=0]=0;
plt.contourf(x,y,q[:len(y),:len(x)],np.linspace(-rg,rg,31),cmap='bwr',extend='both'); cbar=plt.colorbar();
plt.contour(x,y,mask,levels=[.5],colors=['k']); plt.ylim([-580,-225])
plt.yticks(yticks,labels=yticks.astype('str'),fontsize=fsize)
plt.xticks(xticks,labels=xticks.astype('str'),fontsize=fsize)
ticks=np.linspace(-rg,rg,5);
ticks = np.round(ticks,5)
cbar.set_ticks(ticks,labels=np.array([f"{x:.1e}" for x in ticks]),fontsize=fsize)
plt.grid('both')
#draw_circle(x0,y0,30)
draw_ellipse(-1478, -480, 75, 20, -10)

#plt.savefig('../dbeta_vel.png')

plt.figure(); 
#rg=150;
q=rdmds('/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/LCURVE/run_ad_coul_tc_surf_a0a966bceb3f/gradcontrol/xx_beta',nin); 
#q=rdmds('MELTTEST/run_ad_coul_tc_surf_a72907e92a8e/gradcontrol/xx_beta',40); 
q=skimage.filters.gaussian(q, sigma=2,mode = 'nearest',truncate=4.0)
q[haf<=0]=0;
plt.contourf(x,y,q[:len(y),:len(x)],np.linspace(-rg,rg,31),cmap='bwr',extend='both'); cbar=plt.colorbar(); 
plt.contour(x,y,mask,levels=[.5],colors=['k']); plt.ylim([-580,-225])
plt.yticks(yticks,labels=yticks.astype('str'),fontsize=fsize)
plt.xticks(xticks,labels=xticks.astype('str'),fontsize=fsize)
ticks=np.linspace(-rg,rg,5);
ticks = np.round(ticks,4)
cbar.set_ticks(ticks,labels=np.array([f"{x:.1e}" for x in ticks]),fontsize=fsize)
plt.grid('both')
#draw_circle(x0,y0,30)
draw_ellipse(-1478, -480, 75, 20, -10)

#plt.savefig('../dbeta_surf.png')

plt.figure();
rg=2.5e9;
q=rdmds('/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/ADVAF/run_advaf_coul_snap_97ee11cadfce/adxx_beta',0);
plt.contourf(x,y,q[:len(y),:len(x)],np.linspace(-rg,rg,31),cmap='bwr',extend='both'); cbar=plt.colorbar();
plt.contour(x,y,mask,levels=[.5],colors=['k']); plt.ylim([-580,-225])
plt.yticks(yticks,labels=yticks.astype('str'),fontsize=fsize)
plt.xticks(xticks,labels=xticks.astype('str'),fontsize=fsize)
ticks=np.linspace(-rg,rg,5);
ticks = np.round(ticks,4)
cbar.set_ticks(ticks,labels=np.array([f"{x:.1e}" for x in ticks]),fontsize=fsize)
cbar.ax.set_title('m$^3$ a$^{-1}$ Pa$^{-1/2}$ (m/a)$^{1/6}$')
plt.grid('both')
#draw_circle(x0,y0,30)
draw_ellipse(-1478, -480, 75, 20, -10)

plt.savefig('Jdvaf_beta.png')
#plt.figure(); q=rdmds('LCURVE_VEL/run_ad_coul_tc_vel_853a9d6495e8//gradcontrol/adxx_beta',nin); plt.contourf(x,y,q[:len(y),:len(x)],np.linspace(-1e-4,1e-4,31),cmap='bwr',extend='both'); cbar=plt.colorbar(); plt.contour(x,y,mask,levels=[.5],colors=['k']); plt.ylim([-580,-225])

plt.show()

