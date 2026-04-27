function plot_expts(t1,t2)

global I J

addpath('/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts')
load /home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/temp_data
xrange = length(x_mesh_mid);
yrange = length(y_mesh_mid);
I = 1:xrange;
J = 1:yrange;

experiment_names={'Transient Cal: Mix','Transient Cal: Surf only','Transient Cal: Vel only','Snapshot Cal'};
out_fold_names={'/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/TransientCalMix/',...
                '/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/TransientCalSurf/',...
                '/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/TransientCalVel/',...
                '/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/SnapshotCal/'};


morlighem_files={'/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal//morlighem_output/Transient_Calibration_ForDan.mat', ...
    '/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal//morlighem_output/Transient_CalibrationSurfaceOnly_ForDan.mat', ...
    '/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal//morlighem_output/Transient_CalibrationVelOnly_ForDan.mat', ...
    '/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal//morlighem_output/Transient_Snapshot_ForDan.mat'};

dan_folders={'/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g00S_mix_last_50',...
	     '/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g00S_surf_last_50',...
	     '/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g00S_vel_last_50',...
	     '/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_snap_50_15'};

s0 = binread('/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/full_CPOMSmith_surf0000000036.bin',8,260,300)';
s1 = binread('/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/full_CPOMSmith_surf0000000156.bin',8,260,300)';
u0 = binread('/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug0000000108u.bin',8,260,300)';
v0 = binread('/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug0000000108u.bin',8,260,300)';
u1 = binread('/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug0000000156u.bin',8,260,300)';
v1 = binread('/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug0000000156u.bin',8,260,300)';
rlow = binread('/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/topog.bin',8,260,300)';
rlow = rlow(1:length(y_mesh_mid),1:length(x_mesh_mid));
c0 = sqrt(u0.^2+v0.^2);
c1 = sqrt(u1.^2+v1.^2);
dc = c1-c0; dc(u0==-999999 | v0==-999999 | v1==-999999 | u1==-999999) = nan;
ds = s1-s0; ds(s1==-999999 | s0==-999999)=nan; ds = ds/2;
ds = ds(1:length(y_mesh_mid),1:length(x_mesh_mid));
dc = dc(1:length(y_mesh_mid),1:length(x_mesh_mid));

figure(5)
rlow=rlow(1:length(y_mesh_mid),1:length(x_mesh_mid));
rlow(~mask_cost)=nan;
pcolor(x_mesh_mid/1e3,y_mesh_mid/1e3,rlow); shading flat; colorbar; caxis([-1500 -500]); 
colormap default

close(figure(6))
close(figure(7))

% figure(6)
% rlow=rlow(1:length(y_mesh_mid),1:length(x_mesh_mid));
% rlow(~mask_cost)=nan;
% pcolor(x_mesh_mid/1e3,y_mesh_mid/1e3,rlow); shading flat; colorbar; caxis([-1500 -500]); 
% colormap default
 


%cols={'k','m','b','g'};
load flow.mat

