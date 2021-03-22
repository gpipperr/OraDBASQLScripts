--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:  get information about the temp Usage in the DB history
--   
--==============================================================================
-- see 
-- http://coskan.wordpress.com/2011/01/24/analysing-temp-usage-on-11gr2-temp-space-is-not-released/
-- alternative from v$active_session_history 
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

column begin_interval_time format a18        heading "Snap | Begin"
column plan_hash_value     format 9999999999 heading "Plan | Hash"
column instance_number     format 99         heading "In|st"
column COMMAND_TYPE        format 999        heading "C|typ"
column sql_id              format a15        heading "SQL|ID"
column temp_mb             format 99G999G999 heading "Temp Usage|MB"
column temp_diff           format 99G999G999 heading "Temp Usage Dif|MB"
column USERNAME            format a18        heading "Schema|Name"
column SAMPLE_Time         format a10        heading "Sample|Minute"

select ss.instance_number
	  , to_char(s.begin_interval_time,'dd.mm.yyyy hh24:mi') as begin_interval_time
	  , to_char(ss.SAMPLE_time,'hh24:mi:ss') as SAMPLE_Time
	  , u.USERNAME	
	  , ss.sql_id 
	  , st.COMMAND_TYPE
	  , ss.temp_space_allocated/1024/1024 temp_mb
	  , ss.temp_space_allocated/1024/1024- lag(temp_space_allocated/1024/1024,1,0) over (order by sample_time) as temp_diff
 from dba_hist_active_sess_history ss
	 , dba_hist_snapshot s 
	 , DBA_HIST_SQLTEXT  st
	 , DBA_users u
where ss.snap_id         = s.snap_id 
  and ss.instance_number = s.instance_number
  -- st
  and st.sql_id=ss.sql_id   
  -- u
  and u.USER_ID=ss.USER_ID
  --
  and s.begin_interval_time between to_date('&&START_SNAP','dd.mm.yyyy hh24:mi') and to_date('&&END_SNAP','dd.mm.yyyy hh24:mi')
  and ss.temp_space_allocated > 0
  --
order by s.snap_id
       , ss.instance_number
		 , ss.sql_id
/

prompt 
prompt ... time = microseconds!
prompt
prompt  ... to see command type Numbers use select * from audit_actions order by action
prompt

