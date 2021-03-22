--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:  create AWR report from sql*Plus
-- Date:  10.2015
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt

column end_interval_time format a18 heading "End Interval|Time"
break on dbid

ttitle left  "Overview over the snapshots in the last days" skip 2

select dbid
	 , instance_number
	 , snap_id
	 , to_char(end_interval_time,'hh24:mi dd.mm.yyyy') as end_interval_time
  from dba_hist_snapshot
 where end_interval_time > trunc(sysdate-1)
order by snap_id, instance_number
/

clear break
ttitle off


set feedback off
set heading off
set termout off

column spool_name_col new_val spool_name
column instance_number new_val inst_nr
column aktdbid new_val databaseid
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_awr_report.html','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
   AS SPOOL_NAME_COL
  ,SYS_CONTEXT('USERENV','INSTANCE') as instance_number
 FROM dual
/

select dbid as aktdbid 
  from v$database
/

set feedback on
set heading on
set termout on

set verify off
SET linesize 500 pagesize 9000 
set long 64000

accept snapshot_id_begin number prompt 'Enter Frist Snapshot Begin ID    : '
accept snapshot_id_end   number prompt 'Enter Snapshot End Id to compare : '

set heading off
set feedback off
spool &&SPOOL_NAME

select * from table(sys.dbms_workload_repository.awr_report_html(&&databaseid,&&inst_nr,&&snapshot_id_begin,&&snapshot_id_end));

spool off
set heading on
set feedback on

prompt ... check the created report  &&SPOOL_NAME

host &&SPOOL_NAME

set linesize 130 pagesize 300 