from mds import rdmds 
from scipy.io import loadmat
import numpy as np
import sys
import glob

invIter = int(sys.argv[1])
direc=(sys.argv[2])
run_direc=(sys.argv[3])
project_mode=(sys.argv[4]) # mode is max, min, or last (min for beta/B, max for melt)


#run_ad_coul_tc_gentim_g00

#direc='../run_ad_' + sliding_law + '_tc_' + foldname + '_' + melt_mode_str + bglen_mode + beta_mode
#run_direc = '../run_val_' + sliding_law + '_' + melt_mode_str + bglen_mode + beta_mode + '_' + project_mode + pad
melt_control=rdmds(direc + '/gradcontrol/xx_bdot_max',invIter)
bglen_control=rdmds(direc + '/gradcontrol/xx_bglen',invIter)
beta_control=rdmds(direc + '/gradcontrol/xx_beta',invIter)

if (melt_mode_str=='G'):
    if (project_mode=='max'):
        melt_control_new = np.max(melt_control,axis=0)
    elif (project_mode=='last'):
        melt_control_new = melt_control[-1,:,:]
    elif (project_mode=='mean'):
        melt_control_new = np.mean(melt_control,axis=0)
    else: 
        raise Exception("invalid melt project mode")
else:
    melt_control_new = melt_control

if (int(bglen_mode)==1):
    if (project_mode=='min'):
        bglen_control_new = np.min(bglen_control,axis=0)
    elif (project_mode=='mean'):
        bglen_control_new = np.mean(bglen_control,axis=0)
    elif (project_mode=='last'):
        bglen_control_new = bglen_control[-1,:,:]
    else: 
        raise Exception("invalid bglen project mode")
else:
    bglen_control_new = bglen_control

if (int(beta_mode)==1):
    if (project_mode=='min'):
        beta_control_new = np.min(beta_control,axis=0)
    elif (project_mode=='mean'):
        beta_control_new = np.mean(beta_control,axis=0)
    elif (project_mode=='last'):
        beta_control_new = beta_control[-1,:,:]
    else: 
        raise Exception("invalid beta project mode")
else:
    beta_control_new = beta_control

bglen_ax=1
beta_ax=1


bglen0 = np.tile(rdmds(direc + '/runoptiter000/B_glen_sqrt'),(bglen_ax,1,1))
beta0 = np.tile(rdmds(direc + '/runoptiter000/C_basal_fric'),(beta_ax,1,1))

melt_control_new.byteswap().tofile(run_direc + '/xx_bdot_max.bin')
(beta0+beta_control_new).byteswap().tofile(run_direc + '/xx_beta.bin')
(bglen0+bglen_control_new).byteswap().tofile(run_direc + '/xx_bglen.bin')

