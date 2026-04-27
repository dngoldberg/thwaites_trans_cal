%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_snap_50_n
%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_snapBM_50_n
%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g00NSC_mix_last_50_n
%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g00NS_mix_last_50_n
%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g00NS_surf_last_50_n
%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g00NS_vel_last_50_n
%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g00SC_mix_last_50_n
%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g00S_mix_last_50_n
%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_G00S_mix_last_50_n
%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g00S_vel_last_50_n
%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g01S_mix_last_50_n
%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g10S_mix_last_50_n
%/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentimlong_g00S_mix_last_50_n

%(base) dgoldber@stream:~/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts$ ls ../morlighem_output/ 
%Transient_Calibration_ForDan.mat	     Transient_CalibrationTransientFriction_ForDan.mat	Transient_CalibrationVelOnly_ForDan.mat
%Transient_CalibrationSurfaceOnly_ForDan.mat  Transient_CalibrationTransientMelt_ForDan.mat	Transient_Snapshot2017_ForDan.mat
%Transient_CalibrationTo2017_ForDan.mat	     Transient_CalibrationTransientRheology_ForDan.mat	Transient_Snapshot_ForDan.mat

% transient_mix
% transient_surf
% transient_vel
% snapshot
%close all
clear all
do_plots=false;
do_cal_plots=false;
save_files = true;
global niter_inv
niter_inv = 24;

addpath('/exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts');
surf_fwd_dir='run_val_coul_tc_gentim_g00S_surf_last_50_n_.2e5_.6e5';
tok = strsplit(surf_fwd_dir,'_');
gam = tok{12};
surfdir=['run_ad_coul_tc_gentim_' tok{6} '_' tok{7}];
if (length(tok) > 10);
    for i=1:(length(tok)-10);
	 surfdir = [surfdir '_' tok{i+10}];
    end
end

disp(surfdir)

experiment_names={'Mixed','Surf only','Vel only','Snapshot Cal'};
out_fold_names={'/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/TransientCalMix/',...
                '/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/TransientCalSurf/',...
                '/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/TransientCalVel/',...
                '/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/SnapshotCal/'};

morlighem_files={'../morlighem_output/output2/Transient_Calibration_ForDan.mat', ...
    '../morlighem_output/output2/Transient_CalibrationVelOnly_ForDan.mat', ...
    '../morlighem_output/output2/Transient_CalibrationSurfaceOnly_ForDan.mat', ...
    '../morlighem_output/output2/Transient_Snapshot_ForDan.mat'};

dan_folders={'/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g00S_mix_last_50_n',...
      ['/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/' surf_fwd_dir],...
	     '/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_tc_gentim_g00S_vel_last_50_n',...
	     '/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/run_val_coul_snap_50_15'};

metrics_acc_issm=zeros(4,1);
metrics_acc_streamice=zeros(4,1);
metrics_vel_issm=zeros(4,1);
metrics_vel_streamice=zeros(4,1);
metrics_surf_issm=zeros(4,1);
metrics_surf_streamice=zeros(4,1);
metrics_dhdt_issm=zeros(4,1);
metrics_dhdt_streamice=zeros(4,1);
metrics_dvaf_issm=zeros(4,1);
metrics_dvaf_streamice=zeros(4,1);

if (~strcmp(['run' '_val_coul_tc_gentim_g00S_surf_last_50_n'],surf_fwd_dir));
    ilist = 2;
else
    ilist = (1:4);
end



