foldroot = '/exports/geos.ed.ac.uk/iceocean/dgoldber/archer_output/THWAITES/MAINRUNS/run_ad*';

S = dir(foldroot)


%strs={'surf_.1e5','vel','mix'};

strs={'surf','vel','mix'};
folds={};
for j=1:3;
    for i=1:length(S);
        if(~isempty(findstr(S(i).name,strs{j})));
            folds{j} = ['/exports/geos.ed.ac.uk/iceocean/dgoldber/archer_output/THWAITES/MAINRUNS/' S(i).name];
        end
    end
end

chars={'(a)','(b)','(c)','(d)'};

for i=1:3;
    subplot(2,2,i)
    
    exp = folds{i}
    [surfMis velMis J] = get_conv(exp);
    
    if (i==2)
        J = J*5/6;
        velMis = velMis * 5/6;
    end
    
    surferr{i} = surfMis;
    velerr{i} = velMis;
    totcost{i} = J;

    
    plot(0:40,J,'k','linewidth',2)
    hold on
    %if (i~=2)
    hsurf = plot(0:40,surfMis,'r','linewidth',2);
    
    yl = get(gca,'ylim'); yl=yl(2);
    ylim([10 yl])
    
    %end
    %if (i~=1)
    hvel = plot(0:40,velMis,'b','linewidth',2)
    %end
    hold off
    
    set(gca,'fontsize',16,'fontweight','bold');
    if (i==1);
	    legend('Tot. Cost','Surf','Vel','location','SouthWest')
    end
    if (i==2)
	    delete(hsurf)
    end
    if(i==3)
        set(gca,'Yscale','log')
        ylim([20 yl])
    end
    
	    xlabel('iteration');
	    ylabel('cost')
    grid on

end

subplot(2,2,4)

plot(surferr{3}./surferr{1},'k--','linewidth',2)
hold on
plot(velerr{3}./velerr{2},'k','linewidth',2)
hold off
set(gca,'fontsize',16,'fontweight','bold');
xlabel('iteration')
ylabel('relative cost')
legend('Surf','Vel','location','SouthEast')
grid on

set(gcf,'position',[1 1 850 600])

for i=1:4;
	subplot(2,2,i)
        xl = get(gca,'xlim')
        yl = get(gca,'ylim')
        text(xl(1)+.75*diff(xl),yl(1)+.9*diff(yl),chars{i},'fontsize',20,'fontweight','bold');
end

print -dpng fig_conv.png
