function [metric_vel metric_acc metric_surf metric_dhdt T Vaf Tobs1 Tobs2 Tobs0 vafobs] = plot_val(do_plot, do_cal_plot, morlighem_mat_file)
addpath('/home/dgoldber/network_links/datastore/ice_data/ThwaitesDataProphet/CODE');

global rlow I J

%close all

if (exist(morlighem_mat_file))
    read_issm = true
else
    read_issm = false
end

if (~read_issm)

    rlow=rdmds(['R_low_siinit'])';
    folder = pwd();
    rest = folder;
    while (length(rest)>1);
        [front rest] = strtok(rest,'/');
    end
    folder = front;

    isRema = false;
    folder_start=96;

    parts = split(folder,'_');
    if (strcmp(parts{4},'snap'));
        ad_folder=[];
        folder_start = 0;
    elseif (strcmp(parts{4},'snapBM'));
        ad_folder=[];
        isRema=true;
        folder_start = 0;
    else
        ad_folder=['run_ad_' parts{3} '_' parts{4} '_' parts{5} '_' parts{6} '_' parts{7}];
        if (strcmp(parts{5},'gentimlong'));
            folder_start = 156;
        end
    end

end

if (isempty(ad_folder))
    h0 = rdmds('H_streamiceinit')';
else
    h0 = rdmds(['../' ad_folder '/runoptiter040/H_streamiceinit'])';
end


metric_vel = 0;
metric_dhdt = 0;
metric_surf = 0;
metric_acc = 0;

nitervel=[108 120 132 144 156];% 162 180 198 216 234];
%nitervel=[];% 162 180 198 216 234];
nitersurf=[156];% 234];


strgrep = evalc('!grep niter0 STDOUT.0000');
niter0 = str2num(strgrep(end-2:end-1));
if (isempty(niter0))
 niter0 = str2num(strgrep(end-1));
end

%grd = get_record(isRema,ad_folder,folder_start,1,5,read_issm);


load /home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/temp_data
xrange = length(x_mesh_mid);
yrange = length(y_mesh_mid);
I = 1:xrange;
J = 1:yrange;
rlow = rlow(J,I);
[X Y]=meshgrid(x_mesh_mid,y_mesh_mid);
mask0 = interpBedmachineAntarctica(X,Y,'mask');


if (length(nitervel)>0 & do_plot);
	h1 = figure;
	h2 = figure;
end

if (do_cal_plot);
	h4=figure;
	i=96;
	vobs1 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(i,10) 'v.bin'],8,260,300)';
        uobs1 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(i,10) 'u.bin'],8,260,300)';
	uobs1(uobs1==-999999 | uobs1==0)=nan;
        cobs1 = sqrt(uobs1(J,I).^2+vobs1(J,I).^2);
        u1 = get_record(isRema,ad_folder,folder_start,96,1,read_issm); 
        v1 = get_record(isRema,ad_folder,folder_start,96,2,read_issm); 
	c1 = sqrt(u1.^2+v1.^2);
	figure(h4);
	pcolor(x_mesh_mid/1e3,y_mesh_mid/1e3,c1-cobs1); shading flat;  axis equal; axis tight; colormap redblue;
	set(gca,'fontsize',14,'fontweight','bold');
	ylim([-600 -200]);
	h=colorbar; title(h,'m/a');
	xlabel('x (km)');
	ylabel('y (km)');
load /home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/bounds1
        hold on
	caxis([-1e3 1e3])
	plot([x; x(1)]/1e3,[y; y(1)]/1e3,'k','linewidth',2)
end

mis_full=[];
mis_speed_full=[];


