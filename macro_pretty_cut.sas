/*CUT_V2*/
%macro cut(data, var, nbm, bn);
	PROC UNIVARIATE data=&data. outtable=out noprint;
		var &var.;
	RUN;

	%let nbm1 = %eval(&nbm.-1);
	%let nbm2 = %eval(&nbm.-2);

	DATA _NULL_;
		set out;
		call symput('mini', _MIN_);
		call symput('maxi', _MAX_);
	RUN;

	%if &nbm. > 2 %then
		%do;

			DATA _NULL_;
				SET &data.;
				array borne[&nbm1.];

				do i=1 to (&nbm1.);
					borne[i]=round(&mini.+((&maxi.-&mini.)/(&nbm.)*(i)), .1);
				end;

				do j=1 to &nbm1.;
					call symput(cats('borne', put(j, 8.)), borne[j]);
				end;
			RUN;

		%end;
	%else %if &nbm.=2 %then
		%do;

			DATA _NULL_;
				SET &data.;
				borne=round(&mini.+((&maxi.-&mini.)/2), .1);
				call symput('borne1', borne);
			RUN;

		%end;
/******/
	%if &bn.=exclude %then
		%do;

			%if &nbm.=2 %then
				%do;
					%let txt = %sysfunc(catx(' ', %sysfunc(compress(low-<&borne1.="low-<&borne1.")), %sysfunc(compress(&borne1.-high="&borne1.-high"))));					
					
					PROC FORMAT ;
						value cut &txt.;					
					RUN;

				%end;
			%else %if &nbm.=3 %then
				%do;
					%let txt = %sysfunc(catx(' ', %sysfunc(compress(low-<&borne1.="low-<&borne1.")), %sysfunc(compress(&borne1.-<&borne2.=%sysfunc(cats("&borne1.", '-<' , "&borne2.")))), %sysfunc(compress(&borne2.-high="&borne2.-high"))));					

					PROC FORMAT ;
						value cut &txt.;
					RUN;

				%end;
			%else
				%do;
					%let txt1 = %sysfunc(compress(low-<&borne1.="low-<&borne1."));
					%let txt3 = %sysfunc(compress(&&borne&nbm1.-high="&&borne&nbm1.-high"));

					%do j=1 %to &nbm2.;
						%let jj = %eval(&j.+1);
						%let part&j.= %sysfunc(compress(&&borne&j.-<&&borne&jj.="&&borne&j.-<&&borne&jj."));
					%end;
					%let txt2 = ;

					%do k=1 %to &nbm2.;
						%let txt2 = &txt2. &&part&k.;
					%end;

					PROC FORMAT ;
						value cut 
	&txt1. &txt2. &txt3.;
					RUN;

				%end;
		%end;
/*********************************/
	%if &bn.=include %then
		%do;

			%if &nbm.=2 %then
				%do;
					%let txt = %sysfunc(catx(' ', %sysfunc(compress(low-&borne1.="low-&borne1.")), %sysfunc(compress( &borne1.<-high="&borne1.<-high"))));					
					
					PROC FORMAT ;
						value cut &txt.;					
					RUN;

				%end;
			%else %if &nbm.=3 %then
				%do;
					%let txt1 = %sysfunc(compress(low-&borne1.="low-&borne1.")); 
					%let txt3 = %sysfunc(compress(&borne2.<-high="&borne2.<-high"));					
					
					DATA _NULL_;
					txt2 = cats(catx('<-', &borne1., &borne2.), "=&borne1.", "'<-'", "&borne2.");
					call symput('txt2', txt2);
					RUN;
					
					PROC FORMAT ;
						value cut &txt1. &txt2. &txt3.;
					RUN;

				%end;
			%else
				%do;
					%let txt1 = %sysfunc(compress(low-&borne1.="low-&borne1."));
					%let txt3 = %sysfunc(compress(&&borne&nbm1.<-high="&&borne&nbm1.<-high"));

					%do j=1 %to &nbm2.;
						%let jj = %eval(&j.+1);
						%let part&j.= %sysfunc(compress(&&borne&j.<-&&borne&jj.="&&borne&j.<-&&borne&jj."));
					%end;
					%let txt2 = ;

					%do k=1 %to &nbm2.;
						%let txt2 = &txt2. &&part&k.;
					%end;

					PROC FORMAT ;
						value cut 
	&txt1. &txt2. &txt3.;
					RUN;

				%end;
		%end;

	DATA &data.;
		set &data.;
		format &var._cut&nbm. $20.;
		&var._cut&nbm.=put(&var., cut.);
	RUN;

%mend;

PROC DATASETS lib=work kill nolist nodetails;
PROC copy in=sashelp out=work;
	select class;
RUN;

%cut(class, height, 2, include);
%tri(class, height_cut2);