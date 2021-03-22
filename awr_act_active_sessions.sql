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
define SERVICE_NAME='%'

prompt
prompt Parameter 1 = DB_USER_NAME     => &&DB_USER_NAME.
prompt Parameter 2 = SERVICE_NAME     => &&SERVICE_NAME.
prompt



column username        format a10
column user_id         format 9999999
column SESSION_ID      format 9999999
column inst_id         format 99
column SQL_ID          format a15
column last_sample_id  format 99999999999
column SAMPLE_TIME     format a18
column serial          format 999999
column SQL_EXEC_START  format a18
column SQL_EXEC_ID     format 9999999999


ttitle "SQL Summary"   skip 2

select count(*)
      ,u.username
      ,ah.user_id
      ,ah.SESSION_ID
      ,ah.inst_id
      ,ah.SQL_ID
      ,max(SAMPLE_ID) as last_sample_id
      ,to_char(max(SAMPLE_TIME),'dd.mm.yyyy hh24:mi') as SAMPLE_TIME
      ,ah.SESSION_SERIAL# as serial
      ,ah.SQL_EXEC_START      
  from GV$ACTIVE_SESSION_HISTORY ah
      ,GV$ACTIVE_SERVICES        ass
      ,dba_users                 u
 where ass.inst_id = ah.inst_id
    and ass.NAME_HASH = ah.SERVICE_HASH
  --and ass.name like '%&&SERVICE_NAME.%'
    and u.username like '%&&DB_USER_NAME.%'
   and u.user_id = ah.user_id
   and ah.SAMPLE_TIME > (sysdate - ((1 / (24 * 60)) * 60))
 group by u.username
         ,ah.user_id
         ,ah.SESSION_ID
         ,ah.inst_id
         ,ah.SQL_ID
         ,ah.SESSION_SERIAL#
         ,ah.SQL_EXEC_ID
         ,ah.SQL_EXEC_START
--having count(*) > 25 * 60
 order by max(SAMPLE_ID) desc
/ 

ttitle "Summary"   skip 2


select count(*)
      ,u.username		
      ,ah.inst_id
		 ,ah.SESSION_ID
		 ,ah.WAIT_CLASS
      ,max(SAMPLE_ID) as last_sample_id
      ,to_char(SAMPLE_TIME,'dd.mm.yyyy hh24:mi') as SAMPLE_TIME     
  from GV$ACTIVE_SESSION_HISTORY ah
      ,GV$ACTIVE_SERVICES        ass
      ,dba_users                 u
 where ass.inst_id = ah.inst_id
    and ass.NAME_HASH = ah.SERVICE_HASH
 --and ass.name like '%&&SERVICE_NAME.%'
   and u.username like '%&&DB_USER_NAME.%'
   and u.user_id = ah.user_id
   and ah.SAMPLE_TIME > (sysdate - ((1 / (24 * 60)) * 60))
 group by u.username
         ,ah.inst_id
			 ,ah.SESSION_ID
			 ,ah.WAIT_CLASS
			, to_char(SAMPLE_TIME,'dd.mm.yyyy hh24:mi')
--having count(*) > 25 * 60
 order by max(SAMPLE_ID) desc
/ 

ttitle "Summary only sessions"   skip 2

select count(*), username,SAMPLE_TIME from (
select count(*)
      ,u.username		
      ,ah.inst_id
		 ,ah.SESSION_ID
      ,max(SAMPLE_ID) as last_sample_id
      ,to_char(SAMPLE_TIME,'dd.mm.yyyy hh24:mi') as SAMPLE_TIME     
  from GV$ACTIVE_SESSION_HISTORY ah
      ,GV$ACTIVE_SERVICES        ass
      ,dba_users                 u
 where ass.inst_id = ah.inst_id
    and ass.NAME_HASH = ah.SERVICE_HASH
    --and ass.name like '%&&SERVICE_NAME.%'
   and u.username like '%&&DB_USER_NAME.%'
   and u.user_id = ah.user_id
    and ah.SAMPLE_TIME > (sysdate - ((1 / (24 * 60)) * 60))
 group by u.username
         ,ah.inst_id
			 ,ah.SESSION_ID
			, to_char(SAMPLE_TIME,'dd.mm.yyyy hh24:mi')
--having count(*) > 25 * 60
 order by max(SAMPLE_ID) desc
)
group by username,SAMPLE_TIME
order by SAMPLE_TIME
/ 

ttitle off