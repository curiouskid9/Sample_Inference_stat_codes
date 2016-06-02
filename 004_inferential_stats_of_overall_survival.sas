ods output ProductLimitEstimates = ple;
ods output Quartiles = quart (drop = stratum);

proc lifetest data=adtte method=km timelist=91.3125,182.625,365.25 reduceout outsurv=survest alpha=0.05;
   time aval*cnsr(1);
   strata trtan;
run;
ods output close;
