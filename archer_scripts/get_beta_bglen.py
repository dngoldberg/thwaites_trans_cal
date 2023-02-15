from mds import rdmds
import numpy as np
import sys

numiter=sys.argv[2]
slid=sys.argv[1]

if (slid == 'Weert'):
    slidstr='weert'
else:
    slidstr='coul'

beta0=rdmds('../run_ad_' + slidstr + '_snap/runoptiter' + numiter + '/C_basal_fric')
betap=rdmds('../run_ad_' + slidstr +  '_snap/runoptiter' + numiter + '/xx_beta',int(numiter))
B0=rdmds('../run_ad_' + slidstr + '_snap/runoptiter' + numiter + '/B_glen_sqrt')
Bp=rdmds('../run_ad_' + slidstr + '_snap/runoptiter' + numiter + '/xx_bglen',int(numiter))

beta=beta0+betap
B=B0+Bp

beta.byteswap().tofile('../input/Beta' + slid + '.bin')
B.byteswap().tofile('../input/Bglen' + slid + '.bin')
