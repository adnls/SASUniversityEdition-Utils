/*convert*/
%macro convert(var, convert=, to=, round=1);	

%let message = NOTE: variables &var._&convert. &var._&to. created.;

%if ((&convert. = kg or &convert. = lb or
      &convert. = cm or &convert. = in or
      &convert. = km or &convert. = mi) 
			   and 			
	(&to.= kg or &to.= lb or
	&to.= cm or &to.= in or
	&to.= km or &to.= mi) 
	           and 
	(&convert. ^= &to.))   %then %do;
 
		%if &convert.=lb and &to.=kg %then
			%let ratio = 0.453592; 
		
		%else %if &convert.=kg and &to.=lb %then
			%let ratio = 2.20462; 
	
		%else %if &convert.=in and &to.=cm %then 
			%let ratio = 2.54;
		
		%else %if &convert.=cm and &to.=in %then 
			%let ratio = 03.93701; 
	
		%else %if &convert.=mi and &to.=km %then %do; 
			%let ratio = 1.60934; %end;
		
		%else %if &convert.=km and &to.=mi %then 
			%let ratio = 0.621371; 
        
        %else  %do; %put ERROR: NO RATIO FOUND !; 
        %put WARNING: dataset may be incomplete.; 
        %return; %end;
      
        &var._&convert. = &var.;
        &var._&to. = round(&var.*&ratio., &round.);      
        drop &var.;       
        %put &message.;
   
   %end;

 %else %do;%put ERROR: NO RATIO FOUND !; 
 %put WARNING: dataset may be incomplete.;
 %return; 
 %end; 
 
%mend;

/*test*/
PROC DATASETS library= work KILL NOLIST; RUN;

PROC COPY in= sashelp out= work;
select class; 
RUN;

DATA class;
SET class;
%convert(weight, convert=chgsdrjhs, to=kg, round=.5);
RUN;

