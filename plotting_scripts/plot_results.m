function plot_results(iter,sm)

	rlow=rdmds(['runoptiter' appNum(iter,3) '/R_low_siinit'])';



nitervel=[60 72 84 96];% 162 180 198 216 234];
%nitervel=[];% 162 180 198 216 234];
nitersurf=[36 96];% 234];


load /home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/temp_data
xrange = length(x_mesh_mid);
yrange = length(y_mesh_mid);
I = 1:xrange;
J = 1:yrange;
rlow = rlow(J,I);

if (length(nitervel)>0);
	h1 = figure;
	h2 = figure;
end

for i = 1:length(nitervel);
%for i = 1:0;
    n = nitervel(i)
    vobs = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(n,10) 'v.bin'],8,260,300)';
    uobs = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(n,10) 'u.bin'],8,260,300)';
    uerr = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(n,10) 'err.bin'],8,260,300)';
    uobs(uobs==-999999 | uobs==0)=nan;

    [q x m]=rdmds(['runoptiter' appNum(iter,3) '/land_ice'],n);
    u=q(I,J,1)';
    v=q(I,J,2)';
    c = sqrt(u.^2+v.^2);
    c(q(I,J,4)'~=1)=nan;
    cobs = sqrt(uobs.^2+vobs.^2);
    cobs(q(I,J,4)'~=1)=nan;
    figure(h1); subplot(ceil(length(nitervel)/2),2,i);
    pcolor(c); shading flat; colorbar; axis equal; axis tight;
    figure(h2); subplot(ceil(length(nitervel)/2),2,i);
    size(c)
    size(cobs)
    pcolor(x_mesh_mid,y_mesh_mid,(c-cobs(J,I))./sqrt(1.+uerr(J,I).^2)); shading flat; colorbar; caxis([-100 100]); axis equal; axis tight;
    %pcolor(x_mesh_mid,y_mesh_mid,uerr(J,I)); shading flat; colorbar; axis equal; axis tight;
    hold on
    h=q(I,J,3)';
    haf = h;
    haf(rlow<0)=haf(rlow<0)+1027/917*rlow(rlow<0);
    hmask=q(I,J,4)';
    fl = (haf>0);
    haf(haf<0)=0;
    contour(x_mesh_mid,y_mesh_mid,hmask==1,[.5 .5],'k','linewidth',2);
    title(num2str(2004 + nitervel(i)/12))
%    contour(x_mesh_mid,y_mesh_mid,fl,[.5 .5],'color',[.6 0 0],'linewidth',2);
    hold off

%    colormap redblue
end
    figure(h2)
%    print('-dpng',['vel_mis_' num2str(iter) '.png'])

%close(h1)
%close(h2)
h3 = figure;

for i = 1:length(nitersurf);
    n = nitersurf(i)
    if (sm)
    disp(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/CPOMSmith_surf' appNum(n,10) '.bin'])
    sobs = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/CPOMSmith_surf' appNum(n,10) '.bin'],8,260,300)';
    serr = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/CPOMSmith_surf' appNum(n,10) 'err.bin'],8,260,300)';
    else
    disp(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/CPOM_surf' appNum(n,10) '.bin'])
    sobs = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/CPOM_surf' appNum(n,10) '.bin'],8,260,300)';
    serr = binread(['/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/CPOM_surf' appNum(n,10) 'err.bin'],8,260,300)';
    end

    sobs(sobs==-999999)=nan;
    sobs=sobs(J,I);
    serr=serr(J,I);

    [q x m]=rdmds(['runoptiter' appNum(iter,3) '/land_ice'],n);

    hmask=q(I,J,4)';

    h=q(I,J,3)';
    haf = h;
    haf(rlow<0)=haf(rlow<0)+1027/917*rlow(rlow<0);
    fl = (haf>0);
    haf(haf<0)=0;
    s=q(I,J,6)';
    s(q(I,J,4)'~=1)=nan;
%    s(haf<5)=nan;
    figure(h3)
    subplot(ceil(length(nitersurf)/2),2,i);

    s_mis = s-sobs;
    s_mis(~isnan(sobs) & serr<1) = s_mis(~isnan(sobs) & serr<1);

    size(s)
    pcolor(x_mesh_mid,y_mesh_mid,s_mis); shading flat; colorbar; caxis([-80 80]); colormap default; axis equal; axis tight
    hold on
    contour(x_mesh_mid,y_mesh_mid,hmask==1,[.5 .5],'k','linewidth',2);
    contour(x_mesh_mid,y_mesh_mid,fl,[.5 .5],'color',[.6 0 0],'linewidth',2);
    hold off
    h=colorbar; ylabel(h,'meters')
    title(num2str(2004 + nitersurf(i)/12))
end
    figure(h3)
set(gcf,'position',[100 500 800 500]);
%    print('-dpng',['surf_mis_' num2str(iter) '.png'])
%    close(h3)


