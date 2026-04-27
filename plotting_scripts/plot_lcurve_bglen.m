
eval(['!cp iter' num2str(iterinv) 'mat/*mat ./']);
load LcurveSurfBglen.mat
keys = Lcurvedata.keys;

%  struct with fields:
%
%      dvafdt1: -22.7119
%      dvafdt2: -30.8836
%    dvafdtfin: -218.9265
%     betacost: 3.8449
%     glencost: 3.4185
%     surfcost: 38.3187
%

gam=[];
dvafdt1=[];
dvafdt2=[];
dvafdtfin=[];
betacost=[];
glencost=[];
surfcost=[];

for i=1:length(keys);
 gamstr = keys{i};
 if (str2num(gamstr)>0);
	gam = [gam str2num(keys{i})];
	a = Lcurvedata(gamstr);
	dvafdt1   = [dvafdt1 a.dvafdt1];
     	dvafdt2   = [dvafdt2 a.dvafdt2];
 	dvafdtfin = [dvafdtfin a.dvafdtfin];
  	betacost  = [betacost a.betacost];
	glencost  = [glencost a.glencost];
	surfcost  = [surfcost a.surfcost];
 else
	a = Lcurvedata(gamstr);
        dvafdt1_lo   = a.dvafdt1;
        dvafdt2_lo   = a.dvafdt2;
        dvafdtfin_lo = a.dvafdtfin;
        betacost_lo  = a.betacost;
        glencost_lo  = a.glencost;
        surfcost_lo  = a.surfcost;	
 end
end

subplot(2,2,1)
scatter(surfcost, glencost./gam,[], gam,'o'); grid on; xlabel('Jmis'); ylabel('Jreg'); grid on; colorbar
set(gca,'yscale','log')
xl = get(gca,'xlim'); set(gca,'xlim',[xl(1)-(xl(2)-xl(1))*.1 xl(2)+(xl(2)-xl(1))*.1]);
[r p] = corr(log(surfcost'),log(glencost'./gam'));
title(['corr = ' num2str(r)])
text(37,.6e-5,'(a)','fontsize',20,'fontweight','bold')

%yyaxis left
%plot(gam,surfcost,'ro');
%yyaxis right
%plot(gam,glencost./gam,'bo');


subplot(2,2,2)
semilogx(gam, dvafdt1, 'ko','markersize',8); grid on; xlabel('gamma'); ylabel('dvafdt 2007-2012 (Gt/a)'); grid on
%hold on
%semilogx(.15e5, dvafdt1_lo, 'ro','markersize',8); grid on; xlabel('gamma'); ylabel('dvafdt 2007-2012 (Gt/a)'); grid on
%hold off
xl = get(gca,'xlim'); set(gca,'xlim',[xl(1)-(xl(2)-xl(1))*.01 xl(2)+(xl(2)-xl(1))*.01]);
set(gca,'xlim',[.05e5 1.5e6])
ylim([-24 -17])
text(3e5,-23,'(b)','fontsize',20,'fontweight','bold')
subplot(2,2,3)
semilogx(gam, dvafdt2, 'ko','markersize',8); grid on; xlabel('gamma'); ylabel('dvafdt 2012-2017 (Gt/a)'); grid on
%hold on
%semilogx(.15e5, dvafdt2_lo, 'ro','markersize',8); grid on; xlabel('gamma'); ylabel('dvafdt 2012-2017 (Gt/a)'); grid on
%hold off
xl = get(gca,'xlim'); set(gca,'xlim',[xl(1)-(xl(2)-xl(1))*.01 xl(2)+(xl(2)-xl(1))*.01]);
set(gca,'xlim',[.05e5 1.5e6])
ylim([-31 -20])
text(3e5,-29,'(c)','fontsize',20,'fontweight','bold')
subplot(2,2,4)
semilogx(gam, dvafdtfin, 'ko','markersize',8); grid on; xlabel('gamma'); ylabel('dvafdt final (Gt/a)'); grid on
%hold on
%semilogx(.15e5, dvafdtfin_lo, 'ro','markersize',8); grid on; xlabel('gamma'); ylabel('dvafdt final (Gt/a)'); grid on
%hold off
xl = get(gca,'xlim'); set(gca,'xlim',[xl(1)-(xl(2)-xl(1))*.01 xl(2)+(xl(2)-xl(1))*.01]);
set(gca,'xlim',[.05e5 1.5e6])
ylim([-250 -30])
text(3e5,-212,'(d)','fontsize',20,'fontweight','bold')
print -dpng fig_lcurve.png
