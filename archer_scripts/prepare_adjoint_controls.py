from mds import rdmds 
from scipy.io import loadmat
import numpy as np
import sys
import glob

invDir = int(sys.argv[1])
run_direc = int(sys.argv[1])

print(invDir)

paramfile = invDir + '/params_file.txt'
with open(str(path)+ '/params_file.txt', 'r') as file:
            lines = file.readlines()

cfg_dict = {line.split(':')[0].strip(): line.split(':')[1].strip() for line in lines}
print(cfg_dict)

#run_ad_coul_tc_gentim_g00

#direc='../run_ad_' + sliding_law + '_tc_' + foldname + '_' + melt_mode_str + bglen_mode + beta_mode
#run_direc = '../run_val_' + sliding_law + '_' + melt_mode_str + bglen_mode + beta_mode + '_' + project_mode + pad
melt_control=rdmds('../' + invDir + '/gradcontrol/xx_bdot_max',int(cfg_dict['numInvIter']))
bglen_control=rdmds('../' + invDir + '/gradcontrol/xx_bglen',int(cfg_dict['numInvIter']))
beta_control=rdmds('../' + invDir + '/gradcontrol/xx_beta',int(cfg_dict['numInvIter']))
project_mode = cfg_dict['proj']

if (cfg_dict['MeltType']=='G'):
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

if (int(cfg_dict['BglenType'])==1):
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

if (int(cfg_dict['BetaMode'])==1):
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


bglen_ax=1
beta_ax=1

#bglen0 = np.tile(rdmds('../' + direc + '/runoptiter' + str(invIter).zfill(3) + '/B_glen_sqrt'),(bglen_ax,1,1))
#beta0 = np.tile(rdmds('../' + direc + '/runoptiter' + str(invIter).zfill(3) + '/C_basal_fric'),(beta_ax,1,1))
bglen0 = np.fromfile('../' + invDir + '/BetaCoul.bin',count=-1,dtype='float64').byteswap().reshape(np.shape(beta_control_new)
beta0 = np.fromfile('../' + invDir + '/BglenCoul.bin',count=-1,dtype='float64').byteswap().reshape(np.shape(bglen_control_new)


melt_control_new.byteswap().tofile('../' + run_direc + '/xx_bdot_max.bin')
(beta0+beta_control_new).byteswap().tofile('../' + run_direc + '/xx_beta.bin')
(bglen0+bglen_control_new).byteswap().tofile('../' + run_direc + '/xx_bglen.bin')

