load comparison.mat
colors = {[0 .5 0],[.85 .325 .098],[.929 .694 .125],[0    0.4470    0.7410],[0 0 0]./255};

figure(1)
%subplot(1,2,1)
% hold off
% for i=1:4;
%     h(i) = plot(2004+time_st{i},vaf_st{i}/1e9*.917,'-o','MarkerIndices',[40:40:756],'Color',colors{i},'markersize',5,'MarkerFaceColor','auto','linewidth',2); hold on
% end
% for i=1:4;
%     %plot(2004+time_issm{i},vaf_issm{i}/1e9*.917,'Color',h(i).Color,'LineStyle','--','linewidth',2); hold on
% end
%plot(2007,vafobs(1)*917/1e12,'ks')
%plot(2012,vafobs(2)*917/1e12,'ks')
%plot(2017,vafobs(3)*917/1e12,'ks')
% hold off
% % for i=1:4;
% %     h(i) = plot(2004+time_st{i},vaf_st{i}/1e9,'--'); hold on
% % end
% 

% 
% ylim([-6000 100])
% grid on
% hold off


figure(1);
%subplot(1,2,2)
hold off
for i=[1 2 3 4];
    h(i) = plot(2004+.5*(time_st{i}(1:end-1)+time_st{i}(2:end)),diff(vaf_st{i})*4/1e9*.917,'-o','markersize',5,'MarkerIndices',[40:40:756],'Color',colors{i},'MarkerFaceColor','auto','linewidth',2); hold on
end
for i=[1 2 3 4];
    %plot(2004+.5*(time_issm{i}(1:end-1)+time_issm{i}(2:end)),diff(vaf_issm{i})*4/1e9*.917,'Color',h(i).Color,'LineStyle','--','linewidth',2); hold on
end

set(gca,'fontsize',24,'fontweight','bold')
xticks([2010 2030 2050])
%plot(2004+Tobs1([1 end]),[1 1]*(vafobs(2)-vafobs(1))/5e9*.917,'linewidth',4,'color',[0.6350 0.0780 0.1840]);
%plot(2004+Tobs2([1 end]),[1 1]*(vafobs(3)-vafobs(2))/5e9*.917,'linewidth',4,'color',[0.6350 0.0780 0.1840]);
plot(2004+Tobs1([1 end]),[1 1]*(vafobs(2)-vafobs(1))/5e9*.917,'linewidth',4,'color','k');
plot(2004+Tobs2([1 end]),[1 1]*(vafobs(3)-vafobs(2))/5e9*.917,'linewidth',4,'color','K');

 set(gca,'fontsize',24,'fontweight','bold')
 legend(experiment_names,'fontsize',20,'location','southwest')
 set(gca,'fontsize',24,'fontweight','bold')
 xticks([2010 2030 2050])


ylabel('Rate of VAF (Gt/a)')
ylim([-215 0])
hold off
set(gcf,'position',[100 100 700 900])
xlim([2000 2070])

%exportgraphics(gcf, 'dvaf_tseries.pdf')

%savefig(gcf,'dvaf_tseries.fig')
grid on
print -dpng dvaf_trunc_melt.png
%close (figure(1));
%figure(2);
return

max_vel_met = max([metrics_vel_streamice; metrics_vel_issm]);
max_acc_met = max([metrics_acc_streamice; metrics_acc_issm]);
max_surf_met = max([metrics_surf_streamice; metrics_surf_issm]);
max_dhdt_met = max([metrics_dhdt_streamice; metrics_dhdt_issm]);
max_dvaf_met = max([metrics_dvaf_streamice; metrics_dvaf_issm]);

barV = zeros(4,10);
barV(:,1) = metrics_vel_issm/max_vel_met;
barV(:,2) = metrics_vel_streamice/max_vel_met;
barV(:,3) = metrics_acc_issm/max_acc_met;
barV(:,4) = metrics_acc_streamice/max_acc_met;
barV(:,5) = metrics_surf_issm/max_surf_met;
barV(:,6) = metrics_surf_streamice/max_surf_met;
barV(:,7) = metrics_dhdt_issm/max_dhdt_met;
barV(:,8) = metrics_dhdt_streamice/max_dhdt_met;
barV(:,9) = metrics_dvaf_issm/max_dvaf_met;
barV(:,10) = metrics_dvaf_streamice/max_dvaf_met;

b=bar(barV);
for i=1:5;
 b(2*i-1).FaceColor = colors{i};
 b(2*i).FaceColor =  colors{i};
 b(2*i).FaceAlpha = .5;
end
ylim([0 1.5])
legend('vel metric issm','vel metric streamice','acc metric issm',...
    'acc metric streamice','surf metric issm','surf metric streamice',...
    'dhdt metric issm','dhdt metric streamice','dvafdt metric issm','dvafdt metric streamice','NumColumns',2,'fontsize',20)
set(gca,'xticklabel',experiment_names)
ylabel('metric (normalised)')
set(gca,'fontsize',18)
set(gca,'fontsize',24,'fontweight','bold')
set(gcf,'position',[100 100 1200 900])
grid on

print -dpng validation_metrics_2012_2017.png
close all

