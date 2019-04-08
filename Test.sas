/* This is a Test Sas Code. */

Data _NULL_;
	Location = "/usr/bin/sas/nothing.sas";
Run;

Libname home '/usr/library/nothing';

proc import data="/home/Development/Test.xlsx";
Quit;

%include "/data/include.sas";