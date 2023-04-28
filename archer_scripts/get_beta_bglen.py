from mds import rdmds
import numpy as np
import sys

numiter=sys.argv[2]
slid=sys.argv[1]
ad_folder=sys.argv[3]
run_folder=sys.argv[4]

if (slid == 'Weert'):
    slidstr='weert'
else:
    slidstr='coul'

beta0=rdmds(ad_folder+ '/runoptiter' + numiter + '/C_basal_fric')
betap=rdmds(ad_folder+ '/gradcontrol/xx_beta',int(numiter))
B0=rdmds(ad_folder+ '/runoptiter' + numiter + '/B_glen_sqrt')
Bp=rdmds(ad_folder+ '/gradcontrol/xx_bglen',int(numiter))

beta=beta0+betap
B=B0+Bp

beta.byteswap().tofile('Beta' + slid + '.bin')
B.byteswap().tofile('Bglen' + slid + '.bin')
