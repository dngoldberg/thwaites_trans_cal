clear all
%close all

rgb = [ ...
    94    79   162
    50   136   189
   102   194   165
   171   221   164
   230   245   152
   255   255   191
   254   224   139
   253   174    97
   244   109    67
   213    62    79
   158     1    66  ] / 255;


rgb

global I J

load ../input_tc/temp_data.mat
addpath('/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/batch_scripts')
experiment_names={'Mixed','Surf only','Vel only','Snapshot Cal'};

xrange = length(x_mesh_mid);
yrange = length(y_mesh_mid);
I = 1:xrange;
J = 1:yrange;

x_mesh_mid = x_mesh_mid * 1e-3;
y_mesh_mid = y_mesh_mid * 1e-3;
ylims = [-600 -200];
xlims = [x_mesh_mid(1) -1250];


rlow=bed(1:length(y_mesh_mid),1:length(x_mesh_mid));
        maskbm=maskbm(1:length(y_mesh_mid),1:length(x_mesh_mid));
        rlow(~mask_cost)=nan;
        maskbm(~mask_cost)=nan;

mainfolder='/exports/geos.ed.ac.uk/iceocean/dgoldber/archer_output/THWAITES/MAINRUNS/'

expcodes={'snap','tc_vel','tc_mix','tc_surf'};
expcodes = expcodes([3 4 2 1]);

for i=1:4;
    code=expcodes{i};
    s=dir([mainfolder 'run_val_coul_' code '*']);
    dan_folders{i}=[mainfolder s(1).name];
end

eval(['cd ' dan_folders{1}]);
!ln -s /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/batch_scripts/plot_expt.m .
[h1d h2d haf0d haf1d haf2d u1d u2d v1d v2d]= plot_expt(2004, 2030, []);
cd /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/grl_manu_figures/
haf0d(~mask_cost)=nan;
bed(~mask_cost)=nan;

surf_expt_index =  find(strcmp(experiment_names,'Surf only'));      
vel_expt_index =  find(strcmp(experiment_names,'Vel only'));
snap_expt_index =  find(strcmp(experiment_names,'Snapshot Cal'));


load([dan_folders{surf_expt_index} '/series.mat']);

Beta_st(~mask_cost)=nan;
Bglen_st(~mask_cost)=nan;

beta_surf_d = Beta_st;
beta_surf_m = Beta_is; %sqrt((Beta_is / (31536000)^(1/6)) );
bglen_surf_d = Bglen_st;
bglen_surf_m = Bglen_is;

load([dan_folders{vel_expt_index} '/series.mat']);

Beta_st(~mask_cost)=nan;
Bglen_st(~mask_cost)=nan;

beta_vel_d = Beta_st;
beta_vel_m = Beta_is; % sqrt((Beta_is / (31536000)^(1/6))) ;
bglen_vel_d = Bglen_st;
bglen_vel_m = Bglen_is;

load([dan_folders{snap_expt_index} '/series.mat']);

Beta_st(~mask_cost)=nan;
Bglen_st(~mask_cost)=nan;

beta_snap_d = Beta_st;
beta_snap_m = Beta_is; % sqrt((Beta_is / (31536000)^(1/6))) ;
bglen_snap_d = Bglen_st;
bglen_snap_m = Bglen_is;

beta_vel_d(h1d==0 | beta_vel_d==0)=nan;
bglen_vel_d(h1d==0 | bglen_vel_d==0)=nan;
beta_surf_d(h1d==0 | beta_surf_d==0)=nan;
bglen_surf_d(h1d==0 | bglen_surf_d==0)=nan;
beta_snap_d(h1d==0 | beta_snap_d==0 | haf0d<0)=nan;
bglen_snap_d(h1d==0 | bglen_snap_d==0)=nan;


beta_vel_m(h1d==0 | beta_vel_m==0)=nan;
bglen_vel_m(h1d==0 | bglen_vel_m==0)=nan;
beta_surf_m(h1d==0 | beta_surf_m==0)=nan;
bglen_surf_m(h1d==0 | bglen_surf_m==0)=nan;
beta_snap_m(h1d==0 | beta_snap_m==0 | haf0d<0)=nan;
bglen_snap_m(h1d==0 | bglen_snap_m==0)=nan;





% beta_vel_d(isnan(h1d))=0;
% beta_surf_d(isnan(h1d))=0;
% bglen_vel_d(isnan(h1d))=0;
% bglen_surf_d(isnan(h1d))=0;
% beta_vel_m(isnan(h1d))=0;
% beta_surf_m(isnan(h1d))=0;
% bglen_vel_m(isnan(h1d))=0;
% bglen_surf_m(isnan(h1d))=0;

