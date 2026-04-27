% [vmis smis] = bar_graph_output (...
%     'coul', ...
%     'tc', ...
%     'gentim', ...
%     'g', ...
%     0, ...
%     0, ...
%     'NS', ...
%     'mix', ...
%     'last' ...
%     )

ex{1} = {'coul','snap','','',0,0,'','',''};               %snapshot
ex{2} = {'coul','tc','gentim','g',0,0,'S','mix','last'};  %base TC
ex{3} = {'coul','tc','gentim','G',0,0,'S','mix','last'};  %melt TC
ex{4} = {'coul','tc','gentim','g',1,0,'S','mix','last'};  %glan TC
ex{5} = {'coul','tc','gentim','g',0,1,'S','mix','last'};  %beta TC
ex{6} = {'coul','tc','gentim','g',0,0,'S','surf','last'}; %surf TC
ex{7} = {'coul','tc','gentim','g',0,0,'S','vel','last'};  %vel TC
ex{7} = {'coul','tc','gentim','g',0,0,'S','vel','last'};  %vel TC
ex{8} = {'coul','tc','gentimlong','g',0,0,'NS','mix','last'};  %vel TC

figure(1)

veltime = 2005:2017;
stime = [2007 2012 2017];

vel_misfits = [];
surf_misfits = [];

for i=[1 2]
    [vmis smis] = bar_graph_output(ex{i}{1},ex{i}{2},ex{i}{3},ex{i}{4}, ...
                                  ex{i}{5},ex{i}{6},ex{i}{7},ex{i}{8},ex{i}{9});
    vel_misfits = [vel_misfits vmis'];
    surf_misfits = [surf_misfits smis'];
end

vel_misfits = [zeros(4,2); vel_misfits]

legstrings = {'Snapshot','Transient Calibration'}
set(gcf,'Color','w');
   subplot(1,2,1);
   bar(veltime, vel_misfits(1:end,:))
   title('Velocity misfit'); ylabel('m/a')
   subplot(1,2,2);
   bar(stime, surf_misfits(1:end,:))
   title('Surface height misfit'); ylabel('m');
   legend(legstrings,'location','Northwest')
   ylim([0 25])
   set(gcf,'position',[1 1 1000 400])

   % fig 2


print -dpng fig_slide10.png

figure(2)

veltime = 2005:2017;
stime = [2007 2012 2017];

vel_misfits = [];
surf_misfits = [];

for i=[1 2 6 7]
    [vmis smis] = bar_graph_output(ex{i}{1},ex{i}{2},ex{i}{3},ex{i}{4}, ...
                                  ex{i}{5},ex{i}{6},ex{i}{7},ex{i}{8},ex{i}{9});
    vel_misfits = [vel_misfits vmis'];
    surf_misfits = [surf_misfits smis'];
end

vel_misfits = [zeros(4,4); vel_misfits]

legstrings = {'Snapshot','Transient Calibration','Transient Calibration SurfaceOnly','Transient Calibration VelOnly'}
set(gcf,'Color','w');
   subplot(1,2,1);
   bar(veltime, vel_misfits(1:end,:))
   title('Velocity misfit'); ylabel('m/a')
   subplot(1,2,2);
   bar(stime, surf_misfits(1:end,:))
   title('Surface height misfit'); ylabel('m');
   legend(legstrings,'location','Northwest')
   ylim([0 25])
   set(gcf,'position',[1 1 1000 400])

   print -dpng fig_slide11.png

figure(3)

veltime = 2005:2017;
stime = [2007 2012 2017];

vel_misfits = [];
surf_misfits = [];

for i=[1 2 5 4 3]
    [vmis smis] = bar_graph_output(ex{i}{1},ex{i}{2},ex{i}{3},ex{i}{4}, ...
                                  ex{i}{5},ex{i}{6},ex{i}{7},ex{i}{8},ex{i}{9});
    vel_misfits = [vel_misfits vmis'];
    surf_misfits = [surf_misfits smis'];
end

vel_misfits = [zeros(4,5); vel_misfits]

legstrings = {'Snapshot','Transient Calibration','Transient Calibration TransientFriction','Transient Calibration TransientRheology','Transient Calibration TransientMelt'}
set(gcf,'Color','w');
   subplot(1,2,1);
   bar(veltime, vel_misfits(1:end,:))
   title('Velocity misfit'); ylabel('m/a')
   subplot(1,2,2);
   bar(stime, surf_misfits(1:end,:))
   title('Surface height misfit'); ylabel('m');
   legend(legstrings,'location','Northwest')
   ylim([0 25])
   
   set(gcf,'position',[1 1 1000 400])
   print -dpng fig_slide12.png

figure(4)

veltime = 2005:2017;
stime = [2007 2012 2017];

vel_misfits = [];
surf_misfits = [];

for i=[1 2 8]
    [vmis smis] = bar_graph_output(ex{i}{1},ex{i}{2},ex{i}{3},ex{i}{4}, ...
                                  ex{i}{5},ex{i}{6},ex{i}{7},ex{i}{8},ex{i}{9});
    vel_misfits = [vel_misfits vmis'];
    surf_misfits = [surf_misfits smis'];
end

vel_misfits = [zeros(4,3); vel_misfits]

legstrings = {'Snapshot','Transient Calibration','Transient Calibration to2017'}
set(gcf,'Color','w');
   subplot(1,2,1);
   bar(veltime, vel_misfits(1:end,:))
   title('Velocity misfit'); ylabel('m/a')
   subplot(1,2,2);
   bar(stime, surf_misfits(1:end,:))
   title('Surface height misfit'); ylabel('m');
   legend(legstrings,'location','Northwest')
   ylim([0 25])
   
   set(gcf,'position',[1 1 1000 400])
   print -dpng fig_slide13.png
   
