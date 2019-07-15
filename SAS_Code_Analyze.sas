




%MACRO Analyze_Code(Code_Location=, Analyzed_Output=);
	proc scaproc; record attr  "&Analyzed_Output." ; run;
		%Include "&Code_Location.";
	proc scaproc ; write; run;
%MEND;


%Analyze_Code(
	Code_Location=/folders/myfolders/Test.sas,
	Analyzed_Output=/folders/myfolders/out.txt
	);
 
 
 
 
 /*----------------------------------------------------------------------
* SAMPLE code for parsing the output from SCAPROC and creating a  
* dataset with inputs and output.
* 
* Macro variables used:
* scaprocout - textual output of SCAPROC to be analyzed
*
* Librefs used:
* mywork - library where the output data set will be stored
*
* SAS INSTITUTE INC. IS PROVIDING YOU WITH THE COMPUTER SOFTWARE CODE
* INCLUDED WITH THIS AGREEMENT ("CODE") ON AN "AS IS" BASIS, AND
* AUTHORIZES YOU TO USE THE CODE SUBJECT TO THE TERMS HEREOF.  BY USING
* THE CODE, YOU AGREE TO THESE TERMS.  YOUR USE OF THE CODE IS AT YOUR
* OWN RISK.  SAS INSTITUTE INC. MAKES NO REPRESENTATION OR WARRANTY,
* EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NONINFRINGEMENT AND
* TITLE, WITH RESPECT TO THE CODE.
* 
* The Code is intended to be used solely as part of a product
* ("Software") you currently have licensed from SAS Institute Inc. or
* one of its subsidiaries or authorized agents ("SAS"). The Code is
* designed to either correct an error in the Software or to add
* functionality to the Software, but has not necessarily been tested. 
* Accordingly, SAS makes no representation or warranty that the Code
* will operate error-free.  SAS is under no obligation to maintain or
* support the Code.
* 
* Neither SAS nor its licensors shall be liable to you or any third
* party for any general, special, direct, indirect, consequential,
* incidental or other damages whatsoever arising out of or related to
* your use or inability to use the Code, even if SAS has been advised of
* the possibility of such damages.
* 
* Except as otherwise provided above, the Code is governed by the same
* agreement that governs the Software.  If you do not have an existing
* agreement with SAS governing the Software, you may not use the Code.
*
*----------------------------------------------------------------------*/

