--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get Information about long running sessions
-- Src:    see http://docs.oracle.com/cd/B19306_01/server.102/b14237/dynviews_2092.htm
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME   =  &1

prompt
prompt Parameter 1 = Username          => &&USER_NAME.
prompt


ttitle left  "All Long Running Sessions on this DB" skip 2

column inst_id          format 99            heading "Inst|ID"
column username         format a20           heading "DB User|name"
column sid              format 99999         heading "SID"
column serial#          format 99999         heading "Serial"
column START_TIME       format a16     heading "Start|Time"
column LAST_UPDATE_TIME format a16     heading "Last Update|Time"
column TIMESTAMP        format a16     heading "Timestamp"
column ELAPSED_SECONDS  format 99G999  heading "Elapsed|Seconds"
column TIME_REMAINING   format 99G999  heading "Time|Renaming"
column MESSAGE          format a80     heading "Message"  FOLD_BEFORE   
column MESSAGE          format 9G999D00 heading "% Done"

  select inst_id
       ,  sid
       ,  serial#
       ,  username
       ,  to_char (START_TIME, 'dd.mm.yyyy hh24:mi') as START_TIME
       ,  to_char (LAST_UPDATE_TIME, 'dd.mm.yyyy hh24:mi') as LAST_UPDATE_TIME
       --, to_char(TIMESTAMP,'dd.mm.yyyy hh24:mi') as TIMESTAMP
       ,  ELAPSED_SECONDS
       ,  TIME_REMAINING
       ,  message
	   , (sofar/totalwork)*100 as DONE   
    from gv$session_longops
   where username like upper ('%&&USER_NAME.%') and username not in ('SYS')
   -- and TIME_REMAINING > 0
   -- and TOTALWORK > SOFAR
order by username, inst_id, TIME_REMAINING desc
/
