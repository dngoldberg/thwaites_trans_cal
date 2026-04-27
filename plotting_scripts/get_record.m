function vec = get_record(isRema,ad_folder,folder_start,n,rec,read_issm,iter);

global rlow I J infile SURF       THICK      VX         VY  times niter_inv

if (isempty(niter_inv))
    niter=40
else
    niter = niter_inv;
end


if (~read_issm)

 if (isRema); 
            k = n-96;
 else
            k = n;
 end

 if (n<=folder_start);
            vec=rdmds(['../' ad_folder '/runoptiter' appNum(niter,3) '/land_ice'],k,'rec',rec);
 else
            vec=rdmds('land_ice',k,'rec',rec);
 end

 vec = vec(I,J)';
  
else

 domask = false;
 switch(rec)
     case 1
         recstring = 'VX';
     case 2
         recstring = 'VY';
     case 3
         recstring = 'THICK';
     case 6
         recstring = 'SURF';
     case 4
         recstring = 'Xmask';
         domask=true;

 end

 
 load(infile,'times');
 if (~domask)
    %load(infile,recstring);
    eval(['vart = ' recstring ';']);
 else
    %load(infile,'THICK');
    eval(['vart = THICK;']);
 end
 
 target_time = 2004 + n/12;
 n1 = max(find(times<target_time));
 if (isempty(n1));
	 n1=1; n2=1;
 elseif (n1==size(vart,3));
	 n2=size(vart,3);
 else
	 n2 = n1+1;
 end
 dt = times(n2)-times(n1);
 vecret = (target_time-times(n1))/dt * vart(:,:,n2) + ...
	  (times(n2)-target_time)/dt * vart(:,:,n1);

 if (domask)
	 vec = double(vecret>2);
 else
	 vec = vecret;
 end
end
return



