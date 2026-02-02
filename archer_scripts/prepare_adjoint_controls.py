from mds import rdmds 
from scipy.io import loadmat
import numpy as np
import sys
import glob
import os

invDir = sys.argv[1]
run_direc = sys.argv[2]


print(invDir)



paramfile = '../' + invDir + '/params_file.txt'
with open(paramfile, 'r') as file:
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

if (int(cfg_dict['GlenType'])==1):
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

if (int(cfg_dict['BetaType'])==1):
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

if (os.path.exists(os.path.join(os.getcwd(), '..', invDir, 'xx_beta.bin'))):
 beta0 = np.fromfile('../' + invDir + '/xx_beta.bin',count=-1,dtype='float64').byteswap().reshape(np.shape(beta_control_new))
else:                   
 beta0 = np.fromfile('../' + invDir + '/BetaCoul.bin',count=-1,dtype='float64').byteswap().reshape(np.shape(beta_control_new))

(beta0+beta_control_new).byteswap().tofile('../' + run_direc + '/xx_beta.bin')

########################################

if (os.path.exists(os.path.join(os.getcwd(), '..', invDir, 'xx_bglen.bin'))):
 bglen0 = np.fromfile('../' + invDir + '/xx_bglen.bin',count=-1,dtype='float64').byteswap().reshape(np.shape(bglen_control_new))
else:                   
 bglen0 = np.fromfile('../' + invDir + '/BglenCoul.bin',count=-1,dtype='float64').byteswap().reshape(np.shape(bglen_control_new))

(bglen0+bglen_control_new).byteswap().tofile('../' + run_direc + '/xx_bglen.bin')
                                                                                                   
########################################

if (os.path.exists(os.path.join(os.getcwd(), '..', invDir, 'xx_bdot_max.bin'))):
 bdot0 = np.fromfile('../' + invDir + '/xx_bdot_max.bin',count=-1,dtype='float64').byteswap().reshape(np.shape(melt_control_new))
 (bdot0+melt_control_new).byteswap().tofile('../' + run_direc + '/xx_bdot_max.bin')
else:                   
 melt_control_new.byteswap().tofile('../' + run_direc + '/xx_bdot_max.bin')