for i=ilist;
    eval(['!mkdir ' out_fold_names{i}]);
    eval(['cd ' dan_folders{i}]);
    !ln -s /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/plot_val.m .
    !ln -s /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/save_arrays.m .
    [metric_vel_st metric_acc_st metric_surf_st metric_dhdt_st metric_dvaf_st T_st Vaf_st Tobs1 Tobs2 Tobs0 vafobs Bglen Beta] = plot_val(do_plots, do_cal_plots, []);
    if (save_files)
        [BGLEN BETA BED THICK0 SURF THICK VX VY times] = save_arrays;
    end
    cd /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/
    if (save_files)
        save([strrep(experiment_names{i},' ','_') '.mat'],'BGLEN', 'BETA', 'BED', 'THICK0', 'SURF', 'THICK', 'VX', 'VY', 'times')
    end
    
    
     if (do_plots)
    figure(1); pause(.1); print('-dpng',[out_fold_names{i} 'dvel_misfit_validation_st'])

    close(figure(1))
    
    figure(2); pause(.1); print('-dpng',[out_fold_names{i} 'vel_misfit_calibration_st'])
    close(figure(2))
    
    figure(3); pause(.1); print('-dpng',[out_fold_names{i} 'dhdt_misfit_validation_st'])
    close(figure(3))
    figure(4); pause(.1); print('-dpng',[out_fold_names{i} 'surf_misfit_calibration_st'])
    close (figure(4))

    end
        
    [metric_vel_issm metric_acc_issm metric_surf_issm metric_dhdt_issm metric_dvaf_issm T_issm Vaf_issm Tobs1 Tobs2 Tobs0 vafobs Bglen_issm Beta_issm] = plot_val(do_plots, do_cal_plots, morlighem_files{i});
    

    Bglen(isnan(Bglen_issm))=nan;
    Beta(isnan(Beta_issm))=nan;

    Betas{i} = Beta;
    Bglens{i} = Bglen;
    
    Betas_issm{i} = Beta_issm;
    Bglens_issm{i} = Bglen_issm;
    
    
     if (do_plots)
    figure(1); pause(.1); print('-dpng',[out_fold_names{i} 'dvel_misfit_validation_issm'])
    close(figure(1))
    pause(.1)
    figure(2); pause(.1); print('-dpng',[out_fold_names{i} 'vel_misfit_calibration_issm'])
    close(figure(2))
    pause(.1)
    figure(3); pause(.1); print('-dpng',[out_fold_names{i} 'dhdt_misfit_validation_issm'])
    close(figure(3))
    pause(.1)
    figure(4); pause(.1); print('-dpng',[out_fold_names{i} 'surf_misfit_calibration_issm'])
    close(figure(4))
     end
    
    if (do_plots)
     figure(10);
     drawnow;
     pause(2);
     set(gcf,'position',[100 100 1000 800])
     print('-dpng',[out_fold_names{i} out_fold_names{i}(104:end-1) '_misfit_calibration'])
    close all
    end
    
    metrics_acc_issm(i)=metric_acc_issm;
    metrics_acc_streamice(i)=metric_acc_st;
    metrics_vel_issm(i)=metric_vel_issm;
    metrics_vel_streamice(i)=metric_vel_st;
    metrics_surf_issm(i)=metric_surf_issm;
    metrics_surf_streamice(i)=metric_surf_st;
    metrics_dhdt_issm(i)=metric_dhdt_issm;
    metrics_dhdt_streamice(i)=metric_dhdt_st;
    metrics_dvaf_issm(i)=metric_dvaf_issm;
    metrics_dvaf_streamice(i)=metric_dvaf_st;

    time_issm{i}=T_issm;
    time_st{i}=T_st;
    vaf_issm{i}=Vaf_issm;
    vaf_st{i}=Vaf_st;
end

save comparison.mat metrics_dhdt_streamice metrics_dhdt_issm metrics_surf_streamice metrics_surf_issm metrics_vel_streamice metrics_vel_issm metrics_acc_streamice metrics_acc_issm vaf_st vaf_issm time_st time_issm experiment_names Tobs1 Tobs2 Tobs0 vafobs metrics_dvaf_streamice metrics_dvaf_issm Betas Bglens Betas_issm Bglens_issm

vaf_st = vaf_st{2};

%disp(['2007 to 2012: ' num2str((vaf_st(96/3)-vaf_st(36/3))*917/1e12/5) '; 2012 to 2017: ' num2str((vaf_st(156/3)-vaf_st(96/3))*917/1e12/5) '; dvafdt end: ' num2str(diff(vaf_st(end-1:end))*917*4/1e12)]);

obj.dvafdt1=(vaf_st(96/3)-vaf_st(36/3))*917/1e12/5;
obj.dvafdt2=(vaf_st(156/3)-vaf_st(96/3))*917/1e12/5;
last_vaf = vaf_st(end-8:end);
t_temp = (0:8)/4;
p = polyfit(t_temp,last_vaf*917/1e12,1);
%obj.dvafdtfin=diff(vaf_st(end-1:end))*917*4/1e12;
obj.dvafdtfin = p(1);


[stat,str1]=system(['grep "fric smooth contr" /home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/' surfdir '/outputoptiter' appNum(niter_inv,3)]);
obj.betacost = str2num(regexp(str1, '[\d\.\+\-D]+', 'match', 'once'));

[stat,str1]=system(['grep "bglen smooth contr" /home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/' surfdir '/outputoptiter' appNum(niter_inv,3)]);
obj.glencost = str2num(regexp(str1, '[\d\.\+\-D]+', 'match', 'once'));

[stat,str1]=system(['grep "thinning contr" /home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/' surfdir '/outputoptiter' appNum(niter_inv,3)]);
obj.surfcost = str2num(regexp(str1, '[\d\.\+\-D]+', 'match', 'once'));

if (isfile('LcurveSurfBglen.mat'));
    load LcurveSurfBglen.mat
    Lcurvedata(gam)=obj;
else
    Lcurvedata = containers.Map([gam],obj)
end

save LcurveSurfBglen.mat Lcurvedata;
disp(num2str(obj.surfcost))
%disp(num2str(obj.betacost))
%disp(num2str(gam))
disp(num2str(obj.dvafdt1))
disp(num2str(obj.dvafdt2))
disp(num2str(obj.dvafdtfin))
