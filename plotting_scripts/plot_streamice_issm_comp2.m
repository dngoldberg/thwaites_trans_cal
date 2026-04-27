load comparison.mat
colors = {[0 .5 0],[.85 .325 .098],[.929 .694 .125],[0    0.4470    0.7410],[0 0 0]./255};


figure(2);
%subplot(1,2,2)
hold off
for i=[1 2 3 4];
    h(i) = plot(2004+.5*(time_st{i}(1:end-1)+time_st{i}(2:end)),-1*diff(vaf_st{i})*4/1e9*.917/36,'-','Color',colors{i},'linewidth',3); hold on
end
for i=[1 2 3 4];
    plot(2004+.5*(time_issm{i}(1:end-1)+time_issm{i}(2:end)),-1*diff(vaf_issm{i})*4/1e9*.917/36,'Color',h(i).Color,'LineStyle','--','linewidth',3); hold on
end

set(gca,'fontsize',10,'fontweight','bold')
xticks([2010 2030 2050])
%plot(2004+Tobs1([1 end]),[1 1]*(vafobs(2)-vafobs(1))/5e9*.917,'linewidth',4,'color',[0.6350 0.0780 0.1840]);
%plot(2004+Tobs2([1 end]),[1 1]*(vafobs(3)-vafobs(2))/5e9*.917,'linewidth',4,'color',[0.6350 0.0780 0.1840]);
plot(2004+Tobs1([1 end]),-1*[1 1]*(vafobs(2)-vafobs(1))/5e9*.917/36,'linewidth',5,'color','k');
plot(2004+Tobs2([1 end]),-1*[1 1]*(vafobs(3)-vafobs(2))/5e9*.917/36,'linewidth',5,'color','k');

ylabel('Rate of SLR (mm/decade)')
ylim([0/360 210/36])
set(gca,'YTick',[0:.5:6])
set(gca,'yticklabel',{'0','','1','','2','','3','','4','','5',''})
hold off
set(gcf,'position',[100 100 225 300])

%exportgraphics(gcf, 'dvaf_tseries.pdf')

%savefig(gcf,'dvaf_tseries.fig')

grid on
%legend('Transient','Snapshot','fontsize',10,'location','southeast')
legend(experiment_names,'fontsize',16,'location','southwest')
%print -dpng dvaf_tseries.png


return

close (figure(1));
