/*MACRO TRI*/
%MACRO tri(data, var, missing=TRUE, order=TRUE);

%if &missing. = TRUE %then %let option1 = missing;
%else %if &missing. = FALSE %then %let option1 = ;

%if &order. = TRUE %then %let option2 = order=freq;
%else %if &order. = FALSE %then %let option2 = ;


PROC FREQ data= &data. &option2.;
tables &var. / &option1. nocum missprint;
run;

%MEND;

/*demo*/
PROC DATASETS lib= work KILL NOLIST; RUN;
PROC COPY in=sashelp out=work; select dynattr; RUN;

ODS HTML FILE='/folders/myfolders/sasuser.v94/archives/test.html';
%tri(dynattr, attrtype clasname cvalue explabel format informat);
%tri(dynattr, attrtype clasname cvalue explabel format informat, missing=FALSE);
%tri(dynattr, attrtype clasname cvalue explabel format informat, order=FALSE);
%tri(dynattr, attrtype clasname cvalue explabel format informat, missing=FALSE, order=FALSE);
ODS HTML CLOSE;