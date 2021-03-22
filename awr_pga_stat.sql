--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc: get more information over the pga usage
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
column instance_number format 99 heading "In|st"
column name  format a50 heading "PGA Pool"
column value format 999G999G999G999 heading "Size Value"

select p.instance_number
     , to_char(s.begin_interval_time,'dd.mm.yyyy hh24:mi') as begin_interval_time
     , p.NAME
     , p.VALUE 
 from dba_hist_pgastat p
    , dba_hist_snapshot s 
where s.snap_id = p.snap_id 
  and p.instance_number = s.instance_number
  --and s.snap_id > (select max(i.snap_id)-1000 from dba_hist_snapshot i where i.instance_number=p.instance_number)   
  and s.begin_interval_time between to_date('&&START_SNAP','dd.mm.yyyy hh24:mi') and to_date('&&END_SNAP','dd.mm.yyyy hh24:mi')
  and p.name like '%PGA%'
  and p.instance_number=4
order by p.instance_number,s.snap_id,p.name
/

prompt
