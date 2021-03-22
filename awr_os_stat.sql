--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc - display the OS statistic of the last days  
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt

set linesize 130 pagesize 300 

select ss.instance_number
       ,  to_char (s.begin_interval_time, 'dd.mm.yyyy hh24:mi') as begin_interval_time
       ,  'LOAD =>' as param
       ,  round (ss.value, 3) as load_value
    from dba_hist_snapshot s, DBA_HIST_OSSTAT ss, DBA_HIST_OSSTAT_NAME ssn
   where  s.snap_id = ss.snap_id
     and ss.instance_number = s.instance_number
     and s.snap_id > (select   max (i.snap_id)
                             - 10
                        from dba_hist_snapshot i
                       where i.instance_number = ss.instance_number)
     and ssn.stat_id = ss.stat_id
     and ssn.stat_name = 'LOAD'
order by 1
/
