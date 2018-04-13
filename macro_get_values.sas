PROC DATASETS lib=work kill nolist nodetails;
PROC copy in=sashelp out=work; select nvst2; RUN;

%macro get_values(data);

PROC UNIVARIATE data= &data. outtable=out noprint;
RUN;

DATA _NULL_;
SET &data.;
array list[*]_NUMERIC_;
call symput('dim', dim(list));
RUN;

DATA _NULL_;
set out;
call symput(cats('varname', put(_N_, 8.)), _VAR_);
RUN;

%do x=1 %to &dim.;
DATA _NULL_;
set out (where=(_VAR_="&&varname&x."));
call symputx(cats('mean_',"&&varname&x."), _MEAN_, "G");
call symputx(cats('median_',"&&varname&x."), _MEDIAN_, "G");
call symputx(cats('min_',"&&varname&x."), _MIN_, "G");
call symputx(cats('max_',"&&varname&x."), _MAX_, "G");
call symputx(cats('nobs_',"&&varname&x."), _NOBS_, "G");
call symputx(cats('nmiss_',"&&varname&x."), _NMISS_, "G");
call symputx(cats('std_',"&&varname&x."), _STD_, "G");
call symputx(cats('sum_',"&&varname&x."), _SUM_, "G");
call symputx(cats('vari_',"&&varname&x."), _VARI_, "G");
call symputx(cats('stdmean_',"&&varname&x."), _STDMEAN_, "G");
call symputx(cats('range_',"&&varname&x."), _RANGE_, "G");
RUN;
%end;


PROC DATASETS lib=work nolist nodetails; delete out; RUN; 
/*%do j=1 %to &dim.;
PROC DATASETS lib=work nolist nodetails; delete A&j.; RUN; 
%end;*/

%let msg1 = "NOTE: mean median min max nobs nmiss std sum vari stdmean range of all numeric variables of data set &data. are now available as global macro-variables.";
%let msg2 = "NOTE: Get those stats in a data step or elsewhere by calling them with this synthax: &<stat>_<variable>(.)";  

DATA _NULL_;
put &msg1./&msg2.;
RUN;

%mend;

/*DEMO*/
%get_values(nvst2);
%put &mean_amount.;
%put &mean_date.;
%put &min_amount.;
