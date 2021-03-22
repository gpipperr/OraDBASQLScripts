--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   HTML Report for the entries in the audit log
-- see :   http://www.pipperr.de/dokuwiki/doku.php?id=dba:index_column_usage
-- Date:   September 2013
--
--==============================================================================
/*
Timeformat differences between audit$ and audit trail!
select 
    ntimestamp#,
    from_tz(ntimestamp#,'UTC') at local,
    from_tz(ntimestamp#,'UTC') at time zone 'Europe/Berlin'
from sys.aud$;
*/

col SPOOL_NAME_COL new_val SPOOL_NAME
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_audit_log.html','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
  AS SPOOL_NAME_COL
FROM dual
/

set verify off
SET linesize 250 pagesize 2000 

spool &&SPOOL_NAME


set markup html on

ttitle left  "Audit Log entries " skip 2

column username    format a10  heading "DB User|name"
column action_name format a25  heading "Action|name"
column first_log   format a25  heading "First|entry"
column last_log    format a25  heading "Last|entry"


select  os_username
	, username
	, userhost
	, terminal
    , to_char(timestamp,'dd.mm.yyyy hh24:mi:ss') as timestamp
    , owner
    , obj_name
 ,action_name
 ,new_owner
 ,new_name
--,ses_actions
 ,comment_text
 ,sessionid
--,entryid
--,statementid
--,returncode
--,priv_used
--,client_id
-- ,econtext_id
-- ,session_cpu
-- ,extended_timestamp
-- ,proxy_sessionid
 --,global_uid
 --,instance_number
 --,os_process
 --,transactionid
 --,scn
-- ,sql_bind
 ,sql_text
-- ,obj_edition_name
 from dba_audit_object
where timestamp between sysdate- 1 and sysdate
order by timestamp
/
ttitle left  "Audit log summary Login/Logoff last 12 hours " skip 2

select    to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0'
       ,  instance_number
       ,  count (*) as action_count
       , username
       ,  action_name
       ,  userhost
       ,  CLIENT_ID
    from dba_audit_trail
   where extended_timestamp between   sysdate - (  1 / 4) and sysdate
     and action_name like 'LOG%'
group by                                                                                                               -- username
         to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0'
	   ,  username
       ,  action_name
       ,  userhost
       ,  instance_number
       ,  CLIENT_ID
order by to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0'
/


break on instance_number
compute sum of action_count on instance_number

ttitle left  "Audit log summary Login/Logoff last 12 hours over 10 minutes " skip 2

  select to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0'
       ,  instance_number
       ,  count (*) as action_count
       ,  username
       ,  os_username
       ,  action_name
    from dba_audit_trail
   where     extended_timestamp between   sysdate - (  1/ 4) and sysdate
         and action_name like 'LOG%'
group by to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0'
       ,  instance_number
       ,  username
       ,  os_username
       ,  action_name
order by to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0', username
/



clear break
clear computes



ttitle left  "Audit log summary last 12 hours " skip 2
 select  -- to_char(extended_timestamp,'dd.mm hh24')
          to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0'
       ,  instance_number
       ,  username
       ,  action_name
       ,  userhost
       ,  CLIENT_ID
	   ,  action_name
    from dba_audit_trail
   where  extended_timestamp between   sysdate - (  1 / 2) and sysdate
 order by extended_timestamp  
/   
   
set markup html off

spool off
ttitle off

-- works only in a ms windows environment
-- auto start of the result in a browser window
host &&SPOOL_NAME
