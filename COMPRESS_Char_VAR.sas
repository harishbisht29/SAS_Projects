Data Baseball;
	Length Div $100.;
	Set Sashelp.Baseball;
Run;
/*  */
/* %Let Dataset_Name = Work.Baseball; */
/* %Let Column_Name = Name; */
/* %Let Output_Dataset = Compressed_Baseball; */

%Macro Compress_Char_Column(Dataset_Name, Column_Name, Output_Dataset);

	Proc Sql;
		Create Table All_Compressed_Len As 
		Select &Column_Name., Length(&Column_Name.) As Compressed_Len From &Dataset_Name.
		Group By Length(&Column_Name.);
		
		Select Max(Compressed_len) Into: Compressed_Length Trimmed From All_Compressed_Len;
		%put Compressed Length is found to be &Compressed_Length.;
		
		Drop Table All_Compressed_Len;
	Quit;
	
	Data &Output_Dataset.;
		Length &Column_Name. $&Compressed_Length.;
		Set &Dataset_Name.;
	Run;
	
%Mend;

%Compress_Char_Column(Baseball, Div, New_baseball);


