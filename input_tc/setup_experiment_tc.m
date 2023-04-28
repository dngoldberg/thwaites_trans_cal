function setup_experiment(nx,ny,gx,gy);
% this function creates a set of input files for use with STREAMICE
% it is meant to be called by gen_mesh.m
% nx, ny -- columns and rows of computational grid
% gx, gy -- padding to ensure all tiles have same size
% note files created will be of size (nx+gx, ny+gy)

global timesteps_per_year

load temp_data


filter_surf = false;

%%% THESE VALUES SHOULD BE CONSISTENT WITH data.streamice
density_ice = 917;
density_oce = 1027;




[X Y] = meshgrid(x_mesh_mid,y_mesh_mid);

%% interpolate all data to grid

%save temp.mat bed firn geoid YEARS vxmoug vymoug errxmoug errymoug surf x_mesh_mid y_mesh_mid mask_dom maskbm
%%% ADJUST BAMBER SURFACE

surfadj = surf - firn - geoid;
surf(isnan(surf))=0;
surfadj(surf==0)=0;



%%% PREPARE VELOCITY CONSTRAINTS

YEARS=[2009:2017]';
[vxout vyout errxout erryout stdxout stdyout]= interpMouginotAntTimeSeries1973to2018(X,Y,YEARS);
for i=1:length(YEARS);
 vxmoug{i} = vxout(:,((i-1)*nx+1):(nx*i));
 vymoug{i} = vyout(:,((i-1)*nx+1):(nx*i));
 errxmoug{i} = errxout(:,((i-1)*nx+1):(nx*i));
 errymoug{i} = erryout(:,((i-1)*nx+1):(nx*i));
end