dx=diff(xflow);
dy=diff(yflow);
dlen = sqrt(dx.^2+dy.^2);
len = [0; cumsum(dlen)];
%cols=[];
is = [4 1 2 3];
for i=is;
    eval(['cd ' dan_folders{i}]);
    !ln -s /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/plot_expt.m .
    [h1d h2d haf0d haf1d haf2d u1d u2d v1d v2d]= plot_expt(t1, t2, []);
    [h1m h2m haf0m haf1m haf2m u1m u2m v1m v2m]= plot_expt(t1, t2, morlighem_files{i});
    cd /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/

    
    h1d(~mask_cost)=nan;
    h2d(~mask_cost)=nan;
    haf1d(~mask_cost)=nan;
    haf2d(~mask_cost)=nan;
    haf0d(~mask_cost)=nan;

    h1m(~mask_cost)=nan;
    h2m(~mask_cost)=nan;
    haf1m(~mask_cost)=nan;
    haf2m(~mask_cost)=nan;

    u1d(~mask_cost)=nan;
    u2d(~mask_cost)=nan;
    v1d(~mask_cost)=nan;
    v2d(~mask_cost)=nan;
    
    c1d=sqrt(u1d.^2+v1d.^2);
    c2d=sqrt(u2d.^2+v2d.^2);

    c1m=sqrt(u1m.^2+v1m.^2);
    c2m=sqrt(u2m.^2+v2m.^2);

    u1m(~mask_cost)=nan;
    u2m(~mask_cost)=nan;
    v1m(~mask_cost)=nan;
    v2m(~mask_cost)=nan;

    c1dflow = interp2(x_mesh_mid,y_mesh_mid,c1d,xflow,yflow);
    c1mflow = interp2(x_mesh_mid,y_mesh_mid,c1m,xflow,yflow);
    c2dflow = interp2(x_mesh_mid,y_mesh_mid,c2d,xflow,yflow);
    c2mflow = interp2(x_mesh_mid,y_mesh_mid,c2m,xflow,yflow);

    h1dflow = interp2(x_mesh_mid,y_mesh_mid,h1d,xflow,yflow);
    h1mflow = interp2(x_mesh_mid,y_mesh_mid,h1m,xflow,yflow);
    h2dflow = interp2(x_mesh_mid,y_mesh_mid,h2d,xflow,yflow);
    h2mflow = interp2(x_mesh_mid,y_mesh_mid,h2m,xflow,yflow);




    figure(10);
    [c h] = contour(x_mesh_mid/1e3,y_mesh_mid/1e3,(h2d-h1d)/(t2-t1)<-5);
    delete(figure(10))
    haf0=interp2(x_mesh_mid/1e3,y_mesh_mid/1e3,haf1d,c(1,:),c(2,:));
    I0=(haf0>100);

    figure(5);
    if(i==2)
    hold on; contour(x_mesh_mid/1e3,y_mesh_mid/1e3,haf0d,[.5 .5],'k','linewidth',3); hold off
    end

    
    figure(5)
    hold on
    load cols
    h=scatter(c(1,I0),c(2,I0),'markeredgecolor',cols{i}, 'marker','.');
    %cols{i}=h.CData
    hold off

    %figure; contour(x_mesh_mid/1e3,y_mesh_mid/1e3,(c2d-c1d)/(t2-t1));

    figure(6)
    subplot(2,1,1)
     
    plot(len/1e3,(h2dflow-h1dflow)/(t2-t1),'color',cols{i},'linewidth',2); 
    hold on;
    ylim([-5 2])
    subplot(2,1,2)
     
    plot(len/1e3,(c2dflow-c1dflow)/(t2-t1),'color',cols{i},'linewidth',2); 
    hold on
    ylim([-1 10])
    figure(7)
    subplot(2,1,1)
     
    semilogy(len/1e3,h2mflow-h1mflow,'color',cols{i},'linewidth',2); 
    hold on
    subplot(2,1,2)
     
    semilogy(len/1e3,c2mflow-c1mflow,'color',cols{i},'linewidth',2); 
    hold on

    if (true)
        figure(i)
        subplot(2,2,1)
    
        lev = (t2-t1) * 8;
    
        pcolor(x_mesh_mid/1e3,y_mesh_mid/1e3,h2d-h1d); shading flat; colorbar; colormap jet; caxis([-lev lev]);
        colorbar
        hold on
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,haf2d>0,[.5 .5],'m','LineWidth',2);
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,haf1d>0,[.5 .5],'k','LineWidth',2);
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,haf0d>0,[.5 .5],'k--','LineWidth',2);
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,ds<-5,[.5 .5],'color',[171 104 87]./255,'LineWidth',2);
        %contour(x_mesh_mid/1e3,y_mesh_mid/1e3,rlow,[-900 -900],'color',[0 .5 .0],'LineWidth',2);
        %contour(x_mesh_mid/1e3,y_mesh_mid/1e3,rlow,[-1000 -1000],'color',[0 1 .0],'LineWidth',3);
        
        figure(i)
    
        hold off
        title('streamice dthick')
        axis equal; axis tight; ylim([-580 -230])
        colormap redblue
        
    
        subplot(2,2,2)
        pcolor(x_mesh_mid/1e3,y_mesh_mid/1e3,h2m-h1m); shading flat; colorbar; colormap jet; caxis([-lev lev]);
        colorbar
        hold on
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,haf2m>0,[.5 .5],'m','LineWidth',2);
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,haf1m>0,[.5 .5],'k','LineWidth',2);
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,haf0m>0,[.5 .5],'k--','LineWidth',2);
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,ds<-5,[.5 .5],'color',[171 104 87]./255,'LineWidth',2);
        %contour(x_mesh_mid/1e3,y_mesh_mid/1e3,rlow,[-900 -900],'color',[0 .5 .0],'LineWidth',3);
        hold off
        title('issm dthick')
        axis equal; axis tight; ylim([-580 -230])
        colormap redblue
    
        subplot(2,2,3)
    
        lev = (t2-t1) * 20;
    
        pcolor(x_mesh_mid/1e3,y_mesh_mid/1e3,c2d-c1d); shading flat; colorbar; colormap jet; caxis([-lev lev]);
        colorbar
        hold on
        
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,ds<-5,[.5 .5],'color',[171 104 87]./255,'LineWidth',2);
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,ds<-7.5,[.5 .5],'m','LineWidth',2);
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,ds<-7.5,[.5 .5],'m','LineWidth',2);
        %contour(x_mesh_mid/1e3,y_mesh_mid/1e3,dc<30,[.5 .5],'color',[0 .5 0],'LineWidth',2);
        %contour(x_mesh_mid/1e3,y_mesh_mid/1e3,haf2d>0,[.5 .5],'k','LineWidth',2);
        %contour(x_mesh_mid/1e3,y_mesh_mid/1e3,haf1d>0,[.5 .5],'m','LineWidth',2);
        hold off
        title('streamice dvel')
        axis equal; axis tight; ylim([-580 -230])
        colormap redblue
    
        subplot(2,2,4)
    
        pcolor(x_mesh_mid/1e3,y_mesh_mid/1e3,c2m-c1m); shading flat; colorbar; colormap jet; caxis([-lev lev]);
        colorbar
        hold on
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,ds<-5,[.5 .5],'color',[171 104 87]./255,'LineWidth',2);
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,ds<-7.5,[.5 .5],'m','LineWidth',2);
        contour(x_mesh_mid/1e3,y_mesh_mid/1e3,ds<-7.5,[.5 .5],'m','LineWidth',2);
        %contour(x_mesh_mid/1e3,y_mesh_mid/1e3,dc<30,[.5 .5],'color',[0 .5 0],'LineWidth',2);
        %contour(x_mesh_mid/1e3,y_mesh_mid/1e3,ds<-5,[.5 .5],'k','LineWidth',2);
        %contour(x_mesh_mid/1e3,y_mesh_mid/1e3,ds<-7.5,[.5 .5],'m','LineWidth',2);
        colormap redblue
    
        %contour(x_mesh_mid/1e3,y_mesh_mid/1e3,haf2m>0,[.5 .5],'k','LineWidth',2);
        %contour(x_mesh_mid/1e3,y_mesh_mid/1e3,haf1m>0,[.5 .5],'m','LineWidth',2);
        hold off
        title('issm dvel')
        axis equal; axis tight; ylim([-580 -230])
        
    
        sgtitle([experiment_names{i} ' ' num2str(t1) '-' num2str(t2) ' diff'])
    end
end;
for k=5:7;
    figure(k);
legend(experiment_names{is(1)},...
       experiment_names{is(2)},...
       experiment_names{is(3)},...
       experiment_names{is(4)});

figure(6); 
subplot(2,1,1); hold off
subplot(2,1,2); hold off
figure(7); 
subplot(2,1,1); hold off
subplot(2,1,2); hold off



end