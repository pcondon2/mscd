/****
Metro State College  TZPINCP.SQL 
*****/

set serveroutput on size 100000 
set termout on
set feedback on
set echo on
/*-----------------------*/
/* Global Bind Variables */
/*-----------------------*/

Variable brun_type       varchar2(1);  
Variable bAuditFlag      varchar2(1);   
Variable bOneUpNum       NUMBER;       
Variable bFatalflag      varchar2(1);  
Variable bUNIX_command   varchar2(200);
Variable bFileName       varchar2(50);
Variable berrString     varchar2(1000);  

Variable bInFileName     varchar2(100);
Variable bOUTFileName    varchar2(100);

/*---------------------------------------*/
/* drop temporary table from previous    */
/* runs                                  */
/*---------------------------------------*/

    drop table tzpincp_temp;

/*---------------------------------------*/
/* create temporary table for formatting */
/* file output.                          */
/*---------------------------------------*/

    create table tzpincp_temp(
    pidm number,
    term_code varchar2(6),
    seq_number number,
    record_text varchar2(1100));

declare
 
   /* Input and output directories */
   IN_DIR  CONSTANT VARCHAR2(50):='/transfer01/studhealth/infile';    
   OUT_DIR CONSTANT VARCHAR2(50):='/transfer01/studhealth/outfile';  
     
      l_output   utl_file.file_type;
      rec_buff   varchar2(1100);
      lineNo     number;
      ret_code   varchar2(1);
      ret_record tzrimp2%rowtype;
      
      batch_id   varchar2(9);

/*-------------------------------------------------*/
/* Function that determines if there are duplicate */
/* Id s in the import file.                        */
/* Return:                                         */
/*   TRUE - there are duplicate ids                */
/*   FALSE - there are no duplicates               */
/*-------------------------------------------------*/
FUNCTION check_duplicates return BOOLEAN
IS
   dup_flag VARCHAR2(1);
begin
     select distinct 'x' INTO dup_flag
     from (select distinct tzrimp2_studentid stu_id
     from tzrimp2
     group by tzrimp2_studentid
     having count(tzrimp2_studentid) > 1) duplicates;
     
     return(TRUE);
              
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
       return(FALSE);
end check_duplicates;
     
/************************************************************************

Function to return both the record type and record contents of a data record.

Parameters 
    rec_buff  Single record from data file
    table_rec Record containing individual columns of tzrimp2
    
Return Values:
    tzrimp2 rowtype for data record.
    
Return Codes:
    H  Header Record
    T  Trailer Record
    D  Data Record
    E  Unknown Record Type
**************************************************************************/

function format_line( rec_buff varchar2, table_rec IN OUT tzrimp2%ROWTYPE)return VARCHAR2
is
  ret_code varchar2(1);
begin
      /*-------------------------------------------------------*/
      /* Do not return data if either header or trailer record */
      /*-------------------------------------------------------*/
      if 'H'= substr(rec_buff,1,1) then 
           return('H') ;
      end if;
      if 'T'= substr(rec_buff,1,1) then 
          return('T'); 
      end if;
          
      /*-------------------------------*/
      /* extract data from data record */
      /*-------------------------------*/
      if 'D'= substr(rec_buff,1,1) then 
           table_rec.tzrimp2_from_term         := substr(rec_buff,77,6);
           table_rec.tzrimp2_STUDENTID         := substr(rec_buff,83,9); 
	         table_rec.tzrimp2_payment_type      := substr(rec_buff,92,1);
           table_rec.tzrimp2_payment_status    := substr(rec_buff,93,1);
            return('D');
       else
       /* Not a valid record */
           return('E');
       end if;  
end format_line;

/*****************************************************************************/                                                                           /* Procedure to update compliance table from import file.  This procedure    */
/* updates the both the payment type and payment status codes in the         */
/* insurance compliance table.  Students are identified by their student id  */
/* and start term from the import file.                                      */
/*****************************************************************************/                                                       
procedure update_import                                                                                  
is                                                                                                                              
  ret_term_code number;                                                                                                         
