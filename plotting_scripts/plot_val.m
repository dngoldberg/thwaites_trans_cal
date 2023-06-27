function [metric_vel metric_dhdt] = plot_val(do_plot)

rlow=rdmds(['R_low_siinit'])';
folder = pwd();
rest = folder;
while (length(rest)>1);
 [front rest] = strtok(rest,'/');
end
folder = front;

metric_vel = 0;
metric_dhdt = 0;

nitervel=[108 120 132 144 156];% 162 180 198 216 234];
%nitervel=[];% 162 180 198 216 234];
nitersurf=[156];% 234];

strgrep = evalc('!grep niter0 STDOUT.0000');
niter0 = str2num(strgrep(end-2:end-1));
if (isempty(niter0))
 niter0 = str2num(strgrep(end-1));
end

strgrep = evalc('!grep streamicethickFile STDOUT.0000');
strRema = findstr(strgrep,'Rema');
isRema = ~isempty(strRema);

load /home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/temp_data
xrange = length(x_mesh_mid);
yrange = length(y_mesh_mid);
I = 1:xrange;
J = 1:yrange;
rlow = rlow(J,I);

if (length(nitervel)>0 & do_plot);
	h1 = figure;
	h2 = figure;
end

for i = 1:length(nitervel)-1;
    
    if (~isRema)
     n1 = nitervel(i)
     n2 = nitervel(i+1)
    else
     n1 = nitervel(i)-96
     n2 = nitervel(i+1)-96
    end
    
    vobs1 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(n1,10) 'v.bin'],8,260,300)';
    uobs1 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(n1,10) 'u.bin'],8,260,300)';
    uobs1(uobs1==-999999 | uobs1==0)=nan;
    cobs1 = sqrt(uobs1(J,I).^2+vobs1(J,I).^2);

    vobs2 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(n2,10) 'v.bin'],8,260,300)';
    uobs2 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(n2,10) 'u.bin'],8,260,300)';
    uobs2(uobs2==-999999 | uobs2==0)=nan;
    cobs2 = sqrt(uobs2(J,I).^2+vobs2(J,I).^2);

    dc_obs = cobs2-cobs1;

    [q x m]=rdmds(['land_ice'],[n1 n2]);
    u1=q(I,J,1,1)';
    v1=q(I,J,2,1)';
    u2=q(I,J,1,2)';
    v2=q(I,J,2,2)';
    c1 = sqrt(u1.^2+v1.^2);
    c2 = sqrt(u2.^2+v2.^2);
    c1(q(I,J,4,1)'~=1)=nan;
    c2(q(I,J,4,2)'~=1)=nan;
    dc = c2 - c1;
    size(dc)
    size(dc_obs)

    mis = dc-dc_obs;

    metric_vel = metric_vel + sum(abs(mis(~isnan(mis))));

    if (do_plot)
    figure(h1); subplot(ceil((length(nitervel)-1)/2),2,i);
    pcolor(x_mesh_mid,y_mesh_mid,dc_obs(J,I)); shading flat;  axis equal; axis tight;
    colormap parula;
    freezeColors;
    freezeColors(colorbar);
    figure(h2); subplot(ceil((length(nitervel)-1)/2),2,i);
    pcolor(x_mesh_mid,y_mesh_mid,dc-dccobs(J,I)); shading flat; colorbar; caxis([-1500 1500]); axis equal; axis tight;
    hold on
    h=q(I,J,3,2)';
    haf = h;
    haf(rlow<0)=haf(rlow<0)+1027/917*rlow(rlow<0);
    hmask=q(I,J,4,2)';
    fl = (haf>0);
    haf(haf<0)=0;
    contour(x_mesh_mid,y_mesh_mid,hmask==1,[.5 .5],'k','linewidth',2);
    title(num2str(2004 + nitervel(i)/12))
    hold off
    colormap redblue; freezeColors; freezeColors(colorbar);
    end
end

if (do_plot)
figure(h2)
print('-dpng',['../validation_plots/' folder '.png'])
end


if (do_plot)
h3 = figure;
end
%sm=false

%if (sm)
% filenamebase = 'CPOMSmith_surf';
%else
filenamebase = 'CPOM_surf';
%end

sobs96 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/' filenamebase appNum(96,10) '.bin'],8,260,300)';
sobs156 = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/' filenamebase appNum(156,10) '.bin'],8,260,300)';
sobs156(sobs156==-999999)=nan;
sobs96(sobs96==-999999)=nan;
sobs156=sobs156(J,I);
sobs96=sobs96(J,I);

dhdt_obs = (sobs156-sobs96)/5;
dhdt_obs(dhdt_obs>.25) = nan;

if (isRema)
	s96 = rdmds('H_streamiceinit')';
	q = rdmds('land_ice',60);
elseif (niter0==96);
	s96 = rdmds('H_streamiceinit')';
	q = rdmds('land_ice',156);
elseif (niter0 == 0);
	s96 = rdmds('land_ice',96,'rec',3)';
        q = rdmds('land_ice',156);
else
	error ('found corner case');
end

hmask=q(I,J,4)';
h = q(I,J)';
haf = h;
haf(rlow<0)=haf(rlow<0)+1027/917*rlow(rlow<0);
fl = (haf>0);
haf(haf<0)=0;

dhdt=(h-s96(J,I))/5;
dhdt(haf<5)=nan;
dhdt(hmask~=1)=nan;

mis = dhdt - dhdt_obs;

metric_dhdt = abs(sum(mis(~isnan(mis))));


if (do_plot)
    figure(h3)
    subplot(1,2,1);
    pcolor(x_mesh_mid,y_mesh_mid,(sobs156-sobs96)/5); shading flat; colorbar; caxis([-10 10]); colormap redblue; axis equal; axis tight
    hold on
    contour(x_mesh_mid,y_mesh_mid,hmask==1,[.5 .5],'k','linewidth',2);
    contour(x_mesh_mid,y_mesh_mid,fl,[.5 .5],'color',[.6 0 0],'linewidth',2);
    hold off
    h=colorbar; ylabel(h,'meters')
    subplot(1,2,2);
    pcolor(x_mesh_mid,y_mesh_mid,(dhdt)); shading flat; colorbar; caxis([-10 10]); colormap redblue; axis equal; axis tight
    %hold on
    %contour(x_mesh_mid,y_mesh_mid,hmask==1,[.5 .5],'k','linewidth',2);
    %contour(x_mesh_mid,y_mesh_mid,fl,[.5 .5],'color',[.6 0 0],'linewidth',2);
    %hold off
    h=colorbar; ylabel(h,'meters')
end

return



