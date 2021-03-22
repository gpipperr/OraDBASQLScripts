--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:  create ASH report from sql*Plus
-- Date:  10.2015
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt


-- ===== 
-- get the spoolfile name and instance_number + DB ID
-- =====
set feedback off
set heading off
set termout off

column spool_name_col new_val spool_name
column instance_number new_val inst_nr
column aktdbid new_val databaseid
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_ash_report.html','\','_') 
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

-- ===== 
-- ask for the Start and endtime of the report
-- =====
set verify off

SET linesize 120 pagesize 300 

define TIME_FORMAT='dd.mm.yyyy hh24:mi'  

column min_start_time format a18 heading "Early Start|Date"
column max_start_time format a18 heading "Latest Start|Date"

ttitle left  "Overview over the possible timeframe to get an ash report " skip 2

select to_char(min(s.sample_time),'&&TIME_FORMAT') as min_start_time
    ,  to_char(max(s.sample_time),'&&TIME_FORMAT') as max_start_time
  from dba_hist_active_sess_history s
 where  dbid = &&databaseid
   and  instance_number = &&inst_nr
/   

--
-- fix  and  snap_id in (... ) like seelect  min(snap_id), max(snap_id) from dba_hist_snapshot where  dbid = s.dbid  and  instance_number = s.inst_num )
--
ttitle off
 
accept l_btime date prompt 'Enter start time (format &&TIME_FORMAT): '
accept l_etime date prompt 'Enter end time   (format &&TIME_FORMAT): '


-- ===== 
-- create the ASH Report
-- =====	


SET linesize 500 pagesize 9000 
set long 64000
set feedback off
set heading off

spool &&SPOOL_NAME

select * 
  from table(sys.dbms_workload_repository.ash_report_html( &&databaseid
                                                         , &&inst_nr
														 , to_date('&&l_btime','&&TIME_FORMAT')
														 , to_date('&&l_etime','&&TIME_FORMAT')
														 )
			)
/			

spool off
set heading on
set feedback on

prompt ... check the created report  &&SPOOL_NAME

host &&SPOOL_NAME

set linesize 130 pagesize 300 