begin                                                                                                                           
                                                                                                                                
     /*------------------------------------------*/                                                                               
     /* update ins comp table with imported data */                                                                               
     /*------------------------------------------*/ 
                                                                              
            update tzrincp
            set (tzrincp_payment_type, 
                 tzrincp_payment_status,
                 tzrincp_activity_date,
                 tzrincp_user) = 
                 (select tzrimp2_payment_type,
                         tzrimp2_payment_status,
                         sysdate,
                         'ECI_SELECT_IMPORT'
                    from tzrimp2                                                                                    
                   where tzkar04.f_m_get_pidm(tzrimp2_studentid) = tzrincp_pidm and                               
                         tzrimp2_from_term = tzrincp_from_term)                                                                    
            where (tzrincp_pidm, tzrincp_from_term) in 
                  (select tzkar04.f_m_get_pidm(tzrimp2_studentid),tzrimp2_from_term                                                                                         from tzrimp2
                    where tzkar04.f_m_get_pidm(tzrimp2_studentid) = tzrincp_pidm 
                      and tzrimp2_from_term = tzrincp_from_term);
 
end update_import;                                                                 

/************************************************************************
Procedure to insert insurance data from the clearing house into import
collector table.  
************************************************************************/
procedure insert_line( table_rec tzrimp2%ROWTYPE)
is
  ret_term_code number;
begin
      insert into tzrimp2(tzrimp2_from_term ,    
                          tzrimp2_STUDENTID ,     
                          tzrimp2_payment_type , 
                          tzrimp2_payment_status,
                          tzrimp2_activity_date)
      values(table_rec.tzrimp2_from_term ,  
             table_rec.tzrimp2_STUDENTID  ,   
             table_rec.tzrimp2_payment_type ,
             table_rec.tzrimp2_payment_status ,
             sysdate);
      commit;
end insert_line;

/*--------------------------------------------------------------------*/
/* Format records and insert into temporary table for file generation */
/*--------------------------------------------------------------------*/
       
procedure build_export_table( audit_flag varchar2)
       is
          batch_id varchar2(9);
          record_count number;

       begin
       
          /* Pending Students  */
          
          /* Assign batch Id */
          batch_id := to_char(sysdate,'yyyyddd') || '01';
       
          record_count := 0;
          select count(*) into record_count
               from tzrincp, spriden
              where tzrincp_pidm = spriden_pidm    
                and tzrincp_from_term in (select * from TABLE(gzpparm.f_col_getparm(&2,'02'))) and
                    spriden_change_ind is null;

          /*--------------------------------------------------------*/       
          /* create header, data, and trailer records in that order */
          /*--------------------------------------------------------*/
          insert into tzpincp_temp(pidm, term_code, seq_number,record_text)
          select  0,
               '000000',
               1,
              'H'                                   ||                          
              to_char(sysdate,'yyyyddd')            ||      
              decode(audit_flag,'U','P','T')        ||                         
              'MSCD'                                ||                           
              rpad(:bFileName,29)                   ||           
              '1629196324'                          ||                       
              ltrim(to_char(record_count,'000000')) ||
              'P'                          
          from dual
          union
          select spriden_pidm,
              tzrincp_from_term,
              2,
              'D'                                                  ||   /* record type    */
              rpad(tzkar01.remove_prefix(spriden_first_name),15)   ||   /* first name     */
              rpad(tzkar01.remove_suffix(spriden_last_name),60)    ||   /* last name      */
              substr(tzrincp_from_term,1,6)                        ||   /* starting term  */
              rpad(tzkar04.f_m_get_id(tzrincp_pidm),9)             ||   /* student ID     */
              substr(tzrincp_payment_type,1,1)                     ||   /* payment type   */
              substr(tzrincp_payment_status,1,1)                        /* payment status */
          from  tzrincp, spriden
          where tzrincp_pidm = spriden_pidm and
                spriden_change_ind is null  and
                tzrincp_from_term in (select * from TABLE(gzpparm.f_col_getparm(&2,'02')))
          UNION
          select 0,
              '000000',
              3,
             'T'                                    ||      
              to_char(sysdate,'yyyyddd')            ||     
              'MSCD'                                ||
              ltrim(to_char(record_count,'000000'))
          from dual;
       
 end build_export_table;

