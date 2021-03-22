-- ======================================================
-- GPI - Gunther Pippèrr
-- Desc : Check the status of the standby DB for Gaps
-- ======================================================
-- http://arjudba.blogspot.de/2011/03/scripts-to-monitor-data-guard.html
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

set serveroutput on size 1000000

column dest_name  format a20
column process    format a10
column status     format a10
column error      format a20
column state      format a10
column log_sequence  format 999999999

prompt ... Check the DB enviroment

  select dest_name
       ,  process
       ,  status
       ,  error
    from v$archive_dest
   where status != 'INACTIVE'
order by status
/

column process    format 999999999

  select process
       ,  status
       ,  log_sequence
       ,  state
    from v$archive_processes
   where status != 'STOPPED'
order by status
/

prompt ...
prompt ... check Status of the Standby processes

column process    format a10

select process
     ,  status
     ,  client_process
     ,  sequence#
     ,  block#
     ,  active_agents
     ,  known_agents
  from v$managed_standby
/

--==============================================================================
-- Where the types of PROCESS may be,
-- - RFS - Remote file server
-- - MRP0 - Detached recovery server process
-- - MR(fg) - Foreground recovery session
-- - ARCH - Archiver process
-- - FGRD
-- - LGWR
-- - RFS(FAL)
-- - RFS(NEXP)
-- - LNS - Network server process
--
-- The process status may be,
-- UNUSED - No active process
-- ALLOCATED - Process is active but not currently connected to a primary database
-- CONNECTED - Network connection established to a primary database
-- ATTACHED - Process is actively attached and communicating to a primary database
-- IDLE - Process is not performing any activities
-- ERROR - Process has failed
-- OPENING - Process is opening the archived redo log
-- CLOSING - Process has completed archival and is closing the archived redo log
-- WRITING - Process is actively writing redo data to the archived redo log
-- RECEIVING - Process is receiving network communication
-- ANNOUNCING - Process is announcing the existence of a potential dependent archived redo log
-- REGISTERING - Process is registering the existence of a completed dependent archived redo log
-- WAIT_FOR_LOG - Process is waiting for the archived redo log to be completed
-- WAIT_FOR_GAP - Process is waiting for the archive gap to be resolved
-- APPLYING_LOG - Process is actively applying the archived redo log to the standby database
--
-- The client process may be,
-- Archival - Foreground (manual) archival process (SQL)
-- ARCH - Background ARCn process
-- LGWR - Background LGWR process
--==============================================================================

-------
prompt ...
prompt Check log last applied to last received log time


column info format a120

select 'Last Applied  : ' || to_char (next_time, 'dd.mm.yyyy hh24:mi') info
  from v$archived_log
 where sequence# = (select max (sequence#)
                      from v$archived_log
                     where applied = 'YES')
union
select 'Last Received : ' || to_char (next_time, 'dd.mm.yyyy hh24:mi') info
  from v$archived_log
 where sequence# = (select max (sequence#) from v$archived_log)
/

-------
prompt ...
prompt Verify the last sequence# received and the last sequence# applied to standby database

select al.thrd "Thread", almax "Last Seq Received", lhmax "Last Seq Applied"
  from (  select thread# thrd, max (sequence#) almax
            from v$archived_log
           where resetlogs_change# = (select resetlogs_change# from v$database)
        group by thread#) al
     ,  (  select thread# thrd, max (sequence#) lhmax
             from v$log_history
            where first_time = (select max (first_time) from v$log_history)
         group by thread#) lh
 where al.thrd = lh.thrd
/


-------------
prompt ...
prompt transport lag time, apply lag and apply finish time

select name, value, unit from v$dataguard_stats
union
select null, null, ' ' from dual
union
select null, null, 'time computed: ' || min (time_computed) from v$dataguard_stats
/


------- Check if that works -------

prompt ------- works only with logical or open physical standby -------
prompt ------- or oracle streams --------------------------------------
prompt ...
prompt ... check if gap exists

  select thread
       ,  consumer_name
       ,    seq + 1 first_seq_missing
       ,    seq + (  next_seq - seq - 1)  last_seq_missing
       ,    next_seq - seq - 1 missing_count
    from (select THREAD# thread
               ,  SEQUENCE# seq
               ,  lead (SEQUENCE#, 1, SEQUENCE#) over (partition by thread# order by sequence#) next_seq
               ,  consumer_name
            from dba_registered_archived_log
           where RESETLOGS_CHANGE# = (select max (RESETLOGS_CHANGE#) from dba_registered_archived_log))
   where   next_seq - seq > 1
order by 1, 2
/

----------------------------------------