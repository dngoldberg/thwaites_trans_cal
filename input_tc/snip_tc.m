% This matlab script is designed to "snip" a predefined section of topography, surface, BM_mask, and velocity from 
% predefined file paths. BedMachine and measures velocity is used. A grid is also defined which is separate
% from either data product grid.
% the data is saved in a matfile to allow for manipulation of smaller arrays later on


% paths to datafiles -- NEED TO BE MODIFIED
%path_to_BM = '/home/dgoldber/network_links/datastore/ice_data/BM_greenland/BedMachineGreenland-2021-04-20.nc'
%path_to_IL = '/home/dgoldber/network_links/datastore/ice_data/its_live_greenland//GRE_G0240_0000.nc'

% limits of domain set here, in Polar Stereo coordinates


load bounds1


load bounds2
xlim_domain = [floor(min(x)/1e3)-1 ceil(max(x)/1e3)+1]*1e3;
ylim_domain = [floor(min(y)/1e3)-1 ceil(max(y)/1e3)+1]*1e3;

dx = 1500;

x_mesh = (xlim_domain(1)-dx/2):dx:(xlim_domain(2)+dx/2);
y_mesh = (ylim_domain(1)-dx/2):dx:(ylim_domain(2)+dx/2);

x_mesh_mid = .5*(x_mesh(1:end-1)+x_mesh(2:end));
y_mesh_mid = .5*(y_mesh(1:end-1)+y_mesh(2:end));

diffx = diff(x_mesh);
diffy = diff(y_mesh);

[X Y] = meshgrid(x_mesh_mid,y_mesh_mid);

mask_dom = roipoly(X,Y,X,x,y);
load bounds2
mask_cost = roipoly(X,Y,X,x,y);

verr = interpMouginotAnt2017(X,Y,1,1);
verrstd = interpMouginotAnt2017(X,Y,1,0);
[vx vy] = interpMouginotAnt2017(X,Y,0,0);
v = interpMouginotAnt2017(X,Y,0,0);
bed = interpBedmachineAntarctica(X,Y,'bed','linear','/totten_1/ModelData/Antarctica/BedMachine/BedMachineAntarctica-v3.5.nc');
bmthick = interpBedmachineAntarctica(X,Y,'thickness','linear','/totten_1/ModelData/Antarctica/BedMachine/BedMachineAntarctica-v3.5.nc');
firn = interpBedmachineAntarctica(X,Y,'firn','linear','/totten_1/ModelData/Antarctica/BedMachine/BedMachineAntarctica-v3.5.nc');
geoid = interpBedmachineAntarctica(X,Y,'geoid','linear','/totten_1/ModelData/Antarctica/BedMachine/BedMachineAntarctica-v3.5.nc');
maskbm = interpBedmachineAntarctica(X,Y,'mask','nearest','/totten_1/ModelData/Antarctica/BedMachine/BedMachineAntarctica-v3.5.nc');
smb = interpRACMOant(X,Y);
%[dh_paolo dh_paolo_fil T_out] = interpPaolo2015(X(:), Y(:), [2004:2011]');
%dh_paolo_rec = zeros(length(y_mesh_mid),length(x_mesh_mid),size(dh_paolo,3));
%for i=1:size(dh_paolo,3);
% dh_paolo_rec(:,:,i) = reshape(dh_paolo(:,i),length(y_mesh_mid),length(x_mesh_mid));
%end
%dh_paolo = squeeze(sum(dh_paolo_rec,3));

% get smith 2020 ice shelf thinning
[Asmith R]=geotiffread('/totten_1/ModelData/Antarctica/DHDTSmith/ais_floating.tif');
% get georeferencing
Asmith = flipud(double(Asmith));
xsmith = R.XWorldLimits(1):R.CellExtentInWorldX:R.XWorldLimits(2);
ysmith = R.YWorldLimits(1):R.CellExtentInWorldY:R.YWorldLimits(2);
xsmith = .5 * (xsmith(1:end-1) + xsmith(2:end));
ysmith = .5 * (ysmith(1:end-1) + ysmith(2:end));
dhdtSmith = interp2(xsmith,ysmith,Asmith,X,Y,'nearest');
dhdtSmith(Y<-5e5) = nan;

[Anoel R]=geotiffread('../data/basal_melt_map_racmo_firn_air_added_PT.tif');
% get georeferencing
Anoel = flipud(double(Anoel));
xnoel = R.XWorldLimits(1):R.CellExtentInWorldX:R.XWorldLimits(2);
ynoel = R.YWorldLimits(1):R.CellExtentInWorldY:R.YWorldLimits(2);
xnoel = .5 * (xnoel(1:end-1) + xnoel(2:end));
ynoel = .5 * (ynoel(1:end-1) + ynoel(2:end));

[xnoel ynoel] = meshgrid(xnoel,ynoel);
Hnoel = interpBedmachineAntarctica(xnoel,ynoel,'thickness','linear','/totten_1/ModelData/Antarctica/BedMachine/BedMachineAntarctica-v3.5.nc');
Snoel = interpBedmachineAntarctica(xnoel,ynoel,'surface','linear','/totten_1/ModelData/Antarctica/BedMachine/BedMachineAntarctica-v3.5.nc');
Hnoel(ynoel<-3.75e5) = nan;
Anoel(ynoel<-3.75e5) = nan;
Bnoel = Snoel-Hnoel;



nx = length(x_mesh_mid);
YEARS=[2009:2017]';
[vxout vyout errxout erryout stdxout stdyout]= interpMouginotAntTimeSeries1973to2018(X,Y,YEARS);
for i=1:length(YEARS);
 vxmoug{i} = vxout(:,((i-1)*nx+1):(nx*i));
 vymoug{i} = vyout(:,((i-1)*nx+1):(nx*i));
 errxmoug{i} = errxout(:,((i-1)*nx+1):(nx*i));
 errymoug{i} = erryout(:,((i-1)*nx+1):(nx*i));
end

load /totten_1/ModelData/Antarctica/Bamber2009DEM/krigged_dem_nsidc.mat
surf = interp2(x,y,surfacedem,X,Y);
return

load /totten_1/ModelData/Antarctica/CPOM_dhdt/dH_cpom_interpolants.mat
dH_T3_cpom = dH_T3(X,Y);
dH_T8_cpom = dH_T8(X,Y);
dH_T13_cpom = dH_T13(X,Y);

surf(surf<-8)=nan;

hasfirn = (firn>0);
nofirn = (firn==0 & ~isnan(surf));
firn(nofirn) = InvDistWeighting(X(hasfirn),Y(hasfirn),firn(hasfirn),...
    X(nofirn),Y(nofirn),2,5e4);



save temp_data.mat bed firn geoid YEARS surf x_mesh_mid y_mesh_mid mask_dom dH_T3_cpom dH_T8_cpom dH_T13_cpom smb diffx diffy verrstd vx vy v maskbm bmthick mask_cost dhdtSmith

%surf = interpBedmachineAntarctica(X,Y,'surface');
%thick = interpBedmachineAntarctica(X,Y,'thickness');
%mask_bm = interpBedmachineAntarctica(X,Y,'mask');

%save temp_data.mat verr vx vy bed surf thick diffx diffy x_mesh_mid y_mesh_mid mask_dom mask_bm v verrstd

