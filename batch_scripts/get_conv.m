function [surfMis velMis J] = get_conv(exp)


 %fold = '/exports/geos.ed.ac.uk/iceocean/dgoldber/archer_output/THWAITES/run_ad_coul_tc_gentim_g00S_mix/'


 for i=0:40;

	ii=appNum(i,3);
	fname=[exp '/outputoptiter' ii];

	strVelMis = evalc(['!grep "td vel misfit" ' fname]);
	tokens = strsplit(strVelMis,' ');
	velMis(i+1,1) = str2num(tokens{end});
	strSurfMis = evalc(['!grep "thinning contr" ' fname]);
	tokens = strsplit(strSurfMis,' ');
	surfMis(i+1,1) = str2num(tokens{end});
	strCost = evalc(['!grep "global fc" ' fname]);
	tokens = strsplit(strCost,' ');
	J(i+1,1) = str2num(tokens{end});

 end
return
 
