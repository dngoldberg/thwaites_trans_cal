from mds import rdmds 
from scipy.io import loadmat
import numpy as np
import sys
import glob
import re

invIter = int(sys.argv[1])
direc=(sys.argv[2])
run_direc=(sys.argv[3])
project_mode=(sys.argv[4]) # mode is max, min, or last (min for beta/B, max for melt)
melt_mode_str=(sys.argv[5])
bglen_mode=(sys.argv[6])
beta_mode=(sys.argv[7])
#mconst=(sys.argv[8])

#if (mconst=='n'):
#    mconst=0
#else:
#    mconst=str(mconst)


print(run_direc)

#run_ad_coul_tc_gentim_g00

#direc='../run_ad_' + sliding_law + '_tc_' + foldname + '_' + melt_mode_str + bglen_mode + beta_mode
#run_direc = '../run_val_' + sliding_law + '_' + melt_mode_str + bglen_mode + beta_mode + '_' + project_mode + pad
melt_control=rdmds('../' + direc + '/gradcontrol/xx_bdot_max',invIter)
bglen_control=rdmds('../' + direc + '/gradcontrol/xx_bglen',invIter)
beta_control=rdmds('../' + direc + '/gradcontrol/xx_beta',invIter)

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

#if (mconst != 0):
#    melt_control[:] = mconst


bglen_ax=1
beta_ax=1


#bglen0 = np.tile(rdmds('../' + direc + '/runoptiter' + str(invIter).zfill(3) + '/B_glen_sqrt'),(bglen_ax,1,1))
#beta0 = np.tile(rdmds('../' + direc + '/runoptiter' + str(invIter).zfill(3) + '/C_basal_fric'),(beta_ax,1,1))

bdotmaxfile0=''
with open('../' + direc + '/data.streamice','r') as f:
 for line in f.readlines():
  ln = line.upper()
  if 'STREAMICEBASALTRACFILE' in ln:
   match = re.search(r"""(['"])(.*?)\1""", line)
   if match:
    betafile0=match.group(2)
  if 'STREAMICEGLENCONSTFILE' in ln:
   match = re.search(r"""(['"])(.*?)\1""", line)
   if match:
    glenfile0=match.group(2)
  if 'STREAMICEBDOTMAXMELTFILE' in ln:
   match = re.search(r"""(['"])(.*?)\1""", line)
   if match:
    bdotmaxfile0=match.group(2)


bglen0 = np.fromfile('../' + direc + '/' + glenfile0 ,count=-1,dtype='float64').byteswap().reshape(np.shape(bglen_control_new))
(bglen0+bglen_control_new).byteswap().tofile('../' + run_direc + '/xx_bglen.bin')
beta0 = np.fromfile('../' + direc + '/' + betafile0 ,count=-1,dtype='float64').byteswap().reshape(np.shape(bglen_control_new))
(beta0+beta_control_new).byteswap().tofile('../' + run_direc + '/xx_beta.bin')

if (bdotmaxfile0 == ''):
 melt_control_new.byteswap().tofile('../' + run_direc + '/xx_bdot_max.bin')
else:
 print(bdotmaxfile0)
 bdot0 = np.fromfile('../' + direc + '/' + bdotmaxfile0 ,count=-1,dtype='float64').byteswap().reshape(np.shape(bglen_control_new))
 (bdot0+melt_control_new).byteswap().tofile('../' + run_direc + '/xx_bdot_max.bin')