/*-------------------------------*/
/* Import file into the database */
/*-------------------------------*/
procedure import_data
is
   
   l_output utl_file.file_type;
   rec_buff varchar2(1100);
   lineNo           number;
   ret_code varchar2(1);
   ret_record tzrimp2%rowtype;
      
   begin
   dbms_output.put_line('start');
   l_output := utl_file.fopen('/transfer01/studhealth/infile', :bInFileName, 'r', 32767);
   lineNo := 0;
--   dbms_output.put_line('start 1');
   /* skip header record */
   utl_file.get_line(l_output,rec_buff);

   /*--------------------------------------------------*/             
   /* loop thru all remaining records in the data file */
   /* inserting into table tzrimp2                     */
   /*--------------------------------------------------*/       
   loop
        
      /* retreive 2..n records */
      lineNo := lineNo + 1;
--      dbms_output.put_line('LineNo: '|| lineNo);
      utl_file.get_line(l_output,rec_buff);
      ret_code := format_line(rec_buff, ret_record); 
         
      /* insert data record into table */
      if ret_code = 'D' then
--        dbms_output.put_line('before: ' || ret_record.tzrimp2_STUDENTID ||' '||ret_record.tzrimp2_EFFECTIVE_DATE);
         insert_line( ret_record);
--        dbms_output.put_line('after');
       end if;

       if ret_code = 'T' then
          RAISE NO_DATA_FOUND;
       end if;
             
   end loop;
       
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            UTL_FILE.FCLOSE(l_output);
            dbms_output.put_line('UTL FILE: end of data ' || lineNo);
      
       WHEN UTL_FILE.INVALID_PATH THEN
            UTL_FILE.FCLOSE(l_output);
            dbms_output.put_line('UTL FILE: Invalid path '||:bInFileName);
            :bFatalflag := 'Y';
      
       WHEN UTL_FILE.INVALID_MODE THEN
            UTL_FILE.FCLOSE(l_output);
            dbms_output.put_line('UTL FILE: Invalid mode');
            :bFatalflag := 'Y';
      
       WHEN UTL_FILE.INVALID_OPERATION THEN
            UTL_FILE.FCLOSE(l_output);
            dbms_output.put_line('UTL FILE: invalid operation');
            :bFatalflag := 'Y';
      
       WHEN OTHERS THEN
            UTL_FILE.FCLOSE(l_output);
            dbms_output.put_line(substr(sqlerrm,1,100));
            dbms_output.put_line('error record: ' || ret_record.tzrimp2_studentid);
            :bFatalflag := 'Y';

end import_data;
  
/********************************** Start of main process **************/
begin

   /*---------------------------*/
   /* Initialize bind variables */
   /*---------------------------*/
   :brun_type   := gzpparm.f_m_getparm(&2,'01');
   :bAuditFlag  := gzpparm.f_m_getparm(&2,'05');  
   :bInFileName := gzpparm.f_m_getparm(&2,'03');
   :bOneUpNum   := &2;
   :bFatalflag  := 'N';
   
   /*-------------------------------*/
   /* Import file into the database */
   /*-------------------------------*/
   if :brun_type = 'I' then     
          import_data;
          
          if check_duplicates then
                :bFatalflag := 'Y';
                :berrString := 'Duplicate Ids Found';
          else
                update_import; 
          end if;         
   else  
          /* Construct File Name for export */
          :bFileName := 'InsSelect' || to_char(sysdate,'yyyyddd') || 'MSCD' || '01';
          
          /* Build UNIX command to rename export file */
          :bUNIX_Command := 'host ';
          :bUNIX_Command := :bUNIX_Command || 'mv /jobsub/tzpincp_datafile.lst ' || :bFileName || ';';          
          :bUNIX_Command := :bUNIX_Command ||  'umask 0002; cp ' || :bFileName || '  /transfer01/studhealth/outfile/' || :bFileName || ';';
                         
          /* Process export data */
          build_export_table(:bAuditFlag);
   end if;

end;
/

/*************************************/
/*** Summary report on processing  ***/
/*************************************/

clear breaks
CLEAR COLUMNS
set linesize 80
set pagesize 55
set recsep off

clear breaks

spool &3 

ttitle Left 'TZPINCP' CENTER 'Metropolitan State College of Denver' Right 'Page' format 999 SQL.PNO skip 1 -
       Left _DATE CENTER 'Insurance Compliance Error Report ' SKIP 1

    select distinct duplicates.stu_id Duplicate 
     from (select  tzrimp2_studentid stu_id
           from tzrimp2
           where :bFatalflag = 'Y' AND :brun_type = 'I'
           group by tzrimp2_studentid
           having count(tzrimp2_studentid) > 1) duplicates;

