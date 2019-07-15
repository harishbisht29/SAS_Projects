proc scaproc; record '/folders/myfolders/out.txt' grid 'gridout.txt'; run;
data a;
 input x y z @@; cards;
1 2 3 4 5 6 7 8 9
run; 

proc summary data=a;
 var x;
 output out=new1 mean=mx;
 run;
proc summary data=a;
 var y;
 output out=new2 mean=my;
 run;
proc summary data=a;
 var z;
 output out=new3 mean=mz;
 run;
proc scaproc; write; run;

 