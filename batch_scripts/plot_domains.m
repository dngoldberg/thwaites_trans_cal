load ../input_tc/temp_data.mat

subplot(1,2,1)

contour(x_mesh_mid/1e3,y_mesh_mid/1e3,maskbm,'k'); hold on;
contour(x_mesh_mid/1e3,y_mesh_mid/1e3,mask_dom,'r')
contour(x_mesh_mid/1e3,y_mesh_mid/1e3,mask_cost,'b')
set(gca,'fontsize',12,'fontweight','bold')
xlabel('x (km)')
ylabel('y (km)')
grid on

xlim([-1640 -1250])
ylim([-660 -225])



set(gcf,'Position',[214   382   1100   550])

XL=get(gca,'xlim')
YL=get(gca,'ylim')

text(-1558,-273,'(a)','fontsize',14,'FontWeight','bold')

load ../morlighem_output/Mesh_ForDan.mat

subplot(1,2,2)
patch( 'Faces', tri, 'Vertices', [x y]/1e3,'FaceColor','none','EdgeColor','k');

set(gca,'fontsize',12,'fontweight','bold')
xlabel('x (km)')
ylabel('y (km)')
grid on
xlim([-1640 -1250])
ylim([-660 -225])

text(-1558,-273,'(b)','fontsize',14,'FontWeight','bold')

print -dpng model_domains.png


% ISSM MESH....?