/* Importing New Data Set */
data diabetes_data;
    infile '/Users/hussainvakharwala/Downloads/heart_clinic_records.csv’ dsd missover firstobs=2;
    input age gender bmi blood_pressure cholesterol glucose outcome;
run;

/* Sorting Data Based on Outcome Variable */
proc sort data=diabetes_data;
    by outcome;
run;

/* Defining Variables for Analysis */
%let NumVar=age bmi blood_pressure cholesterol glucose;
%let CatVar=gender;

/* Preliminary Descriptive Analysis */
proc means data=diabetes_data NMISS RANGE MIN Q1 MEDIAN MEAN Q3 MAX STD SKEW MAXDEC=4;
    var &NumVar;
run;

/* Descriptive Stats for Categorical Variables */
proc freq data=diabetes_data;
    tables &CatVar;
run;

/* Histogram and Normality Tests for Continuous Variables */
proc univariate data=diabetes_data normal;
    var &NumVar;
    qqplot / normal;
    histogram;
run;

/* Correlation Matrix */
proc corr data=diabetes_data;
    var &NumVar;
run;

/* Visualizing Continuous Variables */
proc sgpanel data=diabetes_data;
    panelby outcome;
    vbox age / group=outcome;
    vbox bmi / group=outcome;
    vbox blood_pressure / group=outcome;
run;

/* Barplot for Categorical Variable */
proc sgplot data=diabetes_data;
    vbar gender / group=outcome datalabel;
    title "Gender vs. Outcome";
run;

/* Frequency Tables for Categorical Variables */
proc freq data=diabetes_data;
    tables gender*outcome / chisq expected relrisk riskdiff;
run;

/* Normality Test for Categorical Variables */
proc univariate data=diabetes_data normal;
    class outcome;
    var age bmi blood_pressure cholesterol glucose;
run;

/* Wilcoxon Rank Sum Test for Non-Normal Data */
proc npar1way data=diabetes_data wilcoxon;
    class outcome;
    var age bmi blood_pressure cholesterol glucose;
run;

/* Logistic Regression Analysis */
proc logistic data=diabetes_data;
    class gender;
    model outcome(event='1') = age bmi blood_pressure cholesterol glucose gender;
    output out=predicted_values predicted=probabilities;
run;

/* Stepwise Selection for Logistic Regression */
proc logistic data=diabetes_data;
    class gender;
    model outcome(event='1') = age bmi blood_pressure cholesterol glucose gender / selection=stepwise sle=0.05 sls=0.05;
    output out=stepwise_predicted predicted=probabilities;
run;

/* Decision Tree Model */
proc hpsplit data=diabetes_data;
    class outcome gender;
    model outcome = age bmi blood_pressure cholesterol glucose;
    grow entropy;
    prune costcomplexity;
run;

/* Confusion Matrix for Logistic Model */
proc freq data=stepwise_predicted;
    tables outcome*predicted / nopercent norow nocol;
run;

/* ROC Curve for Logistic Model */
proc logistic data=diabetes_data plots(only)=roc;
    class gender;
    model outcome(event='1') = age bmi blood_pressure cholesterol glucose;
run;

/* Output Results */
ods pdf file='/Users/hussainvakharwala/Downloads/Diabetes_Analysis_Report;
title 'Diabetes_Analysis_Report';
proc print data=predicted_values;
run;
ods pdf close;
