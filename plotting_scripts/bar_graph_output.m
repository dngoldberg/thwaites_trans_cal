function [vmis smis] = bar_graph_output (...
    slid, ...
    timedep, ...
    period, ...
    melt_tdep, ...
    glen_tdep, ...
    beta_tdep, ...
    smith_constr, ...
    main_constr, ...
    val_ctrl ...
    )



    expt_folder_ad = ['/home/dgoldber/network_links/geosIceOcean/dgoldber/' ...
        'archer_output/THWAITES/run_ad_'];
    expt_folder_val = ['/home/dgoldber/network_links/geosIceOcean/dgoldber/' ...
        'archer_output/THWAITES/run_val_'];

    
        ad_max = 96;
        if(strcmp(period,'gentimlong'))
            ad_max = 156;
        end

    if (strcmp(timedep,'tc'))

        expt_folder_val = [expt_folder_val slid '_' timedep '_' period '_'];
        expt_folder_val = [expt_folder_val melt_tdep num2str(glen_tdep) num2str(beta_tdep)];
        expt_folder_val = [expt_folder_val smith_constr '_'];
        expt_folder_val = [expt_folder_val main_constr '_' val_ctrl '_50'];

        expt_folder_ad = [expt_folder_ad slid '_' timedep '_' period '_'];
        expt_folder_ad = [expt_folder_ad melt_tdep num2str(glen_tdep) num2str(beta_tdep)];
        expt_folder_ad = [expt_folder_ad smith_constr '_'];
        expt_folder_ad = [expt_folder_ad main_constr '/runoptiter040'];

    else

        expt_folder_val = ['/home/dgoldber/network_links/geosIceOcean/dgoldber/' ...
        'archer_output/THWAITES/run_val_' slid '_snap_50'];
        
    end

    ind_vel = 60:12:156;
    ind_surf = [36 96 156];

    vmis = zeros(size(ind_vel));
    smis = zeros(size(ind_surf));

    load ../input_tc/temp_data.mat

    rlow = rdmds([expt_folder_val '/R_low_siinit'])';
    %rlow = rlow(1:length(y_mesh_mid),1:length(x_mesh_mid));
    
    for i=1:length(ind_vel);

        vobs = binread(['/home/dgoldber/network_links/geosIceOcean/' ...
            'dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/' ...
            'velocity_constraints/velobsMoug' appNum(ind_vel(i),10) 'v.bin'],8,260,300)';
        vobs=vobs(1:length(y_mesh_mid),1:length(x_mesh_mid));
        uobs = binread(['/home/dgoldber/network_links/geosIceOcean/' ...
            'dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/' ...
            'velocity_constraints/velobsMoug' appNum(ind_vel(i),10) 'u.bin'],8,260,300)';
        uobs=uobs(1:length(y_mesh_mid),1:length(x_mesh_mid));
        cobs = sqrt(vobs.^2+uobs.^2);
        cobs(uobs<-99990)=nan;
        
        %cobs = cobs(1:length(y_mesh_mid),1:length(x_mesh_mid));
        cobs(~mask_cost)=nan;


        if (ind_vel(i)<=ad_max & ~strcmp(timedep,'snap'));
            [q x m] = rdmds([expt_folder_ad '/land_ice'], ind_vel(i));
        else
            [q x m] = rdmds([expt_folder_val '/land_ice'], ind_vel(i));
        end
        u=q(:,:,1)';
        v=q(:,:,2)';
        v=v(1:length(y_mesh_mid),1:length(x_mesh_mid));
        u=u(1:length(y_mesh_mid),1:length(x_mesh_mid));
        c=sqrt(u.^2+v.^2);

        eval(['speed' num2str(ind_vel(i)/12+2004) '=c;']);

        c(uobs<-99990)=nan;
        
        %c=c(1:length(y_mesh_mid),1:length(x_mesh_mid));
        c(~mask_cost)=nan;
        I = ~isnan(c);
        vmis(i) = mean(abs(c(I)-cobs(I)));
    end

    filenamebase = 'CPOMSmith_surf';

    for i=1:length(ind_surf);
        sobs = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/' filenamebase appNum(ind_surf(i),10) '.bin'],8,260,300)';
        if (ind_surf(i)<=ad_max & ~strcmp(timedep,'snap'));
            [q x m] = rdmds([expt_folder_ad '/land_ice'], ind_surf(i));
        else
            [q x m] = rdmds([expt_folder_val '/land_ice'], ind_surf(i));
        end
        h = q(:,:,3)';
        b = -917/1027 * h;
        b = max(b,rlow);
        s = b + h;
        sobs = sobs(1:length(y_mesh_mid),1:length(x_mesh_mid));
        s = s(1:length(y_mesh_mid),1:length(x_mesh_mid));

        eval(['surf' num2str(ind_surf(i)/12+2004) '=s;']);

        s(sobs<-99990)=nan;
        sobs(sobs<-99990)=nan;
        sobs(~mask_cost)=nan;
        
        s(~mask_cost)=nan;
        I = ~isnan(s);
        smis(i) = mean(abs(s(I)-sobs(I)));

    end

rest = expt_folder_val;
for i=1:7
   
 [front rest] = strtok(rest,'/');
end
rest = rest(2:end)
[X Y] = meshgrid(x_mesh_mid,y_mesh_mid);
save([rest '.mat'],'speed2009','speed2010','speed2011','speed2012',...
    'speed2013','speed2014','speed2015','speed2016','speed2017',...
    'surf2007','surf2012','surf2017','X','Y')

return



