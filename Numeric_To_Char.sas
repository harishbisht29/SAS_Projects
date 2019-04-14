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
	Length Format_Text $1000.;
	
	Set Column_Metadata;
	If Upcase(Name) = Upcase("&Column_Name.");
	
/* Represents Numeric part of format which comes after format name	 */

	format_tail = Input(Cats(Put(FormatL,Best.),".",Put(FormatD,Best.)),Best.);	
	
	If Format = "" And format_tail Eq 0 Then Do;
		Format_Text = Cats(Put(Length,Best.),".");
	End;
	Else If Format Ne "" And format_tail Eq 0 Then Do;
		Format_Text = Cats(Format,".");
	End;
	Else If Format_tail Ne 0 Then Do;
		Format_Text = Cats(Format,Put(format_tail,Best.),".");
	End;
	
	Keep Name Length Format FormatL FormatD format_tail Format_Text;
	
	Call Symput("Format_Text",Format_Text);
Run;

%Put &Format_Text.;