ttitle Left 'TZPINCP' CENTER 'Metropolitan State College of Denver' Right 'Page' format 999 SQL.PNO skip 1 -
       Left _DATE CENTER 'Insurance Compliance Import Report ' SKIP 1
            
   select tzrimp2_STUDENTID      Student_Id,
          substr(spriden_LAST_NAME||', '||spriden_FIRST_NAME,1,40)  WHOLE_NAME,
          tzrimp2_FROM_TERM      Starting_Term,
          tzrimp2_payment_type   T,
          tzrimp2_payment_status S
     from tzrimp2, spriden
    where :brun_type = 'I'
      and tzkar04.f_m_get_pidm(tzrimp2_studentid) = spriden_pidm
      and spriden_change_ind is null
    order by 2;


ttitle Left 'TZPINCP' CENTER 'Metropolitan State College of Denver' Right 'Page' format 999 SQL.PNO skip 1 -
       Left _DATE CENTER 'Insurance Conpliance Export Report ' SKIP 1
       
          
   select substr(tzkar04.f_m_get_id(tzrincp_pidm),1,11)  Student_Id, 
          substr(spriden_last_name,1,25)                 Last_Name,
          substr(spriden_first_name,1,15)                First_Name,
          tzrincp_payment_type                           T,
          tzrincp_payment_status                         S
     from tzpincp_temp, tzrincp, spriden
    where pidm =         tzrincp_pidm AND
          spriden_pidm = tzrincp_pidm AND
          term_code = tzrincp_from_term AND
          spriden_change_ind is NULL AND
          :brun_type = 'E'
    order by 2,3;

/***************************************/
/****       Job Summary Report      ****/
/***************************************/
set serveroutput on size 100000
set feedback off
set head off
ttitle LEFT '*** Job Summary ***' SKIP 3

column RUN_DATE  format A30
SELECT 'Run Date: ' || to_char(sysdate,'DD-Mon-YYYY HH:MI AM') RUN_DATE
FROM dual;

ttitle off

column PARM_NUM head 'No.'         format 999
column DESCRIP  head 'Description' format A30
column VALUE    head 'Value'       format A30

exec dbms_output.put_line('--');
exec dbms_output.put_line('List File : '   || '&&3');
exec dbms_output.put_line('Audit Flag: '   || :bAuditFlag);
exec dbms_output.put_line('Fatal Flag: '   || :bFatalflag);
exec dbms_output.put_line('Error String:'  || :berrString);


select gjbpdef_number PARM_NUM, gjbpdef_desc DESCRIP, NVL(gjbprun_value,'** Null Value Entered **') VALUE
from gjbpdef, gjbprun
where gjbprun_job = gjbpdef_job and
      gjbprun_number = gjbpdef_number and
      gjbprun_one_up_no = &2
order by 1,2;

spool off

/*--------------------------------------*/
/* Generate output file for data export */
/*--------------------------------------*/
set echo off
set feedback off
set verify off
set heading off
set linesize 1077
set pagesize 0
set space 0
set wrap off
set pause off
set timing off
set term off

spool tzpincp_datafile
select RPAD(record_text,1076) || CHR(13)
from tzpincp_temp
where :brun_type = 'E'  AND :bFatalflag = 'N'
order by seq_number;
spool off

/*-------------------------------------------*/
/* Do commit or rollback based on audit flag */
/*-------------------------------------------*/
set termout on
begin    
    case
      when (:bAuditFlag = 'U' AND :bFatalflag = 'N') then
      --   GZPPARM.f_m_delparms(&2); 
         gb_common.p_commit();
      else 
         gb_common.p_rollback();
 --        delete from tzrimp2 where tzrimp2_oneup_num = 0;
     --    GZPPARM.f_m_delparms(&2);
         gb_common.p_commit();
    end case;
 end;
 /


set serveroutput on size 100000
spool tzpincp.temp;
exec dbms_output.put_line(:bUNIX_Command);
spool off
host chmod ugo+x tzpincp.temp
start tzpincp.temp;

exit sql.sqlcode;
 sql.sqlcode;
