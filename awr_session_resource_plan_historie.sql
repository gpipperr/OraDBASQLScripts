--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:  show the consumer group of all history active sessions of a user
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt


set linesize 130 pagesize 300 
set verify off


define USER_NAME = &1 
prompt
prompt Parameter 1 = USER_NAME  => &&USER_NAME.
prompt


column sample_time    format a18 heading "Sample|Time"
column session_state  format a10 heading "Session|state"
column event          format a35 heading "Event"
column consumer_group format a18    heading "Consumer|Group"
column service_name   format a20 heading "DB|Service"
column snaps          format 999 heading "CNT"
column inst_id        format 99 heading "IN|ST"

  select to_char (sh.sample_time, 'dd.mm.yyyy hh24:mi') as sample_time
       ,  count (*) as snaps
       ,  sh.session_state
       ,  sh.event
       ,  cg.consumer_group
       ,  sv.name as service_name
       ,  sh.INSTANCE_NUMBER as inst_id
    from DBA_HIST_ACTIVE_SESS_HISTORY sh
       ,  dba_users du
       ,  DBA_RSRC_CONSUMER_GROUPS cg
       ,  dba_SERVICES sv
   where     sh.user_id = du.user_id
         and sh.consumer_group_id = cg.consumer_group_id
         and sv.NAME_HASH = sh.SERVICE_HASH
         and du.username like upper ('&&USER_NAME.')
         and sh.sample_time between   sysdate - 31 and sysdate
         --and  cg.consumer_group != 'OTHER_GROUPS'
         and sv.name != 'SYS$USERS'
group by to_char (sh.sample_time, 'dd.mm.yyyy hh24:mi')
       ,  sh.session_state
       ,  sh.event
       ,  cg.consumer_group
       ,  sv.name
       ,  sh.INSTANCE_NUMBER
order by 1
/
 