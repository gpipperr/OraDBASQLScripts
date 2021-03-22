--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc: get Information about the last blocking sessions
--   
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt


set linesize 130 pagesize 300 
define SNAPTIME=10

prompt
prompt Snaptime => &&SNAPTIME.
prompt


col SPOOL_NAME_COL new_val SPOOL_NAME
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_blocking_sessions_last_&&SNAPTIME._minutes.html','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
  AS SPOOL_NAME_COL
FROM dual
/

spool &&SPOOL_NAME

set markup html on

column username        format a10
column user_id         format 9999999
column SESSION_ID      format 9999999
column inst_id         format 99
column SQL_ID          format a15
column last_sample_id  format 99999999999
column SAMPLE_TIME     format a18
column serial          format 999999
column SQL_EXEC_START  format a18  heading "SQL|Start at"
column BLOCKING_SESSION_STATUS format a10 heading "Block Se|Status"
column BLOCKING_SESSION  format 999999 heading "Block|Session"
column BLOCKING_INST_ID  format 999 heading "Block|Inst"


ttitle "Get all sessions blocked by this Sessions"   skip 2

set verify off
SET linesize 130 pagesize 4000 

select count(*)
      ,u.username
      ,ah.user_id
      ,ah.SESSION_ID
      ,ah.inst_id
      ,ah.SQL_ID
      ,max(SAMPLE_ID) as last_sample_id
		,min(SAMPLE_ID) as frist_sample_id
      ,to_char(max(SAMPLE_TIME),'dd.mm.yyyy hh24:mi') as MAX_SAMPLE_TIME
		,to_char(min(SAMPLE_TIME),'dd.mm.yyyy hh24:mi') as MIN_SAMPLE_TIME
      ,ah.SESSION_SERIAL# as serial
      ,ah.SQL_EXEC_START      
		,ah.BLOCKING_SESSION_STATUS
		,ah.BLOCKING_SESSION
		,ah.BLOCKING_INST_ID	
  from GV$ACTIVE_SESSION_HISTORY ah
      ,GV$ACTIVE_SERVICES        ass
      ,dba_users                 u
 where ass.inst_id = ah.inst_id
    and ass.NAME_HASH = ah.SERVICE_HASH
 	 and ah.BLOCKING_SESSION is not null
	 and u.user_id = ah.user_id
    and ah.SAMPLE_TIME > (sysdate - ((1 / (24 * 60)) * &SNAPTIME.))	
 group by u.username
         ,ah.user_id
         ,ah.SESSION_ID
         ,ah.inst_id
         ,ah.SQL_ID
         ,ah.SESSION_SERIAL#
         ,ah.SQL_EXEC_START
			,ah.BLOCKING_SESSION_STATUS
			,ah.BLOCKING_SESSION
			,ah.BLOCKING_INST_ID		
order by max(SAMPLE_ID) desc
/ 


---------- Join with the sample id to the get the blocking session

ttitle "Get all sessions for this  BLOCK_SESSION ID'd in the blocking time period"   skip 2

select u.username
      ,ah.user_id
      ,ah.SESSION_ID Blocker_Session
		,ah.inst_id
		,blocker.SESSION_ID blocked_Session
		,blocker.SESSION_ID blocked_Session_instance
		,blocker.SQL_ID blocked_sql     
		,ah.PROGRAM
      ,ah.SQL_ID
      ,ah.SAMPLE_ID as sample_id
      ,to_char(ah.SAMPLE_TIME,'dd.mm.yyyy hh24:mi') as SAMPLE_TIME
      ,ah.SESSION_SERIAL# as serial
      ,ah.SQL_EXEC_START      		
  from GV$ACTIVE_SESSION_HISTORY ah
      ,GV$ACTIVE_SERVICES        ass
		,GV$ACTIVE_SESSION_HISTORY blocker
      ,dba_users                 u
 where  ass.inst_id = ah.inst_id
    and ass.NAME_HASH = ah.SERVICE_HASH
    and ah.SAMPLE_ID =blocker.SAMPLE_ID
	 and ah.SESSION_ID =blocker.BLOCKING_SESSION
	 and u.user_id = ah.user_id
	 and ah.inst_id=blocker.inst_id
	 and ah.SAMPLE_TIME=blocker.SAMPLE_TIME
    and ah.SAMPLE_TIME > (sysdate - ((1 / (24 * 60)) * &SNAPTIME.))	 
 order by ah.SAMPLE_ID desc
/ 

ttitle off

set markup html off
spool off
ttitle off

-- works only in a ms windows environment
-- auto start of the result in a browser window

host &&SPOOL_NAME