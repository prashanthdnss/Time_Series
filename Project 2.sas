/*importing data till 1080 left 15 days to forecast*/
DM 'LOG;CLEAR;OUT;CLEAR;';
options formdlim='-' pageno=min nodate;
title 'Time Series Analysis';
PROC IMPORT OUT= WORK.power
            DATAFILE= "/home/u54014787/Predictive Analytics/Project 2/Final_cleaned_dataset.xlsx"
            DBMS=xlsx REPLACE;
     GETNAMES=Yes;
RUN;

proc print data=power;
title "power";
run;

/*plotting data*/
Symbol1 v=line I=Join;
proc gplot data = power;
plot Value*Day ;
title "Power consumption data";
run;
quit;

/*simple expo smoothing*/
proc forecast data = power method = expo trend=2 lead = 15 outlimit out=forecast;
    var Value;

proc print data = forecast;
run;

/*add winters*/
proc forecast data = power method = addwinters seasons = day 
        trend=2 lead=15 outlimit out=forecast;
	var Value;
	id Day;
run;

proc print data = forecast;   
run;

/*holt exponential smoothing using weight(alpha)*/
proc forecast data=power out=myout1 /*outfull*/ trend = 2 
  method=Winters 
  weight = .1 lead=15 /*outlimit*/
  out1step outest=est1 interval = day;
  id Day;
  var Value;
run;

proc print data=myout1;
  title2 "myout1";
  run;

/*another method*/
proc forecast data = power method = Winters seasons = 365 trend=1 weight = (0.2, 1, 0) lead=15 outlimit out=forecast; 
var Value; id Day; 
run; 
proc print data = forecast; 
run;


/*adf test*/
proc arima data = power;
identify var = Value(1) stationarity = (adf = 2);
title "ARIMA Stationarity Analysis";
run;

/*recommended models using scan*/
proc arima data = power;
identify var = Value(1) scan;
title "First Difference";
run;


proc arima data = power;
identify var = Value(1);
estimate q=(1,2,3) noconstant printall ;
forecast lead=15 out=pred;
title "Moving Average model order = 3";
run; 






/*extra to do*/

/*Arima models*/
proc print data=power2;
   Data power2;
   Set power;
   Z = Dif1(Value);
   Lny=log(Value);
run;

Symbol1 v=line I=Join;
proc gplot data = power2;
plot Z*Day ;
title "Power consumption data";
run;
quit;

Symbol1 v=line I=Join;
proc gplot data = power2;
plot Lny*Day ;
title "Power consumption data";
run;
quit;

proc arima data=work.power2; 
identify var=Lny; 
identify var=Lny(1);
identify var=Lny(365);
identify var=Lny(1,365);
run;

proc arima data=work.power2;
identify var=Lny(1);
estimate q=(1,2,3) noconstant printall plot;
forecast lead=12 out=pred;
run;

proc print data=pred;
run;

data new_data;
set pred;
y= exp(Forecast);
l95 = exp(L95);
u95 = exp(U95);
forecast_new = exp( forecast + std*std/2 );
proc print data=new_data;
run;

/*diff*/
proc arima data=work.power2; 
identify var=Z; 
identify var=Z(1);
identify var=Z(365);
identify var=Z(1,365);
run;

proc arima data=work.power2;
identify var=Z;
estimate q=(1,2,7) noconstant printall plot;
forecast lead=12 out=pred;
run;

proc print data=pred;
run;


proc arima data=work.power2; 
identify var=Value; 
identify var=Value(1);
identify var=Value(365);
identify var=Value(1,365);
run;

proc arima data=work.power2;
identify var=Value;
estimate q=(1,2,7) noconstant printall plot;
forecast lead=12 out=pred;
run;

proc print data=pred;
run;









