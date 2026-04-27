load ../input_tc/temp_data.mat
bsurf1 = binread('../input_tc/surface_constraints/CPOMSmith_surf0000000036.bin',8,260,300)';
bsurf2 = binread('../input_tc/surface_constraints/CPOMSmith_surf0000000096.bin',8,260,300)';

bsurf1(bsurf1==-999999)=nan;
bsurf1(293:end,:)=nan;
bsurf1(:,253:end)=nan;
bsurf1(200:end,1:60)=nan;
bsurf2(bsurf2==-999999)=nan;
bsurf2(293:end,:)=nan;
bsurf2(:,253:end)=nan;
bsurf2(200:end,1:60)=nan;

bsurf = bsurf2-bsurf1;

S = bwconncomp(~isnan(bsurf));
[x k]=max(cellfun(@length, S.PixelIdxList))

maskShep = ~isnan(bsurf);
maskBen = ~isnan(bsurf);

for i=1:length(S.PixelIdxList);

    if (i==k);
        maskBen(S.PixelIdxList{i})=false;
    else
        maskShep(S.PixelIdxList{i})=false;
    end

end

%figure(1); contourf(maskBen)
%figure(2); contourf(maskShep)

dBen = bsurf;
dBen(~maskBen)=nan;
dShep = bsurf;
dShep(~maskShep)=nan;

close all

ax1=axes;
surf(ax1,x_mesh_mid/1e3,y_mesh_mid/1e3,zeros(292,255),dBen(1:292,1:255)/5,'AlphaData',double(maskBen)); 
shading(ax1,'flat'); 
colormap(ax1,redblue)
set(ax1,'fontsize',12,'fontweight','bold')
h1 = colorbar(ax1);
caxis(ax1,[-1 1])
title(h1,'m/a')
set(h1,'ylim',[-1 1])
freezeColors(ax1)
set(h1,'colormap',redblue,'Location','westoutside')
P = get(h1,'position')
set(h1,'position',[P(1)-.1 P(2) P(3) P(4)])
xlabel(ax1,'x (km');
ylabel(ax1,'y (km');

view(ax1,0,90)
ylim(ax1,[-600 -200])
xlim(ax1,[-1625 -1250])

ax2 = axes('Position', get(ax1,'Position'), 'Color', 'none');

hold (ax2,'on')
colormap (ax2,copper)
surf(ax2,x_mesh_mid/1e3,y_mesh_mid/1e3,zeros(292,255),dShep(1:292,1:255)/5,'AlphaData',double(maskShep)); shading flat
caxis(ax2,[-5 5])
hold (ax2,'off')
h2=colorbar(ax2)
set(h2,'ylim',[-5 5])
set(h2,'colormap',copper,'Location','eastoutside')
P = get(h2,'position')
set(h2,'position',[P(1)+.075 P(2) P(3) P(4)])
view(ax2,0,90)
ylim(ax2,[-600 -200])
xlim(ax2,[-1625 -1250])
title(h2,'m/a')
set(ax2,'fontsize',12,'fontweight','bold')
xlabel(ax2,'x (km');
ylabel(ax2,'y (km');


P = get(ax1,'position')
set(ax1,'position',[P(1)+.1 P(2)+.1 P(3)*.8 P(4)*.8])
set(ax2,'position',[P(1)+.1 P(2)+.1 P(3)*.8 P(4)*.8])

print -dpng smith_constr.png
