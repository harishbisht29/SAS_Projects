Options Symbolgen MLogic;

/* %Let Var_Start_String = Name; */
/* %Let Dataset_Name = Sashelp.Baseball; */
/* %Let Column_Name = Name; */

%Macro Get_Macro_Iterators(Var_Start_String, Dataset_Name, Column_Name);
	Proc Sql;
		Select &Column_Name. into: %Sysfunc(Cats(&Var_Start_String.,1))- From &Dataset_Name.;
		Select Count(*) into:Macro_Var_Count Trimmed From &Dataset_Name.;
		%Put &Macro_Var_Count.;
	Quit;
%Mend;

%Macro Clear_Macro_Iterators(Var_Start_String, Macro_Var_Count);
	%Do I = 1 %To &Macro_Var_Count.;
		%Symdel %Sysfunc(Cats(&Var_Start_String.,&I.));
	%End;
%Mend;

/* %Clear_Macro_Iterators(Name, 322); */
