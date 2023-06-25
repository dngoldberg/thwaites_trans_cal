function plot_val(sm)

rlow=rdmds(['R_low_siinit'])';



nitervel=[108 120 132 144 156];% 162 180 198 216 234];
%nitervel=[];% 162 180 198 216 234];
nitersurf=[156];% 234];


load ../../../MITgcm_forinput/thwaites_trans_cal/input_tc/temp_data
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
    n = nitervel(i)
    vobs = binread(['../../../MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(n,10) 'v.bin'],8,260,300)';
    uobs = binread(['../../../MITgcm_forinput/thwaites_trans_cal/input_tc/velocity_constraints/velobsMoug' appNum(n,10) 'u.bin'],8,260,300)';
    uobs(uobs==-999999 | uobs==0)=nan;

    [q x m]=rdmds(['land_ice'],n);
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
    pcolor(x_mesh_mid,y_mesh_mid,c-cobs(J,I)); shading flat; colorbar; caxis([-1500 1500]); axis equal; axis tight;
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

    colormap redblue
end
    figure(h2)
    print('-dpng',['vel_mis_.png'])



h3 = figure;
sm=false
%for i = 1:length(nitersurf);
    if (sm)
    disp(['../../../MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/CPOMSmith_surf' appNum(n,10) '.bin'])
    sobs = binread(['../../../MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/CPOMSmith_surf' appNum(n,10) '.bin'],8,260,300)';
    else
    disp(['../../../MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/full_CPOM_surf' appNum(n,10) '.bin'])
    n=96;
    sobs96 = binread(['../../../MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/full_CPOM_surf' appNum(n,10) '.bin'],8,260,300)';
    n=156;
    sobs156 = binread(['../../../MITgcm_forinput/thwaites_trans_cal/input_tc/surface_constraints/full_CPOM_surf' appNum(n,10) '.bin'],8,260,300)';
    end

    sobs156(sobs156==-999999)=nan;
    sobs96(sobs96==-999999)=nan;
    sobs156=sobs156(J,I);
    sobs96=sobs96(J,I);

    [q x m]=rdmds(['land_ice'],[96 156]);

    hmask=q(I,J,4,1)';

    h=q(I,J,3,2)';
    haf = h;
    haf(rlow<0)=haf(rlow<0)+1027/917*rlow(rlow<0);
    fl = (haf>0);
    haf(haf<0)=0;

    ds=q(I,J,3,2)'-q(I,J,3,1)';
    ds(hmask~=1)=nan;
%    s(haf<5)=nan;
    figure(h3)


    subplot(1,2,1);
    pcolor(x_mesh_mid,y_mesh_mid,(sobs156-sobs96)/5); shading flat; colorbar; caxis([-10 10]); colormap redblue; axis equal; axis tight
    hold on
    contour(x_mesh_mid,y_mesh_mid,hmask==1,[.5 .5],'k','linewidth',2);
    contour(x_mesh_mid,y_mesh_mid,fl,[.5 .5],'color',[.6 0 0],'linewidth',2);
    hold off
    h=colorbar; ylabel(h,'meters')
    subplot(1,2,2);
    pcolor(x_mesh_mid,y_mesh_mid,(ds/5)); shading flat; colorbar; caxis([-10 10]); colormap redblue; axis equal; axis tight
    hold on
    contour(x_mesh_mid,y_mesh_mid,hmask==1,[.5 .5],'k','linewidth',2);
    contour(x_mesh_mid,y_mesh_mid,fl,[.5 .5],'color',[.6 0 0],'linewidth',2);
    hold off
    h=colorbar; ylabel(h,'meters')
%set(gcf,'position',[100 500 800 50]);
%    print('-dpng',['surf_mis_' num2str(iter) '.png'])
%    close(h3)


