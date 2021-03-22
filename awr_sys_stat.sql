--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc: get  the statistic information over a system statistic
--   
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt


set linesize 130 pagesize 300 


define SYSSTAT_NAME='&1'

prompt
prompt Parameter 1 = SYSSTAT_NAME     => &&SYSSTAT_NAME.
prompt


column begin_interval_time format a18 heading "Snap | Begin"
column instance_number     format 99 heading "In|st"
column value               format a20 heading "Value"
column stat_name           format a18 heading "Stat|Name"
column diff                format a20 heading "Dif |before"

break on instance_number skip 2 
--COMPUTE SUM OF instance_number ON begin_interval_time

select  ss.instance_number
      , ss.STAT_NAME
      , to_char(s.begin_interval_time,'dd.mm.yyyy hh24:mi') as begin_interval_time
      , to_char(round(ss.value,2),'999G999G999G990D99') as value
	  , to_char(round((ss.value -lag (ss.value, 1, ss.value) OVER (ORDER BY  ss.STAT_NAME,ss.instance_number, s.snap_id)) / 600 ,2),'999G999G999G990D99') AS diff
from dba_hist_sysstat ss
    , dba_hist_snapshot s 
where s.snap_id = ss.snap_id 
  and ss.instance_number = s.instance_number
  and s.snap_id > (select max(i.snap_id)-25 from dba_hist_snapshot i where i.instance_number=ss.instance_number)   
  and ss.STAT_NAME  like lower('&&SYSSTAT_NAME.%')
order by  ss.STAT_NAME,ss.instance_number, s.snap_id
/

clear break