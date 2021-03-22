--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:  get information about the last sql in the database over a time period
--   
--==============================================================================
-- see 
-- http://oracleprof.blogspot.de/2011/06/how-to-color-mark-sql-for-awr-snapshots.html
-- http://mwidlake.wordpress.com/2010/01/08/more-on-command_type-values/ 
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt

set linesize 130 pagesize 300 

define START_SNAP='&1'
define END_SNAP='&2'

prompt
prompt ... time format must be dd.mm.yyyy hh24:mi
prompt
prompt Parameter 1 = START_SNAP     => &&START_SNAP.
prompt Parameter 2 = END_SNAP       => &&END_SNAP.
prompt



column begin_interval_time format a18 heading "Snap | Begin"
column plan_hash_value     format 9999999999 heading "Plan | Hash"
column execution_time      format 9G999G999G999D99 heading "Execution Time|per SQL"
column executions_delta    format 99G999G999 heading "Executions|delta"
column cpu_time_delta      format 99G999G999 heading "Cpu time|delta"
column elapsed_time_delta  format 999G999G999G999 heading "Elapsed time|delta"
column disk_reads_delta    format 99G999G999 heading "Disk Read|Delta"
column instance_number     format 99 heading "In|st"
column COMMAND_TYPE        format 999 heading "C|typ"
column sql_id              format a15 heading "SQL|ID"
column USERNAME            format a18        heading "Schema|Name"

select ss.instance_number
	  , to_char(s.begin_interval_time,'dd.mm.yyyy hh24:mi') as begin_interval_time
	  , ss.PARSING_SCHEMA_NAME as  USERNAME
	  , ss.sql_id 
	  , st.COMMAND_TYPE
    -- , ss.plan_hash_value
	  , case when ss.executions_delta = 0 then -1 else ss.elapsed_time_delta/ss.executions_delta  end as execution_time
	  , ss.executions_delta
	  , ss.cpu_time_delta
	  , ss.elapsed_time_delta
	  , ss.disk_reads_delta 
 from dba_hist_sqlstat ss
    , dba_hist_snapshot s 
	 , DBA_HIST_SQLTEXT  st	 
where s.snap_id = ss.snap_id 
  and ss.instance_number = s.instance_number
  and st.sql_id=ss.sql_id 
  and ss.PX_SERVERS_EXECS_TOTAL > 0
   --
  and s.begin_interval_time between to_date('&&START_SNAP','dd.mm.yyyy hh24:mi') and to_date('&&END_SNAP','dd.mm.yyyy hh24:mi')
  -- update or delete
  -- and st.COMMAND_TYPE in (6,7)
  and ss.PARSING_SCHEMA_NAME not in ('SYS','SYSTEM','DBSNMP')
order by ss.sql_id ,s.snap_id, ss.instance_number,ss.PARSING_SCHEMA_NAME, ss.elapsed_time_delta desc
/

prompt 
prompt ... time = microseconds!
prompt
prompt  ... to see command type Numbers use select * from audit_actions order by action
prompt
