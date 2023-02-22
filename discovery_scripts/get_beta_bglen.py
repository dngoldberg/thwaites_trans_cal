from mds import rdmds
import numpy as np
import sys, os

numiter=sys.argv[2]
slid=sys.argv[1]
iceshare=sys.argv[3]
homedir=os.environ['HOME']

if (slid == 'Weert'):
    slidstr='weert'
else:
    slidstr='coul'

beta0=rdmds(iceshare + '/run_ad_' + slidstr + '_snap/runoptiter' + numiter + '/C_basal_fric')
betap=rdmds(iceshare + '/run_ad_' + slidstr +  '_snap/runoptiter' + numiter + '/xx_beta',int(numiter))
B0=rdmds(iceshare + '/run_ad_' + slidstr + '_snap/runoptiter' + numiter + '/B_glen_sqrt')
Bp=rdmds(iceshare + '/run_ad_' + slidstr + '_snap/runoptiter' + numiter + '/xx_bglen',int(numiter))

beta=beta0+betap
B=B0+Bp

beta.byteswap().tofile(homedir + '/thwaites_trans_cal/input_tc/Beta' + slid + '.bin')
B.byteswap().tofile(homedir + '/thwaites_trans_cal/input_tc/Bglen' + slid + '.bin')
