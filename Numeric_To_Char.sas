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
/* Represents Numeric part of format which comes after format name	 */
	format_tail = Input(Cats(Put(FormatL,3.),".",Put(FormatD,3.)),Best.);	
	Keep Name Length Format FormatL FormatD format_tail;
Run;