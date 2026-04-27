basedir=('/exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal');
addpath([basedir '/batch_scripts']);

do_plots=false;
do_cal_plots=false;
save_files=true;

bigConstrs={'mix','surf','vel','snap'};

morlighem_files={[basedir '/morlighem_output/output_13_2/Transient_Calibration_ForDan.mat'], ...
    [basedir '/morlighem_output/output_13_2/Transient_CalibrationSurfaceOnly_ForDan.mat'], ...
    [basedir '/morlighem_output/output_13_2/Transient_CalibrationVelocityOnly_ForDan.mat'], ...
    [basedir '/morlighem_output/output_13_2/Transient_Snapshot_ForDan.mat']};

niter=40;
fid=fopen('params_file.txt','r');
while ~feof(fid)
        line = fgetl(fid);
        if contains(line,'BigConstr');
                q=split(line,':');
                constr = strtrim(q{2});
        end
        if contains(line,'Timedep');
                q=split(line,':');
                timedep = strtrim(q{2});
        end
end
fclose(fid);
rec = find(strcmp(constr,bigConstrs));
if (strcmp(timedep,'snap'));
    rec=4;
end

[metric_vel1_st metric_vel1_gr_st metric_acc1_st metric_accrel1_st metric_surf1_st metric_dhdt1_st dvafdt_err1_st tikhbeta wgtvel wgtsurf betacost bglencost priorcost thincost velcost T_st Vaf_st Tobs1 Tobs2 Tobs0 vafobs Bglen_st Beta_st] = ...
    plot_val(do_plots, do_cal_plots, [],1);
[metric_vel2_st metric_vel2_gr_st metric_acc2_st metric_accrel2_st metric_surf2_st metric_dhdt2_st dvafdt_err2_st tikhbeta wgtvel wgtsurf betacost bglencost priorcost thincost velcost T_st Vaf_st Tobs1 Tobs2 Tobs0 vafobs Bglen_st Beta_st] = ...
    plot_val(do_plots, do_cal_plots, [],2);
if isempty(rec)
    rec=2;
end

[metric_vel1_is metric_vel1_gr_is metric_acc1_is metric_accrel1_is metric_surf1_is metric_dhdt1_is dvafdt_err1_is tikhbeta0 wgtvel0 wgtsurf0 betacost0 bglencost0 priorcost0 thincost0 velcost0 T_is Vaf_is Tobs1 Tobs2 Tobs0 vafobs Bglen_is Beta_is] = ...
    plot_val(do_plots, do_cal_plots,  morlighem_files{rec}, 1);
[metric_vel2_is metric_vel2_gr_is metric_acc2_is metric_accrel2_is metric_surf2_is metric_dhdt2_is dvafdt_err2_is tikhbeta0 wgtvel0 wgtsurf0 betacost0 bglencost0 priorcost0 thincost0 velcost0 T_is Vaf_is Tobs1 Tobs2 Tobs0 vafobs Bglen_is Beta_is] = ...
    plot_val(do_plots, do_cal_plots,  morlighem_files{rec}, 2);

if (save_files)
    [BGLEN BETA BED THICK0 SURF THICK VX VY times] = save_arrays;
end
 
%cd /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/plotting_scripts/
 
if (save_files)
    save('expout.mat','BGLEN', 'BETA', 'BED', 'THICK0', 'SURF', 'THICK', 'VX', 'VY', 'times', 'Vaf_st')
    save series.mat T_st Vaf_st Tobs1 Tobs2 Tobs0 vafobs Bglen_st Beta_st T_is Vaf_is Tobs1 Bglen_is Beta_is
    save metrics.mat metric_vel1_st metric_acc1_st metric_surf1_st metric_dhdt1_st dvafdt_err1_st ...
                     metric_vel2_st metric_acc2_st metric_surf2_st metric_dhdt2_st dvafdt_err2_st ...
		     metric_vel1_is metric_acc1_is metric_surf1_is metric_dhdt1_is dvafdt_err1_is ...
		     metric_vel2_is metric_acc2_is metric_surf2_is metric_dhdt2_is dvafdt_err2_is ...
	             tikhbeta wgtvel wgtsurf betacost bglencost priorcost thincost velcost metric_accrel1_st metric_accrel2_st  metric_accrel1_is metric_accrel2_is ...
                 metric_vel1_gr_st  metric_vel2_gr_st  ...
                 metric_vel1_gr_is  metric_vel2_gr_is
end
