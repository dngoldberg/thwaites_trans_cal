global period

S = dir('/home/dgoldber/network_links/geosIceOcean/dgoldber/archer_output/THWAITES/MAINRUNS/run_val*');
close all
expnames = {'snap','vel','surf','mix'};
longnames = {'snapshot','vel only','surf only','mixed'};
period=1;

% expnames = {'surf'};
% longnames = {'surf only'};


!mkdir cal_plots
for j=1:4;
    name = {expnames{j}}
    disp(name{1});
    for i=1:length(S);
        if ~isempty(findstr(S(i).name,name{1}));
            eval(['cd /exports/geos.ed.ac.uk/iceocean/dgoldber/archer_output/THWAITES/MAINRUNS/' S(i).name])
            eval('!ln -s /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/batch_scripts/cal_plots_dir.m .;')
            close(figure(10))
            figure(10)
            set(gcf,'position',[100 100 900 800])
            cal_plots_dir;
            cd /exports/geos.ed.ac.uk/iceocean/dgoldber/MITgcm_forinput/thwaites_trans_cal/batch_scripts/
            figure(10); 
            sgtitle([longnames{j} ' calibration results'],'fontweight','bold','fontsize',18)
            print('-dpng',['cal_plots/' expnames{j} '_cal_' num2str(period) '_.png'])
        end
    end
end
