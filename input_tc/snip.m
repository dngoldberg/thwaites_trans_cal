% This matlab script is designed to "snip" a predefined section of topography, surface, BM_mask, and velocity from 
% predefined file paths. BedMachine and measures velocity is used. A grid is also defined which is separate
% from either data product grid.
% the data is saved in a matfile to allow for manipulation of smaller arrays later on


% paths to datafiles -- NEED TO BE MODIFIED
%path_to_BM = '/home/dgoldber/network_links/datastore/ice_data/BM_greenland/BedMachineGreenland-2021-04-20.nc'
%path_to_IL = '/home/dgoldber/network_links/datastore/ice_data/its_live_greenland//GRE_G0240_0000.nc'

% limits of domain set here, in Polar Stereo coordinates
load bounds1

xlim_domain = [floor(min(x)/1e3)-5 ceil(max(x)/1e3)+5]*1e3;
ylim_domain = [floor(min(y)/1e3)-5 ceil(max(y)/1e3)+5]*1e3;

dx = 1400;

x_mesh = (xlim_domain(1)-dx/2):dx:(xlim_domain(2)+dx/2);
y_mesh = (ylim_domain(1)-dx/2):dx:(ylim_domain(2)+dx/2);

x_mesh_mid = .5*(x_mesh(1:end-1)+x_mesh(2:end));
y_mesh_mid = .5*(y_mesh(1:end-1)+y_mesh(2:end));

diffx = diff(x_mesh);
diffy = diff(y_mesh);

[X Y] = meshgrid(x_mesh_mid,y_mesh_mid);

mask_dom = roipoly(X,Y,X,x,y);

mask_oob = roipoly(X,Y,X,[min(min(x_mesh)) -1.4e6 min(min(x_mesh))],[-3.75e5 max(max(y_mesh)) max(max(y_mesh))]);

verr = interpMouginotAnt2017(X,Y,1,1);
verrstd = interpMouginotAnt2017(X,Y,1,0);
[vx vy] = interpMouginotAnt2017(X,Y,0,0);
v = interpMouginotAnt2017(X,Y,0,0);
bed = interpBedmachineAntarctica(X,Y,'bed');
surf = interpBedmachineAntarctica(X,Y,'surface');
thick = interpBedmachineAntarctica(X,Y,'thickness');
mask_bm = interpBedmachineAntarctica(X,Y,'mask');

save temp_data.mat verr vx vy bed surf thick diffx diffy x_mesh_mid y_mesh_mid mask_dom mask_bm v verrstd mask_oob

