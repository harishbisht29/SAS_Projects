Proc Sql;
	Create Table Test_Dataset as 
	Select 
		Workers.Date as WDate,
		Steel.Date as SDate,
		Gnp.Date as GDate
	From 
		Sashelp.Workers Workers, 
		Sashelp.Steel Steel, 
		Sashelp.GNP Gnp;
Run;

%Let Dataset_Name = Test_Dataset;
%Let Column_Name = WDate;

Proc Contents Noprint Data=&Dataset_Name. Out=Column_Metadata;
Quit;

Data Column_Metadata;
	Set Column_Metadata;
	If Upcase(Name) = Upcase("&Column_Name.");
	Keep Name Length Format FormatL FormatD;
Run;