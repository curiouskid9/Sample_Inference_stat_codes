
ods output lsmeans = lsmean diffs = diff tests3 = effect;

proc mixed data = qs;  
   where avisitn gt 0 ;
   class treatment avisitn pcountry usubjid;   
   model chg = base pcountry treatment avisitn   treatment*avisitn  /ddfm = kr htype = 3;
   repeated avisitn/subject = usubjid type = cs;
   lsmeans treatment treatment*avisitn/diff cl;
run;  

data lsmean;
   set lsmean;
   where not missing(treatment) and not missing(avisitn) and treatment in (3,4,5);
    c11=put(round(estimate,0.01),8.2);
    c12=put(round(stderr,0.001),8.3);
   keep avisitn treatment c11 c12;
   
run;

Description given in footnote:

  line @1 "[a] The LS mean change from baseline and standard error are derived using mixed model repeated measures (MMRM) methodology with";
  line @1 "factors for pooled country, treatment, visit, treatment-by-visit interaction and baseline as a covariate.";
