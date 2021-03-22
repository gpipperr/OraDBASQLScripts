--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc : search for changed plans in a time period - parameter 1 - Startdate  - parameter 2 end date in DE format
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt

set linesize 130 pagesize 300 

define START_SNAP='&1'
define END_SNAP  ='&2'

prompt
prompt ... time format must be "dd.mm.yyyy hh24:mi"
prompt
prompt Parameter 1 = START_SNAP     => &&START_SNAP.
prompt Parameter 2 = END_SNAP       => &&END_SNAP.
prompt


set pagesize 1000
set linesize 250
set verify off

column end_interval_time   format a18 heading "Snap | End"
column begin_interval_time format a18 heading "Snap | Begin"
column plan_hash_value     format 9999999999 heading "Plan | Hash"
column execution_time_max  format 999G999G999G999D99 heading "Max Execution Time|per SQL"
column execution_time_min  format 999G999G999G999D99 heading "Min Execution Time|per SQL"
column snapshot_count      format 999999 heading "Snap|Cnt"
column instance_number     format 99 heading "In|st"
column parsing_schema_name format a20 heading "Parsing|Schema"
column hash_list           format a60
column user_list           format a40

select *
  from (  select                                                                                                 --instance_number
                 --,
                 --  parsing_schema_name
                 --     ,
                 sql_id
               ,  listagg (to_char (plan_hash_value), ':') within group (order by sql_id) as hash_list
               ,  listagg (to_char (parsing_schema_name), ':') within group (order by sql_id) as user_list
               ,  sum (sqlrang) as sqlrang
            from (  select                                                                                    --ss.instance_number
                           -- ,
                           ss.sql_id
                         ,  ss.plan_hash_value
                         -- , to_char(min(s.begin_interval_time),'dd.mm.yyyy hh24:mi') as begin_interval_time
                         -- , to_char(max(s.begin_interval_time),'dd.mm.yyyy hh24:mi') as end_interval_time
                         -- , min(case when ss.executions_delta = 0 then -1 else ss.elapsed_time_delta/ss.executions_delta end ) as  execution_time_min
                         -- , max(case when ss.executions_delta = 0 then -1 else ss.elapsed_time_delta/ss.executions_delta end ) as  execution_time_max
                         -- , count(*) snapshot_count
                         ,  row_number () over (partition by sql_id order by plan_hash_value) sqlrang
                         ,  ss.parsing_schema_name
                      from dba_hist_sqlstat ss, dba_hist_snapshot s
                     where     s.snap_id = ss.snap_id
                           and ss.instance_number = s.instance_number
                           and s.begin_interval_time between to_date ('&&START_SNAP', 'dd.mm.yyyy hh24:mi')
                                                         and to_date ('&&END_SNAP', 'dd.mm.yyyy hh24:mi')
                           and ss.parsing_schema_name not in ('SYS', 'DBSNMP')
                  group by                                                                                   -- ss.instance_number
                           --,
                           ss.sql_id, ss.plan_hash_value, ss.parsing_schema_name)
        group by                                                                                                 --instance_number
                 --,
                 --parsing_schema_name
                 --,
                 sql_id
        order by sql_id)
 where sqlrang > 1
/


prompt
prompt ... time = microseconds!
prompt
prompt