Data Baseball;
	Length Name $100.;
	Set Sashelp.Baseball;
Run;

%Let Dataset_Name = Work.Baseball;

Proc Contents Noprint Data= &Dataset_Name. Out=&Dataset_Name._Column_Details;
Run;

Proc Sql;
	Create Table &Dataset_Name._Char_Column_Details As
	Select Distinct Name, Length as Variable_Length 
	From
	&Dataset_Name._Column_Details
	Where Type=2;
Quit;

Data &Dataset_Name._Lengths;
	Set &Dataset_Name.;
	
Run;

Data &Dataset_Name.Char_Vars;
	Set &Dataset_Name.;
	Length  Var_Name $100.;
	Array allChars[*] _character_;

Run;

