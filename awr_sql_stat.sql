--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc: get more information about one sql statement from the awr
--   
--==============================================================================
-- see
-- http://oracleprof.blogspot.de/2011/06/how-to-color-mark-sql-for-awr-snapshots.html
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt


set linesize 130 pagesize 300 

define SQL_ID='&1'

prompt
prompt Parameter 1 = SQL ID     => &&SQL_ID.
prompt



column begin_interval_time format a18                heading "Snap| Begin"
column plan_hash_value     format 9999999999         heading "Plan| Hash"
column execution_time      format 999G999G999G999D99 heading "Execution Time|per SQL"
column executions_delta    format 99G999G999         heading "Executions|delta"
column cpu_time_delta      format 999G999G999G999    heading "Cpu time|delta"
column elapsed_time_delta  format 999G999G999G999    heading "Elapsed time|delta"
column disk_reads_delta    format 999G999G999        heading "Disk Read|Delta"
column instance_number     format 99                 heading "In|st"
column PARSING_SCHEMA_NAME format a20                heading "Parsing|User"


select ss.instance_number
      , ss.sql_id
	  , to_char(s.begin_interval_time,'dd.mm.yyyy hh24:mi') as begin_interval_time
      , ss.plan_hash_value
	  , case when ss.executions_delta = 0 then -1 else ss.elapsed_time_delta/ss.executions_delta end as  execution_time
	  , ss.executions_delta
	  , ss.cpu_time_delta
	  , ss.elapsed_time_delta
	  , ss.disk_reads_delta 
	  , ss.PARSING_SCHEMA_NAME
 from dba_hist_sqlstat ss
    , dba_hist_snapshot s 
where s.snap_id = ss.snap_id 
  and ss.instance_number = s.instance_number
 and ss.sql_id = '&&sql_id.'  
  and s.snap_id > (select max(i.snap_id)-1000 from dba_hist_snapshot i where i.instance_number=ss.instance_number)
order by s.snap_id, ss.instance_number, ss.sql_id
/


prompt
prompt ... time = microseconds!
prompt
prompt
prompt ...
prompt ... to mark a sql statment use this function : exec dbms_workload_repository.add_colored_sql('&&SQL_ID.') 
prompt ... check with : select * from DBA_HIST_COLORED_SQL; 
prompt ... do not forget to uncolor the statement   : exec dbms_workload_repository.remove_colored_sql('&&SQL_ID.') 
prompt
prompt

