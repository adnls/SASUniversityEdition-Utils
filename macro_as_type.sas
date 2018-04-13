PROC DATASETS lib=work kill nolist nodetails;
PROC copy in=sashelp out=work; select class; RUN;

/*as_char*/
%macro as_char(var, infmt=BEST10., outfmt= $CHAR10.);
&var._num = &var.;
format &var._char &outfmt.; 
&var._char = left(put(&var., &infmt.)); 
drop &var.;
%put NOTE: Variable &var._char has been created with format &outfmt..;
%put NOTE: Target variable &var. has been renamed as &var._num.;
%mend;

/*test*/
DATA class1;
SET class;
%as_char(height);
RUN;

/*as num*/
%macro as_num(var, infmt=$CHAR10., outfmt=best10.);
&var._char =&var.;
format &var._num &outfmt.; 
&var._num= put(&var., &infmt.); 
drop &var.;
%put NOTE: Variable &var._num has been created with format &outfmt..;
%put NOTE: Target variable &var. has been renamed as &var._char.;
%mend;

/*test*/
DATA class2;
SET class1 (drop=height_num rename=height_char=height);
%as_num(height);
RUN;

/*****************/
/**sur les dates**/
/*****************/

/*************/
/*as_chardate*/
%macro as_CHARdate(var, SASdate=, CHARdate=);
format &var._SASdate &SASdate. &var._CHARdate $20.;
&var._SASdate= date;
&var._CHARdate=left(put(&var., &CHARdate.));
drop &var.;
%put NOTE: Variable &var._CHARdate has been created with format &CHARdate..;
%put NOTE: Target variable &var. has been renamed as &var._char with format &SASdate..;
%mend;

/*test*/
PROC DATASETS lib=work kill nolist nodetails;
DATA b;
SET sashelp.buy;
RUN;

Data b1;
SET b;
%as_CHARdate(date, SASdate=ddmmyy10., CHARdate=ddmmyy10.);
RUN;

/************/
/*as_SASdate*/
%macro as_SASdate(var, infmt=, outfmt=);
&var._CHARdate = &var;
format &var._SASdate &outfmt.;
&var._SASdate=input(&var., &infmt.);
drop &var.;
%put NOTE: Variable &var._SASdate has been created with format &outfmt..;
%put NOTE: Target variable &var. has been renamed as &var._CHARdate.;
RUN;
%mend;

/*test*/
PROC DATASETS lib=work kill nolist nodetails;
DATA b;
SET sashelp.buy;
RUN;

DATA b;
SET b; 
format date1 $10.;
date1 = put(date, date10.);
drop date;
rename date1=date;
RUN;

DATA b1; 
SET b;
%as_SASdate(date, infmt=date10., outfmt=date10.);
RUN;