%beta_surf_m((beta_surf_m-beta_vel_m)>100)=beta_vel_m((beta_surf_m-beta_vel_m)>100);


figure(5)
set(gcf,'Position',[100 100 640 400])

params={'beta','bglen'};
models={'d','m'}
constr={'surf','vel'}

unit={'Pa^{1/2} (m/a)^{-1/6}','Pa a^{1/3}'}

for j=1:2;
    
    if (j==1)
    lev = 10000;
    else
        lev=100000;
    end

    for k=1:2

        

        subplot(2,2,(j-1)*2+k)
        eval(['pcolor(x_mesh_mid,y_mesh_mid,abs(' params{1} '_' constr{j} '_' models{k} ').^1-abs(' params{1} '_snap_' models{k} ').^1);']); shading flat

        %subplot(2,2,(j-1)*2+k+2)
        %eval(['pcolor(x_mesh_mid,y_mesh_mid,abs(' params{1} '_vel_' models{k} ').^1-abs(' params{1} '_snap_' models{k} ').^1);']);

        %eval(['pcolor(x_mesh_mid,y_mesh_mid,' params{j} '_' constr{k} '_' models{2} '.^2-' params{j} '_' constr{k} '_' models{1} '.^2);']);

        shading flat;
        grid on
        
        
        %colormap redblue; 
        
        lims=get(gca,'clim');
        lev=1.5e3;
        caxis([-lev/10 lev/10])
        %if (k==2)
%            h(j)=colorbar('eastoutside')
        %end


        colormap redblue;

        if (j==1 & k==1)
            h1 = colorbar('southoutside')
            ylabel(h1,unit{2})
            pos = get(h1,'Position')
            set(h1,'Position',[pos(1)+.22 pos(2)-.175 pos(3) pos(4)],'fontsize',12)
            freezeColors(h1)
%         elseif (j==2)
%             h(k)=colorbar('southoutside')
%             ylabel(h(k),unit{j})
%             pos = get(h(k),'Position')
%             set(h(k),'Position',[pos(1)+.05 pos(2)-.07 .7*pos(3) pos(4)])
         end
            
        

        %h(2*(j-1)+k)=colorbar;
        %ylabel(h,unit{j})
        
        
        hold on
        %contour(x_mesh_mid,y_mesh_mid,rlow,[-800 -800],'k','LineWidth',1)
        %contour(x_mesh_mid,y_mesh_mid,rlow,[-1000 -1000],'b','LineWidth',1)
        contour(x_mesh_mid,y_mesh_mid,haf0d,[.5 .5],'color',.5*[1 1 1],'LineWidth',1)
        contour(x_mesh_mid,y_mesh_mid,mask_cost,[.5 .5],'color','k','LineWidth',1)
        %contour(x_mesh_mid,y_mesh_mid,bed,[-1100 -1100],'k','LineWidth',1)

        ellipse_line(-1478, -480, 75, 20, -10);

        hold off
        axis equal; axis tight; 
        ylim(ylims)
        xlim(xlims)

        
        
    end


end


xshift = 0;
yshift = 0;

% uncomment below
%freezeColors(colorbar); delete(colorbar)
set(gcf,'Position',[100 100 650 900])
for i=1:4;

    subplot(2,2,i)
    grid on
    xticks([-1600 -1500 -1400 -1300])
    yticks([-500:100:-300])
    set(gca,'fontsize',12,'FontWeight','bold')
    if (i>0)
        xticklabels({'-1600','','-1400',''})
        xlabel('x (km)');
    else
        xticklabels({'','','',''})
    end
    ax=gca
    if (mod(i,2)==0)
        yticklabels({'','',''})
    else
        ylabel('y (km)')
    end
end
chars='abcdef'
for i=1:4
      subplot(2,2,i)
      drawnow
      pause(.01)
    ishift = 1-mod(i,2);
    jshift = 1;

    pos = get(gca,'position');
    if (i==1)
        posa=pos;
    end
        set(gca,'position',pos+[xshift*ishift jshift*yshift 0 0])
    
    text(-1620,-270,['(' chars(i) ')'],'fontsize',12,'fontweight','bold')
end    
ylabel(h1,unit{1})

annotation('textbox', [.22, .9, 0, 0], 'string', 'STREAMICE','fontsize',12,'fontweight','bold')
annotation('textbox', [.68, .9, 0, 0], 'string', 'ISSM','fontsize',12,'fontweight','bold')

print -dpng fig4.png