!mkdir -p velocity_constraints
!rm velocity_constraints/*
for i =1:length(YEARS);
 YEARS(i)
 vxt = vxmoug{i};
 vxt(isnan(v)) = nan;
 vyt(isnan(v)) = nan;
 errxt(isnan(v)) = nan;
 erryt(isnan(v)) = nan;
 vyt = vymoug{i};
 errxt = errxmoug{i};
 erryt = errymoug{i};
 set_to_nan = (isnan(vxt) | isnan(vyt) | isnan(errxt) | isnan(erryt) | mask_cost==0);
 vxt(set_to_nan) = -999999;
 vyt(set_to_nan) = -999999;
 errxt(set_to_nan) = -999999;
 erryt(set_to_nan) = -999999;


 vxt = [[vxt zeros(ny,gx)];zeros(gy,nx+gx)];
 vyt = [[vyt zeros(ny,gx)];zeros(gy,nx+gx)];
 errxt = [[errxt zeros(ny,gx)];zeros(gy,nx+gx)];
 erryt = [[erryt zeros(ny,gx)];zeros(gy,nx+gx)];

 binwrite(['velocity_constraints/velobsMoug' appNum(timesteps_per_year*(YEARS(i)-2004),10) 'u.bin'],vxt');
 binwrite(['velocity_constraints/velobsMoug' appNum(timesteps_per_year*(YEARS(i)-2004),10) 'v.bin'],vyt');
 binwrite(['velocity_constraints/velobsMoug' appNum(timesteps_per_year*(YEARS(i)-2004),10) 'err.bin'],sqrt(errxt.^2+erryt.^2));
end

vx0=vx;
vy0=vy;


vx(isnan(v) | isnan(verrstd) | ~mask_dom) = -999999;
vy(isnan(v) | isnan(verrstd) | ~mask_dom) = -999999;
verr(isnan(v) | isnan(verrstd)| ~mask_dom) = -999999;
verrstd(isnan(v) | isnan(verrstd)| ~mask_dom) = -999999;

%%% PREPARE SURFACE CONSTRAINTS

!mkdir -p surface_constraints
!rm surface_constraints/*
% dH_T3_cpom dH_T8_cpom dH_T13_cpom
years=[3 8 13];
Ismith = ~isnan(dhdtSmith);
for i=1:length(years);
	yr = num2str(years(i));
	str = ['dhT = dH_T' num2str(years(i)) '_cpom;'];
	eval(str)
	str = ['surftemp = surf + dH_T' num2str(years(i)) '_cpom;'];
	eval(str)
	surftemp(~mask_cost) = nan;
	surftemp(Y<-561e3 | X>-1350e3) = nan;

	surftemp(isnan(surftemp)) = -999999;
        surftemp_smith = surftemp;
	surftemp_smith(Ismith) = ...
		surf(Ismith) + years(i)*dhdtSmith(Ismith)*(1-density_ice/density_oce);
	surftemp_smith(isnan(surftemp_smith)) = -999999;

	surftemp2 = surftemp;
	surftemp2(dhT>(-.25*years(i))) = -999999;
	surftemp2_smith = surftemp_smith;
	surftemp2_smith(dhT>(-.25*years(i))) = -999999;
        surftemp = [[surftemp zeros(ny,gx)];zeros(gy,nx+gx)];
        surftemp_smith = [[surftemp_smith zeros(ny,gx)];zeros(gy,nx+gx)];
        surftemp2_smith = [[surftemp2_smith zeros(ny,gx)];zeros(gy,nx+gx)];
        surftemp2 = [[surftemp2 zeros(ny,gx)];zeros(gy,nx+gx)];
        dhT = [[dhT zeros(ny,gx)];zeros(gy,nx+gx)];
	dhT(surftemp==-99999) = -999999;
        errCpom = ones(ny,nx);
        errCpomSmith = errCpom; 
        errCpomSmith(Ismith) = .5;
	errCpomSmith = [[errCpomSmith zeros(ny,gx)];zeros(gy,nx+gx)];




	binwrite(['surface_constraints/full_CPOM_surf'  appNum(timesteps_per_year*years(i),10) '.bin'],surftemp');
        binwrite(['surface_constraints/CPOM_surf' appNum(timesteps_per_year*years(i),10) 'err.bin'],errCpomSmith');
	binwrite(['surface_constraints/full_CPOMSmith_surf'  appNum(timesteps_per_year*years(i),10) '.bin'],surftemp_smith');
        binwrite(['surface_constraints/CPOMSmith_surf' appNum(timesteps_per_year*years(i),10) 'err.bin'],errCpomSmith');

	binwrite(['surface_constraints/CPOM_surf'  appNum(timesteps_per_year*years(i),10) '.bin'],surftemp2');
	binwrite(['surface_constraints/CPOMSmith_surf'  appNum(timesteps_per_year*years(i),10) '.bin'],surftemp2_smith');
	binwrite(['surface_constraints/full_CPOM_dh'  appNum(timesteps_per_year*years(i),10) '.bin'],dhT');

end


%vx(isnan(v) | mask_dom==0 | isnan(verrstd)) = -999999;
%vy(isnan(v) | mask_dom==0 | isnan(verrstd)) = -999999;
%verr(isnan(v) | mask_dom==0 | isnan(verrstd)) = -999999;
%verrstd(isnan(v) | mask_dom==0 | isnan(verrstd)) = -999999;

%%% PREPARE THICKNESS BASED ON SURFACE, BED and DENSITIES

%TODO 
%     set SMB
%     set up code folder

%%% Note, a gaussian filter is applied to the surface but only has an effect
%%% where topography is extremely variable -- IGNORED if filter_surf = false

mask = zeros(size(surf));
    mask(surf>0)=2;
    mask(maskbm==1)=1;
    mask(surf<0)=0;
    surf(surf<0)=0;

%surf(surf<0)=0;

if(filter_surf)
    surf2 = surfadj;
    surf2(surf2>0 & surf2<1)=1;
    surf2(surf2==0)=nan;
    gaussFilter = fct_GaussianFilter([4 4], 1, 0);
    [surf2,im_conv,count,NaNcount] = fct_convNaN(surf2, gaussFilter, 'same', .5);
    surf2(isnan(surf))=nan;
    surf2(isnan(surf2))=surf(isnan(surf2));
    surfadj = surf2;
    surfadj(isnan(surfadj))=0;
end

%%% RATHER THAN USE BEDMACHINE THICKNESS, SURFACE IS USED AND THICKNESS IS INFERRED FROM LOCATION
%%% THIS IS IN CASE OF ANY DISCREPANCIES IN DENSITY WITH BEDMACHINE FOR FLOATING ICE

thick_floatation = (- density_oce*surfadj) / (density_ice - density_oce);
thick_floatation(surfadj==0)=0;
base_floatation = surfadj - thick_floatation;
base = max(bed,base_floatation);
thick_mod = surfadj-base;
thick_mod(surfadj==0)=0;
thick = thick_mod;
gr = (bed==base);
mask(thick<0 & mask~=1) = 1;

%%%%%%%%%%%%%%%%%%%%%

thick_floatation_bm = (- density_oce*surfbm) / (density_ice - density_oce);
thick_floatation_bm(surfbm==0)=0;
base_floatation_bm = surfbm - thick_floatation_bm;
basebm = max(bed,base_floatation_bm);
thick_mod_bm = surfbm-basebm;
thick_mod_bm(surfbm==0)=0;
thick_bm = thick_mod_bm;
maskbm(thick<0 & mask~=1) = 1;

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

%mask = zeros(size(surf));
%    mask(surf>0)=2;
%    mask(maskbm==1)=1;
%    mask(surf<0)=0;
%    surf(surf<0)=0;

%%%%%%%%%%%%%%%%%%%%%%

hmask = ones(size(thick));
hmask(mask==1)=-1;
hmask(surf==0 & mask~=1)=0;
hmask([1 end],:) = -1;
hmask(:,[1 end]) = -1;
hmask(thick<10 & (hmask==1 | hmask==2))= -1;
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

%%%%%%%%%%%%%%%%%%%%%%

hmaskbm = ones(size(thick_bm));
hmaskbm(maskbm==1)=-1;
hmaskbm(surfbm==0 & maskbm~=1)=0;
hmaskbm([1 end],:) = -1;
hmaskbm(:,[1 end]) = -1;
hmaskbm(thick_bm<10 & (hmaskbm==1 | hmaskbm==2))= -1;
hmaskbm(surfbm>2000)=-1;
hmaskbm(~mask_dom)=-1;

con_mask = hmaskbm==1;
CC = bwconncomp(con_mask,4);
pp = CC.PixelIdxList;
length_pp = [];

for i=1:length(pp);
    length_pp(i) = length(pp{i});
end
[xx isort] = sort(length_pp,'descend');
if (length(pp)>1);
 for i=2:length(pp);
  for k=1:length(pp{isort(i)});
   hmaskbm(pp{isort(i)}(k)) = -1;
  end;
 end;
end;

%%%%%%%%%%%%%%%%%%%%%%

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
faketopog(~mask)=0;
singleton_mask = zeros(ny,nx);
singleton_mask(1,1) = 1;


%%%%% VFACE VELOCITY AND MASK

vfacemask = -1 * ones(ny,nx);
vfacevel = zeros(ny,nx);
vhfacevel = zeros(ny,nx);
vfacevel(2:end,:) = .5 * (vy0(1:end-1,:)+vy0(2:end,:));
%vfacevel(isnan(vfacevel)) = 0;
vhfacevel(2:end,:) = .5 * (bmthick(1:end-1,:)+bmthick(2:end,:));

mask_vel_south = zeros(ny,nx);
mask_vel_south(2:end-1,:) = (hmask(2:end-1,:)==1) & (hmask(1:end-2,:)==-1) & ~isnan(vfacevel(2:end-1,:)) & ~isnan(vhfacevel(2:end-1,:));
mask_vel_north = zeros(ny,nx);
mask_vel_north(2:end-1,:) = (hmask(2:end-1,:)==-1) & (hmask(1:end-2,:)==1) & ~isnan(vfacevel(2:end-1,:)) & ~isnan(vhfacevel(2:end-1,:));

vfacevel(isnan(vfacevel))=0;

vfacemask(mask_vel_south==1) = 4;
vfacemask(mask_vel_north==1) = 4;

%%%%% VFACE VELOCITY AND MASK

ufacemask = -1 * ones(ny,nx);
ufacevel = zeros(ny,nx);
uhfacevel = zeros(ny,nx);
ufacevel(:,2:end) = .5 * (vx0(:,1:end-1)+vx0(:,2:end));
%ufacevel(isnan(ufacevel)) = 0;
uhfacevel(:,2:end) = .5 * (bmthick(:,1:end-1)+bmthick(:,2:end));

mask_vel_west = zeros(ny,nx);
mask_vel_west(:,2:end-1) = (hmask(:,2:end-1)==1) & (hmask(:,1:end-2)==-1) & ~isnan(ufacevel(:,2:end-1)) & ~isnan(uhfacevel(:,2:end-1));
mask_vel_east = zeros(ny,nx);
mask_vel_east(:,2:end-1) = (hmask(:,2:end-1)==-1) & (hmask(:,1:end-2)==1) & ~isnan(ufacevel(:,2:end-1)) & ~isnan(uhfacevel(:,2:end-1));

ufacevel(isnan(ufacevel))=0;

ufacemask(mask_vel_west==1) = 4;
ufacemask(mask_vel_east==1) = 4;


%%%%%%%%%%%%%%

smb = [[smb zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('RACMOant.bin',smb');

bed = [[bed zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('topog.bin',bed');

faketopog = [[faketopog zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('faketopog.bin',faketopog');

thick = [[thick zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('BedMachineThick.bin',thick');
thick_bm = [[thick_bm zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('BedMachineThickRema.bin',thick_bm');

vx = [[vx zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('velobsSnapu.bin',vx');

vy = [[vy zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('velobsSnapv.bin',vy');

%verr = [[verr zeros(ny,gx)];zeros(gy,nx+gx)];
%binwrite('errU.box',verr');
verrstd = [[verrstd zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('velobsSnaperr.bin',verrstd');

ufluxdirich = [[ufacevel.*uhfacevel zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('ufluxdirich.bin',abs(ufluxdirich)');
vfluxdirich = [[vfacevel.*vhfacevel zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('vfluxdirich.bin',abs(vfluxdirich)');

ufacemask = [[ufacemask zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('ufacemask_dirich.bin',ufacemask');
vfacemask = [[vfacemask zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('vfacemask_dirich.bin',vfacemask');
ufacevel = [[ufacevel zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('ufacevel_dirich.bin',ufacevel');
vfacevel = [[vfacevel zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('vfacevel_dirich.bin',vfacevel');
uhfacevel = [[uhfacevel zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('uhfacevel_dirich.bin',uhfacevel');
vhfacevel = [[vhfacevel zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('vhfacevel_dirich.bin',vhfacevel');




binwrite('ufacemask.bin',-1*ones(nx+gx,ny+gy));
binwrite('vfacemask.bin',-1*ones(nx+gx,ny+gy));
binwrite('uext.bin',0*ones(nx+gx,ny+gy));
binwrite('vext.bin',0*ones(nx+gx,ny+gy));

%binwrite('dhdtCryo.bin',dhdt');
%binwrite('oceModelMelt.bin',shelfMelt');

Bbar = [[Bbar zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('BglenPattyn.bin',Bbar');

Bbar2 = [[Bbar2 zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('BglenPattynMask.bin',Bbar2');

sngl = [[singleton_mask zeros(ny,gx)];zeros(gy,nx+gx)];
binwrite('SingletonMask.bin',sngl');

binwrite('delX.bin',[diffx ones(1,gx)]);
binwrite('delY.bin',[diffy ones(1,gy)]);


hmask = [[hmask -1*ones(ny,gx)];-1*ones(gy,nx+gx)];
binwrite('hmask.bin',hmask');
hmaskbm = [[hmaskbm -1*ones(ny,gx)];-1*ones(gy,nx+gx)];
binwrite('hmask_bm.bin',hmaskbm');
%hmask_dirich = [[hmask_dirich -1*ones(ny,gx)];-1*ones(gy,nx+gx)];
%binwrite('hmask_dirich.bin',hmask_dirich');

