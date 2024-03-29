OPTIONS NOCENTER MPRINT SYMBOLGEN COMPRESS=BINARY FULLSTIMER
        MSTORED SASMSTORE=MACIN SOURCE2;

%SYSMSTORECLEAR;
LIBNAME macin ('~/MACROS/') ACCESS=READONLY;


%let DS=sashelp.cars;
%let Y=MPG_Highway;
%let X=Horsepower;

*ODS TRACE ON / LABEL ;
data test;
  set sashelp.cars;
  %rcspline(Horsepower,115,170,210,245,340);
run;
*ODS TRACE off;

options orientation=landscape;

ods EXCEL file="~/PLM/TEST7F.xlsx"
        style=SASWEB
          OPTIONS (fittopage = 'yes'
                   frozen_headers='no'
                   autofilter='none'
                   embedded_titles = 'YES'
                   embedded_footnotes = 'YES'
                   zoom = '100'
                   orientation='Landscape'
                   Pages_FitHeight = '100'
                   center_horizontal = 'no'
                   center_vertical = 'no'
              );
ods EXCEL options(sheet_interval="none"
            sheet_name="Contents"
           );
PROC CONTENTS DATA=sashelp.cars order=collate ;
TITLE PROC CONTENTS for sashelp.cars;
RUN;
TITLE;

%BREAK;

ods EXCEL options(sheet_interval="none"
            sheet_name="&X."
           );

TITLE Optimized Restricted Cubic Spline;
PROC GENMOD DATA=TEST;
 MODEL MPG_HIGHWAY = horsepower horsepower1
                     horsepower2 horsepower3 / dist=normal link=identity;
 OUTPUT OUT=SPLINE PRED=FIT;
 RUN;

 PROC SORT DATA=spline;
   BY horsepower;
 run;

 proc sgplot DATA=spline;
   SCATTER x=horsepower y=MPG_Highway;
   SERIES x=horsepower y=Fit / lineattrs=(thickness=3 color=red);
   XAXIS GRID;
   YAXIS GRID;
   TITLE Restricted Cubic Sline;
   TITLE2 x=horsepower y=MPG_Highway;
run;
TITLE;

%BREAK;
ods EXCEL options(sheet_interval="none"
            sheet_name="LOESS PLOTS"
           );


%LET NPLOTS=7; %LET ROWS=3;
%LET LIB=SASHELP; %LET DS=cars;
%LET DV=MPG_Highway;

%LET vars = Cylinders EngineSize Invoice Length MSRP Weight Wheelbase;

TITLE Loess Output;
%MACRO PLOTIT;
%LET I = 1; /* INITIALIZE &I. */

  %DO %UNTIL(%SCAN(&VARS,&I.,%STR( ) ) = %STR( ) );
    %LET VAR=%SCAN(&VARS,&I.,%STR( ) );
    %DO PLT_STREAM= 1 %TO &NPLOTS;
      %LET PLT_&PLT_STREAM. = %SCAN(&VARS,&I.,%STR( ) );
      %LET I = %EVAL(&I. + 1);
    %END;

  PROC SGSCATTER DATA=&LIB..&DS.;
    PLOT &DV. * (
    %DO PLT_STREAM= 1 %TO &NPLOTS;
      &&PLT_&PLT_STREAM.
    %END; )
      / MARKERATTRS=(SIZE=2 COLOR=BLACK) GRID
        LOESS=(SMOOTH=0.5 ALPHA=0.05 CLM
        LINEATTRS=(COLOR=RED THICKNESS=.5))
        ROWS=&ROWS.
        ;
        TITLE BOLD BOX=1 "SGSCATER PLOTS";
      RUN;
  %END;
%MEND; /* END MACRO */
%PLOTIT;
TITLE;
%BREAK;

ODS EXCEL CLOSE;

