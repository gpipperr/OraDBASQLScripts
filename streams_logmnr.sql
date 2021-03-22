--==============================================================================
-- desc: information about the log miner process
--==============================================================================
set verify off
set linesize 130 pagesize 300 

column ROLE format a16
column SESSION_ID format 99999 head 'Logmr|id'
column WORK_MICROSEC format 9999990.99 head 'Work(sec)'
column OVERHEAD_MICROSEC format 9999990.99 head 'Overead (sec)'


select inst_id
     ,  SESSION_ID
     ,  ROLE
     ,  SID
     ,  spid
     ,  WORK_MICROSEC / 1000000
     ,  OVERHEAD_MICROSEC  / 1000000
     ,  LATCHWAIT
     ,  LATCHSPIN
  from GV$LOGMNR_PROCESS
/

select a.inst_id
       ,  class
       ,  name
       ,  value
    from gv$sesstat a, gv$statname b
   where     value > 0
         and a.statistic# = b.statistic#
         and sid = (select sid
                      from v$logmnr_process
                     where role = 'preparer')
         and a.inst_id = b.inst_id
order by class, name, value
/

column WAIT_CLASS for a16
column event for a45

select a.inst_id
     ,  a.event
     ,  total_waits total_waits
     ,  total_timeouts total_timeouts
     ,  time_waited  / 100  time_waited
     ,  average_wait average_wait
     ,  a.wait_class
     ,  a.wait_class#
  from gv$session_event a, gv$session b
 where     a.sid = b.sid
       and a.sid = (select sid
                      from v$logmnr_process
                     where role = 'preparer')
       and a.inst_id = b.inst_id
/

--
--  Procedure to Manually Coalesce All the IOTs / Indexes Associated with Advanced Queueing Tables to Maintain Enqueue 
--  / Dequeue Performance; Reduce QMON CPU Usage and Redo Generation (Doc ID 271855.1)
--

column INST_ID                        format 99            heading "INST_ID"
column QUEUE_TABLE_ID                 format 9999999            heading "QUEUE|TABLE_ID"
column DEQUEUE_INDEX_BLOCKS_FREED     format 99G999G999    heading "DEQUEUE_INDEX|BLOCKS_FREED"
column HISTORY_INDEX_BLOCKS_FREED     format 99G999G999   heading "HISTORY_INDEX|BLOCKS_FREED"
column TIME_INDEX_BLOCKS_FREED        format 99G999G999   heading "TIME_INDEX|BLOCKS_FREED"
column INDEX_CLEANUP_COUNT            format 99G999G999   heading "INDEX|CLEANUP_COUNT"
column INDEX_CLEANUP_ELAPSED_TIME     format 99G999G999   heading "INDEX_CLEANUP|ELAPSED_TIME"
column INDEX_CLEANUP_CPU_TIME         format 99G999G999   heading "INDEX_CLEANUP|CPU_TIME"
column LAST_INDEX_CLEANUP_TIME        format a20   heading "LAST_INDEX|CLEANUP_TIME"


select INST_ID
     ,  QUEUE_TABLE_ID
     ,  DEQUEUE_INDEX_BLOCKS_FREED
     ,  HISTORY_INDEX_BLOCKS_FREED
     ,  TIME_INDEX_BLOCKS_FREED
     ,  INDEX_CLEANUP_COUNT
     ,  INDEX_CLEANUP_ELAPSED_TIME
     ,  INDEX_CLEANUP_CPU_TIME
     ,  LAST_INDEX_CLEANUP_TIME
  from GV$PERSISTENT_QMN_CACHE
/

--
--QMON Slaves Processes Consuming High Amount of CPU after Upgrade to 11.2.0.4 (Doc ID 1615165.1)
--

 column INST_ID              format 99 heading "INST|ID"
 column TASK_NAME            format a20 heading "TASK|NAME"
 column TASK_NUMBER          format 99999 heading "TASK|NUMBER"
 column TASK_TYPE            format a20 heading "TASK|TYPE"
 column TASK_SUBMIT_TIME     format a10 heading "TASK|SUBMIT_TIME"
 column TASK_READY_TIME      format a10 heading "TASK|READY_TIME"
 column TASK_EXPIRY_TIME     format a10 heading "TASK|EXPIRY_TIME"
 column TASK_START_TIME      format a10 heading "TASK|START_TIME"
 column TASK_STATUS          format a10 heading "TASK|STATUS"
 column SERVER_NAME          format a10 heading "SERVER|NAME"
 column MAX_RETRIES          format 999 heading "MAX|RETRIES"
 column NUM_RUNS             format 999999999999 heading "NUM|RUNS"
 column NUM_FAILURES         format 999 heading "NUM|FAILURES"

  select *
    from gv$qmon_tasks
order by inst_id
       ,  task_type
       ,  task_name
       ,  task_number
/

column inst_id          format 99 heading "inst_id"
column queue_schema     format 99 heading "queue_schema"
column queue_name       format 99 heading "queue_name"
column queue_id         format 9999999 heading "queue_id"
column queue_state      format 99 heading "queue_state"
column startup_time     format 99 heading "startup_time"
column num_msgs         format 99999 heading "num_msgs"
column spill_msgs       format 99 heading "spill_msgs"
column waiting          format 99 heading "waiting"
column ready            format 99 heading "ready"
column expired          format 999999 heading "expired"
column cnum_msgs        format 999999 heading "cnum_msgs"
column cspill_msgs      format 999999 heading "cspill_msgs"
column expired_msgs     format 999999 heading "expired_msgs"
column total_wait       format 99 heading "total_wait"
column average_wait     format 99 heading "average_wait"

  select inst_id
       ,  queue_schema
       ,  queue_name
       ,  queue_id
       ,  queue_state
       ,  startup_time
       ,  num_msgs
       ,  spill_msgs
       ,  waiting
       ,  ready
       ,  expired
       ,  cnum_msgs
       ,  cspill_msgs
       ,  expired_msgs
       ,  total_wait
       ,  average_wait
    from gv$buffered_queues b, gv$aq q
   where b.queue_id = q.qid
order by 1, 2, 3
/

