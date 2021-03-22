--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc : Get the status of the streams replication
--==============================================================================
-- http://docs.oracle.com/cd/E11882_01/server.112/e10705/toc.htm
-- http://www.oracle11ggotchas.com/articles/Resolving%20archived%20log%20file%20gaps%20in%20Streams.pdf
-- http://it.toolbox.com/blogs/oracle-guide/manually-creating-a-logical-change-record-lcr-13838
--
-- Streams Troubleshooting Guide (Doc ID 883372.1)
--
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt

set verify off
set linesize 130 pagesize 300 

set serveroutput on size 1000000


column running_inst           format 99 heading "In|St"
column capture_process_status format a10 heading "CaptureP|Status"
column apply_process_status   format a10 heading "ApplyP|Status"
column apply_state            format a10 heading "Apply|state"
column capture_state          format a30 heading "Capture|State"
column hwm_message_create_time format a18 heading "MessageC|Time"
column delay_min               format 9999999 heading "Delay|Minute"
column total_applied           format 9999999 heading "Total|Applied"

select to_char (sysdate, 'dd.mm.yyyy hh24:mi') as act_date from dual;

select capture_state.inst_id as running_inst
     ,  capture_status.status as capture_process_status
     ,  apply_status.status as apply_process_status
     ,  capture_state.state as capture_state
     ,  apply_state.state as apply_state
     ,  to_char (apply_state.hwm_message_create_time, 'dd.mm.yyyy hh24:mi') as hwm_message_create_time
     ,  round (  (  sysdate - apply_state.hwm_message_create_time) * 24 * 60) as delay_min
     ,  apply_state.total_applied
  from (select 1 as jc, state, inst_id from gv$streams_capture) capture_state
     ,  (select 1 as jc
              ,  state
              ,  hwm_message_create_time
              ,  total_applied
           from gv$streams_apply_coordinator) apply_state
     ,  (select 1 as jc, status from dba_apply) apply_status
     ,  (select 1 as jc, status from dba_capture) capture_status
 where     capture_status.jc = apply_state.jc(+)
       and capture_status.jc = apply_status.jc(+)
       and capture_status.jc = capture_state.jc(+)
/

prompt check for apply latency

select to_char (applied_message_create_time, 'dd.mm.yyyy hh24:mi:ss') "event_creation"
     ,  to_char (apply_time, 'dd.mm.yyyy hh24:mi:ss') "apply_time"
     ,  round (  (  apply_time - applied_message_create_time)  * 86400 / 60)      "create_apply_latency_minutes"
     ,    (  sysdate - apply_time) * 86400   "last_apply_in_seconds"
  from dba_apply_progress
/