%let scaprocout=;
libname mywork "";

      *******************************************************;
      *** PARSE SCAPROC OUTPUT                            ***;
      *******************************************************;

      filename scafile "&scaprocout";
      data mywork.scadata;
        infile scafile lrecl=1000 length=linelength end=eof;
        input scaline $varying1000. linelength;
      run;

      data mywork.scadata1;
        infile scafile lrecl=1000 length=linelength end=eof;
        input scaline $varying1000. linelength;
      
		* change / to \ for windows;
        * Ignoring SASTemp outputs;
        if index(scaline,"JOBSPLIT")>0 and index(scaline,"\sas_tmp\")= 0 then output;
      run;

      data mywork.scadata2;
        set mywork.scadata1;
        retain obj_type_pattern type_pattern lib_path_pattern xpt_libname_pattern ttf_pattern;
        length type obj_type $200;
        
        if _n_=1 then do;
           type_pattern = prxparse("/(INPUT|OUTPUT|UPDATE|LIBNAME)/i");
           obj_type_pattern = prxparse("/:\s*\w+\s/i");
		   * Change pattern to include all characters and spaces between quotes;
           lib_path_pattern = prxparse("/(\'|\"")+.*(\'|\"")+/i");
           xpt_libname_pattern = prxparse("/LIBNAME .* XPORT .*.xpt/i");
		   ttf_pattern = "/.*\.ttf/";
        end;
        
        if prxmatch(type_pattern,scaline)>0 and prxmatch(ttf_pattern,scaline)=0 then do;
           
           * IDENTIFY TYPE;
           call prxsubstr(type_pattern,scaline,type_start,type_len);
           if type_start>0 then TYPE=strip(substrn(scaline,type_start,type_len));
           
           * IDENTIFY OBJECT TYPE;
           call prxsubstr(obj_type_pattern,scaline,obj_type_start,obj_type_len);
           if obj_type_start>0 then OBJ_TYPE=strip(compress(strip(substrn(scaline,obj_type_start,obj_type_len)),":"));
           
           * LIB_PATH;
           call prxsubstr(lib_path_pattern,scaline,lp_start,lp_len);
           if lp_start>0 then lib_path=compress(strip(substrn(scaline,lp_start,lp_len)),"'""");
		   put lib_path=;

           * LIB name and xport engine;
           call prxsubstr(xpt_libname_pattern,scaline,lp_start,lp_len);
           if lp_start>0 then lib_engine="XPORT";
           
           * IDENTIFY OBJECT;
		   put type=;
           if type in ("INPUT") then 
              obj=substr(scaline,type_start + 5); * 5 represents length of INPUT and UPDATE;
           else if type in ("OUTPUT","UPDATE") then
              obj=substr(scaline,type_start + 6); * 6 represents length of OUTPUT;
           else if type in ("LIBNAME") then
              obj = scan(strip(substr(scaline,type_start + 7)),1," "); * 7 represents length of LIBNAME;
              
           * Suppress extra characters;
			put obj=;
           obj = compress(obj,"*");
           
           len = length(strip(obj));
           loc = find(strip(obj),"/",-1000);
           if len = loc then obj = substr(obj,1,length(strip(obj))-1);
           
           * Suppress EXTRA LIB WORDS - SEQ, MULTI;
           if indexw(obj,"SEQ")>0 then obj = tranwrd(obj,"SEQ","");
           if indexw(obj,"MULTI")>0 then obj = tranwrd(obj,"MULTI","");
           
           * Parse DATASET DATA and LIBNAME;
           if obj_type in ("DATASET","CATALOG","ITEMSTORE") then do;
              lib_name= scan(obj,1,".");
              if obj_type in ("DATASET","CATALOG") then obj_name = scan(obj,2,".");
              else if obj_type in ("ITEMSTORE") then obj_name=scan(obj,-1,".");
           end;
           else if obj_type in ("LIBNAME") then do;
              /* Ignore any libnames with no path. This fixes the issue where a libname references a
                  second libname i.e. libname a (b) */
              if not missing( lib_path ); 
              lib_name = obj;
           end;
           
           * CONVERT obj_name to LOWERCASE;
           if strip(type)^="FILE" then obj_name=lowcase(obj_name);
           
           sec_order_id = _n_;

           * OUTPUT ONLY JOBSPLIT RECORDS WITH I/O/U DEFINITIONS;       
           output;
        end;
        
        * DROP EXTRA VARIABLES;
        drop type_pattern type_start type_len;
        drop obj_type_pattern obj_type_start obj_type_len;
        drop lib_path_pattern lp_start lp_len xpt_libname_pattern ttf_pattern;
      run;
      
      proc sql;
       * Parse Lib Paths;
       create table mywork.lib_info as
          select distinct lib_name, lib_engine, lib_path
             from mywork.scadata2
                where obj_type="LIBNAME"
                order by lib_name;
       
       * Merge Lib Path information back with data;
       create table mywork.io_info as
          select a.type, a.obj_type, a.lib_name, a.obj_name, b.lib_path, a.obj, a.sec_order_id
             from mywork.scadata2 a LEFT JOIN mywork.lib_info b
                ON strip(a.lib_name) = strip(b.lib_name)
                where a.obj_type ^= "LIBNAME"
                      and b.lib_engine ^= "XPORT" /* Drop any data objects used by a transport libname */
                order by a.type, a.obj_type;
      quit;

      /* Remove all the input references that were outputs from this JOB */
      proc sql;
         create table mywork.firstRecord as
            select * from mywork.io_info a
               where strip(type) = "OUTPUT"
               and sec_order_id = 
                    ( select min(sec_order_id) from mywork.io_info b
                          where a.obj_name = b.obj_name
                           and a.lib_path = b.lib_path );
      
      
         delete from mywork.io_info a
            where strip(type) = "INPUT"
            and exists 
               ( select 1 from mywork.firstRecord b
                    where a.obj_name = b.obj_name
                     and a.lib_path = b.lib_path );
      
      quit;

      /* Remove the sca proc output file */
      proc sql;
         delete from mywork.io_info a
            where strip(type) = "OUTPUT"
            and strip(obj) = "&scaprocout";
      quit;

      * Exclude MYWORK, WORK, SASHELP and SASUSER content from the job;
      data mywork.io_info2;
        retain order_id sec_order_id;
        set mywork.io_info;
		* upcase and change / to \ for windows;
        where strip(upcase(lib_name)) not in ("MYWORK","WORK","SASHELP","SASUSER") and index(lib_path,'\sashelp')=0 ;
        length file_path $500;
      
		* change / to \ for windows;
        if obj_type="DATASET" then file_path=strip(lib_path) || "\" || strip(obj_name) || ".sas7bdat";
        else if obj_type="FILE" then file_path=strip(obj);
		* KIA 03/21/2016 change / to \ for windows;
        else if obj_type="CATALOG" then file_path=strip(lib_path) || "\" || strip(obj_name) || ".sas7bcat";
        else file_path = strip(obj);
      
        if strip(type)="INPUT" then order_id=3;
        else if strip(type)="OUTPUT" then order_id=4;
        
        keep order_id sec_order_id obj_type type file_path;
      run;
      
      proc sort data=mywork.io_info2 out=mywork.io_info2 nodupkey;
       by order_id sec_order_id type obj_type file_path;
       where length(strip(file_path))>1;
      run;
      
      * Exclude API Macros and any other content located in /sfw location;
	  
      data mywork.io_info3;
       set mywork.io_info2;
       by order_id sec_order_id type obj_type file_path;
	   * Change for windows;
        where index(upcase(file_path),"C:\WINDOWS")=0 ; * Exclude list from the output job;
       
       * SINCE INPUT CAN BE FILE OR CONTAINER, BUT PARSER IDENTIFY EXACT FILES, SO ONLY FILES;
       * OUTPUT CAN ONLY BE CONTAINER;
       if strip(type) in ("INPUT","OUTPUT") then obj_type="FILE";
	   * For PC SAS OUTPUTS should be FILE not CONTAINER
       * else if strip(type)="OUTPUT" then obj_type="CONTAINER";
      
		* change / to \ for windows;
       if index(file_path,"\\")>0 then file_path=tranwrd(file_path,"\\","\");
      
       file_path=strip(file_path);
      
      run;
      

      * COLLECT ALL THE REQUIRED JOB INFORMATION;
      data mywork.job_info(drop=order_id sec_order_id);
        set mywork.io_info3;
		*set mywork.job_info mywork.task mywork.io_info4;
		*set mywork.job_info mywork.io_info2;
        by order_id sec_order_id;
		sas_task = "&programPath";
      run;