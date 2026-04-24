from mds import rdmds 
from scipy.io import loadmat
import numpy as np
import sys
import glob

invIter = int(sys.argv[1])
sliding_law=(sys.argv[2])
melt_mode_str=(sys.argv[3])
bglen_mode=(sys.argv[4])
beta_mode=(sys.argv[5])
project_mode=(sys.argv[6]) # mode is max, min, or last (min for beta/B, max for melt)


direc='../run_ad_' + sliding_law + '_tc_gentim_' + melt_mode_str + bglen_mode + beta_mode
run_direc = '../run_val_' + sliding_law + '_' + melt_mode_str + bglen_mode + beta_mode + '_' + project_mode
melt_control=rdmds(direc + '/gradcontrol/xx_bdot_max',invIter)
bglen_control=rdmds(direc + '/gradcontrol/xx_bglen',invIter)
beta_control=rdmds(direc + '/gradcontrol/xx_beta',invIter)

if (melt_mode_str=='G'):
    s=np.shape(melt_control)
    melt_control_new = np.zeros((s[0]+2,s[1],s[2]))
    melt_control_new[:-2,:,:] = melt_control
    if (project_mode=='max'):
        melt_control_new[-2:,:,:] = np.tile(np.max(melt_control,axis=0),(2,1,1))
    elif (project_mode=='last'):
        melt_control_new[-2:,:,:] = np.tile(melt_control[-1,:,:],(2,1,1))
    else: 
        raise Exception("invalid melt project mode")
else:
    melt_control_new = melt_control

if (int(bglen_mode)==1):
    s=np.shape(bglen_control)
    bglen_control_new = np.zeros((s[0]+2,s[1],s[2]))
    bglen_control_new[:-2,:,:] = bglen_control
    if (project_mode=='min'):
        bglen_control_new[-2:,:,:] = np.tile(np.min(bglen_control,axis=0),(2,1,1))
    elif (project_mode=='last'):
        bglen_control_new[-2:,:,:] = np.tile(bglen_control[-1,:,:],(2,1,1))
    else: 
        raise Exception("invalid bglen project mode")
else:
    bglen_control_new = bglen_control

if (int(beta_mode)==1):
    s=np.shape(beta_control)
    beta_control_new = np.zeros((s[0]+2,s[1],s[2]))
    beta_control_new[:-2,:,:] = beta_control
    if (project_mode=='min'):
        beta_control_new[-2:,:,:] = np.tile(np.min(beta_control,axis=0),(2,1,1))
    elif (project_mode=='last'):
        beta_control_new[-2:,:,:] = np.tile(beta_control[-1,:,:],(2,1,1))
    else: 
        raise Exception("invalid beta project mode")
else:
    beta_control_new = beta_control


s = np.shape(bglen_control_new)
if (len(s)==3):
    bglen_ax=s[0]
else:
    bglen_ax=1
s = np.shape(beta_control_new)
if (len(s)==3):
    beta_ax=s[0]
else:
    beta_ax=1


bglen0 = np.tile(rdmds(direc + '/runoptiter000/B_glen_sqrt'),(bglen_ax,1,1))
beta0 = np.tile(rdmds(direc + '/runoptiter000/C_basal_fric'),(beta_ax,1,1))

melt_control_new.byteswap().tofile(run_direc + '/xx_bdot_max.bin')
(beta0+beta_control_new).byteswap().tofile(run_direc + '/xx_beta.bin')
(bglen0+bglen_control_new).byteswap().tofile(run_direc + '/xx_bglen.bin')