prompt ...
prompt ... check if gap exists

  select thread
       ,  consumer_name
       ,    seq + 1 first_seq_missing
       ,    seq  + (  next_seq  - seq  - 1)  last_seq_missing
       ,    next_seq  - seq  - 1  missing_count
    from (select THREAD# thread
               ,  SEQUENCE# seq
               ,  lead (SEQUENCE#, 1, SEQUENCE#) over (partition by thread# order by sequence#) next_seq
               ,  consumer_name
            from dba_registered_archived_log
           where RESETLOGS_CHANGE# = (select max (RESETLOGS_CHANGE#) from dba_registered_archived_log))
   where   next_seq
         - seq > 1
order by 1, 2
/


prompt ...
prompt ... check count of old archive logs not needed anymore for streams

select purged_candiates_logs_count, registerd_logs_count
  from (select count (*) as purged_candiates_logs_count from DBA_LOGMNR_PURGED_LOG)
     ,  (select count (*) as registerd_logs_count from DBA_REGISTERED_ARCHIVED_LOG LR  where Lr.first_time <   sysdate  - 1)
/

prompt ...
prompt ... check in apply_error for

set long 650000

column local_transaction_id format a20 heading "trans|ID"
column source_database      format a10 heading "Source|DB"
column message_number       format 9999999
column message_count        format 9999999
column error_number         format 999999
column error_message        format a30

column MESSAGE_ID          format a10
column TRANSACTION_MESSAGE_NUMBER format 999 heading "Trans|Number"
column SOURCE_OBJECT_OWNER  format a10
column SOURCE_OBJECT_NAME   format a20
column OBJECT_OWNER         format a10
column OBJECT_NAME          format a30
column PRIMARY_KEY          format a20
column POSITION             format a10
column OPERATION            format a10
column MESSAGE              format a50 word_wrapped
column error_time           format a16

  select local_transaction_id
       ,  source_database
       ,  message_number
       ,  message_count
       ,  error_number
       ,  error_message
       ,  to_char (ERROR_CREATION_TIME, 'dd.mm hh24:mi:ss') as error_time
    from dba_apply_error
order by source_database, source_commit_scn
/

--BREAK ON local_transaction_id

prompt .... Total count of error message in the apply error message

select count (*)
  from dba_apply_error_messages em
/

prompt .... Detail Error messages around the actual error

  select em.local_transaction_id
       ,  em.object_owner || '.' || em.object_name as object_name
       ,  em.operation
       ,  em.transaction_message_number
       ,  em.message
    from dba_apply_error_messages em, dba_apply_error ar
   where     em.local_transaction_id = ar.local_transaction_id
         and em.transaction_message_number between   ar.message_number
                                                   - 1
                                               and   message_number
                                                   + 1
order by em.local_transaction_id, em.transaction_message_number, em.position
/

prompt ...
prompt ... check apply statistic for the last 24 hours
prompt ... check apply statistic first line is the cumulativ value over the whole statistic
prompt ... create from statistic, last hour values can be 0 in statistic was not now collected
prompt ... the total count is more informal, the highest number can be ignored - bug in the SQL Script

column instance_number format A2   heading "IN|ST"
column hhour           format a11  heading "Apply|Hour"
column apply_name      format a16  heading "Apply|Name"
column server_total_messages_applied  format 999g999g999 heading "applied | total"
column reader_total_messages_dequeued format 999g999g999 heading "dequeued| total"

  select instance_number
       ,  hhour
       ,  apply_name
       ,  nvl (  server_total_messages_applied
               - (lag (server_total_messages_applied, 1, 0) over (order by server_total_messages_applied))
             ,  0)
             as server_total_messages_applied
       ,  nvl (  reader_total_messages_dequeued
               - (lag (reader_total_messages_dequeued, 1, 0) over (order by reader_total_messages_dequeued))
             ,  0)
             as reader_total_messages_dequeued
    from (  select nvl (to_char (stat.instance_number), '-') as instance_number
                 ,  to_char (hour_list.sorthour, 'dd.mm hh24:mi') as hhour
                 --  , stat.STARTUP_TIME
                 ,  nvl (stat.apply_name, '-') as apply_name
                 ,  nvl (stat.server_total_messages_applied, 0) as server_total_messages_applied
                 ,  nvl (stat.reader_total_messages_dequeued, 0) as reader_total_messages_dequeued
              from (  select ah.instance_number
                           ,  to_number (to_char (sh.end_interval_time, 'YYYYMMDDHH24')) as interval_time
                           -- , to_char(ah.STARTUP_TIME,'dd.mm hh24:mi')   as STARTUP_TIME
                           ,  ah.apply_name
                           ,  round (max (server_total_messages_applied)) as server_total_messages_applied
                           ,  round (max (reader_total_messages_dequeued)) as reader_total_messages_dequeued
                           ,  to_number (to_char (min (end_interval_time), 'YYYYMMDDHH24')) as joinhour
                        from dba_hist_streams_apply_sum ah, dba_hist_snapshot sh
                       where     ah.snap_id = sh.snap_id
                             and sh.end_interval_time > trunc (  sysdate
                                                               - 1)
                    group by ah.instance_number                                      -- , to_char(ah.STARTUP_TIME,'dd.mm hh24:mi')
                                               , ah.apply_name, to_number (to_char (sh.end_interval_time, 'YYYYMMDDHH24'))) stat
                 ,                                                                                        -- get the last 24 hours
                  (   select to_date (to_char (  (  sysdate - 1 - (  1 / 24)) + (  1 / 24 * rownum) ,  'YYYYMMDDHH24') ,  'YYYYMMDDHH24') sorthour
                           ,  to_number (to_char (  (  sysdate - 1 - (  1 / 24)) + (  1  / 24 * rownum),  'YYYYMMDDHH24')) joinhour
                        from user_objects
                       where rownum < 26
                    order by sorthour) hour_list
             where hour_list.joinhour = stat.joinhour(+)
          order by hour_list.sorthour asc)
order by hhour
/

-- column component_name             heading 'component|name'     format a24
-- column component_type             heading 'component|type'     format a12
-- column action                         heading 'action'                 format a18
-- column source_database_name     heading 'source|database'     format a10
-- column object_owner                 heading 'object|owner'         format a8
-- column object_name                 heading 'object|name'         format a18
-- column command_type                 heading 'command|type'         format a7
--
-- select component_name
--        ,component_type
--        ,action
--        ,source_database_name
--        ,object_owner
--        ,object_name
--        ,command_type
--          ,ACTION_DETAILS
--          ,to_char(MESSAGE_CREATION_TIME,'dd.mm.yyyy hh24:mi' )
--    from v$streams_message_tracking
-- /

column consumer_name     heading 'capture|process|name'                 format a18
column source_database   heading 'source|database'                      format a10
column sequence#         heading 'sequence|number'                      format 99999999
column name              heading 'required|archived redo log|file name' format a60

/*
select  r.consumer_name
      , r.source_database
      , r.sequence# 
      , r.name 
        , to_char(FIRST_TIME,'dd.mm hh24:mi') as start_time
from dba_registered_archived_log r
   , dba_capture c
where r.consumer_name =  c.capture_name 
  and r.next_scn     >=  c.required_checkpoint_scn
 order by FIRST_TIME,THREAD#  asc          
/
 */
 
 -- clear break