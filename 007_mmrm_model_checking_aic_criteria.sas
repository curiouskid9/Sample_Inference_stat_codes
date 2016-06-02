ods trace on;
ods listing close;
%MACRO converge(type=,outtyp=);
ods output FitStatistics=csfits_&outtyp. ConvergenceStatus=OutConverge_&outtyp.;
proc mixed data=adsl_adeg2 METHOD=REML;
where avisitn > 0 and trtan ne 7;
class USUBJID METBASFL BMIGR1 HBA1CGR1 geogr1 TRTA AVISITN;
model CHG = METBASFL BMIGR1 HBA1CGR1 geogr1 BASE TRTA AVISITN TRTA*AVISITN/solution DDFM=KR;
lsmeans TRTA*AVISITN/diff cl alpha=0.05;
repeated AVISITN /type=&type. subject= USUBJID; 
run;
%mend;
%converge(type=un,outtyp=un);
%converge(type=cs,outtyp=cs);
%converge(type=csh,outtyp=csh);
%converge(type=arh(1),outtyp=arh);
%converge(type=ar(1),outtyp=ar);


/*******************************************************************************************************************************************
To create a dummy dataset for one of the 4 possible types which produce warning
********************************************************************************************************************************************/;

%macro checkds(dsn=);
  %if %sysfunc(exist(&dsn))>0 %then %do;
    data &dsn.2;
    set &dsn;
    run;
  %end;
  %else %do;
    data &dsn.2;
       attrib
       descr  length=$25  label="Description"
       value  length=8  label="Value";
       descr='';
       value=.; output;
    stop;
    run;
  %end;
%mend checkds;
     
%checkds(dsn=csfits_cs);
%checkds(dsn=csfits_csh);
%checkds(dsn=csfits_arh);
%checkds(dsn=csfits_ar);
%checkds(dsn=csfits_un);

%macro checkds2(dsn=);
  %if %sysfunc(exist(&dsn))>0 %then %do;
    data &dsn.2;
    set &dsn;
    run;
  %end;
  %else %do;
    data &dsn.2;
       attrib
       reason  length=$200  label="Reason"
       status  length=8  label="Status"
		 pdg  length=8  label="pdG"
		 pdh  length=8  label="pdH";
       reason='Convergence criteria not met';
       status=.;
		 pdg=.;
		 pdh=.; output;
    stop;
    run;
  %end;
%mend checkds2;
     
%checkds2(dsn=outconverge_cs);
%checkds2(dsn=outconverge_csh);
%checkds2(dsn=outconverge_arh);
%checkds2(dsn=outconverge_ar);
%checkds2(dsn=outconverge_un);


********************************************************************************************************************************************;
*get cs type*
*******************************************************************************************************************************************;
data cstypes;
length ctype $6;
  set csfits_cs2 (in=a) csfits_csh2 (in=b) csfits_arh2 (in=c) csfits_ar2 (in=d) csfits_un2 (in=e);
  if descr='AIC (smaller is better)';
    if a then do; csort=5; ctype='CS';  end;
    if b then do; csort=3; ctype='CSH';  end;
    if c then do; csort=2; ctype='ARH(1)';  end;
    if d then do; csort=4; ctype='AR(1)';  end;
	 if e then do; csort=1; ctype='UN';  end;
run;

data outconverge;
length ctype $6;
  set outconverge_cs2 (in=a) outconverge_csh2 (in=b) outconverge_arh2 (in=c) outconverge_ar2 (in=d) outconverge_un2 (in=e);
  if reason="Convergence criteria met.";
    if a then do; csort=5; ctype='CS';  end;
    if b then do; csort=3; ctype='CSH';  end;
    if c then do; csort=2; ctype='ARH(1)';  end;
    if d then do; csort=4; ctype='AR(1)';  end;
	 if e then do; csort=1; ctype='UN';  end;
run;


proc sort data=cstypes;
  by  ctype value csort ;
run;

proc sort data=outconverge;
  by  ctype csort ;
run;

data test_;
merge cstypes(in=a) outconverge (in=b);
by  ctype csort;
if a and b;
if ctype = 'UN' and reason = 'Convergence criteria met.' then flag = 1;
else flag = 2;
run;

proc sort data=test_;
by flag value csort ctype;
run;

data test;
  set test_;
	if _n_=1;  
run;

proc sql;
  select ctype into :ctype
  from test;
quit;
