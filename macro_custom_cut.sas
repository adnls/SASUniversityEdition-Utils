/*CUSTOM CUT*/
%MACRO custom_cut(data, var, bornes, bornes1);
	
DATA _NULL_;
	format a1 $100.;
	a1="&bornes.";
	
	xx=1;
	do while((scan(a1, xx, ' ')^=.) or (scan(a1, xx, ' ')^=''));
		call symputx(cats('borne', put(xx, 8.)), scan(a1, xx, ' '));
		xx=xx+1;
	end;
	
	call symputx('xx', xx);
	call symputx('xxx', xx-1);
	call symputx('xxxx', xx-2);
RUN;

	%if &bornes1.=exclude %then
		%do;
			%let txt1 = %sysfunc(compress(low-<&borne1.="low-<&borne1."));
			%let txt3 = %sysfunc(compress(&&borne&xxx.-high="&&borne&xxx.-high"));
			
			%if &xx.=2 %then 
				%do;
				
					DATA _NULL_;
						txt = catx(" ", "low-<&borne1.=low'-<'&borne1.", "&borne1.-high=&borne1.'-'high");
						call symput('txt', txt);
					RUN;
					
					PROC FORMAT;
						value custom &txt.;
					RUN;
					
					DATA &data.;
						set &data.;
						format &var._cc&xx. $50.;
						&var._cc&xx.=put(&var., custom.);						
					RUN;
					%goto exit;
					
				%end;			
			%else %if &xx.=3 %then
				%do;

					DATA _NULL_;
						txt2=cats(catx('-<', &borne1., &borne2.), "=&borne1'-<'&borne2.");
						call symput('txt', txt2);
					RUN;

				%end;
			%else
				%do;

					%do j=1 %to &xxxx.;
						%let jj = %eval(&j.+1);
						%let part&j.= %sysfunc(compress(&&borne&j.-<&&borne&jj.="&&borne&j.-<&&borne&jj."));
					%end;
					
					%let txt = ;
					%do k=1 %to &xxxx.;
						%let txt = &txt. &&part&k.;
					%end;
				%end;
		%end;		
	%else %if &bornes1.=include %then
		%do;
			%let txt1 = %sysfunc(compress(low-&borne1.="low-&borne1."));
			%let txt3 = %sysfunc(compress(&&borne&xxx.<-high="&&borne&xxx.<-high"));

			%if &xx.=2 %then 
				%do;
				
					DATA _NULL_;
						txt = catx(" ", "low-&borne1.=low'-'&borne1.", "&borne1.<-high=&borne1.'<-'high");
						call symput('txt', txt);
					RUN;
					
					PROC FORMAT;
						value custom &txt.;
					RUN;
					
					DATA &data.;
						set &data.;
						format &var._cc&xx. $50.;
						&var._cc&xx.=put(&var., custom.);
					RUN;
					%goto exit;
				
				%end;
			%else %if &xx.=3 %then
				%do;

					DATA _NULL_;
						txt2=cats(catx('<-', &borne1., &borne2.), "=&borne1'<-'&borne2.");
						call symput('txt', txt2);
					RUN;

				%end;
			%else
				%do;

					%do j=1 %to &xxxx.;
						%let jj = %eval(&j.+1);
						%let part&j.= %sysfunc(compress(&&borne&j.<-&&borne&jj.="&&borne&j.<-&&borne&jj."));
					%end;
					%let txt = ;

					%do k=1 %to &xxxx.;
						%let txt = &txt. &&part&k.;
					%end;

				%end;
		%end;

PROC FORMAT;
	value custom &txt1. &txt. &txt3.;
RUN;

DATA &data.;
	set &data.;
	format &var._cc&xx. $50.;
	&var._cc&xx.=put(&var., custom.);
RUN;

%exit:
%put NOTE: Variable &var._cc&xx. has been successfully created.;
%MEND;

/*demo*/
PROC DATASETS lib=work KILL NOLIST;
	RUN;

PROC COPY in=sashelp out=work;
	select class;
RUN;

%custom_cut(class, age, 14, exclude);
%tri(class, age_cc2);
/*voir affichage ac valeurs si possible*/