for i = 1:length(nitervel)-1;
    
    %if (~isRema)
     n1 = nitervel(i);
     n2 = nitervel(i+1);
    %else
    % n1 = nitervel(i)-96;
    % n2 = nitervel(i+1)-96;
    %end
    
    vobs1 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(nitervel(i),10) 'v.bin'],8,260,300)';
    uobs1 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(nitervel(i),10) 'u.bin'],8,260,300)';
    uobs1(uobs1==-999999 | uobs1==0)=nan;
    cobs1 = sqrt(uobs1(J,I).^2+vobs1(J,I).^2);

    vobs2 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(nitervel(i+1),10) 'v.bin'],8,260,300)';
    uobs2 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(nitervel(i+1),10) 'u.bin'],8,260,300)';
    uobs2(uobs2==-999999 | uobs2==0)=nan;
    cobs2 = sqrt(uobs2(J,I).^2+vobs2(J,I).^2);

    dc_obs = cobs2-cobs1;





    u1 = get_record(isRema,ad_folder,folder_start,n1,1,read_issm); 
    u2 = get_record(isRema,ad_folder,folder_start,n2,1,read_issm); 
    v1 = get_record(isRema,ad_folder,folder_start,n1,2,read_issm); 
    v2 = get_record(isRema,ad_folder,folder_start,n2,2,read_issm); 
    th2 = get_record(isRema,ad_folder,folder_start,n2,3,read_issm); 
    th1 = get_record(isRema,ad_folder,folder_start,n1,3,read_issm); 
    

    mask1=get_record(isRema,ad_folder,folder_start,n1,4,read_issm); 
    mask2=get_record(isRema,ad_folder,folder_start,n2,4,read_issm); 

    haf2 = th2;
    haf2(rlow<0)=haf2(rlow<0)+1027/917*rlow(rlow<0);
    f2 = (haf2>0);
    haf1 = th1;
    haf1(rlow<0)=haf1(rlow<0)+1027/917*rlow(rlow<0);
    f1 = (haf1>0);
    
    

