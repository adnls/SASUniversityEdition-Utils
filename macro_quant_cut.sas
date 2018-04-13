/*QUANT_CUT_V4*/

%macro quant_cut_v5(data, var, def, br);
	
	/*****/
	%let def1= %eval(&def.-1);
	%let def2= %eval(&def.-2);

	%if &br.=exclude %then
		%let op = -<;
	%else %if &br. = include %then
		%let op = <-;
	%put &op;

	/*****/


	%if &def.=2 %then
		%do;

			DATA _NULL_;
				bornes=50;
				call symput('bornes', bornes);
			RUN;

		%end;
	%else %if &def. > 2 %then
		%do;

			data _NULL_;
				array txt[&def1.];

				do i=1 to &def1.;
					txt[i]=round((100/&def.)*i, .1);
				end;
				length bornes $300.;
				bornes=catx(' ', of txt[*]);
				keep bornes;
				call symput('bornes', bornes);
			RUN;

		%end;

	/********/
	PROC UNIVARIATE data=&data. noprint;
		var &var.;
		output out=out pctlpts=&bornes. pctlpre=pct;
	RUN;

	/********/


	%if &def.=2 %then
		%do;

			DATA _NULL_;
				SET out;
				borne1=pct50;
				txt2=" ";
				call symput('borne1', borne1);
				call symput('txt2', txt2);
			RUN;

		%end;
	%else %if &def. > 2 %then
		%do;

			DATA _NULL_;
				SET out;
				array borne[*]_ALL_;

				do i=1 to dim(borne);
					call symput(compress('borne'||i), borne[i]);
				end;
				length txt2 $300.;

				if &def.=3 then
					do;
						txt2=cats(catx("&op.", borne[1], borne[2]), "=", borne[1], "'&op'", 
							borne[2]);
						call symput('txt2', txt2);
					end;
				else if &def. > 3 then
					do;
						array part[&def2.]$300.;

						do j=1 to &def2.;
							jj=j+1;
							part[j]=cats(catx("&op.", borne[j], borne[jj]), "=", borne[j], "'&op.'", 
								borne[jj]);
							call symput(cats('part', put(j, 8.)), part[j]);
						end;
						txt2=catx('', of part[*]);
						call symput('txt2', txt2);
					end;
			RUN;

		%end;

	%if &br.=exclude %then
		%do;

			DATA _NULL_;
				SET out;
				array borne[*]_ALL_;

				do i=1 to dim(borne);
					call symput(compress('borne'||i), borne[i]);
				end;
				txt1=cats("low", "-<", borne[1], "=", "low", "'-<'" , borne[1]);
				txt3=cats(borne[&def1.], "-", "high", "=", borne[&def1.], "'-'", "high");
				call symput('txt1', txt1);
				call symput('txt3', txt3);
			RUN;

		%end;
	%else %if &br.=include %then
		%do;

			DATA _NULL_;
				SET out;
				array borne[*]_ALL_;

				do i=1 to dim(borne);
					call symput(compress('borne'||i), borne[i]);
				end;
				txt1=cats("low", "-", borne[1], "=", "low", "'-'" , borne[1]);
				txt3=cats(borne[&def1.], "<-", "high", "=", borne[&def1.], "'<-'", "high");
				call symput('txt1', txt1);
				call symput('txt3', txt3);
			RUN;

		%end;

	Proc format ;
		value quant &txt1. &txt2. &txt3.;
	RUN;

	DATA &data.;
		set &data.;
		format &var._qc&def. $50.;
		&var._qc&def.=put(&var., quant.);
	RUN;

	PROC DATASETS library=work nolist nodetails;
		delete out;
		RUN;
	%MEND;

	/*test*/
PROC DATASETS library=work KILL NOLIST;
	RUN;

PROC COPY in=sashelp out=work;
	select class;
RUN;

%quant_cut_v5(class, age, 4, exclude); 
%tri(class, age_qc4);