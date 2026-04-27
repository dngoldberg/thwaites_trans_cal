fname='/home/dgoldber/network_links/datastore/ice_data/thwaites_ngeo/1b_basal_melt.tif';
addpath('/home/dgoldber/network_links/datastore/ice_data/ThwaitesDataProphet/CODE');
close all
[A R]=geotiffread(fname);
X=geotiffinfo(fname);
xn = R.XWorldLimits(1):1000:R.XWorldLimits(2);
yn = R.YWorldLimits(1):1000:R.YWorldLimits(2);
yn = yn(1:end-1)+500;
xn = xn(1:end-1)+500;
[xn yn]=meshgrid(xn,yn);

subplot(1,2,1)
mlt = flipud(double(A));
pcolor(xn/1e3,yn/1e3,mlt);

xlim([-1625 max(max(xn))/1e3]);
ylim([-475 -390]);


grid on;
set(gca,'fontsize',12,'fontweight','bold');
h=colorbar;
shading flat;
caxis([0 100])
xlabel('x (km)');
ylabel('y (km)');
title(h,'m/a')
set(gcf,'Position',[100 100 1000 400])

thick = interpBedmachineAntarctica(xn,yn,'thickness');
surf = interpBedmachineAntarctica(xn,yn,'surface');
bot = surf-thick;

hold on
bot(isnan(mlt))=nan;
contour(xn/1e3,yn/1e3,bot,[-600 -600],'k','linewidth',2)
contour(xn/1e3,yn/1e3,bot,[-500 -500],'r','linewidth',2)
contour(xn/1e3,yn/1e3,bot,[-400 -400],'y','linewidth',2)
hold off
freezeColors
C=colormap;
set(h,'colormap',C)

text(-1610,-467,'(a)','fontsize',20,'fontweight','bold')

subplot(1,2,2)
mlt(mlt<=0)=nan;
xd=1540e3;
yd = 440e3;
I = yn<-400e3&yn>-500e3;
scatter(mlt(I),bot(I),8,xn(I)/1e3); hold on
h=colorbar
colormap jet
caxis([-1600 -1530])
title (h,'x-coord (km)')
set(h,'ticks',[-1595:10:-1535])
%plot(mlt(yn<-400e3 & yn<-yd),bot(yn<-400e3 & yn<-yd),'ro'); hold on
%plot(mlt(yn<-400e3 & yn>=-yd),bot(yn<-400e3 & yn>=-yd),'ro'); hold off

%hold on
%plot(mlt(yn>-400e3),bot(yn>-400e3),'k+');
set(gca,'fontsize',12,'fontweight','bold');
xlabel('melt (m/a)')
ylabel('depth')

rho=917;
rhow=1024;

D = linspace(0,1200,101);
H = D/(rho/rhow);
Jmelt = zeros(size(D));
Jmelt(H>=600) = 154-.273*H(H>=600);
Jmelt(H<600 & H>=375) = 15 - .04 * H(H<600 & H>=375);



hold on
%mmelt = 50;
%Dmelt = zeros(size(D));
%z1=0;
%Dmelt(D<700 & D>=z1)=mmelt * (D(D<700 & D>=z1)-z1)/(700-z1);
%Dmelt(D>=700)=mmelt;
%plot(Dmelt,-D,'k--','linewidth',2)

mmelt = 65;
Dmelt = zeros(size(D));
z1=0;
Dmelt(D<700 & D>=z1)=mmelt * (D(D<700 & D>=z1)-z1)/(700-z1);
Dmelt(D>=700)=mmelt;
plot(Dmelt,-D,'k','linewidth',2)

mmelt = 50;
Dmelt = zeros(size(D));
z1=0;
Dmelt(D<540 & D>=z1)=mmelt * (D(D<540 & D>=z1)-z1)/(540-z1);
Dmelt(D>=540)=mmelt;
%plot(Dmelt,-D,'k--','linewidth',2)

%mmelt = 115;
%Dmelt = zeros(size(D));
%z1=300;
%Dmelt(D<700 & D>=z1)=mmelt * (D(D<700 & D>=z1)-z1)/(700-z1);
%Dmelt(D>=700)=mmelt;
%plot(Dmelt,-D,'color',[.6 0 .2], 'linewidth',2)

plot(-4*Jmelt,-D,'r','linewidth',2)
hold off
xlim([-1 120])
grid on
legend('Observed','This study','J2014m4')

text(10,-900,'(b)','fontsize',20,'fontweight','bold')

set(gcf,'position',[1 1 1000 400])



print -dpng fig_melt_param.png

