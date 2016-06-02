
ods output close;
ods output   OddsRatiosWald=OutORW  ContrastEstimate=OutConEst  ContrastTest=OutTest;
proc logistic data=adeff_1  descending;

class TRTPN METBASFL GEOGR1 BMIGR1 ;
model HBA1C6FL = TRTPN METBASFL GEOGR1 BMIGR1 BASE/expb /*firth  /*maxiter=60 gconv=0.0001*/;
oddsratio TRTPN ;     

contrast '10mg vs ER' trtpn 1 0 0 0 -1 / estimate=exp;
 contrast '15mg vs ER' trtpn 0 1 0 0 -1 / estimate=exp;
 contrast '30mg vs ER' trtpn 0 0 1 0 -1 / estimate=exp;
 contrast '50mg vs ER' trtpn 0 0 0 1 -1 / estimate=exp;
 contrast 'ALLLY vs ER'  trtpn 1 1 1 1 -1 / estimate=exp;

 contrast '10mg vs PBO' trtpn 2 1 1 1 1 / estimate = exp;
 contrast '15mg vs PBO' trtpn 1 2 1 1 1 / estimate = exp;
 contrast '30mg vs PBO' trtpn 1 1 2 1 1 / estimate = exp;
 contrast "50mg vs PBO" trtpn 1 1 1 2 1 / estimate = exp;
 contrast 'ER vs PBO'   trtpn 1 1 1 1 2 / estimate = exp;
 contrast "ALLLY vs PBO" trtpn 2 2 2 2 1 / estimate = exp;
 
run;

line @1 "*a - Statistics are from a logistic regression model for the proportion of patients achieving HbA1c < 6.5% at Week 24, with treatment,";
line @1 "     country, baseline BMI category, and metformin use (yes, no) as fixed effects and with continuous baseline HbA1c as a covariate.";
line @1 "     Data collected after start of rescue therapy are not included.";