%     u1=q(I,J,1,1)';
%     v1=q(I,J,2,1)';
%     u2=q(I,J,1,2)';
%     v2=q(I,J,2,2)';
    c1 = sqrt(u1.^2+v1.^2);
    c2 = sqrt(u2.^2+v2.^2);
    c1(mask1~=1)=nan;
    c2(mask2~=1)=nan;
    dc = c2 - c1;
    %c1(~f1)=nan;
    %c2(~f2)=nan;

    mis_speed = (c2-cobs2).^2;
    
    mis = (dc-dc_obs).^2;

    %if (i>1)
    mis_full = [mis_full mis(~isnan(mis))'];
    %end
    mis_speed_full = [mis_speed_full mis_speed(~isnan(mis_speed))'];

    
    if (do_plot)
    figure(h1); subplot(ceil((length(nitervel)-1)/2),2,i);
    pcolor(x_mesh_mid,y_mesh_mid,dc_obs(J,I)); shading flat;  axis equal; axis tight;
    colormap parula;
    figure(h2); subplot(ceil((length(nitervel)-1)/2),2,i);
    pcolor(x_mesh_mid,y_mesh_mid,dc-dc_obs(J,I)); shading flat; colorbar; caxis([-1500 1500]); axis equal; axis tight;
    hold on
    %h=q(I,J,3,2)';
    hmask=mask2;
    contour(x_mesh_mid,y_mesh_mid,hmask==1,[.5 .5],'k','linewidth',2);
    title(num2str(2004 + nitervel(i)/12))
    hold off
    colormap redblue; 
     end
end


metric_vel = sqrt(mean(mis_speed_full));
metric_acc = sqrt(mean(mis_full));


if (do_plot)
figure(h2)
print('-dpng',['../validation_plots/' folder '.png'])
end

if (do_plot)
h3 = figure;
end
%sm=false

%if (sm)k
% filenamebase = 'CPOMSmith_surf';
%else
filenamebase = 'CPOMSmith_surf';
sobs36 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/' filenamebase appNum(36,10) '.bin'],8,260,300)';
sobs156 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/' filenamebase appNum(156,10) '.bin'],8,260,300)';
sobs96 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/' filenamebase appNum(96,10) '.bin'],8,260,300)';
serr36 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/' filenamebase appNum(36,10) 'err.bin'],8,260,300)';
serr96 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/' filenamebase appNum(96,10) 'err.bin'],8,260,300)';
serr156 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/' filenamebase appNum(156,10) 'err.bin'],8,260,300)';
sobs156(sobs156==-999999)=nan;
sobs96(sobs96==-999999)=nan;
sobs36(sobs36==-999999)=nan;
sobs156=sobs156(J,I);
serr156=serr156(J,I);
sobs96=sobs96(J,I);
sobs36=sobs36(J,I);
sobs156(~mask_cost)=nan;
serr96=serr96(J,I);
serr36=serr36(J,I);

dhdt_obs = (sobs156-sobs96)/5;
dhdt_obs(dhdt_obs>0) = nan;
dhdt_obs0 = (sobs96-sobs36)/5;
dhdt_obs0(dhdt_obs0>0) = nan;


inds=[36 96 156];
for i=1:3;
 ind = num2str(inds(i));
 eval(['hmask' ind '=get_record(isRema,ad_folder,folder_start,' ind ',4,read_issm);']);
 eval(['h' ind '=get_record(isRema,ad_folder,folder_start,' ind ',3,read_issm);']);
% eval(['hmask' ind '=hmask' ind '(J,I);']);
% eval(['h' ind '=h' ind '(J,I);']);
 eval(['haf' ind '=h' ind ';']);
 eval(['haf' ind '(rlow<0)=haf' ind '(rlow<0)+1027/917*rlow(rlow<0);']); 
 eval(['haf' ind '(haf' ind '<0)=0;']);  
 eval(['b' ind '=max(rlow,-917/1027*h' ind ');']);
 eval(['s' ind '=b' ind '+h' ind ';']); 
end



dhdt156=(h156-h96)/5;
dhdt156(haf156<0)=nan;
dhdt156(hmask156~=1)=nan;
dhdt156(isnan(sobs156))=nan;
dhdt156(serr156~=1)=nan;

dhdt96=(h96-h36)/5;
dhdt96(haf96<0)=nan;
dhdt96(hmask96~=1)=nan;
dhdt96(isnan(sobs96))=nan;
dhdt96(serr96~=1)=nan;

mis_dhdt = (dhdt156 - dhdt_obs).^2;
metric_dhdt = sqrt(mean(mis_dhdt(~isnan(mis_dhdt))));

mis_surf = (s156 - sobs156).^2;
mis_surf(hmask156~=1)=nan;
mis_surf(isnan(sobs156))=nan;
mis_surf(serr156~=1)=nan;
metric_surf = sqrt(mean(mis_surf(~isnan(mis_surf))));

mis = (dhdt96-dhdt_obs0); 
mis(hmask156~=1)=nan; 
mis(isnan(dhdt_obs))=nan; 
mis(serr156<1)=nan;
% metric_surf = sqrt(mean(mis(~isnan(mis.^2))));

if (do_cal_plot)
    h5 = figure;
    sdiff = s96-sobs96;
    sdiff(haf96<=0)=nan;
    pcolor(x_mesh_mid/1e3,y_mesh_mid/1e3,sdiff); shading flat;  axis equal; axis tight; colormap redblue;
        set(gca,'fontsize',14,'fontweight','bold');
        ylim([-600 -200]);
        h=colorbar; title(h,'m');
        xlabel('x (km)');
        ylabel('y (km)');
load /home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/bounds1
        hold on
        caxis([-40 40])
        plot([x; x(1)]/1e3,[y; y(1)]/1e3,'k','linewidth',2)
end;

close(figure(h2))
close(figure(h1))

if (do_plot)
    figure(h3)
    

    subplot(2,2,1);
    pcolor(x_mesh_mid/1e3,y_mesh_mid/1e3,(-dhdt96)); shading flat; colorbar; caxis([0 5]); colormap redblue; axis equal; axis tight
    h=colorbar; ylabel(h,'meters')
    ylim([-5.8 -2.2]*1e2)
    hold on
    contour(x_mesh_mid/1e3,y_mesh_mid/1e3,mask0==3,[.5 .5],'k','linewidth',2);
    hold off

    subplot(2,2,2);
    pcolor(x_mesh_mid/1e3,y_mesh_mid/1e3,(dhdt156)); shading flat; colorbar; caxis([-10 10]); colormap redblue; axis equal; axis tight
    h=colorbar; ylabel(h,'meters')
    ylim([-5.8 -2.2]*1e2)
    hold on
    contour(x_mesh_mid/1e3,y_mesh_mid/1e3,mask_cost,[.5 .5],'k','linewidth',2);
    hold off

    subplot(2,2,3);
    pcolor(x_mesh_mid/1e3,y_mesh_mid/1e3,(-dhdt_obs0)); shading flat; colorbar; caxis([0 5]); colormap redblue; axis equal; axis tight
    h=colorbar; ylabel(h,'meters')
    ylim([-5.8 -2.2]*1e2)
    hold on
    contour(x_mesh_mid/1e3,y_mesh_mid/1e3,mask0==3,[.5 .5],'k','linewidth',2);
    hold off

    subplot(2,2,4);
    pcolor(x_mesh_mid/1e3,y_mesh_mid/1e3,(mis)); shading flat; colorbar; caxis([-4 4]); colormap default; axis equal; axis tight
    h=colorbar; ylabel(h,'meters')
    ylim([-5.8 -2.2]*1e2)
    hold on
    contour(x_mesh_mid/1e3,y_mesh_mid/1e3,mask0==3,[.5 .5],'k','linewidth',2);
    hold off

    



end


filenamebase = 'full_CPOM_surf';
sobs36 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/' filenamebase appNum(36,10) '.bin'],8,260,300)';
sobs156 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/' filenamebase appNum(156,10) '.bin'],8,260,300)';
sobs96 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/' filenamebase appNum(96,10) '.bin'],8,260,300)';
sobs156(sobs156==-999999)=nan;
sobs96(sobs96==-999999)=nan;
sobs36(sobs36==-999999)=nan;
sobs156=sobs156(J,I);
sobs96=sobs96(J,I);
sobs36=sobs36(J,I);
sobs156(~mask_cost)=nan;
vafmask=(~isnan(sobs156) & serr156==1.);
Vaf = zeros(756/12,1);
T = zeros(756/12,1);
rlow=rdmds(['R_low_siinit'])';
rlow = rlow(J,I);
Vaf(:) = nan;
for i = 3:3:756;
    i
    T(round(i/3)) = i/12;
    if (~isRema | i>96);
        if (i<=folder_start);
	  h = zeros(300,260);
          for j=0:2;
            h = h + 1/3 * get_record(isRema,ad_folder,folder_start,i-j,3,read_issm)';
	  end
        else	
          h = get_record(isRema,ad_folder,folder_start,i,3,read_issm)';
        end
        h = h(J,I);
        haf = h;
	haf(~vafmask)=0;
        haf(rlow<0)=haf(rlow<0)+1027/917*rlow(rlow<0);
        haf(haf<0)=0;
        Vaf(round(i/3)) = sum(sum(haf))*1500^2;
    end
end
h0 = h0(J,I);
haf = h0;
        haf(rlow<0)=haf(rlow<0)+1027/917*rlow(rlow<0);
        haf(haf<0)=0;
	haf(~vafmask)=0;
        Vaf0 = sum(sum(haf))*1500^2;
Vaf = Vaf-Vaf0;        

hobs36 = sobs36-max (-917/1027*sobs36/(1-917/1027),rlow);
hobs96 = sobs96-max (-917/1027*sobs96/(1-917/1027),rlow);
hobs156 = sobs156-max (-917/1027*sobs156/(1-917/1027),rlow);

inds = [36 96 156];
for i = 1:3;
 ind = inds(i);
 num=num2str(ind);
 eval(['hobs = sobs' num '-max (-917/1027*sobs' num '/(1-917/1027),rlow);']);
 haf = hobs;
 haf(~vafmask)=0;
 haf(rlow<0)=haf(rlow<0)+1027/917*rlow(rlow<0);
 haf(haf<0)=0;
 vafobs(i)=sum(sum(sum(haf)))*1500^2-Vaf0;
end

Tobs0=T(1:12);
Tobs1=T(12:32);
Tobs2=T(32:52);

return



function vec = get_record(isRema,ad_folder,folder_start,n,rec,read_issm,aug);

global rlow I J

if (~read_issm)

 if (isRema); 
            k = n-96;
 else
            k = n;
 end

 if (n<=folder_start);
            vec=rdmds(['../' ad_folder '/runoptiter040/land_ice'],k,'rec',rec);
 else
            vec=rdmds('land_ice',k,'rec',rec);
 end

 vec = vec(I,J)';
  
else

 switch(rec)
     case 1
         recstring = 'VX';
     case 2
         recstring = 'VY';
     case 3
         recstring = 'THICK';
     case 6
         recstring = 'SURF'
     case 4
         recstring = 'Xmask'

 end



return





