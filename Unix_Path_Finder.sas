Filename myfile "/folders/myfolders/Test.sas";

Data Test;
	Length Line $1000.;
	infile myfile;
	input;
	line = _infile_;
/* 	line = 'Libname Test "/staging/staging2/tis_development/myfile.sas"    Nothing Else in this line'; */
	line = Compress(line, """");
	line = Compress(line, '''');
	put line=;
	If _N_ = 1 Then Pattern_Num = PRXPARSE('#(/[\w|.]*)+( ?)#I');
	Retain Pattern_num;
/* 	first_pattern_index = PRXMATCH(Pattern_Num, line); */
	Length Location $1000.; 
	Call PRXSUBSTR(Pattern_Num ,line,START,LENGTH);
	If Start ne 0 Then Do;
		Location = SUBSTRN(line, Start, Length);
	End;
Run;