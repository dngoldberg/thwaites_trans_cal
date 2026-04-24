imposewgtvel=0
imposetikhbeta=0
imposetikhbglen=0
imposedepth=0
imposewgtsurf=0
while read -r line; do
   # Look for the correct line (if you have other parameters)
   if [[ $line == Restart:* ]]; then
      reStart=$(echo "$line" | cut -c 10-);
   fi;
   if [[ $line == Sliding:* ]]; then
      sliding=$(echo "$line" | cut -c 10-);
   fi;
   if [[ $line == Timedep:* ]]; then
      tdep=$(echo "$line" | cut -c 10-);
   fi;
   if [[ $line == MeltType:* ]]; then
      melttype=$(echo "$line" | cut -c 11-);
   fi;
   if [[ $line == GlenType:* ]]; then
      glentype=$(echo "$line" | cut -c 11-);
   fi;
   if [[ $line == BetaType:* ]]; then
      betatype=$(echo "$line" | cut -c 11-);
   fi;
   if [[ $line == Smith:* ]]; then
      smithconstr=$(echo "$line" | cut -c 8-);
   fi;
   if [[ $line == BigConstr:* ]]; then
      bigconstr=$(echo "$line" | cut -c 12-);
   fi;
   if [[ $line == gentim:* ]]; then
      gentim=$(echo "$line" | cut -c 9-);
   fi;
   if [[ $line == proj:* ]]; then
      proj=$(echo "$line" | cut -c 7-);
   fi;
   if [[ $line == longproj:* ]]; then
      longproj=$(echo "$line" | cut -c 11-);
   fi;
   if [[ $line == meltconst:* ]]; then
      meltconst=$(echo "$line" | cut -c 12-);
   fi;
   if [[ $line == tikhbeta:* ]]; then
      tikhbeta=$(echo "$line" | cut -c 11-);
      imposetikhbeta=1
   fi;
   if [[ $line == tikhbglen:* ]]; then
      tikhbglen=$(echo "$line" | cut -c 12-);
      imposetikhbglen=1
   fi;
   if [[ $line == bdotdepth:* ]]; then
      bdotdepth=$(echo "$line" | cut -c 12-);
      imposedepth=1
   fi;
   if [[ $line == wgtvel:* ]]; then
      wgtvel=$(echo "$line" | cut -c 9-);
      imposewgtvel=1
   fi;
   if [[ $line == wgtsurf:* ]]; then
      wgtsurf=$(echo "$line" | cut -c 10-);
      imposewgtsurf=1
   fi;
   if [[ $line == precondBeta:* ]]; then
      precondBeta=$(echo "$line" | cut -c 14-);
   fi
   if [[ $line == precondBglen:* ]]; then
      precondBglen=$(echo "$line" | cut -c 15-);
   fi
   if [[ $line == precondMelt:* ]]; then
      precondMelt=$(echo "$line" | cut -c 14-);
   fi
   if [[ $line == numInvIter:* ]]; then
      numInvIter=$(echo "$line" | cut -c 13-);
   fi
   if [[ $line == numInvSaveRun:* ]]; then
      numInvSaveRun=$(echo "$line" | cut -c 16-);
   fi
   if [[ $line == expFolder:* ]]; then
      expFolder=$(echo "$line" | cut -c 12-);
   fi

done < $1

if [ x$sliding == x ]; then
        sliding='coul'
fi
if [ x$reStart == x ]; then
        reStart='false'
fi
if [ x$tdep == x ]; then
        tdep='tc'
fi
if [ x$melttype == x ]; then
        melttype=g
fi
if [ x$glentype == x ]; then
        glentype=0
fi
if [ x$betatype == x ]; then
        betatype=0
fi
if [ x$smithconstr == x ]; then
        smithconstr='NS'
fi
if [ x$bigconstr == x ]; then
        bigconstr='surf'
fi
if [ x$gentim == x ]; then
        gentim='gentim'
fi
if [ x$proj == x ]; then
        proj='last'
fi
if [ x$longproj == x ]; then
        longproj=50
fi
if [ x$meltconst == x ]; then
        meltconst="n"
        #meltapp="_${meltconst}"
fi
if [ x$tikhbeta == x ]; then
        tikhbeta='0.2e5'
fi
if [ x$tikhbglen == x ]; then
        tikhbglen='0.2e5'
fi
if [ x$bdotdepth == x ]; then
        bdotdepth=0
fi
if [ x$wgtvel == x ]; then
        wgtvel=0.000
fi
if [ x$wgtsurf == x ]; then
        wgtsurf=1.000
fi
if [ x$precondBeta == x ]; then
        precondBeta=1.0
fi
if [ x$precondBglen == x ]; then
        precondBglen=1.0
fi
if [ x$precondMelt == x ]; then
        precondMelt=0.1
fi
if [ x$numInvIter == x ]; then
        numInvIter=40
fi
if [ x$numInvSaveRun == x ]; then
        numInvSaveRun=5
fi
if [ x$expFolder == x ]; then
        expFolder=""
fi

