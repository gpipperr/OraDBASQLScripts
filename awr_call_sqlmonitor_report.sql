--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:  create AWR report from sql*Plus
-- Date:  10.2015
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt


set feedback off
set heading off
set termout off

column spool_name_col new_val spool_name
column instance_number new_val inst_nr

SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_sqlmonitor_report.html','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
   AS SPOOL_NAME_COL
  ,SYS_CONTEXT('USERENV','INSTANCE') as instance_number
FROM dual
/

set feedback on
set heading on
set termout on

set trimspool on
set trim on
set pages 0
set linesize 1000
set long 1000000
set longchunksize 1000000
spool &&SPOOL_NAME

--11g!

select dbms_sqltune.report_sql_monitor(type=> 'active') from dual
/

spool off

prompt ... check the created report  &&SPOOL_NAME
