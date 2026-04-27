clear all
close all

cols={[0, 0.5, 0], ...
      [0.6350, 0.0780, 0.1840], ...
      [0.8500, 0.3250, 0.0980], ...
  	  [0 0 0]};

global I J

load ../input_tc/temp_data.mat
addpath('/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts')

xrange = length(x_mesh_mid);
yrange = length(y_mesh_mid);
I = 1:xrange;
J = 1:yrange;

x_mesh_mid = x_mesh_mid * 1e-3;
y_mesh_mid = y_mesh_mid * 1e-3;
ylims = [-600 -200]
xlims = [x_mesh_mid(1) -1250]

t1=2004;
t2_thick=2063;
t3_thick=2067;
t2_vel=2020;

% thinning constraints

nx = length(x_mesh_mid)
ny = length(y_mesh_mid)

mainfolder='/exports/geos.ed.ac.uk/iceocean/dgoldber/archer_output/THWAITES/MAINRUNS/'

expcodes={'snap','tc_vel','tc_mix','tc_surf'};
expcodes = expcodes([3 4 2 1]);

for i=1:4;
    code=expcodes{i};
    s=dir([mainfolder 'run_val_coul_' code '*']);
    dan_folders{i}=[mainfolder s(1).name];
end

rlow=bed(1:length(y_mesh_mid),1:length(x_mesh_mid));
        maskbm=maskbm(1:length(y_mesh_mid),1:length(x_mesh_mid));
        rlow(~mask_cost)=nan;
        maskbm(~mask_cost)=nan;

        set(gca,'FontWeight','bold','FontSize',14)

        pcolor(x_mesh_mid,y_mesh_mid,rlow); shading flat; hold on
        caxis([-1100 -500]); 
        set(gca,'FontSize',16,'fontweight','bold')
        xticks([-1600 -1500 -1400 -1300])
        yticks([-500:100:-300])
        
            ylabel('y (km)')
	
        colormap default
        
	grid on
 eval(['cd ' dan_folders{i}]);   
[h1d h2d haf0 haf1d haf2d u1d u2d v1d v2d]= plot_expt(t1, t2_thick, []);
haf0(~mask_cost)=nan;
hold on; contour(x_mesh_mid,y_mesh_mid,haf0,[.5 .5],'color',.5*ones(1,3),'linewidth',3); 

cd /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/batch_scripts/
h=colorbar;
xlabel('x (km)')
title(h,'m')
ylim([-600 -200])
addpath('../grl_manu_figures/')
ellipse_line(-1478, -480, 75, 20, -10);
hold off
print -dpng bathy.png




