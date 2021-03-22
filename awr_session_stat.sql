--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc: get  the statistic information over a the active sessions of a DB user
--   
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt

set linesize 130 pagesize 300 


define DB_USER_NAME='&1'

prompt
prompt Parameter 1 = DB_USER_NAME     => &&DB_USER_NAME.
prompt


column begin_interval_time format a18 heading "Snap | Begin"
column instance_number     format 99 heading "In|st"
column value               format a20 heading "Value"
column stat_name           format a18 heading "Stat|Name"
column diff                format a20 heading "Dif |before"
column program_a           format a20 heading "One|Prog"
column program_b           format a20 heading "Other|Prog"
column sql_id_a            format a20 heading "One|SQL"
column sql_id_b            format a20 heading "Other|SQL"
column username            format a14 heading "User|Name"
column snap_count          format 999 heading "Snap|Cnt"
column SESSION_ID          format 99999 heading "Sess|ID"
column SESSION_SERIAL#     format 99999 heading "Ser|ial"
column event_a             format a20 heading "One|Event"
column event_b             format a20 heading "Other|Event"


break on instance_number skip 2 
--COMPUTE SUM OF instance_number ON begin_interval_time

select ss.instance_number
       ,  to_char (s.begin_interval_time, 'dd.mm.yyyy hh24:mi') as begin_interval_time
       ,  ss.SESSION_ID
       ,  ss.SESSION_SERIAL#
       ,  count (s.snap_id) as snap_count
       ,  u.username
       ,  ss.CLIENT_ID
       ,  ss.MACHINE
       ,  min (ss.PROGRAM) as program_a
       ,  min (SQL_ID) as sql_id_a
       ,  min (EVENT) as event_a
       ,  max (EVENT) as event_b
    from dba_hist_active_sess_history ss, dba_hist_snapshot s, dba_users u
   where     u.user_id = ss.user_id
         and s.snap_id = ss.snap_id
         and ss.instance_number = s.instance_number
         and s.snap_id > (select   max (i.snap_id)- 50
                            from dba_hist_snapshot i
                           where i.instance_number = ss.instance_number)
-- and ss.SESSION_ID = 4382
-- and  u.username like upper('&&DB_USER_NAME.')
-- and ss.instance_number = 3
-- and s.begin_interval_time between to_date('14.11.2014 08:19','dd.mm.yyyy hh24:mi') and to_date('14.11.2014 08:31','dd.mm.yyyy hh24:mi')
group by ss.SESSION_ID
       ,  ss.SESSION_SERIAL#
       ,  ss.instance_number
       ,  to_char (s.begin_interval_time, 'dd.mm.yyyy hh24:mi')
       ,  u.username
       ,  ss.CLIENT_ID
       ,  ss.MACHINE
--, ss.PROGRAM
order by ss.instance_number, to_char (s.begin_interval_time, 'dd.mm.yyyy hh24:mi')
/

clear breaks