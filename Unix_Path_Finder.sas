
Data Test;
	String = 'Libname Test "/staging/staging2/tis_development/myfile.sas"    Nothing Else in this line';
	String = Compress(String, """");
	String = Compress(String, '''');
	put String=;
	If _N_ = 1 Then Pattern_Num = PRXPARSE('#(/[\w|.]*)+( |")#I');
	
/* 	first_pattern_index = PRXMATCH(Pattern_Num, String); */
	Length Location $1000.; 
	Call PRXSUBSTR(Pattern_Num ,String,START,LENGTH);
	If Start ne 0 Then Do;
		Location = SUBSTRN(String, Start, Length);
	End;
Run;