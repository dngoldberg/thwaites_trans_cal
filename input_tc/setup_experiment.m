function setup_experiment(nx,ny,gx,gy);
% this function creates a set of input files for use with STREAMICE
% it is meant to be called by gen_mesh.m
% nx, ny -- columns and rows of computational grid
% gx, gy -- padding to ensure all tiles have same size
% note files created will be of size (nx+gx, ny+gy)



load temp_data

% verr vx vy bed surf thick diffx diffy x_mesh_mid y_mesh_mid mask_dom mask_bm v

filter_surf = false;

%%% THESE VALUES SHOULD BE CONSISTENT WITH data.streamice
density_ice = 917;
density_oce = 1027;

[X Y] = meshgrid(x_mesh_mid,y_mesh_mid);

%% interpolate all data to grid


%%% PREPARE VELOCITY CONSTRAINTS


vx_dirich = vx;
vy_dirich = vy;


vx(isnan(v) | mask_dom==0 | isnan(verrstd)) = -999999;
vy(isnan(v) | mask_dom==0 | isnan(verrstd)) = -999999;
verr(isnan(v) | mask_dom==0 | isnan(verrstd)) = -999999;
verrstd(isnan(v) | mask_dom==0 | isnan(verrstd)) = -999999;

%%% PREPARE THICKNESS BASED ON SURFACE, BED and DENSITIES

%%% Note, a gaussian filter is applied to the surface but only has an effect
%%% where topography is extremely variable -- IGNORED if filter_surf = false

surf(surf<0)=0;

if(filter_surf)
    surf2 = surf;
    surf2(thick<5 & surf2>0)=.5;
    surf2(surf2==0 | mask_bm==1 | mask_bm==0)=nan;
    gaussFilter = fct_GaussianFilter([4 4], 1, 0);
    [surf2,im_conv,count,NaNcount] = fct_convNaN(surf2, gaussFilter, 'same', .5);
    surf2(mask_bm==0 | mask_bm==1)=nan;
    surf2(isnan(surf2))=surf(isnan(surf2));
    surf = surf2;
    surf(isnan(surf))=0;
end

%%% RATHER THAN USE BEDMACHINE THICKNESS, SURFACE IS USED AND THICKNESS IS INFERRED FROM LOCATION
%%% THIS IS IN CASE OF ANY DISCREPANCIES IN DENSITY WITH BEDMACHINE FOR FLOATING ICE

thick_floatation = (- density_oce*surf) / (density_ice - density_oce);
thick_floatation(surf==0)=0;
base_floatation = surf - thick_floatation;
base = max(bed,base_floatation);
thick_mod = surf-base;
thick_mod(surf==0)=0;
thick = thick_mod;


%%%%%%%%%%%%%%%%%%%%%

%%% HMASK IS DEFINED HERE
% MASK = 1: active ice
% MASK = -1: out of domain
% MASK = 0: ocean
% ice-ocean boundaries have a calving front stress condition
% ice-"out of domain" boundaries have no-slip (zero velocity) conditions
%
% MASK is -1 where ice is less then 2m (to avoid ill conditioning)
% 

hmask = zeros(size(thick));
hmask(thick>2) = 1;
hmask(:,[1 end])=-1;
hmask([1 end],:)=-1;
hmask(surf>2000)=-1;
hmask(~mask_dom)=-1;

con_mask = hmask==1;
CC = bwconncomp(con_mask,4);
pp = CC.PixelIdxList;
for i=1:length(pp);
    length_pp(i) = length(pp{i});
end
[xx isort] = sort(length_pp,'descend');
if (length(pp)>1);
 for i=2:length(pp);
  for k=1:length(pp{isort(i)});
   hmask(pp{isort(i)}(k)) = -1;
  end;
 end;
end;

hmask_dirich = hmask;
hmask_dirich(mask_dom==0 & hmask_dirich==1) = -1;

% this field is not used -- but demonstrates how to define the B field for isothermal ice

Xhere = X;
Yhere = Y;
load ../../../pattyn/Temp_2013
load ../../../pattyn/Zeta
Zeta = ones(1,1,length(zeta));
Zeta(1,1,:) = zeta;
Zeta = repmat(Zeta,[size(temp507,1) size(temp507,2) 1]);
Xp = X;
Yp = Y;
X = Xhere;
Y = Yhere;

Aglen = apaterson(temp507-273.15) * 31104000;
Bglen = Aglen.^(-1/3);

