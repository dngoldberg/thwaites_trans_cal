from mds import rdmds
import numpy as np
import sys
import glob

thresh=float(sys.argv[1])
timestep=float(sys.argv[2])

filelist = glob.glob('../input/surface_constraints/full_*surf*bin');

for fname in filelist:
    step = float(fname[-14:-4])
    print(step)
    print(fname)
    q = np.fromfile(fname,dtype='float64').byteswap()
    qdh = np.fromfile('../input/surface_constraints/full_CPOM_dh' + str(int(step)).zfill(10) + '.bin').byteswap()
    print(np.shape(np.where(q>-999999)))
    print(np.shape(np.where((qdh>(-1.0*thresh*step*timestep/31104000.)) & (q>-999999.))))
    q[(qdh>(-1.0*thresh*step*timestep/31104000.)) & (q>-999999.)] = -999999.
    print(fname[:29]+fname[34:])
    q.byteswap().tofile(fname[:29]+fname[34:])

