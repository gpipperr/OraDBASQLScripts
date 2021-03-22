--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: show the streams archive logs - which can be deleted 
--==============================================================================
set verify off
set linesize 130 pagesize 2000 

set serveroutput on size 1000000

---
col SPOOL_NAME_COL new_val SPOOL_NAME

select    ora_database_name
       -- fix Window Domain
	   --|| '_'
       --|| sys_context ('USERENV', 'HOST')
       || '_'
       || to_char (sysdate, 'dd_mm_yyyy_hh24_mi')
       || '_remove_old_streams_logs'
          as SPOOL_NAME_COL
  from dual
/

spool &&SPOOL_NAME


select to_char (sysdate, 'dd.mm.yyyy hh24:mi') as starttime from dual
/

declare
   cursor c_log_remove (v_last_appl_scn number)
   is
        select *
          from (select lr.name, lr.first_time, rank () over (order by lr.first_time asc) as rang
                  from DBA_REGISTERED_ARCHIVED_LOG LR, DBA_LOGMNR_PURGED_LOG LP
                 where     lr.first_scn < v_last_appl_scn
                       and lr.name = lp.file_name
                       and lr.first_time <   sysdate
                                           - 1)
         --for debug to get only the first records
         where rang < 250
      order by FIRST_TIME desc;

   cursor c_need_logs
   is
        select r.name, to_char (FIRST_TIME, 'dd.mm hh24:mi') as start_time
          from dba_registered_archived_log r, dba_capture c
         where     r.consumer_name = c.capture_name
               and r.next_scn >= c.required_checkpoint_scn
      order by FIRST_TIME desc;

   v_high_Scn       number := 0;
   v_low_Scn        number := 0;
   v_start_Scn      number;
   v_applied_Scn    number;
   v_required_scn   number;

   v_alog           varchar2 (1000);
begin
   -- fix for pls-sql developer
   dbms_output.ENABLE (1000000);

   -- get actual scn
   select min (start_scn), min (applied_scn), min (required_checkpoint_scn)
     into v_start_Scn, v_applied_Scn, v_required_scn
     from dba_capture;

   dbms_output.put_line ('Info -- last applied scn: ' || v_applied_Scn || ' -required_checkpoint_scn ' || v_required_scn);
   dbms_output.put_line ('Info -- Capture will restart from SCN ' || v_required_scn || ' in the following file:');
   dbms_output.put_line ('Info --    ');

   for rec in c_need_logs
   loop
      dbms_output.put_line (
            rpad ('Info -- still need this files fro the capture ', 46, ' ')
         || ' :: '
         || rpad (rec.name, 56, ' ')
         || ' from :: '
         || rec.start_time);
   end loop;

   dbms_output.put_line ('Info --    ');
   dbms_output.put_line ('Info -- START -> This archivelogs could be removed::');

   for rec in c_log_remove (v_last_appl_scn => v_start_Scn)
   loop
      dbms_output.put_line (
            rpad ('Info -- try to delete this file ', 46, ' ')
         || ' :: '
         || rpad (rec.name, 56, ' ')
         || ' from :: '
         || to_char (rec.first_time, 'dd.mm hh24:mi'));

      begin
         -- only possible if you have sys rights
         null;
         -- dbms_backup_restore.deletefile(rec.name);
         dbms_output.put_line ('Info -- Command :: exec dbms_backup_restore.deletefile(''' || rec.name || ''')');
      exception
         when others
         then
            dbms_output.put_line (
               rpad ('Info --try to delete this file ', 46, ' ') || ' :: ' || rpad (rec.name, 56, ' ') || ' Error ::' || sqlerrm);
      end;
   end loop;

   dbms_output.put_line ('Info -- END -> This archivelogs could be removed::');
end;
/

select to_char (sysdate, 'dd.mm.yyyy hh24:mi') as endtime from dual
/

prompt check logfile &&SPOOL_NAME

spool off
