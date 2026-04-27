close all
clear all

rgb2 = [ ...
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

rgb3 = [...
    interp1((1:11)',rgb2(:,1),(1:.1:11)') ...
    interp1((1:11)',rgb2(:,2),(1:.1:11)') ...
    interp1((1:11)',rgb2(:,3),(1:.1:11)')]

rgb2=rgb3;


ylims = [-600 -200]
xlims = [-1600 -1250]

xbounds_region = [-1700 -1100];
ybounds_region = [-740 100];

Sout = shaperead('/home/dgoldber/network_links/ice_data/zwally_outline/IceBoundaries_Y2014-2016_Antarctica');
nThw=65;

load ../input_tc/temp_data.mat
load ../input_tc/bounds1.mat
addpath('/home/dgoldber/network_links/ice_data/ThwaitesDataProphet/CODE');

[XX YY] = meshgrid(-3.2e3:20:3.2e3,-3e3:20:3e3);


x_mesh_mid = x_mesh_mid * 1e-3;
y_mesh_mid = y_mesh_mid * 1e-3;

% thinning constraints

nx = length(x_mesh_mid)
ny = length(y_mesh_mid)


vels = zeros(ny,nx,13);
for i=1:13
    vx = binread(['../input_tc/velocity_constraints/velobsMoug' appNum(i*12,10) 'u.bin'],8,260,300)';
    vx = vx(1:ny,1:nx);
    vx(~mask_cost)=nan;
    vx(vx==-999999)=nan;
    vy = binread(['../input_tc/velocity_constraints/velobsMoug' appNum(i*12,10) 'v.bin'],8,260,300)';
    vy = vy(1:ny,1:nx);
    vy(~mask_cost)=nan;
    vy(vy==-999999)=nan;
    v=sqrt(vx.^2+vy.^2);
    vels(:,:,i)=v;
end

close all
figure(1)
set(gcf,'Position',[100 100 1000 900])
for i=1:12;

    subplot(3,4,i)
    velnum = i+1;
    pcolor(x_mesh_mid,y_mesh_mid,(vels(:,:,velnum)-vels(:,:,velnum-1)));
    colormap(rgb2)
    caxis([-100 100])
    shading flat;
    
    
    xlim([-1650 -1200])
    ylim([-610 -190])

    ylims = [-600 -200]
    xlims = [x_mesh_mid(1) -1250]
    xlim(xlims)
    ylim(ylims)

    yticks([-600 -400 -200])
    xticks([-1600 -1400])
    xticklabels([])
    yticklabels([])
    grid on

    set(gca,'FontWeight','bold','FontSize',10)

    P = get(gca,'Position')
    if (mod(i,4)==1);
        yticklabels([-600 -400 -200])
        ylabel('y (km)')
        %set(gca,'Position',[P(1) P(2) P(3) P(4)])
    else
        
    %    set(gca,'Position',[P(1)-0.025*(2-mod(i,3)/2) P(2) P(3) P(4)])
    end

    if (i>8);
        xticklabels([-1600 -1400])
        xlabel('x (km)')
    end

    y1 = num2str(2004+i+1);
    y2 = num2str(2004+(i));
    text(-1550,-250,[y2 ' to ' y1],'fontweight','bold')
    %text(-1325,-530,['(' char(i+'a') ')'],'fontweight','bold','fontsize',10)
    if (i==8); 
        h=colorbar('eastoutside')
        P = get(h,'position')
        set(h,'position',[P(1)+.06 P(2)-.2 P(3)*1.5 P(4)*2.5])
        title(h,'m/a')
    end

    
end
print -dpng vel_obs_detail.png


