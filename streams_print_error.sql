--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc : print the SQL Statements for all LCRS in a transaction if a streams error occurs
--==============================================================================
-- Source
-- http://docs.oracle.com/cd/B19306_01/appdev.102/b14258/d_apply.htm
-- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/t_lcr.htm#BABGGBHF
-- http://wedostreams.blogspot.de/2009/09/new-streams-112-sql-generation-facility.html
-- http://it.toolbox.com/blogs/oracle-guide/manually-creating-a-logical-change-record-lcr-13838
-- http://www.fadalti.com/oracle/database/Streams.htm
--==============================================================================

set verify off
set linesize 1000 pagesize 4000 

set trimspool on
set serveroutput on

-------------------
-- create spool name
col SPOOL_NAME_COL new_val SPOOL_NAME

select replace (
             ora_database_name
          || '_'
          || sys_context ('USERENV', 'HOST')
          || '_'
          || to_char (sysdate, 'dd_mm_yyyy_hh24_mi')
          || '_streams_sql.sql'
        ,  '\'
        ,  '_')
          --' resolve syntax highlight bug FROM my editer .-(
          as SPOOL_NAME_COL
  from dual
/

alter session set NLS_TERRITORY=AMERICA;
alter session set NLS_LANGUAGE=AMERICAN;
alter session set NLS_NUMERIC_CHARACTERS='.,';

spool &&SPOOL_NAME

prompt
prompt spool recreate_&&SPOOL_NAME.log
prompt
prompt
prompt prompt  ============ Start ================
prompt select to_char(sysdate,'dd.mm.yyyy hh24:mi') as start_date from dual
prompt /
prompt prompt  ===================================
prompt
prompt alter session set NLS_TERRITORY=AMERICA;
;
prompt alter session set NLS_LANGUAGE=AMERICAN;
;
prompt alter session set NLS_NUMERIC_CHARACTERS='.,';
;
prompt

prompt set heading   on
prompt set echo      on
prompt set feedback  on
prompt set define   off

declare
   cursor c_error_queue
   is
        select local_transaction_id
             ,  source_database
             ,  message_number
             ,  message_count
             ,  error_number
             ,  error_message
          from dba_apply_error
      order by local_transaction_id, message_number;

   v_i         number;
   v_txnid     varchar2 (30);
   v_source    varchar2 (128);
   v_msgno     number;
   v_msgcnt    number;
   v_errnum    number := 0;
   v_errno     number;
   v_errmsg    varchar2 (255);
   v_rowlcr    sys.lcr$_row_record;
   v_ddllcr    sys.lcr$_ddl_record;
   v_sqltext   clob := ' ';
   v_e_lcr     sys.anydata;
   v_res       number;
   v_typenm    varchar2 (61);
begin
   dbms_lob.createtemporary (v_sqltext, true);

   for rec in c_error_queue
   loop
      v_errnum :=
           v_errnum
         + 1;
      v_msgcnt := rec.MESSAGE_COUNT;
      v_txnid := rec.LOCAL_TRANSACTION_ID;
      v_source := rec.SOURCE_DATABASE;
      v_msgno := rec.MESSAGE_NUMBER;
      v_errno := rec.ERROR_NUMBER;
      v_errmsg := rec.ERROR_MESSAGE;

      dbms_output.put_line ('-- Info --------------------------------------------------');
      dbms_output.put_line ('-- Info -- ERROR #              : ' || v_errnum);
      dbms_output.put_line ('-- Info -- Local Transaction ID : ' || v_txnid);
      dbms_output.put_line ('-- Info -- Source Database      : ' || v_source);
      dbms_output.put_line ('-- Info -- Error in Message     : ' || v_msgno);
      dbms_output.put_line ('-- Info -- Error Number         : ' || v_errno);
      dbms_output.put_line ('-- Info -- Message Text         : ');
      dbms_output.put_line ('/*');
      dbms_output.put_line (v_errmsg);
      dbms_output.put_line ('*/');
      dbms_output.put_line ('-- Info -- Message Count        : ' || v_msgcnt);
      dbms_output.put_line ('-- Info --------------------------------------------------');
      dbms_output.put_line (' ');

      for v_i in 1 .. v_msgcnt
      loop
         -- reinitialise all variables!
         dbms_lob.createtemporary (v_sqltext, true);
         v_rowlcr := null;
         v_res := null;
         v_e_lcr := null;

         begin
            --- read LCR
            v_e_lcr := dbms_apply_adm.GET_ERROR_MESSAGE (v_i, v_txnid);
            -- get the Type of the LCR
            v_typenm := v_e_lcr.GETTYPENAME ();

            -- extract SQL text
            case v_typenm
               when 'SYS.LCR$_DDL_RECORD'
               then
                  -- transform to original data type sys.lcr$_ddl_record
                  v_res := v_e_lcr.GETOBJECT (v_ddllcr);
                  v_ddllcr.GET_DDL_TEXT (v_sqltext);
               when 'SYS.LCR$_ROW_RECORD'
               then
                  -- transform to original data type sys.lcr$_row_record
                  v_res := v_e_lcr.GETOBJECT (v_rowlcr);
                  v_rowlcr.get_row_text (v_sqltext);
               else
                  dbms_output.put_line ('-- Error -- Non-LCR Message with type ' || v_typenm);
                  v_sqltext := '-- No SQL statement found';
            end case;
         exception
            when others
            then
               dbms_output.put_line ('-- Error -- SQL Error Message: ' || sqlerrm);
         end;

         dbms_output.put_line ('-- Info -- Message id :' || v_i);
         dbms_output.put_line ('-- Info -- SQL Command:');
         dbms_output.put_line (substr (v_sqltext, 1, 32000));
         dbms_output.put_line ('/');
         dbms_output.put_line ('-- Info --------------------------------------------------');
      -- If you are brave you can execute this also directly
      --
      -- begin
      --   execute immediate v_sqltext;
      --    dbms_output.put_line('Info ----------successfully execute SQL from message:'||v_i||'for '|| %SQLCOUNT ||' records');
      -- exception
      --   when others then
      --     dbms_output.put_line('Error -- Error execute the SQL: '||v_sqltext);
      --     dbms_output.put_line('Error -- Error execute the SQL: '||SQLERRM);
      -- end;

      end loop;
   end loop;
end;
/


prompt
prompt prompt  ============ Finish ================
prompt select to_char(sysdate,'dd.mm.yyyy hh24:mi') as finish_date from dual
prompt /
prompt prompt  ===================================
prompt
prompt prompt to check the log see reexecute_&&SPOOL_NAME.log
prompt prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
prompt prompt dont forget the commit if all is ok!
prompt prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

prompt set heading  on
prompt set feedback off
prompt set define on
prompt set echo off

spool off

prompt .....
prompt to start he recreate scripts use the script:  &&SPOOL_NAME
prompt .....
prompt ..... to delete the errors and restart streams use this commands:
prompt ..... exec dbms_apply_adm.delete_all_errors( apply_name => 'downstream_apply')
prompt ..... exec dbms_apply_adm.start_apply      ( apply_name => 'downstream_apply')
prompt .....
prompt .....