




%MACRO Analyze_Code(Code_Location=, Analyzed_Output=);
	proc scaproc; record  "&Analyzed_Output." ; run;
		%Include "&Code_Location.";
	proc scaproc; write; run;
%MEND;


%Analyze_Code(
	Code_Location=/folders/myfolders/Test.sas,
	Analyzed_Output=/folders/myfolders/out.txt
	);
 