Bbar = .5*sum((Bglen(:,:,1:end-1)+Bglen(:,:,2:end)).*diff(Zeta,1,3),3);

Bbar = sqrt(InterpFromGrid(Xp(1,:)'*1000,Yp(:,1)*1000,Bbar,double(X),double(Y),'linear'));
Bbar2 = Bbar;
Bbar(isnan(Bbar))=0;
Bbar(Bbar==0)=700;
Bbar2(isnan(Bbar2))=0;

%%%%%

faketopog = -1000*ones(ny,nx);
faketopog([1 end],:) = 0;
faketopog(:,[1 end]) = 0;

%%%%% VFACE VELOCITY AND MASK

vfacemask = -1 * ones(ny,nx);
vfacevel = zeros(ny,nx);
vhfacevel = zeros(ny,nx);
vfacevel(2:end,:) = .5 * (vy_dirich(1:end-1,:)+vy_dirich(2:end,:));
vfacevel(isnan(vfacevel)) = 0;
vhfacevel(2:end,:) = .5 * (thick(1:end-1,:)+thick(2:end,:));

mask_vel_south = zeros(ny,nx);
mask_vel_south(2:end-1,:) = (mask_dom(2:end-1,:)==0) & (mask_dom(1:end-2,:)==1) & ~isnan(vfacevel(2:end-1,:));
mask_vel_north = zeros(ny,nx);
mask_vel_north(2:end-1,:) = (mask_dom(2:end-1,:)==1) & (mask_dom(1:end-2,:)==0) & ~isnan(vfacevel(2:end-1,:));

vfacemask(mask_vel_south==1) = 3;
vfacemask(mask_vel_north==1) = 3;

%%%%% VFACE VELOCITY AND MASK

ufacemask = -1 * ones(ny,nx);
ufacevel = zeros(ny,nx);
uhfacevel = zeros(ny,nx);
ufacevel(:,2:end) = .5 * (vx_dirich(:,1:end-1)+vx_dirich(:,2:end));
ufacevel(isnan(ufacevel)) = 0;
uhfacevel(:,2:end) = .5 * (thick(:,1:end-1)+thick(:,2:end));

mask_vel_west = zeros(ny,nx);
mask_vel_west(:,2:end-1) = (mask_dom(:,2:end-1)==0) & (mask_dom(:,1:end-2)==1) & ~isnan(ufacevel(:,2:end-1));
mask_vel_east = zeros(ny,nx);
mask_vel_east(:,2:end-1) = (mask_dom(:,2:end-1)==1) & (mask_dom(:,1:end-2)==0) & ~isnan(ufacevel(:,2:end-1));

ufacemask(mask_vel_west==1) = 3;
ufacemask(mask_vel_east==1) = 3;

%%%%%%%%%%%%%%






bed = [[bed zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('topog.bin',bed');

faketopog = [[faketopog zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('faketopog.bin',faketopog');

thick = [[thick zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('BedMachineThick.bin',thick');

vx = [[vx zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('velobsu.bin',vx');

vy = [[vy zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('velobsv.bin',vy');

verr = [[verr zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('errU.box',verr');
verrstd = [[verrstd zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('errUstd.box',verrstd');


ufacemask = [[ufacemask zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('ufacemask_dirich.bin',ufacemask');
vfacemask = [[vfacemask zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('vfacemask_dirich.bin',vfacemask');
ufacevel = [[ufacevel zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('ufacevel_dirich.bin',ufacevel');
vfacevel = [[vfacevel zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('vfacevel_dirich.bin',vfacevel');


binwrite('ufacemask.bin',-1*ones(nx+gx,ny+gy));
binwrite('vfacemask.bin',-1*ones(nx+gx,ny+gy));

%binwrite('dhdtCryo.bin',dhdt');
%binwrite('oceModelMelt.bin',shelfMelt');

Bbar = [[Bbar zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('BglenPattyn.bin',Bbar');

Bbar2 = [[Bbar2 zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('BglenPattynMask.bin',Bbar2');

binwrite('delX.bin',[diffx ones(1,gx)]);
binwrite('delY.bin',[diffy ones(1,gy)]);

disp('GOT HERE'); 
hmask = [[hmask -1*ones(ny,gx)];-1*ones(gy,nx+gx)];
binwrite('hmask.bin',hmask');
hmask_dirich = [[hmask_dirich -1*ones(ny,gx)];-1*ones(gy,nx+gx)];
binwrite('hmask_dirich.bin',hmask_dirich');

