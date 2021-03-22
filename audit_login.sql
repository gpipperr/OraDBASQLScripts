--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Query the audit log entries for logins
--
-- Must be run with dba privileges
--==============================================================================
set linesize 130 pagesize 300 

define DB_USER_NAME = &1


prompt
prompt Parameter 1 = DB_USER_NAME     => &&DB_USER_NAME.
prompt


column username    format a20  heading "DB User|name"
column action_name format a25  heading "Action|name"
column first_log   format a25  heading "First|entry"
column last_log    format a25  heading "Last|entry"
column entries     format 999G999G999 heading "Audit|entries"
column action_count format 999G9999 heading "Action|Count"
column os_username  format a16 heading "User|Name"
column userhost     format a20 heading "User |Host"
column timestamp    format a18  heading "Time"
column  CLIENT_ID  format a18  heading "DB User|Client Id"


ttitle left  "Audit log summary Logins last 12 hours " skip 2

  select                                                                               -- to_char(extended_timestamp,'dd.mm hh24')
        to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0' as timestamp
       ,  instance_number
       ,  count (*) as action_count
       --, username
       ,  action_name
       ,  userhost
       ,  CLIENT_ID
    from dba_audit_trail
   where     extended_timestamp between   sysdate - (  1 / 4) and sysdate
         and action_name like 'LOGOFF%'
-- and username like '&&DB_USER_NAME.'
-- and USERHOST='xxxxxx'
-- and extended_timestamp between to_date('14.11.2014 08:00','dd.mm.yyyy hh24:mi') and to_date('14.11.2014 09:00','dd.mm.yyyy hh24:mi')
group by                                                                                                               -- username
         --,
         -- to_char(extended_timestamp,'dd.mm hh24')
         to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0'
       ,  action_name
       ,  userhost
       ,  instance_number
       ,  CLIENT_ID
order by to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0'

-- to_char(extended_timestamp,'dd.mm hh24') --,username
/


break on instance_number
compute sum of action_count on instance_number

ttitle left  "Audit log summary Logins last 12 hours over 10 minutes " skip 2

  select to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0' as timestamp
       ,  instance_number
       ,  count (*) as action_count
       ,  username
       ,  os_username
       ,  action_name
    from dba_audit_trail
   where     extended_timestamp between   sysdate - (  1/ 4) and sysdate
         and action_name like 'LOGOFF%'
-- and username like '&&DB_USER_NAME.'
-- and USERHOST='srvgpidb01'
-- and instance_number=2
-- and extended_timestamp between to_date('14.11.2014 08:00','dd.mm.yyyy hh24:mi') and to_date('14.11.2014 09:00','dd.mm.yyyy hh24:mi')
group by to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0'
       ,  instance_number
       ,  username
       ,  os_username
       ,  action_name
order by to_char (extended_timestamp, 'dd.mm hh24') || ':' || substr (to_char (extended_timestamp, 'mi'), 1, 1) || '0', username
/



clear break
clear computes


prompt
prompt

ttitle off