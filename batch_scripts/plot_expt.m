function [h1 h2 haf0 haf1 haf2 u1 u2 v1 v2]= plot_expt(t1, t2,mmfile)

global rlow I J infile  SURF       THICK      VX         VY  times

%close all

n1 = floor((t1-2004)*12);
n2 = floor((t2-2004)*12);

addpath('/home/dgoldber/network_links/geosIceOcean/dgoldber/MITgcm_forinput/thwaites_trans_cal/batch_scripts')

if (~isempty(mmfile))
    read_issm = true
    infile = mmfile;
else
    read_issm = false
end

isRema = false;

if (~read_issm)

    rlow=rdmds(['R_low_siinit'])';
    folder = pwd();
    rest = folder;
    while (length(rest)>1);
        [front rest] = strtok(rest,'/');
    end
    folder = front;
    
    folder_start=96;
    
    parts = split(folder,'_');
    
    ad_folder = 'run_ad';
    for i=3:length(parts);
        ad_folder = [ad_folder '_' parts{i}];
    end
    
    if(strcmp(parts{4},'snap'));
        folder_start=0;
    end

    if (isempty(ad_folder))
        h0 = rdmds('H_streamiceinit')';
        h0=h0(J,I);
    else
        h0 = rdmds(['../' ad_folder '/runoptiter040/H_streamiceinit'])';
    end
else
 %base_folder = [pwd() '/runoptiter040'];
 tempStruct=load(mmfile,'BED');
 rlow = (tempStruct.BED);
 tempStruct=load(mmfile,'INITTHICK');
 h0 = (tempStruct.INITTHICK);
 ad_folder = '';
 folder_start = 0;
 load(mmfile)
end

rlow = rlow(J,I);
h0=h0(J,I);

% u1 = get_record(isRema,ad_folder,folder_start,96,1,read_issm);

if(n1==0)
    n1=3;
end
%h0 = get_record(isRema,ad_folder,folder_start,3,3,read_issm);
h1 = get_record(isRema,ad_folder,folder_start,n1,3,read_issm);
h2 = get_record(isRema,ad_folder,folder_start,n2,3,read_issm);

u1 = get_record(isRema,ad_folder,folder_start,n1,1,read_issm);
u2 = get_record(isRema,ad_folder,folder_start,n2,1,read_issm);

v1 = get_record(isRema,ad_folder,folder_start,n1,2,read_issm);
v2 = get_record(isRema,ad_folder,folder_start,n2,2,read_issm);

haf1 = h1;
haf1(rlow<0)=haf1(rlow<0)+1027/917*rlow(rlow<0);

haf0 = h0;
haf0(rlow<0)=haf0(rlow<0)+1027/917*rlow(rlow<0);

haf2 = h2;
haf2(rlow<0)=haf2(rlow<0)+1027/917*rlow(rlow<0);









