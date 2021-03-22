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



column end_interval_time   format a18 heading "Snap | End"
column begin_interval_time format a18 heading "Snap | Begin"
column plan_hash_value     format 9999999999 heading "Plan | Hash"
column execution_time_max  format 999G999G999G999D99 heading "Max Execution Time|per SQL"
column execution_time_min  format 999G999G999G999D99 heading "Min Execution Time|per SQL"
column snapshot_count      format 999999 heading "Snap|Cnt" 
column instance_number     format 99 heading "In|st"
column parsing_schema_name format a20 heading "Parsing|Schema"

select ss.instance_number
     , ss.sql_id
	  , ss.plan_hash_value
	  , to_char(min(s.begin_interval_time),'dd.mm.yyyy hh24:mi') as begin_interval_time
	  , to_char(max(s.begin_interval_time),'dd.mm.yyyy hh24:mi') as end_interval_time
	  , min(case when ss.executions_delta = 0 then -1 else ss.elapsed_time_delta/ss.executions_delta end ) as  execution_time_min
	  , max(case when ss.executions_delta = 0 then -1 else ss.elapsed_time_delta/ss.executions_delta end ) as  execution_time_max
	  , count(*) snapshot_count
     , ss.parsing_schema_name
 from dba_hist_sqlstat ss
    , dba_hist_snapshot s 
where s.snap_id = ss.snap_id 
  and ss.instance_number = s.instance_number
 and ss.sql_id = '&&sql_id.' 
group by   ss.instance_number
        , ss.sql_id
		, ss.plan_hash_value
		, ss.parsing_schema_name
order by 4
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